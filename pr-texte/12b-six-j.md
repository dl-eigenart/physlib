# feat(PhyslibAlpha): recoupling coefficients and 6j symbols

Branch: `pr/six-j` · Base: master after merge of `pr/coupling-schemes` · Depends on: `pr/coupling-schemes`

This PR defines the recoupling coefficients between the two coupling schemes of `pr/coupling-schemes` as the contravariant form between them, and proves that they do not depend on `M` and form an orthogonal matrix. The 6j symbol `sixJ` is defined from the recoupling coefficient at `M = J`, and its orthogonality relation follows.

## Main results

- `eq_sum_vecA`: the states `|(j₁ j₂) j₁₂, j₃; J M⟩` form an orthonormal basis of the triple product.
- `tripleForm_stateA_stateB_eq_zero`: states of the two schemes with different `J` or different `M` are orthogonal.
- `recoupling_eq_recoupling_zero`: `⟨(j₁ j₂) j₁₂, j₃; J M | j₁, (j₂ j₃) j₂₃; J M⟩` does not depend on `M`.
- `sum_recoupling_mul_recoupling`: `Σ_{j₁₂} ⟨… j₁₂ … | … j₂₃ …⟩ ⟨… j₁₂ … | … j₂₃' …⟩ = δ_{j₂₃ j₂₃'}`.
- `sum_sixJ_mul_sixJ`: `Σ_{j₁₂} (2j₁₂ + 1)(2j₂₃ + 1) {j₁ j₂ j₁₂; j₃ J j₂₃}{j₁ j₂ j₁₂; j₃ J j₂₃'} = δ_{j₂₃ j₂₃'}`.

## Reviewer map

1. `SixJ.lean` §A Eigenvalues, ladders and orthonormality of the coupled states: eigenvalues of `tripleH` and `tripleCas`, the lowering step `tripleF_stateA` and the raising step `tripleE_stateB_succ`.
2. `SixJ.lean` §A.1 Completeness of the first coupling scheme: the general lemma `eq_sum_of_orthonormal`, the dimension count `card_indexA`, and `tripleForm_vecA`.
3. `SixJ.lean` §A.2 Separation by `J` and `M`: comparison of the eigenvalues of `tripleCas` and `tripleH` via `nat_eq_of_mul_add_two_eq`.
4. `SixJ.lean` §A.3 The recoupling coefficients: the admissibility predicates `ValidA`, `ValidB`, the definition `recoupling`, and the induction on `l` in `recoupling_eq_recoupling_zero` using `tripleForm_tripleF`.
5. `SixJ.lean` §A.4 Orthogonality: the expansion of `stateB` in the basis `vecA` and the case split on `ValidA` in `sum_recoupling_mul_recoupling`.
6. `SixJ.lean` §B The 6j symbols: the phase `(-1)^(a + b + c - K)` and the factor `√((2j₁₂ + 1)(2j₂₃ + 1))` in `sixJ`, and `sum_sixJ_mul_sixJ`.
7. `PhyslibAlpha.lean`: the added import.

## Declarations

All declarations are in the namespace `PhyslibAlpha.Sl2`.

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/SixJ.lean`

| Declaration | Kind | Description |
|---|---|---|
| `tripleH_stateA` | lemma | `stateA` has `tripleH`-eigenvalue `2J - 2l`. |
| `tripleCas_stateA` | lemma | `stateA` has `tripleCas`-eigenvalue `2J(2J + 2)/2`. |
| `tripleF_stateA` | lemma | `tripleF (stateA … l) = √((l + 1)(2J - l)) • stateA … (l + 1)` for `l < 2J`. |
| `tripleH_stateB` | lemma | `stateB` has `tripleH`-eigenvalue `2J - 2l`. |
| `tripleCas_stateB` | lemma | `stateB` has `tripleCas`-eigenvalue `2J(2J + 2)/2`. |
| `tripleE_stateB_succ` | lemma | `tripleE (stateB … (l + 1)) = √((l + 1)(2J - l)) • stateB … l` for `l < 2J`. |
| `tripleForm_stateB_self` | lemma | `stateB` is normalised for `l ≤ 2J`. |
| `tripleForm_stateB_of_ne` | lemma | `stateB` vectors with `k₃ ≠ k₃'` are orthogonal. |
| `eq_sum_of_orthonormal` | lemma | An orthonormal family of `finrank` many vectors gives the expansion `x = Σ_i B(v_i, x) v_i`. |
| `IndexA` | abbrev | The index set `Σ k₁, StringIndex (a + b - 2k₁) c` of the first scheme. |
| (anonymous) `Nonempty (IndexA a b c)` | instance | `IndexA a b c` is nonempty. |
| `vecA` | def | `stateA` as a family indexed by `IndexA`. |
| `card_indexA` | lemma | `card (IndexA a b c) = finrank (Triple a b c)`. |
| `tripleForm_vecA` | lemma | `vecA` is orthonormal for `tripleForm` (`0 < c`). |
| `eq_sum_vecA` | lemma | Completeness: every `x` is `Σ_i tripleForm (vecA i) x • vecA i`. |
| `nat_eq_of_mul_add_two_eq` | lemma | `p(p + 2) = q(q + 2)` implies `p = q` in `ℕ`. |
| `tripleForm_stateA_stateB_eq_zero` | lemma | `stateA` and `stateB` with different `J` or `M` are orthogonal. |
| `ValidA` | abbrev | `k₁` gives an admissible `j₁₂` for `J = (a + b + c)/2 - K`. |
| `ValidB` | abbrev | `k₃` gives an admissible `j₂₃` for `J = (a + b + c)/2 - K`. |
| `recoupling` | def | `tripleForm (stateA k₁ (K - k₁) l) (stateB k₃ (K - k₃) l)`. |
| `recoupling_succ` | lemma | `recoupling` at `l + 1` equals `recoupling` at `l`, for `l < 2J`. |
| `recoupling_eq_recoupling_zero` | lemma | `recoupling` at `l` equals `recoupling` at `l = 0`, for `l ≤ 2J`. |
| `sum_recoupling_mul_recoupling` | lemma | Orthogonality of the recoupling coefficients, summed over admissible `k₁`. |
| `sixJ` | def | `(-1)^(a + b + c - K) · recoupling … 0 … / √((2j₁₂ + 1)(2j₂₃ + 1))` for admissible arguments, `0` otherwise. |
| `recoupling_eq_sixJ` | lemma | `recoupling = (-1)^(a + b + c - K) √((2j₁₂ + 1)(2j₂₃ + 1)) · sixJ` for every `l ≤ 2J`. |
| `mul_mul_div_mul_div_sqrt` | lemma | A real identity for products of `s U / √(p₁ p₃)` with `s² = 1`, used in `sum_sixJ_mul_sixJ`. |
| `sum_sixJ_mul_sixJ` | lemma | Orthogonality of the 6j symbols, summed over `k₁`. |

## Notes

- Spins are doubled: `j₁ = a/2`, `j₂ = b/2`, `j₃ = c/2`; `j₁₂`, `j₂₃` and `J` are encoded by `k₁`, `k₃` and `K`.
- Besides `0 < a + b` and `0 < b + c`, `tripleH_stateA`, `tripleCas_stateA`, `tripleForm_vecA` and `eq_sum_vecA` assume `0 < c`, and `tripleH_stateB`, `tripleCas_stateB`, `tripleE_stateB_succ`, `tripleForm_stateB_self`, `recoupling_succ`, `recoupling_eq_recoupling_zero` and `recoupling_eq_sixJ` assume `0 < a`; `tripleForm_stateA_stateB_eq_zero`, `sum_recoupling_mul_recoupling` and `sum_sixJ_mul_sixJ` assume both.
- `sixJ` is defined from the recoupling coefficient; Racah's closed formula for the 6j symbols is not proved here.
- `eq_sum_of_orthonormal`, `nat_eq_of_mul_add_two_eq` and `mul_mul_div_mul_div_sqrt` are general auxiliary results.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
