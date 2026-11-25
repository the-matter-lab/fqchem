module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSamples
import Mathlib.Tactic

/-! # Mean-square accuracy of subgraphs-world energy estimates

Independent runs of the explicit edge-toggle kernel start at the empty subgraph.
The result separates their finite-time distance to stationarity from the sampling
error of the batch. Both influence the relative RMS guarantee.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

def law (g : Glass n) (y u : ℝ) (A : Config g.bonds) := boostedWeight y u A.val / boostedMass g.bonds y u

theorem lawMean (g : Glass n) (y u : ℝ) (F : Finset (Spin n) → ℝ) :
    expected (law g y u) (fun A => F A.val) = mean g.bonds y u F := by
  simp [expected,law,mean,Finset.sum_div,div_mul_eq_mul_div]
  exact Finset.sum_attach _ (fun A => boostedWeight y u A*F A/boostedMass g.bonds y u)

def fromEmpty (g : Glass n) (y u : ℝ) : ℕ → Config g.bonds → ℝ
  | 0,T => if T.val=∅ then 1 else 0
  | k+1,T => ∑ A, fromEmpty g y u k A * kernel g y u A T

theorem fromEmptyProbability (g : Glass n) {y u : ℝ} (hy : 0 < y) (hu : 0 < u) (t : ℕ) :
    (∀ A, 0 ≤ fromEmpty g y u t A) ∧ ∑ A, fromEmpty g y u t A = 1 := by
  induction t with
  | zero =>
    let empty : Config g.bonds := ⟨∅,Finset.empty_mem_powerset _⟩
    have eq (A : Config g.bonds) : A.val=∅ ↔ A=empty := ⟨fun h => Subtype.ext h,fun h => congrArg Subtype.val h⟩
    constructor
    · intro A; unfold fromEmpty; split <;> norm_num
    · simp only [fromEmpty,eq]; simp
  | succ t ih =>
    constructor
    · intro T
      exact Finset.sum_nonneg fun A _ => mul_nonneg (ih.1 A) ((kernelProbability g hy hu A).1 T)
    · simp only [fromEmpty]
      rw [Finset.sum_comm]
      calc _ = ∑ A, fromEmpty g y u t A := Finset.sum_congr rfl (fun A _ => by
               rw [← Finset.mul_sum,(kernelProbability g hy hu A).2,mul_one])
           _ = 1 := ih.2

def ratioEstimate {k : ℕ} (g : Glass n) (x y : ℝ) (ω : Fin k → Config g.bonds) :=
  empirical (fun A : Config g.bonds => numerator g.bonds.card x y A.val) ω /
    max (1/9) (empirical (fun A : Config g.bonds => denominator x y A.val) ω)

theorem ratioError {a b v d θ : ℝ} (hd : 1/9 ≤ d) (hθ : 1 ≤ θ) (hv : v = θ*d) :
    (a/max (1/9) b-θ)^2 ≤ 162*θ^2*((a-v)^2+(b-d)^2) := by
  let c := max (1/9:ℝ) b
  have low : (1/9:ℝ) ≤ c := le_max_left ..
  have cp : 0 < c := (by norm_num : (0 : ℝ) < 1/9).trans_le low
  have θnonneg : 0 ≤ θ := zero_le_one.trans hθ
  have changeD : |d-c| ≤ |b-d| := by
    by_cases h : 1/9 ≤ b
    · rw [show c=b from max_eq_right h,abs_sub_comm]
    · rw [show c=1/9 from max_eq_left (le_of_not_ge h),abs_of_nonneg (by linarith),
          abs_of_nonpos (by linarith)]
      linarith
  have split : |a-θ*c| ≤ |a-v| + θ*|b-d| := by
    calc |a-θ*c| = |(a-v)+θ*(d-c)| := by rw [hv]; congr 1; ring
         _ ≤ |a-v|+|θ*(d-c)| := abs_add_le ..
         _ ≤ _ := by rw [abs_mul,abs_of_nonneg θnonneg]; gcongr
  have eb : |a/c-θ| ≤ (9*θ)*(|a-v|+|b-d|) := by
    have frac : a/c-θ = (a-θ*c)/c := (eq_div_iff cp.ne').mpr (by field_simp)
    rw [frac,abs_div,abs_of_pos cp,div_le_iff₀ cp]
    have large : 1 ≤ 9*c := by linarith
    have p : 0 ≤ |a-v|+|b-d| := by positivity
    nlinarith only [split, mul_le_mul_of_nonneg_right large (mul_nonneg θnonneg p),
      mul_le_mul_of_nonneg_right hθ (abs_nonneg (a-v))]
  have sq := pow_le_pow_left₀ (abs_nonneg _) eb 2
  rw [sq_abs] at sq
  have cross : (|a-v|+|b-d|)^2 ≤ 2*((a-v)^2+(b-d)^2) := by
    nlinarith only [sq_abs (a-v), sq_abs (b-d), sq_nonneg (|a-v|-|b-d|)]
  rw [mul_pow] at sq
  nlinarith only [sq, mul_le_mul_of_nonneg_left cross (sq_nonneg (9*θ))]

/-- A uniform mean-square bound on bounded subgraph observables controls the
relative error of the clamped energy estimator for any sampling law. -/
theorem ratioEnergyMSE (g : Glass n) (hn : 0 < n) (hm : 0 < g.bonds.card) {β : ℝ} (hβ : 0 < β)
    {k : ℕ} (samples : (Fin k → Config g.bonds) → ℝ) (nonneg : ∀ ω, 0 ≤ samples ω) (B : ℝ) :
    let x := Real.tanh β
    let y := proposal g.bonds.card x
    let p := law g y (n : ℝ)⁻¹
    let E := g.ferro.quantumThermal β
    let L := ((g.bonds.card : ℝ) + 1)^2
    (∀ f : Config g.bonds → ℝ, (∀ A, 0 ≤ f A ∧ f A ≤ L) →
      expected samples (fun ω => (empirical f ω - expected p f)^2) ≤ B) →
      expected samples (fun ω => (-(g.bonds.card*x)*ratioEstimate g x y ω - E)^2) ≤
        324*B*E^2 := by
  intro x y p E L readout
  let u := (n : ℝ)⁻¹
  let v := fun A : Config g.bonds => numerator g.bonds.card x y A.val
  let d := fun A : Config g.bonds => denominator x y A.val
  let θ := expected p v / expected p d
  have hx : 0 < x := tanhPositive hβ
  have hy : 0 < y := hx.trans_le (le_max_left ..)
  have hu : 0 < u := inv_pos.mpr (by exact_mod_cast hn)
  have obs (A : Config g.bonds) := observationBounds g hm hx (Real.tanh_lt_one β) (Finset.mem_powerset.mp A.property)
  have means := proposalMeans g hn hm hβ
  change 1/9 ≤ mean g.bonds y u _ ∧ mean g.bonds y u _ / mean g.bonds y u _ = _ at means
  rw [← lawMean, ← lawMean] at means
  change 1/9 ≤ expected p d ∧ θ = -E / ((g.bonds.card:ℝ)*x) at means
  have dp : 0 < expected p d := (by norm_num : (0 : ℝ) < 1/9).trans_le means.1
  have pn (A : Config g.bonds) : 0 ≤ p A := by
    apply div_nonneg (boostedWeightPositive hy hu _).le
    exact Finset.sum_nonneg fun A _ => (boostedWeightPositive hy hu A).le
  have order : 1 ≤ θ := (one_le_div dp).mpr
    (Finset.sum_le_sum (fun A _ => mul_le_mul_of_nonneg_left (obs A).2.2.1 (pn A)))
  have value : expected p v = θ*expected p d := (div_mul_cancel₀ _ dp.ne').symm
  have LP : 1 ≤ L := one_le_pow₀ (le_add_of_nonneg_left (Nat.cast_nonneg _))
  have vb := readout v (fun A => ⟨(obs A).1.trans (obs A).2.2.1, (obs A).2.2.2⟩)
  have db := readout d (fun A => ⟨(obs A).1, (obs A).2.1.trans LP⟩)
  have normalized : expected samples (fun ω : Fin k → Config g.bonds => (ratioEstimate g x y ω-θ)^2) ≤
      324*θ^2*B := by
    calc _ ≤ expected samples (fun ω : Fin k → Config g.bonds =>
           (162*θ^2)*(empirical v ω-expected p v)^2+(162*θ^2)*(empirical d ω-expected p d)^2) := by
             apply Finset.sum_le_sum
             intro ω _
             apply mul_le_mul_of_nonneg_left _ (nonneg ω)
             dsimp only; rw [← mul_add]
             exact ratioError means.1 order value
         _ = (162*θ^2)*expected samples (fun ω : Fin k → Config g.bonds => (empirical v ω-expected p v)^2)+
             (162*θ^2)*expected samples (fun ω : Fin k → Config g.bonds => (empirical d ω-expected p d)^2) := expectationLinear ..
         _ ≤ (162*θ^2)*B + (162*θ^2)*B := by gcongr
         _ = _ := by ring
  let scale := (g.bonds.card:ℝ)*x
  have sp : 0 < scale := mul_pos (by exact_mod_cast hm) hx
  have eng : E = -scale*θ := by have := (eq_div_iff sp.ne').mp means.2; linarith
  calc _ = scale^2*expected samples (fun ω : Fin k → Config g.bonds => (ratioEstimate g x y ω-θ)^2) := by
         simp only [expected,Finset.mul_sum]
         apply Finset.sum_congr rfl
         intro ω _
         change _ * (-scale*_ - E)^2 = _
         rw [eng]; ring
       _ ≤ _ := by
         have bound := mul_le_mul_of_nonneg_left normalized (sq_nonneg scale)
         rw [eng]; nlinarith only [bound]

/-- Finite-chain energy readout with a polynomial number of independent draws.
The remaining input is the unhalved L¹ distance of t actual Metropolis steps
from stationarity. For L=(m+1)², k≥1296 L²/ε² and distance ≤ε/(36L)
give relative RMS error at most ε. -/
theorem energySamplingRMS (g : Glass n) (hn : 0<n) (hm : 0<g.bonds.card) {β : ℝ} (hβ : 0<β)
    (t k : ℕ) (hk : 0<k) (η : ℝ) :
    let x := Real.tanh β
    let y := proposal g.bonds.card x
    let u := (n:ℝ)⁻¹
    let q := fromEmpty g y u t
    let E := g.ferro.quantumThermal β
    let L := ((g.bonds.card:ℝ)+1)^2
    (∑ A, |q A-law g y u A|) ≤ η →
    expected (batches q) (fun ω : Fin k → Config g.bonds =>
      (-(g.bonds.card*x)*ratioEstimate g x y ω-E)^2) ≤
      648*L^2*((k:ℝ)⁻¹+η^2)*E^2 := by
  intro x y u q E L dist
  have hy : 0 < y := (tanhPositive hβ).trans_le (le_max_left ..)
  have hu : 0 < u := inv_pos.mpr (by exact_mod_cast hn)
  obtain ⟨qNonneg, qMass⟩ := fromEmptyProbability g hy hu t
  have bound := ratioEnergyMSE g hn hm hβ (batches q)
    (fun ω => Finset.prod_nonneg (fun i _ => qNonneg (ω i))) (2*L^2*((k:ℝ)⁻¹+η^2))
    (fun f bounds => batchError _ q f qNonneg qMass (sq_nonneg _) bounds dist hk)
  exact bound.trans_eq (by ring)

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
