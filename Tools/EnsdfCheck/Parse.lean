/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
import EnsdfCheck.Rules

/-!

# ENSDF check: reading the records

Reads the 80-column records of an ENSDF file and decomposes the fields used by the check: level
energy and Jπ, gamma energy, multipolarity and mixing ratio, and the final level `FL=` from the
continuation records. Column positions follow the ENSDF manual (BNL-NCS-51655-01/02-Rev,
sections III.B.9, III.B.14, IV.B, IV.C.2, V.18–V.20).

This is unverified code. Fields that cannot be read are reported, never guessed.

-/

namespace EnsdfCheck

open PhyslibAlpha.Sl2

/-! ## Characters and columns -/

/-- Drop leading and trailing whitespace. -/
def trimL (s : List Char) : List Char :=
  ((s.dropWhile Char.isWhitespace).reverse.dropWhile Char.isWhitespace).reverse

/-- Columns `a` to `b` (1-based, inclusive) of a record. -/
def cols (r : Array Char) (a b : Nat) : List Char := (r.extract (a - 1) b).toList

/-- Column `a` of a record, a blank if the record is shorter. -/
def col (r : Array Char) (a : Nat) : Char := r.getD (a - 1) ' '

/-- Split a list at every element satisfying `p`. -/
def splitBy {α : Type} (p : α → Bool) : List α → List (List α)
  | [] => [[]]
  | x :: xs =>
    if p x then [] :: splitBy p xs
    else match splitBy p xs with
      | [] => [[x]]
      | y :: ys => (x :: y) :: ys

/-- Whether `p` occurs in `s` as a contiguous sublist. -/
def hasSub (s p : List Char) : Bool :=
  (List.range (s.length + 1)).any fun i => (s.drop i).take p.length == p

/-- Replace every occurrence of `p` by `q`. -/
partial def replaceSub (s p q : List Char) : List Char :=
  match s with
  | [] => []
  | c :: t => if p ≠ [] && s.take p.length == p then q ++ replaceSub (s.drop p.length) p q
    else c :: replaceSub t p q

/-- A natural number written with decimal digits only. -/
def digitsToNat (l : List Char) : Option Nat :=
  if l.isEmpty || !l.all Char.isDigit then none
  else some (l.foldl (fun n c => 10 * n + (c.toNat - '0'.toNat)) 0)

/-! ## Numbers and energies -/

/-- A decimal number together with the place value of its last digit, so that an ENSDF
uncertainty `n` (in units of the last digit, manual V.11) is `n * unit`. -/
structure Dec where
  /-- The value. -/
  value : Float
  /-- The place value of the last digit. -/
  unit : Float
  deriving Repr

/-- `10^k` for an integer `k`. -/
def pow10 (k : Int) : Float :=
  if k ≥ 0 then Float.pow 10.0 k.toNat.toFloat else 1.0 / Float.pow 10.0 (-k).toNat.toFloat

/-- Parse `[sign]digits[.digits][E[sign]digits]`. -/
def parseDec (s : List Char) : Option Dec := do
  let (neg, s) := match s with
    | '-' :: t => (true, t)
    | '+' :: t => (false, t)
    | _ => (false, s)
  let ip := s.takeWhile Char.isDigit
  let s1 := s.drop ip.length
  let (fp, s2) := match s1 with
    | '.' :: t => (t.takeWhile Char.isDigit, t.drop (t.takeWhile Char.isDigit).length)
    | _ => ([], s1)
  if ip.isEmpty && fp.isEmpty then none
  let e : Int ← match s2 with
    | [] => some 0
    | 'E' :: '-' :: t => (digitsToNat t).map fun n => -(n : Int)
    | 'E' :: '+' :: t => (digitsToNat t).map fun n => (n : Int)
    | 'E' :: t => (digitsToNat t).map fun n => (n : Int)
    | _ => none
  let m ← digitsToNat (ip ++ fp)
  let k : Int := e - fp.length
  let v := m.toFloat * pow10 k
  pure ⟨if neg then -v else v, pow10 k⟩

/-- An ENSDF energy (manual V.18): a number, possibly relative to an unknown offset such as
`1234.5+X`, `X+1234.5` or `SN+20`, or only an offset. -/
structure Energy where
  /-- The offset label, empty if there is none. -/
  offset : String
  /-- The number, if any. -/
  num : Option Dec
  deriving Repr

/-- Parse an energy field. Parentheses (deduced value) are dropped. -/
def parseEnergy (s : List Char) : Option Energy :=
  let s := trimL s
  let s := match s with
    | '(' :: t => if t.getLast? == some ')' then t.dropLast else s
    | _ => s
  let s := trimL s
  -- an exponent `E+3` or `e3` is not an offset
  let s := replaceSub (s.map fun c => if c == 'e' then 'E' else c) "E+".toList "E".toList
  let isLetters (l : List Char) := !l.isEmpty && l.all Char.isUpper
  match splitBy (· == '+') s with
  | [a] =>
    match parseDec a with
    | some d => some ⟨"", some d⟩
    | none => if isLetters a then some ⟨String.ofList a, none⟩ else none
  | [a, b] =>
    match parseDec a, parseDec b with
    | some d, none => if isLetters b then some ⟨String.ofList b, some d⟩ else none
    | none, some d => if isLetters a then some ⟨String.ofList a, some d⟩ else none
    | _, _ => none
  | _ => none

/-- A symmetric uncertainty in units of the last digit (manual V.11); `none` if it is blank or
not numeric (`LT`, `GT`, `AP`, `CA`, `SY`, …). -/
def parseUnc (s : List Char) : Option Nat := digitsToNat (trimL s)

/-! ## Spin and parity -/

/-- One alternative of a Jπ field. -/
structure SpinCand where
  /-- Twice the spin. -/
  twoJ : Nat
  /-- The parity `±1`, if given. -/
  parity : Option Int
  /-- The spin is in brackets (parentheses or square brackets). -/
  jTent : Bool
  /-- The parity is in brackets. -/
  pTent : Bool
  deriving Repr, BEq, Inhabited

/-- The result of reading a Jπ field. -/
inductive JParse
  /-- Blank field. -/
  | empty
  /-- One or more alternatives (`3/2+`, `(3/2,5/2)+`, `1-,2-`, …). -/
  | ok (alts : List SpinCand)
  /-- A form that is understood but not checked: unknown offset (`J+2`), bound (`LE 3`), range
  (`0+ TO 3+`), `NATURAL`, `NOT`, doublet (`&`), parity only (`+`). -/
  | unchecked (kind : String)
  /-- Not readable. -/
  | unparsable
  deriving Repr

/-- Opening bracket. -/
def isOpen (c : Char) : Bool := c == '(' || c == '['

/-- Closing bracket. -/
def isClose (c : Char) : Bool := c == ')' || c == ']'

/-- Attach to each character whether it lies inside brackets. -/
def flagChars (s : List Char) : List (Char × Bool) :=
  (s.foldl (fun (acc : List (Char × Bool) × Nat) c =>
    let (out, d) := acc
    if isOpen c then ((c, d > 0) :: out, d + 1)
    else if isClose c then ((c, d > 1) :: out, d - 1)
    else ((c, d > 0) :: out, d)) ([], 0)).1.reverse

/-- The index of the bracket that closes the opening bracket at position `0`. -/
def closeIdx (s : List Char) : Option Nat := go s 0 0
where
  /-- Scan with position `i` and depth `d`. -/
  go : List Char → Nat → Nat → Option Nat
    | [], _, _ => none
    | c :: t, i, d =>
      if isOpen c then go t (i + 1) (d + 1)
      else if isClose c then (if d == 1 then some i else go t (i + 1) (d - 1))
      else go t (i + 1) d

/-- Split at commas outside brackets. -/
def splitTop (s : List (Char × Bool)) : List (List (Char × Bool)) :=
  let r := s.foldl (fun (acc : List (List (Char × Bool)) × List (Char × Bool) × Nat) x =>
    let (parts, cur, d) := acc
    if x.1 == ',' && d == 0 then (cur.reverse :: parts, [], d)
    else if isOpen x.1 then (parts, x :: cur, d + 1)
    else if isClose x.1 then (parts, x :: cur, d - 1)
    else (parts, x :: cur, d)) ([], [], 0)
  (r.2.1.reverse :: r.1).reverse

/-- A spin value `N` or `N/2` (manual V.20), in doubled units. -/
def parseSpin (s : List Char) : Option Nat :=
  match splitBy (· == '/') s with
  | [a] => (digitsToNat a).map (2 * ·)
  | [a, ['2']] => digitsToNat a
  | _ => none

/-- One alternative `J`, `Jπ` with brackets anywhere; `common` is a parity standing after a
bracket group, with its bracket flag. -/
def parseAlt (toks : List (Char × Bool)) (common : Option (Int × Bool)) : Option SpinCand :=
  let body := toks.filter fun x => !isOpen x.1 && !isClose x.1
  match body.reverse with
  | [] => none
  | (c, f) :: rest =>
    if c == '+' || c == '-' then
      -- an inner parity must agree with a parity after the group, as in `(5/2-,7/2)-`
      if common.any (fun p => p.1 != (if c == '+' then 1 else -1)) then none
      else
        let js := rest.reverse
        (parseSpin (js.map (·.1))).map fun j =>
          ⟨j, some (if c == '+' then 1 else -1), js.any (·.2), f⟩
    else
      (parseSpin (body.map (·.1))).map fun j =>
        ⟨j, common.map (·.1), body.any (·.2), (common.map (·.2)).getD false⟩

/-- A Jπ expression with brackets and comma-separated alternatives. -/
partial def parseGroup (toks : List (Char × Bool)) (common : Option (Int × Bool)) :
    Option (List SpinCand) :=
  let cs := toks.map (·.1)
  let n := cs.length
  match cs with
  | [] => none
  | c0 :: _ =>
    let last := cs.getLast?.getD ' '
    if isOpen c0 && n ≥ 3 && (last == '+' || last == '-') && closeIdx cs == some (n - 2) then
      if common.isSome then none
      else
        let s := toks.getLast?.getD (' ', false)
        parseGroup ((toks.drop 1).take (n - 3)) (some (if s.1 == '+' then 1 else -1, s.2))
    -- a group followed by a bracketed parity, `(1,2,3)(+)`
    else if isOpen c0 && n ≥ 6 && closeIdx cs == some (n - 4) &&
        isOpen (cs.getD (n - 3) ' ') && isClose last &&
        (cs.getD (n - 2) ' ' == '+' || cs.getD (n - 2) ' ' == '-') then
      if common.isSome then none
      else
        let p : Int := if cs.getD (n - 2) ' ' == '+' then 1 else -1
        parseGroup ((toks.drop 1).take (n - 5)) (some (p, true))
    else if isOpen c0 && closeIdx cs == some (n - 1) then
      parseGroup ((toks.drop 1).take (n - 2)) common
    else
      match splitTop toks with
      | [p] => (parseAlt p common).map ([·])
      | parts => parts.foldr (fun p acc => do
          let a ← acc
          let b ← parseGroup p common
          pure (b ++ a)) (some [])

/-- Read a Jπ field (manual V.20). -/
def parseJ (field : List Char) : JParse :=
  let s := trimL field
  if s.isEmpty then .empty
  else if hasSub s "NOT".toList then .unchecked "not"
  else if hasSub s "NATURAL".toList then .unchecked "natural"
  else if hasSub s "TO".toList || s.contains ':' then .unchecked "range"
  else if ["LE", "GE", "LT", "GT", "AP"].any (fun k => hasSub s k.toList) ||
      s.contains '<' || s.contains '>' then .unchecked "bound"
  else if hasSub s "AND".toList || s.contains '&' then .unchecked "doublet"
  else
    let s := replaceSub s " OR ".toList ",".toList
    if s.any Char.isAlpha then .unchecked "offset"
    else if (s.filter fun c => c != ' ' && !isOpen c && !isClose c).all
        (fun c => c == '+' || c == '-') then .unchecked "parity only"
    else
      let s := s.filter (· != ' ')
      if !s.all (fun c => c.isDigit || "/+-,()[]".toList.contains c) then .unparsable
      else match parseGroup (flagChars s) none with
        | some alts => .ok alts
        | none => .unparsable

/-! ## Multipolarity -/

/-- One component of a multipolarity with its bracket flag. -/
structure MComp where
  /-- The component. -/
  comp : Component
  /-- In brackets: probable `( )` or assumed `[ ]`. -/
  tent : Bool

/-- The result of reading a multipolarity field. -/
inductive MParse
  /-- Blank field. -/
  | empty
  /-- Comma-separated alternatives (manual V.19, `Mult,Mult`), each a list of mixed components. -/
  | ok (alts : List (List MComp))
  /-- `NOT Mult`. -/
  | unchecked (kind : String)
  /-- Not readable. -/
  | unparsable

/-- `Eλ`, `Mλ'` (`λ' ≥ 1`), `D`, `Q`. -/
def parseComp (t : List (Char × Bool)) : Option MComp :=
  let tent := t.any (·.2)
  match t.map (·.1) with
  | ['E', d] => (digitsToNat [d]).map fun l => ⟨.typed .electric l, tent⟩
  | ['M', d] => (digitsToNat [d]).bind fun l =>
      if l ≥ 1 then some ⟨.typed .magnetic l, tent⟩ else none
  | ['D'] => some ⟨.untyped 1, tent⟩
  | ['Q'] => some ⟨.untyped 2, tent⟩
  | _ => none

/-- Read a multipolarity field. An admixture in brackets such as `M1(+E2)` is read as `M1+E2`
with the second component in brackets. -/
def parseM (field : List Char) : MParse :=
  let s := (trimL field).filter (· != ' ')
  if s.isEmpty then .empty
  else if hasSub s "NOT".toList then .unchecked "not"
  else
    let s := replaceSub (replaceSub s "(+".toList "+(".toList) "[+".toList "+[".toList
    let body := (flagChars s).filter fun x => !isOpen x.1 && !isClose x.1
    let alts := (splitBy (·.1 == ',') body).map fun a => (splitBy (·.1 == '+') a).map parseComp
    if alts.all (·.all Option.isSome) then .ok (alts.map (·.filterMap id)) else .unparsable

/-! ## Records and data sets -/

/-- A level record. -/
structure LevelRec where
  /-- Line number in the file. -/
  line : Nat
  /-- Energy, columns 10–19. -/
  e : List Char
  /-- Uncertainty of the energy, columns 20–21. -/
  de : List Char
  /-- Jπ, columns 22–39. -/
  j : List Char
  /-- Half-life or width, columns 40–49. -/
  t : List Char
  /-- Column 80: `?` questionable level, `S` separation energy or expected level. -/
  q : Char
  deriving Inhabited

/-- A gamma record with its continuation records. -/
structure GammaRec where
  /-- Line number in the file. -/
  line : Nat
  /-- Energy, columns 10–19. -/
  e : List Char
  /-- Uncertainty of the energy, columns 20–21. -/
  de : List Char
  /-- Multipolarity, columns 32–41. -/
  m : List Char
  /-- Mixing ratio, columns 42–49. -/
  mr : List Char
  /-- Uncertainty of the mixing ratio, columns 50–55. -/
  dmr : List Char
  /-- Column 77: `*`, `&`, `@` mark multiply placed transitions. -/
  c77 : Char
  /-- Column 80: `?` uncertain placement, `S` expected but unobserved. -/
  q : Char
  /-- The value of `FL=` from a continuation record. -/
  fl : Option (List Char)
  /-- The index of the level record it follows, if any. -/
  level : Option Nat
  deriving Inhabited

/-- An ENSDF data set: the records between an identification record and an end record. -/
structure Dataset where
  /-- Source file. -/
  file : String
  /-- Line number of the identification record. -/
  line : Nat
  /-- Nuclide, columns 1–5. -/
  nucid : String
  /-- Data set identification, columns 10–39. -/
  dsid : String
  /-- Level records in order. -/
  levels : Array LevelRec
  /-- Gamma records in order. -/
  gammas : Array GammaRec

/-- The mass number from the nuclide identification (columns 1–3, manual V.1). -/
def Dataset.massNumber (d : Dataset) : Option Nat :=
  digitsToNat (d.nucid.toList.takeWhile Char.isDigit)

/-- A level width given in the half-life field in energy units (manual V.14: `EV`, `KEV`,
`MEV`), in keV. -/
def parseWidth (t : List Char) : Option Float :=
  match splitBy (· == ' ') (trimL t) |>.filter (!·.isEmpty) with
  | [v, u] =>
    let f : Option Float := if u == "EV".toList then some 1e-3 else if u == "KEV".toList then
      some 1.0 else if u == "MEV".toList then some 1e3 else none
    match f, parseDec v with
    | some f, some d => some (d.value * f)
    | _, _ => none
  | _ => none

/-- The `FL=` value among the `$`-separated items of a continuation record. -/
def findFL (data : List Char) : Option (List Char) :=
  (splitBy (· == '$') data).findSome? fun item =>
    match trimL item with
    | 'F' :: 'L' :: '=' :: v => some (trimL v)
    | _ => none

/-- Split the contents of an ENSDF file into data sets. -/
def parseFile (file : String) (contents : String) : Array Dataset := Id.run do
  let lines := contents.splitOn "\n"
  let mut out : Array Dataset := #[]
  let mut cur : Option Dataset := none
  let mut n := 0
  for raw in lines do
    n := n + 1
    let r := (raw.toList.filter (· != '\r')).toArray
    if (trimL r.toList).isEmpty then
      if let some d := cur then out := out.push d
      cur := none
      continue
    match cur with
    | none =>
      cur := some ⟨file, n, String.ofList (trimL (cols r 1 5)),
        String.ofList (trimL (cols r 10 39)),
        #[], #[]⟩
    | some d =>
      let c6 := col r 6
      let c7 := col r 7
      let c8 := col r 8
      if c7 != ' ' then continue
      let first := c6 == ' ' || c6 == '1'
      if c8 == 'L' && first then
        cur := some { d with levels := d.levels.push ⟨n, cols r 10 19, cols r 20 21,
          cols r 22 39, cols r 40 49, col r 80⟩ }
      else if c8 == 'G' && first then
        cur := some { d with gammas := d.gammas.push ⟨n, cols r 10 19, cols r 20 21,
          cols r 32 41, cols r 42 49, cols r 50 55, col r 77, col r 80, none,
          if d.levels.isEmpty then none else some (d.levels.size - 1)⟩ }
      else if c8 == 'G' && !first then
        match d.gammas.back?, findFL (cols r 10 80) with
        | some g, some v =>
          cur := some { d with gammas := d.gammas.pop.push { g with fl := some v } }
        | _, _ => pure ()
  if let some d := cur then out := out.push d
  return out

end EnsdfCheck
