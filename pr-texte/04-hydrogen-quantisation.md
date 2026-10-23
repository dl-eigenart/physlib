# feat(PhyslibAlpha): quantisation of the hydrogen levels

Branch: `pr/hydrogen-quantisation` · Base: master

Builds on #1909 (radial functions of the hydrogen atom) and #1900 (generalised Laguerre polynomials), both merged.

This PR proves that the bound-state energies of hydrogen are discrete within the power series ansatz. If `u(ρ) = ρ^(l+1) e^(-κρ) Σ_k c_k ρ^k`, with an everywhere convergent series, `c_0 ≠ 0` and `κ > 0`, solves the radial equation `u'' = (l(l+1)/ρ² - 2/ρ + κ²) u` on `(0, ∞)` and is square integrable, then `κ = 1/ν` for a natural number `ν > l` and `u` is a multiple of `u_{νl}`. It builds on `radialU` and `eval_radialPoly` of `RadialFunctions.lean` and on `laguerreCoeff` of `Laguerre.lean`.

## Main results

- `hasDerivAt_psum`: an everywhere convergent power series is differentiable with the termwise derivative.
- `coeff_eq_zero_of_psum`: an everywhere convergent power series that vanishes on `(0, ∞)` has all coefficients zero.
- `recursion_of_radial_ode`: a solution of the radial equation of the ansatz form satisfies `(k + 1)(k + 2l + 2) c_{k+1} = (2κ(k + l + 1) - 2) c_k`.
- `radialSeries_eq_of_terminating`: if `κ(N + l + 1) = 1`, the ansatz equals `c_0 / laguerreCoeff N (2l+1) 0 · u_{N+l+1, l}`.
- `not_integrableOn_of_nonterminating`: if `κ(N + l + 1) ≠ 1` for all `N`, then `u²` is not integrable on `(0, ∞)`.
- `radial_quantization`: the combination of the above.

## Reviewer map

1. `RadialQuantization.lean` §A Power series with infinite radius of convergence: the predicate `EntireCoeff`, `psum`, `dcoeff` and their closure lemmas; the two analytic facts are `hasDerivAt_psum` (via `hasDerivAt_tsum_of_isPreconnected`) and `coeff_eq_zero_of_psum` (induction on `n`, continuity at `0` from the right).
2. `RadialQuantization.lean` §B The radial equation for a power series ansatz: `radialSeries`, its derivatives, the algebraic `radial_identity`, and `recursion_of_radial_ode`, which applies `coeff_eq_zero_of_psum` to the series of `ρ W'' + (2l + 2 - 2κρ) W' + (2 - 2κ(l + 1)) W`.
3. `RadialQuantization.lean` §C Terminating series: the Laguerre polynomials: `RadialRec`, `coeff_of_terminating` (comparison with `laguerreCoeff_succ_mul`) and `radialSeries_eq_of_terminating`.
4. `RadialQuantization.lean` §D Non-terminating series are not normalisable: `not_integrableOn_of_nonterminating` is the long proof of the PR; its commented steps are `c_{k+1}/c_k ≥ (3κ/2)/(k + 1)` for `k ≥ K`, the bound `W(ρ) ≥ δ e^(3κρ/2) - Q(ρ)` with a polynomial `Q`, and `u(ρ)² ≥ 1` for large `ρ`.
5. `RadialQuantization.lean` §E Quantisation: `radial_quantization`, a case split on termination.
6. `PhyslibAlpha.lean`: one added import.

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/RadialQuantization.lean`

All declarations are in the namespace `PhyslibAlpha.Hydrogen`.

| Declaration | Kind | Description |
|---|---|---|
| `EntireCoeff` | def | The predicate that `Σ_k \|c_k\| r^k` is summable for every `r ≥ 0`. |
| `psum` | def | The power series `Σ' c_k x^k`. |
| `dcoeff` | def | The coefficients `(k + 1) c_{k+1}` of the derivative. |
| `succ_mul_pow_le_pow_succ` | lemma | `(k + 1) r^k ≤ (1 + r)^(k+1)` for `r ≥ 0`. |
| `EntireCoeff.summable` | lemma | `Σ c_k x^k` is summable for every real `x`. |
| `EntireCoeff.derivCoeff` | lemma | `EntireCoeff c` implies `EntireCoeff (dcoeff c)`. |
| `EntireCoeff.shift` | lemma | `EntireCoeff c` implies `EntireCoeff (fun k => c (k + 1))`. |
| `psum_eq_add` | lemma | `psum c x = c 0 + x · psum (fun k => c (k + 1)) x`. |
| `psum_zero` | lemma | `psum c 0 = c 0`. |
| `hasDerivAt_psum` | lemma | The derivative of `psum c` at `x` is `psum (dcoeff c) x`. |
| `coeff_eq_zero_of_psum` | lemma | If `psum c x = 0` for all `x > 0`, then `c n = 0`. |
| `EntireCoeff.unshift` | lemma | `EntireCoeff (fun k => c (k + 1))` implies `EntireCoeff c`. |
| `EntireCoeff.add` | lemma | `EntireCoeff` is closed under sums. |
| `EntireCoeff.const_mul` | lemma | `EntireCoeff` is closed under multiplication by a constant. |
| `psum_add` | lemma | `psum` is additive in the coefficients. |
| `psum_const_mul` | lemma | `psum (a · c) x = a · psum c x`. |
| `dcoeff_eq` | lemma | `dcoeff c` agrees with `fun k => ((k + 1 : ℕ) : ℝ) * c (k + 1)`. |
| `EntireCoeff.natMul` | lemma | `EntireCoeff c` implies `EntireCoeff (fun k => k · c k)`. |
| `mul_psum_dcoeff` | lemma | `x Σ_k (k + 1) c_{k+1} x^k = Σ_k k c_k x^k`. |
| `radialSeries` | def | The ansatz `u(ρ) = ρ^(l+1) e^(-κρ) psum c ρ` for a bound state of energy `-κ²`. |
| `hasDerivAt_exp_neg_mul` | lemma | The derivative of `e^(-κρ)` is `-κ e^(-κρ)`. |
| `radialSeriesD` | def | The explicit first derivative of `radialSeries`. |
| `hasDerivAt_radialSeries` | lemma | `radialSeriesD` is the derivative of `radialSeries`. |
| `hasDerivAt_radialSeriesD` | lemma | Explicit derivative of `radialSeriesD` in terms of `psum c`, `psum (dcoeff c)`, `psum (dcoeff (dcoeff c))`. |
| `radial_identity` | lemma | For `ρ ≠ 0`, the radial operator applied to `ρ^(l+1) E W` equals `ρ^l E (ρ W'' + (2l + 2 - 2κρ) W' + (2 - 2κ(l + 1)) W)`. |
| `recursion_of_radial_ode` | lemma | If the ansatz solves the radial equation on `(0, ∞)`, then `(k + 1)(k + 2l + 2) c_{k+1} = (2κ(k + l + 1) - 2) c_k`. |
| `RadialRec` | abbrev | The coefficient recursion above as a predicate on `c`. |
| `coeff_of_terminating` | lemma | If `κ(N + l + 1) = 1`, then `c_k = c_0 / laguerreCoeff N (2l+1) 0 · laguerreCoeff N (2l+1) k · (2κ)^k` for `k ≤ N` and `c_k = 0` for `k > N`. |
| `radialSeries_eq_of_terminating` | lemma | In the terminating case `radialSeries κ l c = c_0 / laguerreCoeff N (2l+1) 0 · radialU (N + l + 1) l`. |
| `tendsto_pow_mul_exp_neg_mul` | lemma | `ρ^k e^(-κρ) → 0` as `ρ → ∞` for `κ > 0`. |
| `coeff_ne_zero` | lemma | Under the recursion, without termination and with `c_0 ≠ 0`, every `c_k` is non-zero. |
| `not_integrableOn_of_nonterminating` | lemma | Without termination, `c_0 ≠ 0` and `κ > 0`, `radialSeries κ l c ^ 2` is not integrable on `(0, ∞)`. |
| `radial_quantization` | lemma | A square integrable solution of the ansatz form has `κ = 1/ν` for some `ν > l` and is `C · u_{νl}`. |

## Notes

- The module docstring states what is assumed: the power series ansatz, i.e. that the solution regular at the origin is `ρ^(l+1) e^(-κρ)` times an entire function. That every solution regular at the origin has this form, and that the second, singular solution is excluded by the boundary condition at `ρ = 0`, is not formalised.
- The statement is in Rydberg units (energy `-κ²`); the connection to physical units is `radialFun_schrodinger` in `RadialFunctions.lean`.
- `not_integrableOn_of_nonterminating` is a single long proof (about 150 lines) with comments marking its four steps; it has not been split into lemmas.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
