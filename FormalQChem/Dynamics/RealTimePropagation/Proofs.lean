module

public import FormalQChem.Dynamics.RealTimePropagation.Theorems

/-! # The bounded Schrödinger unitary group -/

@[expose] public section

namespace FormalQChem.Dynamics.RealTimePropagation

open NormedSpace
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]

theorem unitaryEvolution (H : E →L[ℂ] E) : UnitaryEvolution H := by
  let +nondep : NormedAlgebra ℚ (E →L[ℂ] E) := .restrictScalars ℚ ℂ _
  intro hH
  refine ⟨by simp [evolution], ?_, ?_, fun t ↦ hasDerivAt_exp_smul_const' (generator H) t⟩
  · intro s t
    rw [evolution, add_smul]
    exact exp_add_of_commute (((Commute.refl (generator H)).smul_left s).smul_right t)
  · intro t
    apply exp_mem_unitary_of_mem_skewAdjoint
    rw [skewAdjoint.mem_iff]
    simp [generator, star_smul, hH.star_eq]

end FormalQChem.Dynamics.RealTimePropagation
