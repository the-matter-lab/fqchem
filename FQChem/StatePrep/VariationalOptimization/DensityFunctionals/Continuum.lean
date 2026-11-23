/-
Copyright (c) 2026 Miguel A. L. Marques. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Miguel A. L. Marques
Adapted for FQChem from hyllios/lean_dft, revision b9065256a6ddb1a7a4e1df3fbbf49a9a3fd546a4.
-/
module

public import Mathlib.MeasureTheory.Integral.Bochner.Basic
public import Mathlib.Data.EReal.Operations
public import Mathlib.Tactic.Linarith
public import Mathlib.Tactic.FieldSimp
public import Mathlib.Algebra.QuadraticDiscriminant
public import Mathlib.Tactic.Ring

/-!
# Ground-state density functional theory

For a fixed internal energy form, a density records the expectation of every one-body
potential. In molecular notation this pairing is `ρ(v) = ∫ ρ(r) v(r) dr`.
The infima and suprema take extended real values. Existence of a normalized
minimizer is a separate hypothesis in the attainment statement.

The continuum proofs follow Miguel A. L. Marques's `DFT/Continuum/General/{HK,Lieb}.lean`.
The quadratic variation argument uses the discriminant bound in mathlib.
This port uses mathlib's extended-real cancellation lemmas and formulates the
energy infimum directly over representable densities.
-/

@[expose] public section

namespace FQChem.DFT

open MeasureTheory

variable {X : Type*} [MeasurableSpace X] {μ : Measure X} {P : Type*} [AddCommGroup P] [Module ℝ P]

/-- A real-wavefunction quantum system on the configuration space `(X, μ)` with one-body potentials in `P`. -/
structure Setting (μ : Measure X) (P : Type*) [AddCommGroup P] [Module ℝ P] where
  /-- The form domain. -/
  D : Submodule ℝ (X → ℝ)
  /-- The potential-free energy form (kinetic energy plus interaction), bilinear on `D`. -/
  h0 : (X → ℝ) → (X → ℝ) → ℝ
  h0_add : ∀ a ∈ D, ∀ b ∈ D, ∀ c ∈ D, h0 (a + b) c = h0 a c + h0 b c
  h0_smul : ∀ r : ℝ, ∀ a ∈ D, ∀ c ∈ D, h0 (r • a) c = r * h0 a c
  h0_symm : ∀ ψ ∈ D, ∀ φ ∈ D, h0 ψ φ = h0 φ ψ
  /-- The coupling of one-body potentials to configurations. -/
  L : P →ₗ[ℝ] (X → ℝ)
  int_L : ∀ w ψ φ, ψ ∈ D → φ ∈ D → Integrable (fun x => L w x * (ψ x * φ x)) μ
  int_sq : ∀ ψ φ, ψ ∈ D → φ ∈ D → Integrable (fun x => ψ x * φ x) μ

variable (S : Setting μ P)

/-- The `L²` inner product. -/
noncomputable def ip (ψ φ : X → ℝ) : ℝ := ∫ x, ψ x * φ x ∂μ

/-- The potential energy form of `w`. -/
noncomputable def pf (w : P) (ψ φ : X → ℝ) : ℝ := ∫ x, S.L w x * (ψ x * φ x) ∂μ

/-- The energy `⟨ψ, H(w) ψ⟩`. -/
noncomputable def Q (w : P) (ψ : X → ℝ) : ℝ := S.h0 ψ ψ + pf S w ψ ψ

/-- The density of `ψ`, as a functional on one-body potentials. -/
noncomputable def dens (ψ : X → ℝ) (w : P) : ℝ := pf S w ψ ψ

/-- `ψ` is a ground state of `H(w)`: a nonzero minimiser of the Rayleigh quotient on `D`. -/
def IsGS (w : P) (ψ : X → ℝ) : Prop :=
  ψ ∈ S.D ∧ 0 < ip (μ := μ) ψ ψ ∧
    ∀ φ ∈ S.D, Q S w ψ * ip (μ := μ) φ φ ≤ Q S w φ * ip (μ := μ) ψ ψ

/-- The form domain separates the functions `(L w - c) ψ` (fundamental lemma of the calculus of
variations). -/
def Sep : Prop :=
  ∀ (w : P) (c : ℝ) (ψ : X → ℝ), ψ ∈ S.D →
    (∀ φ ∈ S.D, ∫ x, (S.L w x - c) * ψ x * φ x ∂μ = 0) →
      (fun x => (S.L w x - c) * ψ x) =ᵐ[μ] 0

/-- Rigidity: a one-body potential whose coupling is a.e. constant is a multiple of `one`. -/
def RigidL (one : P) : Prop :=
  ∀ (w : P) (c : ℝ), (S.L w =ᵐ[μ] fun _ => c) → ∃ k : ℝ, w = k • one

/-- Normalised states. -/
def Nst : Set (X → ℝ) := {ψ | ψ ∈ S.D ∧ ip (μ := μ) ψ ψ = 1}

/-- `ψ` is a normalised ground state of `H(v)`. -/
def IsNGS (v : P) (ψ : X → ℝ) : Prop :=
  ψ ∈ Nst S ∧ ∀ φ ∈ Nst S, Q S v ψ ≤ Q S v φ

/-- The ground-state energy. -/
noncomputable def gsE (v : P) : EReal := ⨅ ψ ∈ Nst S, ((Q S v ψ : ℝ) : EReal)

/-- The Lieb functional. -/
noncomputable def liebF (ρ : P → ℝ) : EReal := ⨆ v, gsE S v - ((ρ v : ℝ) : EReal)

/-- Densities realized by normalized states in the model's form domain. -/
def Representable (ρ : P → ℝ) : Prop := ∃ ψ ∈ Nst S, dens S ψ = ρ

/-- Hohenberg–Kohn (1964). Equally normalized ground states with the same density determine
the external potential up to a constant. Separation, rigidity, and almost-everywhere
nonvanishing of one ground state are explicit analytic hypotheses. -/
def HohenbergKohn (one : P) : Prop :=
  Sep S → RigidL S one →
    ∀ {v v' : P} {ψ ψ' : X → ℝ}, IsGS S v ψ → IsGS S v' ψ' →
      ip (μ := μ) ψ ψ = ip (μ := μ) ψ' ψ' → dens S ψ = dens S ψ' →
      (∀ᵐ x ∂μ, ψ x ≠ 0) → ∃ k : ℝ, v - v' = k • one

/-- The universal-functional variational identity for every external potential.
The infimum runs over representable densities. -/
def VariationalPrinciple (F : (P → ℝ) → EReal) : Prop :=
  ∀ v : P, gsE S v = ⨅ ρ : {ρ // Representable S ρ}, F ρ.val + (ρ.val v : EReal)

/-- Existence of one potential-independent functional recovering all ground-state energies. -/
def UniversalFunctionalExists : Prop := ∃ F, VariationalPrinciple S F

/-- At the density of a normalized ground state, the Lieb functional gives its internal energy. -/
def GroundDensityExactness : Prop :=
  ∀ {v : P} {ψ : X → ℝ}, IsNGS S v ψ → liebF S (dens S ψ) = (S.h0 ψ ψ : EReal)

private lemma lin_coeff_zero {a b : ℝ} (h : ∀ s : ℝ, 0 ≤ a * s + b * s ^ 2) : a = 0 := by
  have hd : discrim b a 0 ≤ 0 :=
    discrim_le_zero fun s => by simpa only [add_zero, ← sq, add_comm] using h s
  have ha : a * a ≤ 0 := by simpa only [discrim, mul_zero, sub_zero, sq] using hd
  exact mul_self_eq_zero.mp (le_antisymm ha (mul_self_nonneg a))

section expand

variable {g : X → ℝ} {ψ φ : X → ℝ}

/-- Expansion of a weighted quadratic form along `ψ + s φ`. -/
lemma integral_expand (hψψ : Integrable (fun x => g x * (ψ x * ψ x)) μ)
    (hψφ : Integrable (fun x => g x * (ψ x * φ x)) μ)
    (hφφ : Integrable (fun x => g x * (φ x * φ x)) μ) (s : ℝ) :
    ∫ x, g x * ((ψ + s • φ) x * (ψ + s • φ) x) ∂μ =
      ∫ x, g x * (ψ x * ψ x) ∂μ + 2 * s * ∫ x, g x * (ψ x * φ x) ∂μ +
        s ^ 2 * ∫ x, g x * (φ x * φ x) ∂μ := by
  have hpt : (fun x => g x * ((ψ + s • φ) x * (ψ + s • φ) x)) =
      fun x => (g x * (ψ x * ψ x) + (2 * s) * (g x * (ψ x * φ x))) +
        s ^ 2 * (g x * (φ x * φ x)) := by
    funext x; simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]; ring
  rw [hpt, integral_add (f := fun x => g x * (ψ x * ψ x) + 2 * s * (g x * (ψ x * φ x)))
    (hψψ.add (hψφ.const_mul _)) (hφφ.const_mul _),
    integral_add (f := fun x => g x * (ψ x * ψ x)) hψψ (hψφ.const_mul _), integral_const_mul,
    integral_const_mul]

end expand

variable {S}

lemma ip_expand {ψ φ : X → ℝ} (hψ : ψ ∈ S.D) (hφ : φ ∈ S.D) (s : ℝ) :
    ip (μ := μ) (ψ + s • φ) (ψ + s • φ) =
      ip (μ := μ) ψ ψ + 2 * s * ip (μ := μ) ψ φ + s ^ 2 * ip (μ := μ) φ φ := by
  have h := integral_expand (μ := μ) (g := fun _ => 1) (ψ := ψ) (φ := φ)
    (by simpa using S.int_sq ψ ψ hψ hψ) (by simpa using S.int_sq ψ φ hψ hφ)
    (by simpa using S.int_sq φ φ hφ hφ) s
  simpa [ip] using h

lemma pf_expand (w : P) {ψ φ : X → ℝ} (hψ : ψ ∈ S.D) (hφ : φ ∈ S.D) (s : ℝ) :
    pf S w (ψ + s • φ) (ψ + s • φ) =
      pf S w ψ ψ + 2 * s * pf S w ψ φ + s ^ 2 * pf S w φ φ :=
  integral_expand (S.int_L w ψ ψ hψ hψ) (S.int_L w ψ φ hψ hφ) (S.int_L w φ φ hφ hφ) s

lemma h0_expand {ψ φ : X → ℝ} (hψ : ψ ∈ S.D) (hφ : φ ∈ S.D) (s : ℝ) :
    S.h0 (ψ + s • φ) (ψ + s • φ) = S.h0 ψ ψ + 2 * s * S.h0 ψ φ + s ^ 2 * S.h0 φ φ := by
  have hsφ : s • φ ∈ S.D := S.D.smul_mem s hφ
  have hψs : ψ + s • φ ∈ S.D := S.D.add_mem hψ hsφ
  rw [S.h0_add ψ hψ (s • φ) hsφ _ hψs, S.h0_smul s φ hφ _ hψs, S.h0_symm ψ hψ _ hψs,
    S.h0_symm φ hφ _ hψs, S.h0_add ψ hψ (s • φ) hsφ _ hψ, S.h0_smul s φ hφ _ hψ,
    S.h0_add ψ hψ (s • φ) hsφ _ hφ, S.h0_smul s φ hφ _ hφ, S.h0_symm φ hφ ψ hψ]
  ring

/-- **Euler–Lagrange equation.** A ground state of `H(w)` with energy `E = ⟨ψ,Hψ⟩/⟨ψ,ψ⟩` satisfies
the weak Schrödinger equation `h₀(ψ, φ) + ⟨w ψ, φ⟩ = E ⟨ψ, φ⟩` for every `φ` in the form domain. -/
theorem euler_lagrange {w : P} {ψ : X → ℝ} (hψ : IsGS S w ψ) {φ : X → ℝ} (hφ : φ ∈ S.D) :
    S.h0 ψ φ + pf S w ψ φ = Q S w ψ / ip (μ := μ) ψ ψ * ip (μ := μ) ψ φ := by
  obtain ⟨hD, hpos, hmin⟩ := hψ
  set p := ip (μ := μ) ψ ψ
  set q := Q S w ψ
  have key : ∀ s : ℝ, 0 ≤ (2 * (p * (S.h0 ψ φ + pf S w ψ φ) - q * ip (μ := μ) ψ φ)) * s +
      (p * Q S w φ - q * ip (μ := μ) φ φ) * s ^ 2 := by
    intro s
    have h := hmin (ψ + s • φ) (S.D.add_mem hD (S.D.smul_mem s hφ))
    rw [ip_expand hD hφ, Q, h0_expand hD hφ, pf_expand w hD hφ] at h
    have hq : q = S.h0 ψ ψ + pf S w ψ ψ := rfl
    have hp : ip (μ := μ) ψ ψ = p := rfl
    rw [hp] at h
    simp only [Q, hq] at h ⊢
    nlinarith [h]
  have h0 := lin_coeff_zero key
  field_simp
  linarith

/-- **Weak Hohenberg–Kohn.** If `ψ` and `ψ'` are ground states of `v` and `v'` with the same norm
and the same density, then `ψ` is also a ground state of `v'`. -/
theorem weak_hk {v v' : P} {ψ ψ' : X → ℝ} (hψ : IsGS S v ψ) (hψ' : IsGS S v' ψ')
    (hn : ip (μ := μ) ψ ψ = ip (μ := μ) ψ' ψ') (hd : dens S ψ = dens S ψ') : IsGS S v' ψ := by
  obtain ⟨hD, hpos, hmin⟩ := hψ
  obtain ⟨hD', hpos', hmin'⟩ := hψ'
  have hdv : pf S v ψ ψ = pf S v ψ' ψ' := congrFun hd v
  have hdv' : pf S v' ψ ψ = pf S v' ψ' ψ' := congrFun hd v'
  have h1 := hmin ψ' hD'
  have h2 := hmin' ψ hD
  rw [← hn] at h1 h2
  have h1' : Q S v ψ ≤ Q S v ψ' := le_of_mul_le_mul_right h1 hpos
  have h2' : Q S v' ψ' ≤ Q S v' ψ := le_of_mul_le_mul_right h2 hpos
  have heq : Q S v' ψ = Q S v' ψ' := by
    simp only [Q] at h1' h2' ⊢
    linarith
  refine ⟨hD, hpos, fun φ hφ => ?_⟩
  rw [heq, hn]
  exact hmin' φ hφ

/-- Subtracting the weak equations for a shared ground state makes the lifted
potential difference constant on configuration space, almost everywhere. -/
theorem commonStateConstantLift (hsep : Sep S) {v v' : P}
    {ψ : X → ℝ} (hψ : IsGS S v ψ) (hψ' : IsGS S v' ψ) (hucp : ∀ᵐ x ∂μ, ψ x ≠ 0) :
    ∃ c : ℝ, S.L (v - v') =ᵐ[μ] fun _ => c := by
  have hD := hψ.1
  set c := Q S v ψ / ip (μ := μ) ψ ψ - Q S v' ψ / ip (μ := μ) ψ ψ
  set g : X → ℝ := fun x => (S.L (v - v') x - c) * ψ x
  have hzero : ∀ φ ∈ S.D, ∫ x, (S.L (v - v') x - c) * ψ x * φ x ∂μ = 0 := by
    intro φ hφ
    have e1 := euler_lagrange hψ hφ
    have e2 := euler_lagrange hψ' hφ
    have hsplit : ∫ x, (S.L (v - v') x - c) * ψ x * φ x ∂μ =
        (pf S v ψ φ - pf S v' ψ φ) - c * ip (μ := μ) ψ φ := by
      have hpt : (fun x => (S.L (v - v') x - c) * ψ x * φ x) = fun x =>
          (S.L v x * (ψ x * φ x) - S.L v' x * (ψ x * φ x)) - c * (ψ x * φ x) := by
        funext x; simp only [map_sub, Pi.sub_apply]; ring
      rw [hpt, integral_sub (f := fun x => S.L v x * (ψ x * φ x) - S.L v' x * (ψ x * φ x))
        ((S.int_L v ψ φ hD hφ).sub (S.int_L v' ψ φ hD hφ))
        ((S.int_sq ψ φ hD hφ).const_mul c), integral_sub (f := fun x => S.L v x * (ψ x * φ x))
        (S.int_L v ψ φ hD hφ) (S.int_L v' ψ φ hD hφ), integral_const_mul]
      rfl
    rw [hsplit]
    simp only [c]
    linarith
  have hg : g =ᵐ[μ] 0 := hsep (v - v') c ψ hD hzero
  have hL : S.L (v - v') =ᵐ[μ] fun _ => c := by
    filter_upwards [hg, hucp] with x hx hx0
    simp only [g, Pi.zero_apply, mul_eq_zero] at hx
    exact sub_eq_zero.mp (hx.resolve_right hx0)
  exact ⟨c, hL⟩

/-- **Strong Hohenberg–Kohn, conditional on unique continuation.** If `v` and `v'` share a ground
state `ψ` that vanishes only on a null set, then `v - v'` is a multiple of `one`. -/
theorem strong_hk_of_ucp (hsep : Sep S) {one : P} (hrig : RigidL S one) {v v' : P}
    {ψ : X → ℝ} (hψ : IsGS S v ψ) (hψ' : IsGS S v' ψ) (hucp : ∀ᵐ x ∂μ, ψ x ≠ 0) :
    ∃ k : ℝ, v - v' = k • one := by
  obtain ⟨c, hL⟩ := commonStateConstantLift hsep hψ hψ' hucp
  exact hrig _ c hL

/-- The two variational inequalities give a common ground state. Subtracting its weak
Schrödinger equations identifies the external potentials up to a constant. -/
theorem hohenbergKohn (one : P) : HohenbergKohn S one := by
  intro hsep hrig v v' ψ ψ' hψ hψ' hn hd hucp
  exact strong_hk_of_ucp hsep hrig hψ (weak_hk hψ hψ' hn hd) hucp

private lemma energy_le_trial {v : P} {ψ : X → ℝ} (hψ : ψ ∈ Nst S) :
    gsE S v ≤ (Q S v ψ : EReal) := biInf_le _ hψ

private lemma energy_le_functional_add (v : P) (ρ : P → ℝ) :
    gsE S v ≤ liebF S ρ + (ρ v : EReal) := by
  have h := le_iSup (fun w => gsE S w - (ρ w : EReal)) v
  exact (EReal.sub_le_iff_le_add (.inl (EReal.coe_ne_bot _)) (.inl (EReal.coe_ne_top _))).mp h

private lemma functional_le_internal {ψ : X → ℝ} (hψ : ψ ∈ Nst S) :
    liebF S (dens S ψ) ≤ (S.h0 ψ ψ : EReal) := by
  refine iSup_le fun v => EReal.sub_le_of_le_add ?_
  rw [← EReal.coe_add]
  exact energy_le_trial hψ

/-- The Lieb functional recovers the exact energy by variation over representable densities. -/
theorem liebVariationalPrinciple : VariationalPrinciple S (liebF S) := by
  intro v
  apply le_antisymm
  · exact le_iInf fun ρ => energy_le_functional_add v ρ.val
  · refine le_iInf₂ fun ψ hψ => ?_
    let ρ : {ρ // Representable S ρ} := ⟨dens S ψ, ψ, hψ, rfl⟩
    refine (iInf_le _ ρ).trans ?_
    change liebF S (dens S ψ) + (dens S ψ v : EReal) ≤ (Q S v ψ : EReal)
    calc
      _ ≤ (S.h0 ψ ψ : EReal) + (dens S ψ v : EReal) := add_le_add (functional_le_internal hψ) le_rfl
      _ = (Q S v ψ : EReal) := by rw [← EReal.coe_add]; rfl

theorem universalFunctionalExists : UniversalFunctionalExists S :=
  ⟨liebF S, liebVariationalPrinciple⟩

theorem groundDensityExactness : GroundDensityExactness S := by
  intro v ψ h
  have hE : gsE S v = (Q S v ψ : EReal) :=
    le_antisymm (energy_le_trial h.1) (le_iInf₂ fun φ hφ => EReal.coe_le_coe_iff.mpr (h.2 φ hφ))
  apply le_antisymm (functional_le_internal h.1)
  have hdual := le_iSup (fun w => gsE S w - (dens S ψ w : EReal)) v
  rw [hE, ← EReal.coe_sub] at hdual
  simpa only [Q, liebF, dens, add_sub_cancel_right] using hdual

end FQChem.DFT
