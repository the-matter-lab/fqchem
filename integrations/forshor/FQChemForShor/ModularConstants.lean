import FQChem.Complexity.ModularInverse
import ForShor.ShorVerification.Implementation.ModularExponentiation.Statement

/-! # Computing the constants of Shor's modular exponentiation circuit

Shor §3 generates controlled multipliers by repeated squaring modulo the input
modulus. The reference circuit also uses the inverse residue for its cleanup
step. Squaring the multiplier and its inverse together gives both constants
for every control in one pass over the clock register. -/

namespace FQChem.Complexity.ModularConstants
open OrderFindingBitCost Shor

private theorem cleanup_constant {c v N : ℕ} (hv : v < N)
    (hinv : (c*v)%N = 1) : (1+N-v)%N = step5Constant c N := by
  have existsInv : ∃ x : ℕ, x < N ∧ (c*x)%N = 1 := ⟨v,hv,hinv⟩
  let t := Nat.find existsInv
  obtain ⟨ht, hi⟩ : t < N ∧ (c*t)%N = 1 := Nat.find_spec existsInv
  have one {x : ℕ} (h : (c*x)%N = 1) : (c : ZMod N)*x = 1 := by
    simpa only [ZMod.natCast_mod, Nat.cast_mul, Nat.cast_one] using
      congrArg (fun k : ℕ => (k : ZMod N)) h
  have eqmod : (v : ZMod N) = (t : ZMod N) := calc
    (v : ZMod N) = v * (c*t) := by rw [one hi, mul_one]
    _ = (c*v)*t := by ring
    _ = t := by rw [one hinv, one_mul]
  have eq := (ZMod.natCast_eq_natCast_iff v t N).mp eqmod |>.eq_of_lt_of_lt hv ht
  rw [step5Constant, dite_eq_left existsInv, eq]

/-- The five reference steps, with both integer constants supplied explicitly. -/
def multiplier (c k N ctrl : ℕ) (data work scratch : ExtReg) (flag : ℕ)
    (hw : ModMulCircuitWorkspaceOK data work)
    (hc : CmpLtNWWorkspace N (data.grow 1) work scratch flag) : Gate :=
  .seq (step1 c N ctrl data work hw)
    (.seq (step2 N data work hw)
      (.seq (step3 N (data.grow 1) scratch flag)
        (.seq (step4 N (data.grow 1) work scratch flag hc) (step5 k N ctrl data work hw))))

/-- Emit a controlled multiplier per wire, from its reduced residue and inverse.
The counter charges the Boolean operations that produce its integer constants. -/
def steps (w N : ℕ) (data work scratch : ExtReg) (flag : ℕ)
    (hw : ModMulCircuitWorkspaceOK data work)
    (hc : CmpLtNWWorkspace N (data.grow 1) work scratch flag) :
    ℕ → ℕ → List ℕ → Gate × ℕ
  | _, _, [] => (.id, 0)
  | c, v, ctrl :: cs =>
    let k := ModularInverse.subtractMod w N 1 v
    let c' := productMod w N c c
    let v' := productMod w N v v
    let tail := steps w N data work scratch flag hw hc c'.1 v'.1 cs
    (.seq (multiplier c k.1 N ctrl data work scratch flag hw hc) tail.1,
      k.2 + c'.2 + v'.2 + tail.2)

private theorem steps_spec (w N a : ℕ) (data work scratch : ExtReg) (flag : ℕ)
    (hw : ModMulCircuitWorkspaceOK data work)
    (hc : CmpLtNWWorkspace N (data.grow 1) work scratch flag)
    (hN : 1<N) (hW : N < 2^w) (cs : List ℕ) (e c v : ℕ)
    (hcval : c = a^(2^e)%N) (hv : v < N) (hinv : (c*v)%N = 1) :
    let out := steps w N data work scratch flag hw hc c v cs
    out.1 = modExpApproxStepsValid a N data work scratch flag hw hc e cs ∧
      out.2 ≤ cs.length * (162*(w+1)^2) := by
  induction cs generalizing e c v with
  | nil => simp [steps, modExpApproxStepsValid]
  | cons ctrl cs ih =>
    have hpos : 0<N := by omega
    have csmall : c < N := hcval ▸ Nat.mod_lt _ hpos
    have C := productMod_spec w N c c (csmall.trans hW) (csmall.trans hW) hpos hW
    have V := productMod_spec w N v v (hv.trans hW) (hv.trans hW) hpos hW
    have K := ModularInverse.subtractMod_spec w N 1 v hpos hW hN hv
    have next : (c*c)%N = a^(2^(e+1))%N := by
      rw [hcval, pow_succ 2 e, pow_mul, sq]; simp
    have both : ((c*c%N)*(v*v%N))%N = 1 := by
      rw [Nat.mod_mul_mod, Nat.mul_mod_mod, show c*c*(v*v) = (c*v)*(c*v) by ring,
        Nat.mul_mod, hinv, one_mul, Nat.mod_eq_of_lt hN]
    have rest := ih (e+1) (c*c%N) (v*v%N) next (Nat.mod_lt _ hpos) both
    dsimp only at rest ⊢
    rw [steps, modExpApproxStepsValid]
    simp only [C.1, V.1, K.1, cleanup_constant hv hinv, rest.1, List.length_cons]
    constructor
    · rw [← hcval]; rfl
    · rw [Nat.succ_mul]
      omega

/-- Build the modular-exponentiation stage starting from the two input
integers. The inverse of the base is computed just once. -/
def compile (a N : ℕ) (x : Reg) (data work scratch : ExtReg) (flag : ℕ)
    (hw : ModMulCircuitWorkspaceOK data work)
    (hc : CmpLtNWWorkspace N (data.grow 1) work scratch flag) : Gate × ℕ :=
  let width := N.log2 + 1
  let inv := ModularInverse.inverse width N a
  let circuit := steps width N data work scratch flag hw hc a inv.1 x.qubits
  (circuit.1, inv.2 + circuit.2)

/-- At the compiled Shor clock width, the generator emits literally the
reference modular-exponentiation gate tree. Producing *all multiplier and
cleanup constants* takes at most 624 (w+1)³ Boolean gates for w input bits.
This counts the integer arithmetic before the subsequent lowering of gates. -/
theorem compile_constants (a N : ℕ) (x : Reg) (data work scratch : ExtReg) (flag : ℕ)
    (hw : ModMulCircuitWorkspaceOK data work)
    (hc : CmpLtNWWorkspace N (data.grow 1) work scratch flag)
    (hN : 1<N) (ha : a<N) (coprime : a.Coprime N)
    (clock : regSize x = (2*N^2).log2) :
    let out := compile a N x data work scratch flag hw hc
    out.1 = modExpApproxValid a N x data work scratch flag hw hc ∧
      out.2 ≤ 624 * (N.log2+2)^3 := by
  let w := N.log2+1
  have width : N < 2^w := Nat.lt_log2_self
  have inv := ModularInverse.inverse_spec w N a hN width ha coprime
  have S := steps_spec w N a data work scratch flag hw hc hN width x.qubits 0 a
    (ModularInverse.inverse w N a).1 (by simp [Nat.mod_eq_of_lt ha]) inv.1 inv.2.1
  have sqBound : 2*N^2 < 2^(2*w+1) := by
    have sqLt := Nat.pow_lt_pow_left width (by decide : 2 ≠ 0)
    rw [pow_succ 2 (2*w), pow_mul' 2 2 w]
    nlinarith
  have len : x.qubits.length ≤ 2*w := by
    change regSize x ≤ _
    rw [clock]
    have := (Nat.log2_lt (by positivity : 2*N^2 ≠ 0)).mpr sqBound
    omega
  refine ⟨S.1, (Nat.add_le_add inv.2.2 S.2).trans ?_⟩
  calc
    _ ≤ 300*(w+1)^3 + 2*w*(162*(w+1)^2) := by gcongr
    _ ≤ 624*(w+1)^3 := by nlinarith

end FQChem.Complexity.ModularConstants
