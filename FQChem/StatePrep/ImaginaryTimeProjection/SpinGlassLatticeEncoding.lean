module

public import FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassLatticeGadgets
public import FQChem.StatePrep.ImaginaryTimeProjection.CubicSpinGlass
import Mathlib.Tactic

/-! # Encoding routed clauses into a finite cubic spin-glass Hamiltonian

The signed lattice compiler has one occupied entry for each copy bond, each
horizontal row segment, each column segment and each clause-rim edge. We verify
that no two entries designate the same unordered spin pair.
-/

@[expose] public section
namespace FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT.Lattice
open IsingSign

private theorem colInjective {m} : Function.Injective (@col m) := by
  rintro ⟨a,b⟩ ⟨c,d⟩ h
  dsimp [col] at h
  have h₁ : a.val = c.val := by omega
  have h₂ : b.val = d.val := by omega
  exact Prod.ext (Fin.ext h₁) (Fin.ext h₂)

private theorem wireInjective {n m} (f : Formula n m) : Function.Injective (wirePosition f) := by
  rintro (⟨x,i⟩ | p | ⟨p,y⟩) (⟨u,v⟩ | q | ⟨q,z⟩) h <;> simp [wirePosition] at h ⊢
  · exact ⟨Fin.ext h.1, Fin.ext h.2⟩
  · exact colInjective h.1
  · obtain rfl := colInjective h.1
    have hk : y = z := Fin.ext h.2
    subst z
    exact ⟨rfl,HEq.rfl⟩

private theorem rimInjective {m} : Function.Injective (fun p : Fin m × Fin 6 => rimPosition p.1 p.2) := by
  rintro ⟨c,i⟩ ⟨d,j⟩ h
  fin_cases i <;> fin_cases j <;> simp [rimPosition] at h ⊢ <;>
    first | exact Fin.ext (by omega) | omega

private theorem positionInjective {n m} (f : Formula n m) : Function.Injective (position f) := by
  have dis (w : Wire f) (d : Fin m × Fin 6) : wirePosition f w ≠ rimPosition d.1 d.2 := by
    obtain ⟨c,i⟩ := d
    rcases w with (⟨x,v⟩|p|⟨p,y⟩) <;> fin_cases i <;> simp [wirePosition,rimPosition]
  rintro (p|p) (q|q) h
  · exact congrArg Sum.inl (wireInjective f h)
  · exact (dis p q h).elim
  · exact (dis q p h.symm).elim
  · exact congrArg Sum.inr (rimInjective h)

abbrev Grid (n m : ℕ) := Coord (m*3+1) (n+1) 3

abbrev size (n m : ℕ) := (m*3+1)*((n+1)*3)

abbrev fits (n m : ℕ) (p : Site) : Prop := p.x < m*3+1 ∧ p.y < n+1 ∧ p.z < 3

private theorem wireBounds {n m} (f : Formula n m) (w : Wire f) :
    fits n m (wirePosition f w).start ∧ fits n m (wirePosition f w).finish := by
  rcases w with (⟨x,i⟩ | ⟨c,i⟩ | ⟨⟨c,i⟩,y⟩) <;>
    simp [wirePosition, Position.finish, fits, col] <;> omega

private theorem rimBounds {n m} (c : Fin m) (i : Fin 6) :
    fits n m (rimPosition c i).start ∧ fits n m (rimPosition c i).finish := by
  fin_cases i <;> simp [rimPosition, Position.finish, fits] <;> omega

theorem bounds {n m} (f : Formula n m) (e : Edge f) :
    fits n m (position f e).start ∧ fits n m (position f e).finish := by
  rcases e with w|⟨c,i⟩
  · exact wireBounds f w
  · exact rimBounds c i

def asGrid {n m} (p : Site) (h : fits n m p) : Grid n m :=
  (⟨p.x,h.1⟩,⟨p.y,h.2.1⟩,⟨p.z,h.2.2⟩)

def asSite {n m} (p : Grid n m) : Site := ⟨p.1.val,p.2.1.val,p.2.2.val⟩

private theorem asSite_asGrid {n m} (p : Site) (h : fits n m p) : asSite (asGrid p h) = p := rfl

def direction : Axis → Fin 3 | .x => 0 | .y => 1 | .z => 2

def slot {n m} (f : Formula n m) (e : Edge f) : Grid n m × Fin 3 :=
  (asGrid _ (bounds f e).1, direction (position f e).axis)

private theorem forwardStep {n m} (p : Position) (h : fits n m p.start) (k : fits n m p.finish) :
    forward (asGrid p.start h) (direction p.axis) = asGrid p.finish k := by
  obtain ⟨⟨x,y,z⟩,a⟩ := p
  cases a <;> simp [Position.finish, fits] at k <;>
    simp [forward, asGrid, direction, Position.finish, forwardCoordinate, k]

private theorem stepNe (p : Position) : p.start ≠ p.finish := by
  obtain ⟨⟨x,y,z⟩,a⟩ := p
  cases a <;> simp [Position.finish]

private theorem orderedEdge {p q : Position} (h : p.start=q.start ∧ p.finish=q.finish) : p=q := by
  obtain ⟨⟨x,y,z⟩,a⟩ := p
  obtain ⟨⟨x',y',z'⟩,b⟩ := q
  cases a <;> cases b <;> simp_all [Position.finish] <;> omega

private theorem neverReverse {p q : Position} (h : p.start=q.finish ∧ p.finish=q.start) : False := by
  obtain ⟨⟨x,y,z⟩,a⟩ := p
  obtain ⟨⟨x',y',z'⟩,b⟩ := q
  cases a <;> cases b <;> simp_all [Position.finish] <;> omega

def bondMask {n m} (f : Formula n m) (e : Edge f) : Spin (size n m) :=
  pairMask (siteIndex _ _ _ (asGrid _ (bounds f e).1)) (siteIndex _ _ _ (asGrid _ (bounds f e).2))

private theorem indexedNe {n m} (f : Formula n m) (e : Edge f) :
    siteIndex _ _ _ (asGrid _ (bounds f e).1) ≠ siteIndex _ _ _ (asGrid _ (bounds f e).2) :=
  (siteIndex _ _ _).injective.ne (fun h => stepNe (position f e) (congrArg asSite h))

private theorem maskUnique {n m} (f : Formula n m) : Function.Injective (bondMask f) := by
  intro e d h
  have both := maskUnordered (indexedNe f e) h
  simp only [Equiv.apply_eq_iff_eq] at both
  rcases both with he|he
  · exact positionInjective f (orderedEdge ⟨congrArg asSite he.1,congrArg asSite he.2⟩)
  · exact (neverReverse ⟨show (position f e).start = (position f d).finish from congrArg asSite he.1,
      congrArg asSite he.2⟩).elim

noncomputable def occupied {n m} (f : Formula n m) (p : Grid n m) (d : Fin 3) : Bool :=
  decide ((p,d) ∈ Finset.univ.image (slot f))

noncomputable def negativeMasks {n m} (f : Formula n m) : Finset (Spin (size n m)) :=
  (Finset.univ.filter (fun e => sign f e)).image (bondMask f)

noncomputable def model {n m} (f : Formula n m) : Glass (size n m) :=
  cubicGlass (occupied f) (negativeMasks f)

private theorem permitted {n m} (f : Formula n m) (e : Edge f) : (slot f e).1 ≠ forward (slot f e).1 (slot f e).2 := by
  dsimp [slot]
  rw [forwardStep _ _ (bounds f e).2]
  exact fun h => stepNe _ (congrArg asSite h)

theorem sparseBonds {n m} (f : Formula n m) :
    (model f).bonds = Finset.univ.image (bondMask f) := by
  have active : Finset.univ.filter (fun p : Grid n m × Fin 3 =>
      occupied f p.1 p.2 ∧ p.1 ≠ forward p.1 p.2) = Finset.univ.image (slot f) := by
    ext p
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, occupied, decide_eq_true_eq]
    exact and_iff_left_of_imp fun h => by
      change p ∈ Finset.univ.image (slot f) at h
      obtain ⟨e, _, rfl⟩ := Finset.mem_image.mp h
      exact permitted f e
  change Finset.image _ (Finset.filter _ Finset.univ) = _
  rw [active, Finset.image_image]
  apply Finset.image_congr
  intro e _
  simp only [Function.comp_apply, slot, bondMask, forwardStep _ _ (bounds f e).2]

theorem compiledBondCount {n m} (f : Formula n m) :
    (model f).bonds.card = Fintype.card (Edge f) := by
  rw [sparseBonds, Finset.card_image_of_injective _ (maskUnique f), Finset.card_univ]

theorem signedCoupling {n m} (f : Formula n m) (e : Edge f) :
    (model f).coupling (bondMask f e) = if sign f e then -1 else 1 := by
  rw [Glass.coupling, sparseBonds]
  simp only [Finset.mem_image_of_mem _ (Finset.mem_univ e), ite_true]
  change (if decide (bondMask f e ∈ negativeMasks f) then (-1:ℤ) else 1) = _
  simp [negativeMasks, Finset.mem_image, (maskUnique f).eq_iff]

/-- Any infinite-lattice labeling restricts to the finite, open-boundary cubic model;
the two energies agree term by term. -/
theorem finiteEnergy {n m} (f : Formula n m) (s : Site → Bool) :
    (model f).energy (s ∘ asSite ∘ (siteIndex _ _ _).symm) = energy f s := by
  rw [Glass.energy, sparseBonds, Finset.sum_image (maskUnique f).injOn, ← Finset.sum_neg_distrib]
  have one (e : Edge f) :
      -((model f).coupling (bondMask f e) * character (s ∘ asSite ∘ (siteIndex _ _ _).symm) (bondMask f e)) =
      term s (sign f e) (position f e) := by
    rw [signedCoupling, bondMask, character_pair _ _ _ (indexedNe f e)]
    simp only [Function.comp_apply, Equiv.symm_apply_apply, asSite_asGrid]
    exact bondCharacter ..
  simp_rw [one]
  rw [Fintype.sum_sum_type, Fintype.sum_prod_type]
  rfl

private def extend {n m} (s : Spin (size n m)) (p : Site) := if h : fits n m p then
  s (siteIndex _ _ _ (asGrid p h)) else false

private theorem restrictExtend {n m} (s : Spin (size n m)) :
    extend s ∘ asSite ∘ (siteIndex _ _ _).symm = s := by
  funext i
  obtain ⟨p,rfl⟩ := (siteIndex _ _ _).surjective i
  have inside : fits n m (asSite p) := ⟨p.1.isLt,p.2.1.isLt,p.2.2.isLt⟩
  simp only [Function.comp_apply, Equiv.symm_apply_apply, extend, dite_eq_left inside]
  rfl

/-- The concrete cubicGlass Hamiltonian has a classical state below the compiled
threshold exactly when the NAE formula is satisfiable. Its box has only three layers. -/
theorem cubicThreshold {n m} (f : Formula n m) : feasible (model f) (target f) ↔ Satisfiable f := by
  rw [← latticeThreshold]
  constructor
  · rintro ⟨s,hs⟩
    refine ⟨extend s,?_⟩
    rwa [← finiteEnergy, restrictExtend]
  · rintro ⟨s,hs⟩
    exact ⟨_, (finiteEnergy f s).le.trans hs⟩

end FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT.Lattice
