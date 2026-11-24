module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticCongestion
import Mathlib.Tactic

/-! # Telescoping along all subgraphs-world paths

Cauchy–Schwarz bounds one squared endpoint difference by its path length times
the sum of squared single-edge differences. Summing over source/target pairs and
applying the proved congestion estimate gives the comparison of quadratic forms.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
open scoped symmDiff
variable {n : ℕ}

def grad {B : Finset (Spin n)} (f : Config B → ℝ) (T : Config B) (e : ↥B) :=
  (f (flip e T)-f T)^2

theorem flipSet {B : Finset (Spin n)} (e : ↥B) (A : Config B) : (flip e A).val = A.val∆{e.val} := by
  ext d
  by_cases h : e.val∈A.val <;> simp [flip,h,Finset.mem_symmDiff] <;> grind

private theorem telescope (z : ℕ → ℝ) (k : ℕ) :
    (z k-z 0)^2 ≤ k * ∑ j : Fin k, (z (j.val+1)-z j.val)^2 := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq (Finset.range k) (fun _ => (1:ℝ)) (fun i => z (i+1)-z i)
  rw [Fin.sum_univ_eq_sum_range (fun j => (z (j+1)-z j)^2)]
  simp only [one_mul, one_pow, Finset.sum_const, Finset.card_range, nsmul_eq_mul,mul_one,Finset.sum_range_sub] at h
  exact h

private theorem endSet {α : Type*} [DecidableEq α] (A B : Finset α) : A∆(A∆B)=B := by
  ext e; simp only [Finset.mem_symmDiff]; tauto

private theorem pathBound (g : Glass n) (f : Config g.bonds → ℝ) (I F : Config g.bonds) :
    (f F-f I)^2 ≤ g.bonds.card * ∑ e : ↥g.bonds, if e.val∈I.val∆F.val then
      grad f (intermediate g I F e.val) e else 0 := by
  let D := I.val∆F.val
  have sub : D⊆g.bonds := differenceSubset I F
  let l := route g D
  have nd : l.Nodup := (routeSpec g D sub).1
  have cover : l.toFinset = D := (routeSpec g D sub).2.1
  have inside {e} (h : e∈l) : e∈D := cover ▸ List.mem_toFinset.mpr h
  let state (k : ℕ) : Config g.bonds :=
    ⟨I.val∆(l.take k).toFinset,Finset.mem_powerset.mpr (Finset.symmDiff_subset_union.trans
      (Finset.union_subset (Finset.mem_powerset.mp I.property) (fun _ h => sub
        (inside (List.mem_of_mem_take (List.mem_toFinset.mp h))))))⟩
  let edge (i : Fin l.length) : ↥g.bonds := ⟨l[i.val],sub (inside (List.getElem_mem i.isLt))⟩
  have atZero : state 0=I := Subtype.ext (by change I.val∆(l.take 0).toFinset=I.val; exact symmDiff_bot _)
  have atEnd : state l.length=F := by
    apply Subtype.ext
    change I.val∆(l.take l.length).toFinset=F.val
    rw [List.take_length,cover]; exact endSet ..
  have position (i : Fin l.length) : intermediate g I F (edge i).val = state i.val := by
    apply Subtype.ext
    change I.val∆(l.take (l.idxOf l[i.val])).toFinset = _
    rw [nd.idxOf_getElem]
  have move (i : Fin l.length) : state (i.val+1)=flip (edge i) (state i.val) := by
    apply Subtype.ext
    rw [flipSet]
    change I.val∆(l.take (i.val+1)).toFinset=(I.val∆(l.take i.val).toFinset)∆{l[i.val]}
    rw [List.take_succ_eq_append_getElem i.isLt, List.toFinset_append,symmDiff_assoc]
    congr 1
    have fresh : l[i.val] ∉ (l.take i.val).toFinset := by
      intro h
      obtain ⟨j,hj,eq⟩ := List.mem_take_iff_getElem.mp (List.mem_toFinset.mp h)
      have same := (nd.get_inj_iff (i := ⟨j,by omega⟩) (j := i)).mp eq
      have := congrArg Fin.val same
      dsimp at this; omega
    change (l.take i.val).toFinset ∪ {l[i.val]} = (l.take i.val).toFinset ∆ {l[i.val]}
    rw [toggleAbsent _ fresh, Finset.union_singleton]
  have size : l.length ≤ g.bonds.card := by rw [← List.toFinset_card_of_nodup nd,cover]; exact Finset.card_le_card sub
  have distinct : Function.Injective edge := by
    intro i j h; exact nd.get_inj_iff.mp (congrArg Subtype.val h)
  let total (e : ↥g.bonds) := if e.val∈D then grad f (intermediate g I F e.val) e else 0
  have nodes : (∑ i : Fin l.length, (f (state (i.val+1))-f (state i.val))^2) =
      ∑ e ∈ Finset.univ.image edge, total e := by
    rw [Finset.sum_image distinct.injOn]
    apply Finset.sum_congr rfl
    intro i _
    have yes : (edge i).val∈D := inside (List.getElem_mem i.isLt)
    simp [total,yes,grad,position,move]
  have totalBound : (∑ e ∈ Finset.univ.image edge, total e) ≤ ∑ e, total e :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun e _ _ => by unfold total grad; split <;> positivity)
  have p := telescope (fun k => f (state k)) l.length
  rw [atEnd,atZero,nodes] at p
  exact p.trans (mul_le_mul (by exact_mod_cast size) totalBound
    (Finset.sum_nonneg (fun e _ => by unfold total grad; split <;> positivity)) (by positivity))

/-- Summing the canonical paths yields the unnormalized Poincaré comparison against
the sum of all edge-toggle squared gradients at each current subgraph. -/
theorem pathComparison (g : Glass n) {x u : ℝ} (hx : 0<x) (hu : 0<u) (u1 : u≤1)
    (f : Config g.bonds → ℝ) :
    let w := fun a : Config g.bonds => boostedWeight x u a.val
    u^4 * (∑ a : Config g.bonds × Config g.bonds, (w a.1*w a.2)*(f a.2-f a.1)^2) ≤
      g.bonds.card * boostedMass g.bonds x u * ∑ T, w T * ∑ e : ↥g.bonds, grad f T e := by
  intro w
  let pair := fun a : Config g.bonds × Config g.bonds => w a.1*w a.2
  let routeCost := fun (a : Config g.bonds × Config g.bonds) (e : ↥g.bonds) =>
    if e.val∈(a.1.val∆a.2.val) then grad f (intermediate g a.1 a.2 e.val) e else 0
  let load := fun (e : ↥g.bonds) (T : Config g.bonds) => ∑ a ∈ through g T e.val, pair a
  have flow (e : ↥g.bonds) :
      ∑ a, pair a*routeCost a e = ∑ T, load e T*grad f T e := by
    dsimp only [load, through]
    simp only [Finset.sum_mul,Finset.sum_filter]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro a _
    by_cases h : e.val∈(a.1.val∆a.2.val) <;> simp [routeCost,h,eq_comm]
  have bound (e : ↥g.bonds) (T : Config g.bonds) :
      u^4*(load e T*grad f T e) ≤ boostedMass g.bonds x u * (w T*grad f T e) := by
    have h := mul_le_mul_of_nonneg_right (congestion g hx hu u1 T e.val) (sq_nonneg (f (flip e T)-f T))
    calc _ = (u^4*load e T)*grad f T e := by ring
         _ ≤ _ := h
         _ = _ := by dsimp [w,grad]; ring
  have start : (∑ a : Config g.bonds × Config g.bonds, pair a*(f a.2-f a.1)^2) ≤
      g.bonds.card*(∑ e : ↥g.bonds, ∑ a, pair a*routeCost a e) := by
    rw [Finset.sum_comm,Finset.mul_sum]
    apply Finset.sum_le_sum
    intro a _
    have h := mul_le_mul_of_nonneg_left (pathBound g f a.1 a.2) (mul_nonneg
      (boostedWeightPositive hx hu a.1.val).le (boostedWeightPositive hx hu a.2.val).le)
    change pair a*(f a.2-f a.1)^2 ≤ pair a*(g.bonds.card*∑ e, routeCost a e) at h
    rw [mul_left_comm,Finset.mul_sum (a := pair a)] at h
    exact h
  have s := mul_le_mul_of_nonneg_left start (pow_nonneg hu.le 4)
  simp_rw [flow] at s
  calc _ ≤ (g.bonds.card:ℝ)*(u^4*(∑ e : ↥g.bonds, ∑ T, load e T*grad f T e)) := by
         simpa only [mul_left_comm (u^4) (g.bonds.card:ℝ)] using s
       _ ≤ (g.bonds.card:ℝ)*(boostedMass g.bonds x u * ∑ e : ↥g.bonds, ∑ T, w T*grad f T e) := by
         apply mul_le_mul_of_nonneg_left _ (by positivity)
         simp only [Finset.mul_sum]
         exact Finset.sum_le_sum fun e _ => Finset.sum_le_sum fun T _ => bound e T
       _ = _ := by
         rw [mul_assoc,Finset.sum_comm]
         congr 2
         exact Finset.sum_congr rfl fun T _ => (Finset.mul_sum ..).symm

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
