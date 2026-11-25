module

public import FQChem.Unproven.AtomicEnergy
import Mathlib.Analysis.Calculus.BumpFunction.FiniteDimension
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.Measure.Haar.NormedSpace
import Mathlib.Tactic

/-! # Trial states for an isolated Coulomb atom

A smooth packet around distinct positions away from the nucleus can be
antisymmetrized without cancellation. Keeping its support away from all
collisions gives finite potential energy in every electron sector. Dilating the
one-electron trial proves strict binding to every positive nucleus in the
[atomic model discussed by Nam](https://arxiv.org/abs/2206.15393).
-/

@[expose] public section
noncomputable section

namespace FQChem.Properties.AtomicBinding

open FQChem.MolecularDFT FQChem.Unproven.AtomicEnergy MeasureTheory Filter
open scoped ContDiff Topology

private def regular {N : ℕ} (q : Configuration N) : Prop :=
  Function.Injective q ∧ ∀ i, q i ≠ 0

private theorem permutationPacket (N : ℕ) :
    ∃ (p : Configuration N) (w : Configuration N → ℝ),
      w p = 1 ∧ ContDiff ℝ ∞ w ∧ HasCompactSupport w ∧
      (∀ q, ¬ regular q → w =ᶠ[𝓝 q] 0) ∧
      ∀ q (i j : Fin N), i ≠ j → w (q ∘ Equiv.swap i j) = -w q := by
  classical
  let p : Configuration N := fun i => WithLp.toLp 2 (fun _ : Fin 3 => (i.val : ℝ) + 1)
  have inj : Function.Injective p := by
    intro i j h
    have eq := congrArg (fun r : Position => r (0 : Fin 3)) h
    change (i.val : ℝ) + 1 = j.val + 1 at eq
    exact Fin.ext (by exact_mod_cast (add_right_cancel eq))
  have nz (i : Fin N) : p i ≠ 0 := by
    intro h
    have eq := congrArg (fun r : Position => r (0 : Fin 3)) h
    change (i.val : ℝ) + 1 = 0 at eq
    linarith [Nat.cast_nonneg (α := ℝ) i.val]
  let U := {q : Configuration N | regular q ∧
    ∀ σ : Equiv.Perm (Fin N), σ ≠ 1 → q ≠ p ∘ σ}
  have near : U ∈ 𝓝 p := by
    have pairs : ∀ᶠ q : Configuration N in 𝓝 p, ∀ i j : Fin N, i ≠ j → q i ≠ q j := by
      apply eventually_all.mpr; intro i
      apply eventually_all.mpr; intro j
      by_cases h : i = j
      · simp [h]
      · have apart := ((continuous_apply (A := fun _ : Fin N => Position) i).sub
            (continuous_apply j)).continuousAt (x := p) |>.eventually_ne
            (sub_ne_zero.mpr (inj.ne h))
        filter_upwards [apart] with q hq using fun _ => sub_ne_zero.mp hq
    have off : ∀ᶠ q : Configuration N in 𝓝 p, ∀ i : Fin N, q i ≠ 0 :=
      eventually_all.mpr fun i => (continuous_apply i).continuousAt.eventually_ne (nz i)
    have orbit : ∀ᶠ q : Configuration N in 𝓝 p, ∀ σ : Equiv.Perm (Fin N), σ ≠ 1 → q ≠ p ∘ σ := by
      apply eventually_all.mpr; intro σ
      by_cases h : σ = 1
      · simp [h]
      · have distinct : p ≠ p ∘ σ := by
          intro eq
          exact h (Equiv.ext fun i => inj (congrFun eq i).symm)
        filter_upwards [continuousAt_id.eventually_ne distinct] with q hq using fun _ => hq
    filter_upwards [pairs, off, orbit] with q hq hzero ho
    exact ⟨⟨fun {i j} hij => by_contra fun neq => hq i j neq hij, hzero⟩, ho⟩
  obtain ⟨f, supp, comp, smooth, _, center⟩ :=
    exists_contDiff_tsupport_subset (n := ⊤) near
  let term (σ : Equiv.Perm (Fin N)) (q : Configuration N) : ℝ :=
    (Equiv.Perm.sign σ : ℤ) * f (q ∘ σ)
  let w (q : Configuration N) := ∑ σ, term σ q
  refine ⟨p, w, ?_, ?_, ?_, ?_, ?_⟩
  · unfold w
    rw [Finset.sum_eq_single (1 : Equiv.Perm (Fin N))]
    · simpa [term, Function.comp_def] using center
    · intro σ _ h
      have outside : p ∘ σ ∉ tsupport f := fun hx => (supp hx).2 σ h rfl
      simp [term, image_eq_zero_of_notMem_tsupport outside]
    · simp
  · apply ContDiff.sum; intro σ _
    exact contDiff_const.mul (smooth.comp (contDiff_pi.mpr fun i => contDiff_apply ℝ _ (σ i)))
  · have compactTerm (σ : Equiv.Perm (Fin N)) : HasCompactSupport (term σ) :=
      HasCompactSupport.mul_left (f := fun _ => ((Equiv.Perm.sign σ : ℤ) : ℝ))
        (comp.comp_homeomorph (Homeomorph.piCongrLeft (Y := fun _ => Position) σ).symm)
    simpa only [w, ← Finset.sum_apply] using HasCompactSupport.finset_sum
      (s := Finset.univ) (fun σ _ => compactTerm σ)
  · intro q bad
    have each (σ : Equiv.Perm (Fin N)) : ∀ᶠ r : Configuration N in 𝓝 q, f (r ∘ σ) = 0 := by
      have outside : q ∘ σ ∉ tsupport f := by
        intro here
        obtain ⟨one, two⟩ := (supp here).1
        exact bad ⟨fun {i j} h => by
          have eq : σ.symm i = σ.symm j := one (by simpa using h)
          simpa using congrArg σ eq, fun i => by simpa using two (σ.symm i)⟩
      exact (notMem_tsupport_iff_eventuallyEq.mp outside).comp_tendsto
        ((continuous_pi fun i => continuous_apply (σ i)).continuousAt)
    filter_upwards [eventually_all.mpr each] with r hr
    simp [w, term, hr]
  · intro q i j ne
    let τ := Equiv.swap i j
    have a (σ : Equiv.Perm (Fin N)) : term σ (q ∘ τ) = -term (τ * σ) q := by
      simp [term, τ, map_mul, Equiv.Perm.sign_swap ne, Function.comp_def, Equiv.Perm.mul_apply]
    change (∑ σ, term σ (q ∘ τ)) = -∑ σ, term σ q
    simp_rw [a, Finset.sum_neg_distrib]
    exact congrArg Neg.neg (Equiv.sum_comp (Equiv.mulLeft τ) (fun σ => term σ q))

private theorem integrableKinetic {N : ℕ} {ψ : Configuration N → ℂ}
    (smooth : ContDiff ℝ ∞ ψ) (comp : HasCompactSupport ψ) : Integrable (kinetic ψ) := by
  let component (i : Fin N) (a : Fin 3) (q : Configuration N) :=
    ‖fderiv ℝ ψ q (Pi.single i (EuclideanSpace.single a 1))‖ ^ 2
  have componentInt (i a) : Integrable (component i a) := by
    have c := (smooth.continuous_fderiv (by simp)).clm_apply
      (continuous_const (y := Pi.single i (EuclideanSpace.single a 1)))
    have cont : Continuous (component i a) := (continuous_pow 2).comp c.norm
    exact cont.integrable_of_hasCompactSupport
      ((comp.fderiv_apply (𝕜 := ℝ) (Pi.single i (EuclideanSpace.single a 1))).norm.comp_left (g := fun t : ℝ => t^2) (by simp))
  exact
    (integrable_finsetSum _ (fun i _ => integrable_finsetSum _ (fun a _ => componentInt i a))).div_const 2

private theorem finiteEnergy_of_regularSupport {N : ℕ} (Z : ℕ) {ψ : Configuration N → ℂ}
    (smooth : ContDiff ℝ ∞ ψ) (comp : HasCompactSupport ψ)
    (vanish : ∀ q, ¬ regular q → ψ =ᶠ[𝓝 q] 0) : Integrable (energyDensity Z ψ) := by
  apply (integrableKinetic smooth comp).add
  apply Continuous.integrable_of_hasCompactSupport
  · apply continuous_iff_continuousAt.mpr; intro q
    by_cases h : regular q
    · have rep : ContinuousAt (repulsion (N := N)) q := by
        apply tendsto_finsetSum; intro i _
        apply tendsto_finsetSum; intro j hj
        exact ((continuous_apply (A := fun _ : Fin N => Position) i).dist (continuous_apply j)).continuousAt.inv₀
          (dist_ne_zero.mpr (h.1.ne (Finset.mem_filter.mp hj).2.ne))
      have nuc : ContinuousAt (fun r : Configuration N => ∑ i, (Z : ℝ) / ‖r i‖) q := by
        apply tendsto_finsetSum; intro i _
        exact continuousAt_const.div (continuous_apply i).continuousAt.norm (norm_ne_zero_iff.mpr (h.2 i))
      exact (rep.sub nuc).mul (smooth.continuous.continuousAt.norm.pow 2)
    · apply (continuousAt_const (y := (0 : ℝ))).congr_of_eventuallyEq
      filter_upwards [vanish q h] with r hr
      simp [show ψ r = 0 from hr]
  · exact HasCompactSupport.mul_left (comp.norm.comp_left (g := fun t : ℝ => t^2) (by simp))

private theorem normalizedPacket {N : ℕ} (Z : ℕ) (p : Configuration N)
    (w : Configuration N → ℝ) (center : w p = 1) (smooth : ContDiff ℝ ∞ w)
    (comp : HasCompactSupport w) (vanish : ∀ q, ¬ regular q → w =ᶠ[𝓝 q] 0)
    (swap : ∀ q (i j : Fin N), i ≠ j → w (q ∘ Equiv.swap i j) = -w q) :
    ∃ u : TrialSpinor Z N, ∀ s q, u.wave s q =
      if s = 0 then ((w q / Real.sqrt (∫ r, w r ^ 2) : ℝ) : ℂ) else 0 := by
  classical
  let mass := ∫ q, w q ^ 2
  have massPos : 0 < mass :=
    (smooth.continuous.pow 2).integral_pos_of_hasCompactSupport_nonneg_ne_zero
      (comp.comp_left (g := fun t : ℝ => t^2) (by simp)) (fun q => sq_nonneg (w q))
      (x := p) (by simp [center])
  let ψ (q : Configuration N) : ℂ := ((w q / Real.sqrt mass : ℝ) : ℂ)
  have ψsmooth : ContDiff ℝ ∞ ψ :=
    Complex.ofRealCLM.contDiff.comp (smooth.div_const _)
  have ψcomp : HasCompactSupport ψ :=
    comp.comp_left (g := fun t : ℝ => ((t / Real.sqrt mass : ℝ) : ℂ)) (by simp)
  have ψvanish (q) (hq : ¬ regular q) : ψ =ᶠ[𝓝 q] 0 := by
    filter_upwards [vanish q hq] with r hr
    simp [ψ, show w r = 0 from hr]
  have ψmass : (∫ q, ‖ψ q‖ ^ 2) = 1 := by
    simp only [ψ, Complex.norm_real, Real.norm_eq_abs, sq_abs, div_pow,
      Real.sq_sqrt massPos.le, integral_div]
    exact div_self massPos.ne'
  refine ⟨{ wave := fun s => if s = 0 then ψ else 0
            smooth := fun s => ?_, compact_support := fun s => ?_,
            antisymmetric := ?_, normalized := ?_, finiteEnergy := fun s => ?_ }, ?_⟩
  · split
    · exact ψsmooth
    · exact contDiff_const
  · split
    · exact ψcomp
    · exact HasCompactSupport.zero
  · intro s q i j ne
    have spin : s ∘ Equiv.swap i j = 0 ↔ s = 0 := by
      constructor
      · intro eq; funext k
        simpa [Function.comp_def] using congrFun eq (Equiv.swap i j k)
      · rintro rfl; rfl
    simp only [spin]; split <;> simp [ψ, swap q i j ne, neg_div]
  · rw [Finset.sum_eq_single (0 : Spins N)]
    · simpa using ψmass
    · intro s _ h; simp [h]
    · simp
  · split
    · exact finiteEnergy_of_regularSupport Z ψsmooth ψcomp ψvanish
    · have zero : energyDensity Z (0 : Configuration N → ℂ) = 0 := by
        funext q; simp [energyDensity, kinetic]
      rw [zero]; exact integrable_zero _ _ _
  · intro s q; split <;> simp_all [ψ, mass]

/-- At every electron number a normalized smooth antisymmetric spinor has finite
Coulomb and kinetic energy. The construction uses just the all-spin-up component. -/
theorem trialSpinor_nonempty (Z N : ℕ) : Nonempty (TrialSpinor Z N) := by
  obtain ⟨p, w, center, smooth, comp, vanish, swap⟩ := permutationPacket N
  obtain ⟨u, _⟩ := normalizedPacket Z p w center smooth comp vanish swap
  exact ⟨u⟩

private theorem kinetic_dilate {N : ℕ} {φ : Configuration N → ℂ} (smooth : ContDiff ℝ ∞ φ)
    (a t : ℝ) (q : Configuration N) :
    kinetic (fun r => a • φ (t • r)) q = a^2 * t^2 * kinetic φ (t • q) := by
  have diff : DifferentiableAt ℝ (fun r : Configuration N => φ (t • r)) q :=
    (smooth.differentiable (by simp)).differentiableAt.comp q (by fun_prop)
  unfold kinetic
  rw [fderiv_fun_const_smul diff, fderiv_comp_smul]
  simp only [smul_apply, norm_smul, Real.norm_eq_abs, mul_pow, sq_abs,
    ← Finset.mul_sum]
  ring

/-- A positive nucleus strictly binds the first electron in the continuum trial-state model.
Spatial dilation makes the kinetic energy quadratic in the inverse length scale
and the Coulomb attraction linear. -/
theorem firstElectronBinds (Z : ℕ) (hZ : 0 < Z) : groundEnergy Z 1 < groundEnergy Z 0 := by
  classical
  obtain ⟨p, w, center, smooth, comp, vanish, _⟩ := permutationPacket 1
  let φ (q : Configuration 1) : ℂ := (w q : ℂ)
  have φsmooth : ContDiff ℝ ∞ φ := Complex.ofRealCLM.contDiff.comp smooth
  have φcomp : HasCompactSupport φ := comp.comp_left (g := ((↑) : ℝ → ℂ)) (by simp)
  let V (q : Configuration 1) := (Z : ℝ) / ‖q 0‖ * ‖φ q‖^2
  have Vcont : Continuous V := by
    apply continuous_iff_continuousAt.mpr; intro q
    by_cases h : regular q
    · have denominator : ContinuousAt (fun r : Configuration 1 => ‖r 0‖) q :=
        (continuous_apply (A := fun _ : Fin 1 => Position) 0).norm.continuousAt
      exact (continuousAt_const.div denominator (norm_ne_zero_iff.mpr (h.2 0))).mul
        (((continuous_pow 2).comp φsmooth.continuous.norm).continuousAt)
    · apply (continuousAt_const (y := (0 : ℝ))).congr_of_eventuallyEq
      filter_upwards [vanish q h] with r hr
      simp [V, φ, show w r = 0 from hr]
  have Vcomp : HasCompactSupport V :=
    HasCompactSupport.mul_left (φcomp.norm.comp_left (g := fun v : ℝ => v^2) (by simp))
  have pRegular : regular p := by
    by_contra h
    exact one_ne_zero (center.symm.trans (vanish p h).eq_of_nhds)
  have Vpos : 0 < ∫ r, V r :=
    Vcont.integral_pos_of_hasCompactSupport_nonneg_ne_zero Vcomp
      (fun q => mul_nonneg (div_nonneg (by positivity) (norm_nonneg _)) (sq_nonneg _))
      (x := p) (by simp [V, φ, center, hZ.ne', pRegular.2 0])
  let K := ∫ q, kinetic φ q
  let t := (∫ r, V r) / (|K| + 1)
  have tpos : 0 < t := div_pos Vpos (by positivity)
  have gain : t*K < ∫ r, V r := calc
    t*K < t*(|K|+1) := mul_lt_mul_of_pos_left (by linarith [le_abs_self K]) tpos
    _ = _ := div_mul_cancel₀ _ (by positivity)
  let w' (q : Configuration 1) := w (t • q)
  have wc : w' (t⁻¹ • p) = 1 := by simp [w', smul_smul, tpos.ne', center]
  have ws : ContDiff ℝ ∞ w' := smooth.comp (by fun_prop : ContDiff ℝ ∞ (fun q : Configuration 1 => t • q))
  have wk : HasCompactSupport w' := comp.comp_homeomorph (Homeomorph.smulOfNeZero t tpos.ne')
  have wv (q) (hq : ¬ regular q) : w' =ᶠ[𝓝 q] 0 := by
    have bad : ¬ regular (t • q) := by
      intro hr
      apply hq
      exact ⟨fun _ _ _ => Subsingleton.elim _ _, fun i he => hr.2 i (by simp [Pi.smul_apply, he])⟩
    exact (vanish _ bad).comp_tendsto ((by fun_prop : Continuous (fun r : Configuration 1 => t • r)).continuousAt)
  obtain ⟨u, wave⟩ := normalizedPacket Z _ w' wc ws wk wv
    (fun _ i j ne => (ne (Subsingleton.elim i j)).elim)
  let m := ∫ q, w' q ^ 2
  have massPos : 0 < m := (ws.continuous.pow 2).integral_pos_of_hasCompactSupport_nonneg_ne_zero
    (wk.comp_left (g := fun x : ℝ => x^2) (by simp)) (fun q => sq_nonneg (w' q))
    (x := t⁻¹ • p) (by simp [wc])
  let a := (Real.sqrt m)⁻¹
  have apos : 0 < a := inv_pos.mpr (Real.sqrt_pos.mpr massPos)
  have up : u.wave 0 = fun q => a • φ (t • q) := by
    funext q
    simp [wave, w', a, m, φ, Complex.real_smul, div_eq_inv_mul]
  have scale (q : Configuration 1) :
      energyDensity Z (u.wave 0) q =
        a^2 * (t^2 * kinetic φ (t • q) - t * V (t • q)) := by
    have lone : repulsion q = 0 := by
      apply Finset.sum_eq_zero; intro i _
      apply Finset.sum_eq_zero; intro j hj
      exact ((Finset.mem_filter.mp hj).2.ne (Subsingleton.elim i j)).elim
    have potential : t * V (t • q) = (Z : ℝ) / ‖q 0‖ * ‖φ (t • q)‖^2 := calc
      _ = (t*t⁻¹) * ((Z : ℝ) / ‖q 0‖ * ‖φ (t • q)‖^2) := by
        simp [V, Pi.smul_apply, norm_smul, abs_of_pos tpos, div_eq_mul_inv]
        ring
      _ = _ := by rw [mul_inv_cancel₀ tpos.ne', one_mul]
    rw [energyDensity, up, kinetic_dilate φsmooth, lone, potential]
    simp [abs_of_pos apos]
    ring
  have neg : (∫ q, energyDensity Z (u.wave 0) q) < 0 := by
    simp_rw [scale]
    rw [integral_const_mul, Measure.integral_comp_smul_of_nonneg (μ := volume)
      (fun r => t^2 * kinetic φ r - t * V r) t (hR := tpos.le),
      integral_sub ((integrableKinetic φsmooth φcomp).const_mul _)
        ((Vcont.integrable_of_hasCompactSupport Vcomp).const_mul _),
      integral_const_mul, integral_const_mul, smul_eq_mul]
    apply mul_neg_of_pos_of_neg (by positivity)
    apply mul_neg_of_pos_of_neg (by positivity)
    change t^2*K - t*(∫ r, V r) < 0
    nlinarith [mul_lt_mul_of_pos_left gain tpos]
  have rest (s : Spins 1) (h : s ≠ 0) : energyDensity Z (u.wave s) = 0 := by
    have zero : u.wave s = 0 := funext fun q => by simp [wave, h]
    funext q; simp [zero, energyDensity, kinetic]
  apply (iInf_le _ u).trans_lt
  rw [Finset.sum_eq_single (0 : Spins 1)]
  · exact EReal.coe_lt_coe_iff.mpr neg
  · intro s _ h; simp [rest s h]
  · simp

end FQChem.Properties.AtomicBinding
