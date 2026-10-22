/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
import EnsdfCheck.Classify

/-!

# ENSDF check: command line

`lake exe ensdf-check <dir> [report.md]` checks all gamma transitions in the files `ensdf.*` of
`<dir>` and writes the report (default `<dir>/../bericht.md`) with tab-separated lists of the A, A'
and B hits next to it. `--parse-stats` and `--placement-stats` report how the fields were read and
how the final levels were found.

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

/-- The category of a placement for the statistics. -/
def placeKey : Placement → String
  | .ok _ true false => "ok via FL="
  | .ok _ true true => "ok via FL= with ?"
  | .ok _ false _ => "ok via E_i - E_γ"
  | .unplaced => "unplaced"
  | .flUnknown => "FL=?"
  | .flNotFound => "FL= not found"
  | .badEnergy => "energy unreadable or offset"
  | .noMatch => "no matching level"
  | .ambiguous => "ambiguous"

/-- Statistics of the final level assignment, for gammas with a multipolarity. -/
def placementStats (dir : System.FilePath) : IO Unit := do
  let entries ← dir.readDir
  let files := (entries.filter fun e => e.fileName.startsWith "ensdf.").qsort
    (fun a b => a.fileName < b.fileName)
  let mut pt : Tally := {}
  let mut ptAll : Tally := {}
  for f in files do
    for d in parseFile f.fileName (← readAscii f.path) do
      let levelE := d.levels.map fun l => parseEnergy l.e
      for g in d.gammas do
        let p := placeGamma d levelE g
        let ex := s!"{f.fileName}:{g.line} [{String.ofList (trimL g.e)}]"
        ptAll := ptAll.add (placeKey p) ex 4
        match parseM g.m with
        | .empty => pure ()
        | _ => pt := pt.add (placeKey p) ex
  pt.print "Placement of gammas with a multipolarity"
  ptAll.print "Placement of all gammas"

/-- One row of the hit lists. -/
structure Hit where
  /-- Category. -/
  cat : Category
  /-- File and line of the gamma record. -/
  loc : String
  /-- Nuclide. -/
  nucid : String
  /-- Data set identification. -/
  dsid : String
  /-- Initial level energy and Jπ. -/
  ei : String
  ji : String
  /-- Final level energy and Jπ. -/
  ef : String
  jf : String
  /-- Gamma energy and multipolarity. -/
  eg : String
  m : String
  /-- Certificate data for `A`. -/
  cert : Option (Nat × Nat × Nat)

/-- Markdown-safe text of a field. -/
def fld (l : List Char) : String :=
  (String.ofList (trimL l)).replace "|" "/"

/-- The Lean file with one kernel-checked certificate per A hit. -/
def certificates (dir : System.FilePath) (hits : Array Hit) : String := Id.run do
  let mut s := "/-\nCopyright (c) 2026 Daniel Leonforte. All rights reserved.\n" ++
    "Released under Apache 2.0 license as described in the file LICENSE.\n" ++
    "Authors: Daniel Leonforte\n-/\n" ++
    "import PhyslibAlpha.QuantumMechanics.AngularMomentum.SelectionRules\n\n" ++
    "/-!\n\n# ENSDF check: certificates for the category A hits\n\n" ++
    "Generated by `lake exe ensdf-check <dir> <report> --certificates <file>`\nfrom `" ++
    dir.toString ++ "`.\n\n" ++
    "For each hit: no multipole of the given order, electric or magnetic, with any\n" ++
    "parities, is allowed between the two spins (doubled units), because the triangle\n" ++
    "rule fails; `decide` checks this in the kernel. The data in the comments come from\n" ++
    "the unverified parser.\n\n-/\n\nnamespace EnsdfCheck.Certificates\n\n" ++
    "open PhyslibAlpha.Sl2\n"
  for h in hits do
    if let some (x, y, l) := h.cert then
      s := s ++ s!"\n-- {h.nucid}, {h.dsid}, {h.loc}: {h.ei} {h.ji} → {h.ef} {h.jf}, " ++
        s!"E_γ = {h.eg}, M = {h.m}\n" ++
        "example : ∀ (t : MultipoleType) (πi πf : ℤ),\n" ++
        s!"    ¬ IsAllowedMultipole {x} {y} πi πf t {l} :=\n" ++
        "  fun _ _ _ h => absurd h.2.1 (by decide)\n"
  return s ++ "\nend EnsdfCheck.Certificates\n"

/-- Run the check and write the report. -/
def runCheck (dir : System.FilePath) (out : System.FilePath)
    (cert : Option System.FilePath := none) : IO Unit := do
  let entries ← dir.readDir
  let files := (entries.filter fun e => e.fileName.startsWith "ensdf.").qsort
    (fun a b => a.fileName < b.fileName)
  let mut total : Nat := 0
  let mut cats : Tally := {}
  let mut hits : Array Hit := #[]
  let mut bHits : Array Hit := #[]
  for f in files do
    for d in parseFile f.fileName (← readAscii f.path) do
      let levelE := d.levels.map fun l => parseEnergy l.e
      for g in d.gammas do
        match classify d levelE g with
        | none => pure ()
        | some r =>
          total := total + 1
          let loc := s!"{f.fileName}:{g.line}"
          cats := cats.add s!"{r.cat.name}	{r.reason}" loc 3
          if r.cat == .a || r.cat == .a' || r.cat == .b then
            let li := g.level.map (d.levels[·]!)
            let lf := r.final.map (d.levels[·]!)
            let h : Hit := ⟨r.cat, loc, d.nucid, d.dsid,
              (li.map (fld ·.e)).getD "", (li.map (fld ·.j)).getD "",
              (lf.map (fld ·.e)).getD "", (lf.map (fld ·.j)).getD "",
              fld g.e, fld g.m, r.cert⟩
            if r.cat == .b then bHits := bHits.push h else hits := hits.push h
  -- report
  let byCat (cat : Category) : Nat :=
    cats.counts.fold (fun n k v => if k.startsWith (cat.name ++ "\t") then n + v else n) 0
  let mut s := "# ENSDF check against the selection rules of `SelectionRules.lean`\n\n"
  s := s ++ s!"Data: `{dir}`. Gamma transitions with a multipolarity: {total}.\n\n"
  s := s ++ "Only category A rests on a theorem (`IsTensorOperator.triangleRule`); A' uses the " ++
    "parity rule, which is a definition in PR 08. The parser and the final level assignment " ++
    "are unverified code.\n\n"
  s := s ++ "| Category | Count |\n|---|---|\n"
  for cat in [Category.a, .a', .b, .c, .p, .n, .ok] do
    s := s ++ s!"| {cat.name} | {byCat cat} |\n"
  s := s ++ "\n## Subcategories\n\n| Category | Reason | Count | Examples |\n|---|---|---|---|\n"
  let l := cats.counts.toList.toArray.qsort (fun a b => a.1 < b.1)
  for (k, n) in l do
    let parts := k.splitOn "\t"
    s := s ++ s!"| {parts.headD ""} | {parts.getD 1 ""} | {n} | " ++
      s!"{", ".intercalate (cats.examples.getD k #[]).toList} |\n"
  for (cat, title) in [(Category.a, "A: angular momentum rule violated, everything firm"),
      (.a', "A': only the parity rule violated, everything firm")] do
    s := s ++ s!"\n## {title}\n\n" ++
      "| Nuclide | E_i | Jπ_i | E_f | Jπ_f | E_γ | M | Data set | Record |\n" ++
      "|---|---|---|---|---|---|---|---|---|\n"
    for h in hits.filter (·.cat == cat) do
      s := s ++ s!"| {h.nucid} | {h.ei} | {h.ji} | {h.ef} | {h.jf} | {h.eg} | {h.m} | " ++
        s!"{h.dsid} | {h.loc} |\n"
  IO.FS.writeFile out s
  -- tab-separated lists for further use
  let tsv (hs : Array Hit) : String := hs.foldl (fun acc h =>
    acc ++ s!"{h.cat.name}\t{h.nucid}\t{h.ei}\t{h.ji}\t{h.ef}\t{h.jf}\t{h.eg}\t{h.m}\t" ++
      s!"{h.dsid}\t{h.loc}\t" ++
      (match h.cert with | some (x, y, l) => s!"{x} {y} {l}" | none => "") ++ "\n") ""
  IO.FS.writeFile (out.withExtension "AA.tsv") (tsv hits)
  IO.FS.writeFile (out.withExtension "B.tsv") (tsv bHits)
  if let some c := cert then IO.FS.writeFile c (certificates dir (hits.filter (·.cat == .a)))
  IO.println (s!"{total} transitions; A {byCat .a}, A' {byCat .a'}, B {byCat .b}, " ++
    s!"C {byCat .c}, P {byCat .p}, N {byCat .n}, ok {byCat .ok}")

/-- Entry point. -/
def main (args : List String) : IO UInt32 := do
  match args with
  | [dir, "--parse-stats"] => parseStats dir; return 0
  | [dir, "--placement-stats"] => placementStats dir; return 0
  | [dir] => runCheck dir ((System.FilePath.mk dir) / ".." / "bericht.md"); return 0
  | [dir, out] => runCheck dir out; return 0
  | [dir, out, "--certificates", c] => runCheck dir out (some c); return 0
  | _ =>
    IO.eprintln ("usage: ensdf-check <dir> [report.md [--certificates file.lean]] | " ++
      "<dir> (--parse-stats | --placement-stats)")
    return 1
