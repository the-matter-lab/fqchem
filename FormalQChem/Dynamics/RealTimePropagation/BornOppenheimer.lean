module

public import Mathlib.Analysis.InnerProductSpace.Calculus
public import Mathlib.Analysis.InnerProductSpace.Symmetric
public import Mathlib.LinearAlgebra.Matrix.Hermitian
public import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add

@[expose] public section

namespace FormalQChem.Dynamics

open Matrix
open scoped InnerProductSpace ComplexConjugate

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

/-- Along a one-coordinate Born–Oppenheimer Newton trajectory on a
differentiable adiabatic energy surface, total mechanical energy is stationary. -/
def BornOppenheimerEnergy (mass : ℝ) (q v U : ℝ → ℝ) (t force : ℝ) : Prop :=
  0 < mass → HasDerivAt q (v t) t → HasDerivAt v (force / mass) t →
  HasDerivAt U (-force) (q t) →
  HasDerivAt (fun s => mass * (v s) ^ 2 / 2 + U (q s)) 0 t

theorem bornOppenheimerEnergy (mass : ℝ) (q v U : ℝ → ℝ) (t force : ℝ) :
    BornOppenheimerEnergy mass q v U t force := by
  intro hm hq hv hU
  have h := (((hv.pow 2).const_mul mass).div_const 2).add (hU.comp t hq)
  convert h using 1
  · funext s
    rfl
  · norm_num
    field_simp [hm.ne']
    ring

end FormalQChem.Dynamics
