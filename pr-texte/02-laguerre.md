# feat(PhyslibAlpha): generalised Laguerre polynomials

Branch: `pr/laguerre` · Base: master · Depends on: nothing, applies to master

This PR defines the generalised Laguerre polynomial `L_N^(α)(x) = Σ_{i ≤ N} (-1)^i C(N + α, N - i) x^i / i!` for natural `N` and `α` and proves the Laguerre differential equation coefficientwise. Through the Chu-Vandermonde identity for `Ring.choose` it computes the moments `Σ_i c_i (q + i)!`, and with Euler's integral `∫₀^∞ x^q e^(-x) dx = q!` it evaluates `∫₀^∞ x^e e^(-x) L_N^(α)(x)² dx` for `e = α + 1, α, α - 1, α - 2`. These four integrals are the ones needed for the radial expectation values of the hydrogen atom.

## Main results

- `laguerre_ode`: `x L'' + (α + 1 - x) L' + N L = 0`.
- `sum_laguerreCoeff_mul_factorial`: `Σ_i c_i (q + i)! = q! C(N + α - q - 1, N)` with `C = Ring.choose` over `ℤ`.
- `integral_laguerre_sq_alpha`: `∫₀^∞ x^α e^(-x) L_N^(α)(x)² dx = (N + α)!/N!`.
- `integral_laguerre_sq_alpha_add_one`: `∫₀^∞ x^(α+1) e^(-x) L_N^(α)(x)² dx = (N + α)!/N! · (2N + α + 1)`.
- `integral_laguerre_sq_alpha_sub_one`, `integral_laguerre_sq_alpha_sub_two`: the weights `x^(α-1)` (for `α ≥ 1`) and `x^(α-2)` (for `α ≥ 2`).

## Reviewer map

1. `PhyslibAlpha/Mathematics/SpecialFunctions/Laguerre.lean` §A Definition and differential equation: the coefficients `laguerreCoeff`, the recursion `laguerreCoeff_succ_mul` and the index shift in `laguerre_ode`.
2. `PhyslibAlpha/Mathematics/SpecialFunctions/Laguerre.lean` §B Moments: the use of `Ring.add_choose_eq` and `Ring.choose_neg` in `sum_choose_mul_choose_neg`, and the three `Ring.choose` evaluations.
3. `PhyslibAlpha/Mathematics/SpecialFunctions/Laguerre.lean` §C Integrals: the reduction to the Gamma integral, the expansion of `L²` as a double sum, then the four closed forms, where all but one or two terms vanish by `ringChoose_natCast_of_lt`.
4. `PhyslibAlpha.lean`: the added import.

## Declarations

### `PhyslibAlpha/Mathematics/SpecialFunctions/Laguerre.lean`

| Declaration | Kind | Description |
|---|---|---|
| `PhyslibAlpha.laguerreCoeff` | def | The coefficient `(-1)^i C(N + α, N - i)/i!` of `x^i` in `L_N^(α)`. |
| `PhyslibAlpha.laguerre` | def | The polynomial `L_N^(α) = Σ_{i ≤ N} laguerreCoeff N α i · X^i` in `ℝ[X]`. |
| `PhyslibAlpha.eval_laguerre` | lemma | `L_N^(α)(x) = Σ_{i ≤ N} c_i x^i`. |
| `PhyslibAlpha.eval_laguerre_zero` | lemma | `L_N^(α)(0) = C(N + α, N)`. |
| `PhyslibAlpha.eval_derivative_laguerre` | lemma | `L'(x) = Σ_i c_i · i · x^(i-1)`. |
| `PhyslibAlpha.eval_derivative_derivative_laguerre` | lemma | `L''(x) = Σ_i c_i · i(i - 1) · x^(i-2)`. |
| `PhyslibAlpha.laguerreCoeff_succ_mul` | lemma | For `i < N`, `c_{i+1} (i + 1)(i + 1 + α) = -(N - i) c_i`. |
| `PhyslibAlpha.laguerre_ode` | lemma | Laguerre's equation `x L'' + (α + 1 - x) L' + N L = 0`. |
| `PhyslibAlpha.sum_choose_mul_choose_neg` | lemma | `Σ_i (-1)^i C(N + α, N - i) C(q + i, i) = Ring.choose (N + α - q - 1) N` in `ℤ`. |
| `PhyslibAlpha.sum_laguerreCoeff_mul_factorial` | lemma | `Σ_i c_i (q + i)! = q! · Ring.choose (N + α - q - 1) N`. |
| `PhyslibAlpha.ringChoose_natCast_of_lt` | lemma | `Ring.choose t N = 0` for natural `t < N`. |
| `PhyslibAlpha.ringChoose_neg_one` | lemma | `Ring.choose (-1) N = (-1)^N`. |
| `PhyslibAlpha.ringChoose_neg_two` | lemma | `Ring.choose (-2) N = (-1)^N (N + 1)`. |
| `PhyslibAlpha.integrableOn_pow_mul_exp_neg` | lemma | `x^q e^(-x)` is integrable on `(0, ∞)`. |
| `PhyslibAlpha.integral_pow_mul_exp_neg` | lemma | `∫₀^∞ x^q e^(-x) dx = q!`. |
| `PhyslibAlpha.integral_pow_mul_exp_neg_mul_laguerre_sq` | lemma | `∫₀^∞ x^e e^(-x) L(x)² dx = Σ_j c_j Σ_i c_i (e + j + i)!`. |
| `PhyslibAlpha.integral_pow_mul_exp_neg_mul_laguerre_sq_eq` | lemma | The same integral as `Σ_j c_j (e + j)! · Ring.choose (N + α - (e + j) - 1) N`. |
| `PhyslibAlpha.neg_one_pow_mul_self` | lemma | `(-1)^n (-1)^n = 1` in `ℝ`. |
| `PhyslibAlpha.integral_laguerre_sq_alpha` | lemma | `∫₀^∞ x^α e^(-x) L_N^(α)(x)² dx = (N + α)!/N!`. |
| `PhyslibAlpha.integral_laguerre_sq_alpha_add_one` | lemma | `∫₀^∞ x^(α+1) e^(-x) L_N^(α)(x)² dx = (N + α)!/N! · (2N + α + 1)`. |
| `PhyslibAlpha.integral_laguerre_sq_alpha_sub_one` | lemma | For `α ≥ 1`, `∫₀^∞ x^(α-1) e^(-x) L_N^(α)(x)² dx = (N + α)!/(N! α)`. |
| `PhyslibAlpha.integral_laguerre_sq_alpha_sub_two` | lemma | For `α ≥ 2`, `∫₀^∞ x^(α-2) e^(-x) L_N^(α)(x)² dx = (N + α)! (2N + α + 1)/(N! (α - 1) α (α + 1))`. |

## Notes

- `N` and `α` are natural numbers; the polynomial is defined by the explicit finite sum.
- The weighted integrals of `L_N^(α)²` are proved only for the four weights `x^(α+1)`, `x^α`, `x^(α-1)`, `x^(α-2)`.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
