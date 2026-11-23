module

public import FormalQChem.Multiscale.StitchingSolutions.EmbeddedSolvers.Theorems

public section
namespace FormalQChem.Multiscale.Embedding

theorem feshbachReduction {X Y : Type*} [AddCommGroup X] [Module ℂ X] [AddCommGroup Y] [Module ℂ Y]
    (A : X →ₗ[ℂ] X) (B : Y →ₗ[ℂ] X) (C : X →ₗ[ℂ] Y) (D : Y →ₗ[ℂ] Y)
    (z : ℂ) (R : Y ≃ₗ[ℂ] Y) : FeshbachReduction A B C D z R := by
  intro resolvent x y
  have eliminate : C x + D y = z • y ↔ y = R.symm (C x) := by
    rw [R.eq_symm_apply, resolvent]
    exact eq_sub_iff_add_eq.symm.trans eq_comm
  constructor
  · rintro ⟨nonzero, active, env⟩
    have hy := eliminate.mp env
    refine ⟨?_, hy ▸ active, hy⟩
    rintro rfl
    simp_all
  · rintro ⟨hx, active, hy⟩
    exact ⟨Or.inl hx, hy ▸ active, eliminate.mpr hy⟩

end FormalQChem.Multiscale.Embedding
