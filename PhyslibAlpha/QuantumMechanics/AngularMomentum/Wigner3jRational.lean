/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
module

public import Mathlib.Basic.Real.Sign
public import PhyslibAlpha.QuantumMechanics.AngularMomentum.SixJSymmetry

/-!

# Rational values of the Wigner 3j symbols

Computable rational functions for the square of the 3j symbol and for the 3j symbol times its
absolute value, with proofs that they agree with the real definitions of `Wigner3j` and
`SixJSymmetry`.

## i. Overview

The 3j symbol `threeJR R = (-1)^(R₂₀ + R₁₁) √(∏ R_ij! / (J + 1)!) · S` of a Regge square `R`
contains a square root and a `finsum`, so it cannot be evaluated. Its square and the product
`threeJR R · |threeJR R|` are rational:

- `threeJR R ^ 2 = ∏ R_ij! / (J + 1)! · S²`,
- `threeJR R · |threeJR R| = (-1)^(R₂₀ + R₁₁) ∏ R_ij! / (J + 1)! · S |S|`,

where the six-factorial sum `S` is a finite sum of rationals over the range in which all
factorials have nonnegative arguments (`sixSumQ`). The second form keeps the sign, and the 3j
symbol is recovered as `sign(q) √|q|` (`threeJ_eq_sign_mul_sqrt`).

The functions below are defined by finite sums and products over `ℚ`, so concrete values can be
checked in the kernel with `decide +kernel`. Section E checks proven identities this way: the
diagonal orthogonality relations and the symmetries of `SixJSymmetry` on a grid of small spins.

## ii. Key results

- `sixSumQ`, `cast_sixSumQ`: the six-factorial sum over `ℚ`.
- `threeJRSqQ`, `cast_threeJRSqQ`: `threeJR R ^ 2` over `ℚ`.
- `threeJRSgnSqQ`, `cast_threeJRSgnSqQ`: `threeJR R · |threeJR R|` over `ℚ`.
- `threeJSqQ`, `cast_threeJSqQ`, `threeJSgnSqQ`, `cast_threeJSgnSqQ`: the same for `threeJ`.
- `threeJ_eq_sign_mul_sqrt`: `threeJ = sign(q) √|q|` with `q = threeJSgnSqQ`.
- `sq_cgCoefficient`: the square of a Clebsch–Gordan coefficient as a rational number.

## iii. Table of contents

- A. The six-factorial sum over ℚ
- B. The 3j symbol of a Regge square
- C. The 3j symbol with general arguments
- D. The Clebsch–Gordan coefficients
- E. Checks in the kernel

## iv. References

- A. R. Edmonds, *Angular Momentum in Quantum Mechanics*, Princeton University Press (1957),
  section 3.7.

## A. The six-factorial sum over ℚ

-/

@[expose] public section

namespace PhyslibAlpha.Sl2

/-- `1/u!` in `ℚ` for `u ≥ 0` and `0` for `u < 0`. -/
def invFactQ (u : ℤ) : ℚ := if 0 ≤ u then ((u.toNat.factorial : ℚ))⁻¹ else 0

lemma cast_invFactQ (u : ℤ) : (invFactQ u : ℝ) = invFact u := by
  rw [invFactQ, invFact]
  split_ifs <;> push_cast <;> rfl

/-- `(-1)^z` in `ℚ`, by the parity of `z`. -/
def negOnePowQ (z : ℤ) : ℚ := if z % 2 = 0 then 1 else -1

lemma cast_negOnePowQ (z : ℤ) : (negOnePowQ z : ℝ) = (-1) ^ z := by
  rw [negOnePowQ]
  split_ifs with h
  · rw [neg_one_zpow_congr (q := 0) (by omega)]
    simp
  · rw [neg_one_zpow_congr (q := 1) (by omega)]
    simp

/-- The summand of `sixSumQ`. -/
def sixTermQ (a₁ a₂ a₃ b₁ b₂ b₃ z : ℤ) : ℚ :=
  negOnePowQ z * (invFactQ (z - a₁) * invFactQ (z - a₂) * invFactQ (z - a₃) *
    (invFactQ (b₁ - z) * invFactQ (b₂ - z) * invFactQ (b₃ - z)))

lemma cast_sixTermQ (a₁ a₂ a₃ b₁ b₂ b₃ z : ℤ) :
    (sixTermQ a₁ a₂ a₃ b₁ b₂ b₃ z : ℝ) = sixTerm a₁ a₂ a₃ b₁ b₂ b₃ z := by
  simp only [sixTermQ, sixTerm, Rat.cast_mul, cast_negOnePowQ, cast_invFactQ]

/-- The six-factorial sum over `ℚ`, over the range `max aᵢ ≤ z ≤ min bᵢ` outside of which all
summands vanish. -/
def sixSumQ (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) : ℚ :=
  ∑ z ∈ Finset.Icc (max a₁ (max a₂ a₃)) (min b₁ (min b₂ b₃)), sixTermQ a₁ a₂ a₃ b₁ b₂ b₃ z

lemma cast_sixSumQ (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) :
    (sixSumQ a₁ a₂ a₃ b₁ b₂ b₃ : ℝ) = sixSum a₁ a₂ a₃ b₁ b₂ b₃ := by
  rw [sixSum, finsum_eq_sum_of_support_subset (s := Finset.Icc (max a₁ (max a₂ a₃))
    (min b₁ (min b₂ b₃))), sixSumQ, Rat.cast_sum]
  · exact Finset.sum_congr rfl fun z _ => cast_sixTermQ _ _ _ _ _ _ z
  · intro z hz
    rw [Function.mem_support] at hz
    simp only [sixTerm, ne_eq, mul_eq_zero, not_or] at hz
    have h₁ := nonneg_of_invFact_ne_zero hz.2.1.1.1
    have h₂ := nonneg_of_invFact_ne_zero hz.2.1.1.2
    have h₃ := nonneg_of_invFact_ne_zero hz.2.1.2
    have h₄ := nonneg_of_invFact_ne_zero hz.2.2.1.1
    have h₅ := nonneg_of_invFact_ne_zero hz.2.2.1.2
    have h₆ := nonneg_of_invFact_ne_zero hz.2.2.2
    simp only [Finset.coe_Icc, Set.mem_Icc]
    omega

/-!

## B. The 3j symbol of a Regge square

-/

/-- The rational number `∏ R_ij! / (J + 1)!` under the square root of `threeJR`. -/
def threeJRRadQ (R : Fin 3 → Fin 3 → ℕ) : ℚ :=
  (∏ i, ∏ j, ((R i j).factorial : ℚ)) / ((R 0 0 + R 0 1 + R 0 2 + 1).factorial : ℚ)

/-- The six-factorial sum of `threeJR` over `ℚ`. -/
def threeJRSumQ (R : Fin 3 → Fin 3 → ℕ) : ℚ :=
  sixSumQ 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1)

/-- `threeJR R ^ 2` over `ℚ`. -/
def threeJRSqQ (R : Fin 3 → Fin 3 → ℕ) : ℚ := threeJRRadQ R * threeJRSumQ R ^ 2

/-- `threeJR R · |threeJR R|` over `ℚ`. -/
def threeJRSgnSqQ (R : Fin 3 → Fin 3 → ℕ) : ℚ :=
  (-1) ^ (R 2 0 + R 1 1) * threeJRRadQ R * (threeJRSumQ R * |threeJRSumQ R|)

lemma cast_threeJRRadQ (R : Fin 3 → Fin 3 → ℕ) : (threeJRRadQ R : ℝ) =
    (∏ i, ∏ j, ((R i j).factorial : ℝ)) / ((R 0 0 + R 0 1 + R 0 2 + 1).factorial : ℝ) := by
  simp only [threeJRRadQ, Rat.cast_div, Rat.cast_prod, Rat.cast_natCast]

lemma threeJRRadQ_nonneg (R : Fin 3 → Fin 3 → ℕ) : 0 ≤ (threeJRRadQ R : ℝ) := by
  rw [cast_threeJRRadQ]
  positivity

lemma cast_threeJRSumQ (R : Fin 3 → Fin 3 → ℕ) : (threeJRSumQ R : ℝ) =
    sixSum 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1) :=
  cast_sixSumQ _ _ _ _ _ _

lemma threeJR_eq_rat (R : Fin 3 → Fin 3 → ℕ) :
    threeJR R = (-1) ^ (R 2 0 + R 1 1) * Real.sqrt (threeJRRadQ R : ℝ) * (threeJRSumQ R : ℝ) := by
  rw [threeJR, cast_threeJRRadQ, cast_threeJRSumQ]

lemma cast_threeJRSqQ (R : Fin 3 → Fin 3 → ℕ) : (threeJRSqQ R : ℝ) = threeJR R ^ 2 := by
  have hs := Real.sq_sqrt (threeJRRadQ_nonneg R)
  have hp : ((-1 : ℝ) ^ (R 2 0 + R 1 1)) ^ 2 = 1 := by
    rw [← pow_mul, mul_comm, pow_mul, neg_one_sq, one_pow]
  rw [threeJR_eq_rat, threeJRSqQ, Rat.cast_mul, Rat.cast_pow, mul_pow, mul_pow, hp, hs, one_mul]

lemma cast_threeJRSgnSqQ (R : Fin 3 → Fin 3 → ℕ) :
    (threeJRSgnSqQ R : ℝ) = threeJR R * |threeJR R| := by
  have hs := Real.mul_self_sqrt (threeJRRadQ_nonneg R)
  rw [threeJR_eq_rat, threeJRSgnSqQ, abs_mul, abs_mul, abs_pow, abs_neg, abs_one, one_pow,
    abs_of_nonneg (Real.sqrt_nonneg _)]
  push_cast
  linear_combination -(-1 : ℝ) ^ (R 2 0 + R 1 1) * ((threeJRSumQ R : ℝ) * |(threeJRSumQ R : ℝ)|) *
    hs

/-!

## C. The 3j symbol with general arguments

-/

/-- `threeJ j₁ j₂ j₃ m₁ m₂ m₃ ^ 2` over `ℚ` (doubled units). -/
def threeJSqQ (j₁ j₂ j₃ : ℕ) (m₁ m₂ m₃ : ℤ) : ℚ :=
  if Adm3 j₁ j₂ j₃ m₁ m₂ m₃ then threeJRSqQ (reggeJ j₁ j₂ j₃ m₁ m₂ m₃) else 0

/-- `threeJ j₁ j₂ j₃ m₁ m₂ m₃ · |threeJ j₁ j₂ j₃ m₁ m₂ m₃|` over `ℚ` (doubled units). -/
def threeJSgnSqQ (j₁ j₂ j₃ : ℕ) (m₁ m₂ m₃ : ℤ) : ℚ :=
  if Adm3 j₁ j₂ j₃ m₁ m₂ m₃ then threeJRSgnSqQ (reggeJ j₁ j₂ j₃ m₁ m₂ m₃) else 0

variable (j₁ j₂ j₃ : ℕ) (m₁ m₂ m₃ : ℤ)

lemma cast_threeJSqQ : (threeJSqQ j₁ j₂ j₃ m₁ m₂ m₃ : ℝ) = threeJ j₁ j₂ j₃ m₁ m₂ m₃ ^ 2 := by
  rw [threeJSqQ, threeJ]
  split_ifs
  · exact cast_threeJRSqQ _
  · simp

lemma cast_threeJSgnSqQ :
    (threeJSgnSqQ j₁ j₂ j₃ m₁ m₂ m₃ : ℝ) =
      threeJ j₁ j₂ j₃ m₁ m₂ m₃ * |threeJ j₁ j₂ j₃ m₁ m₂ m₃| := by
  rw [threeJSgnSqQ, threeJ]
  split_ifs
  · exact cast_threeJRSgnSqQ _
  · simp

/-- **The 3j symbol from a rational number.** `threeJ = sign(q) √|q|` with
`q = threeJSgnSqQ`. -/
lemma threeJ_eq_sign_mul_sqrt :
    threeJ j₁ j₂ j₃ m₁ m₂ m₃ =
      Real.sign (threeJSgnSqQ j₁ j₂ j₃ m₁ m₂ m₃ : ℝ) *
        Real.sqrt |(threeJSgnSqQ j₁ j₂ j₃ m₁ m₂ m₃ : ℝ)| := by
  rw [cast_threeJSgnSqQ]
  set t := threeJ j₁ j₂ j₃ m₁ m₂ m₃
  rw [abs_mul, abs_abs, Real.sqrt_mul_self (abs_nonneg t)]
  rcases lt_trichotomy t 0 with h | h | h
  · rw [Real.sign_of_neg (mul_neg_of_neg_of_pos h (abs_pos.mpr h.ne)), abs_of_neg h]
    ring
  · simp [h]
  · rw [Real.sign_of_pos (mul_pos h (abs_pos.mpr h.ne')), abs_of_pos h, one_mul]

/-!

## D. The Clebsch–Gordan coefficients

-/

/-- **Clebsch–Gordan coefficients squared are rational.**
`⟨j₁ m₁ j₂ m₂ | J M⟩² = (2J + 1) (j₁ j₂ J; m₁ m₂ -M)²`, in the parameters of
`ClebschGordanCoefficients`. -/
lemma sq_cgCoefficient {m n : ℕ} (hmn : 0 < m + n) {k l α β : ℕ} (hkm : k ≤ m) (hkn : k ≤ n)
    (hl : l ≤ m + n - 2 * k) (hα : α ≤ m) (hβ : β ≤ n) :
    cgCoefficient m n k l α β ^ 2 = ((m + n - 2 * k + 1 : ℕ) : ℝ) *
      (threeJSqQ m n (m + n - 2 * k) ((m : ℤ) - 2 * α) ((n : ℤ) - 2 * β)
        (-(((m + n - 2 * k : ℕ) : ℤ) - 2 * l)) : ℝ) := by
  have hp : ((-1 : ℝ) ^ (m + k + l)) ^ 2 = 1 := by
    rw [← pow_mul, mul_comm, pow_mul, neg_one_sq, one_pow]
  rw [cgCoefficient_eq_wigner3j hmn hkm hkn hl hα hβ, wigner3j_eq_threeJ hkm hkn hl hα hβ,
    cast_threeJSqQ, mul_pow, mul_pow, hp, one_mul, Real.sq_sqrt (Nat.cast_nonneg _)]

/-!

## E. Checks in the kernel

Proven identities, evaluated with `decide +kernel` on small spins (doubled units). The
orthogonality relations involving two different 3j symbols are not rational term by term, so only
the diagonal relations are checked.

-/

/-- `Σ_{m₁ m₂} (j₁ j₂ J; m₁ m₂ M)² = 1/(2J + 1)` (`sum_wigner3j_mul_wigner3j`), for
`j₁ = 2`, `j₂ = 3/2` and all `J`, `M`. -/
example : ∀ J ∈ Finset.range 8, ∀ M ∈ Finset.Icc (-(J : ℤ)) J, (J - M) % 2 = 0 →
    ∑ m₁ ∈ Finset.Icc (-4 : ℤ) 4, threeJSqQ 4 3 J m₁ (-m₁ - M) M =
      if 1 ≤ J ∧ J ≤ 7 ∧ J % 2 = 1 then 1 / ((J : ℚ) + 1) else 0 := by
  decide +kernel

/-- `Σ_J (2J + 1) (j₁ j₂ J; m₁ m₂ -M)² = 1` (`sum_wigner3j_mul_wigner3j_JM`), for `j₁ = 2`,
`j₂ = 3/2` and all admissible `m₁`, `m₂`. -/
example : ∀ m₁ ∈ Finset.Icc (-4 : ℤ) 4, ∀ m₂ ∈ Finset.Icc (-3 : ℤ) 3, m₁ % 2 = 0 → m₂ % 2 = 1 →
    ∑ J ∈ Finset.range 8, ((J : ℚ) + 1) * threeJSqQ 4 3 J m₁ m₂ (-m₁ - m₂) = 1 := by
  decide +kernel

/-- `threeJ_swap` for all spins up to `3/2` and all projections. -/
example : ((List.range 4).all fun j₁ => (List.range 4).all fun j₂ => (List.range 4).all fun j₃ =>
    (List.range (j₁ + 1)).all fun a => (List.range (j₂ + 1)).all fun b =>
      threeJSgnSqQ j₂ j₁ j₃ (2 * b - j₂) (2 * a - j₁) (j₁ + j₂ - 2 * a - 2 * b) -
          (-1) ^ ((j₁ + j₂ + j₃) / 2) *
            threeJSgnSqQ j₁ j₂ j₃ (2 * a - j₁) (2 * b - j₂) (j₁ + j₂ - 2 * a - 2 * b) == 0) =
    true := by
  decide +kernel

/-- `threeJ_cycle` for all spins up to `3/2` and all projections. -/
example : ((List.range 4).all fun j₁ => (List.range 4).all fun j₂ => (List.range 4).all fun j₃ =>
    (List.range (j₁ + 1)).all fun a => (List.range (j₂ + 1)).all fun b =>
      threeJSgnSqQ j₂ j₃ j₁ (2 * b - j₂) (j₁ + j₂ - 2 * a - 2 * b) (2 * a - j₁) -
          threeJSgnSqQ j₁ j₂ j₃ (2 * a - j₁) (2 * b - j₂) (j₁ + j₂ - 2 * a - 2 * b) == 0) =
    true := by
  decide +kernel

/-- `threeJ_neg` for all spins up to `3/2` and all projections. -/
example : ((List.range 4).all fun j₁ => (List.range 4).all fun j₂ => (List.range 4).all fun j₃ =>
    (List.range (j₁ + 1)).all fun a => (List.range (j₂ + 1)).all fun b =>
      threeJSgnSqQ j₁ j₂ j₃ (j₁ - 2 * a) (j₂ - 2 * b) (2 * a + 2 * b - j₁ - j₂) -
          (-1) ^ ((j₁ + j₂ + j₃) / 2) *
            threeJSgnSqQ j₁ j₂ j₃ (2 * a - j₁) (2 * b - j₂) (j₁ + j₂ - 2 * a - 2 * b) == 0) =
    true := by
  decide +kernel

/-- `(j j j; 0 0 0) = 0` for odd `3j`, a consequence of `threeJ_neg`, and a non-vanishing
symbol stated as a negation. -/
example : threeJSqQ 2 2 2 0 0 0 = 0 ∧ ¬threeJSqQ 4 4 4 0 0 0 = 0 := by
  decide +kernel

end PhyslibAlpha.Sl2
