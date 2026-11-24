module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticComparison
import Mathlib.Tactic

/-! # Satisfiability reduced to a signed two-body Ising energy

Each not-all-equal clause has three fresh spins on an antiferromagnetic triangle.
Three signed bonds copy the literal values to its corners. The six bonds have
energy at least −4, with equality precisely when all copies agree with their
literals and the clause is satisfied. Variables and literals may be repeated.
This construction uses arbitrary pairs of sites.
-/

@[expose] public section
namespace FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT
open IsingSign MeasureTheory

structure Literal (n : ℕ) where
  var : Fin n
  neg : Bool
  deriving DecidableEq

abbrev Formula (n m : ℕ) := Fin m → Fin 3 → Literal n

def Literal.eval {n} (l : Literal n) (s : Fin n → Bool) := s l.var ^^ l.neg

def nae (a b c : Bool) : Prop := a ≠ b ∨ b ≠ c

def Satisfiable {n m} (f : Formula n m) : Prop :=
  ∃ s, ∀ c, nae ((f c 0).eval s) ((f c 1).eval s) ((f c 2).eval s)

abbrev Vertex (n m : ℕ) := Fin n ⊕ (Fin m × Fin 3)

def vertexIndex (n m : ℕ) : Vertex n m ≃ Fin (n + m*3) :=
  ((Equiv.refl (Fin n)).sumCongr finProdFinEquiv).trans finSumFinEquiv

/-- An executable edge list with exactly six entries per not-all-equal clause. -/
def endpoints {n m} (f : Formula n m) (c : Fin m) (k : Fin 6) :
    Vertex n m × Vertex n m :=
  ![(.inl (f c 0).var, .inr (c,0)), (.inl (f c 1).var, .inr (c,1)),
    (.inl (f c 2).var, .inr (c,2)), (.inr (c,0), .inr (c,1)),
    (.inr (c,1), .inr (c,2)), (.inr (c,0), .inr (c,2))] k

def negative {n m} (f : Formula n m) (c : Fin m) (k : Fin 6) : Bool :=
  ![(f c 0).neg, (f c 1).neg, (f c 2).neg, true, true, true] k

def mask {n m} (f : Formula n m) (e : Fin m × Fin 6) : Spin (n + m*3) :=
  let p := endpoints f e.1 e.2
  pairMask (vertexIndex n m p.1) (vertexIndex n m p.2)

private theorem distinctEnds {n m} (f : Formula n m) (c : Fin m) (k : Fin 6) :
    (endpoints f c k).1 ≠ (endpoints f c k).2 := by
  fin_cases k <;> simp [endpoints]

theorem maskUnordered {n} {a b c d : Fin n} (hab : a ≠ b)
    (h : pairMask a b = pairMask c d) : (a=c ∧ b=d) ∨ (a=d ∧ b=c) := by
  have ha : a=c ∨ a=d := by simpa [pairMask] using (congrFun h a).symm
  have hb : b=c ∨ b=d := by simpa [pairMask] using (congrFun h b).symm
  grind

set_option maxHeartbeats 1000000 in
private theorem maskInjective {n m} (f : Formula n m) : Function.Injective (mask f) := by
  rintro ⟨c,i⟩ ⟨d,j⟩ h
  have h' := maskUnordered ((vertexIndex n m).injective.ne (distinctEnds f c i)) h
  simp only [Equiv.apply_eq_iff_eq] at h'
  fin_cases i <;> fin_cases j <;> simp_all [endpoints]

noncomputable def glass {n m} (f : Formula n m) : Glass (n + m*3) where
  bonds := Finset.univ.image (mask f)
  negative e := decide (e ∈ (Finset.univ.filter (fun p => negative f p.1 p.2)).image (mask f))
  twoSite := by
    intro e he
    obtain ⟨⟨c,k⟩,_,rfl⟩ := Finset.mem_image.mp he
    exact ⟨_,_,(vertexIndex n m).injective.ne (distinctEnds f c k),rfl⟩

theorem edgeCount {n m} (f : Formula n m) : (glass f).bonds.card = m*6 := by
  change (Finset.univ.image (mask f)).card = _
  rw [Finset.card_image_of_injective _ (maskInjective f)]
  simp

private theorem coupling {n m} (f : Formula n m) (e : Fin m × Fin 6) :
    (glass f).coupling (mask f e) = if negative f e.1 e.2 then -1 else 1 := by
  obtain ⟨a,b⟩ := e
  simp [Glass.coupling, glass, Finset.mem_image, (maskInjective f).eq_iff]

def bond (neg a b : Bool) : ℤ := if (a ^^ neg) = b then -1 else 1

def score (a b c u v w : Bool) : ℤ :=
  bond false a u + bond false b v + bond false c w +
    bond true u v + bond true v w + bond true u w

theorem bondCharacter : ∀ neg a b : Bool,
    -( (if neg then -1 else 1 : ℤ) * (bitCharacter a true * bitCharacter b true)) =
      bond neg a b := by decide

private theorem literalBond : ∀ neg a b : Bool, bond neg a b = bond false (a ^^ neg) b := by decide

/-- The exact local minimum, its equality conditions, and its attainability are
checked on all six independent Boolean inputs. -/
theorem clauseMinimum : ∀ a b c u v w : Bool,
    -4 ≤ score a b c u v w ∧
    (score a b c u v w = -4 ↔ u=a ∧ v=b ∧ w=c ∧ nae a b c) := by
  unfold nae
  decide

def clauseScore {n m} (f : Formula n m) (s : Vertex n m → Bool) (c : Fin m) : ℤ :=
  score ((f c 0).eval (s ∘ Sum.inl)) ((f c 1).eval (s ∘ Sum.inl))
    ((f c 2).eval (s ∘ Sum.inl)) (s (.inr (c,0))) (s (.inr (c,1))) (s (.inr (c,2)))

theorem energyDecomposition {n m} (f : Formula n m) (s : Spin (n+m*3)) :
    (glass f).energy s = ∑ c, clauseScore f (s ∘ vertexIndex n m) c := by
  change -(∑ e ∈ Finset.univ.image (mask f), (glass f).coupling e * character s e) = _
  rw [Finset.sum_image (maskInjective f).injOn, ← Finset.sum_neg_distrib, Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro c _
  have one (k : Fin 6) : -((glass f).coupling (mask f (c,k)) * character s (mask f (c,k))) =
      bond (negative f c k) (s (vertexIndex n m (endpoints f c k).1))
        (s (vertexIndex n m (endpoints f c k).2)) := by
    rw [coupling, mask, character_pair _ _ _ ((vertexIndex n m).injective.ne (distinctEnds f c k))]
    exact bondCharacter ..
  simp_rw [one]
  simp [Fin.sum_univ_succ, endpoints, negative, clauseScore, score, Literal.eval, literalBond]
  abel

/-- The threshold −4m is reached if and only if the source NAE formula is satisfiable. -/
theorem thresholdEquivalence {n m} (f : Formula n m) :
    feasible (glass f) (-4*(m:ℤ)) ↔ Satisfiable f := by
  constructor
  · rintro ⟨s,hs⟩
    rw [energyDecomposition] at hs
    let t := s ∘ vertexIndex n m
    have pos (c : Fin m) : 0 ≤ clauseScore f t c + 4 := by
      have h := (clauseMinimum ((f c 0).eval (t ∘ Sum.inl)) ((f c 1).eval (t ∘ Sum.inl))
        ((f c 2).eval (t ∘ Sum.inl)) (t (.inr (c,0))) (t (.inr (c,1))) (t (.inr (c,2)))).1
      change 0 ≤ _ + 4
      dsimp only [clauseScore]
      omega
    have hsum : (∑ c, (clauseScore f t c + 4)) ≤ 0 := by
      rw [Finset.sum_add_distrib]
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      change (∑ c, clauseScore f t c) ≤ _ at hs
      linarith
    refine ⟨t ∘ Sum.inl, fun c => ?_⟩
    have h := (Finset.single_le_sum (fun i _ => pos i) (Finset.mem_univ c)).trans hsum
    have eq : clauseScore f t c = -4 := by linarith [pos c]
    exact ((clauseMinimum ..).2.mp eq).2.2.2
  · rintro ⟨s,hs⟩
    let t : Vertex n m → Bool := Sum.elim s (fun p => (f p.1 p.2).eval s)
    refine ⟨t ∘ (vertexIndex n m).symm, ?_⟩
    rw [energyDecomposition, Function.comp_assoc, Equiv.symm_comp_self, Function.comp_id]
    have h (c : Fin m) : clauseScore f t c = -4 :=
      (clauseMinimum ..).2.mpr ⟨rfl,rfl,rfl,hs c⟩
    simp [h, mul_comm]
end FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT
