module

import all FormalQChemKitaev
import all FormalQChemKitaev.ElectronicStructure
import all FormalQChem.StatePrep.VariationalOptimization.RayleighRitz
import all FormalQChem.StatePrep.VariationalOptimization.VQE
import all FormalQChem.Complexity.ElectronicStructure
import all FormalQChem.Complexity.ElectronicStructureOperators
import all FormalQChem.Complexity.ElectronicStructurePauli
import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-! Check the transitive axiom dependencies of the integration's public and private constants. -/

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let root := `FormalQChemKitaev
  let mut expected := #[root]
  let sourceDir : System.FilePath := "FormalQChemKitaev"
  if ← sourceDir.isDir then
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
    if root.isPrefixOf modName || (`FormalQChem).isPrefixOf modName then
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
