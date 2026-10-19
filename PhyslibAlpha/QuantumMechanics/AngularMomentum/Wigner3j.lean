/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
module

public import PhyslibAlpha.QuantumMechanics.AngularMomentum.ClebschGordanFormula

/-!

# Wigner 3j symbols

The 3j symbols in Regge's form, their relation to the Clebsch–Gordan coefficients, their
symmetries and orthogonality relations.

## i. Overview

For angular momenta `j₁, j₂, j₃` and projections `m₁ + m₂ + m₃ = 0` the nine numbers

```
  -j₁ + j₂ + j₃   j₁ - j₂ + j₃   j₁ + j₂ - j₃
   j₁ - m₁         j₂ - m₂        j₃ - m₃
   j₁ + m₁         j₂ + m₂        j₃ + m₃
```

form Regge's square `R`: natural numbers whose rows and columns all add up to
`J = j₁ + j₂ + j₃`. Racah's formula for the 3j symbol reads, in these entries,

`(j₁ j₂ j₃; m₁ m₂ m₃) = (-1)^(R₂₀ + R₁₁) √(∏ R_ij! / (J + 1)!) · S`,

`S = Σ_z (-1)^z / (z! (R₀₂ - z)! (R₁₀ - z)! (R₂₁ - z)! (R₀₁ - R₁₀ + z)! (R₀₀ - R₂₁ + z)!)`.

This is taken as the definition (`threeJR`). The sum `S` is a special case of
`sixSum a b = Σ_z (-1)^z / ∏_i (z - a_i)! ∏_i (b_i - z)!`, which is invariant under permutations
of the `a_i` and of the `b_i`, changes by `(-1)^c` under the shift `a, b ↦ a + c, b + c`, and is
unchanged under `a, b ↦ -b, -a`. Each symmetry of the 3j symbol is one of these moves:

- transposing `R` (a Regge symmetry) and permuting its columns cyclically leave it unchanged,
- swapping two columns or the last two rows (`m ↦ -m`) multiplies it by `(-1)^J`.

These generate all 72 symmetries of the 3j symbol.

`cgCoefficient_eq_threeJR` identifies the symbol with the Clebsch–Gordan coefficients of
`ClebschGordanCoefficients` through `cgCoefficient_racah`:
`⟨j₁ m₁ j₂ m₂ | J M⟩ = (-1)^(j₁ - j₂ + M) √(2J + 1) (j₁ j₂ J; m₁ m₂ -M)`.
The orthogonality relations of the 3j symbols follow.

## ii. Key results

- `sixSum_shift`, `sixSum_neg`: the moves of the six-factorial sum.
- `threeJR`: the 3j symbol of a Regge square.
- `threeJR_transpose`, `threeJR_swap_columns`, `threeJR_cycle_columns`, `threeJR_swap_rows`:
  the symmetries.
- `cgCoefficient_eq_threeJR`: relation to the Clebsch–Gordan coefficients.
- `sum_wigner3j_mul_wigner3j`, `sum_wigner3j_mul_wigner3j_JM`: the orthogonality relations.

## iii. Table of contents

- A. The six-factorial sum
- B. Regge squares and the 3j symbol
- C. Symmetries
- D. Relation to the Clebsch–Gordan coefficients
- E. Orthogonality

## iv. References

- T. Regge, *Symmetry properties of Clebsch–Gordan's coefficients*, Nuovo Cimento 10, 544 (1958).
- A. R. Edmonds, *Angular Momentum in Quantum Mechanics*, Princeton University Press (1957),
  section 3.7.

## A. The six-factorial sum

-/

@[expose] public section

noncomputable section

namespace PhyslibAlpha.Sl2

/-- `1/u!` for `u ≥ 0` and `0` for `u < 0`. -/
def invFact (u : ℤ) : ℝ := if 0 ≤ u then ((u.toNat.factorial : ℝ))⁻¹ else 0

lemma invFact_natCast (t : ℕ) : invFact t = ((t.factorial : ℝ))⁻¹ := by
  simp [invFact]

lemma invFact_eq {u : ℤ} {t : ℕ} (h : u = t) : invFact u = ((t.factorial : ℝ))⁻¹ := by
  rw [h, invFact_natCast]

lemma invFact_of_neg {u : ℤ} (h : u < 0) : invFact u = 0 := by
  rw [invFact, ite_eq_right (not_le.mpr h)]

lemma nonneg_of_invFact_ne_zero {u : ℤ} (h : invFact u ≠ 0) : 0 ≤ u := by
  by_contra h'
  exact h (invFact_of_neg (by omega))

lemma neg_one_zpow_congr {p q : ℤ} (h : p % 2 = q % 2) : (-1 : ℝ) ^ p = (-1) ^ q := by
  obtain ⟨t, rfl⟩ : ∃ t, p = q + 2 * t := ⟨(p - q) / 2, by omega⟩
  rw [zpow_add₀ (by norm_num), zpow_mul, show ((-1 : ℝ) ^ (2 : ℤ)) = 1 by norm_num, one_zpow,
    mul_one]

/-- The summand of `sixSum`. -/
def sixTerm (a₁ a₂ a₃ b₁ b₂ b₃ z : ℤ) : ℝ :=
  (-1 : ℝ) ^ z * (invFact (z - a₁) * invFact (z - a₂) * invFact (z - a₃) *
    (invFact (b₁ - z) * invFact (b₂ - z) * invFact (b₃ - z)))

/-- `Σ_z (-1)^z / ((z - a₁)! (z - a₂)! (z - a₃)! (b₁ - z)! (b₂ - z)! (b₃ - z)!)`, over the `z`
for which all six arguments are nonnegative. -/
def sixSum (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) : ℝ := ∑ᶠ z : ℤ, sixTerm a₁ a₂ a₃ b₁ b₂ b₃ z

lemma sixSum_swap_a12 (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) :
    sixSum a₁ a₂ a₃ b₁ b₂ b₃ = sixSum a₂ a₁ a₃ b₁ b₂ b₃ :=
  finsum_congr fun z => by simp only [sixTerm]; ring

lemma sixSum_swap_a23 (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) :
    sixSum a₁ a₂ a₃ b₁ b₂ b₃ = sixSum a₁ a₃ a₂ b₁ b₂ b₃ :=
  finsum_congr fun z => by simp only [sixTerm]; ring

lemma sixSum_swap_b12 (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) :
    sixSum a₁ a₂ a₃ b₁ b₂ b₃ = sixSum a₁ a₂ a₃ b₂ b₁ b₃ :=
  finsum_congr fun z => by simp only [sixTerm]; ring

lemma sixSum_swap_b23 (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) :
    sixSum a₁ a₂ a₃ b₁ b₂ b₃ = sixSum a₁ a₂ a₃ b₁ b₃ b₂ :=
  finsum_congr fun z => by simp only [sixTerm]; ring

/-- Shifting all arguments by `c` multiplies the sum by `(-1)^c`. -/
lemma sixSum_shift (a₁ a₂ a₃ b₁ b₂ b₃ c : ℤ) :
    sixSum (a₁ + c) (a₂ + c) (a₃ + c) (b₁ + c) (b₂ + c) (b₃ + c) =
      (-1) ^ c * sixSum a₁ a₂ a₃ b₁ b₂ b₃ := by
  rw [sixSum, sixSum, mul_finsum, ← finsum_comp_equiv (Equiv.addRight c)]
  refine finsum_congr fun z => ?_
  simp only [sixTerm, Equiv.coe_addRight, add_sub_add_right_eq_sub]
  rw [zpow_add₀ (by norm_num)]
  ring

/-- The reflection `z ↦ -z`. -/
lemma sixSum_neg (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) :
    sixSum a₁ a₂ a₃ b₁ b₂ b₃ = sixSum (-b₁) (-b₂) (-b₃) (-a₁) (-a₂) (-a₃) := by
  rw [sixSum, sixSum, ← finsum_comp_equiv (Equiv.neg ℤ)]
  refine finsum_congr fun z => ?_
  simp only [sixTerm, Equiv.neg_apply]
  rw [neg_one_zpow_congr (show -z % 2 = z % 2 by omega), show -z - a₁ = -a₁ - z by ring,
    show -z - a₂ = -a₂ - z by ring, show -z - a₃ = -a₃ - z by ring,
    show b₁ - -z = z - -b₁ by ring, show b₂ - -z = z - -b₂ by ring, show b₃ - -z = z - -b₃ by ring]
  ring

/-!

## B. Regge squares and the 3j symbol

-/

/-- All rows and columns of `R` have the same sum as the first row. -/
def IsMagic (R : Fin 3 → Fin 3 → ℕ) : Prop :=
  R 1 0 + R 1 1 + R 1 2 = R 0 0 + R 0 1 + R 0 2 ∧ R 2 0 + R 2 1 + R 2 2 = R 0 0 + R 0 1 + R 0 2 ∧
  R 0 0 + R 1 0 + R 2 0 = R 0 0 + R 0 1 + R 0 2 ∧ R 0 1 + R 1 1 + R 2 1 = R 0 0 + R 0 1 + R 0 2 ∧
  R 0 2 + R 1 2 + R 2 2 = R 0 0 + R 0 1 + R 0 2

/-- The 3j symbol of a Regge square `R`, by Racah's formula. -/
def threeJR (R : Fin 3 → Fin 3 → ℕ) : ℝ :=
  (-1) ^ (R 2 0 + R 1 1) *
    Real.sqrt ((∏ i, ∏ j, ((R i j).factorial : ℝ)) / ((R 0 0 + R 0 1 + R 0 2 + 1).factorial : ℝ)) *
    sixSum 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1)

lemma neg_one_pow_mul_mul_zpow {n n' q : ℕ} {s : ℤ} (X Y : ℝ)
    (h : ((n' : ℤ) + s) % 2 = ((n : ℤ) + q) % 2) :
    (-1 : ℝ) ^ n' * X * ((-1) ^ s * Y) = (-1) ^ q * ((-1) ^ n * X * Y) := by
  have h' := neg_one_zpow_congr h
  rw [zpow_add₀ (by norm_num), zpow_add₀ (by norm_num), zpow_natCast, zpow_natCast,
    zpow_natCast] at h'
  linear_combination X * Y * h'

lemma neg_one_pow_mul_mul_zpow' {n n' : ℕ} {s : ℤ} (X Y : ℝ)
    (h : ((n' : ℤ) + s) % 2 = (n : ℤ) % 2) :
    (-1 : ℝ) ^ n' * X * ((-1) ^ s * Y) = (-1) ^ n * X * Y := by
  simpa using neg_one_pow_mul_mul_zpow (q := 0) X Y (by simpa using h)

/-!

## C. Symmetries

-/

/-- **Regge symmetry.** Transposing the square leaves the 3j symbol unchanged. -/
lemma threeJR_transpose {R : Fin 3 → Fin 3 → ℕ} (hR : IsMagic R) :
    threeJR (fun i j => R j i) = threeJR R := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := hR
  have hS : sixSum 0 ((R 0 1 : ℤ) - R 1 0) ((R 1 2 : ℤ) - R 0 0) (R 2 0) (R 0 1) (R 1 2) =
      (-1) ^ ((R 0 1 : ℤ) - R 1 0) *
        sixSum 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1) := by
    rw [← sixSum_shift]
    calc _ = sixSum ((R 1 0 : ℤ) - R 0 1 + (R 0 1 - R 1 0)) (0 + ((R 0 1 : ℤ) - R 1 0))
          ((R 2 1 : ℤ) - R 0 0 + (R 0 1 - R 1 0)) (R 0 2 + ((R 0 1 : ℤ) - R 1 0))
          (R 1 0 + ((R 0 1 : ℤ) - R 1 0)) (R 2 1 + ((R 0 1 : ℤ) - R 1 0)) := by
          congr 1 <;> omega
      _ = _ := sixSum_swap_a12 _ _ _ _ _ _
  have hJ : R 0 0 + R 1 0 + R 2 0 = R 0 0 + R 0 1 + R 0 2 := by omega
  simp only [threeJR]
  rw [hJ, Finset.prod_comm, hS]
  exact neg_one_pow_mul_mul_zpow' _ _ (by push_cast; omega)

/-- Swapping the first two columns multiplies the 3j symbol by `(-1)^J`. -/
lemma threeJR_swap_columns {R : Fin 3 → Fin 3 → ℕ} (hR : IsMagic R) :
    threeJR (fun i => ![R i 1, R i 0, R i 2]) = (-1) ^ (R 0 0 + R 0 1 + R 0 2) * threeJR R := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := hR
  have hS : sixSum 0 ((R 1 1 : ℤ) - R 0 0) ((R 2 0 : ℤ) - R 0 1) (R 0 2) (R 1 1) (R 2 0) =
      (-1) ^ (R 0 2 : ℤ) *
        sixSum 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1) := by
    rw [sixSum_neg 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1),
      ← sixSum_shift]
    calc _ = sixSum (-(R 0 2 : ℤ) + R 0 2) (-(R 2 1 : ℤ) + R 0 2) (-(R 1 0 : ℤ) + R 0 2)
          (-0 + (R 0 2 : ℤ)) (-((R 2 1 : ℤ) - R 0 0) + R 0 2) (-((R 1 0 : ℤ) - R 0 1) + R 0 2) := by
          congr 1 <;> omega
      _ = _ := by rw [sixSum_swap_a23, sixSum_swap_b23]
  have hJ : R 0 1 + R 0 0 + R 0 2 = R 0 0 + R 0 1 + R 0 2 := by omega
  have hP : (∏ i, ∏ j, ((![R i 1, R i 0, R i 2] j).factorial : ℝ)) =
      ∏ i, ∏ j, ((R i j).factorial : ℝ) := by
    simp only [Fin.prod_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_two, Matrix.head_cons, Matrix.tail_cons]
    ring
  simp only [threeJR, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    Matrix.head_cons, Matrix.tail_cons]
  rw [hJ, hP, hS]
  exact neg_one_pow_mul_mul_zpow _ _ (by push_cast; omega)

/-- Permuting the columns cyclically leaves the 3j symbol unchanged. -/
lemma threeJR_cycle_columns {R : Fin 3 → Fin 3 → ℕ} (hR : IsMagic R) :
    threeJR (fun i => ![R i 1, R i 2, R i 0]) = threeJR R := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := hR
  have hS : sixSum 0 ((R 1 1 : ℤ) - R 0 2) ((R 2 2 : ℤ) - R 0 1) (R 0 0) (R 1 1) (R 2 2) =
      (-1) ^ ((R 1 1 : ℤ) - R 0 2) *
        sixSum 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1) := by
    rw [← sixSum_shift]
    calc _ = sixSum ((R 2 1 : ℤ) - R 0 0 + (R 1 1 - R 0 2)) (0 + ((R 1 1 : ℤ) - R 0 2))
          ((R 1 0 : ℤ) - R 0 1 + (R 1 1 - R 0 2)) (R 2 1 + ((R 1 1 : ℤ) - R 0 2))
          (R 0 2 + ((R 1 1 : ℤ) - R 0 2)) (R 1 0 + ((R 1 1 : ℤ) - R 0 2)) := by
          congr 1 <;> omega
      _ = _ := by rw [sixSum_swap_a12, sixSum_swap_a23, sixSum_swap_b12, sixSum_swap_b23]
  have hJ : R 0 1 + R 0 2 + R 0 0 = R 0 0 + R 0 1 + R 0 2 := by omega
  have hP : (∏ i, ∏ j, ((![R i 1, R i 2, R i 0] j).factorial : ℝ)) =
      ∏ i, ∏ j, ((R i j).factorial : ℝ) := by
    simp only [Fin.prod_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_two, Matrix.head_cons, Matrix.tail_cons]
    ring
  simp only [threeJR, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    Matrix.head_cons, Matrix.tail_cons]
  rw [hJ, hP, hS]
  exact neg_one_pow_mul_mul_zpow' _ _ (by push_cast; omega)

/-- Swapping the last two rows, `m ↦ -m`, multiplies the 3j symbol by `(-1)^J`. -/
lemma threeJR_swap_rows {R : Fin 3 → Fin 3 → ℕ} (hR : IsMagic R) :
    threeJR ![R 0, R 2, R 1] = (-1) ^ (R 0 0 + R 0 1 + R 0 2) * threeJR R := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := hR
  have hS : sixSum 0 ((R 2 0 : ℤ) - R 0 1) ((R 1 1 : ℤ) - R 0 0) (R 0 2) (R 2 0) (R 1 1) =
      (-1) ^ (R 0 2 : ℤ) *
        sixSum 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1) := by
    rw [sixSum_neg 0 ((R 1 0 : ℤ) - R 0 1) ((R 2 1 : ℤ) - R 0 0) (R 0 2) (R 1 0) (R 2 1),
      ← sixSum_shift]
    congr 1 <;> omega
  have hP : (∏ i, ∏ j, ((![R 0, R 2, R 1] i j).factorial : ℝ)) =
      ∏ i, ∏ j, ((R i j).factorial : ℝ) := by
    simp only [Fin.prod_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_two, Matrix.head_cons, Matrix.tail_cons]
    ring
  simp only [threeJR, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    Matrix.head_cons, Matrix.tail_cons]
  rw [hP, hS]
  exact neg_one_pow_mul_mul_zpow _ _ (by push_cast; omega)

/-!

## D. Relation to the Clebsch–Gordan coefficients

-/

variable {m n : ℕ}

/-- The Regge square of `(j₁ j₂ J; m₁ m₂ -M)` in the parameters of `ClebschGordanCoefficients`:
`m = 2j₁`, `n = 2j₂`, `J = (m + n)/2 - k`, `M = J - l`, `m₁ = j₁ - α`, `m₂ = j₂ - β`. -/
def regge (m n k l α β : ℕ) : Fin 3 → Fin 3 → ℕ :=
  ![![n - k, m - k, k], ![α, β, m + n - 2 * k - l], ![m - α, n - β, l]]

lemma isMagic_regge {k l α β : ℕ} (hkm : k ≤ m) (hkn : k ≤ n) (hl : l ≤ m + n - 2 * k)
    (hα : α ≤ m) (hβ : β ≤ n) (h : α + β = k + l) : IsMagic (regge m n k l α β) := by
  simp only [IsMagic, regge, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    Matrix.head_cons, Matrix.tail_cons]
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> omega

/-- Racah's sum `racahSum` of `ClebschGordanFormula` is the six-factorial sum of the square. -/
lemma sixSum_regge_eq_racahSum {k α β : ℕ} (hkm : k ≤ m) (hkn : k ≤ n) (hβ : β ≤ n) :
    sixSum 0 ((α : ℤ) - (m - k : ℕ)) (((n - β : ℕ) : ℤ) - (n - k : ℕ)) k α (n - β : ℕ) =
      racahSum m n k α β := by
  rw [sixSum, finsum_eq_sum_of_support_subset (s := (Finset.range (k + 1)).map Nat.castEmbedding)]
  · rw [Finset.sum_map, racahSum]
    refine Finset.sum_congr rfl fun z hz => ?_
    have hzk : z ≤ k := Nat.lt_succ_iff.mp (Finset.mem_range.mp hz)
    simp only [Nat.castEmbedding_apply, sixTerm]
    by_cases hg : z ≤ α ∧ α ≤ m - k + z ∧ k ≤ β + z ∧ β + z ≤ n
    · rw [ite_eq_left hg]
      obtain ⟨g1, g2, g3, g4⟩ := hg
      rw [invFact_eq (show (z : ℤ) - 0 = (z : ℕ) by ring),
        invFact_eq (show (z : ℤ) - ((α : ℤ) - (m - k : ℕ)) = ((m - k + z - α : ℕ) : ℤ) by omega),
        invFact_eq (show (z : ℤ) - (((n - β : ℕ) : ℤ) - (n - k : ℕ)) = ((β + z - k : ℕ) : ℤ) by
          omega),
        invFact_eq (show (k : ℤ) - z = ((k - z : ℕ) : ℤ) by omega),
        invFact_eq (show (α : ℤ) - z = ((α - z : ℕ) : ℤ) by omega),
        invFact_eq (show ((n - β : ℕ) : ℤ) - z = ((n - β - z : ℕ) : ℤ) by omega), zpow_natCast]
      push_cast
      ring
    · rw [ite_eq_right hg]
      by_cases h1 : z ≤ α
      · by_cases h2 : α ≤ m - k + z
        · by_cases h3 : k ≤ β + z
          · rw [invFact_of_neg (show ((n - β : ℕ) : ℤ) - z < 0 by omega)]
            simp
          · rw [invFact_of_neg (show (z : ℤ) - (((n - β : ℕ) : ℤ) - (n - k : ℕ)) < 0 by omega)]
            simp
        · rw [invFact_of_neg (show (z : ℤ) - ((α : ℤ) - (m - k : ℕ)) < 0 by omega)]
          simp
      · rw [invFact_of_neg (show (α : ℤ) - z < 0 by omega)]
        simp
  · intro z hz
    rw [Function.mem_support] at hz
    simp only [sixTerm, ne_eq, mul_eq_zero, not_or] at hz
    have h0 := nonneg_of_invFact_ne_zero hz.2.1.1.1
    have hk := nonneg_of_invFact_ne_zero hz.2.2.1.1
    simp only [Finset.coe_map, Set.mem_image, Finset.mem_coe, Finset.mem_range,
      Nat.castEmbedding_apply]
    exact ⟨z.toNat, by omega, by omega⟩

/-- **The 3j symbols and the Clebsch–Gordan coefficients.**
`⟨j₁ m₁ j₂ m₂ | J M⟩ = (-1)^(j₁ - j₂ + M) √(2J + 1) (j₁ j₂ J; m₁ m₂ -M)`, where
`j₁ - j₂ + M = m - k - l ≡ m + k + l (mod 2)`. -/
lemma cgCoefficient_eq_threeJR {k l α β : ℕ} (hkm : k ≤ m) (hkn : k ≤ n)
    (hl : l ≤ m + n - 2 * k) (hα : α ≤ m) (hβ : β ≤ n) (h : α + β = k + l) :
    cgCoefficient m n k l α β = (-1) ^ (m + k + l) *
      Real.sqrt ((m + n - 2 * k + 1 : ℕ) : ℝ) * threeJR (regge m n k l α β) := by
  rw [cgCoefficient_racah hkm hkn hl hα hβ h, threeJR]
  simp only [regge, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    Matrix.head_cons, Matrix.tail_cons, Fin.prod_univ_three]
  rw [sixSum_regge_eq_racahSum hkm hkn hβ, show n - k + (m - k) + k + 1 = m + n - k + 1 by omega,
    neg_one_pow_eq_pow_mod_two (n := m - α + β), show (m - α + β) % 2 = (m + k + l) % 2 by omega,
    ← neg_one_pow_eq_pow_mod_two]
  have hsq : ((-1 : ℝ) ^ (m + k + l)) ^ 2 = 1 := by
    rw [← pow_mul, mul_comm, pow_mul, neg_one_sq, one_pow]
  have hsqrt : Real.sqrt (((m + n - 2 * k + 1) * (m - k).factorial * (n - k).factorial *
      k.factorial : ℕ) / ((m + n - k + 1).factorial : ℝ)) *
      Real.sqrt (((m + n - 2 * k - l).factorial * l.factorial * α.factorial * (m - α).factorial *
        β.factorial * (n - β).factorial : ℕ) : ℝ) =
      Real.sqrt ((m + n - 2 * k + 1 : ℕ) : ℝ) *
        Real.sqrt (((n - k).factorial * (m - k).factorial * k.factorial *
          (α.factorial * β.factorial * (m + n - 2 * k - l).factorial) *
          ((m - α).factorial * (n - β).factorial * l.factorial) : ℝ) /
          ((m + n - k + 1).factorial : ℝ)) := by
    rw [← Real.sqrt_mul' _ (Nat.cast_nonneg _), ← Real.sqrt_mul (Nat.cast_nonneg _)]
    congr 1
    push_cast
    ring
  rw [hsqrt]
  linear_combination (-(Real.sqrt ((m + n - 2 * k + 1 : ℕ) : ℝ)) *
    Real.sqrt (((n - k).factorial * (m - k).factorial * k.factorial *
      (α.factorial * β.factorial * (m + n - 2 * k - l).factorial) *
      ((m - α).factorial * (n - β).factorial * l.factorial) : ℝ) /
      ((m + n - k + 1).factorial : ℝ)) * racahSum m n k α β) * hsq

/-!

## E. Orthogonality

-/

/-- The 3j symbol `(j₁ j₂ J; m₁ m₂ -M)` in the parameters of `ClebschGordanCoefficients`, zero
unless `m₁ + m₂ = M`. -/
def wigner3j (m n k l α β : ℕ) : ℝ :=
  if α + β = k + l then threeJR (regge m n k l α β) else 0

lemma cgCoefficient_eq_wigner3j (hmn : 0 < m + n) {k l α β : ℕ} (hkm : k ≤ m) (hkn : k ≤ n)
    (hl : l ≤ m + n - 2 * k) (hα : α ≤ m) (hβ : β ≤ n) :
    cgCoefficient m n k l α β = (-1) ^ (m + k + l) *
      Real.sqrt ((m + n - 2 * k + 1 : ℕ) : ℝ) * wigner3j m n k l α β := by
  by_cases h : α + β = k + l
  · rw [wigner3j, ite_eq_left h, cgCoefficient_eq_threeJR hkm hkn hl hα hβ h]
  · rw [wigner3j, ite_eq_right h, mul_zero, cgCoefficient_eq_zero_of_ne hmn hkm hkn h]

/-- **Orthogonality.** `Σ_{m₁ m₂} (j₁ j₂ J; m₁ m₂ -M) (j₁ j₂ J'; m₁ m₂ -M') =
δ_{JJ'} δ_{MM'} / (2J + 1)`. -/
lemma sum_wigner3j_mul_wigner3j (hmn : 0 < m + n) {k k' l l' : ℕ} (hkm : k ≤ m) (hkn : k ≤ n)
    (hk'm : k' ≤ m) (hk'n : k' ≤ n) (hl : l ≤ m + n - 2 * k) (hl' : l' ≤ m + n - 2 * k') :
    ∑ a ∈ Finset.range (m + 1), ∑ b ∈ Finset.range (n + 1),
      wigner3j m n k l a b * wigner3j m n k' l' a b =
        if k = k' ∧ l = l' then 1 / ((m + n - 2 * k + 1 : ℕ) : ℝ) else 0 := by
  set c : ℝ := (-1) ^ (m + k + l) * Real.sqrt ((m + n - 2 * k + 1 : ℕ) : ℝ) *
    ((-1) ^ (m + k' + l') * Real.sqrt ((m + n - 2 * k' + 1 : ℕ) : ℝ)) with hc
  have hsum : ∑ a ∈ Finset.range (m + 1), ∑ b ∈ Finset.range (n + 1),
      cgCoefficient m n k l a b * cgCoefficient m n k' l' a b =
      c * ∑ a ∈ Finset.range (m + 1), ∑ b ∈ Finset.range (n + 1),
        wigner3j m n k l a b * wigner3j m n k' l' a b := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun a ha => ?_
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun b hb => ?_
    have ha' := Nat.lt_succ_iff.mp (Finset.mem_range.mp ha)
    have hb' := Nat.lt_succ_iff.mp (Finset.mem_range.mp hb)
    rw [cgCoefficient_eq_wigner3j hmn hkm hkn hl ha' hb',
      cgCoefficient_eq_wigner3j hmn hk'm hk'n hl' ha' hb', hc]
    ring
  rw [sum_cgCoefficient_mul hmn hkm hkn hk'm hk'n hl] at hsum
  have hpos : (0 : ℝ) < ((m + n - 2 * k + 1 : ℕ) : ℝ) := by positivity
  have hpos' : (0 : ℝ) < ((m + n - 2 * k' + 1 : ℕ) : ℝ) := by positivity
  by_cases hkl : k = k' ∧ l = l'
  · obtain ⟨rfl, rfl⟩ := hkl
    rw [ite_eq_left ⟨rfl, rfl⟩] at hsum ⊢
    have hc1 : c = ((m + n - 2 * k + 1 : ℕ) : ℝ) := by
      have hs := Real.mul_self_sqrt hpos.le
      have hsq : ((-1 : ℝ) ^ (m + k + l)) ^ 2 = 1 := by
        rw [← pow_mul, mul_comm, pow_mul, neg_one_sq, one_pow]
      rw [hc]
      linear_combination ((-1 : ℝ) ^ (m + k + l)) ^ 2 * hs +
        ((m + n - 2 * k + 1 : ℕ) : ℝ) * hsq
    rw [hc1] at hsum
    rw [eq_div_iff hpos.ne']
    linarith
  · rw [ite_eq_right hkl] at hsum ⊢
    have hc0 : c ≠ 0 := by
      rw [hc]
      exact mul_ne_zero (mul_ne_zero (pow_ne_zero _ (by norm_num)) (Real.sqrt_pos.mpr hpos).ne')
        (mul_ne_zero (pow_ne_zero _ (by norm_num)) (Real.sqrt_pos.mpr hpos').ne')
    exact (mul_eq_zero.mp hsum.symm).resolve_left hc0

/-- **Second orthogonality relation.**
`Σ_{J M} (2J + 1) (j₁ j₂ J; m₁ m₂ -M) (j₁ j₂ J; m₁' m₂' -M) = δ_{m₁ m₁'} δ_{m₂ m₂'}`. -/
lemma sum_wigner3j_mul_wigner3j_JM (hmn : 0 < m + n) {a b a' b' : ℕ} (ha : a ≤ m) (hb : b ≤ n)
    (ha' : a' ≤ m) (hb' : b' ≤ n) :
    ∑ k ∈ Finset.range (min m n + 1), ∑ l ∈ Finset.range (m + n - 2 * k + 1),
      ((m + n - 2 * k + 1 : ℕ) : ℝ) * wigner3j m n k l a b * wigner3j m n k l a' b' =
        if a = a' ∧ b = b' then 1 else 0 := by
  rw [← sum_cgCoefficient_mul_cgCoefficient hmn ha hb ha' hb']
  refine Finset.sum_congr rfl fun k hk => Finset.sum_congr rfl fun l hl => ?_
  have hk' : k ≤ min m n := Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
  have hl' : l ≤ m + n - 2 * k := Nat.lt_succ_iff.mp (Finset.mem_range.mp hl)
  have hkm : k ≤ m := le_trans hk' (min_le_left _ _)
  have hkn : k ≤ n := le_trans hk' (min_le_right _ _)
  rw [cgCoefficient_eq_wigner3j hmn hkm hkn hl' ha hb,
    cgCoefficient_eq_wigner3j hmn hkm hkn hl' ha' hb']
  have hpos : (0 : ℝ) ≤ ((m + n - 2 * k + 1 : ℕ) : ℝ) := Nat.cast_nonneg _
  have hs := Real.mul_self_sqrt hpos
  have hsq : ((-1 : ℝ) ^ (m + k + l)) ^ 2 = 1 := by
    rw [← pow_mul, mul_comm, pow_mul, neg_one_sq, one_pow]
  linear_combination (-(wigner3j m n k l a b * wigner3j m n k l a' b') *
    ((-1 : ℝ) ^ (m + k + l)) ^ 2) * hs -
    ((m + n - 2 * k + 1 : ℕ) : ℝ) * wigner3j m n k l a b * wigner3j m n k l a' b' * hsq

end PhyslibAlpha.Sl2
