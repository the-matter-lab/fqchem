import FormalQChem
import Lean.Util.CollectAxioms
import Lean.Elab.Command

/-! Check the transitive axiom dependencies of every theorem exported by this package. -/

open Lean Elab Command in
run_cmd do
  let env ← getEnv
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
  logInfo m!"Verified axiom dependencies of {count} theorem declarations."
