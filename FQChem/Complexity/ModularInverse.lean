module

public import FQChem.Complexity.OrderFindingBitCost
public import FQChem.Complexity.OrderFindingPostprocessing
import Mathlib.Tactic

/-! # A bounded-width modular inverse for Shor's circuit generator

Each Euclidean remainder carries its coefficient of the input base modulo
the modulus. Reducing these coefficients after every update keeps them in
one word. All arithmetic uses the Boolean gates counted by OrderFindingBitCost.
-/

@[expose] public section
namespace FQChem.Complexity.ModularInverse
open OrderFindingBitCost OrderFindingPostprocessing

/-- Compute u − p modulo N. One spare bit suffices for the intermediate u + N. -/
def subtractMod (w N u p : ℕ) : ℕ × ℕ :=
  let sum := ripple false (w+1) u N false
  let diff := ripple true (w+1) sum.word p true
  let d := divide (w+1) (w+1) diff.word N
  (d.rem, sum.gates + diff.gates + d.gates)

theorem subtractMod_spec (w N u p : ℕ) (hN : 0 < N) (hw : N < 2^w)
    (hu : u < N) (hp : p < N) :
    (subtractMod w N u p).1 = (u + N - p) % N ∧
      (subtractMod w N u p).2 ≤ 22*(w+1)^2 := by
  have wide : 2^(w+1) = 2^w*2 := pow_succ ..
  have ⟨_,sg,sc⟩ := ripple_spec false (w+1) u N false (by omega) (by omega)
  simp only [Bool.false_eq_true, ite_false, Bool.toNat_false, Nat.add_zero] at sc
  have sval : (ripple false (w+1) u N false).word = u+N := by
    cases h : (ripple false (w+1) u N false).carry <;> simp [h] at sc <;> omega
  have ⟨db,dg,dc⟩ := ripple_spec true (w+1) (u+N) p true (by omega) (by omega)
  simp only [ite_true, Bool.toNat_true] at dc
  have dval : (ripple true (w+1) (u+N) p true).word = u+N-p := by
    cases h : (ripple true (w+1) (u+N) p true).carry <;> simp [h] at dc <;> omega
  have div := divide_spec (w+1) (w+1) (u+N-p) N (by omega) hN (by omega)
  simp only [subtractMod, sval, dval, div, sg, dg, true_and]
  nlinarith

/-- Each Euclidean quotient q sends the coefficient pair (u,v) to (v,u−qv mod N).
Fuel is an upper bound on the number of divisions. -/
def run (w N : ℕ) : ℕ → ℕ → ℕ → ℕ → ℕ → ℕ × ℕ
  | 0, _, _, u, _ => (u, 0)
  | t+1, x, y, u, v =>
    let zero := equalWord w y 0
    if zero.1 then (u, zero.2) else
      let div := divide (w+1) w x y
      let prod := productMod w N div.quot v
      let sub := subtractMod w N u prod.1
      let next := run w N t y div.rem v sub.1
      (next.1, zero.2 + div.gates + prod.2 + sub.2 + next.2)

private theorem remainderCoefficient (N a x y u v : ℕ) (hN : 0 < N)
    (hx : (a : ZMod N)*u = x) (hy : (a : ZMod N)*v = y) :
    (a : ZMod N)*(((u+N-((x/y)*v)%N)%N : ℕ) : ZMod N) = (x%y : ℕ) := by
  have hp := Nat.mod_lt ((x/y)*v) hN
  have rem := congrArg (fun n : ℕ => (n : ZMod N)) (Nat.div_add_mod' x y)
  simp only [Nat.cast_add, Nat.cast_mul] at rem
  rw [ZMod.natCast_mod, Nat.cast_sub (by omega), Nat.cast_add, ZMod.natCast_mod, Nat.cast_mul]
  simp only [ZMod.natCast_self, add_zero]
  linear_combination hx - (↑(x/y) : ZMod N)*hy - rem

private theorem run_spec (w N a t x y u v : ℕ) (hN : 0 < N) (hw : N < 2^w)
    (hx : x < 2^w) (hy : y < 2^w) (hu : u < N) (hv : v < N)
    (huv : (a : ZMod N)*u = x) (hvv : (a : ZMod N)*v = y) (ht : divisions x y ≤ t) :
    let out := run w N t x y u v
    out.1 < N ∧ (a : ZMod N)*out.1 = x.gcd y ∧ out.2 ≤ t*(150*(w+1)^2) := by
  induction t generalizing x y u v with
  | zero =>
    have hz : y=0 := by
      by_contra h
      rw [divisions,dite_eq_right h] at ht
      omega
    subst y
    simpa [run] using And.intro hu huv
  | succ t ih =>
    rw [run, equal_spec w y 0 hy (by positivity)]
    by_cases hz : y=0
    · subst y
      simp only [decide_true, ite_true, Nat.gcd_zero_right]
      exact ⟨hu,huv,by nlinarith⟩
    · have d := divide_spec (w+1) w x y hx (by omega) (by rw [pow_succ]; omega)
      have q := productMod_spec w N (x/y) v ((Nat.div_le_self ..).trans_lt hx) (hv.trans hw) hN hw
      have sub := subtractMod_spec w N u ((x/y)*v%N) hN hw hu (Nat.mod_lt _ hN)
      have hr := remainderCoefficient N a x y u v hN huv hvv
      rw [divisions,dite_eq_right hz] at ht
      have tail :=  ih y (x%y) v ((u+N-((x/y)*v)%N)%N) hy ((Nat.mod_lt _ (by omega)).trans hy)
        hv (Nat.mod_lt _ hN) hvv hr (by omega)
      simp only [hz, decide_false, Bool.false_eq_true, ite_false, d, q.1, sub.1]
      refine ⟨tail.1, ?_, ?_⟩
      · rw [tail.2.1, Nat.gcd_comm y (x%y), ← Nat.gcd_rec y x, Nat.gcd_comm]
      · nlinarith [tail.2.2, q.2, sub.2]

/-- Return the reduced inverse and Boolean data-path gate count, starting with
the remainder/coefficient pairs (N,0) and (a,1). -/
def inverse (w N a : ℕ) : ℕ × ℕ := run w N (2*w) N a 0 1

/-- For a w-bit modulus and a coprime reduced base, the output represents
the multiplicative inverse. The total arithmetic cost is cubic in w. -/
theorem inverse_spec (w N a : ℕ) (hN : 1 < N) (hw : N < 2^w) (ha : a < N) (hc : a.Coprime N) :
    (inverse w N a).1 < N ∧ (a * (inverse w N a).1) % N = 1 ∧
      (inverse w N a).2 ≤ 300 * (w+1)^3 := by
  have res := run_spec w N a (2*w) N a 0 1 (by omega) hw hw (ha.trans hw)
    (by omega) hN (by simp) (by simp) (divisions_bound w N a (ha.trans hw))
  change (inverse w N a).1 < N ∧ (a : ZMod N)*(inverse w N a).1 = N.gcd a ∧
    (inverse w N a).2 ≤ _ at res
  have g : N.gcd a = 1 := hc.symm
  have eq : ((a*(inverse w N a).1 : ℕ) : ZMod N) = ((1 : ℕ) : ZMod N) := by
    rw [Nat.cast_mul, res.2.1, g]
  have inv := (ZMod.natCast_eq_natCast_iff' ..).mp eq
  exact ⟨res.1,by simpa [Nat.mod_eq_of_lt hN] using inv,by nlinarith [res.2.2]⟩

end FQChem.Complexity.ModularInverse
