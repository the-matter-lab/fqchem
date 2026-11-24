module

public import Mathlib.Analysis.InnerProductSpace.PiL2
public import Mathlib.Analysis.InnerProductSpace.Projection.Reflection
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.InverseDeriv
public import Mathlib.Geometry.Euclidean.Angle.Unoriented.TriangleInequality
public import FQChem.StatePrep.CircuitPreparation.AmplitudeAmplification

/-! # Sharp optimality of single-item quantum search

The hidden label indexes the summands of a Hilbert direct sum. Comparing an
algorithm with its run on the identity oracle bounds the change in angle per
query, including when the workspace contains ancillas. Reflecting about the
final readout subspaces expresses average Born success as another angle.
See [Zalka (1999), Sections 2–3 and Appendix](https://doi.org/10.1103/PhysRevA.60.2746).
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.SearchOptimality

open InnerProductGeometry
open scoped BigOperators

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
variable {N : ℕ} [NeZero N]

/-- The subspaces for queries (or for reporting a label) obey the Born mass
bound. The inequality allows an idle query sector or an inconclusive outcome. -/
structure Labels (N : ℕ) (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℂ E] where
  space : Fin N → Submodule ℂ E
  [projectable : ∀ i, (space i).HasOrthogonalProjection]
  mass_le (v : E) : ∑ i, ‖(space i).starProjection v‖ ^ 2 ≤ ‖v‖ ^ 2

attribute [instance] Labels.projectable

/-- The phase flip acts as minus one on the queried label and one on its orthogonal complement. -/
def phase (q : Labels N E) (i : Fin N) : E ≃ₗᵢ[ℂ] E :=
  (q.space i).reflection.trans (LinearIsometryEquiv.neg ℂ)

/-- Equal-prior success for a marked-label-dependent family of final states. -/
def averageSuccess (m : Labels N E) (v : Fin N → E) : ℝ :=
  (∑ i, ‖(m.space i).starProjection (v i)‖ ^ 2) / N

private abbrev bundle (v : Fin N → E) : PiLp 2 (fun _ : Fin N => E) := WithLp.toLp 2 v
local instance : InnerProductSpace ℝ E := InnerProductSpace.complexToReal

private def familyAngle (v w : Fin N → E) : ℝ := angle (bundle v) (bundle w)

omit [NeZero N] in
private theorem angle_formula {v w : Fin N → E} (hv : ∀ i, ‖v i‖ = 1)
    (hw : ∀ i, ‖w i‖ = 1) :
    familyAngle v w = Real.arccos ((∑ i, (inner ℂ (v i) (w i)).re) / N) := by
  have norm_family (x : Fin N → E) (h : ∀ i, ‖x i‖ = 1) :
      ‖bundle x‖ = Real.sqrt N := by
    rw [PiLp.norm_eq_of_L2]
    simp [h]
  rw [familyAngle, angle, norm_family _ hv, norm_family _ hw,
    Real.mul_self_sqrt (Nat.cast_nonneg N)]
  change Real.arccos ((inner ℂ (bundle v) (bundle w)).re / N) = _
  simp [PiLp.inner_apply, Complex.re_sum]

omit [NeZero N] in
private theorem angle_map {v w : Fin N → E} (hv : ∀ i, ‖v i‖ = 1)
    (hw : ∀ i, ‖w i‖ = 1) (u : Fin N → E ≃ₗᵢ[ℂ] E) :
    familyAngle (fun i => u i (v i)) (fun i => u i (w i)) = familyAngle v w := by
  rw [angle_formula (fun i => by simp [hv]) (fun i => by simp [hw]), angle_formula hv hw]
  simp

private theorem success_mem {m : Labels N E} {v : Fin N → E} (hv : ∀ i, ‖v i‖ = 1) :
    averageSuccess m v ∈ Set.Icc 0 1 := by
  refine ⟨by unfold averageSuccess; positivity, ?_⟩
  apply (div_le_iff₀ (by exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne N) : (0:ℝ) < N)).mpr
  calc ∑ i, ‖(m.space i).starProjection (v i)‖ ^ 2 ≤ ∑ _ : Fin N, (1 : ℝ) ^ 2 := by
         apply Finset.sum_le_sum; intro i _
         exact pow_le_pow_left₀ (norm_nonneg _) ((m.space i).norm_starProjection_apply_le _ |>.trans (hv i).le) _
       _ = 1 * N := by simp

private theorem reflection_angle (m : Labels N E) {v : Fin N → E} (hv : ∀ i, ‖v i‖ = 1) :
    familyAngle (fun i => phase m i (v i)) v =
      2 * Real.arcsin (Real.sqrt (averageSuccess m v)) := by
  have hi (i : Fin N) : (inner ℂ (phase m i (v i)) (v i)).re =
      1 - 2 * ‖(m.space i).starProjection (v i)‖ ^ 2 := by
    change (inner ℂ (-((m.space i).reflection (v i))) (v i)).re = _
    rw [Submodule.reflection_apply, two_smul, inner_neg_left, inner_sub_left, inner_add_left]
    have hp := (m.space i).re_inner_starProjection_eq_normSq (v i)
    change (inner ℂ ((m.space i).starProjection (v i)) (v i)).re =
      ‖(m.space i).starProjection (v i)‖ ^ 2 at hp
    simp [inner_self_eq_norm_sq_to_K, hv, hp]
    ring
  have hm := success_mem (m := m) hv
  have hs : Real.sqrt (averageSuccess m v) ≤ 1 := (Real.sqrt_le_one).mpr hm.2
  have hsine := Real.sin_arcsin (by linarith [Real.sqrt_nonneg (averageSuccess m v)]) hs
  have hcos : Real.cos (2 * Real.arcsin (Real.sqrt (averageSuccess m v))) = 1 - 2 * averageSuccess m v := by
    rw [Real.cos_two_mul]
    nlinarith [Real.sin_sq_add_cos_sq (Real.arcsin (Real.sqrt (averageSuccess m v))),
      Real.sq_sqrt hm.1, congrArg (· ^ 2) hsine]
  rw [angle_formula (fun i => by simp [hv]) hv]
  simp_rw [hi]
  rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]
  rw [show ((N:ℝ) - 2 * ∑ i, ‖(m.space i).starProjection (v i)‖ ^ 2) / N =
      1 - 2 * averageSuccess m v by
        unfold averageSuccess; field_simp [Nat.cast_ne_zero.mpr (NeZero.ne N)], ← hcos, Real.arccos_cos]
  · exact mul_nonneg (by norm_num) (Real.arcsin_nonneg.mpr (Real.sqrt_nonneg _))
  · linarith [Real.arcsin_le_pi_div_two (Real.sqrt (averageSuccess m v))]

private theorem reference_angle (m : Labels N E) {x : E} (hx : ‖x‖ = 1) :
    familyAngle (fun i => phase m i x) (fun _ => x) ≤ 2 * Real.arcsin (1 / Real.sqrt N) := by
  rw [reflection_angle m (fun _ => hx)]
  apply mul_le_mul_of_nonneg_left _ (by norm_num)
  apply Real.arcsin_le_arcsin
  rw [← Real.sqrt_one, ← Real.sqrt_div (by norm_num : (0:ℝ) ≤ 1)]
  apply Real.sqrt_le_sqrt
  exact div_le_div_of_nonneg_right (by simpa [hx] using m.mass_le x) (Nat.cast_nonneg N)

/-- A unitary algorithm in the phase-query model. The initial state can include
ancillas. Each entry in the gate list acts after one call and is independent of
the hidden label. A final basis change can be absorbed into the readout. -/
def run (q : Labels N E) (x : E) (i : Fin N) (gates : List (E ≃ₗᵢ[ℂ] E)) : E :=
  gates.foldl (fun v u => u (phase q i v)) x

omit [NeZero N] in
private theorem run_norm (q : Labels N E) (x : E) (i : Fin N) (g : List (E ≃ₗᵢ[ℂ] E)) :
    ‖run q x i g‖ = ‖x‖ := by
  induction g using List.reverseRecOn with
  | nil => rfl
  | append_singleton g u ih => simpa [run, List.foldl_append] using ih

/-- All query algorithms obey the success-angle bound, even after the first Grover peak. -/
theorem query_angle_bound (q m : Labels N E) {x : E} (hx : ‖x‖ = 1)
    (g : List (E ≃ₗᵢ[ℂ] E)) :
    Real.arcsin (Real.sqrt (averageSuccess m (fun i => run q x i g))) ≤
      (2 * g.length + 1) * Real.arcsin (1 / Real.sqrt N) := by
  let θ := Real.arcsin (1 / Real.sqrt N)
  have hybrid : ∃ y : E, ‖y‖ = 1 ∧ familyAngle (fun i => run q x i g) (fun _ => y) ≤
      2 * g.length * θ := by
    induction g using List.reverseRecOn with
    | nil =>
      refine ⟨x, hx, ?_⟩
      have ne : bundle (fun _ : Fin N => x) ≠ 0 := by
        intro h
        have h0 := congrArg (fun v : PiLp 2 (fun _ : Fin N => E) => v (0 : Fin N)) h
        change x = 0 at h0
        simp [h0] at hx
      simp [run, familyAngle, angle_self ne]
    | append_singleton g u ih =>
      obtain ⟨y, hy, prev⟩ := ih
      refine ⟨u y, by simpa using hy, ?_⟩
      let v := fun i => run q x i g
      have hv (i : Fin N) : ‖v i‖ = 1 := (run_norm q x i g).trans hx
      have htriangle := angle_le_angle_add_angle (bundle (fun i => phase q i (v i)))
        (bundle (fun i => phase q i y)) (bundle (fun _ => y))
      change familyAngle _ _ ≤ familyAngle _ _ + familyAngle _ _ at htriangle
      rw [angle_map hv (fun _ => hy) (phase q)] at htriangle
      simp only [run, List.foldl_append, List.foldl_cons, List.foldl_nil,
        List.length_append, List.length_cons, List.length_nil, zero_add, Nat.cast_add, Nat.cast_one]
      change familyAngle (fun i => u (phase q i (v i))) (fun _ => u y) ≤ _
      rw [angle_map (fun i => by simp [hv]) (fun _ => hy) (fun _ => u)]
      linarith [reference_angle q hy]
  obtain ⟨y, hy, hybrid⟩ := hybrid
  let v := fun i => run q x i g
  have hv (i : Fin N) : ‖v i‖ = 1 := (run_norm q x i g).trans hx
  let f := fun i => phase m i (v i)
  let r := fun i => phase m i y
  let z := fun _ : Fin N => y
  have h₁ := angle_le_angle_add_angle (bundle f) (bundle r) (bundle v)
  have h₂ := angle_le_angle_add_angle (bundle r) (bundle z) (bundle v)
  change familyAngle f v ≤ familyAngle f r + familyAngle r v at h₁
  change familyAngle r v ≤ familyAngle r z + familyAngle z v at h₂
  have hfr : familyAngle f r = familyAngle v z := angle_map hv (fun _ => hy) (phase m)
  have hzv : familyAngle z v = familyAngle v z := angle_comm _ _
  have hfv : familyAngle f v = _ := reflection_angle m hv
  have hrz : familyAngle r z ≤ 2 * θ := reference_angle m hy
  change familyAngle v z ≤ _ at hybrid
  change Real.arcsin (Real.sqrt (averageSuccess m v)) ≤ (2 * g.length + 1) * θ
  linarith

/-- Zalka's sharp bound on equal-prior Born success up to the first Grover maximum. -/
theorem optimal_average_success (q m : Labels N E) {x : E} (hx : ‖x‖ = 1)
    (g : List (E ≃ₗᵢ[ℂ] E))
    (beforePeak : (2 * g.length + 1) * Real.arcsin (1 / Real.sqrt N) ≤ Real.pi / 2) :
    averageSuccess m (fun i => run q x i g) ≤
      Real.sin ((2 * g.length + 1) * Real.arcsin (1 / Real.sqrt N)) ^ 2 := by
  have hp := success_mem (m := m) (fun i => (run_norm q x i g).trans hx)
  have h := Real.sin_le_sin_of_le_of_le_pi_div_two (Real.neg_pi_div_two_le_arcsin _) beforePeak
    (query_angle_bound q m hx g)
  rw [Real.sin_arcsin (by linarith [Real.sqrt_nonneg (averageSuccess m (fun i => run q x i g))])
    (Real.sqrt_le_one.mpr hp.2)] at h
  nlinarith [Real.sq_sqrt hp.1, Real.sqrt_nonneg (averageSuccess m (fun i => run q x i g)),
    sq_le_sq₀ (Real.sqrt_nonneg _) ((Real.sqrt_nonneg _).trans h) |>.mpr h]


open StatePrep.CircuitPreparation.AmplitudeAmplification

abbrev basisKet (i : Fin N) := EuclideanSpace.single i (1 : ℂ)

omit [NeZero N] in
private theorem coordinateProjection (i : Fin N) (v : EuclideanSpace ℂ (Fin N)) :
    (ℂ ∙ basisKet i).starProjection v = v i • basisKet i := by
  rw [Submodule.starProjection_unit_singleton ℂ (EuclideanSpace.orthonormal_single.norm_eq_one i)]
  simp [basisKet, EuclideanSpace.inner_single_left]

/-- Computational-basis query and readout labels for the algorithm attaining the bound. -/
def computationalLabels (N : ℕ) : Labels N (EuclideanSpace ℂ (Fin N)) where
  space i := ℂ ∙ basisKet i
  mass_le v := by
    simp_rw [coordinateProjection, norm_smul, EuclideanSpace.orthonormal_single.norm_eq_one, mul_one]
    rw [PiLp.norm_sq_eq_of_L2]

/-- Uniform preparation over all possible marked labels. -/
def uniform (N : ℕ) : EuclideanSpace ℂ (Fin N) :=
  WithLp.toLp 2 (fun _ => ((1 / Real.sqrt N : ℝ) : ℂ))

private theorem uniform_norm : ‖uniform N‖ = 1 := by
  have hn : (0:ℝ) < N := Nat.cast_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne N))
  have hs : (Real.sqrt N) ^ 2 = N := Real.sq_sqrt hn.le
  have h : ‖uniform N‖ ^ 2 = 1 := by
    rw [PiLp.norm_sq_eq_of_L2]
    simp [uniform, Complex.norm_real, Real.norm_eq_abs, hs, hn.ne']
  nlinarith [norm_nonneg (uniform N)]

omit [NeZero N] in
private theorem grover_run {q : Labels N E} {x : E} (hx : ‖x‖ = 1) (i : Fin N) (T : ℕ) :
    run q x i (List.replicate T (ℂ ∙ x).reflection) = (step (q.space i) x)^[T] x := by
  induction T with
  | zero => rfl
  | succ t ih =>
    rw [List.replicate_succ', run, List.foldl_append, List.foldl_cons, List.foldl_nil,
      Function.iterate_succ_apply']
    change (ℂ ∙ x).reflection (phase q i (run q x i _)) = _
    rw [ih, Submodule.reflection_apply, Submodule.starProjection_unit_singleton ℂ hx]
    have flip (z : E) : phase q i z = mark (q.space i) z := by
      change -((q.space i).reflection z) = _
      rw [Submodule.reflection_apply, mark, neg_sub, two_smul, ← two_smul ℂ]
    rw [flip]
    simp [step, reflectPrepared, two_smul, two_mul, add_smul]

/-- Grover attains the sharp bound, with a common diffusion gate for every
possible hidden label and exactly T calls to the same phase oracle model. -/
theorem grover_attains (hN : 2 ≤ N) (T : ℕ) :
    averageSuccess (computationalLabels N) (fun i => run (computationalLabels N) (uniform N) i
      (List.replicate T (ℂ ∙ uniform N).reflection)) =
        Real.sin ((2 * T + 1) * Real.arcsin (1 / Real.sqrt N)) ^ 2 := by
  let q := computationalLabels N
  let u := uniform N
  let θ := Real.arcsin (1 / Real.sqrt N)
  have hu : ‖u‖ = 1 := uniform_norm
  have hN' : 1 < (N:ℝ) := by exact_mod_cast (by omega : 1 < N)
  have hs : 0 < 1 / Real.sqrt N := by positivity
  have ha : 1 / Real.sqrt N < 1 := (div_lt_one (by positivity)).2 (Real.lt_sqrt_of_sq_lt (by simpa using hN'))
  have hsin : Real.sin θ = 1 / Real.sqrt N := Real.sin_arcsin (by linarith) ha.le
  have hc : 0 < Real.cos θ := Real.cos_pos_of_mem_Ioo
    ⟨by dsimp [θ]; linarith [(Real.arcsin_nonneg.mpr hs.le), Real.pi_pos],
      Real.arcsin_lt_pi_div_two.mpr ha⟩
  have each (i : Fin N) :
      ‖(q.space i).starProjection (run q u i (List.replicate T (ℂ ∙ u).reflection))‖ ^ 2 =
        Real.sin ((2 * T + 1) * θ) ^ 2 := by
    let K := q.space i
    let b := u - K.starProjection u
    have hproj : K.starProjection u = (Real.sin θ : ℂ) • basisKet i := by
      change (ℂ ∙ basisKet i).starProjection u = _
      rw [coordinateProjection, hsin]
      rfl
    have hbn : ‖b‖ = Real.cos θ := by
      have py := K.norm_sq_eq_add_norm_sq_starProjection u
      have hb : Kᗮ.starProjection u = b := by
        apply eq_sub_of_add_eq
        rw [add_comm, K.starProjection_add_starProjection_orthogonal]
      rw [hb, hu, hproj, norm_smul, EuclideanSpace.orthonormal_single.norm_eq_one,
        Complex.norm_real, Real.norm_eq_abs, mul_one, sq_abs] at py
      nlinarith [Real.sin_sq_add_cos_sq θ, norm_nonneg b]
    let p : Components K := {
      good := basisKet i, bad := ((Real.cos θ : ℂ)⁻¹) • b
      good_mem := Submodule.mem_span_singleton_self _
      bad_mem := Kᗮ.smul_mem _ (Submodule.sub_starProjection_mem_orthogonal _)
      good_norm := EuclideanSpace.orthonormal_single.norm_eq_one i
      bad_norm := by rw [norm_smul, norm_inv, Complex.norm_real, Real.norm_eq_abs, abs_of_pos hc, hbn,
                          inv_mul_cancel₀ hc.ne'] }
    have prep : state K p θ = u := by
      change (Real.sin θ : ℂ) • basisKet i + (Real.cos θ : ℂ) • (((Real.cos θ : ℂ)⁻¹) • b) = u
      rw [smul_smul, mul_inv_cancel₀ (by exact_mod_cast hc.ne'), one_smul, ← hproj]
      dsimp [b]; abel
    have h := success_law K p θ T
    rw [prep] at h
    rw [grover_run hu]; exact h
  change (∑ i, ‖(q.space i).starProjection (run q u i (List.replicate T (ℂ ∙ u).reflection))‖ ^ 2) / (N:ℝ) = _
  simp_rw [each]
  simp [θ, Nat.cast_ne_zero.mpr (NeZero.ne N)]


/-- In the first lobe, no algorithm's average success exceeds that of ordinary
Grover search using the same number of queries, including a one-item database. -/
theorem grover_is_optimal (q m : Labels N E) {x : E} (hx : ‖x‖ = 1)
    (g : List (E ≃ₗᵢ[ℂ] E))
    (beforePeak : (2 * g.length + 1) * Real.arcsin (1 / Real.sqrt N) ≤ Real.pi / 2) :
    averageSuccess m (fun i => run q x i g) ≤
      averageSuccess (computationalLabels N) (fun i => run (computationalLabels N) (uniform N) i
        (List.replicate g.length (ℂ ∙ uniform N).reflection)) := by
  by_cases hN : 2 ≤ N
  · rw [grover_attains hN]; exact optimal_average_success q m hx g beforePeak
  · have eq : N = 1 := by have := NeZero.ne N; omega
    subst N
    have hT : g.length = 0 := by
      simp at beforePeak
      by_contra! hT
      have len : (1:ℝ) ≤ g.length := by exact_mod_cast (by omega : 1 ≤ g.length)
      nlinarith [Real.pi_pos, mul_le_mul_of_nonneg_right len Real.pi_pos.le]
    rw [hT]
    have hsuccess := (success_mem (m := m) (fun i => (run_norm q x i g).trans hx)).2
    convert hsuccess using 1
    simp [averageSuccess, computationalLabels, coordinateProjection, uniform, run, basisKet]

open Filter Topology

/-- Near-certain success requires at least (π/4 − o(1))√N queries. The
workspace, gates and readout may vary with N. Index n represents N=n+1. -/
theorem near_certain_queries {H : ℕ → Type*} [∀ n, NormedAddCommGroup (H n)]
    [∀ n, InnerProductSpace ℂ (H n)] (q m : ∀ n, Labels (n+1) (H n)) (x : ∀ n, H n)
    (hx : ∀ n, ‖x n‖ = 1) (g : ∀ n, List (H n ≃ₗᵢ[ℂ] H n))
    (certain : Tendsto (fun n => averageSuccess (m n) (fun i => run (q n) (x n) i (g n))) atTop (𝓝 1)) :
    ∀ ε : ℝ, 0 < ε → ∀ᶠ n : ℕ in atTop,
      (Real.pi / 4 - ε) * Real.sqrt (n+1) ≤ (g n).length := by
  let a (n : ℕ) : ℝ := 1 / Real.sqrt (n+1)
  let p (n : ℕ) := averageSuccess (m n) (fun i => run (q n) (x n) i (g n))
  have ha (n : ℕ) : 0 < a n := by dsimp [a]; positivity
  have a_top : Tendsto (fun n : ℕ => (n:ℝ) + 1) atTop atTop :=
    tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop
  have a_zero : Tendsto a atTop (𝓝 0) := by
    simpa [a, one_div, Function.comp_def] using (tendsto_inv_atTop_zero.comp (Real.tendsto_sqrt_atTop.comp a_top))
  have a_ne : Tendsto a atTop (𝓝[≠] 0) :=
    tendsto_nhdsWithin_iff.mpr ⟨a_zero, .of_forall fun n => (ha n).ne'⟩
  have slope : Tendsto (fun z : ℝ => Real.arcsin z / z) (𝓝[≠] 0) (𝓝 1) := by
    have hd : HasDerivAt Real.arcsin 1 0 := by simpa using Real.hasDerivAt_arcsin (x := 0) (by norm_num) (by norm_num)
    exact (hasDerivAt_iff_tendsto_slope.mp hd).congr fun z => by simp [slope_def_field]
  have prob : Tendsto (fun n => Real.arcsin (Real.sqrt (p n))) atTop (𝓝 (Real.pi/2)) := by
    simpa only [Function.comp_def, p, Real.sqrt_one, Real.arcsin_one] using
      (Real.continuous_arcsin.tendsto _).comp ((Real.continuous_sqrt.tendsto _).comp certain)
  let bound (n : ℕ) := Real.arcsin (Real.sqrt (p n)) / (Real.arcsin (a n) / a n) / 2 - a n / 2
  have lim : Tendsto bound atTop (𝓝 (Real.pi/4)) := by
    have h := ((prob.div (slope.comp a_ne) one_ne_zero).div_const 2).sub (a_zero.div_const 2)
    rw [show Real.pi / 2 / 1 / 2 - 0 / 2 = Real.pi / 4 by ring] at h
    exact h
  intro ε hε
  filter_upwards [lim.eventually_const_lt (show Real.pi / 4 - ε < Real.pi / 4 by linarith)] with n hn
  have hθ := (Real.arcsin_pos.mpr (ha n))
  have h := query_angle_bound (q n) (m n) (hx n) (g n)
  have angle_bound : Real.arcsin (Real.sqrt (p n)) ≤ (2 * (g n).length + 1) * Real.arcsin (a n) := by
    simpa [p, a, Nat.cast_add, Nat.cast_one] using h
  have lower : bound n ≤ (g n).length * a n := by
    dsimp [bound]
    rw [div_div_eq_mul_div]
    have hdiv := (div_le_iff₀ hθ).mpr
      (show Real.arcsin (Real.sqrt (p n)) * a n ≤ ((2 * (g n).length + 1) * a n) * Real.arcsin (a n) by
        calc _ ≤ ((2 * (g n).length + 1) * Real.arcsin (a n)) * a n := mul_le_mul_of_nonneg_right angle_bound (ha n).le
             _ = _ := by ring)
    linarith
  have result := hn.le.trans lower
  simpa [a, mul_div_assoc] using (le_div_iff₀ (by positivity : 0 < Real.sqrt ((n:ℝ)+1))).mp
    (by simpa [a, div_eq_mul_inv] using result : Real.pi / 4 - ε ≤ (g n).length / Real.sqrt ((n:ℝ)+1))


end FQChem.Complexity.SearchOptimality
