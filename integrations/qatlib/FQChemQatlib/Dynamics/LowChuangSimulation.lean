module

public import FQChemQatlib.Dynamics.LowChuangCutoff
public import FQChemQatlib.Dynamics.LowChuangGateWord
public import FQChemQatlib.Dynamics.SparseHamiltonianSimulation
public import Qatlib.Concepts.QspSimulation.Achievability.CleanSignalSimulation

/-! # Optimal-cutoff quantum signal simulation on two auxiliary qubits

The sine and cosine phase sequences encode a deliberately attenuated
evolution. Three cubic amplification steps act on the same two auxiliary
qubits. The degree is fixed by Eq. (1) of Low and Chuang (2019).
-/

@[expose] public section

namespace FQChemQatlib.Dynamics.LowChuang

open Matrix Polynomial Qatlib.Concepts.TrotterFormula.SuzukiFourth
open Qatlib.Foundations.PureStateMath Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.CoherentSim.CoherentOAA
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.QspSimulation.JacobiAnger
open Qatlib.Concepts.QueryWordCore.AdjointCircuits Qatlib.Concepts.BlockEncoding
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.BlockEncoding.Encoding Qatlib.Concepts.BlockEncoding.Postselection
open Qatlib.Concepts.BlockEncoding.Postselection.Encoding Qatlib.Concepts.BlockEncoding.LCU
open Qatlib.Concepts.PhaseGeometry.Phase Qatlib.Concepts.CoherentSim.CoherentOAA.SignalProcessing
open Qatlib.Concepts.QsvtCore.PhaseExistence.PhaseSynthesis
open Qatlib.Papers.Qubitization19.MainResults
open scoped Classical Matrix.Norms.L2Operator

variable {W I : Type} [Fintype W] [DecidableEq W] [Fintype I] [DecidableEq I]

/-- The phase response polynomials include the attenuation needed for exact
amplification. The host already contains the two controls for cosine/sine and
conjugate averaging. -/
private theorem attenuatedBody (F : Matrix W I ℂ) (frame : IsIsometry F)
    (t : ℝ) (n : ℕ) (time : 2*|t| ≤ n+1) (tail : exponentialTaylorError t n < 1) :
    ∃ cs : List (AdjointStep (Bool × (Bool × W))),
      WellFormedAdjointCircuit cs ∧ Covered (FrameGate F) cs ∧ adjointQueryCount cs = 4*n+1 ∧
      adjointGateCount cs = 4*n+6 ∧
      ∀ (A : Matrix I I ℂ) (U : Matrix W W ℂ), A.IsHermitian → ProjectedUnitaryEncoding A U F F →
      ProjectedUnitaryEncoding ((Real.sin (Real.pi/54) : ℂ) • aeval A (exponentialTaylorPolynomial t n))
        (evaluate (controlOracle (parallelOracle (J := Bool) U)) cs) (hamiltonianFrame F) (hamiltonianFrame F) := by
  let s := Real.sin (Real.pi/54)
  have hs := scaleEight_parameter_bounds
  have hs0 : 0 ≤ 2*s := by dsimp [s]; linarith
  have phases (p : Polynomial ℝ) (d : ℕ) (degree : p.natDegree ≤ d)
      (parity : HasRealParity d p) (bounded : ∀ x ∈ Set.Icc (-1:ℝ) 1, |p.eval x| < 2) :
      ∃ (z : ℂ) (zs : List ℂ), IsPhase z ∧ (∀ v ∈ zs, IsPhase v) ∧ zs.length = d ∧
        realPartPolynomial (responseP z zs) = (C (2*s)*p).map Complex.ofRealHom := by
    have hd := degree_le_of_natDegree_le ((natDegree_C_mul_le (2*s) p).trans degree)
    have hp : HasRealParity d (C (2*s)*p) := by
      change p.comp (-X) = _ at parity
      simp only [HasRealParity, mul_comp, C_comp, parity]; ring
    obtain ⟨z,zs,hz,hl,hsize,eq,_⟩ := exists_phases_of_strict hd hp (fun x hx => by
      rw [eval_mul,eval_C,abs_mul,abs_of_nonneg hs0]
      have := mul_le_mul_of_nonneg_left (bounded x hx).le hs0
      dsimp [s] at this ⊢
      linarith)
    exact ⟨z,zs,hz,hl,hsize,hamiltonian_realPart_of_completion eq⟩
  obtain ⟨bc,zc,hbc,hzc,lc,hc⟩ := phases (cosineTaylorPolynomial t n) (2*n)
    ((cosineTaylorPolynomial_natDegree_le t n).trans (by omega))
    (by simp [HasRealParity,cosineTaylorPolynomial_comp_neg_X,pow_mul])
    (fun _ hx => cosineTaylorPolynomial_abs_lt_two t n time tail hx)
  obtain ⟨bs,zs,hbs,hzs,ls,hsin⟩ := phases (sineTaylorPolynomial t n) (2*n+1)
    ((sineTaylorPolynomial_natDegree_le t n).trans (by omega))
    (by simp [HasRealParity,sineTaylorPolynomial_comp_neg_X,pow_add,pow_mul])
    (fun _ hx => sineTaylorPolynomial_abs_lt_two t n time tail hx)
  have counts := counts_compileHamiltonian F bc zc bs zs
  refine ⟨compileHamiltonian F bc zc bs zs,
    compileHamiltonian_wellFormed frame hbc zc hzc hbs zs hzs, body_gates F bc zc bs zs hbc hzc hbs hzs,by omega,by omega,?_⟩
  intro A U hermitian enc
  have co := hermitian_realPart_projectedEncoding hermitian enc hbc zc hzc
  have si := hermitian_realPart_projectedEncoding hermitian enc hbs zs hzs
  rw [hc] at co
  rw [hsin] at si
  have joint := average_projectedEncoding co
    (hamiltonian_phase_projectedEncoding si (z := -Complex.I) (by simp [IsPhase]))
  have trig : (2:ℂ)⁻¹ • (aeval A ((C (2*s)*cosineTaylorPolynomial t n).map Complex.ofRealHom) +
      (-Complex.I) • aeval A ((C (2*s)*sineTaylorPolynomial t n).map Complex.ofRealHom)) =
      (s:ℂ) • aeval A (exponentialTaylorPolynomial t n) := by
    have coeff (p : Polynomial ℝ) (a : ℝ) :
        aeval A ((C a*p).map Complex.ofRealHom) = (a:ℂ) • aeval A (p.map Complex.ofRealHom) := by
      rw [Polynomial.map_mul,Polynomial.map_C,map_mul,aeval_C,Algebra.algebraMap_eq_smul_one,
        Matrix.smul_mul,Matrix.one_mul]
      rfl
    rw [coeff,coeff,exponentialTaylorPolynomial_eq_trig,map_sub,map_mul,aeval_C,
      Algebra.algebraMap_eq_smul_one,Matrix.smul_mul,Matrix.one_mul, Complex.ofReal_mul,Complex.ofReal_ofNat]
    ext i j
    simp only [Matrix.smul_apply, smul_eq_mul, Matrix.add_apply, Matrix.sub_apply]
    ring
  rw [trig] at joint
  rw [evaluate_compileHamiltonian]; exact joint

/-- A clean cubic step multiplies the ideal signal angle by three. This bound
tracks the error together with the well-formed word and its two exact ledgers. -/
private theorem amplifiedLevels {O : Matrix W W ℂ} {R : Matrix W I ℂ}
    {cs : List (AdjointStep W)} {V : Matrix I I ℂ} {θ δ : ℝ}
    (hO : O ∈ Matrix.unitaryGroup W ℂ) (hR : IsIsometry R) (wf : WellFormedAdjointCircuit cs)
    (hV : V ∈ Matrix.unitaryGroup I ℂ)
    (base : ‖compress R (evaluate O cs) R - (Real.sin θ : ℂ) • V‖ ≤ δ) (k : ℕ) :
    let word := scaleEightLevels R k cs
    WellFormedAdjointCircuit word ∧ adjointQueryCount word = 3^k * adjointQueryCount cs ∧
    adjointGateCount word+2 = 3^k*(adjointGateCount cs+2) ∧
    ‖compress R (evaluate O word) R - (Real.sin (3^k*θ) : ℂ) • V‖ ≤ 15^k*δ := by
  induction k with
  | zero => simpa [scaleEightLevels,wf] using base
  | succ k ih =>
    let prev := scaleEightLevels R k cs
    obtain ⟨hw,hq,hg,err⟩ := ih
    have unit := hw.evaluate_unitary hO
    have step := coherent_oaa_expanded_subroutine O prev R hw hR
    have poly := (coherent_oaa_word_correct _ R hR unit).2.2.2.2
    have cx := (compress_norm_le hR hR _).trans (unitary_norm_le_one unit)
    have cy : ‖(Real.sin ((3:ℝ)^k*θ) : ℂ) • V‖ ≤ 1 := by
      rw [norm_smul,Complex.norm_real,Real.norm_eq_abs]
      exact (mul_le_mul (Real.abs_sin_le_one _) (unitary_norm_le_one hV)
        (norm_nonneg _) zero_le_one).trans_eq (one_mul 1)
    refine ⟨step.2.2.2,?_,?_,?_⟩
    · rw [scaleEightLevels,step.2.1,hq,pow_succ]; ring
    · rw [scaleEightLevels,step.2.2.1,pow_succ]; dsimp [prev] at *; nlinarith [hg]
    · rw [scaleEightLevels,step.1,poly,show (3:ℝ)^(k+1)*θ=3*(3^k*θ) by rw [pow_succ];ring,
        ← scaleEightCubic_sin V hV]
      exact (scaleEightCubic_lipschitz _ _ cx cy).trans
        ((mul_le_mul_of_nonneg_left err (by norm_num : (0:ℝ)≤15)).trans_eq (by rw [pow_succ];ring))

/-- One circuit simulates every input with operator-norm error, clean-frame
vector error and a Born success guarantee. It acts on the oracle register
and exactly two Boolean registers. Here a fixed gate is a matrix instruction
and a query is a controlled invocation of the encoding or its adjoint. -/
theorem uniformCutoffWord (F : Matrix W I ℂ) (frame : IsIsometry F)
    (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧ ∃ word : List (AdjointStep (Bool × (Bool × W))),
      WellFormedAdjointCircuit word ∧ Covered (FrameGate F) word ∧ adjointQueryCount word = 27*(64*q+1) ∧
      adjointGateCount word = 27*(64*q+8)-2 ∧ ∀ (A : Matrix I I ℂ) (U : Matrix W W ℂ),
      A.IsHermitian → ProjectedUnitaryEncoding A U F F →
      let R := hamiltonianFrame F
      let M := evaluate (controlOracle (parallelOracle (J := Bool) U)) word
      let V := hamiltonianEvolution A t
      ‖compress R M R - V‖ ≤ ε^2/2 ∧
      (∀ ψ : QState I, ‖toEuclidean_fromVec (M *ᵥ (R *ᵥ ψ) - R *ᵥ (V *ᵥ ψ))‖ ≤
        ε*‖toEuclidean_fromVec ψ‖) ∧
      ∀ ψ : QState I, Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ := by
  obtain ⟨q,hq⟩ := leastCutoff t ε positive
  obtain ⟨time,tail⟩ := amplifiedTaylorCutoff t ε hq.1 positive small.le hq.2.1
  have e2 : ε^2 ≤ 1 := by nlinarith [mul_nonneg positive.le (sub_nonneg.mpr small.le)]
  let n := 16*q
  let R := hamiltonianFrame F
  obtain ⟨cs,wf,cover,hc,hg,cores⟩ := attenuatedBody F frame t n time (tail.trans_lt (by linarith))
  let word := scaleEightLevels R 3 cs
  -- The word and both ledgers are fixed before the input oracle is supplied.
  have rIso : IsIsometry R := averageFrame_isIsometry (averageFrame_isIsometry frame)
  have info := amplifiedLevels (O := (1 : Matrix (Bool × (Bool × W)) _ ℂ))
    (R := R) (cs := cs) (V := (1 : Matrix I I ℂ)) (θ := 0)
    (Submonoid.one_mem _) rIso wf (Submonoid.one_mem _) (le_rfl : ‖_ - _‖ ≤ _) 3
  refine ⟨q,hq,word,info.1,amplification_gates cover 3,?_,?_,?_⟩
  · rw [info.2.1,hc]; dsimp [n]; omega
  · have gates := info.2.2.1
    change adjointGateCount (scaleEightLevels R 3 cs)+2 = 27*(adjointGateCount cs+2) at gates
    rw [hg] at gates; dsimp [n] at gates; dsimp [word]; omega
  intro A U hermitian enc
  have body := cores A U hermitian enc
  let O := controlOracle (parallelOracle (J := Bool) U)
  let V := hamiltonianEvolution A t
  have normA : ‖A‖ ≤ 1 := by
    rw [← enc.encoded]
    exact (compress_norm_le enc.left_isometry enc.right_isometry U).trans (unitary_norm_le_one enc.unitary)
  have err := computed_signal_hermitian_polynomial_error A hermitian normA (exponentialTaylorPolynomial t n)
    t (exponentialTaylorError t n) (exponentialTaylorError_nonneg _ _)
    (fun _ hx => exponentialTaylorPolynomial_error_le t n time hx)
  have base : ‖compress R (evaluate O cs) R - (Real.sin (Real.pi/54):ℂ) • V‖ ≤ ε^2/6750 := by
    rw [body.encoded,← smul_sub,norm_smul,Complex.norm_real,Real.norm_eq_abs]
    exact ((mul_le_mul_of_nonneg_right (Real.abs_sin_le_one _) (norm_nonneg _)).trans_eq (one_mul _)).trans
      (err.trans tail)
  have unit := controlOracle_unitary (parallelOracle_unitary (J := Bool) enc.unitary)
  have target := hamiltonianEvolution_unitary hermitian t
  obtain ⟨well,_,_,comp⟩ := amplifiedLevels unit body.right_isometry wf target base 3
  have δ : ‖compress R (evaluate O word) R - V‖ ≤ ε^2/2 := by
    have angle : (3:ℝ)^3*(Real.pi/54) = Real.pi/2 := by ring
    rw [angle,Real.sin_pi_div_two,Complex.ofReal_one,one_smul] at comp
    exact comp.trans_eq (by ring)
  refine ⟨δ,?_,?_⟩
  · intro ψ
    have clean := scaleEight_clean_from_compression V (evaluate O word) R (ε^2/2) target
      (well.evaluate_unitary unit) body.right_isometry (by positivity) δ ψ
    rwa [show 2*(ε^2/2)=ε^2 by ring,Real.sqrt_sq positive.le] at clean
  · intro ψ hψ
    have be : BlockEncoding V (evaluate O word) R R 1 (ε^2/2) :=
      ⟨well.evaluate_unitary unit,body.right_isometry,body.right_isometry,by norm_num,by positivity,
       by simpa only [one_smul,norm_sub_rev] using δ⟩
    have nV : ‖stateVector (V *ᵥ ψ)‖ = 1 := (normalized_iff_stateVector_norm _).mp
      (normalized_applyGate target hψ)
    have born := BlockEncoding.postselection_probability_lower be hψ (show ε^2/2 ≤ _ by rw [nV]; linarith)
    rw [nV,div_one] at born
    exact (show 1-ε^2 ≤ (1-ε^2/2)^2 by nlinarith [sq_nonneg (ε^2)]).trans born

/-- The operator-error and success bounds for an individual encoded input. -/
theorem optimalCutoffEvolution {A : Matrix I I ℂ} {U : Matrix W W ℂ} {F : Matrix W I ℂ}
    (hermitian : A.IsHermitian) (enc : ProjectedUnitaryEncoding A U F F)
    (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧ ∃ word : List (AdjointStep (Bool × (Bool × W))),
      let R := hamiltonianFrame F
      let M := evaluate (controlOracle (parallelOracle (J := Bool) U)) word
      let V := hamiltonianEvolution A t
      WellFormedAdjointCircuit word ∧ adjointQueryCount word = 27*(64*q+1) ∧
      adjointGateCount word = 27*(64*q+8)-2 ∧ ‖compress R M R - V‖ ≤ ε^2/2 ∧
      (∀ ψ : QState I, ‖toEuclidean_fromVec (M *ᵥ (R *ᵥ ψ) - R *ᵥ (V *ᵥ ψ))‖ ≤
        ε*‖toEuclidean_fromVec ψ‖) ∧
      ∀ ψ : QState I, Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ := by
  obtain ⟨q,hq,word,wf,_,queries,gates,uniform⟩ := uniformCutoffWord F enc.left_isometry t ε positive small
  exact ⟨q,hq,word,wf,queries,gates,uniform A U hermitian enc⟩

end FQChemQatlib.Dynamics.LowChuang
