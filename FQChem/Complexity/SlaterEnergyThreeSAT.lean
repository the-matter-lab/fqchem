module

public import FQChem.Complexity.SlaterEnergyHamiltonian
public import FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassThreeSAT
import Mathlib.Tactic

/-! # From a 3-CNF formula to a fixed-basis electronic energy

A vertex represents one literal occurrence. A size-m independent set in the
conflict graph picks one consistent literal in each of the m clauses. Feeding
this explicit graph to the compact-orbital construction gives the completeness
and soundness energy thresholds from the formula itself. -/

@[expose] public section
namespace FQChem.Complexity.SlaterEnergyThreeSAT
open FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT
open SlaterEnergy SlaterEnergyKinetic SlaterEnergyReduction SlaterEnergyHamiltonian
variable {n m : ℕ}

abbrev Slot (m : ℕ) := Fin (m*3)

def clause (v : Slot m) : Fin m := (finProdFinEquiv.symm v : Fin m × Fin 3).1

def literal (f : Formula n m) (v : Slot m) : Literal n :=
  let p : Fin m × Fin 3 := finProdFinEquiv.symm v
  f p.1 p.2

/-- Adjacency takes two clause lookups and compares their variable and sign. -/
def conflict (f : Formula n m) (v w : Slot m) : Bool :=
  decide (v ≠ w ∧ (clause v = clause w ∨
    (literal f v).var = (literal f w).var ∧ (literal f v).neg ≠ (literal f w).neg))

def graph (f : Formula n m) : SimpleGraph (Slot m) where
  Adj v w := conflict f v w
  symm := ⟨by intro v w; simp [conflict]; grind⟩
  loopless := ⟨by simp [conflict]⟩

private theorem clauseTrue {s : Fin n → Bool} {f : Formula n m} {c : Fin m} :
    (∃ k, (f c k).eval s = true) ↔
      ((f c 0).eval s || (f c 1).eval s || (f c 2).eval s) = true := by
  simp only [Bool.or_eq_true]
  constructor
  · rintro ⟨k,h⟩
    fin_cases k <;> tauto
  · rintro ((h|h)|h)
    · exact ⟨0,h⟩
    · exact ⟨1,h⟩
    · exact ⟨2,h⟩

/-- Every assignment and every independent set have their usual witness
interpretation, including repeated variables and tautological clauses. -/
theorem independentIff (f : Formula n m) : Independent (graph f) m ↔ ThreeSAT f := by
  classical
  constructor
  · rintro ⟨S, size, hS⟩
    have distinct := (graph f).isIndepSet_iff.mp hS
    have inj : Set.InjOn clause (S : Set (Slot m)) := by
      intro v hv w hw h
      by_contra ne
      exact distinct hv hw ne (by change conflict f v w = true; simp [conflict,ne,h])
    have allClauses : S.image clause = Finset.univ := Finset.eq_univ_of_card _
      ((Finset.card_image_iff.mpr inj).trans (by simpa using size))
    let assignment := fun x : Fin n => decide (∃ w ∈ S, (literal f w).var=x ∧ (literal f w).neg=false)
    refine ⟨assignment, fun c => clauseTrue.mp ?_⟩
    obtain ⟨v,hv,hc⟩ := Finset.mem_image.mp (show c ∈ S.image clause from allClauses ▸ Finset.mem_univ _)
    obtain ⟨⟨i,k⟩,rfl⟩ := finProdFinEquiv.surjective v
    simp [clause] at hc
    subst i
    let v : Slot m := finProdFinEquiv (c,k)
    have lit : literal f v = f c k := by simp [literal,v]
    have mem : v ∈ S := hv
    refine ⟨k,?_⟩
    rw [← lit]
    cases hs : (literal f v).neg
    · have yes : assignment (literal f v).var = true :=
        decide_eq_true ⟨v,mem,rfl,hs⟩
      simp [Literal.eval,hs,yes]
    · have no : assignment (literal f v).var = false := by
        apply decide_eq_false
        rintro ⟨w,hw,varEq,hwNeg⟩
        have ne : v ≠ w := by rintro rfl; simp_all
        exact distinct mem hw ne (by change conflict f v w = true; simp [conflict,ne,varEq,hs,hwNeg])
      simp [Literal.eval,hs,no]
  · rintro ⟨s,hs⟩
    choose pos good using fun c => clauseTrue.mpr (hs c)
    let pick := fun c : Fin m => (finProdFinEquiv (c,pos c) : Slot m)
    have src (c : Fin m) : clause (pick c) = c := by simp [clause,pick]
    have val (c : Fin m) : (literal f (pick c)).eval s = true := by simpa [literal,pick] using good c
    refine ⟨Finset.univ.image pick,?_, (graph f).isIndepSet_iff.mpr ?_⟩
    · rw [Finset.card_image_of_injective _ (fun i j e => by simpa only [src] using congrArg clause e)]
      simp
    · intro v hv w hw ne edge
      obtain ⟨i,_,rfl⟩ := Finset.mem_image.mp hv
      obtain ⟨j,_,rfl⟩ := Finset.mem_image.mp hw
      change conflict f (pick i) (pick j) = true at edge
      simp only [conflict,decide_eq_true_eq,src] at edge
      rcases edge.2 with rfl|⟨same,opp⟩
      · exact ne rfl
      · have a := val i
        have b := val j
        simp only [Literal.eval,same] at a b
        have agrees : ∀ (x a b : Bool), (x ^^ a) = true → (x ^^ b) = true → a=b := by decide
        exact opp (agrees _ _ _ a b)

/-- For m positive clauses the m-electron Hamiltonian uses 3m spatial orbitals.
Satisfying assignments give a Slater witness; on unsatisfiable inputs the
lower bound holds for every normalized state in the sector. -/
theorem formulaEnergyGap (f : Formula n m) (hm : 0<m) :
    let N := m*3
    let H := electronic (k:=m) (graph f) (spacing N)
    let shift := (m:ℝ)*primitive
    (ThreeSAT f → ∃ ψ : Sector N m → ℂ, IsSlater ψ ∧ ElectronicStructure.mass ψ=1 ∧
      ElectronicStructure.matrixExpectation H ψ ≤ shift+1/(12*(N:ℝ)^2)) ∧
    (¬ ThreeSAT f → ∀ ψ : Sector N m → ℂ, ElectronicStructure.mass ψ=1 →
      shift+1/(6*(N:ℝ)^2) ≤ ElectronicStructure.matrixExpectation H ψ) := by
  simpa only [independentIff] using physicalReduction (graph f) (by omega) m

end FQChem.Complexity.SlaterEnergyThreeSAT
