module

public import Mathlib.Analysis.Calculus.Deriv.Mul
public import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Tactic.Module

/-!
# Adiabatic transport of an isolated spectral band

Time is rescaled to the unit interval. For quantum evolution, the generator
is `A(s) = -i H(s)` in units with ℏ = 1 and multiplication is operator
composition. Bounds use the submultiplicative norm (operator norm in the
Hilbert-space application).

The quantitative argument differentiates the transported observable and
integrates the commutator by parts, as in [Kato (1950)](https://doi.org/10.1143/JPSJ.5.435) and
[Avron & Elgart (1999)](https://doi.org/10.1007/s002200050620). The two-band corollary constructs the commutator
solution directly from the moving projection.
-/

@[expose] public section

namespace FQChem.StatePrep.AdiabaticPreparation

open Set

section RealAlgebra

variable {R : Type*} [NormedRing R] [NormedAlgebra ℝ R]

/-- Forward and backward propagators for a fixed runtime. Unitary evolution
has both norms bounded by one. The differential equations are the
rescaled Schrödinger equation and the equation for its inverse. -/
structure SlowEvolution (A : ℝ → R) (T : ℝ) (U V : ℝ → R) : Prop where
  positive : 0 < T
  forward_initial : U 0 = 1
  backward_initial : V 0 = 1
  inverse_right : ∀ s ∈ Icc (0 : ℝ) 1, U s * V s = 1
  forward_norm : ∀ s ∈ Icc (0 : ℝ) 1, ‖U s‖ ≤ 1
  backward_norm : ∀ s ∈ Icc (0 : ℝ) 1, ‖V s‖ ≤ 1
  forward_deriv : ∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt U (T • (A s * U s)) s
  backward_deriv : ∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt V (-(T • (V s * A s))) s

/-- Quantitative adiabatic intertwining. The spectral observable `P`
commutes with the generator and its derivative solves the commutator
equation `P' = A X - X A`. The auxiliary bounds are independent of runtime. -/
def AdiabaticIntertwining (A P X X' : ℝ → R) (B D : ℝ) : Prop :=
  (∀ s ∈ Icc (0 : ℝ) 1, Commute (A s) (P s)) →
  (∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt P (A s * X s - X s * A s) s) →
  (∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt X (X' s) s) →
  (∀ s ∈ Icc (0 : ℝ) 1, ‖X s‖ ≤ B) →
  (∀ s ∈ Icc (0 : ℝ) 1, ‖X' s‖ ≤ D) →
  ∀ T U V, SlowEvolution A T U V → ∀ s ∈ Icc (0 : ℝ) 1,
    ‖P s * U s - U s * P 0‖ ≤ (2 * B + s * D) / T

/-- Kato's corrected evolution transports the moving projection exactly.
The additional generator is the commutator of the projection derivative
with the projection. -/
def KatoTransport (A P P' : ℝ → R) : Prop :=
  (∀ s, P s * P s = P s) →
  (∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt P (P' s) s) →
  (∀ s ∈ Icc (0 : ℝ) 1, Commute (A s) (P s)) →
  ∀ T : ℝ, ∀ U V, SlowEvolution
    (fun t => T • A t + (P' t * P t - P t * P' t)) 1 U V →
    ∀ s ∈ Icc (0 : ℝ) 1, P s * U s = U s * P 0

end RealAlgebra

variable {R : Type*} [NormedRing R] [NormedAlgebra ℂ R]

/-- Leakage from the moving projector `P` for the two-band generator
`a(s) I + gap P(s)`. For a Hamiltonian, `gap` is the nonzero imaginary
generator splitting and its modulus is the energy gap. The bands may be
degenerate and the projector may vary with time. -/
def GappedBandPreparation (a : ℝ → ℂ) (gap : ℂ)
    (P P' P'' : ℝ → R) (L M : ℝ) : Prop :=
  gap ≠ 0 → (∀ s, P s * P s = P s) →
  (∀ s ∈ Icc (0 : ℝ) 1, ‖P s‖ ≤ 1) →
  (∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt P (P' s) s) →
  (∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt P' (P'' s) s) →
  (∀ s ∈ Icc (0 : ℝ) 1, ‖P' s‖ ≤ L) →
  (∀ s ∈ Icc (0 : ℝ) 1, ‖P'' s‖ ≤ M) →
  ∀ T U V, SlowEvolution (fun s => a s • (1 : R) + gap • P s) T U V →
  ∀ s ∈ Icc (0 : ℝ) 1,
    ‖(1 - P s) * U s * P 0‖ ≤ (4 * L + 2 * s * M) / (T * ‖gap‖)

/-- For a general isolated eigenvalue, the shifted generator `B` annihilates
the spectral projection `P`. Its reduced resolvent `S` inverts `B` on the
complement. In Hilbert space for a normal generator, `‖S‖ ≤ 1/g` is the
resolvent form of the gap estimate. The complementary band can have many
distinct energies and the eigenvalue `a` may vary.

`D` bounds the derivative of the explicitly constructed resolvent correction
`S P' P - P P' S`. -/
def ReducedResolventPreparation (a : ℝ → ℂ) (B S P P' : ℝ → R) (g L D : ℝ) : Prop :=
  0 < g → (∀ t, P t * P t = P t) →
  (∀ t ∈ Icc (0 : ℝ) 1, B t * P t = 0 ∧ P t * B t = 0) →
  (∀ t ∈ Icc (0 : ℝ) 1, B t * S t = 1 - P t ∧ S t * B t = 1 - P t) →
  (∀ t ∈ Icc (0 : ℝ) 1, ‖S t‖ ≤ 1 / g ∧ ‖P t‖ ≤ 1 ∧ ‖P' t‖ ≤ L) →
  (∀ t ∈ Icc (0 : ℝ) 1, HasDerivAt P (P' t) t) →
  let X := fun t => S t * P' t * P t - P t * P' t * S t
  (∀ t ∈ Icc (0 : ℝ) 1, DifferentiableAt ℝ X t ∧ ‖deriv X t‖ ≤ D) →
  ∀ T U V, SlowEvolution (fun t => a t • (1 : R) + B t) T U V →
  ∀ s ∈ Icc (0 : ℝ) 1,
    ‖(1 - P s) * U s * P 0‖ ≤ (4 * L / g + s * D) / T

end FQChem.StatePrep.AdiabaticPreparation

namespace FQChem.StatePrep.AdiabaticPreparation

open Set

section RealAlgebra

variable {R : Type*} [NormedRing R] [NormedAlgebra ℝ R]

theorem transportedDerivative {A F U V : ℝ → R} {d : R} {T s : ℝ}
    (ev : SlowEvolution A T U V) (hs : s ∈ Icc 0 1) (hf : HasDerivAt F d s) :
    HasDerivAt (fun t => V t * F t * U t)
      (V s * (d - T • (A s * F s - F s * A s)) * U s) s := by
  convert ((ev.backward_deriv s hs).fun_mul hf).fun_mul (ev.forward_deriv s hs) using 1
  simp only [mul_sub, sub_mul, smul_sub, add_mul, neg_mul, smul_mul_assoc,
    mul_smul_comm, mul_assoc]
  abel

omit [NormedAlgebra ℝ R] in
theorem sandwichBound {u v x : R} (hu : ‖u‖ ≤ 1) (hv : ‖v‖ ≤ 1) :
    ‖u * x * v‖ ≤ ‖x‖ := calc
  _ ≤ (‖u‖ * ‖x‖) * ‖v‖ := (norm_mul_le ..).trans (by gcongr; exact norm_mul_le ..)
  _ ≤ (1 * ‖x‖) * 1 := by gcongr
  _ = _ := by ring

theorem adiabaticIntertwining (A P X X' : ℝ → R) (B D : ℝ) :
    AdiabaticIntertwining A P X X' B D := by
  intro hcomm hP hX hB hD T U V ev s hs
  let moved (F : ℝ → R) (t : ℝ) := V t * F t * U t
  let Y (t : ℝ) := T • moved P t + moved X t
  have hY (t : ℝ) (ht : t ∈ Icc 0 1) :
      HasDerivAt Y (moved X' t) t := by
    have hp := transportedDerivative ev ht (hP t ht)
    have hx := transportedDerivative ev ht (hX t ht)
    rw [(hcomm t ht).eq, sub_self, smul_zero, sub_zero] at hp
    convert (hp.const_smul T).fun_add hx using 1
    simp only [moved, mul_sub, sub_mul, smul_mul_assoc, mul_smul_comm]
    module
  have hmean := norm_image_sub_le_of_norm_deriv_le_segment'
    (fun t ht => (hY t ht).hasDerivWithinAt)
    (fun t ht => (sandwichBound (ev.backward_norm t (Ico_subset_Icc_self ht))
      (ev.forward_norm t (Ico_subset_Icc_self ht))).trans (hD t (Ico_subset_Icc_self ht))) s hs
  have h0 : (0 : ℝ) ∈ Icc 0 1 := ⟨le_rfl, zero_le_one⟩
  have hscale : T * ‖moved P s - P 0‖ ≤ 2 * B + s * D := calc
    _ = ‖(Y s - Y 0) - moved X s + X 0‖ := by
      rw [← Real.norm_of_nonneg ev.positive.le, ← norm_smul]
      congr 1
      simp only [Y, moved, ev.forward_initial, ev.backward_initial, one_mul, mul_one, smul_sub]
      abel
    _ ≤ ‖Y s - Y 0‖ + ‖moved X s‖ + ‖X 0‖ :=
      (norm_add_le ..).trans (add_le_add (norm_sub_le ..) le_rfl)
    _ ≤ _ := by
      have hxs := (sandwichBound (ev.backward_norm s hs) (ev.forward_norm s hs)
        (x := X s)).trans (hB s hs)
      change ‖moved X s‖ ≤ B at hxs
      linarith [hB 0 h0, hmean]
  apply (le_div_iff₀ ev.positive).mpr
  have hfwd : P s * U s - U s * P 0 = U s * (moved P s - P 0) := by
    simp only [moved, mul_sub, ← mul_assoc, ev.inverse_right s hs, one_mul]
  rw [hfwd, mul_comm]
  refine le_trans (mul_le_mul_of_nonneg_left ?_ ev.positive.le) hscale
  apply (norm_mul_le ..).trans
  simpa using mul_le_mul_of_nonneg_right (ev.forward_norm s hs) (norm_nonneg (moved P s - P 0))

private theorem projectionDerivative {P : ℝ → R} {p : R} {s : ℝ}
    (proj : ∀ t, P t * P t = P t) (hp : HasDerivAt P p s) :
    P s * (P s * p - p * P s) - (P s * p - p * P s) * P s = p := by
  have d : p * P s + P s * p = p :=
    ((hp.fun_mul hp).congr_of_eventuallyEq (.of_forall (fun t => (proj t).symm))).unique hp
  have mid : P s * p * P s = 0 := by
    have eq := congrArg (fun x => P s * x) d
    simp only [mul_add, ← mul_assoc, proj] at eq
    exact add_right_cancel (show _ + P s * p = 0 + P s * p by simpa using eq)
  rw [mul_sub, sub_mul, ← mul_assoc, proj, ← mul_assoc, mid, mul_assoc p, proj]
  simpa [add_comm] using d

theorem katoTransport (A P P' : ℝ → R) : KatoTransport A P P' := by
  intro proj hp hcomm T U V ev s hs
  have hzero (t : ℝ) (ht : t ∈ Icc 0 1) :
      HasDerivAt (fun t => V t * P t * U t) 0 t := by
    have hgen :
        (T • A t + (P' t * P t - P t * P' t)) * P t -
          P t * (T • A t + (P' t * P t - P t * P' t)) = P' t := by
      have hd := projectionDerivative proj (hp t ht)
      simp only [add_mul, mul_add, smul_mul_assoc, mul_smul_comm, (hcomm t ht).eq,
        add_sub_add_left_eq_sub]
      rw [← neg_sub (P t * P' t) (P' t * P t), neg_mul, mul_neg]
      simpa only [neg_sub_neg] using hd
    simpa only [hgen, one_smul, sub_self, mul_zero, zero_mul] using
      transportedDerivative ev ht (hp t ht)
  have h := norm_image_sub_le_of_norm_deriv_le_segment'
    (fun t ht => (hzero t ht).hasDerivWithinAt)
    (fun _ _ => (norm_zero (E := R)).le) s hs
  have heq : V s * P s * U s = P 0 := by
    simpa only [ev.forward_initial, ev.backward_initial, mul_one, one_mul,
      zero_mul, norm_le_zero_iff, sub_eq_zero] using h
  have left := congrArg (U s * ·) heq
  simpa only [← mul_assoc, ev.inverse_right s hs, one_mul] using left

end RealAlgebra

/-- An idempotent initial projection of norm at most one turns an intertwining
error into a leakage bound. -/
private theorem leakage_le_intertwining {R : Type*} [NormedRing R] {P₀ : R} (P U : R)
    (idempotent : P₀ * P₀ = P₀) (hnorm : ‖P₀‖ ≤ 1) :
    ‖(1 - P) * U * P₀‖ ≤ ‖P * U - U * P₀‖ := by
  have factor : (1 - P) * U * P₀ = -(P * U - U * P₀) * P₀ := by
    simp only [sub_mul, one_mul, mul_assoc, idempotent, neg_sub]
  rw [factor]
  simpa only [norm_neg, mul_one] using
    norm_mul_le_of_le (le_refl ‖-(P * U - U * P₀)‖) hnorm

variable {R : Type*} [NormedRing R] [NormedAlgebra ℂ R]

/-- Leakage bound for an actual two-band path. The inverse gap arises from
solving the commutator equation, while differentiating the projection
identity removes diagonal derivatives. -/
theorem gappedBandPreparation
    (a : ℝ → ℂ) (gap : ℂ) (P P' P'' : ℝ → R) (L M : ℝ) :
    GappedBandPreparation a gap P P' P'' L M := by
  intro hgap proj hnorm hp hpp hL hM T U V ev s hs
  let A := fun t => a t • (1 : R) + gap • P t
  let comm := fun (v w : R) => v * w - w * v
  let X := fun t => gap⁻¹ • comm (P t) (P' t)
  let dX := fun t => gap⁻¹ • comm (P t) (P'' t)
  have hc (t : ℝ) : Commute (A t) (P t) := by
    show A t * P t = P t * A t
    simp [A, add_mul, mul_add]
  have hsolve (t : ℝ) (ht : t ∈ Icc 0 1) : A t * X t - X t * A t = P' t := by
    simp only [A, X, add_mul, mul_add, smul_mul_assoc, mul_smul_comm, mul_one, one_mul,
      smul_smul, mul_inv_cancel₀ hgap, one_smul]
    simp only [smul_add, smul_smul, inv_mul_cancel₀ hgap, one_smul, mul_comm gap⁻¹ (a t)]
    rw [add_sub_add_left_eq_sub]
    exact projectionDerivative proj (hp t ht)
  have hdx (t : ℝ) (ht : t ∈ Icc 0 1) : HasDerivAt X (dX t) t := by
    have h1 := (hp t ht).fun_mul (hpp t ht)
    have h2 := (hpp t ht).fun_mul (hp t ht)
    convert (h1.fun_sub h2).fun_const_smul (gap⁻¹) using 1
    dsimp [dX, comm]
    congr 1
    abel
  have hbound (t : ℝ) (ht : t ∈ Icc 0 1) (w : R) :
      ‖gap⁻¹ • comm (P t) w‖ ≤ ‖gap‖⁻¹ * (2 * ‖w‖) := by
    rw [norm_smul, norm_inv]
    gcongr
    calc
      _ ≤ ‖P t‖ * ‖w‖ + ‖w‖ * ‖P t‖ :=
        (norm_sub_le ..).trans (add_le_add (norm_mul_le ..) (norm_mul_le ..))
      _ ≤ 1 * ‖w‖ + ‖w‖ * 1 := by gcongr <;> exact hnorm t ht
      _ = _ := by ring
  have main := adiabaticIntertwining A P X dX (‖gap‖⁻¹ * (2 * L)) (‖gap‖⁻¹ * (2 * M))
    (fun t _ => hc t) (fun t ht => hsolve t ht ▸ hp t ht) hdx
    (fun t ht => (hbound t ht (P' t)).trans (by gcongr; exact hL t ht))
    (fun t ht => (hbound t ht (P'' t)).trans (by gcongr; exact hM t ht)) T U V ev s hs
  exact (leakage_le_intertwining (P s) (U s) (proj 0) (hnorm 0 ⟨le_rfl, zero_le_one⟩)).trans
    (main.trans_eq (by ring))

theorem reducedResolventPreparation (a : ℝ → ℂ) (B S P P' : ℝ → R) (g L D : ℝ) :
    ReducedResolventPreparation a B S P P' g L D := by
  intro hg proj kernel inverse bounds hp X hX T U V ev s hs
  let A := fun t => a t • (1 : R) + B t
  have hcomm (t : ℝ) (ht : t ∈ Icc 0 1) : Commute (A t) (P t) := by
    show A t * P t = P t * A t
    simp [A, add_mul, mul_add, (kernel t ht).1, (kernel t ht).2]
  have solve (t : ℝ) (ht : t ∈ Icc 0 1) : A t * X t - X t * A t = P' t := by
    have d := projectionDerivative proj (hp t ht)
    simp only [A, add_mul, mul_add, smul_mul_assoc, mul_smul_comm, one_mul, mul_one,
      add_sub_add_left_eq_sub]
    change B t * (S t * P' t * P t - P t * P' t * S t) -
      (S t * P' t * P t - P t * P' t * S t) * B t = P' t
    simp only [mul_sub, sub_mul]
    rw [← mul_assoc (B t) _ (P t), ← mul_assoc (B t) _ (P' t), (inverse t ht).1,
      ← mul_assoc (B t) _ (S t), ← mul_assoc (B t) _ (P' t), (kernel t ht).1,
      zero_mul, zero_mul, sub_zero, mul_assoc _ (P t) (B t), (kernel t ht).2, mul_zero,
      mul_assoc _ (S t) (B t), (inverse t ht).2]
    simp only [mul_sub, sub_mul, one_mul, mul_one, zero_sub, sub_neg_eq_add]
    apply Eq.trans _ d
    simp only [mul_sub, sub_mul, ← mul_assoc, proj]
    rw [mul_assoc (P' t), proj]
    abel
  have bound (t : ℝ) (ht : t ∈ Icc 0 1) : ‖X t‖ ≤ 2 * (L / g) := by
    obtain ⟨hr, hP, hd⟩ := bounds t ht
    have hL : 0 ≤ L := (norm_nonneg _).trans hd
    have triple (u v w : R) : ‖u * v * w‖ ≤ ‖u‖ * ‖v‖ * ‖w‖ :=
      (norm_mul_le ..).trans (by gcongr; exact norm_mul_le ..)
    calc
      _ ≤ ‖S t‖ * ‖P' t‖ * ‖P t‖ + ‖P t‖ * ‖P' t‖ * ‖S t‖ :=
        (norm_sub_le ..).trans (add_le_add (triple ..) (triple ..))
      _ ≤ (1 / g) * L * 1 + 1 * L * (1 / g) := by gcongr
      _ = _ := by ring
  have main := adiabaticIntertwining A P X (deriv X) (2 * (L / g)) D hcomm
    (fun t ht => solve t ht ▸ hp t ht) (fun t ht => (hX t ht).1.hasDerivAt)
    bound (fun t ht => (hX t ht).2) T U V ev s hs
  exact (leakage_le_intertwining (P s) (U s) (proj 0) (bounds 0 ⟨le_rfl, zero_le_one⟩).2.1).trans
    (main.trans_eq (by ring))

/-- Preparation at the end of a fixed two-band path approaches the target
subspace as runtime tends to infinity. The constants control the common
path, independently of the runtime of the Schrödinger solution. -/
theorem gappedBandPreparation_limit (a : ℝ → ℂ) {gap : ℂ} (hgap : gap ≠ 0)
    {P P' P'' : ℝ → R} {L M : ℝ} (proj : ∀ s, P s * P s = P s)
    (hP : ∀ s ∈ Icc (0 : ℝ) 1, ‖P s‖ ≤ 1)
    (hp : ∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt P (P' s) s)
    (hpp : ∀ s ∈ Icc (0 : ℝ) 1, HasDerivAt P' (P'' s) s)
    (hL : ∀ s ∈ Icc (0 : ℝ) 1, ‖P' s‖ ≤ L)
    (hM : ∀ s ∈ Icc (0 : ℝ) 1, ‖P'' s‖ ≤ M)
    (U V : ℝ → ℝ → R)
    (evol : ∀ T > 0, SlowEvolution (fun t => a t • (1 : R) + gap • P t) T (U T) (V T)) :
    Filter.Tendsto (fun T => ‖(1 - P 1) * U T 1 * P 0‖) Filter.atTop (nhds 0) := by
  apply squeeze_zero' (Filter.Eventually.of_forall fun _ => norm_nonneg _)
  · filter_upwards [Filter.eventually_gt_atTop (0 : ℝ)] with T hT
    have h := gappedBandPreparation a gap P P' P'' L M hgap proj hP hp hpp hL hM T
      (U T) (V T) (evol T hT) 1 ⟨zero_le_one, le_rfl⟩
    exact h.trans_eq (show _ = ((4 * L + 2 * M) / ‖gap‖) / T by ring)
  · exact Filter.Tendsto.div_atTop tendsto_const_nhds Filter.tendsto_id

end FQChem.StatePrep.AdiabaticPreparation
