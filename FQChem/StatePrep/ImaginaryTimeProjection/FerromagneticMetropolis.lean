module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticRejection
import Mathlib.Tactic

/-! # The lazy subgraphs-world Metropolis transition

Jerrum and Sinclair, Section 2. Choose an edge uniformly and propose toggling it.
The lazy Metropolis acceptance uses the ratio of the two explicitly evaluated
subgraph weights. The finite transition kernel preserves their normalized law.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

abbrev Config (B : Finset (Spin n)) := ↥B.powerset

def flip {B : Finset (Spin n)} (e : ↥B) (A : Config B) : Config B :=
  if e.val ∈ A.val then ⟨A.val.erase e,Finset.mem_powerset.mpr
    ((Finset.erase_subset _ _).trans (Finset.mem_powerset.mp A.property))⟩
  else ⟨insert e.val A.val,Finset.mem_powerset.mpr (Finset.insert_subset e.property (Finset.mem_powerset.mp A.property))⟩

private theorem flipTwice {B : Finset (Spin n)} (e : ↥B) (A : Config B) : flip e (flip e A) = A := by
  apply Subtype.ext
  by_cases h : e.val ∈ A.val <;> simp [flip,h]

private theorem flipDifferent {B : Finset (Spin n)} (e : ↥B) (A : Config B) : flip e A ≠ A := by
  intro he
  have same : e.val ∈ (flip e A).val ↔ e.val ∈ A.val := by rw [he]
  by_cases h : e.val ∈ A.val <;> simp [flip,h] at same

def acceptance {B : Finset (Spin n)} (w : Config B → ℝ) (e : ↥B) (A : Config B) :=
  min (w A) (w (flip e A)) / (2*w A)

def edgeStep {B : Finset (Spin n)} (w : Config B → ℝ) (e : ↥B) (A T : Config B) :=
  (if T=A then 1-acceptance w e A else 0) + (if T=flip e A then acceptance w e A else 0)

private theorem acceptanceBounds {B : Finset (Spin n)} (w : Config B → ℝ) (hw : ∀ a, 0 < w a)
    (e : ↥B) (A : Config B) : 0 < acceptance w e A ∧ acceptance w e A ≤ 1/2 := by
  unfold acceptance
  exact ⟨div_pos (lt_min (hw _) (hw _)) (by positivity [hw A]),
    (div_le_iff₀ (by positivity [hw A])).mpr (by linarith [min_le_left (w A) (w (flip e A))])⟩

private theorem edgeProbability {B : Finset (Spin n)} (w : Config B → ℝ) (hw : ∀ a, 0 < w a)
    (e : ↥B) (A : Config B) : (∀ T, 0 ≤ edgeStep w e A T) ∧ ∑ T, edgeStep w e A T = 1 := by
  have h := acceptanceBounds w hw e A
  constructor
  · intro T
    unfold edgeStep
    split_ifs <;> linarith
  · simp [edgeStep,Finset.sum_add_distrib]

private theorem edgeBalance {B : Finset (Spin n)} (w : Config B → ℝ) (hw : ∀ a, 0 < w a)
    (e : ↥B) (A T : Config B) : w A*edgeStep w e A T = w T*edgeStep w e T A := by
  by_cases same : A=T
  · rw [same]
  by_cases move : T=flip e A
  · subst T
    simp [edgeStep,flipTwice,flipDifferent,(flipDifferent e A).symm,acceptance,min_comm]
    field_simp [(hw A).ne', (hw (flip e A)).ne']
  · have back : A ≠ flip e T := fun h => move (by rw [h,flipTwice])
    simp [edgeStep,same,Ne.symm same,move,back]

def kernel (g : Glass n) (x u : ℝ) (A T : Config g.bonds) :=
  if g.bonds.card=0 then (if T=A then 1 else 0) else
    (∑ e : ↥g.bonds, edgeStep (fun p => boostedWeight x u p.val) e A T) / g.bonds.card

theorem kernelProbability (g : Glass n) {x u : ℝ} (hx : 0 < x) (hu : 0 < u) (A : Config g.bonds) :
    (∀ T, 0 ≤ kernel g x u A T) ∧ ∑ T, kernel g x u A T = 1 := by
  by_cases hm : g.bonds.card = 0
  · constructor
    · intro T
      simp only [kernel,hm,ite_true]; split <;> norm_num
    · simp [kernel,hm]
  have m : 0 < (g.bonds.card:ℝ) := by exact_mod_cast Nat.pos_of_ne_zero hm
  let w := fun a : Config g.bonds => boostedWeight x u a.val
  have hw (a) : 0 < w a := boostedWeightPositive hx hu _
  constructor
  · intro T; simp only [kernel,hm,ite_false]
    exact div_nonneg (Finset.sum_nonneg (fun e _ => (edgeProbability w hw e A).1 T)) m.le
  · simp only [kernel,hm,ite_false, ← Finset.sum_div]
    rw [Finset.sum_comm]
    change (∑ e : ↥g.bonds, ∑ T, edgeStep w e A T) / g.bonds.card = 1
    rw [Finset.sum_congr rfl (fun e _ => (edgeProbability w hw e A).2)]
    simp [hm]

theorem kernelLazy (g : Glass n) {x u : ℝ} (hx : 0 < x) (hu : 0 < u) (A : Config g.bonds) :
    1/2 ≤ kernel g x u A A := by
  by_cases zero : g.bonds.card=0
  · simp [kernel,zero]; norm_num
  let w := fun a : Config g.bonds => boostedWeight x u a.val
  have m : 0 < (g.bonds.card:ℝ) := by exact_mod_cast Nat.pos_of_ne_zero zero
  simp only [kernel,zero,ite_false]
  apply (le_div_iff₀ m).mpr
  calc 1/2*(g.bonds.card:ℝ) = ∑ _e : ↥g.bonds, (1/2:ℝ) := by simp [mul_comm]
       _ ≤ _ := Finset.sum_le_sum (fun e _ => by
         have h := (acceptanceBounds w (fun _ => boostedWeightPositive hx hu _) e A).2
         change 1/2 ≤ edgeStep w e A A
         simp only [edgeStep,ite_true,ite_eq_right (Ne.symm (flipDifferent e A)),add_zero]; linarith)

theorem detailedBalance (g : Glass n) {x u : ℝ} (hx : 0 < x) (hu : 0 < u) (A T : Config g.bonds) :
    boostedWeight x u A.val * kernel g x u A T = boostedWeight x u T.val * kernel g x u T A := by
  by_cases hm : g.bonds.card=0
  · by_cases h : T=A
    · subst T; rfl
    · simp [kernel,hm,h,Ne.symm h]
  simp only [kernel,hm,ite_false,← mul_div_assoc,Finset.mul_sum]
  congr 1
  exact Finset.sum_congr rfl fun e _ => edgeBalance _ (fun _ => boostedWeightPositive hx hu _) e A T

/-- Detailed balance and stochasticity give exact stationarity for the normalized
boosted distribution, with the empty-edge chain handled by its identity kernel. -/
theorem stationary (g : Glass n) {x u : ℝ} (hx : 0 < x) (hu : 0 < u) (T : Config g.bonds) :
    ∑ A : Config g.bonds, (boostedWeight x u A.val / boostedMass g.bonds x u)*kernel g x u A T =
      boostedWeight x u T.val / boostedMass g.bonds x u := by
  calc _ = (∑ A : Config g.bonds, boostedWeight x u A.val*kernel g x u A T)/boostedMass g.bonds x u := by
         rw [Finset.sum_div]; exact Finset.sum_congr rfl fun _ _ => by ring
       _ = (∑ A : Config g.bonds, boostedWeight x u T.val*kernel g x u T A)/boostedMass g.bonds x u := by
         congr 1; exact Finset.sum_congr rfl fun A _ => detailedBalance g hx hu A T
       _ = _ := by rw [← Finset.mul_sum,(kernelProbability g hx hu T).2,mul_one]

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
