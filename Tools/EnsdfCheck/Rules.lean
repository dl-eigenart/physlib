/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
import PhyslibAlpha.QuantumMechanics.AngularMomentum.SelectionRules

/-!

# ENSDF check: the selection rules as a decision procedure

Data types for spins, parities and multipolarities as they occur in ENSDF, and a computable check
of a gamma transition against the selection rules of `SelectionRules.lean`.

The check is written with `Bool` so that it runs in the compiled tool, and is proved equivalent
to the propositions `TriangleRule` and `IsAllowedMultipole` (`triangleB_iff`,
`checkTransition_eq_violation_iff`). Only the angular momentum rule is backed by a theorem
(`IsTensorOperator.triangleRule`); the parity rule enters `IsAllowedMultipole` as a definition
(`MultipoleType.parity`). The verdicts keep the two apart.

-/

namespace EnsdfCheck

open PhyslibAlpha.Sl2

/-! ## Data types -/

/-- A spin and parity `J^π`, with the spin in doubled units `twoJ = 2J`. -/
structure SpinParity where
  /-- Twice the spin. -/
  twoJ : ℕ
  /-- The parity `±1`. -/
  parity : ℤˣ
  deriving DecidableEq, Repr, Inhabited

/-- How firmly an ENSDF assignment is made. -/
inductive Firmness
  /-- No brackets. -/
  | firm
  /-- In parentheses: probable, based on weak arguments. -/
  | tentative
  /-- In square brackets: assumed or derived. -/
  | assumed
  /-- A list of alternatives, such as `1-,2-`. -/
  | list
  /-- Not given. -/
  | unknown
  deriving DecidableEq, Repr

/-- One multipole component of a gamma transition. -/
inductive Component
  /-- `Eλ` or `Mλ`. -/
  | typed (t : MultipoleType) (l : ℕ)
  /-- `D` (`λ = 1`) or `Q` (`λ = 2`), with electric or magnetic character not given. -/
  | untyped (l : ℕ)
  deriving DecidableEq

/-- A multipolarity: one component, or several for mixed transitions such as `M1+E2`. -/
abbrev Multipolarity := List Component

/-- The outcome of the check, ordered by severity. -/
inductive Verdict
  /-- All components are allowed. -/
  | allowed
  /-- A `D` or `Q` component satisfies the triangle rule; its parity is not determined. -/
  | untypedOk
  /-- An `E0` component; the multipole selection rules require `λ ≥ 1`. -/
  | special
  /-- The triangle rule holds, but the parity rule fails for some component. -/
  | parityViolation
  /-- The angular momentum rule `1 ≤ λ`, `TriangleRule` fails for some component. -/
  | angularViolation
  deriving DecidableEq, Repr

/-! ## The rules as `Bool` -/

/-- `TriangleRule` as a `Bool`. -/
def triangleB (k m p : ℕ) : Bool :=
  decide (p ≤ k + m) && decide (k ≤ m + p) && decide (m ≤ k + p) && decide ((k + m + p) % 2 = 0)

lemma triangleB_iff (k m p : ℕ) : triangleB k m p = true ↔ TriangleRule k m p := by
  simp [triangleB, TriangleRule, and_assoc]

/-- The parity `(-1)^λ` of `Eλ` and `(-1)^(λ+1)` of `Mλ` as a unit. -/
def multipoleParity : MultipoleType → ℕ → ℤˣ
  | .electric, l => (-1) ^ l
  | .magnetic, l => (-1) ^ (l + 1)

lemma coe_multipoleParity (t : MultipoleType) (l : ℕ) :
    ((multipoleParity t l : ℤˣ) : ℤ) = t.parity l := by
  cases t <;> simp [multipoleParity, MultipoleType.parity]

/-! ## The check -/

/-- The check of one component for a transition from `i` to `f`. -/
def checkComponent (i f : SpinParity) : Component → Verdict
  | .typed _ 0 => .special
  | .typed t (l + 1) =>
    if triangleB (2 * (l + 1)) i.twoJ f.twoJ then
      if f.parity = multipoleParity t (l + 1) * i.parity then .allowed else .parityViolation
    else .angularViolation
  | .untyped 0 => .angularViolation
  | .untyped (l + 1) =>
    if triangleB (2 * (l + 1)) i.twoJ f.twoJ then .untypedOk else .angularViolation

/-- The severity of a verdict. -/
def Verdict.rank : Verdict → ℕ
  | .allowed => 0
  | .untypedOk => 1
  | .special => 2
  | .parityViolation => 3
  | .angularViolation => 4

/-- The more severe of two verdicts. -/
def Verdict.max (a b : Verdict) : Verdict := if b.rank ≤ a.rank then a else b

/-- A violation of the angular momentum or the parity rule. -/
def Verdict.IsViolation (v : Verdict) : Prop := v = .parityViolation ∨ v = .angularViolation

instance (v : Verdict) : Decidable v.IsViolation := by
  unfold Verdict.IsViolation
  infer_instance

/-- The check of a transition from `i` to `f`: every component is checked, the most severe
verdict is returned. -/
def checkTransition (i f : SpinParity) (m : Multipolarity) : Verdict :=
  m.foldr (fun c v => (checkComponent i f c).max v) .allowed

/-! ## Correctness -/

lemma Verdict.max_isViolation (a b : Verdict) :
    (a.max b).IsViolation ↔ a.IsViolation ∨ b.IsViolation := by
  cases a <;> cases b <;> decide

lemma Verdict.max_eq_angular (a b : Verdict) :
    a.max b = .angularViolation ↔ a = .angularViolation ∨ b = .angularViolation := by
  cases a <;> cases b <;> decide

lemma checkTransition_isViolation_iff (i f : SpinParity) (m : Multipolarity) :
    (checkTransition i f m).IsViolation ↔ ∃ c ∈ m, (checkComponent i f c).IsViolation := by
  induction m with
  | nil => simp [checkTransition, Verdict.IsViolation]
  | cons c m ih =>
    simp only [checkTransition, List.foldr_cons] at ih ⊢
    rw [Verdict.max_isViolation, ih]
    simp

lemma checkTransition_eq_angular_iff (i f : SpinParity) (m : Multipolarity) :
    checkTransition i f m = .angularViolation ↔
      ∃ c ∈ m, checkComponent i f c = .angularViolation := by
  induction m with
  | nil => simp [checkTransition]
  | cons c m ih =>
    simp only [checkTransition, List.foldr_cons] at ih ⊢
    rw [Verdict.max_eq_angular, ih]
    simp

/-- For a typed component of order `λ ≥ 1`, the check reports a violation exactly when the
transition is not an allowed multipole transition. -/
lemma checkComponent_isViolation_iff (i f : SpinParity) (t : MultipoleType) {l : ℕ}
    (hl : 1 ≤ l) :
    (checkComponent i f (.typed t l)).IsViolation ↔
      ¬ IsAllowedMultipole i.twoJ f.twoJ i.parity f.parity t l := by
  obtain ⟨l, rfl⟩ : ∃ l', l = l' + 1 := ⟨l - 1, by omega⟩
  have hp : (f.parity = multipoleParity t (l + 1) * i.parity) ↔
      ((f.parity : ℤ) = t.parity (l + 1) * i.parity) := by
    rw [← coe_multipoleParity, ← Units.val_mul, Units.val_inj]
  simp only [checkComponent, IsAllowedMultipole, ← triangleB_iff, ← hp]
  split_ifs <;> simp_all [Verdict.IsViolation]

/-- An angular momentum violation of a typed component `Eλ` or `Mλ` means that no multipole of
order `λ`, electric or magnetic, is allowed. -/
lemma not_isAllowedMultipole_of_typed_eq_angular (i f : SpinParity) {t' : MultipoleType} {l : ℕ}
    (h : checkComponent i f (.typed t' l) = .angularViolation) (t : MultipoleType) :
    ¬ IsAllowedMultipole i.twoJ f.twoJ i.parity f.parity t l := by
  rintro ⟨hl, ht, -⟩
  obtain ⟨l, rfl⟩ : ∃ l', l = l' + 1 := ⟨l - 1, by omega⟩
  rw [← triangleB_iff] at ht
  simp only [checkComponent, ht, ↓reduceIte] at h
  split_ifs at h

/-- An angular momentum violation of `D` or `Q` means that neither the electric nor the magnetic
multipole of that order is allowed. -/
lemma not_isAllowedMultipole_of_untyped_eq_angular (i f : SpinParity) {l : ℕ}
    (h : checkComponent i f (.untyped l) = .angularViolation) (t : MultipoleType) :
    ¬ IsAllowedMultipole i.twoJ f.twoJ i.parity f.parity t l := by
  rintro ⟨hl, ht, -⟩
  obtain ⟨l, rfl⟩ : ∃ l', l = l' + 1 := ⟨l - 1, by omega⟩
  rw [← triangleB_iff] at ht
  simp [checkComponent, ht] at h

/-- **The check is as reliable as the selection rules.** For a single typed multipole of order
`λ ≥ 1`, `checkTransition` reports a violation exactly when `¬ IsAllowedMultipole` holds. -/
lemma checkTransition_eq_violation_iff (i f : SpinParity) (t : MultipoleType) {l : ℕ}
    (hl : 1 ≤ l) :
    (checkTransition i f [.typed t l]).IsViolation ↔
      ¬ IsAllowedMultipole i.twoJ f.twoJ i.parity f.parity t l := by
  rw [checkTransition_isViolation_iff, ← checkComponent_isViolation_iff i f t hl]
  simp

/-! ## Examples: the ¹⁷⁸ᵐ²Hf isomer of `SelectionRules.lean` §C -/

/-- `16⁺`. -/
def hf178_16p : SpinParity := ⟨32, 1⟩
/-- `13⁻`. -/
def hf178_13m : SpinParity := ⟨26, -1⟩

example : checkTransition hf178_16p hf178_13m [.typed .electric 3] = .allowed := by decide
example : checkTransition hf178_16p hf178_13m [.typed .magnetic 3] = .parityViolation := by
  decide
example : checkTransition hf178_16p hf178_13m [.typed .electric 2] = .angularViolation := by
  decide
example : checkTransition hf178_16p hf178_13m [.untyped 1, .typed .electric 3] =
    .angularViolation := by decide

end EnsdfCheck
