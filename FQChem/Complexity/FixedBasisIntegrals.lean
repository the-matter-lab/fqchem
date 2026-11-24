module

public import FQChem.Complexity.FixedBasisSelfEnergy
public import FQChem.Complexity.SlaterEnergyOrbitals
import Mathlib.Tactic

/-! # Finite evaluation of compact-orbital intercenter coefficients

The graph is input as an explicit Boolean adjacency table. All cross-center
terms are rational reciprocals of integer distances along the center line.
-/

@[expose] public section
namespace FQChem.Complexity.FixedBasisIntegrals
open MeasureTheory FixedBasisGeometry FixedBasisGaussians FixedBasisShell SlaterEnergyCoulomb SlaterEnergyOrbitals
variable {n : ℕ}

def coordinateCode (adj : Fin n → Fin n → Bool) (R : ℕ) (i j : Fin n) : ℕ :=
  ((max i j).val+n*(min i j).val)*(3*R) +
    (if i≤j then 0 else if adj i j then 4 else R)

def reciprocal (adj : Fin n → Fin n → Bool) (R : ℕ) (i u j v : Fin n) : ℚ :=
  1/|(coordinateCode adj R i u : ℚ) - coordinateCode adj R j v|

/-- The normalized spatial coefficient, parameterized by the universal
single-component self interaction. All arithmetic is rational. -/
def directCode (adj : Fin n → Fin n → Bool) (R : ℕ) (self : ℚ) (i j : Fin n) : ℚ :=
  (∑ u, ∑ v, if (i,u)=(j,v) then self else reciprocal adj R i u j v) / (n:ℚ)^2

theorem coordinate_eq (adj : Fin n → Fin n → Bool) (G : SimpleGraph (Fin n))
    (h : ∀ i j, adj i j=true ↔ G.Adj i j) (R : ℕ) (i j : Fin n) :
    coordinateCode adj R i j = coordinate G R i j := by
  simp only [coordinateCode,coordinate,offset,block,finProdFinEquiv,Equiv.coe_fn_mk]
  congr 1
  by_cases hij : i≤j <;> by_cases he : G.Adj i j <;> simp_all

private theorem self_translation (A : Space) : interaction A A = interaction 0 0 := by
  let e := ((Homeomorph.addRight A).toMeasurableEquiv.prodCongr (Homeomorph.addRight A).toMeasurableEquiv)
  have mp : MeasureTheory.MeasurePreserving e (MeasureTheory.volume.prod MeasureTheory.volume)
      (MeasureTheory.volume.prod MeasureTheory.volume) :=
    (measurePreserving_add_right _ A).prod (measurePreserving_add_right _ A)
  rw [interaction,interaction,←mp.integral_comp e.measurableEmbedding (fun p => density A p.1 * density A p.2 / dist p.1 p.2)]
  apply MeasureTheory.integral_congr_ae
  filter_upwards with p
  change density A (p.1+A) * density A (p.2+A) / dist (p.1+A) (p.2+A) = _
  simp [density,wave]

/-- Each offsite spatial coefficient is a finite rational sum whose
denominators are computed from the Boolean graph and integers. -/
theorem directCode_correct (adj : Fin n → Fin n → Bool) (G : SimpleGraph (Fin n))
    (h : ∀ i j, adj i j=true ↔ G.Adj i j) (R : ℕ) (hR : 4≤R) (self : ℚ) (i j : Fin n)
    (hself : i≠j ∨ (self:ℝ)=interaction 0 0) :
    (directCode adj R self i j : ℝ)=direct G R i j := by
  classical
  rw [direct_formula G R hR,directCode]
  push_cast
  congr 1
  apply Finset.sum_congr rfl; intro u _
  apply Finset.sum_congr rfl; intro v _
  by_cases eq : (i,u)=(j,v)
  · obtain ⟨rfl,rfl⟩ := Prod.mk.inj eq
    simp only [ite_true]
    exact (hself.resolve_left (by simp)).trans (self_translation _).symm
  · rw [ite_eq_right eq, separatedInteraction _ _ (lt_of_lt_of_le (by norm_num) (separated G R hR i u j v eq))]
    simp only [reciprocal,Rat.cast_div,Rat.cast_one,Rat.cast_abs,Rat.cast_sub,
      Rat.cast_natCast,coordinate_eq adj G h]
    rw [dist_eq_norm]
    simp [FixedBasisGeometry.center,←PiLp.single_sub,Real.norm_eq_abs]

/-- All four-index spatial Coulomb coefficients of the constructed orbitals
as an executable rational function of the Boolean adjacency table. -/
def evaluate (adj : Fin n → Fin n → Bool) (R : ℕ) (i l j k : Fin n) : ℚ :=
  if i=l ∧ j=k then directCode adj R (396396/185725) i j else 0

theorem evaluate_correct (adj : Fin n → Fin n → Bool) (G : SimpleGraph (Fin n))
    (h : ∀ i j, adj i j=true ↔ G.Adj i j) (R : ℕ) (hR : 4≤R) (i l j k : Fin n) :
    (evaluate adj R i l j k : ℝ)=coefficient G R i l j k := by
  by_cases hij : i=l ∧ j=k
  · obtain ⟨rfl,rfl⟩ := hij
    simp only [evaluate,and_self,ite_true]
    exact directCode_correct _ _ h _ hR _ _ _ (Or.inr (by norm_num [FixedBasisSelfEnergy.self_value]))
  · rw [evaluate,ite_eq_right hij,coefficient_offdiag G R hR (by tauto)]
    simp

end FQChem.Complexity.FixedBasisIntegrals
