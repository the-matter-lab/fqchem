module

public import Mathlib.Analysis.Calculus.Deriv.Mul
public import Mathlib.Analysis.Complex.Basic

/-! # Adiabatic transport of an isolated spectral band

Time is rescaled to the unit interval. For quantum evolution, the generator
is `A(s) = -i H(s)` in units with ℏ = 1 and multiplication is operator
composition. Bounds use the submultiplicative norm (operator norm in the
Hilbert-space application).
-/

@[expose] public section

namespace FormalQChem.StatePrep.AdiabaticPreparation

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

end FormalQChem.StatePrep.AdiabaticPreparation
