module

import all FQChemQatlib
import all FQChemQatlib.Complexity.QueryAlgorithms
import all FQChemQatlib.Complexity.SimonOracleMachines
import all FQChemQatlib.Complexity.SimonTuringSeparation
import all FQChemQatlib.Dynamics.AncillaFreeNot
import all FQChemQatlib.Dynamics.AncillaFreePhase
import all FQChemQatlib.Dynamics.BorrowedControls
import all FQChemQatlib.Dynamics.BorrowedRipple
import all FQChemQatlib.Dynamics.DirtyIncrement
import all FQChemQatlib.Dynamics.HalvedIncrement
import all FQChemQatlib.Dynamics.LowChuangAllDimensions
import all FQChemQatlib.Dynamics.LowChuangBinaryCompare
import all FQChemQatlib.Dynamics.LowChuangBinaryDecoder
import all FQChemQatlib.Dynamics.LowChuangBinaryPhase
import all FQChemQatlib.Dynamics.LowChuangCutoff
import all FQChemQatlib.Dynamics.LowChuangDecoderLayout
import all FQChemQatlib.Dynamics.LowChuangElementary
import all FQChemQatlib.Dynamics.LowChuangFlagGates
import all FQChemQatlib.Dynamics.LowChuangGateWord
import all FQChemQatlib.Dynamics.LowChuangPadding
import all FQChemQatlib.Dynamics.LowChuangPhysical
import all FQChemQatlib.Dynamics.LowChuangQueries
import all FQChemQatlib.Dynamics.LowChuangReadout
import all FQChemQatlib.Dynamics.LowChuangReflections
import all FQChemQatlib.Dynamics.LowChuangSimulation
import all FQChemQatlib.Dynamics.LowChuangSingleton
import all FQChemQatlib.Dynamics.LowChuangSparseAccess
import all FQChemQatlib.Dynamics.LowChuangSparseAccuracy
import all FQChemQatlib.Dynamics.LowChuangSparseAssembly
import all FQChemQatlib.Dynamics.LowChuangSparseBlock
import all FQChemQatlib.Dynamics.LowChuangSparseCartesian
import all FQChemQatlib.Dynamics.LowChuangSparseControl
import all FQChemQatlib.Dynamics.LowChuangSparseCutoff
import all FQChemQatlib.Dynamics.LowChuangSparseOracle
import all FQChemQatlib.Dynamics.LowChuangSparsePacking
import all FQChemQatlib.Dynamics.LowChuangSparsePhysicalBlock
import all FQChemQatlib.Dynamics.LowChuangSparsePlacement
import all FQChemQatlib.Dynamics.LowChuangSparseReadout
import all FQChemQatlib.Dynamics.LowChuangSparseResources
import all FQChemQatlib.Dynamics.LowChuangSparseScalar
import all FQChemQatlib.Dynamics.LowChuangSparseSimulation
import all FQChemQatlib.Dynamics.LowChuangSparseSwap
import all FQChemQatlib.Dynamics.LowChuangSparseWires
import all FQChemQatlib.Dynamics.LowChuangStandardForm
import all FQChemQatlib.Dynamics.LowChuangUniformBits
import all FQChemQatlib.Dynamics.SingletonPhaseGradient
import all FQChemQatlib.Dynamics.SingularValueTransformation
import all FQChemQatlib.Dynamics.SparseHamiltonianSimulation
import all FQChemQatlib.Properties.AmplitudeEstimation
import all FQChemQatlib.Properties.ClassicalShadows
import all FQChemQatlib.Properties.LinearSystems
import all FQChemQatlib.Properties.SignedSineAmplification
import all FQChemQatlib.Properties.SignedSineClock
import all FQChemQatlib.Properties.SignedSineHermitian
import all FQChemQatlib.Properties.SignedSineQueries
import all FQChemQatlib.Properties.SignedSineUncompute
import all FQChemKitaev
import all FQChemKitaev.AmplificationBounds
import all FQChemKitaev.AmplifierCost
import all FQChemKitaev.Amplify
import all FQChemKitaev.BoundedErrorReduction
import all FQChemKitaev.Compiler
import all FQChemKitaev.DyadicCoefficients
import all FQChemKitaev.ElectronicStructure
import all FQChemKitaev.HistoryHamiltonian
import all FQChemKitaev.Majority
import all FQChemKitaev.UniformCircuits
import all FQChemKitaev.Wiring
import all FQChem.StatePrep.VariationalOptimization.RayleighRitz
import all FQChem.StatePrep.VariationalOptimization.VQE
import all FQChem.Complexity.ElectronicStructure
import all FQChem.Complexity.ElectronicStructureOperators
import all FQChem.Complexity.ElectronicStructurePauli
import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-! Check the transitive axiom dependencies of the integration's public and private constants. -/

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let roots := #[`FQChemKitaev, `FQChemQatlib]
  let mut expected := roots
  for root in roots do
    let sourceDir : System.FilePath := root.toString
    for file in ← sourceDir.walkDir do
      if file.extension == some "lean" then
        expected := expected.push ((file.withExtension "").components.foldl Name.str Name.anonymous)
  for modName in expected do
    unless env.header.modules.any (fun imp => imp.module == modName && imp.importAll) do
      throwError "Missing import all for integration source module {modName}"
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut count : Nat := 0
  let mut theorems : Nat := 0
  let mut privateCount : Nat := 0
  for modName in env.header.moduleNames, data in env.header.moduleData do
    if roots.any (·.isPrefixOf modName) || (`FQChem).isPrefixOf modName then
      for name in data.constNames do
        let some info := env.find? name | throwError "Missing kernel declaration {name}"
        if info.isAxiom then throwError "Unexpected integration axiom {name}"
        let extra := (← Lean.collectAxioms name).filter (!allowed.contains ·)
        unless extra.isEmpty do throwError "{name} depends on {extra}"
        count := count + 1
        if info.isTheorem then theorems := theorems + 1
        if isPrivateName name then privateCount := privateCount + 1
  if theorems == 0 || privateCount == 0 then
    throwError "Integration audit did not load both theorem and private declarations"
  logInfo m!"Checked {count} declarations from {expected.size} integration module(s), including {theorems} theorems and {privateCount} private declarations."
