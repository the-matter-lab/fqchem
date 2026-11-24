module

public import FQChemQatlib.Dynamics.LowChuangSimulation

/-! # Substituting named physical oracles in a controlled simulation word -/

@[expose] public section

namespace FQChemQatlib.Dynamics.LowChuang.Query

open Matrix
open Qatlib.Concepts.CoherentSim.CoherentOAA Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.BlockEncoding.LCU

/-- The fixed matrix is independent of the oracle table supplied when the word
runs. A query names one of the physical oracles and its direction. -/
inductive Step (J K : Type) where
  | fixed (V : Matrix J J ℂ)
  | query (k : K) (adjoint : Bool)

variable {J K : Type} [Fintype J] [DecidableEq J]

def matrix (data : K → Matrix J J ℂ) : Step J K → Matrix J J ℂ
  | .fixed V => V
  | .query k false => data k
  | .query k true => (data k)ᴴ

noncomputable def run (data : K → Matrix J J ℂ) : List (Step J K) → Matrix J J ℂ
  | [] => 1
  | g :: gs => matrix data g * run data gs

def cost [DecidableEq K] (k : K) : List (Step J K) → ℕ
  | [] => 0
  | .fixed _ :: gs => cost k gs
  | .query j _ :: gs => (if j=k then 1 else 0) + cost k gs

def adjoint : Step J K → Step J K
  | .fixed V => .fixed Vᴴ
  | .query k b => .query k (!b)

def inverse (program : List (Step J K)) := (program.map adjoint).reverse

theorem run_append (data : K → Matrix J J ℂ) (a b : List (Step J K)) :
    run data (a++b) = run data a * run data b := by
  induction a with
  | nil => simp [run]
  | cons g gs ih => simp [run,ih,Matrix.mul_assoc]

omit [Fintype J] [DecidableEq J] in
theorem cost_append [DecidableEq K] (k : K) (a b : List (Step J K)) :
    cost k (a++b) = cost k a + cost k b := by
  induction a with
  | nil => simp [cost]
  | cons g gs ih => cases g <;> simp [cost,ih,Nat.add_assoc]

theorem run_inverse (data : K → Matrix J J ℂ) (program : List (Step J K)) :
    run data (inverse program) = (run data program)ᴴ := by
  induction program with
  | nil => simp [inverse,run]
  | cons g gs ih =>
    have eq : inverse (g::gs) = inverse gs ++ [adjoint g] := by simp [inverse]
    rw [eq,run_append,ih]
    simp only [run,Matrix.conjTranspose_mul,Matrix.mul_one]
    cases g with
    | fixed => simp [matrix,adjoint]
    | query k b => cases b <;> simp [matrix,adjoint]

omit [Fintype J] [DecidableEq J] in
theorem cost_inverse [DecidableEq K] (k : K) (program : List (Step J K)) :
    cost k (inverse program) = cost k program := by
  induction program with
  | nil => rfl
  | cons g gs ih =>
    have eq : inverse (g::gs) = inverse gs ++ [adjoint g] := by simp [inverse]
    rw [eq,cost_append,ih]
    cases g <;> simp [adjoint,cost,Nat.add_comm]

noncomputable abbrev lifted (V : Matrix J J ℂ) := controlOracle (parallelOracle (J := Bool) V)

theorem lift_mul (U V : Matrix J J ℂ) : lifted (U*V) = lifted U * lifted V := by
  rw [lifted,lifted,lifted,controlOracle_mul]
  congr 1
  exact (parallel_select_mul (fun _ : Bool => U) (fun _ => V)).symm

omit [Fintype J] in
theorem lift_adjoint (U : Matrix J J ℂ) : lifted Uᴴ = (lifted U)ᴴ := by
  rw [lifted,lifted,controlOracle_adjoint,parallelOracle_adjoint]

/-- Apply an ordinary oracle to its own registers with both signal qubits
untouched. Such a call needs no controlled version of a sparse-input oracle. -/
noncomputable abbrev broadcast (V : Matrix J J ℂ) :=
  parallelOracle (J := Bool) (parallelOracle (J := Bool) V)

omit [DecidableEq J] in
theorem broadcast_mul (U V : Matrix J J ℂ) : broadcast (U*V) = broadcast U * broadcast V := by
  simp only [broadcast,parallelOracle,parallel_select_mul]

omit [Fintype J] [DecidableEq J] in
theorem broadcast_adjoint (U : Matrix J J ℂ) : broadcast Uᴴ = (broadcast U)ᴴ := by
  simp only [broadcast,parallelOracle_adjoint]

/-- Controlling a whole compute/body/uncompute sandwich only requires
controlling the middle operation. Both calls to the computation are ordinary
calls even if its unitary is unknown. -/
theorem lift_conjugate (U V : Matrix J J ℂ) (unit : U ∈ Matrix.unitaryGroup J ℂ) :
    lifted (Uᴴ*V*U) = (broadcast U)ᴴ * lifted V * broadcast U := by
  have hu : Uᴴ*U=1 := (Matrix.mem_unitaryGroup_iff').mp unit
  simp only [lifted,broadcast,controlOracle,parallelOracle,parallel_select_adjoint,parallel_select_mul]
  congr 1
  funext b
  cases b
  · simp [parallel_select_one,parallel_select_mul,hu]
  · simp [parallel_select_mul]

noncomputable def controlled : Step J K → Step (Bool × (Bool × J)) K
  | .fixed V => .fixed (lifted V)
  | .query k b => .query k b

theorem run_controlled (data : K → Matrix J J ℂ) (program : List (Step J K)) :
    run (fun k => lifted (data k)) (program.map controlled) = lifted (run data program) := by
  induction program with
  | nil =>
    change 1 = controlOracle (parallelOracle (J := Bool) (1 : Matrix J J ℂ))
    rw [parallelOracle,parallel_select_one,controlOracle_one]
  | cons g gs ih =>
    simp only [List.map_cons,run,lift_mul,ih]
    congr 1
    cases g with
    | fixed => rfl
    | query k b => cases b <;> simp [matrix,controlled,lift_adjoint]

omit [Fintype J] in
private theorem cost_controlled [DecidableEq K] (k : K) (program : List (Step J K)) :
    cost k (program.map controlled) = cost k program := by
  induction program with
  | nil => rfl
  | cons g gs ih => cases g <;> simp [controlled,cost,ih]

def substitute (body : List (Step J K)) : List (AdjointStep J) → List (Step J K)
  | [] => []
  | .gate V :: rest => .fixed V :: substitute body rest
  | .forward :: rest => body ++ substitute body rest
  | .backward :: rest => inverse body ++ substitute body rest

omit [Fintype J] [DecidableEq J] in
theorem covers_substitute {p : Matrix J J ℂ → Prop} {body : List (Step J K)} {word}
    (cov : Covered p word) (hw : ∀ V, Step.fixed V ∈ body → p V)
    (ha : ∀ V, Step.fixed V ∈ inverse body → p V) :
    ∀ V, Step.fixed V ∈ substitute body word → p V := by
  induction word with
  | nil => simp [substitute]
  | cons s ss ih =>
    have tail := ih (fun M h => cov M (List.mem_cons_of_mem _ h))
    intro V h
    cases s with
    | gate M =>
      rcases List.mem_cons.mp h with eq | h
      · exact (Step.fixed.inj eq) ▸ cov M (by simp)
      · exact tail V h
    | forward => exact (List.mem_append.mp h).elim (hw V) (tail V)
    | backward => exact (List.mem_append.mp h).elim (ha V) (tail V)

theorem run_substitute (data : K → Matrix J J ℂ) (body : List (Step J K)) (word : List (AdjointStep J)) :
    run data (substitute body word) = evaluate (run data body) word := by
  induction word with
  | nil => rfl
  | cons c cs ih => cases c <;> simp [substitute,run_append,run_inverse,run,evaluate,instructionMatrix,matrix,ih]

omit [Fintype J] [DecidableEq J] in
theorem cost_substitute [DecidableEq K] (k : K) (body : List (Step J K)) (word : List (AdjointStep J)) :
    cost k (substitute body word) = cost k body * adjointQueryCount word := by
  induction word with
  | nil => simp [substitute,cost,adjointQueryCount]
  | cons c cs ih => cases c <;> simp [substitute,cost_append,cost_inverse,cost,adjointQueryCount,ih,Nat.mul_add,Nat.add_comm]

def fixedCount : List (Step J K) → ℕ
  | [] => 0
  | .fixed _ :: gs => fixedCount gs + 1
  | .query _ _ :: gs => fixedCount gs

omit [Fintype J] [DecidableEq J] in
theorem fixed_append (a b : List (Step J K)) : fixedCount (a++b) = fixedCount a + fixedCount b := by
  induction a with
  | nil => simp [fixedCount]
  | cons g gs ih => cases g <;> simp [fixedCount,ih]; omega

omit [Fintype J] [DecidableEq J] in
private theorem fixed_inverse (body : List (Step J K)) : fixedCount (inverse body) = fixedCount body := by
  induction body with
  | nil => rfl
  | cons g gs ih =>
    have eq : inverse (g::gs) = inverse gs ++ [adjoint g] := by simp [inverse]
    rw [eq,fixed_append,ih]
    cases g <;> rfl

omit [Fintype J] [DecidableEq J] in
theorem fixed_substitute (body : List (Step J K)) (word : List (AdjointStep J)) :
    fixedCount (substitute body word) = adjointGateCount word + fixedCount body * adjointQueryCount word := by
  induction word with
  | nil => simp [substitute,fixedCount,adjointGateCount,adjointQueryCount]
  | cons c cs ih => cases c <;> simp [substitute,fixed_append,fixed_inverse,fixedCount,adjointQueryCount,
      adjointGateCount,Nat.mul_add,ih] <;> omega

/-- Replace every controlled block-encoding query by a fixed list of controlled
primitive oracles. Its exact matrix and per-oracle count are preserved. -/
theorem controlledSubstitution [DecidableEq K] (body : List (Step J K))
    (word : List (AdjointStep (Bool × (Bool × J)))) :
    let program := substitute (body.map controlled) word
    (∀ data, run (fun k => lifted (data k)) program = evaluate (lifted (run data body)) word) ∧
    (∀ k, cost k program = cost k body * adjointQueryCount word) := by
  exact ⟨fun data => by rw [run_substitute,run_controlled],
    fun k => by rw [cost_substitute,cost_controlled]⟩

end FQChemQatlib.Dynamics.LowChuang.Query
