module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticTrajectoryVariance
public import FQChem.StatePrep.ImaginaryTimeProjection.CubicSpinGlass
import Mathlib.Tactic

/-! # Single-chain Monte Carlo for the sign-free ferromagnetic comparison

An empty-start lazy subgraphs-world chain takes one burn-in, then records every
successive state. Its relative RMS error is ≤1/s in a number of ideal Markov
updates bounded by a temperature-independent polynomial in the graph size times s².
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

/-- Relative energy error of a ratio readout along one consecutive trajectory. -/
theorem trajectoryEnergyRMS (g : Glass n) (hn : 0<n) (hm : 0<g.bonds.card) {β : ℝ} (hβ : 0<β)
    (t k : ℕ) (hk : 0<k) (η : ℝ) :
    let x := Real.tanh β
    let y := proposal g.bonds.card x
    let u := (n:ℝ)⁻¹
    let q := fromEmpty g y u t
    let p := law g y u
    let K := kernel g y u
    let r := rate g.bonds.card y u
    let E := g.ferro.quantumThermal β
    let L := ((g.bonds.card:ℝ)+1)^2
    (∑ A, |q A-p A|) ≤ η →
    expected (trajectory K k q) (fun ω => (-(g.bonds.card*x)*ratioEstimate g x y ω-E)^2) ≤
      324*L^2*(6/(k*r)+η)*E^2 := by
  intro x y u q p K r E L dist
  have hx : 0 < x := tanhPositive hβ
  have hy : 0 < y := hx.trans_le (le_max_left ..)
  have nr : 0 < (n:ℝ) := by exact_mod_cast hn
  have hu : 0 < u := inv_pos.mpr nr
  have nr1 : (1:ℝ)≤n := by exact_mod_cast hn
  have u₁ : u≤1 := (inv_le_one₀ nr).mpr nr1
  have y₁ : y≤1 := max_le (Real.tanh_lt_one _).le ((inv_le_one₀ (by positivity)).mpr (by linarith [Nat.cast_nonneg (α := ℝ) g.bonds.card] : (1:ℝ)≤g.bonds.card+1))
  have r₁ : r≤1 := sub_nonneg.mp (rateBudget hn hm hx (Real.tanh_lt_one β)).1
  have qprob := fromEmptyProbability g hy hu t
  have prob := trajectoryProbability K (kernelProbability g hy hu) q qprob.1 qprob.2 k
  have bound := ratioEnergyMSE g hn hm hβ (trajectory K k q) prob.1 (L^2*(6/(k*r)+η))
    (fun f bounds => trajectoryError g hm hy y₁ hu u₁ q f bounds dist r₁ hk)
  exact bound.trans_eq (by ring)

def warmPrecision (m s : ℕ) := 18*(m+1)^2*s^2

def trajectoryLength (n m s : ℕ) := 3888*(m+1)^4*s^2*relaxationBudget n m

/-- For every positive temperature, the same explicit burn-in and length (which
depend only on graph size and precision) suffice. The squared error is averaged
over one physical edge-toggle trajectory started at the empty subgraph. -/
theorem singleChainEnergy (g : Glass n) (hn : 0<n) (hm : 0<g.bonds.card)
    {β : ℝ} (hβ : 0<β) {s : ℕ} (hs : 0<s) :
    let m := g.bonds.card
    let x := Real.tanh β
    let y := proposal m x
    let u := (n:ℝ)⁻¹
    let q := fromEmpty g y u (burnIn n m (warmPrecision m s))
    let E := g.ferro.quantumThermal β
    expected (trajectory (kernel g y u) (trajectoryLength n m s) q)
      (fun ω => (-(m*x)*ratioEstimate g x y ω-E)^2) ≤ (|E|/s)^2 := by
  intro m x y u q E
  let R := relaxationBudget n m
  let r := rate m y u
  let D := ((m:ℝ)+1)^4*(s:ℝ)^2
  have sp : (0:ℝ)<s := by exact_mod_cast hs
  have dn : 0<D := by dsimp [D]; positivity
  have hR : 0<R := by dsimp [R,relaxationBudget,m]; positivity
  have hk : 0<trajectoryLength n m s := by dsimp [trajectoryLength]; positivity
  have hW : 0<warmPrecision m s := by dsimp [warmPrecision]; positivity
  have h := trajectoryEnergyRMS g hn hm hβ (burnIn n m (warmPrecision m s)) (trajectoryLength n m s)
    hk _ (burnInAccuracy g hn hm hβ hW)
  apply h.trans
  have rb : 1≤(R:ℝ)*r := (rateBudget hn hm (tanhPositive hβ) (Real.tanh_lt_one β)).2
  have kb : 3888*D ≤ (trajectoryLength n m s:ℝ)*r := calc
    _ ≤ (3888*D)*((R:ℝ)*r) := le_mul_of_one_le_right (by positivity) rb
    _ = _ := by dsimp [D,trajectoryLength,R]; push_cast; ring
  have kk : 0 < (trajectoryLength n m s:ℝ)*r := lt_of_lt_of_le (by positivity) kb
  have a : 6/((trajectoryLength n m s:ℝ)*r) ≤ 1/(648*D) := by
    rw [div_le_div_iff₀ kk (by positivity)]; linarith
  have b : (inverseTolerance m (warmPrecision m s):ℝ)⁻¹ = 1/(648*D) := by
    dsimp [inverseTolerance,warmPrecision,D]; push_cast; rw [one_div]; congr 1; ring
  change 324*(((m:ℝ)+1)^2)^2*(6/((trajectoryLength n m s:ℝ)*r)+_)*E^2 ≤ (|E|/s)^2
  rw [b]
  calc _ ≤ 324*(((m:ℝ)+1)^2)^2*(1/(648*D)+1/(648*D))*E^2 := by gcongr
       _ = _ := by dsimp [D]; rw [div_pow,sq_abs]; field_simp; ring

/-- One burn-in followed by k consecutive observations costs at most this many
ideal edge proposals. In particular precision enters quadratically, with no extra
logarithmic factor. -/
theorem singleChainWork (n m s : ℕ) (hs : 0<s) :
    burnIn n m (warmPrecision m s)+trajectoryLength n m s ≤
      relaxationBudget n m*(m+2+5184*(m+1)^4)*s^2 := by
  have log := Nat.log2_le_self (inverseTolerance m (warmPrecision m s))
  have val : inverseTolerance m (warmPrecision m s)=648*(m+1)^4*s^2 := by
    unfold inverseTolerance warmPrecision; ring
  rw [val] at log
  have ss : 1≤s^2 := Nat.one_le_pow _ _ hs
  have small := Nat.mul_le_mul_left (m+2) ss
  unfold burnIn precisionBits trajectoryLength
  rw [val]
  calc _ = relaxationBudget n m *
             (m+2*(Nat.log2 (648*(m+1)^4*s^2)+1)+3888*(m+1)^4*s^2) := by ring
       _ ≤ relaxationBudget n m*((m+2+5184*(m+1)^4)*s^2) := by
         apply Nat.mul_le_mul_left; nlinarith
       _ = _ := by ring

/-- All-temperature sign-free comparison in the relative-error parameter ε of
Troyer–Wiese Eq. (9). Both the RMS accuracy and the quadratic update budget
refer to the same single-chain estimator and use only known input parameters. -/
theorem polynomialComparison (g : Glass n) (hn : 0<n) (hm : 0<g.bonds.card)
    {β ε : ℝ} (hβ : 0<β) (hε : 0<ε) (ε₁ : ε≤1) :
    let m := g.bonds.card
    let s := ⌈ε⁻¹⌉₊
    let x := Real.tanh β
    let y := proposal m x
    let u := (n:ℝ)⁻¹
    let t := burnIn n m (warmPrecision m s)
    let k := trajectoryLength n m s
    let E := g.ferro.quantumThermal β
    expected (trajectory (kernel g y u) k (fromEmpty g y u t))
      (fun ω => (-(m*x)*ratioEstimate g x y ω-E)^2) ≤ (ε*|E|)^2 ∧
    ((t+k:ℕ):ℝ) ≤ 4*(relaxationBudget n m:ℝ)*(m+2+5184*((m:ℝ)+1)^4)*ε⁻¹^2 := by
  intro m s x y u t k E
  have ip := inv_pos.mpr hε
  have hs : 0<s := Nat.one_le_ceil_iff.mpr ip
  have cmp : ε⁻¹≤(s:ℝ) := Nat.le_ceil _
  have large : 1≤ε⁻¹ := (one_le_inv₀ hε).mpr ε₁
  have su : (s:ℝ) ≤ 2*ε⁻¹ := by linarith [(Nat.ceil_lt_add_one ip.le).le]
  have sp : 0<(s:ℝ) := by exact_mod_cast hs
  constructor
  · apply (singleChainEnergy g hn hm hβ hs).trans
    apply pow_le_pow_left₀ (div_nonneg (abs_nonneg _) sp.le)
    rw [div_le_iff₀ sp]
    have es := (inv_le_iff_one_le_mul₀ hε).mp cmp
    nlinarith only [mul_le_mul_of_nonneg_right es (abs_nonneg E)]
  · have natBudget := singleChainWork n m s hs
    change t+k ≤ _ at natBudget
    have realBudget := (Nat.cast_le (α := ℝ)).mpr natBudget
    push_cast at realBudget ⊢
    apply realBudget.trans
    have ss := pow_le_pow_left₀ sp.le su 2
    calc _ ≤ (relaxationBudget n m:ℝ)*(m+2+5184*((m:ℝ)+1)^4)*(2*ε⁻¹)^2 := by gcongr
         _ = _ := by ring

private theorem latticeBudget {n m : ℕ} (hn : 0<n) (hm : m≤3*n) :
    4*relaxationBudget n m*(m+2+5184*(m+1)^4) ≤ 764414784*n^13 := by
  have m1 : m+1≤4*n := by omega
  have m2 : m+2≤5*n := by omega
  have n4 : n≤n^4 := by simpa using Nat.pow_le_pow_right hn (show 1≤4 by decide)
  have R : relaxationBudget n m ≤ 144*n^9 := calc
    _ ≤ 4*(3*n)^2*(4*n)*n^6 := by unfold relaxationBudget; gcongr
    _ = _ := by ring
  have rest : m+2+5184*(m+1)^4 ≤ 1327109*n^4 := calc
    _ ≤ 5*n^4+5184*(4*n)^4 :=
      Nat.add_le_add (m2.trans (Nat.mul_le_mul_left 5 n4)) (Nat.mul_le_mul_left _ (Nat.pow_le_pow_left m1 _))
    _ = _ := by ring
  calc _ ≤ 4*(144*n^9)*(1327109*n^4) := by gcongr
       _ = _ := by ring

/-- The sign-free partner of the actual open three-dimensional nearest-neighbour
±1/0 input has an all-temperature bound solely in site count and target precision.
On the nonempty-bond case the sampler below is the same one whose error is bounded.
Empty-bond instances have zero energy by `emptyEnergy`. -/
theorem cubicPolynomialComparison {a b c : ℕ} (on : Coord a b c → Fin 3 → Bool)
    (neg : Finset (Spin (a*(b*c)))) (hn : 0<a*(b*c)) (hm : 0<(cubicGlass on neg).bonds.card)
    {β ε : ℝ} (hβ : 0<β) (hε : 0<ε) (ε₁ : ε≤1) :
    let n := a*(b*c)
    let g := cubicGlass on neg
    let m := g.bonds.card
    let s := ⌈ε⁻¹⌉₊
    let x := Real.tanh β
    let y := proposal m x
    let u := (n:ℝ)⁻¹
    let t := burnIn n m (warmPrecision m s)
    let k := trajectoryLength n m s
    let E := g.ferro.quantumThermal β
    expected (trajectory (kernel g y u) k (fromEmpty g y u t))
      (fun ω => (-(m*x)*ratioEstimate g x y ω-E)^2) ≤ (ε*|E|)^2 ∧
    ((t+k:ℕ):ℝ) ≤ 764414784*(n:ℝ)^13*ε⁻¹^2 := by
  intro n g m s x y u t k E
  have ⟨err,cost⟩ := polynomialComparison g hn hm hβ hε ε₁
  refine ⟨err,cost.trans ?_⟩
  apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
  exact_mod_cast latticeBudget hn (cubicBondCount on neg)

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
