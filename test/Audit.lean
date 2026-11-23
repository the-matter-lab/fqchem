import FormalQChem
import Lean.Util.CollectAxioms
import Lean.Elab.Command

/-! Check the transitive axiom dependencies of every theorem exported by this package. -/

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let mut sourceModules : Nat := 0
  for file in ← ("FormalQChem" : System.FilePath).walkDir do
    if file.extension == some "lean" then
      let modName := (file.withExtension "").components.foldl Name.str Name.anonymous
      unless env.header.moduleNames.contains modName do
        throwError "The library root does not import {modName}"
      sourceModules := sourceModules + 1
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut count : Nat := 0
  for (name, info) in env.constants.toList do
    if `FormalQChem |>.isPrefixOf name then
      match info with
      | .axiomInfo _ => throwError "Unexpected axiom {name}"
      | .thmInfo _ =>
        let extra := (← Lean.collectAxioms name).filter (!allowed.contains ·)
        unless extra.isEmpty do throwError "{name} depends on {extra}"
        count := count + 1
      | _ => pure ()
  if count == 0 then throwError "No package theorems were imported"
  logInfo m!"Imported all {sourceModules} source modules. Verified axiom dependencies of {count} theorem declarations."
