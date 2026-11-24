module

public import FQChem.Multiscale.ChoosingLayers.ClassicalEnvironments
public import FQChem.StatePrep.ImaginaryTimeProjection.GroundStateProjection
public import FQChem.Properties.ResponseAndEstimation.HellmannFeynman
public import FQChem.Dynamics.RealTimePropagation.BornOppenheimer

@[expose] public section
noncomputable section

namespace FQChem.Multiscale

open Filter StatePrep.ImaginaryTimeProjection
open scoped InnerProductSpace Topology

section Projection

variable {g e : ℕ} (fullMM ground modelMM : ℝ → ℝ) (S : ℝ → SpectralData g e)

/-- ONIOM energy using the normalized imaginary-time state for the high-level model.
At geometry x, the model eigenvalues are ground x and ground x + (S x).excitation i. -/
def projectedLayeredEnergy (τ x : ℝ) : ℝ :=
  layered fullMM (fun y => ground y + energyExcess (S y) τ) modelMM x

/-- At a fixed geometry the two MM contributions cancel out of the solver error. -/
theorem projectedLayeredEnergy_eq (τ x : ℝ) :
    projectedLayeredEnergy fullMM ground modelMM S τ x =
      layered fullMM ground modelMM x + energyExcess (S x) τ := by
  unfold projectedLayeredEnergy layered
  ring

/-- The finite-time energy is an upper bound for the converged ONIOM energy, with
the same gap, overlap factor and excitation cutoff as the high-level model. -/
theorem layeredProjectionError (x W : ℝ) (hW : 0 ≤ W)
    (cap : ∀ i, (S x).excitation i ≤ W) (τ : ℝ) (hτ : 0 ≤ τ) :
    let error := projectedLayeredEnergy fullMM ground modelMM S τ x - layered fullMM ground modelMM x
    0 ≤ error ∧ error ≤ W * (excitedMass (S x) 0 / groundMass (S x) *
      Real.exp (-(2 * (S x).gap) * τ)) := by
  dsimp only
  rw [projectedLayeredEnergy_eq, add_sub_cancel_left]
  exact energyBound (S x) W hW cap τ hτ

/-- Pointwise convergence of the layered energy as projection time tends to infinity. -/
theorem layeredProjectionLimit (x : ℝ) :
    Tendsto (fun τ => projectedLayeredEnergy fullMM ground modelMM S τ x) atTop
      (𝓝 (layered fullMM ground modelMM x)) := by
  simpa only [projectedLayeredEnergy_eq, add_zero] using
    (show Tendsto (energyExcess (S x)) atTop (𝓝 0) from energyLimit (S x)).const_add
      (layered fullMM ground modelMM x)

end Projection

section Forces

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
variable {H : ℝ → V →L[ℝ] V} {H' : V →L[ℝ] V} {ψ : ℝ → V} {ψ' : V}
variable {fullMM energy modelMM : ℝ → ℝ} {f l : ℝ}

/-- A normalized electronic eigenbranch supplies the high-level derivative. The
full-system MM force is added and the doubly counted model MM force is subtracted. -/
theorem layeredEigenForce {x : ℝ}
    (hf : HasDerivAt fullMM (-f) x) (hl : HasDerivAt modelMM (-l) x)
    (hH : HasDerivAt H H' x) (hψ : HasDerivAt ψ ψ' x)
    (hsym : (H x).toLinearMap.IsSymmetric) (hnorm : ‖ψ x‖ = 1)
    (heigen : ∀ᶠ y in 𝓝 x, H y (ψ y) = energy y • ψ y) :
    HasDerivAt (layered fullMM energy modelMM) (-(f - ⟪ψ x, H' (ψ x)⟫_ℝ - l)) x := by
  have henergy := hellmannFeynman V hH hψ hsym hnorm heigen
  apply layeredForce fullMM energy modelMM x f (-⟪ψ x, H' (ψ x)⟫_ℝ) l hf _ hl
  simpa only [neg_neg] using henergy

/-- Along one-coordinate Newton motion driven by the eigenbranch and MM forces,
the derivative of kinetic plus layered potential energy vanishes. -/
theorem layeredBornOppenheimerEnergy {mass t : ℝ} {q v : ℝ → ℝ} (hm : 0 < mass)
    (hq : HasDerivAt q (v t) t)
    (hv : HasDerivAt v ((f - ⟪ψ (q t), H' (ψ (q t))⟫_ℝ - l) / mass) t)
    (hf : HasDerivAt fullMM (-f) (q t)) (hl : HasDerivAt modelMM (-l) (q t))
    (hH : HasDerivAt H H' (q t)) (hψ : HasDerivAt ψ ψ' (q t))
    (hsym : (H (q t)).toLinearMap.IsSymmetric) (hnorm : ‖ψ (q t)‖ = 1)
    (heigen : ∀ᶠ y in 𝓝 (q t), H y (ψ y) = energy y • ψ y) :
    HasDerivAt (fun s => mass * (v s) ^ 2 / 2 + layered fullMM energy modelMM (q s)) 0 t :=
  Dynamics.bornOppenheimerEnergy mass q v _ t _ hm hq hv
    (layeredEigenForce hf hl hH hψ hsym hnorm heigen)

end Forces
end FQChem.Multiscale
