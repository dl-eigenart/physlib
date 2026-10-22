/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
import EnsdfCheck.Parse

/-!

# ENSDF check: command line

`lake exe ensdf-check <dir> --parse-stats` reads all files `ensdf.*` in `<dir>` and reports how
the Jπ and multipolarity fields were read.

-/

open EnsdfCheck

/-- Read a file byte by byte as characters (ENSDF is ASCII). -/
def readAscii (p : System.FilePath) : IO String := do
  let b ← IO.FS.readBinFile p
  return String.ofList (b.toList.map fun x => Char.ofNat x.toNat)

/-- A counter with up to `k` examples per key. -/
structure Tally where
  /-- Counts. -/
  counts : Std.HashMap String Nat := {}
  /-- Examples. -/
  examples : Std.HashMap String (Array String) := {}

/-- Count `key` and keep `ex` as an example if fewer than `k` are stored. -/
def Tally.add (t : Tally) (key ex : String) (k : Nat := 8) : Tally :=
  let exs := t.examples.getD key #[]
  { counts := t.counts.insert key (t.counts.getD key 0 + 1)
    examples := if exs.size < k then t.examples.insert key (exs.push ex) else t.examples }

/-- Print a tally sorted by count. -/
def Tally.print (t : Tally) (title : String) : IO Unit := do
  IO.println s!"## {title}"
  let l := t.counts.toList.toArray.qsort (fun a b => a.2 > b.2)
  for (k, n) in l do
    IO.println s!"{n}\t{k}\t{(t.examples.getD k #[]).toList}"

/-- The category of a Jπ field for the statistics. -/
def jKey : JParse → String
  | .empty => "empty"
  | .unparsable => "UNPARSABLE"
  | .unchecked k => s!"unchecked: {k}"
  | .ok [a] => if a.parity.isNone then "single, no parity"
      else if a.jTent || a.pTent then "single, bracketed" else "single, firm"
  | .ok _ => "list"

/-- The category of a multipolarity field for the statistics. -/
def mKey : MParse → String
  | .empty => "empty"
  | .unparsable => "UNPARSABLE"
  | .unchecked k => s!"unchecked: {k}"
  | .ok [cs] => if cs.any (·.tent) then "single, bracketed" else
      if cs.length > 1 then "mixed, firm" else "single, firm"
  | .ok _ => "alternatives"

/-- Statistics of the parser over all files. -/
def parseStats (dir : System.FilePath) : IO Unit := do
  let entries ← dir.readDir
  let files := (entries.filter fun e => e.fileName.startsWith "ensdf.").qsort
    (fun a b => a.fileName < b.fileName)
  let mut nDs := 0
  let mut nL := 0
  let mut nG := 0
  let mut nFL := 0
  let mut jt : Tally := {}
  let mut mt : Tally := {}
  let mut et : Tally := {}
  for f in files do
    let ds := parseFile f.fileName (← readAscii f.path)
    for d in ds do
      nDs := nDs + 1
      for l in d.levels do
        nL := nL + 1
        let raw := String.ofList (trimL l.j)
        jt := jt.add (jKey (parseJ l.j)) s!"{f.fileName}:{l.line} [{raw}]"
        if (parseEnergy l.e).isNone then
          et := et.add "level energy" s!"{f.fileName}:{l.line} [{String.ofList (trimL l.e)}]"
      for g in d.gammas do
        nG := nG + 1
        if g.fl.isSome then nFL := nFL + 1
        let raw := String.ofList (trimL g.m)
        mt := mt.add (mKey (parseM g.m)) s!"{f.fileName}:{g.line} [{raw}]"
        if (parseEnergy g.e).isNone then
          et := et.add "gamma energy" s!"{f.fileName}:{g.line} [{String.ofList (trimL g.e)}]"
  IO.println s!"files {files.size}, data sets {nDs}, levels {nL}, gammas {nG}, FL= {nFL}"
  jt.print "Jπ fields"
  mt.print "Multipolarity fields"
  et.print "Unreadable energies"

/-- Entry point. -/
def main (args : List String) : IO UInt32 := do
  match args with
  | [dir, "--parse-stats"] => parseStats dir; return 0
  | _ => IO.eprintln "usage: ensdf-check <dir> --parse-stats"; return 1
