-- generate.py prepends imports with private declaration data for each source module.
import Lean

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let home (n : Name) := (env.getModuleIdxFor? n).map fun i => env.header.moduleNames[i.toNat]!
  let localModule (m : Name) := (`FormalQChem).isPrefixOf m || (`FormalQChemKitaev).isPrefixOf m
  let upstream (m : Name) := (`AaronsonAmbainisPort).isPrefixOf m || (`AaronsonAmbainis).isPrefixOf m || (`Qatlib).isPrefixOf m
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut externalTheorems : NameSet := {}
  for (n, info) in env.constants.toList do
    let some m := home n | continue
    unless localModule m do continue
    let refs := info.getUsedConstantsAsSet.toList
    let mut selected := #[]
    for other in refs do
      let some owner := home other | continue
      if localModule owner then
        selected := selected.push other.toString
      else if upstream owner then
        -- An upstream module's public facet can erase a theorem body and expose
        -- an axiomInfo. The Python side verifies its source declaration and location.
        match env.find? other with
        | some (.thmInfo _) | some (.axiomInfo _) =>
          externalTheorems := externalTheorems.insert other
          selected := selected.push other.toString
        | _ => pure ()
    let r ← findDeclarationRangesCore? n
    let line := r.map (·.selectionRange.pos.line)
    let theoremInfo := match info with | .thmInfo _ => true | _ => false
    if theoremInfo && line.isSome then
      let extra := (← collectAxioms n).filter (!allowed.contains ·)
      unless extra.isEmpty do throwError "{n} depends on unexpected axioms {extra}"
    IO.println (Json.compress (Json.mkObj [
      ("id", toJson n.toString), ("name", toJson (privateToUserName n).toString),
      ("module", toJson m.toString), ("line", toJson line), ("theorem", toJson theoremInfo),
      ("refs", toJson selected)]))
  for n in externalTheorems do
    let r ← findDeclarationRangesCore? n
    IO.println (Json.compress (Json.mkObj [
      ("id", toJson n.toString), ("name", toJson (privateToUserName n).toString),
      ("module", toJson ((home n).get!).toString), ("line", toJson (r.map (·.selectionRange.pos.line))),
      ("external", toJson true), ("theorem", toJson true), ("refs", Json.arr #[])]))
