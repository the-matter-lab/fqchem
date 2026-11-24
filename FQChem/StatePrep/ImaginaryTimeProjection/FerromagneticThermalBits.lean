module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticRandomBits
import Mathlib.Tactic

/-! # Rounding the thermal edge weight in a finite-bit Ising sampler

The proposal parameter can be irrational for a rational inverse temperature.
Rounding the scalar once perturbs every subsequent update. The bound below
compares the actual two-word sampler with the real-temperature chain, uniformly
over all path observables with a fixed range.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs.RandomBits
open IsingSign
variable {n m : ℕ}

private theorem weightRatio (B : Finset (Spin n)) (T : Config B) {x y u : ℝ}
    (hx : 0<x) (hxy : x≤y) (hu : 0<u) :
    let W := fun z => boostedWeight z u T.val
    W x ≤ W y ∧ W y ≤ (y/x)^B.card * W x := by
  let factor := oddFactor u (boundary T.val)
  have pos := boostedWeightPositive hx hu T.val
  have fp : 0 < factor := (pos_iff_pos_of_mul_pos pos).mp (pow_pos hx _)
  have one : 1 ≤ y/x := (one_le_div hx).mpr hxy
  have cnt := Finset.card_le_card (Finset.mem_powerset.mp T.property)
  constructor
  · exact mul_le_mul_of_nonneg_right (pow_le_pow_left₀ hx.le hxy _) fp.le
  · change y^T.val.card*factor ≤ (y/x)^B.card*(x^T.val.card*factor)
    calc _ = (y/x)^T.val.card*(x^T.val.card*factor) := by rw [div_pow]; field_simp
         _ ≤ _ := mul_le_mul_of_nonneg_right (pow_le_pow_right₀ one cnt) pos.le

private theorem boundedRatio {w v w' v' c : ℝ} (hw : 0<w) (hv : 0<v)
    (wlo : w≤w') (vlo : v≤v') (whi : w'≤c*w) (vhi : v'≤c*v) (hc : 1≤c) :
    |min w' v'/(2*w') - min w v/(2*w)| ≤ (c-1)/2 := by
  let p := min w v/(2*w)
  let q := min w' v'/(2*w')
  have wp := hw.trans_le wlo
  have cp : 0<c := by linarith
  have prob {a b : ℝ} (ha : 0<a) : min a b/(2*a) ≤ 1/2 :=
    (div_le_iff₀ (by positivity)).mpr (by linarith [min_le_left a b])
  have pmax : p ≤ 1/2 := prob hw
  have qmax : q ≤ 1/2 := prob wp
  have qle : q ≤ c*p := by
    calc q ≤ (c*min w v)/(2*w') := by
           rw [mul_min_of_nonneg _ _ cp.le]
           exact div_le_div_of_nonneg_right (min_le_min whi vhi) (by positivity)
         _ ≤ (c*min w v)/(2*w) := div_le_div_of_nonneg_left (by positivity) (by positivity) (by linarith)
         _ = _ := by dsimp [p]; ring
  have ple : p ≤ c*q := by
    apply (div_le_iff₀ (by positivity : 0<2*w)).mpr
    have numerator := min_le_min wlo vlo
    have ratio : q * (2*w') = min w' v' := div_mul_cancel₀ _ (by positivity)
    have qnn : 0 ≤ q := by dsimp [q]; exact div_nonneg (le_min wp.le (hv.trans_le vlo).le) (by positivity)
    nlinarith [mul_le_mul_of_nonneg_right whi qnn]
  change |q-p| ≤ _
  apply abs_le.mpr
  constructor <;> nlinarith [mul_nonneg (sub_nonneg.mpr hc) (sub_nonneg.mpr pmax),
    mul_nonneg (sub_nonneg.mpr hc) (sub_nonneg.mpr qmax)]

private theorem powerError {z r : ℝ} (hz : 1≤z) (h : z≤r) (k : ℕ) :
    z^k-1 ≤ (k:ℝ)*r^k*(z-1) := by
  have r₁ := hz.trans h
  induction k with
  | zero => simp
  | succ k ih =>
    have term := mul_le_mul_of_nonneg_right (pow_le_pow_left₀ (by linarith : 0≤z) h k) (sub_nonneg.mpr hz)
    have mono := pow_le_pow_right₀ r₁ (Nat.le_succ k)
    have factor := mul_nonneg (sub_nonneg.mpr hz) (Nat.cast_nonneg (α:=ℝ) k)
    have inc := mul_le_mul_of_nonneg_right mono factor
    have inc' := mul_le_mul_of_nonneg_right mono (sub_nonneg.mpr hz)
    simp only [Nat.cast_succ, pow_succ] at inc inc' ⊢
    nlinarith only [ih,term,inc,inc']

theorem proposalAcceptance (B : Finset (Spin n)) (T : Config B) (e : ↥B)
    {x y u : ℝ} (hx : ((B.card:ℝ)+1)⁻¹ ≤ x) (hxy : x≤y) (hy : y≤1) (hu : 0<u) :
    let p := fun z => acceptance (fun A : Config B => boostedWeight z u A.val) e T
    |p y-p x| ≤ ((B.card:ℝ)*(B.card+1)^B.card*(B.card+1))*(y-x)/2 := by
  let m := B.card
  have mp : 0 < (m:ℝ)+1 := by positivity
  have xp : 0<x := (inv_pos.mpr mp).trans_le hx
  have lower : 1≤y/x := (one_le_div xp).mpr hxy
  have xi : 1≤((m:ℝ)+1)*x := by simpa [mul_comm] using (inv_le_iff_one_le_mul₀ mp).mp hx
  have upper : y/x ≤ (m:ℝ)+1 := (div_le_iff₀ xp).mpr (hy.trans xi)
  have diff : y/x-1 ≤ ((m:ℝ)+1)*(y-x) := by
    rw [div_sub_one xp.ne']
    exact (div_le_iff₀ xp).mpr (by nlinarith [mul_le_mul_of_nonneg_right xi (sub_nonneg.mpr hxy)])
  have b := weightRatio B T xp hxy hu
  have c := weightRatio B (flip e T) xp hxy hu
  have h := boundedRatio (boostedWeightPositive xp hu _) (boostedWeightPositive xp hu _)
    b.1 c.1 b.2 c.2 (one_le_pow₀ lower)
  refine h.trans ?_
  apply div_le_div_of_nonneg_right _ (by norm_num)
  calc (y/x)^B.card-1 ≤ _ := powerError lower upper m
       _ ≤ (m:ℝ)*((m:ℝ)+1)^m*(((m:ℝ)+1)*(y-x)) :=
         mul_le_mul_of_nonneg_left diff (by positivity)
       _ = _ := by ring

private def scale (m : ℕ) := m*(m+1)^(m+1)

private theorem scaleSpec (m : ℕ) :
    (scale m : ℝ) = (m:ℝ)*(m+1)^m*(m+1) := by simp [scale,pow_succ,mul_assoc]

private theorem thermalRow (g : Glass n) (order : Fin m ≃ ↥g.bonds) (hm : 0<m)
    {x y u : ℝ} (hx : ((m:ℝ)+1)⁻¹ ≤ x) (hxy : x≤y) (hy : y≤1) (hu : 0<u)
    (A : Config g.bonds) (f : Config g.bonds → ℝ) (range : ∀ T, 0≤f T ∧ f T≤1) :
    |expected (kernel g y u A) f - expected (kernel g x u A) f| ≤ (scale m : ℝ)*(y-x)/2 := by
  let p := fun z i => acceptance (fun T : Config g.bonds => boostedWeight z u T.val) (order i) A
  have size : m = g.bonds.card := by simpa using Fintype.card_congr order
  have mp : 0 < (m:ℝ) := by exact_mod_cast hm
  rw [kernelReadout g order hm,kernelReadout g order hm,← sub_div,abs_div,abs_of_pos mp,div_le_iff₀ mp,
    ← Finset.sum_sub_distrib]
  calc _ ≤ _ := Finset.abs_sum_le_sum_abs _ _
       _ ≤ ∑ _i : Fin m, ((scale m : ℝ)*(y-x)/2) := by
          apply Finset.sum_le_sum
          intro i _
          have bounds := proposalAcceptance g.bonds A (order i) (size ▸ hx) hxy hy hu
          change |(1-p y i)*_+p y i*_ - ((1-p x i)*_+p x i*_)| ≤ _
          rw [show (1-p y i)*f A+p y i*f (flip (order i) A) - ((1-p x i)*f A+p x i*f (flip (order i) A)) =
              (p y i-p x i)*(f (flip (order i) A)-f A) by ring,abs_mul]
          have unit : |f (flip (order i) A)-f A| ≤ 1 := abs_le.mpr
            ⟨by linarith [(range A).2,(range (flip (order i) A)).1],by linarith [(range A).1,(range (flip (order i) A)).2]⟩
          refine (mul_le_mul_of_nonneg_left unit (abs_nonneg _)).trans ?_
          rw [mul_one,scaleSpec,size]; exact bounds
       _ = _ := by simp [mul_comm]

private theorem scaleBudget (m : ℕ) : 2*(m+1+scale m) ≤ 2^((m+2)^2+2) := by
  have a : m ≤ 2^m := m.lt_two_pow_self.le
  have b : m+1 ≤ 2^(m+1) := (m+1).lt_two_pow_self.le
  have c : scale m ≤ 2^((m+2)^2) := by
    calc scale m ≤ 2^m*(2^(m+1))^(m+1) := Nat.mul_le_mul a (Nat.pow_le_pow_left b _)
         _ = 2^(m+(m+1)*(m+1)) := by rw [← pow_mul,← pow_add]
         _ ≤ _ := Nat.pow_le_pow_right (by decide) (by nlinarith)
  have b' : m+1 ≤ 2^((m+2)^2) := b.trans (Nat.pow_le_pow_right (by decide) (by nlinarith))
  rw [pow_add]; omega

/-- Any rational enclosure of the physical proposal with one unit of
precision yields the same uniform trajectory guarantee. -/
theorem trajectoryWithProposal (g : Glass n) (order : Fin m ≃ ↥g.bonds) (hm : 0<m) (hn : 0<n)
    {β : ℝ} (hβ : 0<β) (r k a b : ℕ) (ap : 0<a) (bp : 0<b) (q : Config g.bonds → ℝ)
    (hq : (∀ A, 0≤q A) ∧ ∑ A,q A=1) (F : (Fin k → Config g.bonds) → ℝ)
    {L : ℝ} (hL : 0≤L) (range : ∀ ω, 0≤F ω ∧ F ω≤L) :
    let x := proposal m (Real.tanh β)
    let bits := (m+2)^2+2+r
    let y := (a:ℝ)/b
    x≤y → y≤1 → y-x≤1/2^bits →
    let J := fun A => pairLaw bits (graphUpdate g.bonds order a b n bits A)
    let K := kernel g x (n:ℝ)⁻¹
    |expected (trajectory J k q) F - expected (trajectory K k q) F| ≤ k*L/2^r := by
  intro x bits y xy ymax gap J K
  let D := (2:ℝ)^bits
  have dp : 0<D := by dsimp [D]; positivity
  have up : 0<(n:ℝ)⁻¹ := by positivity
  have lo : ((m:ℝ)+1)⁻¹ ≤ x := le_max_right ..
  have xp : 0<x := (tanhPositive hβ).trans_le (le_max_left ..)
  have count : 2*((m:ℝ)+1+(scale m:ℝ))/D ≤ 1/(2:ℝ)^r := by
    apply (div_le_div_iff₀ dp (by positivity)).mpr
    dsimp [D,bits]; rw [pow_add _ _ r,one_mul]
    exact mul_le_mul_of_nonneg_right (by exact_mod_cast scaleBudget m) (by positivity)
  have jprob (A : Config g.bonds) := pairProbability bits (graphUpdate g.bonds order a b n bits A)
  have kprob := kernelProbability g xp up
  have row (A : Config g.bonds) : ∑ T, |J A T-K A T| ≤ 1/(2:ℝ)^r := by
    refine (rowL1 _ _ (jprob A).2 (kprob A).2 (((m:ℝ)+1+(scale m:ℝ))/D) (fun f hf => ?_)).trans ?_
    · have finite := graphReadout g order hm ap bp hn bits A f hf
      have temp := thermalRow g order hm lo xy ymax up A f hf
      have err := (abs_sub_le (expected (J A) f) (expected (kernel g y (n:ℝ)⁻¹ A) f) (expected (K A) f)).trans
        (add_le_add finite temp)
      refine err.trans ?_
      have mult := mul_le_mul_of_nonneg_left gap (by positivity : 0≤(scale m:ℝ))
      change ((m:ℝ)+1)/D + (scale m:ℝ)*(y-x)/2 ≤ ((m:ℝ)+1+(scale m:ℝ))/D
      rw [add_div ((m:ℝ)+1) (scale m), div_eq_mul_one_div (scale m : ℝ) D]
      linarith [mul_nonneg (Nat.cast_nonneg (scale m)) (sub_nonneg.mpr xy)]
    · simpa only [mul_div_assoc] using count
  have err := trajectoryError K J kprob jprob (by positivity) hL row k q q hq hq F range
  simpa [div_eq_mul_inv,mul_assoc,mul_left_comm,mul_comm] using err

/-- Rounding a thermal proposal to a dyadic numerator needs at most
(m+2)²+2 precision bits in addition to the requested accuracy parameter r.
The finite chain tested here draws two b-bit words per update. -/
theorem thermalTrajectory (g : Glass n) (order : Fin m ≃ ↥g.bonds) (hm : 0<m) (hn : 0<n)
    {β : ℝ} (hβ : 0<β) (r k : ℕ) (q : Config g.bonds → ℝ)
    (hq : (∀ A, 0≤q A) ∧ ∑ A,q A=1) (F : (Fin k → Config g.bonds) → ℝ)
    {L : ℝ} (hL : 0≤L) (range : ∀ ω, 0≤F ω ∧ F ω≤L) :
    let x := proposal m (Real.tanh β)
    let bits := (m+2)^2+2+r
    let a := ⌈x*2^bits⌉₊
    let J := fun A => pairLaw bits (graphUpdate g.bonds order a (2^bits) n bits A)
    let K := kernel g x (n:ℝ)⁻¹
    |expected (trajectory J k q) F - expected (trajectory K k q) F| ≤ k*L/2^r := by
  intro x bits a J K
  let D := (2:ℝ)^bits
  let y := (a:ℝ)/D
  have dp : 0<D := by dsimp [D]; positivity
  have bpos : 0<2^bits := Nat.two_pow_pos _
  have xp : 0<x := (tanhPositive hβ).trans_le (le_max_left ..)
  have x₁ : x≤1 := max_le (Real.tanh_lt_one _).le ((inv_le_one₀ (by positivity)).mpr (by linarith [Nat.cast_nonneg (α:=ℝ) m]))
  have ap : 0<a := Nat.ceil_pos.mpr (mul_pos xp dp)
  have xy : x ≤ y := (le_div_iff₀ dp).mpr (Nat.le_ceil _)
  have ymax : y ≤ 1 := by
    apply (div_le_one dp).mpr
    have less : x*D ≤ ((2^bits : ℕ) : ℝ) := by simpa [D] using mul_le_mul_of_nonneg_right x₁ dp.le
    have round : a ≤ 2^bits := Nat.ceil_le.mpr less
    dsimp [D]; exact_mod_cast round
  have gap : y-x ≤ 1/D := by
    have low := (Nat.ceil_lt_add_one (mul_nonneg xp.le dp.le)).le
    rw [sub_le_iff_le_add]
    apply (div_le_iff₀ dp).mpr
    rw [add_mul,one_div_mul_cancel dp.ne']
    linarith
  have eq : ((2^bits : ℕ):ℝ)=D := by simp [D]
  apply trajectoryWithProposal g order hm hn hβ r k a (2^bits) ap bpos q hq F hL range
  · simpa only [eq] using xy
  · simpa only [eq] using ymax
  · simpa only [eq] using gap

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs.RandomBits
