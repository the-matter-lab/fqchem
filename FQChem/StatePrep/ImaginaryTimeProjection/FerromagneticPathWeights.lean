module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticTrails
public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticMetropolis
public import Mathlib.Data.Finset.SymmDiff
import Mathlib.Tactic

/-! # Weight comparison along Jerrum–Sinclair canonical paths

At a prefix P of the trail order for I△F, put T=I△P and U=F△P. Edge counts
are preserved in the pair. Outside two possible extra odd vertices, odd-vertex
factors are preserved or improved. This gives the factor u⁻⁴ used in the
congestion estimate.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
open scoped symmDiff
variable {n : ℕ}

theorem toggleAbsent {α : Type*} [DecidableEq α] (A : Finset α) {e : α} (he : e ∉ A) :
    A ∆ {e} = insert e A := by ext a; simp [Finset.mem_symmDiff]; grind

private theorem togglePresent {α : Type*} [DecidableEq α] (A : Finset α) {e : α} (he : e ∈ A) :
    A ∆ {e} = A.erase e := by ext a; simp [Finset.mem_symmDiff]; grind

private theorem boundaryToggle (A : Finset (Spin n)) (e : Spin n) :
    boundary (A ∆ {e}) = exchange e (boundary A) := by
  by_cases h : e∈A
  · rw [togglePresent _ h]
    have ins := boundary_insert (Finset.notMem_erase e A)
    rw [Finset.insert_erase h] at ins
    funext i
    have h := congrFun ins i
    simp only [exchange] at h ⊢
    rw [h]; simp
  · rw [toggleAbsent _ h,boundary_insert h]

theorem boundaryDifference (A B : Finset (Spin n)) :
    boundary (A ∆ B) = exchange (boundary A) (boundary B) := by
  induction B using Finset.induction_on with
  | empty => funext i; rw [show A ∆ (∅ : Finset (Spin n)) = A from symmDiff_bot _]; simp [boundary_empty,exchange,aligned]
  | @insert e B he ih =>
    rw [← toggleAbsent _ he, ← symmDiff_assoc,boundaryToggle,boundaryToggle,ih]
    funext i
    simp [exchange,Bool.xor_left_comm]

private theorem partitionCard {α : Type*} [Fintype α] [DecidableEq α] (I F P : Finset α)
    (hP : P⊆I∆F) : (I∆P).card+(F∆P).card=I.card+F.card := by
  have asSum (S : Finset α) : S.card = ∑ a, (if a∈S then 1 else 0 : ℕ) := by simp
  simp only [asSum,← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro a _
  have hp := fun (h : a∈P) => Finset.mem_symmDiff.mp (hP h)
  simp only [Finset.mem_symmDiff]
  split_ifs <;> grind

private def oddWeight (u : ℝ) (b : Bool) := if b then u else 1

private theorem siteFactor {u : ℝ} (hu : 0≤u) (u1 : u≤1) (a b p : Bool)
    (bad : Prop) [Decidable bad] (h : ¬bad → (a ^^ b)=false → p=false) :
    (if bad then u^2 else 1)*oddWeight u a*oddWeight u b ≤
    oddWeight u (a ^^ p) * oddWeight u (b ^^ p) := by
  by_cases s : bad <;> cases a <;> cases b <;> cases p <;>
    simp_all [oddWeight,abs_of_nonneg hu] <;> nlinarith [sq_nonneg u, mul_nonneg hu (sub_nonneg.mpr u1),
      mul_nonneg (sq_nonneg u) (sub_nonneg.mpr u1),mul_nonneg (sq_nonneg u) (sub_nonneg.mpr (pow_le_one₀ hu u1 (n := 2)))]

/-- For a partial trail ordering with at most two extra odd sites, the encoding
U=F△P and current state T=I△P satisfy u⁴ w(I)w(F) ≤ w(T)w(U). -/
theorem weightComparison {x u : ℝ} (hx : 0≤x) (hu : 0<u) (u1 : u≤1)
    (I F P : Finset (Spin n)) (sub : P⊆I∆F) (limits : twoDefects (I∆F) P) :
    u^4*boostedWeight x u I*boostedWeight x u F ≤ boostedWeight x u (I∆P)*boostedWeight x u (F∆P) := by
  obtain ⟨S,small,rules⟩ := limits
  let o := oddWeight u
  have localRule (i : Fin n) :
      (if i∈S then u^2 else 1)*o (boundary I i)*o (boundary F i) ≤
      o (boundary (I∆P) i)*o (boundary (F∆P) i) := by
    simp only [boundaryDifference,exchange]
    apply siteFactor hu.le u1
    intro h eq
    exact rules i h (by simpa only [boundaryDifference,exchange] using eq)
  have nn (d : Bool) : 0 ≤ o d := by cases d <;> simp [o,oddWeight,hu.le]
  have p := Finset.prod_le_prod₀ (s := Finset.univ) (fun i _ =>
    mul_nonneg (mul_nonneg (by split <;> positivity : 0 ≤ if i∈S then u^2 else 1) (nn _)) (nn _))
    (fun i _ => localRule i)
  simp only [Finset.prod_mul_distrib] at p
  have coeff : (∏ i : Fin n, if i∈S then u^2 else 1) = u^(2*S.card) := by
    rw [Finset.prod_ite, Finset.prod_const_one,mul_one,Finset.prod_const, ← pow_mul]
    simp
  rw [coeff] at p
  have coeff' := pow_le_pow_of_le_one hu.le u1 (show 2*S.card≤4 by omega)
  change u^(2*S.card)*oddFactor u (boundary I)*oddFactor u (boundary F) ≤
    oddFactor u (boundary (I∆P))*oddFactor u (boundary (F∆P)) at p
  have posit (d : Spin n) : 0≤oddFactor u d := Finset.prod_nonneg fun i _ => nn _
  have q : u^4*(oddFactor u (boundary I)*oddFactor u (boundary F)) ≤ _ := calc
    _ ≤ u^(2*S.card)*(oddFactor u (boundary I)*oddFactor u (boundary F)) :=
      mul_le_mul_of_nonneg_right coeff' (mul_nonneg (posit _) (posit _))
    _ ≤ _ := by simpa only [mul_assoc] using p
  calc u^4*boostedWeight x u I*boostedWeight x u F =
         x^(I.card+F.card)*(u^4*(oddFactor u (boundary I)*oddFactor u (boundary F))) := by
           simp [boostedWeight,pow_add]; ring
       _ ≤ x^(I.card+F.card)*(oddFactor u (boundary (I∆P))*oddFactor u (boundary (F∆P))) :=
           mul_le_mul_of_nonneg_left q (pow_nonneg hx _)
       _ = _ := by rw [← partitionCard I F P sub]; simp [boostedWeight,pow_add]; ring

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
