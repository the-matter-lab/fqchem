module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.PhysicalCuts
public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.MinimalBonds

/-!
# Routing arbitrary two-site gates on a qubit chain

Vidal's Theorem 1 bounds the Schmidt rank over every bipartition at the steps of
the original computation. Moving a wire past another wire only permutes those
bipartitions. The adjacent simulator can therefore use the same physical rank
bound throughout the outward and return routes.
-/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit
namespace Routing

open Matrix
variable {K : Type*} [Field K]

/-- The bond between two successive sites, addressed from the left end. -/
inductive Bond : ℕ → Type
  | head {n : ℕ} : Bond (n+2)
  | tail {n : ℕ} (b : Bond n) : Bond (n+1)

def Bond.gate (G : Matrix Pair Pair K) : {n : ℕ} → Bond n → Gate K n
  | _, .head => .here G
  | _, .tail b => .there (b.gate G)

def Bond.exchange : {n : ℕ} → Bond n → Bits n → Bits n
  | _, .head, (a,b,x) => (b,a,x)
  | _, .tail p, (a,x) => (a,p.exchange x)

def Bond.window : {n : ℕ} → Bond n → Bits n → Pair → Pair × Bits n
  | _, .head, (a,b,x), s => ((a,b),s.1,s.2,x)
  | _, .tail p, (a,x), s => let (ij,y) := p.window x s; (ij,a,y)

def swapMatrix : Matrix Pair Pair K := of fun i j => if j = (i.2,i.1) then 1 else 0

theorem swap_inverse : (swapMatrix : Matrix Pair Pair K) * swapMatrix = 1 := by
  ext ⟨i,j⟩ ⟨k,l⟩
  rw [Matrix.mul_apply, Finset.sum_eq_single (j,i)]
  · simp [swapMatrix, Matrix.one_apply, eq_comm]
  · intro z _ hz
    simp [swapMatrix, hz]
  · simp

theorem Bond.invertible {n : ℕ} (b : Bond n) (G H : Matrix Pair Pair K) (h : H * G = 1) :
    (b.gate G).invertible := by
  induction b with
  | head => exact ⟨H,h⟩
  | tail _ ih => exact ih

omit [Field K] in
theorem Bond.input_eq {n : ℕ} (b : Bond n) (G : Matrix Pair Pair K) (x : Bits n) (s : Pair) :
    (b.gate G).input x s = (G (b.window x s).1 s, (b.window x s).2) := by
  induction b with
  | head => rfl
  | tail b ih => rcases x with ⟨a,x⟩; simp [Bond.gate, Gate.input, Bond.window, ih]

theorem Bond.exchange_twice {n : ℕ} (b : Bond n) (x : Bits n) : b.exchange (b.exchange x) = x := by
  induction b with
  | head => rfl
  | tail b ih => rcases x with ⟨a,x⟩; simp [Bond.exchange, ih] ; rfl

theorem Bond.swap_act {n : ℕ} (b : Bond n) (v : Bits n → K) (x : Bits n) :
    (b.gate swapMatrix).act v x = v (b.exchange x) := by
  induction b with
  | head =>
    rcases x with ⟨a,b,x⟩
    simp [Bond.gate, Gate.act, Gate.input, swapMatrix, Bond.exchange]
  | tail b ih =>
    rcases x with ⟨a,x⟩
    simpa [Bond.gate, Gate.act, Gate.input, Bond.exchange] using ih (fun y => v (a,y)) x

/-- A route moves wires to a neighboring bond, applies the matrix, and restores the wire order. -/
inductive Route (n : ℕ) where
  | direct (b : Bond n)
  | via (s : Bond n) (rest : Route n)

def Route.lift {n : ℕ} : Route n → Route (n+1)
  | .direct b => .direct (.tail b)
  | .via s r => .via (.tail s) r.lift

def Route.window {n : ℕ} : Route n → Bits n → Pair → Pair × Bits n
  | .direct b, x, p => b.window x p
  | .via s r, x, p => let (ij,y) := r.window (s.exchange x) p; (ij,s.exchange y)

theorem Route.lift_window {n : ℕ} (r : Route n) (a : Fin 2) (x : Bits n) (s : Pair) :
    r.lift.window (a,x) s = ((r.window x s).1,a,(r.window x s).2) := by
  induction r generalizing x with
  | direct b => rfl
  | via b r ih => simp [Route.lift, Route.window, Bond.exchange, ih] ; rfl

def Route.gates {n : ℕ} (G : Matrix Pair Pair K) : Route n → List (Gate K n)
  | .direct b => [b.gate G]
  | .via s r => s.gate swapMatrix :: (r.gates G ++ [s.gate swapMatrix])

def Route.hops {n : ℕ} : Route n → ℕ
  | .direct _ => 0
  | .via _ r => r.hops + 1

theorem Route.lift_hops {n : ℕ} (r : Route n) : r.lift.hops = r.hops := by
  induction r with
  | direct => rfl
  | via s r ih => simp [Route.lift, Route.hops, ih]

theorem Route.gate_count {n : ℕ} (r : Route n) (G : Matrix Pair Pair K) :
    (r.gates G).length = 2*r.hops + 1 := by
  induction r with
  | direct => rfl
  | via s r ih => simp [Route.gates, Route.hops, ih]; omega

theorem Route.invertible {n : ℕ} (r : Route n) (G H : Matrix Pair Pair K) (hg : H*G=1) :
    ∀ g ∈ r.gates G, g.invertible := by
  induction r with
  | direct b => simpa [Route.gates] using b.invertible G H hg
  | via s r ih =>
    intro g hg
    simp only [Route.gates, List.mem_cons, List.mem_append, List.mem_nil_iff, or_false] at hg
    rcases hg with rfl | hg | rfl
    · exact s.invertible _ _ swap_inverse
    · exact ih _ hg
    · exact s.invertible _ _ swap_inverse

theorem dense_append {n : ℕ} (a b : List (Gate K n)) (v : Bits n → K) :
    dense (a++b) v = dense b (dense a v) := by
  induction a generalizing v with
  | nil => rfl
  | cons g a ih => exact ih (g.act v)

theorem Route.exact {n : ℕ} (r : Route n) (G : Matrix Pair Pair K) (v : Bits n → K) (x : Bits n) :
    dense (r.gates G) v x = ∑ p : Pair, G (r.window x p).1 p * v (r.window x p).2 := by
  induction r generalizing v x with
  | direct b => simp [Route.gates, Route.window, dense, Gate.act, Bond.input_eq]
  | via b r ih =>
    simp only [Route.gates, dense, dense_append, Bond.swap_act, ih, Route.window]

/-- Choose a second wire to the right of the first. Each skip leaves one further wire untouched. -/
inductive Distance : ℕ → Type
  | near {k : ℕ} : Distance k
  | skip {k : ℕ} (d : Distance k) : Distance (k+1)

def Distance.route : {k : ℕ} → Distance k → Route (k+2)
  | _, .near => .direct .head
  | _, .skip d => .via .head d.route.lift

/-- Read both selected wires and overwrite them with p, preserving every unselected wire. -/
def Distance.window : {k : ℕ} → Distance k → Bits (k+2) → Pair → Pair × Bits (k+2)
  | _, .near, (a,b,x), p => ((a,b),p.1,p.2,x)
  | _, .skip d, (a,b,x), p => let (ij,c,y) := d.window (a,x) p; (ij,c,b,y)

theorem Distance.exact_window {k : ℕ} (d : Distance k) (x : Bits (k+2)) (p : Pair) :
    d.route.window x p = d.window x p := by
  induction d with
  | near => rfl
  | skip d ih =>
    rcases x with ⟨a,b,x⟩
    simp only [Distance.route, Route.window, Bond.exchange, Distance.window]
    simp only [d.route.lift_window b (a,x) p, ih (a,x)]
    rcases d.window (a,x) p with ⟨ij,c,y⟩
    rfl

theorem Distance.hops_le {k : ℕ} (d : Distance k) : d.route.hops ≤ k := by
  induction d with
  | near => exact Nat.zero_le _
  | skip d ih => simpa [Distance.route, Route.hops, Route.lift_hops] using ih

/-- An arbitrary pair in left-to-right order; the gate matrix specifies which wire is control. -/
inductive Address : ℕ → Type
  | first {k : ℕ} (d : Distance k) : Address (k+2)
  | later {n : ℕ} (a : Address n) : Address (n+1)

def Address.route : {n : ℕ} → Address n → Route n
  | _, .first d => d.route
  | _, .later a => a.route.lift

def Address.window : {n : ℕ} → Address n → Bits n → Pair → Pair × Bits n
  | _, .first d, x, p => d.window x p
  | _, .later a, (i,x), p => let (ij,y) := a.window x p; (ij,i,y)

theorem Address.exact_window {n : ℕ} (a : Address n) (x : Bits n) (p : Pair) :
    a.route.window x p = a.window x p := by
  induction a with
  | first d => exact d.exact_window x p
  | later a ih => rcases x with ⟨i,x⟩; simp [Address.route, Route.lift_window, Address.window, ih] ; rfl

theorem Address.gate_count {n : ℕ} (a : Address n) (G : Matrix Pair Pair K) :
    (a.route.gates G).length ≤ 2*n := by
  rw [Route.gate_count]
  induction a with
  | first d => have := d.hops_le; simp [Address.route]; omega
  | later a ih => simp [Address.route, Route.lift_hops]; omega

def Distance.gap : {k : ℕ} → Distance k → ℕ
  | _, .near => 0
  | _, .skip d => d.gap + 1

def Address.positions : {n : ℕ} → Address n → ℕ × ℕ
  | _, .first d => (0,d.gap+1)
  | _, .later a => (a.positions.1+1,a.positions.2+1)

theorem Distance.at_gap {k j : ℕ} (h : j ≤ k) : ∃ d : Distance k, d.gap = j := by
  induction k generalizing j with
  | zero => exact ⟨.near, (Nat.eq_zero_of_le_zero h).symm⟩
  | succ k ih =>
    cases j with
    | zero => exact ⟨.near, rfl⟩
    | succ j => obtain ⟨d,rfl⟩ := ih (Nat.le_of_succ_le_succ h); exact ⟨.skip d,rfl⟩

/-- Every pair of distinct wire positions, in increasing order, has an address. -/
theorem Address.coverage {n i j : ℕ} (hij : i < j) (hj : j < n) :
    ∃ a : Address n, a.positions = (i,j) := by
  induction n generalizing i j with
  | zero => omega
  | succ n ih =>
    cases i with
    | zero =>
      cases n with
      | zero => omega
      | succ k =>
        obtain ⟨d, hd⟩ := Distance.at_gap (show j-1 ≤ k by omega)
        exact ⟨.first d, Prod.ext rfl (show d.gap+1=j by omega)⟩
    | succ i =>
      obtain ⟨a,ha⟩ := ih (show i < j-1 by omega) (show j-1 < n by omega)
      refine ⟨.later a, ?_⟩
      simp only [Address.positions, ha]
      congr 1
      omega

/-- Dense action on the two original sites, independently of how they are routed. -/
def Address.act {n : ℕ} (a : Address n) (G : Matrix Pair Pair K) (v : Bits n → K) (x : Bits n) :=
  ∑ p : Pair, G (a.window x p).1 p * v (a.window x p).2

theorem Address.exact {n : ℕ} (a : Address n) (G : Matrix Pair Pair K) (v : Bits n → K) :
    dense (a.route.gates G) v = a.act G v := by
  funext x
  simp only [Route.exact, Address.exact_window, Address.act]

end Routing
end FQChem.Algorithms.MPSCircuit
