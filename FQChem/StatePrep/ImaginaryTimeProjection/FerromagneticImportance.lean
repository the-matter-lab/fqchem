module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticMetropolis
import Mathlib.Analysis.SpecialFunctions.Artanh
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Tactic

/-! # Uniform-in-temperature importance weights for the homogeneous mean energy

At small x=tanh(β), boost x to y=max(x,1/(m+1)) as well as boosting the odd-vertex
factor. This adapts the change of weights in Jerrum–Sinclair Theorem 12 to the
uniform unit bonds of the sign-problem reduction. A nonempty even subgraph has
at least two edges; this removes the small-x singularity of the scaled readout.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

def proposal (m : ℕ) (x : ℝ) := max x ((m:ℝ)+1)⁻¹

def denominator (x y : ℝ) (A : Finset (Spin n)) :=
  if boundary A=aligned n then (x/y)^A.card else 0

def numerator (m : ℕ) (x y : ℝ) (A : Finset (Spin n)) :=
  denominator x y A * readout m x A / ((m:ℝ)*x)

def mean (B : Finset (Spin n)) (y u : ℝ) (F : Finset (Spin n) → ℝ) :=
  (∑ A ∈ B.powerset, boostedWeight y u A * F A) / boostedMass B y u

private theorem proposalRange {m : ℕ} (hm : 0 < m) {x : ℝ} (hx : 0 < x) (h₁ : x < 1) :
    0 < proposal m x ∧ proposal m x < 1 := by
  have mp : 0 < (m:ℝ) := by exact_mod_cast hm
  exact ⟨hx.trans_le (le_max_left ..),max_lt h₁ ((inv_lt_one₀ (by positivity)).mpr (by linarith))⟩

private theorem emptyLower (B : Finset (Spin n)) {x : ℝ} (hx : 0 ≤ x) : 1 ≤ mass B x := by
  change 1 ≤ ∑ A ∈ B.powerset, evenWeight x A
  have nn (A : Finset (Spin n)) : 0 ≤ evenWeight x A := by unfold evenWeight; split <;> positivity
  simpa [evenWeight,boundary_empty] using
    (Finset.single_le_sum (fun A (_ : A ∈ B.powerset) => nn A) (Finset.empty_mem_powerset B))

private theorem allSubsets (B : Finset (Spin n)) {y : ℝ} (hy : 0 ≤ y) : mass B y ≤ (1+y)^B.card := by
  calc mass B y ≤ ∑ A ∈ B.powerset, y^A.card := Finset.sum_le_sum (fun A _ => by
         change (if boundary A=aligned n then y^A.card else 0) ≤ _; split <;> first | exact le_rfl | positivity)
       _ = ∏ _ ∈ B, (1+y) := by rw [Finset.prod_one_add]; simp
       _ = _ := Finset.prod_const _

private theorem temperatureBoost (B : Finset (Spin n)) {x : ℝ} (hx : 0 ≤ x) :
    mass B (proposal B.card x) ≤ 3 * mass B x := by
  let m : ℝ := B.card
  have hm : 0 ≤ m := Nat.cast_nonneg _
  have one := emptyLower B hx
  by_cases h : (m+1)⁻¹ ≤ x
  · rw [proposal,max_eq_left h]; linarith
  · rw [proposal,max_eq_right (le_of_not_ge h)]
    let y := (m+1)⁻¹
    have yp : 0 ≤ y := by dsimp [y]; positivity
    have yr : y*(m+1) = 1 := inv_mul_cancel₀ (by linarith)
    calc mass B y ≤ (1+y)^B.card := allSubsets B yp
         _ ≤ (Real.exp y)^B.card := pow_le_pow_left₀ (by positivity) (by linarith [Real.add_one_le_exp y]) _
         _ ≤ Real.exp 1 := by
           rw [← Real.exp_nat_mul]
           exact Real.exp_le_exp.mpr (by change m*y ≤ 1; nlinarith)
         _ ≤ 3*mass B x := by linarith [Real.exp_one_lt_three]

private theorem boostCorrection {x y u : ℝ} (hy : y ≠ 0) (A : Finset (Spin n)) :
    boostedWeight y u A * denominator x y A = evenWeight x A := by
  by_cases h : boundary A=aligned n
  · simp [h, denominator,evenWeight,boostedWeight,oddFactor,aligned,div_pow]; field_simp
  · simp [h, denominator,evenWeight]

private theorem evenAtLeastTwo (g : Glass n) {A : Finset (Spin n)} (hA : A ⊆ g.bonds)
    (he : A.Nonempty) (hb : boundary A = aligned n) : 2 ≤ A.card := by
  by_contra! h
  have hcard : A.card=1 := by have := Finset.card_pos.mpr he; omega
  obtain ⟨e,rfl⟩ := Finset.card_eq_one.mp hcard
  have hem := hA (Finset.mem_singleton_self e)
  obtain ⟨a,b,_,rfl⟩ := g.twoSite e hem
  have test := congrFun hb a
  simp [boundary,aligned,pairMask] at test

/-- On every proposed subgraph the normalization readout is in [0,1]; the
dimensionless energy readout is between it and (m+1)^2 for all β>0. -/
theorem observationBounds (g : Glass n) (hm : 0 < g.bonds.card) {x : ℝ} (hx : 0 < x) (h₁ : x < 1)
    {A : Finset (Spin n)} (hA : A ⊆ g.bonds) :
    let m := g.bonds.card
    let y := proposal m x
    0 ≤ denominator x y A ∧ denominator x y A ≤ 1 ∧ denominator x y A ≤ numerator m x y A ∧
    numerator m x y A ≤ ((m:ℝ)+1)^2 := by
  intro m y
  have mp : 0 < (m:ℝ) := by exact_mod_cast hm
  have yp : 0 < y := (proposalRange hm hx h₁).1
  have r₀ : 0 ≤ x/y := (div_pos hx yp).le
  have r₁ : x/y ≤ 1 := (div_le_one yp).mpr (le_max_left ..)
  have den₀ : 0 ≤ denominator x y A := by unfold denominator; split <;> positivity
  have den₁ : denominator x y A ≤ 1 := by unfold denominator; split <;> first | exact pow_le_one₀ r₀ r₁ | norm_num
  have hmx : 0 < (m:ℝ)*x := mul_pos mp hx
  have ⟨lo,hi⟩ := readoutBounds hx h₁.le hA
  refine ⟨den₀,den₁,(le_div_iff₀ hmx).mpr (mul_le_mul_of_nonneg_left lo den₀),?_⟩
  by_cases hb : boundary A=aligned n
  · by_cases he : A.Nonempty
    · have count := evenAtLeastTwo g hA he hb
      have bound : denominator x y A ≤ (x/y)^2 := by
        simpa [denominator,hb] using pow_le_pow_of_le_one r₀ r₁ count
      have prop : 1 ≤ ((m:ℝ)+1)*y := by
        have h : ((m:ℝ)+1)⁻¹ ≤ y := le_max_right ..
        have t := mul_le_mul_of_nonneg_left h (by positivity : 0 ≤ (m:ℝ)+1)
        rwa [mul_inv_cancel₀ (by positivity)] at t
      calc numerator m x y A ≤ (x/y)^2*((m:ℝ)/x)/((m:ℝ)*x) := by
             exact div_le_div_of_nonneg_right (mul_le_mul bound hi (lo.trans' hmx.le) (sq_nonneg _)) hmx.le
           _ = (y⁻¹)^2 := by field_simp
           _ ≤ _ := by
             apply pow_le_pow_left₀ (by positivity)
             apply (inv_le_comm₀ yp (by positivity)).mpr
             exact le_max_right ..
    · have z : A = ∅ := Finset.not_nonempty_iff_eq_empty.mp he
      subst A
      simp [numerator,denominator,boundary_empty,readout,hmx.ne']
      rw [abs_of_pos (by positivity)]; linarith
  · simp [numerator,denominator,hb,sq_nonneg]

/-- Under the actual positive fugacity proposal, the mean denominator is at least
1/9 and the ratio of means equals the negative physical energy in units of m tanh β.
Both statements are uniform for every positive temperature and nonempty bond set. -/
theorem proposalMeans (g : Glass n) (hn : 0 < n) (hm : 0 < g.bonds.card) {β : ℝ} (hβ : 0 < β) :
    let x := Real.tanh β
    let y := proposal g.bonds.card x
    let u := (n:ℝ)⁻¹
    let D := mean g.bonds y u (denominator x y)
    let V := mean g.bonds y u (numerator g.bonds.card x y)
    1/9 ≤ D ∧ V/D = -g.ferro.quantumThermal β / (g.bonds.card*x) := by
  intro x y u D V
  have hx : 0 < x := tanhPositive hβ
  have ⟨hy,hy₁⟩ := proposalRange hm hx (Real.tanh_lt_one β)
  have nr : 0 < (n:ℝ) := by exact_mod_cast hn
  have hu : 0 < u := inv_pos.mpr nr
  have ax : Real.tanh (Real.artanh y) = y := Real.tanh_artanh ⟨by linarith,hy₁⟩
  have accept := evenAcceptance g hn (Real.artanh_pos ⟨hy,hy₁⟩)
  dsimp only at accept
  rw [ax] at accept
  have Zp : 0 < boostedMass g.bonds y u :=
    Finset.sum_pos (fun A _ => boostedWeightPositive hy hu A) ⟨∅, Finset.empty_mem_powerset _⟩
  have den : D = mass g.bonds x / boostedMass g.bonds y u := by
    apply congrArg (· / boostedMass g.bonds y u)
    exact Finset.sum_congr rfl fun A _ => boostCorrection hy.ne' A
  have dpos : 0 < mass g.bonds x := evenPositive g β
  have num : V = (∑ A ∈ g.bonds.powerset, evenWeight x A * readout g.bonds.card x A) /
      ((g.bonds.card:ℝ)*x) / boostedMass g.bonds y u := by
    apply congrArg (· / boostedMass g.bonds y u)
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro A _
    unfold numerator
    rw [← boostCorrection (u := u) hy.ne' A]
    ring
  rw [den,num,div_div_div_cancel_right₀ Zp.ne',thermalReadout g hβ]
  refine ⟨(le_div_iff₀ Zp).mpr ?_, by ring⟩
  have a := (le_div_iff₀ Zp).mp accept
  linarith [temperatureBoost g.bonds hx.le]

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
