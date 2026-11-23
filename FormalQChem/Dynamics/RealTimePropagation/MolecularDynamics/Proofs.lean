module

public import FormalQChem.Dynamics.RealTimePropagation.MolecularDynamics.Theorems
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add

public section

namespace FormalQChem.Dynamics

open Matrix
open scoped InnerProductSpace ComplexConjugate

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

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

theorem ringPolymerSpringForce {b : Type*} [Fintype b] (next : Equiv.Perm b)
    (q : b → ℝ) (spring : ℝ) : RingPolymerSpringForce next q spring := by
  unfold RingPolymerSpringForce
  rw [← Finset.mul_sum, Finset.sum_sub_distrib, Finset.sum_add_distrib,
    Equiv.sum_comp next q, Equiv.sum_comp next.symm q, ← Finset.mul_sum]
  ring

theorem tdConfigurationInteraction {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (H : V →ₗ[ℝ] V) (a b : ℝ → V) (t : ℝ) : TDConfigurationInteraction H a b t := by
  intro hH ha hb
  have h := HasDerivAt.add (ha.inner ℝ ha) (hb.inner ℝ hb)
  convert h using 1
  rw [inner_neg_left, inner_neg_right, hH (b t) (a t), ← hH (a t) (b t)]
  ring

end FormalQChem.Dynamics
