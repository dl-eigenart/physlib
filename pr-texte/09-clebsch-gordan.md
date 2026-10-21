# feat(PhyslibAlpha): normalised basis and Clebsch-Gordan coefficients

Branch: `pr/clebsch-gordan` · Base: master after merge of #1876 · Depends on: #1876 (independent of `pr/projection-selection`)

The basis `v_a = f^a v_0` of the standard module `V(n)` used in #1876 is not normalised. This PR
defines the contravariant form on `V(n)`, for which `e` and `f` are adjoint and `h` is symmetric,
and the orthonormal basis `u_a = |j, m⟩` over `ℝ` with the textbook matrix elements of `J₊`, `J₋`,
`Jz`. On `V(m) ⊗ V(n)` the product form gives the orthonormal coupled basis `|J, M⟩`, and the
Clebsch-Gordan coefficient `⟨j₁ m₁ j₂ m₂ | J M⟩` is defined as an inner product, with the weight
rule, the Condon-Shortley phase, the orthogonality relation and the spin-`½ ⊗ ½` values.

## Main results

- `invForm_comp_ρE`: `⟨e x, y⟩ = ⟨x, f y⟩` for the contravariant form on `V(n)`.
- `invForm_normVec`, `ρF_normVec`, `ρE_normVec_succ`: `u_a` is orthonormal and `f u_a = √((a+1)(n-a)) u_{a+1}`, `e u_{a+1} = √((a+1)(n-a)) u_a`.
- `tensorForm_coupledVec`: the coupled states `|J, M⟩` are orthonormal.
- `cgCoefficient_eq_zero_of_ne`: `⟨j₁ m₁ j₂ m₂ | J M⟩ = 0` unless `m₁ + m₂ = M`.
- `cgCoefficient_top_pos`: Condon-Shortley phase convention `⟨j₁ j₁ j₂ (J - j₁) | J J⟩ > 0`.
- `sum_cgCoefficient_mul`: `Σ_{m₁ m₂} ⟨j₁ m₁ j₂ m₂ | J M⟩ ⟨j₁ m₁ j₂ m₂ | J' M'⟩ = δ_{JJ'} δ_{MM'}`.

## Reviewer map

1. `NormalizedBasis.lean` §A.1 Squared norms and §A.2 Definition and values: `normSq n a = a! · n!/(n - a)!` and the diagonal form `invForm`.
2. `NormalizedBasis.lean` §A.3 Contravariance: the case analysis at the top weight in `invForm_comp_ρE`.
3. `NormalizedBasis.lean` §B The normalised basis over ℝ: the square roots in `ρF_normVec`, `ρE_normVec_succ` against the Condon-Shortley formulas.
4. `ClebschGordanCoefficients.lean` §A The form on the tensor product: `tensorForm` as `LinearMap.BilinForm.tmul` and the adjointness of `tensorE`, `tensorF`.
5. `ClebschGordanCoefficients.lean` §B Inner products of the lowering strings: the induction in `tensorForm_stringVec` and the positivity `hwNormSq_pos`.
6. `ClebschGordanCoefficients.lean` §C The orthonormal coupled basis: the normalisation in `coupledVec` and the ladder relations.
7. `ClebschGordanCoefficients.lean` §D.1 Definition, weight rule and phase: the index convention `j₁ = m/2`, `m₁ = j₁ - a`, `J = (m + n)/2 - k`, `M = J - l` in `cgCoefficient`.
8. `ClebschGordanCoefficients.lean` §D.2 Expansion and orthogonality and §D.3 Values: `eq_sum_normVec` and `eq_sum_normVec_tmul` are general expansion lemmas; the spin-`½` values against a table.

## Declarations

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/NormalizedBasis.lean`

| Declaration | Kind | Description |
|---|---|---|
| `normSq` | def | `normSq n a = a! · n.descFactorial a`, the squared norm of `v_a`. |
| `normSq_succ` | lemma | `normSq n (a + 1) = normSq n a · (a + 1)(n - a)`. |
| `normSq_pos` | lemma | `0 < normSq n a` for `a ≤ n`. |
| `invForm` | def | The bilinear form on `V(n)` with diagonal matrix `normSq n a` in the basis `v_a`. |
| `invForm_v` | lemma | `⟨v_i, v_j⟩ = δ_ij normSq n i` for `i, j : Fin (n + 1)`. |
| `invForm_vNat` | lemma | `⟨v_a, v_b⟩ = normSq n a` if `a = b ≤ n`, else `0`. |
| `bilin_ext_vNat` | lemma | Two bilinear forms on `V(n)` agreeing on all pairs `v_a, v_b` are equal. |
| `invForm_comp_ρE` | lemma | `⟨e x, y⟩ = ⟨x, f y⟩`. |
| `invForm_comp_ρH` | lemma | `⟨h x, y⟩ = ⟨x, h y⟩`. |
| `invForm_comm` | lemma | `invForm` is symmetric. |
| `normVec` | def | `u_a = v_a / √(normSq n a)` in `V(n)` over `ℝ`. |
| `sqrt_normSq_succ` | lemma | `√(normSq n (a + 1)) = √(normSq n a) · √((a + 1)(n - a))`. |
| `invForm_normVec` | lemma | `⟨u_a, u_b⟩ = δ_ab` for `a, b ≤ n`. |
| `ρH_normVec` | lemma | `h u_a = (n - 2a) u_a`. |
| `ρF_normVec` | lemma | `f u_a = √((a + 1)(n - a)) u_{a+1}` for `a < n`. |
| `ρE_normVec_succ` | lemma | `e u_{a+1} = √((a + 1)(n - a)) u_a` for `a < n`. |

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/ClebschGordanCoefficients.lean`

| Declaration | Kind | Description |
|---|---|---|
| `tensorForm` | def | The form `⟨x ⊗ y, x' ⊗ y'⟩ = ⟨x, x'⟩ ⟨y, y'⟩` on `V(m) ⊗ V(n)` over `ℝ`. |
| `tensorForm_tmul` | lemma | The defining formula of `tensorForm` on pure tensors. |
| `tensorBilin_ext` | lemma | Two bilinear forms on `V(m) ⊗ V(n)` agreeing on pure tensors are equal. |
| `invForm_ρE_apply` | lemma | Pointwise form of `invForm_comp_ρE`. |
| `invForm_ρH_apply` | lemma | Pointwise form of `invForm_comp_ρH`. |
| `tensorForm_comm` | lemma | `tensorForm` is symmetric. |
| `tensorForm_tensorE` | lemma | `⟨E x, y⟩ = ⟨x, F y⟩` for the diagonal operators on `V(m) ⊗ V(n)`. |
| `tensorForm_tensorF` | lemma | `⟨F x, y⟩ = ⟨x, E y⟩`. |
| `tensorForm_tensorH` | lemma | `⟨H x, y⟩ = ⟨x, H y⟩`. |
| `tensorForm_hwVec_of_ne` | lemma | `⟨w_k, w_{k'}⟩ = 0` for `k ≠ k'`. |
| `stringVec_zero'` | lemma | `stringVec m n k 0 = hwVec m n k` over `ℝ`. |
| `tensorForm_stringVec` | lemma | `⟨f^a w_k, f^b w_{k'}⟩ = δ_{kk'} δ_{ab} normSq (m + n - 2k) a · ⟨w_k, w_k⟩`. |
| `hwNormSq` | def | `⟨w_k, w_k⟩`. |
| `hwNormSq_eq` | lemma | `⟨w_k, w_k⟩ = Σ_a cgCoeff(a)² normSq m a normSq n (k - a)` for `k ≤ m, n`. |
| `cgCoeff_zero` | lemma | `cgCoeff m n k 0 = (n - k)! m!`. |
| `hwNormSq_pos` | lemma | `0 < ⟨w_k, w_k⟩` for `k ≤ m, n`. |
| `coupledVec` | def | `\|J, M⟩ = f^l w_k / √(normSq (m + n - 2k) l · ⟨w_k, w_k⟩)`. |
| `tensorForm_coupledVec` | lemma | `⟨\|J, M⟩, \|J', M'⟩⟩ = δ_{kk'} δ_{ll'}`. |
| `sqrt_coupled_succ` | lemma | The normalising square root of `coupledVec` at `l + 1` in terms of the one at `l`. |
| `tensorF_coupledVec` | lemma | `J₋ \|J, M⟩ = √((J + M)(J - M + 1)) \|J, M - 1⟩`. |
| `tensorE_coupledVec_succ` | lemma | `J₊ \|J, M⟩ = √((J - M)(J + M + 1)) \|J, M + 1⟩`. |
| `cgCoefficient` | def | `⟨j₁ m₁ j₂ m₂ \| J M⟩ = ⟨u_a ⊗ u_b, \|J, M⟩⟩`. |
| `tensorH_normVec_tmul` | lemma | `H (u_a ⊗ u_b) = ((m - 2a) + (n - 2b)) (u_a ⊗ u_b)`. |
| `tensorH_coupledVec` | lemma | `H \|J, M⟩ = (m + n - 2k - 2l) \|J, M⟩`. |
| `cgCoefficient_eq_zero_of_ne` | lemma | Weight rule: the coefficient vanishes unless `a + b = k + l`. |
| `invForm_normVec_vNat` | lemma | `⟨u_a, v_c⟩ = δ_ac √(normSq n a)` for `a ≤ n`. |
| `tensorForm_normVec_hwVec` | lemma | `⟨u_a ⊗ u_{k-a}, w_k⟩ = cgCoeff(a) √(normSq m a) √(normSq n (k - a))`. |
| `cgCoefficient_top` | lemma | The coefficients of `\|J, J⟩` in closed form with `√⟨w_k, w_k⟩` in the denominator. |
| `cgCoefficient_top_pos` | lemma | Condon-Shortley phase: `0 < ⟨j₁ j₁ j₂ (J - j₁) \| J J⟩`. |
| `eq_sum_normVec` | lemma | `x = Σ_a ⟨u_a, x⟩ u_a` in `V(n)`. |
| `eq_sum_normVec_tmul` | lemma | `x = Σ_{a b} ⟨u_a ⊗ u_b, x⟩ u_a ⊗ u_b` in `V(m) ⊗ V(n)`. |
| `coupledVec_eq_sum` | lemma | `\|J, M⟩ = Σ_{a b} ⟨j₁ m₁ j₂ m₂ \| J M⟩ u_a ⊗ u_b`. |
| `sum_cgCoefficient_mul` | lemma | Orthogonality relation `Σ_{a b} ⟨… \| J M⟩ ⟨… \| J' M'⟩ = δ_{JJ'} δ_{MM'}`. |
| `hwNormSq_zero` | lemma | `⟨w_0, w_0⟩ = (n! m!)²`. |
| `cgCoefficient_stretched` | lemma | `⟨j₁ j₁ j₂ j₂ \| j₁+j₂, j₁+j₂⟩ = 1`. |
| `hwNormSq_one_one` | lemma | `⟨w_1, w_1⟩ = 2` for `m = n = 1`. |
| `cgCoefficient_singlet_up` | lemma | `⟨½ ½ ½ -½ \| 0 0⟩ = 1/√2`. |
| `cgCoefficient_singlet_down` | lemma | `⟨½ -½ ½ ½ \| 0 0⟩ = -1/√2`. |
| `coupledVec_one_one_zero_one` | lemma | `\|1, 0⟩ = (1/√2) J₋ \|1, 1⟩` in `V(1) ⊗ V(1)`. |
| `ρE_normVec_one_zero` | lemma | `e u_0 = 0` in `V(1)`. |
| `ρE_normVec_one_one` | lemma | `e u_1 = u_0` in `V(1)`. |
| `cgCoefficient_triplet_zero_up` | lemma | `⟨½ ½ ½ -½ \| 1 0⟩ = 1/√2`. |
| `cgCoefficient_triplet_zero_down` | lemma | `⟨½ -½ ½ ½ \| 1 0⟩ = 1/√2`. |

## Notes

- All names are in the namespace `PhyslibAlpha.Sl2`.
- `invForm` is defined over any field; the normalised basis, the coupled basis and the coefficients are defined over `ℝ` only.
- The coefficients are indexed by natural numbers `k, l, a, b`; the translation to `j₁, m₁, j₂, m₂, J, M` is given in the docstrings.
- The module docstrings state that the form on `V(n)` is unique up to a scalar and that the listed properties determine the Clebsch-Gordan coefficients uniquely, so they agree with the tabulated values. Neither uniqueness statement is proved in the files.
- A closed formula (Racah's formula) is not proved here; it is the subject of the follow-up `pr/clebsch-gordan-formula`.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
