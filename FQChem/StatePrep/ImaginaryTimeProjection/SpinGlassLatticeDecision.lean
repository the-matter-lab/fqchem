module

public import FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassFrustration
import Mathlib.Tactic

/-! # A finite cubic-lattice sign-problem query for 3-SAT

The input uses arbitrary natural variable names, including repeated names and
negative literals. Occurrence-based renaming keeps the number of lattice sites
quadratic in the clause count irrespective of the numeric values of the names.
The sparse compiler enumerates physical signed nearest-neighbour bonds.
-/

@[expose] public section
namespace FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT.Lattice
open IsingSign MeasureTheory

abbrev Input (m : ℕ) := Fin m → Fin 3 → ℕ × Bool

def names {m} (f : Input m) : List ℕ := List.ofFn fun i : Fin (m*3) =>
  let p := finProdFinEquiv.symm i
  (f p.1 p.2).1

private theorem namePresent {m} (f : Input m) (c : Fin m) (i : Fin 3) : (f c i).1 ∈ names f := by
  apply List.mem_ofFn.mpr
  exact ⟨finProdFinEquiv (c,i), by simp⟩

/-- First occurrence and exact number of label comparisons in a linear search. -/
def firstOccurrence (key : ℕ) : List ℕ → ℕ × ℕ
  | [] => (0,0)
  | x::xs => if x=key then (0,1) else
      let rest := firstOccurrence key xs
      (rest.1+1,rest.2+1)

theorem firstOccurrenceSpec (key : ℕ) (xs : List ℕ) :
    (firstOccurrence key xs).1 = xs.idxOf key ∧ (firstOccurrence key xs).2 ≤ xs.length := by
  induction xs with
  | nil => simp [firstOccurrence]
  | cons x xs ih =>
    by_cases h : x=key <;> simp_all [firstOccurrence]

/-- Number a variable by its first occurrence; repeated literal names get the same number. -/
def rename {m} (f : Input m) (c : Fin m) (i : Fin 3) : Literal (m*3) :=
  ⟨⟨(firstOccurrence (f c i).1 (names f)).1, by
    rw [(firstOccurrenceSpec ..).1]
    simpa [names] using (List.idxOf_lt_length_iff.mpr (namePresent f c i))⟩, (f c i).2⟩

def evalRaw (s : ℕ → Bool) (l : ℕ × Bool) := s l.1 ^^ l.2

def satisfiableInput {m} (f : Input m) : Prop :=
  ∃ s, ∀ c, (evalRaw s (f c 0) || evalRaw s (f c 1) || evalRaw s (f c 2)) = true

theorem renameEquivalence {m} (f : Input m) : ThreeSAT (rename f) ↔ satisfiableInput f := by
  constructor
  · rintro ⟨s,hs⟩
    let raw (v : ℕ) := if h : (names f).idxOf v < m*3 then s ⟨_,h⟩ else false
    refine ⟨raw, fun c => ?_⟩
    have v (i : Fin 3) : evalRaw raw (f c i) = (rename f c i).eval s := by
      have h : (names f).idxOf (f c i).1 < m*3 := by
        simpa [rename,(firstOccurrenceSpec ..).1] using (rename f c i).var.isLt
      simp [evalRaw, raw, h, rename, Literal.eval, (firstOccurrenceSpec ..).1]
    simpa only [v] using hs c
  · rintro ⟨s,hs⟩
    let dense (i : Fin (m*3)) := s ((names f)[i.val]'(by simp [names]))
    refine ⟨dense, fun c => ?_⟩
    have v (i : Fin 3) : (rename f c i).eval dense = evalRaw s (f c i) := by
      simp [Literal.eval, dense, rename, (firstOccurrenceSpec ..).1, List.getElem_idxOf, evalRaw]
    simpa only [v] using hs c

/-- Store the occurrence renaming in an array once before routing the new clauses. -/
def compact {m} (f : Input m) : Formula (m*3) m :=
  let table := Vector.ofFn (fun j : Fin (m*3) =>
    let p := finProdFinEquiv.symm j
    rename f p.1 p.2)
  fun c i => table[(finProdFinEquiv (c,i)).val]

theorem compactEq {m} (f : Input m) : compact f = rename f := by
  funext c i
  simp only [compact, Vector.getElem_ofFn]
  change rename f (finProdFinEquiv.symm (finProdFinEquiv (c,i))).1
    (finProdFinEquiv.symm (finProdFinEquiv (c,i))).2 = _
  rw [Equiv.symm_apply_apply]

/-- Materializing the compact variable table performs at most (3m)²
variable-name equality comparisons, independently of the numeric variable labels. -/
theorem renamingComparisons {m} (f : Input m) :
    (∑ p : Fin m × Fin 3, (firstOccurrence (f p.1 p.2).1 (names f)).2) ≤ (m*3)^2 := by
  calc _ ≤ ∑ _p : Fin m × Fin 3, m*3 := Finset.sum_le_sum (fun p _ => by
         simpa [names] using (firstOccurrenceSpec (f p.1 p.2).1 (names f)).2)
       _ = _ := by simp [pow_two]

def pairList (a b : ℕ) : List (Fin a × Fin b) := List.ofFn finProdFinEquiv.symm

private theorem pairMem {a b} (p : Fin a × Fin b) : p ∈ pairList a b := by
  exact List.mem_ofFn.mpr ⟨finProdFinEquiv p,Equiv.symm_apply_apply _ _⟩

def edgeList {n m} (f : Formula n m) : List (Edge f) :=
  (pairList (m*3) n).map (Sum.inl ∘ Sum.inl) ++
  (pairList m 3).map (Sum.inl ∘ Sum.inr ∘ Sum.inl) ++
  (pairList m 3).flatMap (fun p => List.ofFn (fun y : Fin ((f p.1 p.2).var.val+1) =>
    Sum.inl (Sum.inr (Sum.inr ⟨p,y⟩)))) ++
  (pairList m 6).map Sum.inr

def compile {n m} (f : Formula n m) : List (Position × Bool) :=
  (edgeList f).map fun e => (position f e,sign f e)

theorem listComplete {n m} (f : Formula n m) (e : Edge f) : e ∈ edgeList f := by
  rcases e with ((p | p | ⟨p,y⟩) | p)
  · simp [edgeList, pairMem]
  · simp [edgeList, pairMem]
  · have h : (Sum.inl (Sum.inr (Sum.inr ⟨p,y⟩)) : Edge f) ∈ (pairList m 3).flatMap
        (fun q => List.ofFn (fun z : Fin ((f q.1 q.2).var.val+1) => Sum.inl (Sum.inr (Sum.inr ⟨q,z⟩)))) :=
        List.mem_flatMap.mpr ⟨p,pairMem p,List.mem_ofFn.mpr ⟨y,rfl⟩⟩
    simp only [edgeList,List.mem_append]
    tauto
  · simp [edgeList, pairMem]

/-- Every emitted signed physical slot is a model bond, and every model bond has
such a record. The model's coupling evaluated at that bond is exactly its emitted sign. -/
theorem compilerSpecification {n m} (f : Formula n m) (p : Position) (b : Bool) :
    (p,b) ∈ compile f ↔ ∃ e : Edge f, position f e=p ∧ sign f e=b ∧
      bondMask f e ∈ (model f).bonds ∧ (model f).coupling (bondMask f e) = (if b then -1 else 1) := by
  constructor
  · intro hp
    obtain ⟨e,_,he⟩ := List.mem_map.mp hp
    obtain rfl : p = position f e := (congrArg Prod.fst he).symm
    obtain rfl : b = sign f e := (congrArg Prod.snd he).symm
    exact ⟨e,rfl,rfl, by simp [sparseBonds], signedCoupling f e⟩
  · rintro ⟨e,rfl,rfl,_,_⟩
    exact List.mem_map.mpr ⟨e,listComplete f e,rfl⟩

theorem compilerLength {n m} (f : Formula n m) :
    (compile f).length = (model f).bonds.card := by
  rw [compiledBondCount]
  simp [compile, edgeList, pairList, List.length_flatMap, List.map_ofFn, List.sum_ofFn,
    Wire, Edge, Fintype.card_sigma]
  have eq := finProdFinEquiv.symm.sum_comp (fun p : Fin m × Fin 3 => (f p.1 p.2).var.val+1)
  simpa [Function.comp_def, add_assoc] using eq

/-- The emitted signed table contains each occupied slot just once and has at most
three entries per spin. Counting the table produces the bosonic energy estimate
at the same inverse temperature and accuracy used by the decision query. -/
theorem compiledComparison {n m} (f : Formula n m) :
    (compile f).length ≤ 3*size n m ∧
    |-((compile f).length : ℝ) - (model f).ferro.quantumThermal (13*(size n m:ℝ))| ≤
      |(model f).ferro.quantumThermal (13*(size n m:ℝ))| / (24*(size n m:ℝ)) := by
  rw [compilerLength]
  exact ⟨cubicBondCount _ _,bosonicDecisionEstimate _ (by dsimp [size]; positivity)⟩

def compileInput {m} (f : Input m) := splitFormula (compact f)

theorem siteCount (m : ℕ) :
    size (m*3+(m+1)) (m*2) = 72*m^2+48*m+6 := by dsimp [size]; ring

/-- The integer threshold is obtained directly from the sparse output by one count.
There are six rim edges per NAE clause, and a satisfied rim contributes −4. -/
theorem compiledThreshold {n m} (f : Formula n m) :
    target f = -((compile f).length : ℤ) + 2*m := by
  rw [compilerLength, compiledBondCount]
  simp [target, Edge]
  ring

/-- Substituting the verified site count, β=13N and ε⁻¹=24N in Troyer–Wiese
Eq. (9) gives an explicit polynomial in the 3-CNF clause count. This accounts
for the signed oracle call under its proposed running-time guarantee. -/
theorem oracleWork (κ a b m : ℕ) :
    let N := size (m*3+(m+1)) (m*2)
    κ*(24*N)^2*N^a*(13*N)^b ≤
      (κ*24^2*13^b*126^(2+a+b))*(m+1)^(2*(2+a+b)) := by
  intro N
  have small : N ≤ 126*(m+1)^2 := by
    change size _ _ ≤ _
    rw [siteCount]
    nlinarith
  calc κ*(24*N)^2*N^a*(13*N)^b = (κ*24^2*13^b)*N^(2+a+b) := by
         simp [mul_pow, pow_add]; ring
       _ ≤ (κ*24^2*13^b)*(126*(m+1)^2)^(2+a+b) := by gcongr
       _ = _ := by rw [mul_pow, ← pow_mul]; ring

/-- A single signed-energy estimate solves ordinary three-literal satisfiability
on a three-layer nearest-neighbour Hamiltonian, with error at most 1/4. The input
is compact in the number of clauses even when its variable names are large. -/
theorem signedEnergyDecidesThreeSAT {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {m} (input : Input m) (estimate : Ω → ℝ) :
    let f := compileInput input
    let N := size (m*3+(m+1)) (m*2)
    let g := model f
    Integrable (fun x => (estimate x-g.quantumThermal (13*N))^2) μ →
    (∫ x, (estimate x-g.quantumThermal (13*N))^2 ∂μ) ≤ (|g.quantumThermal (13*N)|/(24*N))^2 →
    μ.real {x | ¬ ((estimate x < -((compile f).length : ℝ)+4*m+3/4) ↔ satisfiableInput input)} ≤ 1/4 ∧
      (compile f).length ≤ 3*N ∧
      |-((compile f).length : ℝ)-g.ferro.quantumThermal (13*N)| ≤ |g.ferro.quantumThermal (13*N)|/(24*N) := by
  intro f N g hi hr
  have equiv : feasible g (target f) ↔ satisfiableInput input :=
    (cubicThreshold f).trans (by
      change Satisfiable (splitFormula (compact input)) ↔ _
      rw [compactEq,splitEquivalence,renameEquivalence])
  have pos : 0 < N := by dsimp [N,size]; positivity
  have decision := statisticalDecision μ g pos (cubicBondCount _ _) (target f) estimate hi hr
  rw [equiv] at decision
  have cutoff : (target f : ℝ) = -((compile f).length : ℝ)+4*m := by
    rw [compiledThreshold]
    push_cast
    ring
  rw [cutoff] at decision
  exact ⟨decision,compiledComparison f⟩

/-- Every nonempty source instance gives a sign problem on the very same
Hamiltonian used in the decision reduction. -/
theorem decisionInstanceFrustrated {m} (input : Input m) (hm : 0 < m) :
    let g := model (compileInput input)
    ∃ p, p.length = 6 ∧ (aligned _ :: p).getLast? = some (aligned _) ∧
      pathWeight g (aligned _) p = -1 ∧ pathWeight g.ferro (aligned _) p = 1 := by
  exact frustratedInstance (compileInput input) ⟨0,by omega⟩

end FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT.Lattice
