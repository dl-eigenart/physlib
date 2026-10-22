/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
import EnsdfCheck.Assign

/-!

# ENSDF check: categories

Every gamma transition with a multipolarity falls into one category:

- `A`: both levels, the multipolarity and the placement are firm (no brackets, no lists, no `?`),
  and the angular momentum rule is violated by a component outside brackets. A violation only by a
  bracketed component such as the `E2` in `M1(+E2)` is `B`. Backed by
  `IsTensorOperator.triangleRule` through `Rules.lean`.
- `A'`: as `A`, with both parities given and firm, but only the parity rule is violated. The parity
  rule is a definition in `SelectionRules.lean`, not a theorem.
- `B`: the violation involves tentative or assumed assignments, lists or uncertain placements; for
  lists it counts only if no combination is allowed.
- `C`: special cases: `E0`, `0 → 0`, `D`/`Q` without type, final level missing, ambiguous or
  only a broad level.
- `S`: a level of the transition has a spin that is half-integer for even `A` or integer for odd
  `A` (`2J` and `A` of different parity); such transitions are not checked further.
- `P`: unreadable fields.
- `N`: not checkable: Jπ blank or of a form that is not checked (offset, bound, range, …).
- `ok`: consistent with the rules.

This is unverified code; the verdicts themselves come from `checkTransition`.

-/

namespace EnsdfCheck

open PhyslibAlpha.Sl2

/-- The category of a gamma transition, with a short reason. -/
inductive Category
  | a | a' | b | c | s | p | n | ok
  deriving DecidableEq, Repr, Hashable

/-- Short name of a category. -/
def Category.name : Category → String
  | .a => "A" | .a' => "A'" | .b => "B" | .c => "C" | .s => "S" | .p => "P" | .n => "N"
  | .ok => "ok"

/-- The result of classifying one gamma transition. -/
structure Finding where
  /-- The category. -/
  cat : Category
  /-- A reason, used as subcategory in the report. -/
  reason : String
  /-- The final level, if placed. -/
  final : Option Nat := none
  /-- For `A`: twice the spins and the order of the violating component. -/
  cert : Option (Nat × Nat × Nat) := none
  /-- The final level comes from `FL=` (rather than from the energy difference). -/
  viaFL : Bool := false

/-- A spin candidate with its parity resolved, both parities if it is not given. -/
def expand (c : SpinCand) : List SpinParity :=
  match c.parity with
  | some p => [⟨c.twoJ, if p == 1 then 1 else -1⟩]
  | none => [⟨c.twoJ, 1⟩, ⟨c.twoJ, -1⟩]

/-- The first component with an angular momentum violation, as `(λ)`. -/
def angularOrder (i f : SpinParity) (m : Multipolarity) : Option Nat :=
  m.findSome? fun c =>
    if checkComponent i f c == .angularViolation then
      some (match c with | .typed _ l => l | .untyped l => l)
    else none

/-- A spin alternative whose `2J` has a different parity than the mass number `A`: half-integer
spin for even `A` or integer spin for odd `A`. -/
def spinMassMismatch (a : Nat) : JParse → Bool
  | .ok alts => alts.any fun c => c.twoJ % 2 != a % 2
  | _ => false

/-- Whether a component is `D` or `Q`. -/
def Component.isUntyped : Component → Bool
  | .untyped _ => true
  | _ => false

/-- Classify one gamma transition of a data set. -/
def classify (ds : Dataset) (levelE : Array (Option Energy)) (g : GammaRec) : Option Finding :=
  match parseM g.m with
  | .empty => none
  | .unparsable => some ⟨.p, "multipolarity unreadable", none, none, false⟩
  | .unchecked k => some ⟨.n, s!"multipolarity {k}", none, none, false⟩
  | .ok malts =>
    match placeGamma ds levelE g, g.level with
    | .ok f viaFL unc, some i =>
      let li := ds.levels[i]!
      let lf := ds.levels[f]!
      match parseJ li.j, parseJ lf.j with
      | .unparsable, _ | _, .unparsable => some ⟨.p, "Jπ unreadable", some f, none, false⟩
      | .ok ai, .ok af =>
        let comps := malts.map (·.map (·.comp))
        let hasE0 := comps.any (·.any fun c => c == .typed .electric 0)
        let zeroZero := ai.all (·.twoJ == 0) && af.all (·.twoJ == 0)
        let mass := ds.massNumber.getD 0
        if mass > 0 && (spinMassMismatch mass (parseJ li.j) || spinMassMismatch mass (parseJ lf.j))
        then some ⟨.s, "2J and A of different parity", some f, none, viaFL⟩
        else if hasE0 then some ⟨.c, "E0", some f, none, viaFL⟩
        else if zeroZero then some ⟨.c, "0 → 0", some f, none, viaFL⟩
        else
          let origin := if viaFL then "FL=" else "E_i - E_γ"
          let placeFirm := !unc && g.q != '?' && g.q != 'S' &&
            !"*&@".toList.contains g.c77 && li.q != '?' && li.q != 'S' &&
            lf.q != '?' && lf.q != 'S'
          let firm := placeFirm && ai.length == 1 && af.length == 1 && malts.length == 1 &&
            !(ai.head!.jTent) && !(af.head!.jTent)
          -- all combinations of alternatives and unknown parities
          let combos := ai.flatMap fun x => af.flatMap fun y => comps.flatMap fun m =>
            (expand x).flatMap fun si => (expand y).map fun sf => (si, sf, m)
          let verdicts := combos.map fun (si, sf, m) => checkTransition si sf m
          let allViol := verdicts.all (·.IsViolation)
          let allAng := verdicts.all (· == .angularViolation)
          let anyUntyped := comps.any (·.any Component.isUntyped)
          if firm then
            let x := ai.head!
            let y := af.head!
            let mFirm := (malts.head!.filter (!·.tent)).map (·.comp)
            let mTent := (malts.head!.filter (·.tent)).map (·.comp)
            let si := (expand x).head!
            let sf := (expand y).head!
            let parityFirm := x.parity.isSome && y.parity.isSome && !x.pTent && !y.pTent
            -- the angular momentum rule does not depend on the parities
            match angularOrder si sf mFirm, angularOrder si sf mTent with
            | some l, _ =>
              some ⟨.a, s!"angular momentum, final level from {origin}", some f,
                some (x.twoJ, y.twoJ, l), viaFL⟩
            | none, some _ =>
              some ⟨.b, "angular momentum, bracketed component only", some f, none, viaFL⟩
            | none, none =>
              let firmViol := !mFirm.isEmpty && ((expand x).all fun si =>
                (expand y).all fun sf => (checkTransition si sf mFirm).IsViolation)
              if firmViol then
                if parityFirm then
                  some ⟨.a', s!"parity, final level from {origin}", some f, none, viaFL⟩
                else some ⟨.b, "parity, tentative or unknown", some f, none, viaFL⟩
              else if allViol then
                some ⟨.b, "parity, bracketed component only", some f, none, viaFL⟩
              else if anyUntyped then
                some ⟨.c, "D/Q without type, allowed", some f, none, viaFL⟩
              else some ⟨.ok, "allowed", some f, none, viaFL⟩
          else if allViol then
            some ⟨.b, if allAng then "angular momentum" else "parity or mixed", some f, none,
              viaFL⟩
          else if anyUntyped then
            some ⟨.c, "D/Q without type, allowed", some f, none, viaFL⟩
          else some ⟨.ok, "allowed", some f, none, viaFL⟩
      | .empty, _ | _, .empty => some ⟨.n, "Jπ blank", some f, none, false⟩
      | _, _ => some ⟨.n, "Jπ not checked (offset, bound, range, …)", some f, none, false⟩
    | .ok _ _ _, none => some ⟨.c, "unplaced", none, none, false⟩
    | .unplaced, _ => some ⟨.c, "unplaced", none, none, false⟩
    | .flUnknown, _ => some ⟨.c, "FL=?", none, none, false⟩
    | .flNotFound, _ => some ⟨.c, "FL= not found", none, none, false⟩
    | .badEnergy, _ => some ⟨.c, "energy unreadable or offset", none, none, false⟩
    | .noMatch, _ => some ⟨.c, "no matching final level", none, none, false⟩
    | .ambiguous, _ => some ⟨.c, "final level ambiguous", none, none, false⟩
    | .onlyBroad, _ => some ⟨.c, "only a broad level matches", none, none, false⟩

end EnsdfCheck
