# feat(PhyslibAlpha): radial functions of the hydrogen atom

Branch: `pr/hydrogen-radial` · Base: master, after the Laguerre PR is merged · Depends on: #1900 (generalised Laguerre polynomials)

This PR defines the bound-state radial functions `u_{νl}(ρ) = ρ^(l+1) e^(-ρ/ν) L_{ν-l-1}^(2l+1)(2ρ/ν)` of the three-dimensional hydrogen atom in units of the Bohr radius, proves that they solve the radial Schrödinger equation, and computes the expectation values `⟨1/ρ⟩`, `⟨1/ρ²⟩`, `⟨1/ρ³⟩` and the density `|R_{ν0}(0)|²` at the origin. In physical units the eigenvalue is physlib's Bohr level `HydrogenAtom.energyLevel (ν - 1)` for `d = 3`. It builds on the generalised Laguerre polynomials of `PhyslibAlpha/Mathematics/SpecialFunctions/Laguerre.lean`: the radial equation follows from the Laguerre equation, and the moments reduce to the Laguerre integrals proved there.

## Main results

- `radialU_ode`: for `l < ν` and `ρ ≠ 0`, `u_{νl}'' = (l(l+1)/ρ² - 2/ρ + 1/ν²) u_{νl}`.
- `radialFun_schrodinger`: for `d = 3` and `k > 0`, `u_{νl}(r/a)` solves `-ℏ²/(2m) u'' + (ℏ² l(l+1)/(2m r²) - k/r) u = E u` with `E = H.energyLevel (ν - 1)`.
- `radialMoment_zero`: `‖u_{νl}‖² = (ν/2)^(2l+3) (ν+l)!/(ν-l-1)! · 2ν`.
- `radialMean_one`, `radialMean_two`, `radialMean_three`: `⟨1/ρ⟩ = 1/ν²`, `⟨1/ρ²⟩ = 1/(ν³ (l + 1/2))`, and `⟨1/ρ³⟩ = 1/(ν³ l (l + 1/2)(l + 1))` for `l ≥ 1`.
- `radialR_zero_sq_div`: `|R_{ν0}(0)|²/‖u_{ν0}‖² = 4/ν³`.

## Reviewer map

1. `RadialFunctions.lean` §A Polynomial times exponential: two derivative lemmas for `Q(ρ) e^(-βρ)`, reused in the bound-states PR.
2. `RadialFunctions.lean` §B The radial functions and the radial equation: the definitions `radialPoly`, `radialU`; the reduction of the radial equation to `radialPoly_identity`, which is a `linear_combination` of `laguerre_ode` with a split on `l = 0`.
3. `RadialFunctions.lean` §C Radial moments and expectation values: the substitution `x = 2ρ/ν` in `integral_pow_mul_exp_mul_laguerre_sq_comp` and `radialMoment_eq`; then the four moments, each a rewrite into one Laguerre integral.
4. `RadialFunctions.lean` §D The value at the origin: `radialR` and the `s`-state density.
5. `RadialFunctions.lean` §E Physical units: `bohrRadius` and the rescaling to `radialFun_schrodinger`; check that the energy matches `HydrogenAtom.energyLevel_eq` for `d = 3`.
6. `PhyslibAlpha.lean`: one added import.

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/RadialFunctions.lean`

All declarations are in the namespace `PhyslibAlpha.Hydrogen`.

| Declaration | Kind | Description |
|---|---|---|
| `hasDerivAt_eval_mul_exp` | lemma | The derivative of `Q(ρ) e^(-βρ)` is `(Q' - βQ)(ρ) e^(-βρ)` for a real polynomial `Q`. |
| `deriv_eval_mul_exp` | lemma | The same statement for `deriv`, as an equality of functions. |
| `radialPoly` | def | The polynomial `ρ^(l+1) L_{ν-l-1}^(2l+1)(2ρ/ν)`. |
| `radialU` | def | The reduced radial function `u_{νl}(ρ) = radialPoly(ρ) e^(-ρ/ν)`, unnormalised, in units of the Bohr radius. |
| `eval_radialPoly` | lemma | Evaluation of `radialPoly` as `ρ^(l+1) L_{ν-l-1}^(2l+1)(2ρ/ν)`. |
| `eval_derivative_radialPoly` | lemma | Explicit form of the first derivative of `radialPoly` in terms of `L` and `L'`. |
| `eval_derivative_derivative_radialPoly` | lemma | Explicit form of the second derivative of `radialPoly` in terms of `L`, `L'` and `L''`. |
| `radialPoly_identity` | lemma | For `l < ν`, `ρ² (Q'' - 2Q'/ν + Q/ν²) = (l(l+1) - 2ρ + ρ²/ν²) Q` with `Q = radialPoly ν l`. |
| `deriv_deriv_radialU` | lemma | `u_{νl}'' = (Q'' - 2Q'/ν + Q/ν²) e^(-ρ/ν)`. |
| `radialU_ode` | lemma | The radial equation `u_{νl}'' = (l(l+1)/ρ² - 2/ρ + 1/ν²) u_{νl}` for `l < ν`, `ρ ≠ 0`. |
| `integral_pow_mul_exp_mul_laguerre_sq_comp` | lemma | Change of variables `x = bρ` in `∫₀^∞ ρ^e e^(-bρ) L_N^(α)(bρ)² dρ` for `b > 0`. |
| `radialU_sq_div_pow` | lemma | For `k ≤ 2l + 2` and `ρ > 0`, `u_{νl}²/ρ^k = ρ^(2l+2-k) e^(-2ρ/ν) L_{ν-l-1}^(2l+1)(2ρ/ν)²`. |
| `radialMoment` | def | The radial moment `∫₀^∞ u_{νl}(ρ)² ρ^(-k) dρ`; for `k = 0` the squared norm. |
| `radialMean` | def | The expectation value `⟨ρ^(-k)⟩ = radialMoment ν l k / radialMoment ν l 0`. |
| `radialMoment_eq` | lemma | For `l < ν`, `k ≤ 2l + 2`, the moment as `(ν/2)^(2l+3-k)` times the Laguerre integral `∫ x^(2l+2-k) e^(-x) L² dx`. |
| `radialMoment_zero` | lemma | `‖u_{νl}‖² = (ν/2)^(2l+3) (ν+l)!/(ν-l-1)! · 2ν`. |
| `radialMoment_one` | lemma | `radialMoment ν l 1 = (ν/2)^(2l+2) (ν+l)!/(ν-l-1)!`. |
| `radialMoment_two` | lemma | `radialMoment ν l 2 = (ν/2)^(2l+1) (ν+l)!/((ν-l-1)! (2l+1))`. |
| `radialMoment_three` | lemma | For `l ≥ 1`, `radialMoment ν l 3 = (ν/2)^(2l) (ν+l)! 2ν/((ν-l-1)! 2l(2l+1)(2l+2))`. |
| `radialMean_one` | lemma | `⟨1/ρ⟩ = 1/ν²`, the virial theorem for hydrogen. |
| `radialMean_two` | lemma | `⟨1/ρ²⟩ = 1/(ν³ (l + 1/2))`. |
| `radialMean_three` | lemma | `⟨1/ρ³⟩ = 1/(ν³ l (l + 1/2)(l + 1))` for `l ≥ 1`. |
| `radialR` | def | The radial wave function `R_{νl}(ρ) = ρ^l e^(-ρ/ν) L_{ν-l-1}^(2l+1)(2ρ/ν)`. |
| `radialU_eq_mul_radialR` | lemma | `u_{νl}(ρ) = ρ R_{νl}(ρ)`. |
| `radialR_zero_sq_div` | lemma | For `ν > 0`, `R_{ν0}(0)²/‖u_{ν0}‖² = 4/ν³`. |
| `bohrRadius` | def | The Bohr radius `a = ℏ²/(m k)` of a `HydrogenAtom`. |
| `bohrRadius_pos` | lemma | `a > 0` when `k > 0`. |
| `radialFun` | def | The reduced radial function in physical units, `r ↦ u_{νl}(r/a)`. |
| `radialFun_schrodinger` | lemma | For `d = 3`, `k > 0`, `l < ν`, `r ≠ 0`, the radial Schrödinger equation with energy `H.energyLevel (ν - 1)`. |

## Notes

- The functions are not normalised; all expectation values are quotients by `‖u‖² = radialMoment ν l 0`.
- The separation of the three-dimensional Schrödinger equation into spherical harmonics is not part of this module.
- The radial equations are proved pointwise for `ρ ≠ 0` (resp. `r ≠ 0`).

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
