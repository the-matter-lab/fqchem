import Lake
open Lake DSL System

package aaCompat

require AaronsonAmbainis from git
  "https://github.com/physical-superintelligence/aaronson-ambainis.git" @
  "2a6ceaef872ae993708950f951989134084b851a"

target portSources pkg : Unit := do
  let some upstream ← findPackageByName? `AaronsonAmbainis
    | error "missing pinned AaronsonAmbainis source package"
  Job.async do
    proc {
      cmd := "python3"
      args := #[(pkg.dir / "prepare.py").toString, upstream.dir.toString,
        (pkg.dir / ".lake" / "ported").toString]
    }

@[default_target]
lean_lib AaronsonAmbainisPort where
  srcDir := ".lake/ported"
  needs := #[portSources]
