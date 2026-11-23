module

public import Mathlib.Analysis.InnerProductSpace.Projection.Basic
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
public import Mathlib.Algebra.Order.Floor.Semifield

/-! # Quantum amplitude amplification

The marking operator reverses the phase of the good subspace. Reflection about the
prepared state completes a rotation in its good–bad plane. The success probability
is the squared norm of the orthogonal projection, including for a multidimensional
good subspace. See [Brassard, Høyer, Mosca and Tapp](https://doi.org/10.1090/conm/305/05215). -/

@[expose] public section

namespace FormalQChem.StatePrep.CircuitPreparation.AmplitudeAmplification

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
variable (G : Submodule ℂ E) [G.HasOrthogonalProjection]

/-- Unit axes of the good and bad components of the prepared state. -/
structure Components where
  good : E
  bad : E
  good_mem : good ∈ G
  bad_mem : bad ∈ Gᗮ
  good_norm : ‖good‖ = 1
  bad_norm : ‖bad‖ = 1

/-- A state of the good–bad plane with real good amplitude sin θ. -/
noncomputable def state (p : Components G) (θ : ℝ) : E :=
  (Real.sin θ : ℂ) • p.good + (Real.cos θ : ℂ) • p.bad

/-- Actual phase oracle I − 2P for the marked subspace. -/
noncomputable def mark (x : E) : E := x - (2 : ℂ) • G.starProjection x

/-- Reflection 2|ψ⟩⟨ψ| − I about a normalized prepared state. -/
noncomputable def reflectPrepared (ψ x : E) : E := (2 * inner ℂ ψ x) • ψ - x

/-- One amplification step, applying the phase oracle first. -/
noncomputable def step (ψ : E) (x : E) : E := reflectPrepared ψ (mark G x)

/-- Probability of a marked outcome in a normalized state. -/
noncomputable def success (x : E) : ℝ := ‖G.starProjection x‖ ^ 2

private theorem project_state (p : Components G) (θ : ℝ) :
    G.starProjection (state G p θ) = (Real.sin θ : ℂ) • p.good := by
  simp [state, G.starProjection_eq_self_iff.mpr p.good_mem,
    G.starProjection_apply_eq_zero_iff.mpr p.bad_mem]

omit [G.HasOrthogonalProjection] in
private theorem inner_states (p : Components G) (α β : ℝ) :
    inner ℂ (state G p α) (state G p β) = (Real.cos (α - β) : ℂ) := by
  have gb := (G.mem_orthogonal _).mp p.bad_mem _ p.good_mem
  have bg := (G.mem_orthogonal' _).mp p.bad_mem _ p.good_mem
  simp [state, inner_add_left, inner_add_right, inner_smul_left, inner_smul_right, gb, bg,
    inner_self_eq_norm_sq_to_K, p.good_norm, p.bad_norm, Real.cos_sub]
  simp only [← Complex.ofReal_sin, ← Complex.ofReal_cos, Complex.conj_ofReal]
  ring

omit [G.HasOrthogonalProjection] in
/-- Every plane state used by the two reflections is normalized. -/
theorem state_normalized (p : Components G) (θ : ℝ) : ‖state G p θ‖ = 1 := by
  have h := congrArg Complex.re (inner_states G p θ θ)
  have sqr : ‖state G p θ‖ ^ 2 = 1 := by
    simpa only [← RCLike.re_to_complex, inner_self_eq_norm_sq, sub_self, Real.cos_zero,
      Complex.ofReal_one, RCLike.one_re] using h
  nlinarith [norm_nonneg (state G p θ)]

private theorem mark_state (p : Components G) (φ : ℝ) :
    mark G (state G p φ) = state G p (-φ) := by
  rw [mark, project_state]
  simp only [state, Real.sin_neg, Real.cos_neg, Complex.ofReal_neg]
  module

/-- The actual product of reflections adds 2θ to the plane angle. -/
theorem step_rotates (p : Components G) (θ φ : ℝ) :
    step G (state G p θ) (state G p φ) = state G p (2 * θ + φ) := by
  have hadd : θ + (θ + φ) = 2 * θ + φ := by ring
  have hsub : θ - (θ + φ) = -φ := by ring
  have s₁ := Real.sin_add θ (θ + φ)
  have s₂ := Real.sin_sub θ (θ + φ)
  have c₁ := Real.cos_add θ (θ + φ)
  have c₂ := Real.cos_sub θ (θ + φ)
  rw [hadd] at s₁ c₁
  rw [hsub] at s₂ c₂
  have ss : 2 * Real.cos (θ + φ) * Real.sin θ - Real.sin (-φ) = Real.sin (2 * θ + φ) := by
    linarith
  have cc : 2 * Real.cos (θ + φ) * Real.cos θ - Real.cos (-φ) = Real.cos (2 * θ + φ) := by
    linarith
  rw [step, mark_state, reflectPrepared, inner_states, sub_neg_eq_add]
  simp only [state, smul_add, smul_smul]
  rw [show ∀ u v w z : E, (u + v) - (w + z) = (u - w) + (v - z) by intros; abel,
    ← sub_smul, ← sub_smul]
  congr 2 <;> exact_mod_cast (by first | exact ss | exact cc)

/-- The full vector after k Grover iterations. -/
theorem iterate_state (p : Components G) (θ : ℝ) (k : ℕ) :
    (step G (state G p θ))^[k] (state G p θ) = state G p ((2 * k + 1) * θ) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', ih, step_rotates]
    congr 1
    push_cast
    ring

/-- Exact success probability after k iterations, for any orthogonally projectable
good subspace and normalized good and bad components. -/
theorem success_law (p : Components G) (θ : ℝ) (k : ℕ) :
    success G ((step G (state G p θ))^[k] (state G p θ)) = Real.sin ((2 * k + 1) * θ) ^ 2 := by
  rw [iterate_state, success, project_state, norm_smul, p.good_norm, mul_one,
    Complex.norm_real, Real.norm_eq_abs, sq_abs]

/-- With known initial success sin² θ, floor(π/(4θ)) iterations give success at
least cos² θ = 1 − sin² θ. This tends to one for small initial overlap. -/
theorem rounded_success (p : Components G) {θ : ℝ} (positive : 0 < θ)
    (first_quadrant : θ ≤ Real.pi / 2) :
    1 - Real.sin θ ^ 2 ≤ success G ((step G (state G p θ))^[⌊Real.pi / (4 * θ)⌋₊]
      (state G p θ)) := by
  let k := ⌊Real.pi / (4 * θ)⌋₊
  have lower : (k : ℝ) ≤ Real.pi / (4 * θ) := Nat.floor_le (by positivity)
  have upper : Real.pi / (4 * θ) < (k : ℝ) + 1 := Nat.lt_floor_add_one _
  have pos : 0 < 4 * θ := by positivity
  have bounds : |Real.pi / 2 - (2 * k + 1) * θ| ≤ θ := by
    have lo := (le_div_iff₀ pos).mp lower
    have hi := (div_lt_iff₀ pos).mp upper
    exact abs_le.mpr ⟨by linarith, by linarith⟩
  have cos_le := Real.cos_le_cos_of_nonneg_of_le_pi (abs_nonneg _)
    (show θ ≤ Real.pi by linarith [Real.pi_pos]) bounds
  rw [Real.cos_abs, Real.cos_pi_div_two_sub] at cos_le
  have nonneg : 0 ≤ Real.cos θ := Real.cos_nonneg_of_mem_Icc ⟨by linarith [Real.pi_pos], first_quadrant⟩
  rw [success_law]
  nlinarith [sq_le_sq₀ nonneg (nonneg.trans cos_le) |>.mpr cos_le, Real.sin_sq_add_cos_sq θ]

/-- For initial success probability a > 0, at most π/(4√a) oracle uses suffice
for success probability at least 1 − a. Each iteration calls the phase oracle once. -/
theorem inverse_sqrt_queries (p : Components G) {θ : ℝ} (positive : 0 < θ)
    (first_quadrant : θ ≤ Real.pi / 2) :
    ∃ k : ℕ, (k : ℝ) ≤ Real.pi / (4 * Real.sqrt (success G (state G p θ))) ∧
      1 - success G (state G p θ) ≤ success G ((step G (state G p θ))^[k] (state G p θ)) := by
  have initial : success G (state G p θ) = Real.sin θ ^ 2 := by
    simpa using success_law G p θ 0
  have hs : 0 < Real.sin θ := Real.sin_pos_of_pos_of_lt_pi positive (by linarith [Real.pi_pos])
  refine ⟨⌊Real.pi / (4 * θ)⌋₊, ?_, ?_⟩
  · rw [initial, Real.sqrt_sq hs.le]
    refine (Nat.floor_le (by positivity : 0 ≤ Real.pi / (4 * θ))).trans ?_
    apply div_le_div_of_nonneg_left Real.pi_pos.le (by positivity)
    linarith [Real.sin_le positive.le]
  · rw [initial]
    exact rounded_success G p positive first_quadrant

end FormalQChem.StatePrep.CircuitPreparation.AmplitudeAmplification
