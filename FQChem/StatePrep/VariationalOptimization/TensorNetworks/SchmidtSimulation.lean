module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.MinimalBonds
public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.PhysicalCuts
public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitReadout
import Mathlib.Tactic

/-! # Classical circuit simulation under a physical Schmidt-rank promise

The rank promise is stated for all contiguous flattenings of the dense physical state.
For product inputs, the pivot-based simulator uses exactly the physical bond spaces
all along the circuit. [Vidal (2003), Theorem 1](https://doi.org/10.1103/PhysRevLett.91.147902).
-/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit
open Matrix
variable {K : Type*} [Field K] [DecidableEq K]

omit [DecidableEq K] in
private theorem rank_of_kernel {X Y : Type*} [Fintype X] [Fintype Y] (M : Matrix X Y K)
    (h : ∀ v, M *ᵥ v = 0 → v = 0) : M.rank = Fintype.card Y := by
  have hz : LinearMap.ker M.mulVecLin = ⊥ := Matrix.ker_mulVecLin_eq_bot_iff.mpr h
  have d := M.mulVecLin.finrank_range_add_finrank_ker
  rw [hz, finrank_bot, add_zero, Module.finrank_pi] at d
  exact d

def suffix {n l r : ℕ} (C : Chain K n l r) : Matrix (Fin l) (Bits n × Fin r) K :=
  Matrix.of fun a z => C.coefficient z.1 a z.2

omit [DecidableEq K] in
/-- A right-full suffix can distinguish every nonzero direction on its incoming bond. -/
private theorem suffix_injective {n l r : ℕ} (C : Chain K n l r) (hc : C.full)
    (v : Fin l → K) (hv : ∀ z : Bits n, v ᵥ* C.coefficient z = 0) : v = 0 := by
  induction C with
  | nil d => simpa [Chain.coefficient] using hv ()
  | cons A C ih =>
    apply hc.1.2
    intro i
    apply ih hc.2
    intro y
    rw [Matrix.vecMul_vecMul]
    exact hv (i,y)

omit [DecidableEq K] in
private theorem suffix_rank {n l r : ℕ} (C : Chain K n l r) (hc : C.full) :
    (suffix C).rank = l := by
  rw [← Matrix.rank_transpose]
  apply (rank_of_kernel _ _).trans (Fintype.card_fin l)
  intro v hv
  apply suffix_injective C hc v
  intro z
  ext b
  simpa only [Matrix.mulVec, Matrix.vecMul, dotProduct, Matrix.transpose_apply,
    suffix, Matrix.of_apply, Pi.zero_apply, mul_comm] using congrFun hv (z,b)

def extendFrame {X : Type*} {l r : ℕ} (F : Matrix X (Fin l) K) (A : Site K l r) :
    Matrix (X × Fin 2) (Fin r) K := Matrix.of fun p b => (F * A p.2) p.1 b

omit [DecidableEq K] in
private theorem frame_injective {X : Type*} [Fintype X] {l r : ℕ}
    (F : Matrix X (Fin l) K) (A : Site K l r) (hf : ∀ v, F *ᵥ v = 0 → v = 0)
    (ha : LeftFull A) (v : Fin r → K) (hv : extendFrame F A *ᵥ v = 0) : v = 0 := by
  apply ha
  intro i
  apply hf
  rw [Matrix.mulVec_mulVec]
  ext x
  exact congrFun hv (x,i)

omit [DecidableEq K] in
private theorem current_cut {n r χ : ℕ} {X : Type*} [Fintype X] (v : X → Bits n → Fin r → K)
    (h : CutBound χ v) : (Matrix.of fun x (z : Bits n × Fin r) => v x z.1 z.2).rank ≤ χ := by
  cases n with
  | zero => exact h
  | succ => exact h.1

omit [DecidableEq K] in
private theorem front_dim {n l r χ : ℕ} {X : Type*} [Fintype X] (C : Chain K n l r)
    (F : Matrix X (Fin l) K) (hc : C.full) (hf : ∀ v, F *ᵥ v = 0 → v = 0)
    (h : CutBound χ (fun x z b => (F*C.coefficient z) x b)) : l ≤ χ := by
  have rankF : F.rank = l := (rank_of_kernel F hf).trans (Fintype.card_fin _)
  have rankR := suffix_rank C hc
  have current := current_cut _ h
  change (F * suffix C).rank ≤ χ at current
  have lo := Matrix.rank_mul_ge F (suffix C)
  rw [rankF, rankR, Fintype.card_fin] at lo
  omega

omit [DecidableEq K] in
/-- Every actual bond lies below the bound on physical cut ranks. The frame is the
amplitude matrix of all already processed sites and has independent columns. -/
theorem width_of_cuts {n l r χ : ℕ} {X : Type*} [Fintype X] (C : Chain K n l r)
    (F : Matrix X (Fin l) K) (hc : C.full) (hf : ∀ v, F *ᵥ v = 0 → v = 0)
    (h : CutBound χ (fun x z b => (F*C.coefficient z) x b)) : C.width ≤ χ := by
  induction C generalizing X with
  | nil => exact front_dim _ F hc hf h
  | @cons n l m r A C ih =>
    refine max_le (front_dim _ F hc hf h) (ih (extendFrame F A) hc.2 (frame_injective F A hf hc.1.1) ?_)
    have eq : (fun (p : X × Fin 2) z b => (extendFrame F A * C.coefficient z) p b) =
        fun p z b => (F * (Chain.cons A C).coefficient (p.2,z)) p.1 b := by
      funext p z b
      exact congrArg (fun (M : Matrix X (Fin r) K) => M p.1 b) (Matrix.mul_assoc F (A p.2) (C.coefficient z))
    rw [eq]
    exact h.2

/-- Rank bound on the initial physical vector and every dense evolved vector. -/
def trajectory {n : ℕ} (χ : ℕ) : List (Gate K n) → (Bits n → K) → Prop
  | [], v => PhysicalCuts v χ
  | g :: gs, v => PhysicalCuts v χ ∧ trajectory χ gs (g.act v)

def amplitude {n : ℕ} (C : Chain K n 1 1) (x : Bits n) : K := C.coefficient x 0 0

omit [DecidableEq K] in
private theorem initialWidth {n χ : ℕ} (C : Chain K n 1 1) (hc : C.full)
    (h : PhysicalCuts (amplitude C) χ) : C.width ≤ χ := by
  apply width_of_cuts C (1 : Matrix (Fin 1) (Fin 1) K) hc (by simp)
  have eq : (fun x z b => ((1 : Matrix (Fin 1) (Fin 1) K)*C.coefficient z) x b) =
      fun _ z _ => amplitude C z := by
    funext x z b
    fin_cases x; fin_cases b
    simp [amplitude]
  rw [eq]
  exact h

/-- At every prefix, physical Schmidt rank controls the actual simulator width. -/
theorem trajectory_width {n χ : ℕ} (gs : List (Gate K n)) (C : Chain K n 1 1)
    (hc : C.full) (hg : ∀ g ∈ gs, g.invertible) (h : trajectory χ gs (amplitude C)) :
    peakWidth gs C ≤ χ := by
  induction gs generalizing C with
  | nil => exact initialWidth C hc h
  | cons g gs ih =>
    apply max_le (initialWidth C hc h.1)
    apply ih _ (advance_full g C (hg _ (by simp)) hc) (fun q hq => hg q (by simp [hq]))
    have eq : amplitude (advance g C).1 = g.act (amplitude C) :=
      funext fun z => advance_exact g C z 0 0
    rw [eq]
    exact h.2

/-- Open product-state input with scalar virtual bonds. -/
def productChain : {n : ℕ} → (Fin n → Fin 2 → K) → Chain K n 1 1
  | 0, _ => .nil 1
  | _+1, v => .cons (fun i => Matrix.of fun _ _ => v 0 i) (productChain (Fin.tail v))

/-- Dense amplitude of the ordinary tensor product of the supplied one-qubit vectors. -/
def productAmplitude : {n : ℕ} → (Fin n → Fin 2 → K) → Bits n → K
  | 0, _, _ => 1
  | _+1, v, (b,x) => v 0 b * productAmplitude (Fin.tail v) x

omit [DecidableEq K] in
theorem product_amplitude {n : ℕ} (v : Fin n → Fin 2 → K) (x : Bits n) :
    amplitude (productChain v) x = productAmplitude v x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rcases x with ⟨b,x⟩
    simpa only [amplitude, productChain, Chain.coefficient, Matrix.mul_apply, Fin.sum_univ_one,
      Matrix.of_apply, productAmplitude] using congrArg (v 0 b * ·) (ih (Fin.tail v) x)

omit [DecidableEq K] in
theorem product_full {n : ℕ} (v : Fin n → Fin 2 → K) (h : ∀ i, ∃ b, v i b ≠ 0) :
    (productChain v).full := by
  induction n with
  | zero => trivial
  | succ n ih =>
    obtain ⟨b,hb⟩ := h 0
    refine ⟨⟨?_,?_⟩,ih (Fin.tail v) (fun i => h i.succ)⟩
    · intro u hu
      have z := congrFun (hu b) 0
      simp [Matrix.mulVec, dotProduct] at z
      ext i
      have e : i = 0 := Subsingleton.elim ..
      simpa [e] using z.resolve_left hb
    · intro u hu
      have z := congrFun (hu b) 0
      simp [Matrix.vecMul, dotProduct] at z
      ext i
      have e : i = 0 := Subsingleton.elim ..
      simpa [e] using z.resolve_right hb

/-- Vidal's polynomial gate-update bound from the physical Schmidt promise, for every
nearest-neighbour circuit of invertible two-qubit gates and every nonzero product input. -/
theorem schmidtCircuit {n χ : ℕ} (gs : List (Gate K n)) (v : Fin n → Fin 2 → K)
    (hv : ∀ i, ∃ b, v i b ≠ 0) (hg : ∀ g ∈ gs, g.invertible)
    (h : trajectory χ gs (amplitude (productChain v))) :
    let C := productChain v
    (∀ x, amplitude (simulate gs C).1 x = dense gs (amplitude C) x) ∧
    (simulate gs C).2 ≤ gs.length*(24*χ^3+40*χ^2) ∧ peakWidth gs C ≤ χ :=
  let width := trajectory_width gs (productChain v) (product_full v hv) hg h
  ⟨fun x => simulate_exact gs _ x 0 0, simulate_work gs _ width, width⟩

end FQChem.Algorithms.MPSCircuit
