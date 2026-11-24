module

public import Qatlib.Concepts.QspSimulation.Achievability.CleanSignalSimulation

/-! # The fixed instructions of the two-flag signal processing circuit -/

@[expose] public section
namespace FQChemQatlib.Dynamics.LowChuang

open Matrix Qatlib.Concepts.CoherentSim.CoherentOAA Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.BlockEncoding Qatlib.Concepts.BlockEncoding.LCU
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.QsvtCore.QueryLowerBound Qatlib.Concepts.PhaseGeometry.Phase
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.TrotterFormula.SuzukiFourth
open scoped Classical

variable {W I : Type} [Fintype W] [DecidableEq W] [Fintype I] [DecidableEq I]

/-- Exhaustive list of the possible fixed unitary matrices. The generic phase
comes in conjugate pairs on the inner Boolean flag. Amplification uses only
the two special phases ±i about the doubly averaged frame. -/
inductive FrameGate (F : Matrix W I ℂ) : Matrix (Bool × (Bool × W)) (Bool × (Bool × W)) ℂ → Prop
  | phase (z : ℂ) (hz : IsPhase z) : FrameGate F (controlOracle
      (select fun b : Bool => phaseRotation (rangeProjector F) (conjugateParallelPhase z b)))
  | flip : FrameGate F controlFlip
  | scalar : FrameGate F (controlOracle ((-Complex.I) • (1 : Matrix (Bool × W) (Bool × W) ℂ)))
  | cubic (z : ℂ) (hz : z=Complex.I ∨ z= -Complex.I) :
      FrameGate F (phaseRotation (rangeProjector (hamiltonianFrame F)) z)
  | adj {M} : FrameGate F M → FrameGate F Mᴴ

def Covered {J : Type} (p : Matrix J J ℂ → Prop) (word : List (AdjointStep J)) :=
  ∀ M, .gate M ∈ word → p M

private theorem swapped_gates {J : Type} {cs : List (AdjointStep J)} {M : Matrix J J ℂ}
    (mem : .gate M ∈ cs.map swapQueries) : .gate M ∈ cs := by
  obtain ⟨s,hs,eq⟩ := List.mem_map.mp mem
  cases s <;> simp_all [swapQueries]

omit [DecidableEq I] in
private theorem parallel_phase_gates (F : Matrix W I ℂ) (base : ℂ) (phases : List ℂ)
    (hb : IsPhase base) (hz : ∀ z ∈ phases, IsPhase z) :
    Covered (fun M => FrameGate F (controlOracle M))
      (compileRealPartQSVT (rangeProjector F) (rangeProjector F) base phases) := by
  induction phases with
  | nil =>
    intro M h
    simp only [compileRealPartQSVT,conjugateParallelPhases,List.map_nil,compileParallelQSVT,
      List.mem_singleton,AdjointStep.gate.injEq] at h
    subst M; exact .phase base hb
  | cons z zs ih =>
    intro M h
    simp only [compileRealPartQSVT,conjugateParallelPhases,List.map_cons,compileParallelQSVT,
      List.mem_cons,AdjointStep.gate.injEq] at h
    rcases h with eq | impossible | h
    · subst M; exact .phase z (hz z (by simp))
    · cases impossible
    · exact ih (fun v hv => hz v (by simp [hv])) M (swapped_gates h)

omit [DecidableEq I] in
private theorem controlled_gates {cs : List (AdjointStep (Bool × W))} {F : Matrix W I ℂ}
    (cov : Covered (fun M => FrameGate F (controlOracle M)) cs) :
    Covered (FrameGate F) (compileControlled cs) := by
  intro M h
  obtain ⟨s,hs,eq⟩ := List.mem_map.mp h
  cases s with
  | gate V => exact (AdjointStep.gate.inj eq) ▸ cov V hs
  | forward => cases eq
  | backward => cases eq

omit [DecidableEq I] in
theorem body_gates (F : Matrix W I ℂ) (bc : ℂ) (zc : List ℂ) (bs : ℂ) (zs : List ℂ)
    (hc : IsPhase bc) (hzc : ∀ z ∈ zc, IsPhase z) (hs : IsPhase bs) (hzs : ∀ z ∈ zs, IsPhase z) :
    Covered (FrameGate F) (compileHamiltonian F bc zc bs zs) := by
  intro M h
  simp only [compileHamiltonian,compileSelected,List.mem_append,List.mem_singleton,AdjointStep.gate.injEq] at h
  rcases h with ((h|rfl)|h)|rfl
  · exact controlled_gates (parallel_phase_gates F bc zc hc hzc) M h
  · exact .flip
  · apply controlled_gates _ M h
    intro V mem
    rcases List.mem_cons.mp mem with e | tail
    · cases e; exact .scalar
    · exact parallel_phase_gates F bs zs hs hzs V tail
  · exact .flip

omit [DecidableEq I] in
private theorem adjoint_gates {F : Matrix W I ℂ} {word}
    (cov : Covered (FrameGate F) word) : Covered (FrameGate F) (adjointCircuit word) := by
  induction word with
  | nil => simp [Covered,adjointCircuit]
  | cons g gs ih =>
    intro M h
    rcases List.mem_append.mp h with old | new
    · exact ih (fun V hv => cov V (List.mem_cons_of_mem _ hv)) M old
    · have eq := List.mem_singleton.mp new
      cases g with
      | gate V =>
        have hM : M=Vᴴ := AdjointStep.gate.inj eq
        exact hM ▸ FrameGate.adj (cov V (by simp))
      | forward => cases eq
      | backward => cases eq

theorem amplification_gates {F : Matrix W I ℂ} {body} (cov : Covered (FrameGate F) body) (k : ℕ) :
    Covered (FrameGate F) (scaleEightLevels (hamiltonianFrame F) k body) := by
  induction k with
  | zero => exact cov
  | succ k ih =>
    intro M h
    obtain ⟨s,outer,inner⟩ := List.mem_flatMap.mp h
    cases s with
    | forward => exact ih M inner
    | backward => exact adjoint_gates ih M inner
    | gate V =>
      obtain rfl : M=V := AdjointStep.gate.inj (List.mem_singleton.mp inner)
      simp [coherentOAAWord,cubicPhases,compileQSVT,swapQueries] at outer
      rcases outer with rfl | rfl <;> exact FrameGate.cubic _ (by simp)

end FQChemQatlib.Dynamics.LowChuang
