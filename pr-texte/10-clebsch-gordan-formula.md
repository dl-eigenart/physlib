# feat(PhyslibAlpha): closed formulas for Clebsch-Gordan coefficients

Branch: `pr/clebsch-gordan-formula` · Base: master

Builds on #1911 (normalised basis and Clebsch-Gordan coefficients) and #1876 (the Wigner-Eckart theorem for sl2), both merged.

This PR builds on the coupled basis `|J, M⟩` and the coefficients `cgCoefficient` of
#1911. It proves completeness of the coupled basis and the second orthogonality
relation, the closed form of the squared norm `⟨w_k, w_k⟩` of the highest-weight vectors, a
closed formula for `⟨j₁ m₁ j₂ m₂ | J M⟩` with a single alternating sum, and Racah's formula. The
passage from the first sum to Racah's sum goes through two binomial sums `L` and `R` with integer
lower indices that satisfy the same recursion in `k`.

## Main results

- `sum_cgCoefficient_mul_cgCoefficient`: `Σ_{J M} ⟨j₁ m₁ j₂ m₂ | J M⟩ ⟨j₁ m₁' j₂ m₂' | J M⟩ = δ_{m₁ m₁'} δ_{m₂ m₂'}`.
- `hwNormSq_closed`: `⟨w_k, w_k⟩ = k! m! n! (m + n - k + 1)! (n - k)! (m - k)! / (m + n - 2k + 1)!`.
- `tensorF_pow_tmul_vNat`: `f^l (v_a ⊗ v_b) = Σ_i C(l, i) v_{a+i} ⊗ v_{b+l-i}`.
- `cgCoefficient_closed`: for `α + β = k + l`, the coefficient equals `cgSum m n k l α` times an explicit square root of factorials.
- `racahL_eq_racahR`: `L(k, α, s) = R(k, α, s)` for all `k` and integers `α, s`.
- `cgCoefficient_racah`: Racah's formula for `⟨j₁ m₁ j₂ m₂ | J M⟩` with `racahSum`.

## Reviewer map

1. `ClebschGordanFormula.lean` §A Completeness and the second orthogonality relation: the use of `tensorStringBasis` in `eq_sum_coupledVec`; its proof is the longest in §A.
2. `ClebschGordanFormula.lean` §B.1 A factorial identity: the induction in `factorialSum_mul`; `factorialSum` and `sum_choose_mul_factorial` have no angular momentum content and may belong in a Mathematics file.
3. `ClebschGordanFormula.lean` §B.2 The closed norm: `hwNormNum` and the reduction of `hwNormSq_eq` to §B.1.
4. `ClebschGordanFormula.lean` §C The lowering strings in the product basis: the binomial theorem for the commuting summands of `tensorF`.
5. `ClebschGordanFormula.lean` §D The closed formula: the hypotheses of `cgCoefficient_closed` and the definition of `cgSum`.
6. `ClebschGordanFormula.lean` §E.1 Binomial coefficients with an integer lower index: `zchoose`, `zchoose_succ`, `sum_range_choose_succ_mul` are general combinatorics; check placement.
7. `ClebschGordanFormula.lean` §E.2 Two binomial sums with the same recursion: `racahL_succ`, `racahR_succ` and the induction in `racahL_eq_racahR`.
8. `ClebschGordanFormula.lean` §E.3 Racah's formula: the range condition in `racahSum`, the factorial bookkeeping in `cgSum_eq_racahL`, `racahR_eq_racahSum`, and the final statement `cgCoefficient_racah` against the textbook form in its docstring.

## Declarations

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/ClebschGordanFormula.lean`

| Declaration | Kind | Description |
|---|---|---|
| `tensorForm_coupledVec_stringVec` | lemma | `⟨\|J, M⟩, f^{l'} w_{k'}⟩ = δ_{kk'} δ_{ll'} √(normSq (m + n - 2k) l · ⟨w_k, w_k⟩)`. |
| `eq_sum_coupledVec` | lemma | Completeness: `x = Σ_{k l} ⟨\|J, M⟩, x⟩ \|J, M⟩` in `V(m) ⊗ V(n)`, for `0 < m + n`. |
| `sum_cgCoefficient_mul_cgCoefficient` | lemma | Second orthogonality relation `Σ_{k l} ⟨a b \| k l⟩ ⟨a' b' \| k l⟩ = δ_{aa'} δ_{bb'}`. |
| `factorialSum` | def | `S(k, p, s) = Σ_{i + j = k} C(k, i) (p + i)! (s + j)!`. |
| `factorialSum_succ` | lemma | `S(k + 1, p, s) = S(k, p, s + 1) + S(k, p + 1, s)`. |
| `factorialSum_mul` | lemma | `S(k, p, s) (p + s + 1)! = (p + k + s + 1)! p! s!`. |
| `sum_choose_mul_factorial` | lemma | The same identity with the sum over `a ∈ range (k + 1)`. |
| `hwNormNum` | def | `k! m! n! (m + n - k + 1)! (n - k)! (m - k)!`. |
| `cgCoeff_sq_mul_normSq` | lemma | `cgCoeff(a)² normSq m a normSq n (k - a) = C(k, a) (n - k + a)! (m - a)! k! m! n!`. |
| `hwNormSq_mul_factorial` | lemma | `⟨w_k, w_k⟩ (m + n - 2k + 1)! = hwNormNum m n k`. |
| `hwNormSq_closed` | lemma | `⟨w_k, w_k⟩ = hwNormNum m n k / (m + n - 2k + 1)!`. |
| `ρF_pow_vNat` | lemma | `f^l v_a = v_{a+l}`. |
| `tensorF_pow_tmul_vNat` | lemma | `f^l (v_a ⊗ v_b) = Σ_i C(l, i) v_{a+i} ⊗ v_{b+l-i}`. |
| `cgSum` | def | `Σ_{a ≤ min(k, α)} cgCoeff(a) C(l, α - a)`, i.e. `Σ (-1)^a C(k, a) (n - k + a)! (m - a)! C(l, α - a)`. |
| `sum_choose_mul_ite` | lemma | `Σ_i C(l, i) [α = a + i] X = [a ≤ α] C(l, α - a) X`. |
| `tensorForm_normVec_tmul_vNat` | lemma | `⟨u_α ⊗ u_β, v_{a+i} ⊗ v_{k-a+l-i}⟩ = [α = a + i] √(normSq m α) √(normSq n β)`. |
| `tensorForm_normVec_stringVec` | lemma | `⟨u_α ⊗ u_β, f^l w_k⟩ = cgSum · √(normSq m α) √(normSq n β)` for `α + β = k + l`. |
| `cgCoefficient_eq_cgSum` | lemma | The coefficient as `cgSum` times square roots, with `⟨w_k, w_k⟩` unevaluated. |
| `cgCoefficient_closed` | lemma | `⟨… \| J M⟩ = cgSum · √(normSq m α normSq n β (N + 1)! / (normSq N l · hwNormNum))`, `N = m + n - 2k`. |
| `zchoose` | def | `C(n, j)` for `j ≥ 0` and `0` for `j < 0`, `j : ℤ`. |
| `zchoose_natCast` | lemma | `zchoose n t = C(n, t)` for `t : ℕ`. |
| `zchoose_of_neg` | lemma | `zchoose n j = 0` for `j < 0`. |
| `zchoose_succ` | lemma | `zchoose (n + 1) j = zchoose n j + zchoose n (j - 1)`. |
| `sum_range_choose_succ_mul` | lemma | `Σ_a C(k + 1, a) f(a) = Σ_a C(k, a) f(a) + Σ_a C(k, a) f(a + 1)`. |
| `racahL` | def | `L(k, α, s) = Σ_a (-1)^a C(k, a) C(r + k - a, α - a) C(p + a, s + a)`. |
| `racahR` | def | `R(k, α, s) = Σ_z (-1)^z C(k, z) C(r, α - z) C(p, s + z)`. |
| `racahL_succ` | lemma | `L(k + 1, α, s) = L(k, α, s) - L(k, α - 1, s + 1)`. |
| `racahR_succ` | lemma | `R(k + 1, α, s) = R(k, α, s) - R(k, α - 1, s + 1)`. |
| `racahL_eq_racahR` | lemma | `L = R`. |
| `racahSum` | def | Racah's sum `Σ_z (-1)^z / (z! (k - z)! (α - z)! (n - β - z)! (m - k - α + z)! (β - k + z)!)` over admissible `z`. |
| `cgSum_eq_racahL` | lemma | `cgSum = l! (m - α)! (n - β)! · L(k, α, l - α)` with `r = m - k`, `p = n - k`. |
| `racahR_eq_racahSum` | lemma | `R(k, α, l - α) = k! (m - k)! (n - k)! · racahSum`. |
| `cgSum_eq_racahSum` | lemma | `cgSum = l! (m - α)! (n - β)! k! (m - k)! (n - k)! · racahSum`. |
| `cgCoefficient_racah` | lemma | Racah's formula: `⟨… \| J M⟩ = √((N + 1)(m - k)! (n - k)! k! / (m + n - k + 1)!) · √((N - l)! l! α! (m - α)! β! (n - β)!) · racahSum`. |

## Notes

- All names are in the namespace `PhyslibAlpha.Sl2`.
- `cgCoefficient_closed` and `cgCoefficient_racah` assume `α + β = k + l`; for `α + β ≠ k + l` the coefficient vanishes by `cgCoefficient_eq_zero_of_ne` from #1911.
- The statements use the natural-number indices `m, n, k, l, α, β`; the spin notation `j₁, m₁, j₂, m₂, J, M` appears only in the docstrings.
- `racahSum` sums only over the `z` for which all six factorial arguments are nonnegative.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
