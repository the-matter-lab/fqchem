module

public import FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassThreeSAT
import Mathlib.Tactic

/-! # Routing not-all-equal clauses on a three-layer cubic lattice

In layer zero every variable has its own horizontal row. Each occurrence gets
a private column in layer one, with a signed vertical contact to its variable.
At the front of three consecutive columns a frustrated six-cycle joins the
three literal spins. Its return path runs through layer two.
-/

@[expose] public section
namespace FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT.Lattice
open IsingSign

structure Site where
  x : ℕ
  y : ℕ
  z : ℕ
  deriving DecidableEq

inductive Axis | x | y | z deriving DecidableEq

structure Position where
  start : Site
  axis : Axis
  deriving DecidableEq

def Position.finish (p : Position) : Site :=
  match p.axis with
  | .x => {p.start with x := p.start.x+1}
  | .y => {p.start with y := p.start.y+1}
  | .z => {p.start with z := p.start.z+1}

def col {m : ℕ} (p : Fin m × Fin 3) := p.1.val*3+p.2.val

abbrev Wire {n m} (f : Formula n m) := (Fin (m*3) × Fin n) ⊕
  (Fin m × Fin 3) ⊕ (Σ p : Fin m × Fin 3, Fin ((f p.1 p.2).var.val+1))

def wirePosition {n m} (f : Formula n m) : Wire f → Position
  | .inl (x,i) => ⟨⟨x,i.val+1,0⟩,.x⟩
  | .inr (.inl p) => ⟨⟨col p,(f p.1 p.2).var.val+1,0⟩,.z⟩
  | .inr (.inr ⟨p,y⟩) => ⟨⟨col p,y.val,1⟩,.y⟩

def wireNegative {n m} (f : Formula n m) : Wire f → Bool
  | .inr (.inl p) => (f p.1 p.2).neg
  | _ => false

def rimPosition {m} (c : Fin m) (k : Fin 6) : Position :=
  ![⟨⟨c.val*3,0,1⟩,.x⟩, ⟨⟨c.val*3+1,0,1⟩,.x⟩, ⟨⟨c.val*3+2,0,1⟩,.z⟩,
    ⟨⟨c.val*3+1,0,2⟩,.x⟩, ⟨⟨c.val*3,0,2⟩,.x⟩, ⟨⟨c.val*3,0,1⟩,.z⟩] k

def rimNegative (k : Fin 6) := ![true,true,false,false,false,true] k

abbrev Edge {n m} (f : Formula n m) := Wire f ⊕ (Fin m × Fin 6)

def position {n m} (f : Formula n m) : Edge f → Position :=
  Sum.elim (wirePosition f) (fun q => rimPosition q.1 q.2)

def sign {n m} (f : Formula n m) : Edge f → Bool :=
  Sum.elim (wireNegative f) (fun q => rimNegative q.2)

def term (s : Site → Bool) (neg : Bool) (p : Position) : ℤ :=
  bond neg (s p.start) (s p.finish)

def rimEnergy {m} (s : Site → Bool) (c : Fin m) :=
  ∑ k, term s (rimNegative k) (rimPosition c k)

noncomputable def energy {n m} (f : Formula n m) (s : Site → Bool) : ℤ :=
  (∑ w : Wire f, term s (wireNegative f w) (wirePosition f w)) + ∑ c : Fin m, rimEnergy s c

def target {n m} (f : Formula n m) : ℤ := -(Fintype.card (Wire f) : ℤ)-4*m

def cycleScore (a b c x y z : Bool) :=
  bond true a b + bond true b c + bond false c z + bond false y z + bond false x y + bond true a x

private theorem rimFormula {m} (s : Site → Bool) (c : Fin m) :
    rimEnergy s c = cycleScore (s ⟨c.val*3,0,1⟩) (s ⟨c.val*3+1,0,1⟩)
      (s ⟨c.val*3+2,0,1⟩) (s ⟨c.val*3,0,2⟩) (s ⟨c.val*3+1,0,2⟩) (s ⟨c.val*3+2,0,2⟩) := by
  simp [rimEnergy, Fin.sum_univ_succ, term, rimNegative, rimPosition, Position.finish, cycleScore]
  abel

private theorem cycleMinimum : ∀ a b c x y z : Bool, -4 ≤ cycleScore a b c x y z ∧
    (cycleScore a b c x y z = -4 → nae a b c) ∧ (nae a b c → cycleScore a b c c c c = -4) := by
  unfold nae
  decide

private theorem wireMinimum : ∀ neg a b : Bool, -1 ≤ bond neg a b ∧
    (bond neg a b = -1 ↔ (a ^^ neg) = b) := by decide

private theorem optimal {n m} (f : Formula n m) (s : Site → Bool) :
    energy f s ≤ target f ↔
    (∀ w, term s (wireNegative f w) (wirePosition f w) = -1) ∧
    (∀ c : Fin m, rimEnergy s c = -4) := by
  let W := fun w : Wire f => term s (wireNegative f w) (wirePosition f w)
  have hw (w : Wire f) : 0 ≤ W w + 1 :=
    neg_le_iff_add_nonneg.mp (wireMinimum (wireNegative f w) _ _).1
  have hr (c : Fin m) : 0 ≤ rimEnergy s c + 4 := by
    rw [rimFormula]
    exact neg_le_iff_add_nonneg.mp (cycleMinimum ..).1
  have eq : (∑ w, (W w+1)) + (∑ c : Fin m, (rimEnergy s c+4)) = energy f s - target f := by
    simp [W, energy, target, Finset.sum_add_distrib]; ring
  constructor
  · intro h
    have wz := Finset.sum_nonneg (fun w (_ : w ∈ Finset.univ) => hw w)
    have rz := Finset.sum_nonneg (fun c (_ : c ∈ Finset.univ) => hr c)
    have zero := (add_eq_zero_iff_of_nonneg wz rz).mp
      (le_antisymm (eq.trans_le (sub_nonpos.mpr h)) (add_nonneg wz rz))
    rw [Finset.sum_eq_zero_iff_of_nonneg (fun i _ => hw i),
      Finset.sum_eq_zero_iff_of_nonneg (fun i _ => hr i)] at zero
    exact ⟨fun w => eq_neg_of_add_eq_zero_left (zero.1 w (Finset.mem_univ w)),
      fun c => eq_neg_of_add_eq_zero_left (zero.2 c (Finset.mem_univ c))⟩
  · rintro ⟨w,r⟩
    simp [energy, w, r, target]
    omega

private theorem rowAgreement {n m} (f : Formula n m) (s : Site → Bool)
    (w : ∀ e, term s (wireNegative f e) (wirePosition f e) = -1) (v : Fin n) :
    ∀ x ≤ m*3, s ⟨x,v.val+1,0⟩ = s ⟨0,v.val+1,0⟩ := by
  intro x hx
  induction x with
  | zero => rfl
  | succ x ih =>
    have h := w (.inl (⟨x,by omega⟩,v))
    change bond false (s ⟨x,v.val+1,0⟩) (s ⟨x+1,v.val+1,0⟩) = -1 at h
    have step := (wireMinimum false _ _).2.mp h
    simp only [Bool.xor_false] at step
    exact step.symm.trans (ih (by omega))

private theorem columnAgreement {n m} (f : Formula n m) (s : Site → Bool)
    (w : ∀ e, term s (wireNegative f e) (wirePosition f e) = -1) (p : Fin m × Fin 3) :
    ∀ y ≤ (f p.1 p.2).var.val+1, s ⟨col p,y,1⟩ = s ⟨col p,0,1⟩ := by
  intro y hy
  induction y with
  | zero => rfl
  | succ y ih =>
    have h := w (.inr (.inr ⟨p,⟨y,by omega⟩⟩))
    change bond false (s ⟨col p,y,1⟩) (s ⟨col p,y+1,1⟩) = -1 at h
    have step := (wireMinimum false _ _).2.mp h
    simp only [Bool.xor_false] at step
    exact step.symm.trans (ih (by omega))

private theorem decodedLiteral {n m} (f : Formula n m) (s : Site → Bool)
    (w : ∀ e, term s (wireNegative f e) (wirePosition f e) = -1) (p : Fin m × Fin 3) :
    (f p.1 p.2).eval (fun v => s ⟨0,v.val+1,0⟩) = s ⟨col p,0,1⟩ := by
  have h := (wireMinimum ..).2.mp (w (.inr (.inl p)))
  change (s ⟨col p,(f p.1 p.2).var.val+1,0⟩ ^^ (f p.1 p.2).neg) =
    s ⟨col p,(f p.1 p.2).var.val+1,1⟩ at h
  rw [rowAgreement f s w _ _ (by dsimp [col]; omega), columnAgreement f s w _ _ (by omega)] at h
  exact h

def liftSpin {n m} (f : Formula n m) (s : Fin n → Bool) (p : Site) : Bool :=
  if p.z = 0 then
    if h : p.y-1 < n then s ⟨p.y-1,h⟩ else false
  else if h : p.x/3 < m then
    if p.z=1 then (f ⟨p.x/3,h⟩ ⟨p.x%3,Nat.mod_lt _ (by decide)⟩).eval s
    else (f ⟨p.x/3,h⟩ 2).eval s
  else false

private theorem liftedBase {n m} (f : Formula n m) (s : Fin n → Bool) (x : ℕ) (v : Fin n) :
    liftSpin f s ⟨x,v.val+1,0⟩ = s v := by simp [liftSpin]

private theorem liftedOccurrence {n m} (f : Formula n m) (s : Fin n → Bool) (p : Fin m × Fin 3)
    (y : ℕ) : liftSpin f s ⟨col p,y,1⟩ = (f p.1 p.2).eval s := by
  have h : col p / 3 = p.1.val := by dsimp [col]; omega
  have k : col p % 3 = p.2.val := by dsimp [col]; omega
  simp [liftSpin,h,k]

private theorem liftedReturn {n m} (f : Formula n m) (s : Fin n → Bool) (p : Fin m × Fin 3) :
    liftSpin f s ⟨col p,0,2⟩ = (f p.1 2).eval s := by
  have h : col p / 3 = p.1.val := by dsimp [col]; omega
  simp [liftSpin,h]

/-- There is a configuration attaining the cubic lattice threshold exactly when the
source NAE-3SAT formula is satisfiable. Every bond is a unit axis step. -/
theorem latticeThreshold {n m} (f : Formula n m) :
    (∃ s : Site → Bool, energy f s ≤ target f) ↔ Satisfiable f := by
  constructor
  · rintro ⟨s,hs⟩
    obtain ⟨w,r⟩ := (optimal f s).mp hs
    refine ⟨fun v => s ⟨0,v.val+1,0⟩, fun c => ?_⟩
    rw [decodedLiteral f s w (c,0), decodedLiteral f s w (c,1), decodedLiteral f s w (c,2)]
    have h := r c
    rw [rimFormula] at h
    exact (cycleMinimum ..).2.1 h
  · rintro ⟨s,hs⟩
    refine ⟨liftSpin f s,(optimal f _).mpr ⟨?_,?_⟩⟩
    · rintro (⟨x,v⟩ | p | ⟨p,y⟩)
      · change bond false (liftSpin f s ⟨x,v.val+1,0⟩) (liftSpin f s ⟨x+1,v.val+1,0⟩) = -1
        simp [liftedBase,bond]
      · change bond (f p.1 p.2).neg (liftSpin f s ⟨col p,(f p.1 p.2).var.val+1,0⟩)
          (liftSpin f s ⟨col p,(f p.1 p.2).var.val+1,1⟩) = -1
        simp [liftedBase,liftedOccurrence,bond,Literal.eval]
      · change bond false (liftSpin f s ⟨col p,y,1⟩) (liftSpin f s ⟨col p,y.val+1,1⟩) = -1
        simp [liftedOccurrence,bond]
    · intro c
      rw [rimFormula]
      change cycleScore (liftSpin f s ⟨col (c,0),0,1⟩) (liftSpin f s ⟨col (c,1),0,1⟩)
        (liftSpin f s ⟨col (c,2),0,1⟩) (liftSpin f s ⟨col (c,0),0,2⟩)
        (liftSpin f s ⟨col (c,1),0,2⟩) (liftSpin f s ⟨col (c,2),0,2⟩) = -4
      simp only [liftedOccurrence,liftedReturn]
      exact (cycleMinimum _ _ _ false false false).2.2 (hs c)

end FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT.Lattice
