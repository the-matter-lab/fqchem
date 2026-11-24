module

public import FQChemQatlib.Dynamics.LowChuangSparseResources

/-! # Exact evolution of a zero-qubit Hamiltonian from an ordinary binary oracle -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseScalar

open Matrix Query SparseBlock Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open Sparse (Access)
open scoped Classical

abbrev Answers (p : ℕ) := Bool × Reg p × Reg p
abbrev W (p : ℕ) := List (Step (Answers p) Access)

def rotor (s : ℝ) : ℂ := Complex.exp ((s:ℂ)*Complex.I)
private theorem rotor_add (x y : ℝ) : rotor (x+y)=rotor x*rotor y := by
  simp [rotor,add_mul,Complex.exp_add]

def pulse {p : ℕ} (i : Fin p) (θ : ℝ) : Matrix (Answers p) (Answers p) ℂ :=
  Matrix.diagonal fun x => if x.2.1 i then rotor θ else 1

def scalarGate (p : ℕ) (θ : ℝ) : Matrix (Answers p) (Answers p) ℂ :=
  Matrix.diagonal fun _ => rotor θ

/-- Each fixed gate acts on the indicated real-value answer bit or applies
the one-qubit unitary exp(iθ) I on the spare flag. -/
inductive OneWire (p : ℕ) : Matrix (Answers p) (Answers p) ℂ → Prop where
  | bit (i : Fin p) (θ : ℝ) : OneWire p (pulse i θ)
  | scalar (θ : ℝ) : OneWire p (scalarGate p θ)

def pulses {p : ℕ} (θ : ℝ) : List (Fin p) → W p
  | [] => []
  | i::xs => .fixed (pulse i (θ*2^xs.length)) :: pulses θ xs

private theorem pulses_eval {p} (data : Access→Matrix (Answers p) _ ℂ) (θ : ℝ) (xs : List (Fin p)) :
    run data (pulses θ xs)=Matrix.diagonal (fun x => rotor (θ*(thermalBitValue (xs.map x.2.1):ℝ))) := by
  induction xs with
  | nil => simp [pulses,run,thermalBitValue,rotor,Matrix.diagonal_one]
  | cons i xs ih =>
    simp only [pulses,run,matrix,ih,pulse,Matrix.diagonal_mul_diagonal]
    congr 1
    funext x
    cases h : x.2.1 i <;> simp [thermalBitValue,h,mul_add,rotor_add]

private theorem counts {p} (θ : ℝ) (xs : List (Fin p)) :
    fixedCount (pulses θ xs)=xs.length ∧ (∀ a,cost a (pulses θ xs)=0) ∧
    ∀ M, .fixed M∈pulses θ xs → OneWire p M := by
  induction xs with
  | nil => simp [pulses,fixedCount,cost]
  | cons i xs ih =>
    refine ⟨by simp [pulses,fixedCount,ih.1],by simp [pulses,cost,ih.2.1],?_⟩
    intro M hm
    rcases List.mem_cons.mp hm with eq | e
    · cases eq; exact .bit _ _
    · exact ih.2.2 _ e

def lookup {p} (re im : Reg p) : Equiv.Perm (Answers p) :=
  (Equiv.refl Bool).prodCongr ((xorWord re).prodCongr (xorWord im))

def inputs {p} (re im : Reg p) : Access → Matrix (Answers p) (Answers p) ℂ
  | .position => 1
  | .entry => permMatrix (lookup re im)

private theorem conjugate {I : Type} [Fintype I] [DecidableEq I] (e : Equiv.Perm I) (d:I→ℂ) :
    (permMatrix e)ᴴ*(Matrix.diagonal d*permMatrix e)=Matrix.diagonal (fun x => d (e x)) := by
  ext x y
  rw [Matrix.mul_apply,Fintype.sum_eq_single (e x)]
  · simp only [Matrix.conjTranspose_apply,Matrix.diagonal_mul,permMatrix,Matrix.of_apply,ite_true,star_one,
      one_mul,Matrix.diagonal_apply,Equiv.apply_eq_iff_eq,mul_ite,mul_one,mul_zero]
  · intro i hi
    simp only [Matrix.conjTranspose_apply,permMatrix,Matrix.of_apply,ite_eq_right hi,star_zero,zero_mul]

/-- Capacity of the scalar phase gate and the addressed bit gates: each
listed phase has unit modulus independently of its input bit. -/
theorem oneWire_unit {p : ℕ} {V : Matrix (Answers p) (Answers p) ℂ} (h : OneWire p V) :
    V∈Matrix.unitaryGroup _ ℂ := by
  cases h with
  | bit i θ =>
    apply diagonal_mem_unitaryGroup
    intro x; cases x.2.1 i <;> simp [rotor,Complex.norm_exp_ofReal_mul_I]
  | scalar θ => exact diagonal_mem_unitaryGroup _ (fun _ => Complex.norm_exp_ofReal_mul_I θ)

def zero (p : ℕ) : Answers p := (false,blank _,blank _)

/-- In dimension one, two ordinary XOR calls, p addressed phases and one
one-qubit global phase implement the scalar evolution exactly on the clean
answer register, with no position query. Multiplication by an arbitrary
input scalar is explicit, so the result covers every zero-qubit state. -/
theorem scalarEvolution (p : ℕ) (b t : ℝ) :
    ∃ program : W p, cost Access.position program=0 ∧ cost Access.entry program=2 ∧
      fixedCount program=p+1 ∧ (∀ M,.fixed M∈program → OneWire p M) ∧
      ∀ (re im : Reg p) (h : ℝ), (h:ℂ)=(b:ℂ)*Binary.signedValue re →
      ∀ z : ℂ, (run (inputs re im) program) *ᵥ (z • Qatlib.Foundations.PureStateMath.Ket (zero p)) =
        (Complex.exp (-Complex.I*(t:ℂ)*h)*z) • Qatlib.Foundations.PureStateMath.Ket (zero p) := by
  let θ : ℝ := -(t*b)*2/2^p
  let xs := List.finRange p
  let word : W p := .query .entry true :: .fixed (scalarGate p (t*b)) :: (pulses θ xs ++ [.query .entry false])
  obtain ⟨nc,nq,lc⟩ := counts θ xs
  refine ⟨word,by simp [word,cost,cost_append,nq],by simp [word,cost,cost_append,nq],?_,?_,?_⟩
  · simp [word,fixedCount,fixed_append,nc,xs]
  · intro M hm
    simp only [word,List.mem_cons,List.mem_append,List.not_mem_nil,or_false,false_or,reduceCtorEq] at hm
    rcases hm with head | mem
    · cases head; exact .scalar _
    · exact lc _ mem
  intro re im h val z
  let d := fun x : Answers p => rotor (t*b + θ*(thermalBitValue (xs.map x.2.1):ℝ))
  have eval : run (inputs re im) word=Matrix.diagonal (fun x => d (lookup re im x)) := by
    rw [← conjugate]
    simp only [word,run,matrix,inputs,run_append,pulses_eval,Matrix.mul_one,scalarGate]
    congr 1
    rw [←Matrix.mul_assoc,Matrix.diagonal_mul_diagonal]
    congr 2; funext x; exact (rotor_add _ _).symm
  have zeroCode : (lookup re im (zero p)).2.1=re := by funext i; simp [lookup,zero,blank,xorWord]
  have phase : d (lookup re im (zero p)) = Complex.exp (-Complex.I*(t:ℂ)*h) := by
    unfold d
    rw [zeroCode]
    have bits : xs.map re=List.ofFn re := by simp [xs,List.ofFn_eq_map]
    rw [bits]
    unfold rotor
    apply congrArg Complex.exp
    rw [val]
    unfold θ Binary.signedValue
    push_cast
    ring
  rw [eval,Matrix.mulVec_smul]
  ext x
  by_cases hx : x=zero p
  · subst x; simp [Matrix.mulVec_diagonal,Qatlib.Foundations.PureStateMath.Ket,phase,mul_comm]
  · simp [Matrix.mulVec_diagonal,Qatlib.Foundations.PureStateMath.Ket,hx]

end FQChemQatlib.Dynamics.LowChuang.SparseScalar
