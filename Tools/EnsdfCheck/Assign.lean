/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
import EnsdfCheck.Parse

/-!

# ENSDF check: the final level of a gamma transition

A gamma record follows the level it depopulates. The final level is taken from `FL=` if given
(manual IV.C.2), otherwise as the level with energy `E_i - E_γ - E_R` within three standard
uncertainties, where `E_R = E_γ²/(2Mc²)` is the recoil energy with `M = A u` and
`u c² = 931494.10372 keV` (CODATA 2022, NIST). Only a unique candidate counts; a broad level
(energy uncertainty or width at least `broadKeV`) is never accepted as the only candidate.
Transitions whose final level is missing or ambiguous are reported separately and never
checked.

This is unverified code.

-/

namespace EnsdfCheck

/-- The outcome of locating the final level. -/
inductive Placement
  /-- Final level found (index into the level records); `viaFL` if from `FL=`, `uncertain` if
  `FL=` carries a `?`. -/
  | ok (f : Nat) (viaFL : Bool) (uncertain : Bool)
  /-- The gamma precedes the first level: unplaced. -/
  | unplaced
  /-- `FL=?`: the final level is not known. -/
  | flUnknown
  /-- `FL=` names an energy not found among the levels. -/
  | flNotFound
  /-- An energy is unreadable or relative to an offset that cannot be resolved. -/
  | badEnergy
  /-- No level matches `E_i - E_γ`. -/
  | noMatch
  /-- Several levels match `E_i - E_γ - E_R`. -/
  | ambiguous
  /-- The only matching level is broad. -/
  | onlyBroad
  deriving Repr, BEq

/-- The standard uncertainty of an energy: `DE` in units of the last digit, or one unit of the
last digit if `DE` is blank or not numeric. -/
def sigma (d : Dec) (de : List Char) : Float :=
  match parseUnc de with
  | some n => n.toFloat * d.unit
  | none => d.unit

/-- The atomic mass constant in keV (CODATA 2022, `931.494 103 72(29) MeV`, NIST). -/
def uKeV : Float := 931494.10372

/-- Levels with an energy uncertainty or a width of at least this many keV count as broad. Fixed at
10 keV after runs with 5, 10, 20 and 50 keV (appendix of the report): category A is the same for
all four, A' changes from 20 keV on by two cases with coarsely written energies. -/
def broadKeV : Float := 10.0

/-- Locate the final level of gamma `g` in data set `ds`. `levelE` holds the parsed level
energies. -/
def placeGamma (ds : Dataset) (levelE : Array (Option Energy)) (g : GammaRec)
    (broadKeV : Float := broadKeV) : Placement :=
  match g.level with
  | none => .unplaced
  | some i =>
    match g.fl with
    | some v =>
      let unc := v.getLast? == some '?'
      let v := trimL (if unc then v.dropLast else v)
      if v.isEmpty then .flUnknown
      else
        -- the manual requires the energy to be identical to a level energy
        match (List.range ds.levels.size).filter (fun k =>
            trimL (ds.levels[k]!).e == v) with
        | [k] => .ok k true unc
        | _ :: _ :: _ => .ambiguous
        | [] =>
          match parseEnergy v with
          | some ⟨o, some x⟩ =>
            match (List.range ds.levels.size).filter (fun k =>
                match levelE[k]! with
                | some ⟨o', some y⟩ => o == o' && Float.abs (x.value - y.value) < 1e-9
                | _ => false) with
            | [k] => .ok k true unc
            | [] => .flNotFound
            | _ => .ambiguous
          | _ => .flNotFound
    | none =>
      match levelE[i]!, parseEnergy g.e with
      | some ⟨o, some ei⟩, some ⟨"", some eg⟩ =>
        let si := sigma ei (ds.levels[i]!).de
        let sg := sigma eg g.de
        let mc2 := (ds.massNumber.getD 0).toFloat * uKeV
        let recoil := if mc2 > 0 then eg.value * eg.value / (2.0 * mc2) else 0.0
        let target := ei.value - eg.value - recoil
        let cands := (List.range ds.levels.size).filter fun k =>
          k != i && match levelE[k]! with
            | some ⟨o', some ef⟩ =>
              let sf := sigma ef (ds.levels[k]!).de
              o == o' && ef.value < ei.value &&
                Float.abs (ef.value - target) ≤ 3.0 * Float.sqrt (si * si + sg * sg + sf * sf)
            | _ => false
        let broad (k : Nat) : Bool :=
          let l := ds.levels[k]!
          (match levelE[k]! with
            | some ⟨_, some ef⟩ => sigma ef l.de ≥ broadKeV
            | _ => false) || (parseWidth l.t).any (· ≥ broadKeV)
        match cands with
        | [k] => if broad k then .onlyBroad else .ok k false false
        | [] => if mc2 > 0 then .noMatch else .badEnergy
        | _ => .ambiguous
      | _, _ => .badEnergy

end EnsdfCheck
