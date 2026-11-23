module

public import Mathlib.Analysis.Complex.Norm
import Mathlib.Tactic

/-!
# Exact pure-state preparation by controlled one-qubit rotations

At each layer the preceding bits select an SU(2) gate on a fresh qubit. Sibling
amplitudes determine its first column. This is the conditional-rotation construction
at the level of multiplexed gates [Möttönen et al.](https://arxiv.org/abs/quant-ph/0407010).
-/

@[expose] public section
noncomputable section

namespace FQChem.StatePrep.CircuitPreparation.ControlledRotations

open scoped ComplexConjugate

/-- A computational basis index with its last qubit exposed. -/
def Register : ℕ → Type
  | 0 => Unit
  | n + 1 => Register n × Bool

instance instRegisterFintype : (n : ℕ) → Fintype (Register n)
  | 0 => inferInstanceAs (Fintype Unit)
  | n + 1 =>
    letI := instRegisterFintype n
    inferInstanceAs (Fintype (Register n × Bool))

structure Rotation where
  a : ℂ
  b : ℂ
  unit : Complex.normSq a + Complex.normSq b = 1

/-- The gate with columns (a,b) and (−conj b,conj a). -/
def Rotation.apply (g : Rotation) (x y : ℂ) : Bool → ℂ
  | false => g.a * x - conj g.b * y
  | true => g.b * x + conj g.a * y

theorem Rotation.preservesNorm (g : Rotation) (x y : ℂ) :
    Complex.normSq (g.apply x y false) + Complex.normSq (g.apply x y true) =
      Complex.normSq x + Complex.normSq y := by
  calc
    _ = (Complex.normSq g.a + Complex.normSq g.b) * (Complex.normSq x + Complex.normSq y) := by
      simp only [Rotation.apply, Complex.normSq_apply, Complex.sub_re, Complex.sub_im,
        Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im, Complex.conj_re, Complex.conj_im]
      ring
    _ = _ := by rw [g.unit, one_mul]

def radius (a b : ℂ) : ℝ := Real.sqrt (Complex.normSq a + Complex.normSq b)

private theorem radius_sq (a b : ℂ) : radius a b ^ 2 = Complex.normSq a + Complex.normSq b :=
  Real.sq_sqrt (add_nonneg (Complex.normSq_nonneg _) (Complex.normSq_nonneg _))

/-- A zero-weight prefix can use the identity gate. -/
def preparePair (a b : ℂ) : Rotation :=
  if h : radius a b = 0 then ⟨1, 0, by simp⟩
  else ⟨a / (radius a b : ℂ), b / (radius a b : ℂ), by
    simp only [Complex.normSq_div, Complex.normSq_ofReal, ← add_div, ← sq, radius_sq]
    exact div_self (by rw [← radius_sq]; positivity)⟩

theorem preparePair_correct (a b : ℂ) :
    (preparePair a b).apply (radius a b : ℂ) 0 false = a ∧
    (preparePair a b).apply (radius a b : ℂ) 0 true = b := by
  by_cases h : radius a b = 0
  · have hs := radius_sq a b
    rw [h, zero_pow (by decide : 2 ≠ 0)] at hs
    have ha : a = 0 := Complex.normSq_eq_zero.mp (by linarith [Complex.normSq_nonneg a, Complex.normSq_nonneg b])
    have hb : b = 0 := Complex.normSq_eq_zero.mp (by linarith [Complex.normSq_nonneg a, Complex.normSq_nonneg b])
    simp [Rotation.apply, ha, hb, radius]
  · have hn : (radius a b : ℂ) ≠ 0 := by exact_mod_cast h
    simp [Rotation.apply, preparePair, h, hn]

/-- A global phase on the empty register, followed by a layer of prefix-controlled
one-qubit gates for each appended bit. -/
inductive Circuit : ℕ → Type
  | phase (z : ℂ) (unit : Complex.normSq z = 1) : Circuit 0
  | layer {n : ℕ} (prior : Circuit n) (gate : Register n → Rotation) : Circuit (n + 1)

/-- Output amplitudes from the all-zero input, including the global phase. -/
def Circuit.state : {n : ℕ} → Circuit n → Register n → ℂ
  | 0, .phase z _, _ => z
  | _ + 1, .layer prior gate, (i, bit) => (gate i).apply (prior.state i) 0 bit

theorem Circuit.normalized {n : ℕ} (C : Circuit n) :
    ∑ i, Complex.normSq (C.state i) = 1 := by
  induction C with
  | phase z unit =>
    change (∑ _ : Unit, Complex.normSq z) = 1
    simpa only [Fintype.sum_unique] using unit
  | @layer n prior gates ih =>
    change (∑ x : Register n × Bool, Complex.normSq ((gates x.1).apply (prior.state x.1) 0 x.2)) = 1
    rw [Fintype.sum_prod_type]
    convert ih using 1
    apply Finset.sum_congr rfl
    intro i _
    simpa [Fintype.sum_bool, add_comm] using (gates i).preservesNorm (prior.state i) 0

/-- Count the individual controlled SU(2) blocks, one per prefix in each layer.
The empty-register phase is counted separately. -/
def Circuit.blocks : {n : ℕ} → Circuit n → ℕ
  | 0, .phase _ _ => 0
  | n + 1, .layer prior _ => prior.blocks + Fintype.card (Register n)

private theorem registerCard : ∀ n : ℕ, Fintype.card (Register n) = 2 ^ n
  | 0 => by change Fintype.card Unit = 2 ^ 0; simp
  | n + 1 => by
    change Fintype.card (Register n × Bool) = 2 ^ (n + 1)
    rw [Fintype.card_prod, registerCard n, Fintype.card_bool, pow_succ]

theorem Circuit.blockCount {n : ℕ} (C : Circuit n) : C.blocks + 1 = 2 ^ n := by
  induction C with
  | phase => rfl
  | @layer n prior gates ih =>
    simp only [Circuit.blocks, registerCard, pow_succ]
    omega

/-- Every normalized complex n-qubit pure state can be prepared exactly by this
circuit family, including states with vanishing branches. -/
theorem exactPreparation (n : ℕ) (ψ : Register n → ℂ)
    (unit : ∑ i, Complex.normSq (ψ i) = 1) : ∃ C : Circuit n, C.state = ψ := by
  induction n with
  | zero =>
    have h : Complex.normSq (ψ ()) = 1 := by
      change (∑ i : Unit, Complex.normSq (ψ i)) = 1 at unit
      simpa only [Fintype.sum_unique] using unit
    exact ⟨.phase (ψ ()) h, by funext i; cases i; rfl⟩
  | succ n ih =>
    let r (i : Register n) := radius (ψ (i, false)) (ψ (i, true))
    have hr : ∑ i, Complex.normSq (r i : ℂ) = 1 := by
      change (∑ i : Register n × Bool, Complex.normSq (ψ i)) = 1 at unit
      rw [Fintype.sum_prod_type] at unit
      simpa [r, Complex.normSq_ofReal, ← sq, radius_sq, add_comm] using unit
    obtain ⟨prior, hp⟩ := ih (fun i ↦ (r i : ℂ)) hr
    refine ⟨.layer prior (fun i ↦ preparePair (ψ (i, false)) (ψ (i, true))), ?_⟩
    funext ⟨i, bit⟩
    have hp' := congrFun hp i
    cases bit
    · simpa only [Circuit.state, hp', r] using (preparePair_correct (ψ (i, false)) (ψ (i, true))).1
    · simpa only [Circuit.state, hp', r] using (preparePair_correct (ψ (i, false)) (ψ (i, true))).2

end FQChem.StatePrep.CircuitPreparation.ControlledRotations
