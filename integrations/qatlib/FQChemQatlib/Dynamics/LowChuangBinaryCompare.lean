module

public import FQChemQatlib.Dynamics.BorrowedControls
public import Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermal.FiniteThermalComparator
public import Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermal.FiniteThermalUniformH

/-! # A linear-size coherent comparator for two binary registers -/

@[expose] public section
namespace FQChemQatlib.Dynamics.LowChuang.Binary

open FQChemQatlib.Dynamics.BorrowedControls
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open Qatlib.Foundations.PureStateMath

variable {n : ℕ}

structure Digit (n : ℕ) where
  left : Fin n
  right : Fin n
  output : Fin n

def carry (x y c : Bool) : Bool := ((!x && y) ^^ (!x && c)) ^^ (y && c)

private theorem carry_order (x y c : Bool) : carry x y c =
    ((!x && y) || ((x == y) && c)) := by cases x <;> cases y <;> cases c <;> decide

def updateDigit (d : Digit n) (input : Fin n) (s : Reg n) : Reg n :=
  BorrowedControls.flip d.output (carry (s d.left) (s d.right) (s input)) s

private theorem step_exact (d : Digit n) (c : Fin n) (distinct : [d.left,d.right,c,d.output].Nodup) :
    Implements (updateDigit d c) 47 := by
  obtain ⟨x,y,t⟩ := d
  simp only [List.nodup_cons,List.mem_cons,List.not_mem_nil,or_false,not_or,List.nodup_nil,and_true] at distinct
  obtain ⟨⟨hxy,hxc,hxt⟩,⟨hyc,hyt⟩,hct,_⟩ := distinct
  have gates := compose (compose (compose (compose (bit x) (toff x y t hxy hxt hyt))
    (toff x c t hxc hxt hct)) (bit x)) (toff y c t hyc hyt hct)
  convert gates using 1
  funext s i
  by_cases hi : i=t <;> by_cases hx : i=x <;>
    simp_all [Function.comp_def,updateDigit,BorrowedControls.flip,carry,Ne.symm]

def result (seed : Fin n) : List (Digit n) → Fin n
  | [] => seed
  | d::_ => d.output

def compute (seed : Fin n) : List (Digit n) → Reg n → Reg n
  | [],s => s
  | d::ds,s => updateDigit d (result seed ds) (compute seed ds s)

def addresses (ds : List (Digit n)) := ds.flatMap fun d => [d.left,d.right,d.output]
def valid (seed : Fin n) (ds : List (Digit n)) := (seed::addresses ds).Nodup

private theorem address_mem (d : Digit n) (ds : List (Digit n)) :
    addresses (d::ds) = d.left::d.right::d.output::addresses ds := rfl

private theorem result_address (seed : Fin n) (ds : List (Digit n)) :
    result seed ds ∈ seed::addresses ds := by
  cases ds <;> simp [result,addresses]

private theorem tail_valid {seed : Fin n} {d : Digit n} {ds} (h : valid seed (d::ds)) :
    valid seed ds := by
  simp only [valid,address_mem,List.nodup_cons,List.mem_cons,not_or] at *
  tauto

private theorem step_valid {seed : Fin n} {d : Digit n} {ds} (h : valid seed (d::ds)) :
    [d.left,d.right,result seed ds,d.output].Nodup := by
  have m := result_address seed ds
  simp only [valid,address_mem,List.nodup_cons,List.mem_cons,List.not_mem_nil,or_false,
    List.nodup_nil,and_true,not_or] at *
  grind

theorem unchanged (seed : Fin n) (ds : List (Digit n)) (s : Reg n) (i : Fin n)
    (unused : i ∉ ds.map Digit.output) : compute seed ds s i = s i := by
  induction ds with
  | nil => rfl
  | cons d ds ih =>
    simp only [List.map_cons,List.mem_cons,not_or] at unused
    simp [compute,updateDigit,BorrowedControls.flip,Function.update_of_ne unused.1,ih unused.2]

/-- The list is in most-significant-bit order. The ripple propagates from the
least significant end. Its action is exact on arbitrary initial carry bits. -/
theorem ripple_word (seed : Fin n) (ds : List (Digit n)) (h : valid seed ds) :
    Implements (compute seed ds) (47*ds.length) := by
  induction ds with
  | nil =>
    exact ⟨[],by simp, rfl,fun _ => rfl⟩
  | cons d ds ih =>
    have word := compose (ih (tail_valid h)) (step_exact d (result seed ds) (step_valid h))
    change Implements (updateDigit d (result seed ds) ∘ compute seed ds) _
    simpa only [List.length_cons,Nat.mul_add,Nat.mul_one] using word

private theorem output_address {x : Fin n} {ds : List (Digit n)} (m : x∈ds.map Digit.output) :
    x∈addresses ds := by
  obtain ⟨d,hd,rfl⟩ := List.mem_map.mp m
  exact List.mem_flatMap.mpr ⟨d,hd,by simp⟩

/-- Clean seed and carry bits make the final output the strict numerical
less-than test. The data registers may hold any pair of bit strings. -/
theorem ripple_result (seed : Fin n) (ds : List (Digit n)) (h : valid seed ds)
    (s : Reg n) (init : s seed=false) (clean : ∀ d∈ds,s d.output=false) :
    compute seed ds s (result seed ds) =
    decide (thermalBitValue (ds.map fun d => s d.left) < thermalBitValue (ds.map fun d => s d.right)) := by
  rw [← thermalLexLess_numeric _ _ (by simp)]
  induction ds with
  | nil => exact init
  | cons d ds ih =>
    have r := ih (tail_valid h) (fun v hv => clean v (by simp [hv]))
    have fresh := h
    simp only [valid,address_mem,List.nodup_cons,List.mem_cons,not_or] at fresh
    have out : ∀ x, x∉addresses ds → compute seed ds s x=s x :=
      fun x hx => unchanged _ _ _ _ (fun m => hx (output_address m))
    have hl := out d.left (by tauto)
    have hr := out d.right (by tauto)
    have ho := out d.output (by tauto)
    simp only [compute,result,updateDigit,BorrowedControls.flip,Function.update_self,hl,hr,ho,
      clean d (by simp),Bool.false_xor,List.map_cons,thermalLexLess,carry_order]
    cases s d.left <;> cases s d.right <;> simp <;> exact r

end FQChemQatlib.Dynamics.LowChuang.Binary
