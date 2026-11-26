-- The driver imports the full facets of the modules listed in auditModules.
open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  for modName in auditModules do
    let some idx := env.header.moduleNames.idxOf? modName
      | throwError "Missing compiled module {modName}"
    let data := env.header.moduleData[idx]!
    if data.isModule && !env.header.modules[idx]!.importAll then
      throwError "Private declaration data missing for {modName}"
    let mut thms := 0
    let mut priv := 0
    let mut counts := #[0, 0, 0]
    for name in data.constNames do
      let some info := env.find? name | throwError "Missing kernel declaration {name}"
      if info.isAxiom then throwError "Axiom declared in {modName}: {name}"
      let deps ← Lean.collectAxioms name
      let extra := deps.filter (!allowed.contains ·)
      unless extra.isEmpty do throwError "{modName}: {name} depends on unapproved axioms {extra}"
      for i in [:allowed.size] do
        if deps.contains allowed[i]! then counts := counts.modify i (· + 1)
      if info.isTheorem then thms := thms + 1
      if isPrivateName name then priv := priv + 1
    let usage := Json.mkObj <| (allowed.zip counts).toList.map fun (n, c) => (n.toString, toJson c)
    let row := Json.mkObj [("module", toJson modName.toString), ("declarations", toJson data.constNames.size),
      ("theorems", toJson thms), ("private", toJson priv), ("uses", usage)]
    IO.println ("FQCHEM_AUDIT " ++ row.compress)
