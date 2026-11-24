module

public import FQChemQatlib.Dynamics.LowChuangBinaryPhase

/-! # Uniformly averaging a reversible phase circuit on selected wires -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Binary

open Matrix Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open scoped Classical

variable {p n : ℕ}

def Outside (w : Fin p ↪ Fin n) (x y : Reg n) := ∀ i, i ∉ Set.range w → y i = x i

def fill (w : Fin p ↪ Fin n) (x : Reg n) (u : Reg p) : Reg n := fun i =>
  if hi : i ∈ Set.range w then u (Classical.choose hi) else x i

theorem fill_at (w : Fin p ↪ Fin n) (x : Reg n) (u : Reg p) (i : Fin p) :
    fill w x u (w i) = u i := by
  have h : w i ∈ Set.range w := ⟨i,rfl⟩
  simp [fill,h]

theorem fill_out (w : Fin p ↪ Fin n) (x : Reg n) (u : Reg p) {i : Fin n} (h : i ∉ Set.range w) :
    fill w x u i = x i := by simp [fill,h]

def slice (w : Fin p ↪ Fin n) (x : Reg n) : {y : Reg n // Outside w x y} ≃ Reg p where
  toFun y := y.val ∘ w
  invFun u := ⟨fill w x u,fun _ h => fill_out w x u h⟩
  left_inv y := by
    ext i
    by_cases h : i∈Set.range w
    · obtain ⟨k,rfl⟩ := h; simp [fill_at]
    · simpa [fill_out w x _ h] using (y.prop i h).symm
  right_inv u := by funext i; exact fill_at w x u i

def hWord (w : Fin p ↪ Fin n) := thermalUniformHWord (List.ofFn w)

theorem hWord_cost (w : Fin p ↪ Fin n) : (hWord w).length=p ∧ finiteWordLegal n (hWord w)=true :=
  ⟨by simp [hWord,thermalUniformHWord],thermalUniformHWord_legal _⟩

/-- With zero initial bits on the selected wires, a Hadamard, diagonal
operator and inverse Hadamard have the exact uniform mean as their clean
column entry. The diagonal operator may depend on every spectator bit. -/
theorem mean_diagonal (w : Fin p ↪ Fin n) (x : Reg n) (clean : ∀ i,x (w i)=false)
    (d : Reg n → ℂ) :
    let H := finiteWordMatrix n (hWord w)
    (Hᴴ * Matrix.diagonal d * H) x x = (∑ u : Reg p, d (fill w x u))/(2:ℂ)^p := by
  let H := finiteWordMatrix n (hWord w)
  have col (y : Reg n) : H y x = if Outside w x y then ((Real.sqrt 2:ℂ)⁻¹)^p else 0 := by
    have eq := thermalUniformHWord_zero_column (List.ofFn w) ((List.nodup_ofFn).mpr w.injective)
      y x (fun v hv => by obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hv; exact clean i)
    rw [run_finiteCodeCircuit] at eq
    simpa [H,hWord,Matrix.mulVec,dotProduct,Qatlib.Foundations.PureStateMath.Ket,Outside,
      List.mem_ofFn,Set.mem_range] using eq
  have sq : ((Real.sqrt 2:ℂ)⁻¹)^p * ((Real.sqrt 2:ℂ)⁻¹)^p = ((2:ℂ)^p)⁻¹ := by
    have h : (Real.sqrt 2:ℂ)^2=2 := by exact_mod_cast Real.sq_sqrt (by norm_num : (0:ℝ)≤2)
    rw [← mul_pow,← mul_inv,← pow_two,h,inv_pow]
  change (Hᴴ * Matrix.diagonal d * H) x x = _
  rw [Matrix.mul_apply]
  simp only [Matrix.mul_diagonal,Matrix.conjTranspose_apply,col]
  have summand (y : Reg n) : star (if Outside w x y then ((Real.sqrt 2:ℂ)⁻¹)^p else 0) *
      d y * (if Outside w x y then ((Real.sqrt 2:ℂ)⁻¹)^p else 0) =
      (if Outside w x y then d y else 0) / (2:ℂ)^p := by
    by_cases h : Outside w x y
    · simp only [h,ite_true,Complex.star_def,map_pow,map_inv₀,Complex.conj_ofReal,div_eq_mul_inv]
      linear_combination (norm:=ring_nf) d y * sq
    · simp [h]
  simp_rw [summand]
  rw [← Finset.sum_div]
  congr 1
  rw [← Finset.sum_filter,← Finset.sum_subtype_eq_sum_filter]
  simp only [Finset.subtype_univ]
  exact (slice w x).symm.sum_comp (fun y => d y.val) |>.symm

end FQChemQatlib.Dynamics.LowChuang.Binary
