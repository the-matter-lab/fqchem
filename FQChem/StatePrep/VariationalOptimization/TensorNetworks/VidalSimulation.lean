module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.RoutedSimulation
public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.SingleSiteGates
public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitMeasurement

/-! # Classical simulation of a slightly entangled quantum computation

[Vidal, Theorem 1](https://doi.org/10.1103/PhysRevLett.91.147902).
The classical simulator returns an exact product-observable expectation. Work is
counted in field operations, conjugations and zero tests, and space in scalar
coefficients. The paper discusses digital approximations separately in note [10].
-/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit.Routing
open Matrix
variable {K : Type*} [Field K]

/-- Logical gates with their original one or two arbitrary wire addresses. -/
inductive Local (K : Type*) (n : ℕ)
  | one (p : Wire n) (U : Matrix (Fin 2) (Fin 2) K)
  | two (a : Address n) (G : Matrix Pair Pair K)

def Local.act {n : ℕ} : Local K n → (Bits n → K) → Bits n → K
  | .one p U => p.act U
  | .two a G => a.act G

def Local.invertible {n : ℕ} : Local K n → Prop
  | .one _ U => ∃ V, V*U=1
  | .two _ G => ∃ H, H*G=1

def Local.encode {k : ℕ} : Local K (k+2) → Address (k+2) × Matrix Pair Pair K
  | .one p U => p.encoded U
  | .two a G => (a,G)

theorem Local.encode_exact {k : ℕ} (g : Local K (k+2)) (v : Bits (k+2) → K) :
    g.encode.1.act g.encode.2 v = g.act v := by
  cases g with
  | one p U => exact funext (p.encoded_exact U v)
  | two => rfl

theorem Local.encode_invertible {k : ℕ} {g : Local K (k+2)} (hg : g.invertible) :
    ∃ H, H*g.encode.2=1 := by
  cases g with
  | one p U => obtain ⟨V,h⟩ := hg; exact ⟨(p.encoded V).2,p.encoded_inverse U V h⟩
  | two => exact hg

def logical {n : ℕ} : List (Local K n) → (Bits n → K) → Bits n → K
  | [], v => v
  | g :: gs, v => logical gs (g.act v)

def logicalPromise {n : ℕ} (χ : ℕ) : List (Local K n) → (Bits n → K) → Prop
  | [], v => AllCuts v χ
  | g :: gs, v => AllCuts v χ ∧ logicalPromise χ gs (g.act v)

theorem encode_reference {k} (gs : List (Local K (k+2))) (v : Bits (k+2) → K) :
    reference (gs.map Local.encode) v = logical gs v := by
  induction gs generalizing v with
  | nil => rfl
  | cons g gs ih =>
    change reference (gs.map Local.encode) (g.encode.1.act g.encode.2 v) = _
    rw [g.encode_exact]
    exact ih _

theorem encode_promise {k χ} (gs : List (Local K (k+2))) (v : Bits (k+2) → K)
    (h : logicalPromise χ gs v) : promised χ (gs.map Local.encode) v := by
  induction gs generalizing v with
  | nil => exact h
  | cons g gs ih =>
    refine ⟨h.1, ?_⟩
    change promised χ (gs.map Local.encode) (g.encode.1.act g.encode.2 v)
    rw [g.encode_exact]
    exact ih _ h.2

variable [DecidableEq K] [StarRing K]

/-- A scalar expectation and the size of the classical computation that obtains it. -/
structure Result (K : Type*) where
  value : K
  work : ℕ
  space : ℕ

/-- On two or more wires use the routed matrix-product chain. The charges are the
actual gate-and-measurement work and peak scalar tables of that same execution. -/
def chainMeasurement {k : ℕ} (gs : List (Local K (k+2))) (v : Fin (k+2) → Fin 2 → K)
    (O : Observable K (k+2)) : Result K :=
  let gates := compile (gs.map Local.encode)
  let C := productChain v
  let (D,w) := simulate gates C
  ⟨(readout D O 1) 0 0, w + readoutWork D, totalSpace gates C⟩

theorem chainMeasurement_spec {k χ : ℕ} (gs : List (Local K (k+2))) (v : Fin (k+2) → Fin 2 → K)
    (O : Observable K (k+2)) (hv : ∀ i, ∃ b, v i b ≠ 0)
    (hg : ∀ g ∈ gs, g.invertible) (hχ : logicalPromise χ gs (amplitude (productChain v))) :
    let n := k+2
    let out := chainMeasurement gs v O
    out.value = bornSum O (logical gs (amplitude (productChain v))) ∧
    out.work ≤ gs.length*(2*n)*(24*χ^3+40*χ^2) + n*(20*χ^3+8*χ^2) ∧
    out.space ≤ 2*n*χ^2+36*χ^2+4*χ := by
  let P := gs.map Local.encode
  let gates := compile P
  let C := productChain v
  have inv : ∀ g ∈ P, ∃ H, H*g.2=1 := by
    intro g hin
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hin
    exact Local.encode_invertible (hg p hp)
  have width := (schmidtCircuit gates v hv (compile_invertible P inv)
    (compile_trajectory P _ (encode_promise gs _ hχ))).2.2
  refine ⟨(final_measurement gates C O).trans (congrArg (bornSum O)
    ((compile_exact P _).trans (encode_reference gs _))), ?_, total_space gates C width⟩
  apply (measurement_work gates C width).trans
  have budget : gates.length ≤ gs.length*(2*(k+2)) := by simpa [gates,P] using compile_length P
  exact Nat.add_le_add_right (Nat.mul_le_mul_right _ budget) _

def oneMatrix : Local K 1 → Matrix (Fin 2) (Fin 2) K
  | .one _ U => U
  | .two (.later p) _ => nomatch p

omit [DecidableEq K] [StarRing K] in
private theorem oneMatrix_act (g : Local K 1) (v : Bits 1 → K) (i : Fin 2) :
    g.act v (i,()) = (oneMatrix g *ᵥ (fun j => v (j,()))) i := by
  cases g with
  | one p U =>
    cases p with
    | first => rfl
    | later p => nomatch p
  | two a G => cases a with | later a => nomatch a

omit [DecidableEq K] [StarRing K] in
private theorem oneState_spec (gs : List (Local K 1)) (v : Bits 1 → K) :
    let (a,w) := oneWireRun (gs.map oneMatrix) (fun i => v (i,()))
    (∀ i, a i = logical gs v (i,())) ∧ w = 8*gs.length := by
  have ⟨ha,hw⟩ := oneWireCircuit (gs.map oneMatrix) (fun i => v (i,()))
  refine ⟨?_, by simpa using hw⟩
  intro i
  rw [ha]
  clear ha hw
  induction gs generalizing v with
  | nil => rfl
  | cons g gs ih =>
    have eq : oneMatrix g *ᵥ (fun i => v (i,())) = fun i => g.act v (i,()) :=
      funext fun i => (oneMatrix_act g v i).symm
    simpa only [List.map_cons, List.foldl_cons, logical, eq] using ih (g.act v)

/-- Simulate a circuit of any width. Zero and one wires have constant-size state tables. -/
def measureCircuit : {n : ℕ} → List (Local K n) → (Fin n → Fin 2 → K) →
    Observable K n → Result K
  | 0, _, _, _ => ⟨1,0,1⟩
  | 1, gs, v, O =>
    let (a,w) := oneWireRun (gs.map oneMatrix) (fun i => amplitude (productChain v) (i,()))
    ⟨∑ s : Pair, O 0 s.1 s.2 * a s.2 * star (a s.1), w+16,8⟩
  | _+2, gs, v, O => chainMeasurement gs v O

/-- Vidal's Theorem 1 in the exact scalar-arithmetic model. On any nonzero product
input, an arbitrary sequence of one- and two-site invertible gates is simulated
classically using polynomial work and space whenever the physical Schmidt ranks
of the original trajectory are polynomially bounded. The result is the exact
expectation of the final product observable, including any local Born projector. -/
theorem vidal_simulation {n χ : ℕ} (gs : List (Local K n)) (v : Fin n → Fin 2 → K)
    (O : Observable K n) (hv : ∀ i, ∃ b, v i b ≠ 0)
    (hg : ∀ g ∈ gs, g.invertible) (hχ : logicalPromise χ gs (amplitude (productChain v))) :
    let out := measureCircuit gs v O
    out.value = bornSum O (logical gs (amplitude (productChain v))) ∧
    out.work ≤ 200*(gs.length+1)*(n+1)*(χ+1)^3 ∧
    out.space ≤ 100*(n+1)*(χ+1)^2 := by
  match n, gs with
  | 0, [] =>
    refine ⟨?_, by simp [measureCircuit], by change 1 ≤ 100*(0+1)*(χ+1)^2; ring_nf; omega⟩
    change (1 : K) = ∑ p : Unit, _ * _ * _
    simp [logical, productEntry, productChain, amplitude, Chain.coefficient, bra, ket]
  | 0, g::_ => cases g with | one p _ => nomatch p | two a _ => nomatch a
  | 1, gs =>
    let ψ := amplitude (productChain v)
    obtain ⟨ha,hw⟩ := oneState_spec gs ψ
    dsimp only [measureCircuit]
    refine ⟨?_, ?_, ?_⟩
    · unfold bornSum
      change _ = ∑ p : Pair × Unit, productEntry (n:=1) O p * _ * _
      conv_rhs => rw [Fintype.sum_prod_type]
      simp only [Fintype.sum_unique, productEntry, mul_one, ket, bra]
      apply Finset.sum_congr rfl
      intro s _
      rw [ha, ha]
    · change (oneWireRun (gs.map oneMatrix) (fun i => ψ (i,()))).2 + 16 ≤ _
      rw [hw]
      ring_nf
      omega
    · ring_nf
      omega
  | k+2, gs =>
    obtain ⟨he,hw,hs⟩ := chainMeasurement_spec gs v O hv hg hχ
    refine ⟨he, hw.trans ?_, hs.trans ?_⟩ <;> ring_nf <;> omega

end FQChem.Algorithms.MPSCircuit.Routing
