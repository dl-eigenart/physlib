# feat(PhyslibAlpha): tetrahedral symmetry of the 6j symbols

Branch: `pr/six-j-symmetry` · Base: master after merge of `pr/wigner-3j` and `pr/six-j` · Depends on: `pr/wigner-3j`, `pr/six-j` (and through them `pr/clebsch-gordan-formula`, `pr/clebsch-gordan` and #1876; independent of `pr/wigner-eckart-cg`)

This PR defines the 3j symbol `threeJ` with general arguments in doubled units and the 6j symbol `sixJSym` as a sum over the projections of four 3j symbols, proves the three generating symmetries of the tetrahedron for `sixJSym`, and shows that the 6j symbol `sixJ` of `pr/six-j`, defined through recoupling coefficients, equals `sixJSym`. It builds on the 3j symmetries `threeJR_*` and the relation `cgCoefficient_eq_wigner3j` of `pr/wigner-3j`, and on `recoupling`, `stateA`, `stateB` and `recoupling_eq_recoupling_zero` of `pr/six-j`.

## Main results

- `threeJ_swap`, `threeJ_cycle`, `threeJ_neg`: `threeJ` changes by `(-1)^(j₁ + j₂ + j₃)` under a swap of the first two columns and under `m ↦ -m`, and is invariant under cyclic permutations.
- `sixJSym_swap₁₂`, `sixJSym_swap₂₃`: `{j₂ j₁ j₃; j₅ j₄ j₆} = {j₁ j₃ j₂; j₄ j₆ j₅} = {j₁ j₂ j₃; j₄ j₅ j₆}`.
- `sixJSym_flip₁₂`: `{j₄ j₅ j₃; j₁ j₂ j₆} = {j₁ j₂ j₃; j₄ j₅ j₆}`.
- `recoupling_eq_sum`: the recoupling coefficient as a sum over products of four Clebsch-Gordan coefficients.
- `sixJ_eq_sixJSym`: `sixJ` equals `sixJSym a b (a + b - 2k₁) c (a + b + c - 2K) (b + c - 2k₃)` for admissible arguments.

## Reviewer map

1. `SixJSymmetry.lean` §A The 3j symbol with general arguments: the admissibility predicate `Adm3`, the Regge square `reggeJ` in doubled units, and the reduction of each `threeJ` symmetry to the corresponding `threeJR` lemma; `wigner3j_eq_threeJ` fixes the dictionary to `Wigner3j`.
2. `SixJSymmetry.lean` §B The 6j symbol as a sum over four 3j symbols: the arguments of the four 3j symbols and the sign in `sixJTerm`, and the finite box `sixJBox`.
3. `SixJSymmetry.lean` §C The tetrahedral symmetry: each symmetry is a bijection of `sixJBox` (`Finset.sum_nbij'`) followed by 3j symmetries; the sign bookkeeping is in `term_congr_1324`, `term_congr_1243`, `term_congr_4321` and uses admissibility only where all four 3j symbols are nonzero.
4. `SixJSymmetry.lean` §D The 6j symbols of `SixJ` as sums over four 3j symbols: `tripleForm_normVec_stateB` and `recoupling_eq_sum` expand both states in the product basis; `cg_four_eq` matches one summand with a summand of `sixJSym` (signs via `link_congr`); `sum_sixJTerm_eq` reindexes the sum; `sixJ_eq_sixJSym` sums over `M` with `recoupling_eq_recoupling_zero`.

## Declarations

All declarations are in the namespace `PhyslibAlpha.Sl2`.

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/SixJSymmetry.lean`

| Declaration | Kind | Description |
|---|---|---|
| `Adm3` | abbrev | Admissibility of `(j₁ j₂ j₃; m₁ m₂ m₃)` in doubled units: `Σ mᵢ = 0`, `\|mᵢ\| ≤ jᵢ`, `jᵢ - mᵢ` even, triangle condition, even perimeter. |
| `reggeJ` | def | The Regge square of `(j₁ j₂ j₃; m₁ m₂ m₃)` in doubled units. |
| `threeJ` | def | `threeJR (reggeJ …)` for admissible arguments, `0` otherwise. |
| `threeJ_of_not` | lemma | `threeJ = 0` for inadmissible arguments. |
| `adm3_of_threeJ_ne_zero` | lemma | `threeJ ≠ 0` implies `Adm3`. |
| `isMagic_reggeJ` | lemma | `reggeJ` of admissible arguments is magic. |
| `reggeJ_row_sum` | lemma | The first row of `reggeJ` sums to `(j₁ + j₂ + j₃)/2`. |
| `threeJ_swap` | lemma | `(j₂ j₁ j₃; m₂ m₁ m₃) = (-1)^(j₁ + j₂ + j₃) (j₁ j₂ j₃; m₁ m₂ m₃)`. |
| `threeJ_cycle` | lemma | `(j₂ j₃ j₁; m₂ m₃ m₁) = (j₁ j₂ j₃; m₁ m₂ m₃)`. |
| `threeJ_neg` | lemma | `(j₁ j₂ j₃; -m₁ -m₂ -m₃) = (-1)^(j₁ + j₂ + j₃) (j₁ j₂ j₃; m₁ m₂ m₃)`. |
| `wigner3j_eq_threeJ` | lemma | `wigner3j m n k l α β = threeJ m n (m + n - 2k) (m - 2α) (n - 2β) (-(m + n - 2k - 2l))`. |
| `sixJTerm` | def | The summand `(-1)^(Σ (jᵢ - mᵢ)) (j₁ j₂ j₃; -m₁ -m₂ -m₃)(j₁ j₅ j₆; m₁ -m₅ m₆)(j₄ j₂ j₆; m₄ m₂ -m₆)(j₄ j₅ j₃; -m₄ m₅ m₃)`. |
| `sixJBox` | def | The finite set of projections `m : Fin 6 → ℤ` with `\|mᵢ\| ≤ jᵢ`. |
| `mem_sixJBox` | lemma | Membership in `sixJBox` as six pairs of inequalities. |
| `sixJSym` | def | `{j₁ j₂ j₃; j₄ j₅ j₆} = Σ_{m ∈ sixJBox} sixJTerm m`. |
| `neg_one_zpow_mul_pow_four` | lemma | Sign bookkeeping: `(-1)^S' ((-1)^p (-1)^q (-1)^r (-1)^s) = (-1)^S` under a parity condition. |
| `prod_four_eq_zero_or` | lemma | `F₁F₂F₃F₄ = 0` or `P`, if `P` holds whenever all four factors are nonzero. |
| `term_congr_1324` | lemma | Sign and reordering identity for four factors (order `1 3 2 4`), conditional on nonvanishing. |
| `term_congr_1243` | lemma | Sign and reordering identity for four factors (order `1 2 4 3`), conditional on nonvanishing. |
| `term_congr_4321` | lemma | Sign and reordering identity for four factors (order `4 3 2 1`), conditional on nonvanishing. |
| `threeJ_swap₂₃` | lemma | `(j₁ j₃ j₂; m₁ m₃ m₂) = (-1)^(j₁ + j₂ + j₃) (j₁ j₂ j₃; m₁ m₂ m₃)`. |
| `threeJ_negCycle` | lemma | `(j₂ j₃ j₁; -m₂ m₃ -m₁) = (-1)^(j₁ + j₂ + j₃) (j₁ j₂ j₃; m₁ m₂ -m₃)`. |
| `sixJSym_swap₁₂` | lemma | `{j₂ j₁ j₃; j₅ j₄ j₆} = {j₁ j₂ j₃; j₄ j₅ j₆}`. |
| `sixJSym_swap₂₃` | lemma | `{j₁ j₃ j₂; j₄ j₆ j₅} = {j₁ j₂ j₃; j₄ j₅ j₆}`. |
| `sixJSym_flip₁₂` | lemma | `{j₄ j₅ j₃; j₁ j₂ j₆} = {j₁ j₂ j₃; j₄ j₅ j₆}`. |
| `link_congr` | lemma | Sign and square-root identity matching a product of four Clebsch-Gordan factors with a `sixJTerm`, conditional on nonvanishing. |
| `tripleForm_normVec_stateB` | lemma | The product-basis component of `stateB` as `Σ_ν cgCoefficient a (b + c - 2k₃) k₄ l α ν · cgCoefficient b c k₃ ν β γ`. |
| `recoupling_eq_sum` | lemma | `recoupling` as a sum over products of four `cgCoefficient`s. |
| `cg_four_eq` | lemma | One summand of `recoupling_eq_sum` is `√((e + 1)(f + 1)) (g + 1) (-1)^(a + b + c - (k₁ + k₂)) · sixJTerm …`. |
| `sum_sixJTerm_eq` | lemma | The sum of `sixJTerm` over the product of ranges, with `mᵢ = jᵢ - 2·index`, equals `sixJSym`. |
| `sixJ_eq_sixJSym` | lemma | `sixJ hab hbc K k₁ k₃ = sixJSym a b (a + b - 2k₁) c (a + b + c - 2K) (b + c - 2k₃)` for admissible arguments. |

## Notes

- All spins and projections are in doubled units; `threeJ` and `sixJSym` take natural spins and integer projections and vanish for inadmissible arguments. A phase written `(-1)^(j₁ + j₂ + j₃)` is `(-1)^((j₁ + j₂ + j₃)/2)` in the doubled arguments of the code.
- The module docstring states that the three proved symmetries generate the 24 symmetries of the tetrahedron; this is not a Lean statement.
- `sixJ_eq_sixJSym` assumes `0 < a`, `0 < c` and the admissibility conditions `ValidA`, `ValidB` of `SixJ`.
- `neg_one_zpow_mul_pow_four`, `prod_four_eq_zero_or`, `term_congr_1324`, `term_congr_1243`, `term_congr_4321` and `link_congr` are auxiliary identities about signs in real products.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
