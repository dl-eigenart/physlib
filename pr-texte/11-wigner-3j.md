# feat(PhyslibAlpha): Wigner 3j symbols and the multipole sum rule

Branch: `pr/wigner-3j` · Base: master after merge of `pr/clebsch-gordan-formula` · Depends on: `pr/clebsch-gordan-formula` (and through it #1911 and #1876)

This PR defines the Wigner 3j symbol of a Regge square by Racah's formula, proves its column, row and Regge symmetries, and identifies it with the Clebsch-Gordan coefficients `cgCoefficient`. From this it derives the two orthogonality relations of the 3j symbols and the sum rule `Σ_{μ M_f} ⟨J_i M_i λ μ | J_f M_f⟩² = (2J_f + 1)/(2J_i + 1)` for multipole transitions. It builds on Racah's formula `cgCoefficient_racah` of `pr/clebsch-gordan-formula` and the orthogonality relations `sum_cgCoefficient_mul` and `sum_cgCoefficient_mul_cgCoefficient` of #1911 and `pr/clebsch-gordan-formula`.

## Main results

- `threeJR_transpose`, `threeJR_swap_columns`, `threeJR_cycle_columns`, `threeJR_swap_rows`: the 3j symbol of a Regge square is invariant under transposition and cyclic column permutations, and changes by `(-1)^J` under a swap of two columns or of the last two rows.
- `threeJR_perm`: permuting the rows by `σ` and the columns by `τ` multiplies the 3j symbol by `(sign σ · sign τ)^J`; with `threeJR_transpose` these are 72 distinct symmetries (`perm_prodMap_injective`, `prodMap_ne_swap`).
- `cgCoefficient_eq_threeJR`: `⟨j₁ m₁ j₂ m₂ | J M⟩ = (-1)^(j₁ - j₂ + M) √(2J + 1) (j₁ j₂ J; m₁ m₂ -M)`.
- `sum_wigner3j_mul_wigner3j`: `Σ_{m₁ m₂} (j₁ j₂ J; m₁ m₂ -M)(j₁ j₂ J'; m₁ m₂ -M') = δ_{JJ'} δ_{MM'}/(2J + 1)`.
- `sum_wigner3j_mul_wigner3j_JM`: `Σ_{J M} (2J + 1)(j₁ j₂ J; m₁ m₂ -M)(j₁ j₂ J; m₁' m₂' -M) = δ_{m₁ m₁'} δ_{m₂ m₂'}`.
- `sum_sq_cgCoefficient_initial`: `Σ_{μ M_f} ⟨J_i M_i λ μ | J_f M_f⟩² = (2J_f + 1)/(2J_i + 1)`, independent of `M_i`.

## Reviewer map

1. `Wigner3j.lean` §A The six-factorial sum: `sixSum` as a `finsum` over `ℤ` with `invFact` vanishing on negative arguments; check `sixSum_shift` and `sixSum_neg`, which carry all symmetry proofs.
2. `Wigner3j.lean` §B Regge squares and the 3j symbol: the definition `threeJR` and the index convention of the square in the module docstring.
3. `Wigner3j.lean` §C Symmetries: each proof reduces to one `sixSum` move plus a parity computation; `IsMagic` supplies the `omega` facts. Then the full group: `isMagic_perm`/`isMagic_transpose` keep squares magic with the same `J`; `threeJR_perm_columns` and `threeJR_perm` build every row/column permutation from the generators; `perm_prodMap_injective` and `prodMap_ne_swap` count 36 · 2 = 72 distinct symmetries.
4. `Wigner3j.lean` §D Relation to the Clebsch-Gordan coefficients: the dictionary `regge` between `(m, n, k, l, α, β)` and `(j₁ j₂ J; m₁ m₂ -M)`, and the phase in `cgCoefficient_eq_threeJR`.
5. `Wigner3j.lean` §E Orthogonality: `wigner3j` is `threeJR ∘ regge` with the selection rule `α + β = k + l`; both relations are transported from the Clebsch-Gordan orthogonality relations.
6. `MultipoleSumRule.lean` §A The cyclic symmetry: the parameter change in `wigner3j_cycle`.
7. `MultipoleSumRule.lean` §B The sum rule: the reindexing `l ↦ m + n - 2k - l` and the use of `sum_wigner3j_mul_wigner3j` with `(n, m + n - 2k)`.

## Declarations

All declarations are in the namespace `PhyslibAlpha.Sl2`.

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/Wigner3j.lean`

| Declaration | Kind | Description |
|---|---|---|
| `invFact` | def | `1/u!` for `u ≥ 0` and `0` for `u < 0`, `u : ℤ`. |
| `invFact_natCast` | lemma | `invFact t = (t!)⁻¹` for `t : ℕ`. |
| `invFact_eq` | lemma | `invFact u = (t!)⁻¹` when `u = t`. |
| `invFact_of_neg` | lemma | `invFact u = 0` for `u < 0`. |
| `nonneg_of_invFact_ne_zero` | lemma | `invFact u ≠ 0` implies `0 ≤ u`. |
| `neg_one_zpow_congr` | lemma | `(-1)^p = (-1)^q` for integers `p ≡ q (mod 2)`. |
| `sixTerm` | def | The summand `(-1)^z ∏ invFact (z - aᵢ) ∏ invFact (bᵢ - z)` of `sixSum`. |
| `sixSum` | def | `Σ_z (-1)^z / ∏(z - aᵢ)! ∏(bᵢ - z)!` over all `z : ℤ`. |
| `sixSum_swap_a12` | lemma | `sixSum` is symmetric in `a₁, a₂`. |
| `sixSum_swap_a23` | lemma | `sixSum` is symmetric in `a₂, a₃`. |
| `sixSum_swap_b12` | lemma | `sixSum` is symmetric in `b₁, b₂`. |
| `sixSum_swap_b23` | lemma | `sixSum` is symmetric in `b₂, b₃`. |
| `sixSum_shift` | lemma | Shifting all six arguments by `c` multiplies `sixSum` by `(-1)^c`. |
| `sixSum_neg` | lemma | `sixSum a b = sixSum (-b) (-a)`, from `z ↦ -z`. |
| `IsMagic` | def | All rows and columns of a `3 × 3` matrix over `ℕ` have the sum of the first row. |
| `threeJR` | def | The 3j symbol of a Regge square by Racah's formula. |
| `neg_one_pow_mul_mul_zpow` | lemma | Sign bookkeeping: `(-1)^n' X ((-1)^s Y) = (-1)^q ((-1)^n X Y)` under a parity condition. |
| `neg_one_pow_mul_mul_zpow'` | lemma | The case `q = 0` of `neg_one_pow_mul_mul_zpow`. |
| `threeJR_transpose` | lemma | Regge symmetry: `threeJR` is invariant under transposition of a magic square. |
| `threeJR_swap_columns` | lemma | Swapping the first two columns multiplies `threeJR` by `(-1)^J`. |
| `threeJR_cycle_columns` | lemma | A cyclic permutation of the columns leaves `threeJR` unchanged. |
| `threeJR_swap_rows` | lemma | Swapping the last two rows (`m ↦ -m`) multiplies `threeJR` by `(-1)^J`. |
| `isMagic_iff` | lemma | `IsMagic R` unfolded: all row and column sums equal the common sum `J`. |
| `isMagic_perm` | lemma | Permuting rows by `σ` and columns by `τ` keeps a square magic. |
| `isMagic_transpose` | lemma | The transpose of a magic square is magic. |
| `isMagic_perm_sum` | lemma | Row and column permutations do not change the sum `J`. |
| `isMagic_transpose_sum` | lemma | Transposition does not change the sum `J`. |
| `threeJR_perm_columns` | lemma | A column permutation `τ` multiplies `threeJR` by `sign(τ)^J`. |
| `threeJR_perm` | lemma | Row permutation `σ` and column permutation `τ` multiply `threeJR` by `(sign σ · sign τ)^J`. |
| `perm_prodMap_injective` | lemma | Distinct pairs `(σ, τ)` act differently on the nine entries of a `3 × 3` square. |
| `prodMap_ne_swap` | lemma | Transposition is not a row and column permutation. |
| `regge` | def | The Regge square of `(j₁ j₂ J; m₁ m₂ -M)` in the parameters `m, n, k, l, α, β` of `ClebschGordanCoefficients`. |
| `isMagic_regge` | lemma | `regge m n k l α β` is magic for admissible parameters with `α + β = k + l`. |
| `sixSum_regge_eq_racahSum` | lemma | The six-factorial sum of `regge` equals `racahSum` of `ClebschGordanFormula`. |
| `cgCoefficient_eq_threeJR` | lemma | `cgCoefficient m n k l α β = (-1)^(m + k + l) √(m + n - 2k + 1) · threeJR (regge …)`. |
| `wigner3j` | def | `threeJR (regge m n k l α β)` if `α + β = k + l`, and `0` otherwise. |
| `cgCoefficient_eq_wigner3j` | lemma | The relation of `cgCoefficient_eq_threeJR` with `wigner3j`, without the hypothesis `α + β = k + l`. |
| `sum_wigner3j_mul_wigner3j` | lemma | First orthogonality relation, summed over `m₁, m₂`. |
| `sum_wigner3j_mul_wigner3j_JM` | lemma | Second orthogonality relation, summed over `J, M` with weight `2J + 1`. |

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/MultipoleSumRule.lean`

| Declaration | Kind | Description |
|---|---|---|
| `wigner3j_cycle` | lemma | `(j₁ j₂ J; m₁ m₂ -M) = (j₂ J j₁; m₂ -M m₁)`, i.e. `wigner3j m n k l α β = wigner3j n (m + n - 2k) (n - k) (m - α) β (m + n - 2k - l)`. |
| `sum_sq_cgCoefficient_initial` | lemma | `Σ_{b, l} cgCoefficient m n k l α b ² = (m + n - 2k + 1)/(m + 1)` for fixed `α`. |

## Notes

- All quantities use the parameters of `ClebschGordanCoefficients`: doubled spins `m = 2j₁`, `n = 2j₂` and natural-number offsets `k, l, α, β`; `wigner3j` is the 3j symbol with third projection `-M`.
- The group of order 72 is given by `threeJR_perm` together with `threeJR_transpose`; a single statement for the whole group is not formulated.
- `invFact`, `neg_one_zpow_congr`, `neg_one_pow_mul_mul_zpow` and `neg_one_pow_mul_mul_zpow'` are auxiliary results about factorials and signs.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
