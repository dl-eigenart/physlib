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
  | .onlyBroad => "only a broad level"

/-- Statistics of the final level assignment, for gammas with a multipolarity. -/
def placementStats (dir : System.FilePath) : IO Unit := do
  let entries ← dir.readDir
  let files := (entries.filter fun e => e.fileName.startsWith "ensdf.").qsort
    (fun a b => a.fileName < b.fileName)
  let mut pt : Tally := {}
  let mut ptAll : Tally := {}
  for f in files do
    let dss := parseFile f.fileName (← readAscii f.path)
    for d in dss do
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
  /-- Final level from `FL=`. -/
  viaFL : Bool
  /-- Whether the Adopted data set shows the same violation. -/
  inAdopted : String := ""
  /-- Whether the Adopted data set contradicts the hit, with details. -/
  adoptedContra : String := ""

/-- Markdown-safe text of a field. -/
def fld (l : List Char) : String :=
  (String.ofList (trimL l)).replace "|" "/"

/-- Whether a data set is the Adopted Levels (and Gammas) data set. -/
def EnsdfCheck.Dataset.isAdopted (d : Dataset) : Bool := d.dsid.startsWith "ADOPTED LEVELS"

/-- The index of the closest element whose energy agrees with `e` within three combined standard
uncertainties or 1 keV, whichever is larger, if any. The 1 keV floor covers energies given without
uncertainty to different precision in different data sets (`2109.4` and `2109.964`). -/
def closestMatch (cands : List (Nat × List Char × List Char)) (e : List Char) (de : List Char) :
    Option Nat :=
  match parseEnergy e with
  | some ⟨o, some x⟩ =>
    let ok := cands.filterMap fun (k, e', de') =>
      match parseEnergy e' with
      | some ⟨o', some y⟩ =>
        let d := Float.abs (x.value - y.value)
        let sx := sigma x de
        let sy := sigma y de'
        let tol := max (3.0 * Float.sqrt (sx * sx + sy * sy)) 1.0
        if o == o' && d ≤ tol then some (k, d) else none
      | _ => none
    (ok.foldl (fun (best : Option (Nat × Float)) c =>
      match best with
      | some b => if c.2 < b.2 then some c else some b
      | none => some c) none).map (·.1)
  | _ => none

/-- Compare a hit with the Adopted data set of the same nuclide. The initial level, the gamma and
the final level are matched by energy; the Adopted gamma is then classified in the same way, with
its final level fixed to the matched one. Returns the entries of the columns "also in Adopted" and
"Adopted contradicts". A violation in Adopted (A, A' or B) counts as "also in Adopted"; Adopted
contradicts only if it gives an allowed transition or no multipolarity; other outcomes (placement
or Jπ not checkable in Adopted) are "unclear". -/
def adoptedCompare (ad : Dataset) (li : LevelRec) (lf : Option LevelRec) (g : GammaRec)
    (broad : Float := broadKeV) : String × String :=
  let adE := ad.levels.map fun l => parseEnergy l.e
  let lvls := (List.range ad.levels.size).map fun k => (k, ad.levels[k]!.e, ad.levels[k]!.de)
  match closestMatch lvls li.e li.de with
  | none => ("level not in Adopted", "–")
  | some k =>
    let gs := (List.range ad.gammas.size).filter (fun n => ad.gammas[n]!.level == some k) |>.map
      fun n => (n, ad.gammas[n]!.e, ad.gammas[n]!.de)
    match closestMatch gs g.e g.de with
    | none => ("gamma not in Adopted", "–")
    | some n =>
      let ga := ad.gammas[n]!
      -- fix the final level to the Adopted level matching the hit's final level
      let ga := match lf.bind (fun l => closestMatch lvls l.e l.de) with
        | some kf => { ga with fl := some ad.levels[kf]!.e }
        | none => ga
      let m := fld ga.m
      match classify ad adE ga broad with
      | none => ("no", "yes: no multipolarity in Adopted")
      | some r =>
        let jf := (r.final.map fun f => fld ad.levels[f]!.j).getD "?"
        if r.cat == .a || r.cat == .a' || r.cat == .b then
          (s!"yes, as {r.cat.name} ({r.reason})", "no")
        else if r.cat == .ok || (r.cat == .c && r.reason == "D/Q without type, allowed") then
          ("no", s!"yes: M={m}, J_f={jf}, allowed")
        else (s!"unclear: {r.cat.name} ({r.reason})", "unclear")

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
    (cert : Option System.FilePath := none) (broad : Float := broadKeV) : IO Unit := do
  let entries ← dir.readDir
  let files := (entries.filter fun e => e.fileName.startsWith "ensdf.").qsort
    (fun a b => a.fileName < b.fileName)
  let mut total : Nat := 0
  let mut cats : Tally := {}
  let mut hits : Array Hit := #[]
  let mut bHits : Array Hit := #[]
  let mut sLevels : Array String := #[]
  for f in files do
    let dss := parseFile f.fileName (← readAscii f.path)
    for d in dss do
      let levelE := d.levels.map fun l => parseEnergy l.e
      if let some a := d.massNumber then
        for l in d.levels do
          let j := parseJ l.j
          if spinMassMismatch a j then
            let firmJ := match j with
              | .ok [c] => !c.jTent
              | _ => false
            sLevels := sLevels.push (s!"| {d.nucid} | {fld l.e} | {fld l.j} | " ++
              s!"{if firmJ then "firm" else "bracketed or list"} | {d.dsid} | " ++
              s!"{f.fileName}:{l.line} |")
      for g in d.gammas do
        match classify d levelE g broad with
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
              fld g.e, fld g.m, r.cert, r.viaFL, "", ""⟩
            if r.cat == .b then bHits := bHits.push h
            else
              let cmp : String × String :=
                if d.isAdopted then ("yes (Adopted itself)", "–")
                else match dss.find? (fun a => a.isAdopted && a.nucid == d.nucid), li with
                  | some ad, some l => adoptedCompare ad l lf g broad
                  | none, _ => ("no Adopted data set", "–")
                  | _, none => ("–", "–")
              hits := hits.push { h with inAdopted := cmp.1, adoptedContra := cmp.2 }
  -- report
  let byCat (cat : Category) : Nat :=
    cats.counts.fold (fun n k v => if k.startsWith (cat.name ++ "\t") then n + v else n) 0
  let mut s := "# ENSDF check against the selection rules of `SelectionRules.lean`\n\n"
  s := s ++ s!"Data: `{dir}`. Gamma transitions with a multipolarity: {total}.\n\n"
  s := s ++ "Only category A rests on a theorem (`IsTensorOperator.triangleRule`); A' uses the " ++
    "parity rule, which is a definition in PR 08. The parser and the final level assignment " ++
    "are unverified code.\n\n"
  s := s ++ "| Category | Count |\n|---|---|\n"
  for cat in [Category.a, .a', .b, .c, .s, .p, .n, .ok] do
    s := s ++ s!"| {cat.name} | {byCat cat} |\n"
  s := s ++ "\n## Subcategories\n\n| Category | Reason | Count | Examples |\n|---|---|---|---|\n"
  let l := cats.counts.toList.toArray.qsort (fun a b => a.1 < b.1)
  for (k, n) in l do
    let parts := k.splitOn "\t"
    s := s ++ s!"| {parts.headD ""} | {parts.getD 1 ""} | {n} | " ++
      s!"{", ".intercalate (cats.examples.getD k #[]).toList} |\n"
  for (cat, title) in [(Category.a, "A: angular momentum rule violated, everything firm"),
      (.a', "A': only the parity rule violated, everything firm")] do
    for viaFL in [true, false] do
      let sub := if viaFL then "final level from FL=" else "final level from E_i - E_γ - E_R"
      let hs := hits.filter fun h => h.cat == cat && h.viaFL == viaFL
      s := s ++ s!"\n## {title}; {sub} ({hs.size})\n\n" ++
        "| Nuclide | E_i | Jπ_i | E_f | Jπ_f | E_γ | M | Data set | Record | also in Adopted | " ++
        "Adopted contradicts |\n|---|---|---|---|---|---|---|---|---|---|---|\n"
      for h in hs do
        s := s ++ s!"| {h.nucid} | {h.ei} | {h.ji} | {h.ef} | {h.jf} | {h.eg} | {h.m} | " ++
          s!"{h.dsid} | {h.loc} | {h.inAdopted} | {h.adoptedContra} |\n"
  s := s ++ s!"\n## S: level records with 2J and A of different parity ({sLevels.size})\n\n" ++
    "All data sets, also levels without a checked gamma transition.\n\n" ++
    "| Nuclide | E | Jπ | Jπ firm | Data set | Record |\n|---|---|---|---|---|---|\n"
  for r in sLevels do
    s := s ++ r ++ "\n"
  IO.FS.writeFile out s
  -- tab-separated lists for further use
  let tsv (hs : Array Hit) : String := hs.foldl (fun acc h =>
    acc ++ s!"{h.cat.name}\t{h.nucid}\t{h.ei}\t{h.ji}\t{h.ef}\t{h.jf}\t{h.eg}\t{h.m}\t" ++
      s!"{h.dsid}\t{h.loc}\t{if h.viaFL then "FL=" else "dE"}\t{h.inAdopted}\t" ++
      s!"{h.adoptedContra}\t" ++
      (match h.cert with | some (x, y, l) => s!"{x} {y} {l}" | none => "") ++ "\n") ""
  IO.FS.writeFile (out.withExtension "AA.tsv") (tsv hits)
  IO.FS.writeFile (out.withExtension "B.tsv") (tsv bHits)
  if let some c := cert then IO.FS.writeFile c (certificates dir (hits.filter (·.cat == .a)))
  IO.println (s!"{total} transitions; A {byCat .a}, A' {byCat .a'}, B {byCat .b}, " ++
    s!"C {byCat .c}, S {byCat .s}, P {byCat .p}, N {byCat .n}, ok {byCat .ok}")

/-- Entry point. -/
def main (args : List String) : IO UInt32 := do
  match args with
  | [dir, "--parse-stats"] => parseStats dir; return 0
  | [dir, "--placement-stats"] => placementStats dir; return 0
  | [dir] => runCheck dir ((System.FilePath.mk dir) / ".." / "bericht.md"); return 0
  | [dir, out] => runCheck dir out; return 0
  | [dir, out, "--certificates", c] => runCheck dir out (some c); return 0
  | [dir, out, "--broad", b] =>
    match parseDec b.toList with
    | some x => runCheck dir out none x.value; return 0
    | none => IO.eprintln s!"not a number: {b}"; return 1
  | _ =>
    IO.eprintln ("usage: ensdf-check <dir> [report.md [--certificates file.lean | " ++
      "--broad keV]] | " ++
      "<dir> (--parse-stats | --placement-stats)")
    return 1
