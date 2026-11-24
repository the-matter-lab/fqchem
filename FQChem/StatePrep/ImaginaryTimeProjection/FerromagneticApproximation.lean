module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticMixing
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Tactic

/-! # An all-temperature polynomial subgraphs-world energy approximation

For target relative RMS precision 1/s, each independent chain runs for an explicit
polynomial burn-in from the empty graph. The final readout uses all sampled subgraphs.
The operation count here is in ideal single-edge Markov updates.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

def relaxationBudget (n m : ℕ) := 4*m^2*(m+1)*n^6
def inverseTolerance (m s : ℕ) := 36*(m+1)^2*s
def precisionBits (m s : ℕ) := (inverseTolerance m s).log2+1
def burnIn (n m s : ℕ) := relaxationBudget n m * (m+2*precisionBits m s)
def sampleCount (m s : ℕ) := 1296*(m+1)^4*s^2

private theorem halving (r : ℝ) (B : ℕ) (low : 0≤1-r) (enough : 1 ≤ (B:ℝ)*r) :
    (1-r)^B ≤ 1/2 := by
  calc (1-r)^B ≤ (Real.exp (-r))^B := pow_le_pow_left₀ low (Real.one_sub_le_exp_neg r) _
       _ = Real.exp (-(B*r)) := by rw [← Real.exp_nat_mul]; congr 1; ring
       _ ≤ Real.exp (-1) := Real.exp_le_exp.mpr (by linarith)
       _ ≤ 1/2 := by rw [Real.exp_neg,← one_div]; exact one_div_le_one_div_of_le (by norm_num) Real.exp_one_gt_two.le

theorem rateBudget {n m : ℕ} (hn : 0<n) (hm : 0<m) {x : ℝ} (hx : 0<x) (x₁ : x<1) :
    let r := rate m (proposal m x) (n:ℝ)⁻¹
    0≤1-r ∧ 1≤(relaxationBudget n m:ℝ)*r := by
  intro r
  have nr : (1:ℝ)≤n := by exact_mod_cast hn
  have mr : (1:ℝ)≤m := by exact_mod_cast hm
  have up : 0<(n:ℝ)⁻¹ := by positivity
  have u₁ : (n:ℝ)⁻¹≤1 := (inv_le_one₀ (by positivity)).mpr nr
  have yp : 0 < proposal m x := hx.trans_le (le_max_left ..)
  have y₁ : proposal m x ≤ 1 := max_le x₁.le ((inv_le_one₀ (by positivity)).mpr (by linarith))
  have prod := mul_le_mul y₁ (pow_le_one₀ up.le u₁ (n := 6)) (pow_nonneg up.le _) zero_le_one
  constructor
  · apply sub_nonneg.mpr; apply (div_le_one (by positivity : 0 < 4*(m:ℝ)^2)).mpr
    nlinarith [sq_nonneg ((m:ℝ)-1)]
  · have lower : ((m:ℝ)+1)⁻¹ ≤ proposal m x := le_max_right ..
    have mul := (inv_le_iff_one_le_mul₀ (by positivity : 0<(m:ℝ)+1)).mp lower
    dsimp [r,rate,relaxationBudget]
    push_cast
    field_simp
    nlinarith [mul]

theorem burnInAccuracy (g : Glass n) (hn : 0<n) (hm : 0<g.bonds.card) {β : ℝ} (hβ : 0<β)
    {s : ℕ} (hs : 0<s) :
    let m := g.bonds.card
    let y := proposal m (Real.tanh β)
    let u := (n:ℝ)⁻¹
    ∑ A, |fromEmpty g y u (burnIn n m s) A - law g y u A| ≤ (inverseTolerance m s:ℝ)⁻¹ := by
  intro m y u
  let b := precisionBits m s
  let B := relaxationBudget n m
  let r := rate m y u
  let q := inverseTolerance m s
  have mp : 1≤(m:ℝ) := by exact_mod_cast hm
  have nr : 1≤(n:ℝ) := by exact_mod_cast hn
  have up : 0<u := by dsimp [u]; positivity
  have u₁ : u≤1 := (inv_le_one₀ (by positivity)).mpr nr
  have yp : 0<y := (tanhPositive hβ).trans_le (le_max_left ..)
  have y₁ : y≤1 := max_le (Real.tanh_lt_one β).le ((inv_le_one₀ (by positivity)).mpr (by linarith))
  have qp : 0 < (q:ℝ) := by dsimp [q,inverseTolerance]; positivity
  have rb := rateBudget hn hm (tanhPositive hβ) (Real.tanh_lt_one β)
  have half : (1-r)^B ≤ 1/2 := halving _ _ rb.1 rb.2
  have cap : (q:ℝ) ≤ 2^b := by exact_mod_cast (Nat.lt_log2_self (n := q)).le
  have gmix := mixingDistance g hm yp y₁ up u₁ (burnIn n m s)
  let distance := ∑ A, |fromEmpty g y u (burnIn n m s) A - law g y u A|
  change distance^2 ≤ (1-r)^(B*(m+2*b))*(2:ℝ)^m at gmix
  apply (sq_le_sq₀ (Finset.sum_nonneg (fun _ _ => abs_nonneg _)) (inv_nonneg.mpr qp.le)).mp
  calc distance^2 ≤ _ := gmix
       _ ≤ (1/2:ℝ)^(m+2*b)*2^m := by
         rw [pow_mul]; exact mul_le_mul_of_nonneg_right (pow_le_pow_left₀ (pow_nonneg rb.1 B) half _) (by positivity)
       _ = (((2:ℝ)^b)⁻¹)^2 := by rw [one_div,inv_pow,pow_add,Nat.mul_comm 2 b,pow_mul]; field_simp
       _ ≤ _ := pow_le_pow_left₀ (by positivity) (inv_anti₀ qp cap) _

/-- An explicit Markov-chain approximation to the sign-free quantum thermal energy.
For each positive β and s≥1 the relative RMS error is at most 1/s. A graph with m
nonzero bonds and n sites uses k=1296(m+1)^4 s² independent chains, each running
4m²(m+1)n⁶ [m+2(1+⌊log₂(36(m+1)²s)⌋)] lazy edge proposals. -/
theorem allTemperatureEnergy (g : Glass n) (hn : 0<n) (hm : 0<g.bonds.card)
    {β : ℝ} (hβ : 0<β) {s : ℕ} (hs : 0<s) :
    let m := g.bonds.card
    let x := Real.tanh β
    let y := proposal m x
    let u := (n:ℝ)⁻¹
    let q := fromEmpty g y u (burnIn n m s)
    let E := g.ferro.quantumThermal β
    expected (batches q) (fun ω : Fin (sampleCount m s) → Config g.bonds =>
      (-(m*x)*ratioEstimate g x y ω-E)^2) ≤ (|E|/s)^2 := by
  intro m x y u q E
  have k : 0<sampleCount m s := by dsimp [sampleCount]; positivity
  have h := energySamplingRMS g hn hm hβ (burnIn n m s) (sampleCount m s) k
    (inverseTolerance m s:ℝ)⁻¹ (burnInAccuracy g hn hm hβ hs)
  apply h.trans
  change 648*(((m:ℝ)+1)^2)^2*(_+_)*E^2 ≤ (|E|/s)^2
  simp only [sampleCount,inverseTolerance,Nat.cast_mul,Nat.cast_add,Nat.cast_pow,Nat.cast_ofNat,Nat.cast_one,
    div_pow,sq_abs]
  have sp : 0<(s:ℝ) := by exact_mod_cast hs
  have a : (0:ℝ)<m+1 := by positivity
  field_simp
  ring_nf
  exact le_rfl

/-- An empty comparison graph has zero thermal energy at every temperature. -/
theorem emptyEnergy (g : Glass n) (he : g.bonds=∅) (β : ℝ) : g.ferro.quantumThermal β=0 := by
  have h := thermalBound g.ferro β
  rw [show g.ferro.bonds=∅ from he,Finset.card_empty,Nat.cast_zero] at h
  exact abs_nonpos_iff.mp h

/-- At β=0 all genuine two-site spin products average to zero, so the zero
estimator is exact, including on an empty box. -/
theorem infiniteTemperature (g : Glass n) : g.ferro.quantumThermal 0=0 := by
  have h := energySectors g 0
  rw [Real.tanh_zero] at h
  have none (e) (he : e∈g.bonds) : sector g.bonds 0 e=0 := by
    obtain ⟨a,b,_,rfl⟩ := g.twoSite e he
    apply Finset.sum_eq_zero
    intro A _
    by_cases z : A=∅
    · subst A
      have ne : aligned n ≠ pairMask a b := fun q => by simpa [aligned,pairMask] using congrFun q a
      simp [boundary_empty,ne]
    · have pos := Finset.card_ne_zero.mpr (Finset.nonempty_iff_ne_empty.mpr z)
      simp [zero_pow pos]
  simp [Finset.sum_eq_zero none] at h
  exact h

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
