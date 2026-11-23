module

public import FormalQChem.StatePrep.CircuitPreparation.AmplitudeAmplification
public import Mathlib.Analysis.InnerProductSpace.Projection.Reflection
import Mathlib.Algebra.Order.Chebyshev
public import Mathlib.Analysis.InnerProductSpace.Orthonormal

/-! # An oracle lower bound for ground-state preparation

A hidden label selects one sector of a projective measurement. The Hamiltonian
is the complementary projector, so its ground space is the marked sector.
A query flips the phase of that sector. Between queries the algorithm may
apply arbitrary unitaries independent of the hidden label. This includes
ancillas by taking the sectors and gates on the joint space. The hybrid
argument follows [Bennett et al.](https://arxiv.org/abs/quant-ph/9701001). -/

@[expose] public section
noncomputable section

namespace FormalQChem.Complexity.GroundStateSearch

open FormalQChem.StatePrep.CircuitPreparation.AmplitudeAmplification

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
variable (G : Submodule ℂ E) [G.HasOrthogonalProjection]

/-- The complementary-projector Hamiltonian. -/
def hamiltonian : E →L[ℂ] E := ContinuousLinearMap.id ℂ E - G.starProjection

theorem groundSpace (x : E) : hamiltonian G x = 0 ↔ x ∈ G := by
  change x - G.starProjection x = 0 ↔ _
  rw [sub_eq_zero, eq_comm, G.starProjection_eq_self_iff]

/-- The energy above zero is exactly the failure probability. -/
theorem energy_eq_failure {x : E} (hx : ‖x‖ = 1) :
    (inner ℂ (hamiltonian G x) x).re = 1 - success G x := by
  change (inner ℂ (x - G.starProjection x) x).re = _
  rw [inner_sub_left, Complex.sub_re]
  have hp := G.re_inner_starProjection_eq_normSq x
  change (inner ℂ (G.starProjection x) x).re = ‖G.starProjection x‖ ^ 2 at hp
  rw [hp]
  simp [inner_self_eq_norm_sq_to_K, hx, success]

private theorem mark_eq_neg_reflection (x : E) : mark G x = -G.reflection x := by
  simp [mark, Submodule.reflection_apply, two_smul]

variable (U : ℕ → E ≃ₗᵢ[ℂ] E) (ψ : E)

/-- Query-free comparison trajectory through the same gates. -/
def reference : ℕ → E
  | 0 => ψ
  | t + 1 => U t (reference t)

/-- Actual trajectory when the oracle marks G. -/
def queried : ℕ → E
  | 0 => ψ
  | t + 1 => U t (mark G (queried t))

theorem reference_norm (t : ℕ) : ‖reference U ψ t‖ = ‖ψ‖ := by
  induction t with
  | zero => rfl
  | succ t ih => simpa [reference] using ih

theorem queried_norm (t : ℕ) : ‖queried G U ψ t‖ = ‖ψ‖ := by
  induction t with
  | zero => rfl
  | succ t ih => simpa [queried, mark_eq_neg_reflection] using ih

private theorem hybrid_step (t : ℕ) :
    dist (queried G U ψ (t + 1)) (reference U ψ (t + 1)) ≤
    dist (queried G U ψ t) (reference U ψ t) + 2 * ‖G.starProjection (reference U ψ t)‖ := by
  rw [queried, reference, (U t).isometry.dist_eq]
  apply (dist_triangle _ (mark G (reference U ψ t)) _).trans
  apply add_le_add
  · simp [mark_eq_neg_reflection, G.reflection.isometry.dist_eq]
  · rw [dist_eq_norm, mark, sub_sub_cancel_left, norm_neg, norm_smul]
    norm_num

variable {N : ℕ} (sector : Fin N → Submodule ℂ E) [∀ i, (sector i).HasOrthogonalProjection]

/-- Bessel's inequality for the query address sectors. A bypass sector is allowed. -/
def AddressBound : Prop := ∀ x : E, ∑ i, ‖(sector i).starProjection x‖ ^ 2 ≤ ‖x‖ ^ 2

/-- Distinct orthonormal candidate states, such as determinants in an orthonormal
orbital basis, satisfy the address bound by Bessel's inequality. -/
theorem orthonormal_addresses (v : Fin N → E) (hv : Orthonormal ℂ v) :
    AddressBound (fun i => Submodule.span ℂ {v i}) := by
  intro x
  simpa [Submodule.starProjection_singleton, hv.norm_eq_one, norm_smul] using
    (hv.sum_inner_products_le (s := Finset.univ) x)

private theorem sum_amplitudes_le (h : AddressBound sector) {x : E} (hx : ‖x‖ = 1) :
    ∑ i, ‖(sector i).starProjection x‖ ≤ Real.sqrt N := by
  have cs := sq_sum_le_card_mul_sum_sq (s := Finset.univ)
    (f := fun i => ‖(sector i).starProjection x‖)
  have mass := h x
  rw [hx, one_pow] at mass
  simp only [Finset.card_univ, Fintype.card_fin] at cs
  apply Real.le_sqrt_of_sq_le
  exact cs.trans ((mul_le_mul_of_nonneg_left mass (Nat.cast_nonneg N)).trans_eq (mul_one _))

/-- Total distance from the common reference trajectory after T mark queries. -/
theorem hybrid_bound (h : AddressBound sector) (hψ : ‖ψ‖ = 1) (T : ℕ) :
    ∑ i, dist (queried (sector i) U ψ T) (reference U ψ T) ≤ 2 * T * Real.sqrt N := by
  induction T with
  | zero => simp [queried, reference]
  | succ t ih =>
    have hs := Finset.sum_le_sum (s := Finset.univ) (fun i _ => hybrid_step (sector i) U ψ t)
    rw [Finset.sum_add_distrib, ← Finset.mul_sum] at hs
    have ha := sum_amplitudes_le sector h ((reference_norm U ψ t).trans hψ)
    push_cast
    linarith [add_le_add ih (mul_le_mul_of_nonneg_left ha (by norm_num : (0 : ℝ) ≤ 2))]

/-- If every possible mark is recovered with probability at least p, then
N√p ≤ (2T+1)√N. For fixed positive p this requires Ω(√N) oracle calls. -/
theorem query_lower_bound (h : AddressBound sector) (hψ : ‖ψ‖ = 1) (T : ℕ) {p : ℝ}
    (wins : ∀ i, p ≤ success (sector i) (queried (sector i) U ψ T)) :
    N * Real.sqrt p ≤ (2 * T + 1) * Real.sqrt N := by
  let ref := reference U ψ T
  let out := fun i => queried (sector i) U ψ T
  have point (i : Fin N) : Real.sqrt p ≤ dist (out i) ref + ‖(sector i).starProjection ref‖ := by
    have hi := Real.sqrt_le_sqrt (wins i)
    rw [success, Real.sqrt_sq (norm_nonneg _)] at hi
    apply hi.trans
    have tri := dist_triangle ((sector i).starProjection (out i)) ((sector i).starProjection ref) 0
    simp only [dist_zero_right] at tri
    apply tri.trans
    rw [dist_eq_norm, ← map_sub]
    rw [dist_eq_norm]
    exact add_le_add ((sector i).norm_starProjection_apply_le (out i - ref)) le_rfl
  have hs := Finset.sum_le_sum (s := Finset.univ) (fun i _ => point i)
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul,
    Finset.sum_add_distrib] at hs
  have hb := hybrid_bound U ψ sector h hψ T
  have ha := sum_amplitudes_le sector h ((reference_norm U ψ T).trans hψ)
  dsimp [out, ref] at hs
  linarith

/-- Uniform energy error ε for these complementary projectors entails the same
oracle lower bound with success probability 1−ε. -/
theorem energy_query_lower_bound (h : AddressBound sector) (hψ : ‖ψ‖ = 1) (T : ℕ) {ε : ℝ}
    (accurate : ∀ i, let x := queried (sector i) U ψ T
                     (inner ℂ (hamiltonian (sector i) x) x).re ≤ ε) :
    N * Real.sqrt (1 - ε) ≤ (2 * T + 1) * Real.sqrt N := by
  apply query_lower_bound U ψ sector h hψ
  intro i
  have hi := accurate i
  dsimp only at hi
  rw [energy_eq_failure _ ((queried_norm _ U ψ T).trans hψ)] at hi
  linarith

/-- The lower bound for preparing an unknown member of any orthonormal list,
given phase-query access and a uniform bound on the final energy. -/
theorem orthonormal_energy_lower_bound (v : Fin N → E) (hv : Orthonormal ℂ v)
    (hψ : ‖ψ‖ = 1) (T : ℕ) {ε : ℝ}
    (accurate : ∀ i, let G := Submodule.span ℂ {v i}
                     let x := queried G U ψ T
                     (inner ℂ (hamiltonian G x) x).re ≤ ε) :
    N * Real.sqrt (1 - ε) ≤ (2 * T + 1) * Real.sqrt N :=
  energy_query_lower_bound U ψ _ (orthonormal_addresses v hv) hψ T accurate

end FormalQChem.Complexity.GroundStateSearch
