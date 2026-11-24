module

public import FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSatisfiability
import Mathlib.Tactic

/-! # A 3-SAT reduction to quantum thermal-energy estimation

Introduce one anchor and one splitting variable per input clause. With the anchor
false, an ordinary disjunction becomes two not-all-equal constraints. Simultaneously
flipping every spin makes either choice of anchor equivalent. The signed edge list
is obtained by composing this transformation with the six-edge clause gadget.
-/

@[expose] public section
namespace FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT
open IsingSign MeasureTheory

def ThreeSAT {n m} (f : Formula n m) : Prop :=
  ∃ s, ∀ c, ((f c 0).eval s || (f c 1).eval s || (f c 2).eval s) = true

def variableSlot {n m : ℕ} (i : Fin n) : Fin (n+(m+1)) := finSumFinEquiv (.inl i)
def auxiliarySlot {n m : ℕ} (c : Fin m) : Fin (n+(m+1)) := finSumFinEquiv (.inr c.castSucc)
def anchorSlot (n m : ℕ) : Fin (n+(m+1)) := finSumFinEquiv (.inr (Fin.last m))

def liftLiteral {n m} (l : Literal n) : Literal (n+(m+1)) := ⟨variableSlot l.var,l.neg⟩

def splitClause {n m} (f : Formula n m) (c : Fin m) (k : Fin 2) : Fin 3 → Literal (n+(m+1)) :=
  if k=0 then ![liftLiteral (f c 0), liftLiteral (f c 1), ⟨auxiliarySlot c,false⟩]
  else ![⟨auxiliarySlot c,true⟩, liftLiteral (f c 2), ⟨anchorSlot n m,false⟩]

def splitFormula {n m} (f : Formula n m) : Formula (n+(m+1)) (m*2) :=
  fun k => let (c,i) := finProdFinEquiv.symm k; splitClause f c i

private theorem splitTest : ∀ a b c d q : Bool,
    nae a b d → nae (!d) c q → ((a ^^ q) || (b ^^ q) || (c ^^ q)) = true := by
  unfold nae
  decide

private theorem splitWitness : ∀ a b c : Bool, (a || b || c) = true →
    nae a b (!(a||b)) ∧ nae (!(!(a||b))) c false := by unfold nae; decide

private theorem switchLiteral : ∀ x q neg : Bool, ((x ^^ q) ^^ neg) = ((x ^^ neg) ^^ q) := by decide

theorem splitEquivalence {n m} (f : Formula n m) : Satisfiable (splitFormula f) ↔ ThreeSAT f := by
  constructor
  · rintro ⟨s,hs⟩
    let q := s (anchorSlot n m)
    let raw (i : Fin n) := s (variableSlot (m := m) i)
    refine ⟨fun i => raw i ^^ q, fun c => ?_⟩
    have h₀ := hs (finProdFinEquiv (c,(0:Fin 2)))
    have h₁ := hs (finProdFinEquiv (c,(1:Fin 2)))
    simp [splitFormula, splitClause, Literal.eval, liftLiteral] at h₀ h₁
    simp only [Literal.eval, switchLiteral]
    exact splitTest _ _ _ _ _ h₀ h₁
  · rintro ⟨s,hs⟩
    let aux (c : Fin m) := !((f c 0).eval s || (f c 1).eval s)
    let t : Fin (n+(m+1)) → Bool := Sum.elim s (Fin.lastCases false aux) ∘ finSumFinEquiv.symm
    refine ⟨t,fun k => ?_⟩
    obtain ⟨⟨c,i⟩,rfl⟩ := finProdFinEquiv.surjective k
    have ta : t (anchorSlot n m) = false := by
      change Sum.elim s (Fin.lastCases false aux) (finSumFinEquiv.symm (finSumFinEquiv (.inr (Fin.last m)))) = false
      rw [Equiv.symm_apply_apply]
      simp
    have tv (i : Fin n) : t (variableSlot i) = s i := by simp [t, variableSlot]
    have tu (d : Fin m) : t (auxiliarySlot d) = aux d := by
      simp [t, auxiliarySlot]
    have hw := splitWitness _ _ _ (hs c)
    fin_cases i
    · simpa [splitFormula, splitClause, tv, liftLiteral, Literal.eval, tu, aux] using hw.1
    · simpa [splitFormula, splitClause, tv, liftLiteral, Literal.eval, tu, ta, aux] using hw.2

/-- The sparse compiled instance has n+7m+1 sites and 12m unit-strength bonds.
Its classical threshold is equivalent to the truth of the input 3-CNF. -/
theorem threeSATThreshold {n m} (f : Formula n m) :
    n+(m+1)+m*2*3 = n+7*m+1 ∧ (glass (splitFormula f)).bonds.card = 12*m ∧
    (feasible (glass (splitFormula f)) (-8*(m:ℤ)) ↔ ThreeSAT f) := by
  refine ⟨by omega, by rw [edgeCount]; omega, ?_⟩
  convert (thresholdEquivalence (splitFormula f)).trans (splitEquivalence f) using 2
  push_cast
  ring

/-- One signed quantum Gibbs-energy estimate decides an arbitrary 3-SAT instance
with error ≤ 1/4, at a linear inverse temperature and inverse relative precision.
At the identical query the sign-free estimator returns −12m deterministically. -/
theorem threeSATEnergyDecision {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {n m} (f : Formula n m) (estimate : Ω → ℝ) :
    let N := n+(m+1)+m*2*3
    let g := glass (splitFormula f)
    Integrable (fun x => (estimate x-g.quantumThermal (13*N))^2) μ →
    (∫ x, (estimate x-g.quantumThermal (13*N))^2 ∂μ) ≤ (|g.quantumThermal (13*N)|/(24*N))^2 →
    μ.real {x | ¬ ((estimate x < -8*(m:ℝ)+3/4) ↔ ThreeSAT f)} ≤ 1/4 ∧
      |-(12*(m:ℝ))-g.ferro.quantumThermal (13*N)| ≤ |g.ferro.quantumThermal (13*N)|/(24*N) := by
  intro N g hi hr
  have h := threeSATThreshold f
  have sites : 0 < N := by dsimp [N]; omega
  have count : g.bonds.card = 12*m := h.2.1
  have edges : g.bonds.card ≤ 3*N := by dsimp [N]; omega
  have decision := statisticalDecision μ g sites edges (-8*(m:ℤ)) estimate hi hr
  rw [show feasible g (-8*(m:ℤ)) ↔ ThreeSAT f from h.2.2] at decision
  have comparison := bosonicDecisionEstimate g sites
  rw [count] at comparison
  push_cast at comparison decision
  refine ⟨decision,?_⟩
  simpa [N] using comparison

end FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT
