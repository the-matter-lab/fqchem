module

public import FQChem.StatePrep.PerturbationTheory.CoupledClusterReplicas
public import FQChem.Complexity.SlaterContraction

/-!
# Polynomial work of single-reference coupled cluster

[Lee et al., Fig. 3A](https://doi.org/10.1038/s41467-023-37587-6) propose a joint
polynomial bound in problem size and inverse absolute energy error. The paper leaves
the quantitative single-reference promise and implementation open. A concrete
instance supplies an encoded Hamiltonian family, reference determinants and a
solver with a specified operation-count model.
-/

@[expose] public section
noncomputable section

namespace FQChem.Unproven.CoupledCluster

open FQChem.StatePrep.CoupledClusterReplicas
open FQChem.Complexity.SlaterContraction

/-- Determinants in a fixed electron-number sector of a finite spin-orbital basis. -/
abbrev Determinant (L N : ℕ) := Set.powersetCard (Fin L) N

structure Instance where
  orbitals : ℕ
  electrons : ℕ
  reference : Determinant orbitals electrons
  hamiltonian : Matrix (Determinant orbitals electrons) (Determinant orbitals electrons) ℂ
  hermitian : hamiltonian.IsHermitian

/-- A particle–hole operator relative to the chosen reference determinant. -/
structure Excitation (x : Instance) where
  hole : {q : Fin x.orbitals // q ∈ x.reference}
  particle : {p : Fin x.orbitals // p ∉ x.reference}

/-- The exterior-power action of a†ₚa_q carries the fermionic exchange signs. -/
def Excitation.operator {x : Instance} (e : Excitation x) :
    Module.End ℂ (Sector (Fin x.orbitals) x.electrons) :=
  one x.electrons e.particle.val e.hole.val

/-- One amplitude multiplying a nonempty product of pure excitations. Singles
have an empty tail. The solver can truncate the rank or omit individual terms. -/
structure Amplitude (x : Instance) where
  coefficient : ℂ
  first : Excitation x
  rest : List (Excitation x)

/-- The cluster operator in the ordered determinant basis. Each amplitude acts
on every determinant in the sector through the same exterior-power operator. -/
def clusterMatrix (x : Instance) (amplitudes : List (Amplitude x)) :
    Matrix (Determinant x.orbitals x.electrons) (Determinant x.orbitals x.electrons) ℂ :=
  let basis := occupationBasis (ι := Fin x.orbitals) x.electrons
  LinearMap.toMatrix basis basis ((amplitudes.map fun t =>
    t.coefficient • (t.first.operator * (t.rest.map Excitation.operator).prod)).sum)

/-- For a specified family, promise and solver, positive inverse accuracy k means
absolute energy error at most 1/k. A successful run returns the cluster amplitudes
and total work, including solving for the amplitudes and evaluating the energy.
The constants are uniform over the promised inputs and requested precisions.
The energy is the reference diagonal of the similarity-transformed Hamiltonian. -/
def PolynomialWork {I : Type*} (family : I → Instance) (singleReference : Set I)
    (run : (i : I) → ℕ → Option (List (Amplitude (family i)) × ℕ)) : Prop :=
  ∃ C a b : ℕ, ∀ i ∈ singleReference, ∀ k : ℕ, 0 < k →
    ∃ amplitudes work, run i k = some (amplitudes, work) ∧
      work ≤ C * ((family i).orbitals + 1) ^ a * k ^ b ∧
      let x := family i
      ∃ E : ℝ, GroundAt x.hamiltonian E ∧
        ‖VariationalMethods.transformed x.hamiltonian (clusterMatrix x amplitudes)
          x.reference x.reference - (E : ℂ)‖ ≤ 1 / (k : ℝ)

end FQChem.Unproven.CoupledCluster
