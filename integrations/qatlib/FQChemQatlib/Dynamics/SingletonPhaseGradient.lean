module

public import Mathlib.Analysis.Complex.Trigonometric
public import Mathlib.LinearAlgebra.Matrix.Permutation
import Mathlib.Tactic

/-! # The modular carry in an ancilla-free controlled phase

On k controls and a target, use one target phase of angle θ/2ᵏ, apply the
control-dependent phase gradient, increment the controls, apply the opposite
gradient, then decrement the controls. Each gradient uses k ordinary controlled
phase gates. The two register permutations are named explicitly in the word.

The modular carry supplies the selective phase in [Gidney, §2.10 and Fig. 21](https://arxiv.org/abs/1706.07884). The two-wire controlled phase convention here is also described in [Huang and Palsberg, §4](https://doi.org/10.1145/3656436). See Gidney’s derivation in [Using Quantum Gates instead of Ancilla Bits](https://algassert.com/circuits/2015/06/22/Using-Quantum-Gates-instead-of-Ancilla-Bits.html).
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.SingletonPhaseGradient

/-- A little-endian addressed binary control register. -/
abbrev Bits (k : ℕ) := Fin k → Bool

def value : {k : ℕ} → Bits k → ℕ
  | 0,_ => 0
  | _+1,s => (s 0).toNat + 2*value (Fin.tail s)

def increment : {k : ℕ} → Bits k → Bits k
  | 0,s => s
  | _+1,s => Fin.cons (!(s 0)) (if s 0 then increment (Fin.tail s) else Fin.tail s)

def decrement : {k : ℕ} → Bits k → Bits k
  | 0,s => s
  | _+1,s => Fin.cons (!(s 0)) (if s 0 then Fin.tail s else decrement (Fin.tail s))

theorem decrement_increment {k} (s : Bits k) : decrement (increment s)=s := by
  induction k with
  | zero => rfl
  | succ k ih =>
    dsimp only [increment,decrement]
    cases h : s 0 <;> simp [ih] <;> funext i <;> exact Fin.cases (by simp [h]) (fun j => by simp [Fin.tail_def]) i

theorem value_lt {k} (s : Bits k) : value s < 2^k := by
  induction k with
  | zero => simp [value]
  | succ k ih => have := ih (Fin.tail s); cases h : s 0 <;> simp [value,h,pow_succ] <;> omega

/-- The only arithmetic discontinuity is overflow of the entire control word. -/
theorem incrementValue {k} (s : Bits k) :
    value (increment s) = if value s+1=2^k then 0 else value s+1 := by
  induction k with
  | zero => simp [value]
  | succ k ih =>
    have lt := value_lt (Fin.tail s)
    cases h : s 0 <;> simp only [increment,value,h,Bool.not_false,Bool.not_true,
      Bool.toNat_false,Bool.toNat_true,Fin.cons_zero,Fin.tail_cons,Bool.false_eq_true,ite_false,
      ite_true,pow_succ,zero_add,ih] <;> split_ifs <;> omega

theorem maximal {k} (s : Bits k) : value s+1=2^k ↔ ∀ i, s i=true := by
  induction k with
  | zero => simp [value]
  | succ k ih =>
    rw [Fin.forall_fin_succ]
    cases h : s 0 <;> simp only [value,h,Bool.toNat_false,Bool.toNat_true,zero_add,
      Bool.false_eq_true,false_and,true_and,pow_succ]
    · have ne (v d : ℕ) : 2*v+1≠d*2 := by omega
      exact iff_false_intro (ne _ _)
    · change 1+2*value (Fin.tail s)+1=2^k*2 ↔ ∀ i, Fin.tail s i=true
      rw [← ih]; omega

abbrev Basis (k : ℕ) := Bits k × Bool

/-- Phase gates act on one addressed target or on that target together with
one addressed control. Increment/decrement operate on the control register. -/
inductive Gate (k : ℕ)
  | phase (control : Option (Fin k)) (angle : ℝ)
  | inc | dec

def phase (θ : ℝ) := Complex.exp ((θ:ℂ)*Complex.I)

theorem phase_add (α β : ℝ) : phase (α+β)=phase α*phase β := by
  simp [phase,add_mul,Complex.exp_add]

def acts {k} : Gate k → Basis k → ℝ × Basis k
  | .phase c θ,(s,b) => (if b && c.elim true s then θ else 0,(s,b))
  | .inc,(s,b) => (0,increment s,b)
  | .dec,(s,b) => (0,decrement s,b)

def run {k} : List (Gate k) → Basis k → ℝ × Basis k
  | [],s => (0,s)
  | g::gs,s => let (a,t) := acts g s; let (b,v) := run gs t; (a+b,v)

/-- The column of the unitary word, including its relative complex phase. -/
def matrix {k} (gs : List (Gate k)) : Matrix (Basis k) (Basis k) ℂ :=
  fun i j => if (run gs j).2=i then phase (run gs j).1 else 0

theorem run_append {k} (a b : List (Gate k)) (s : Basis k) :
    run (a++b) s = ((run a s).1+(run b (run a s).2).1,(run b (run a s).2).2) := by
  induction a generalizing s with
  | nil => simp [run]
  | cons g gs ih => simp only [List.cons_append,run,ih,add_assoc]

def gradient {k} (cs : List (Fin k)) (step : ℝ) : List (Gate k) :=
  match cs with
  | [] => []
  | c::rest => .phase (some c) step :: gradient rest (2*step)

def digitValue {k} (s : Bits k) : List (Fin k) → ℕ
  | [] => 0
  | c::rest => (s c).toNat+2*digitValue s rest

theorem digitValue_full {k} (s : Bits k) : digitValue s (List.finRange k)=value s := by
  have map {l j} (f : Fin l → Fin j) (v : Bits j) (cs : List (Fin l)) :
      digitValue v (cs.map f)=digitValue (v ∘ f) cs := by
    induction cs <;> simp_all [digitValue]
  induction k with
  | zero => simp [value,digitValue]
  | succ k ih => simp only [List.finRange_succ, digitValue,map,value,ih]; rfl

theorem runGradient {k} (s : Bits k) (b : Bool) (cs : List (Fin k)) (step : ℝ) :
    run (gradient cs step) (s,b) = (if b then digitValue s cs*step else 0,(s,b)) := by
  induction cs generalizing step with
  | nil => simp [gradient,run,digitValue]
  | cons c cs ih => cases b <;> cases h : s c <;> simp [gradient,run,acts,h,ih,digitValue] <;> ring

def word (k : ℕ) (θ : ℝ) : List (Gate k) :=
  let t := θ/(2:ℝ)^k
  [.phase none t] ++ gradient (List.finRange k) t ++ [.inc] ++ gradient (List.finRange k) (-t) ++ [.dec]

/-- The target is returned exactly on each input and receives phase angle θ
just when the target and every control are on. -/
theorem runWord {k} (θ : ℝ) (s : Bits k) (b : Bool) :
    run (word k θ) (s,b) = (if b=true ∧ ∀ i, s i=true then θ else 0,(s,b)) := by
  have eq := incrementValue s
  simp only [word,run_append,run,acts,Option.elim_none,Bool.and_true,runGradient,
    digitValue_full,decrement_increment,add_zero]
  by_cases high : value s+1=2^k
  · rw [ite_eq_left high] at eq
    have all := (maximal s).mp high
    have realEq : (value s:ℝ)+1=2^k := by exact_mod_cast high
    cases b <;> simp [eq,all]
    field_simp
    nlinarith only [congrArg (· * θ) realEq]
  · rw [ite_eq_right high] at eq
    have no := mt (maximal s).mpr high
    cases b <;> simp [eq,no]; ring

theorem matrixWord {k} (θ : ℝ) :
    matrix (word k θ) = Matrix.diagonal (fun v => if v.2=true ∧ ∀ i,v.1 i=true then phase θ else 1) := by
  ext i j
  obtain ⟨s,b⟩ := j
  simp only [matrix,runWord,Matrix.diagonal_apply]
  split_ifs <;> simp_all [phase]

/-- Charging the two opposite register permutations separately isolates the
exact synthesis cost. Every other instruction is a one- or two-qubit phase. -/
def cost {k} (incrementCost : ℕ) (g : Gate k) : ℕ :=
  match g with | .phase .. => 1 | .inc | .dec => incrementCost

theorem gradientCost {k} (cs : List (Fin k)) (step : ℝ) (c : ℕ) :
    ((gradient cs step).map (cost c)).sum = cs.length := by
  induction cs generalizing step <;> simp_all [gradient,cost,add_comm]

theorem wordCost (k : ℕ) (θ : ℝ) (c : ℕ) :
    ((word k θ).map (cost c)).sum = 2*c+2*k+1 := by
  simp [word,cost,gradientCost]; omega

end FQChemQatlib.Dynamics.SingletonPhaseGradient
