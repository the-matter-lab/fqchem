module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticPathWeights
import Mathlib.Tactic

/-! # Injective encoding of the paths through a Metropolis transition

At a fixed current subgraph and edge, U determines the symmetric difference of the
two endpoints. Its deterministic trail order recovers the prefix and both endpoints.
Summing the encoded weights gives a uniform canonical-path load bound.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
open scoped symmDiff
variable {n : ℕ}

def route (g : Glass n) (D : Finset (Spin n)) :=
  if h : D ⊆ g.bonds then (canonicalOrdering g D h).choose else []

theorem routeSpec (g : Glass n) (D : Finset (Spin n)) (hd : D ⊆ g.bonds) :
    (route g D).Nodup ∧ (route g D).toFinset = D ∧ ∀ k, twoDefects D ((route g D).take k).toFinset := by
  simpa only [route,dite_eq_left hd] using (canonicalOrdering g D hd).choose_spec

def before (g : Glass n) (D : Finset (Spin n)) (e : Spin n) :=
  ((route g D).take ((route g D).idxOf e)).toFinset

theorem differenceSubset {B : Finset (Spin n)} (I F : Config B) : I.val ∆ F.val ⊆ B :=
  Finset.symmDiff_subset_union.trans (Finset.union_subset (Finset.mem_powerset.mp I.property) (Finset.mem_powerset.mp F.property))

theorem beforeSubset (g : Glass n) {D : Finset (Spin n)} (h : D⊆g.bonds) (e : Spin n) :
    before g D e ⊆ D := by
  intro a ha
  rw [← (routeSpec g D h).2.1]
  exact List.mem_toFinset.mpr (List.mem_of_mem_take (List.mem_toFinset.mp ha))

def intermediate (g : Glass n) (I F : Config g.bonds) (e : Spin n) : Config g.bonds :=
  ⟨I.val ∆ before g (I.val ∆ F.val) e, Finset.mem_powerset.mpr <| Finset.symmDiff_subset_union.trans
    (Finset.union_subset (Finset.mem_powerset.mp I.property)
      ((beforeSubset g (differenceSubset I F) e).trans (differenceSubset I F)))⟩

def encoding (g : Glass n) (I F : Config g.bonds) (e : Spin n) : Config g.bonds :=
  ⟨F.val ∆ before g (I.val ∆ F.val) e, Finset.mem_powerset.mpr <| Finset.symmDiff_subset_union.trans
    (Finset.union_subset (Finset.mem_powerset.mp F.property)
      ((beforeSubset g (differenceSubset I F) e).trans (differenceSubset I F)))⟩

def through (g : Glass n) (T : Config g.bonds) (e : Spin n) :=
  (Finset.univ : Finset (Config g.bonds × Config g.bonds)).filter fun a =>
    e∈(a.1.val∆a.2.val) ∧ intermediate g a.1 a.2 e=T

private theorem cancelBoth {α : Type*} [DecidableEq α] (I F P : Finset α) :
    (I∆P)∆(F∆P)=I∆F := by ext j; simp only [Finset.mem_symmDiff]; tauto

private theorem encodedDifference (g : Glass n) (I F : Config g.bonds) (e : Spin n) :
    (intermediate g I F e).val ∆ (encoding g I F e).val = I.val ∆ F.val :=
  cancelBoth ..

private theorem cancelRight {α : Type*} [DecidableEq α] (a b : Finset α) : (a∆b)∆b = a := by
  ext j; simp only [Finset.mem_symmDiff]; tauto

theorem encodingInjective (g : Glass n) (T : Config g.bonds) (e : Spin n) :
    Set.InjOn (fun a : Config g.bonds × Config g.bonds => encoding g a.1 a.2 e) ↑(through g T e) := by
  rintro ⟨i,f⟩ hi ⟨j,k⟩ hj same
  have ai := (Finset.mem_filter.mp hi).2.2
  have aj := (Finset.mem_filter.mp hj).2.2
  change intermediate g i f e=T at ai
  change intermediate g j k e=T at aj
  change encoding g i f e=encoding g j k e at same
  have diff : i.val∆f.val=j.val∆k.val := by
    rw [← encodedDifference g i f e, ← encodedDifference g j k e, ai,aj,same]
  have left := congrArg Subtype.val (ai.trans aj.symm)
  have right := congrArg Subtype.val same
  change i.val∆before g (i.val∆f.val) e=j.val∆before g (j.val∆k.val) e at left
  change f.val∆before g (i.val∆f.val) e=k.val∆before g (j.val∆k.val) e at right
  rw [diff] at left right
  let P := before g (j.val∆k.val) e
  change i.val∆P=j.val∆P at left
  change f.val∆P=k.val∆P at right
  exact Prod.ext (Subtype.ext (by simpa only [cancelRight] using congrArg (fun a => a∆P) left))
    (Subtype.ext (by simpa only [cancelRight] using congrArg (fun a => a∆P) right))

/-- The total endpoint weight for paths using a fixed intermediate subgraph and
edge is at most w(T)Z/u⁴. No unspecified congestion or mixing constant occurs. -/
theorem congestion (g : Glass n) {x u : ℝ} (hx : 0<x) (hu : 0<u) (u1 : u≤1)
    (T : Config g.bonds) (e : Spin n) :
    u^4*(∑ a ∈ through g T e, boostedWeight x u a.1.val * boostedWeight x u a.2.val) ≤
      boostedWeight x u T.val * boostedMass g.bonds x u := by
  let w := fun a : Config g.bonds => boostedWeight x u a.val
  let U := fun a : Config g.bonds × Config g.bonds => encoding g a.1 a.2 e
  have point (a : Config g.bonds × Config g.bonds) (ha : a ∈ through g T e) :
      u^4*(w a.1*w a.2) ≤ w T*w (U a) := by
    have hd := differenceSubset a.1 a.2
    have bound := weightComparison hx.le hu u1 a.1.val a.2.val (before g (a.1.val∆a.2.val) e)
      (beforeSubset g hd e) ((routeSpec g _ hd).2.2 _)
    have eq := (Finset.mem_filter.mp ha).2.2
    rw [← eq]
    simpa only [w,U,intermediate,encoding,mul_assoc] using bound
  change u^4*(∑ a ∈ through g T e, w a.1*w a.2) ≤ _
  rw [Finset.mul_sum]
  calc _ ≤ ∑ a ∈ through g T e, w T*w (U a) := Finset.sum_le_sum point
       _ = w T*(∑ a ∈ (through g T e).image U, w a) := by
         rw [Finset.sum_image (encodingInjective g T e),Finset.mul_sum]
       _ ≤ w T*(∑ a, w a) := by
         apply mul_le_mul_of_nonneg_left _ (boostedWeightPositive hx hu _).le
         exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun a _ _ => (boostedWeightPositive hx hu a.val).le)
       _ = _ := by
         congr 1
         exact Finset.sum_attach _ (boostedWeight x u)

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
