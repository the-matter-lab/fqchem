module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticThermalBits
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Tactic

/-! # Computing the thermal proposal from an encoded inverse temperature

For large positive β, the value 1 already approximates tanh β. Otherwise a
rational Taylor polynomial gives a certified upper enclosure. The number of
Taylor terms depends only on the requested bit precision, even for a large
binary input temperature.
-/

@[expose] public section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs.RandomBits

/-- Rational arithmetic for the upper endpoint of the thermal edge weight. -/
def thermalUpper (β : ℚ) (s : ℕ) : ℚ :=
  if (s+2 : ℚ) ≤ β then 1 else
    let N := 12*(s+2)
    let P := (∑ j ∈ Finset.range N, (2*β)^j / j.factorial) + 1/2^(s+2)
    (P-1)/(P+1)

private theorem tailBound (s : ℕ) (z : ℝ) (hz : 0≤z) (small : z≤2*(s+2)) :
    let N := 12*(s+2)
    let P := ∑ j ∈ Finset.range N, z^j / j.factorial
    P ≤ Real.exp z ∧ Real.exp z ≤ P + 1/2^(s+2) := by
  intro N P
  have np : 0<(N:ℝ) := by dsimp [N]; positivity
  have scale : 3*z/N ≤ 1/2 := (div_le_iff₀ np).mpr (by dsimp [N]; push_cast; linarith)
  have bound := Real.pow_div_factorial_le_exp (N:ℝ) np.le N
  have expBound : Real.exp N ≤ (3:ℝ)^N := by
    rw [← mul_one (N:ℝ),Real.exp_nat_mul]
    exact pow_le_pow_left₀ (Real.exp_pos 1).le Real.exp_one_lt_three.le _
  have term : z^N / N.factorial ≤ (1/2:ℝ)^N := by
    calc _ = (z/N)^N * ((N:ℝ)^N/N.factorial) := by rw [div_pow]; field_simp
         _ ≤ (z/N)^N * 3^N := mul_le_mul_of_nonneg_left (bound.trans expBound) (by positivity)
         _ = (3*z/N)^N := by rw [← mul_pow]; congr 1; ring
         _ ≤ _ := pow_le_pow_left₀ (by positivity) scale _
  have prelim : ‖(z:ℂ)‖/(N.succ:ℝ) ≤ 1/2 := by
    rw [Complex.norm_real,Real.norm_eq_abs,abs_of_nonneg hz]
    apply (div_le_iff₀ (by positivity)).mpr
    dsimp [N]; push_cast; linarith
  have remainder := Complex.exp_bound' prelim
  have norm_eq : ‖Complex.exp (z:ℂ) - ∑ j ∈ Finset.range N, (z:ℂ)^j / j.factorial‖ =
      |Real.exp z-P| := by
    rw [← Complex.ofReal_exp, show (∑ j ∈ Finset.range N, (z:ℂ)^j / j.factorial) = (P:ℂ) by
      dsimp only [P]; push_cast; rfl, ← Complex.ofReal_sub, Complex.norm_real, Real.norm_eq_abs]
  rw [norm_eq,Complex.norm_real,Real.norm_eq_abs,abs_of_nonneg hz] at remainder
  have decay := pow_le_pow_of_le_one (by norm_num : (0:ℝ)≤1/2) (by norm_num : (1/2:ℝ)≤1)
    (show s+3≤N by dsimp [N]; omega)
  have shrink : (1/2:ℝ)^(s+3)*2 = 1/2^(s+2) := by rw [pow_succ,one_div_pow]; ring
  exact ⟨Real.sum_le_exp_of_nonneg hz N,by linarith [(le_abs_self _).trans remainder,term,decay,shrink]⟩

private theorem tanhForm (z : ℝ) : Real.tanh z = (Real.exp (2*z)-1)/(Real.exp (2*z)+1) := by
  rw [Real.tanh_eq,Real.exp_neg,two_mul,Real.exp_add]
  field_simp [Real.exp_ne_zero]

/-- Certified one-sided approximation at every nonnegative rational inverse
temperature. The small-temperature branch uses exactly 12(s+2) Taylor terms. -/
theorem thermalUpperSpec (β : ℚ) (s : ℕ) (hβ : 0≤β) :
    Real.tanh β ≤ (thermalUpper β s : ℝ) ∧ (thermalUpper β s : ℝ) ≤ 1 ∧
    (thermalUpper β s : ℝ) - Real.tanh β ≤ 1/2^s := by
  have bp : 0≤(β:ℝ) := by exact_mod_cast hβ
  let E := Real.exp (2*(β:ℝ))
  have ep : 0<E := Real.exp_pos _
  rw [tanhForm]
  unfold thermalUpper
  split_ifs with big
  · have large : (s:ℝ)+2 ≤ β := by exact_mod_cast big
    have power : (2:ℝ)^(s+1) ≤ E := by
      calc _ ≤ (Real.exp 1)^(s+1) := pow_le_pow_left₀ (by norm_num) Real.exp_one_gt_two.le _
           _ = Real.exp ((s+1:ℕ)*1) := (Real.exp_nat_mul _ _).symm
           _ ≤ _ := Real.exp_le_exp.mpr (by push_cast; linarith)
    simp only [Rat.cast_one]
    change (E-1)/(E+1) ≤ 1 ∧ (1:ℝ) ≤ 1 ∧ 1-(E-1)/(E+1) ≤ 1/2^s
    refine ⟨(div_le_one (by positivity)).mpr (by linarith),le_rfl,?_⟩
    rw [one_sub_div (by positivity : E+1≠0)]
    apply (div_le_div_iff₀ (by positivity) (by positivity)).mpr
    rw [pow_succ] at power
    linarith
  · let N := 12*(s+2)
    let V := ∑ j ∈ Finset.range N, (2*(β:ℝ))^j / j.factorial
    let δ := 1/(2:ℝ)^(s+2)
    let U := V+δ
    have small : (β:ℝ)<(s:ℝ)+2 := by exact_mod_cast (lt_of_not_ge big)
    have pair := tailBound s (2*β) (by positivity) (by linarith)
    change V≤E ∧ E≤U at pair
    have up : 0<U := ep.trans_le pair.2
    have delta : U-E≤δ := by dsimp [U]; linarith [pair.1]
    push_cast
    change (E-1)/(E+1) ≤ (U-1)/(U+1) ∧ (U-1)/(U+1) ≤ 1 ∧
      (U-1)/(U+1)-(E-1)/(E+1) ≤ 1/2^s
    refine ⟨(div_le_div_iff₀ (by positivity) (by positivity)).mpr (by nlinarith [pair.2]),
      (div_le_one (by positivity)).mpr (by linarith),?_⟩
    have eq : (U-1)/(U+1)-(E-1)/(E+1) = 2*(U-E)/((U+1)*(E+1)) := by
      field_simp; ring
    rw [eq]
    have smallδ : 2*δ ≤ 1/(2:ℝ)^s := by dsimp [δ]; rw [pow_add]; field_simp; norm_num
    refine (div_le_self (by linarith [pair.2]) (by nlinarith [mul_pos up ep])).trans ?_
    linarith

/-- Compute the floored proposal used by the all-temperature chain from
a rational inverse temperature. -/
def rationalProposal (m : ℕ) (β : ℚ) (bits : ℕ) : ℚ :=
  max (thermalUpper β bits) ((m:ℚ)+1)⁻¹

/-- The finite-random-bit trajectory can be generated from the rational
temperature itself, with an explicit error for every bounded path observable. -/
theorem computedThermalTrajectory {m n : ℕ} (g : IsingSign.Glass n)
    (order : Fin m ≃ ↥g.bonds) (hm : 0<m) (hn : 0<n) {β : ℚ} (hβ : 0<β)
    (r k : ℕ) (q : Config g.bonds → ℝ) (hq : (∀ A, 0≤q A) ∧ ∑ A, q A=1)
    (F : (Fin k → Config g.bonds) → ℝ) {L : ℝ} (hL : 0≤L) (range : ∀ ω, 0≤F ω ∧ F ω≤L) :
    let bits := (m+2)^2+2+r
    let y := rationalProposal m β bits
    let J := fun A => pairLaw bits (graphUpdate g.bonds order y.num.natAbs y.den n bits A)
    let K := kernel g (proposal m (Real.tanh β)) (n:ℝ)⁻¹
    |expected (trajectory J k q) F - expected (trajectory K k q) F| ≤ k*L/2^r := by
  intro bits y J K
  have positive : 0<y := (inv_pos.mpr (by positivity : 0<(m:ℚ)+1)).trans_le (le_max_right ..)
  have num := Rat.num_pos.mpr positive
  have ap : 0<y.num.natAbs := Int.natAbs_pos.mpr num.ne'
  have eq : (y.num.natAbs:ℝ)/y.den = (y:ℝ) := by
    rw [Rat.cast_def]
    congr 1
    exact (Int.cast_natCast y.num.natAbs).symm.trans (congrArg (fun v : ℤ => (v:ℝ)) (Int.natAbs_of_nonneg num.le))
  have upper := thermalUpperSpec β bits hβ.le
  have yr : (y:ℝ) = max (thermalUpper β bits : ℝ) ((m:ℝ)+1)⁻¹ := by
    dsimp [y,rationalProposal]; push_cast; rfl
  apply trajectoryWithProposal g order hm hn (by exact_mod_cast hβ : (0:ℝ)<β) r k
    y.num.natAbs y.den ap y.den_pos q hq F hL range
  · rw [eq,yr]; exact max_le_max_right _ upper.1
  · rw [eq,yr]; exact max_le upper.2.1 ((inv_le_one₀ (by positivity)).mpr (by linarith [Nat.cast_nonneg (α:=ℝ) m]))
  · rw [eq,yr]
    change max _ _ - max _ _ ≤ _
    apply sub_le_iff_le_add.mpr
    apply max_le
    · linarith [upper.2.2,le_max_left (Real.tanh β) ((m:ℝ)+1)⁻¹]
    · linarith [le_max_right (Real.tanh β) ((m:ℝ)+1)⁻¹,show 0≤1/(2:ℝ)^bits by positivity]

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs.RandomBits
