# feat(PhyslibAlpha): completeness of the regular radial solutions of hydrogen

Branch: `hydrogen-radial-completeness` · Base: master

Builds on #1947 (quantisation of the hydrogen levels) and #1909 (radial functions of the hydrogen atom), both merged.

`radial_quantization` in `RadialQuantization.lean` assumes the power series ansatz `u(ρ) = ρ^(l+1) e^(-κρ) Σ_k c_k ρ^k`. This PR removes that assumption. Every solution of the radial equation `u'' = (l(l+1)/ρ² - 2/ρ + κ²) u` on `(0, ∞)` with `u(ρ) → 0` as `ρ → 0⁺` has the ansatz form, with an everywhere convergent series whose coefficients satisfy the recursion. Combined with it, a non-zero square integrable solution vanishing at the origin exists only for `κ = 1/ν` with `ν > l`, and it is a multiple of `u_{νl}`.

The origin is a regular singular point with exponents `l + 1` and `-l`. Only the Frobenius solution for `l + 1` is constructed. The second solution, which has a logarithmic term because `2l + 1` is an integer, is never built; it is excluded by a Wronskian argument.

## Main results

- `entireCoeff_regCoeff`, `radial_ode_of_radialRec`: the regular solution `radialSeries κ l (regCoeff κ l)` exists and solves the radial equation.
- `wronskian_eq_zero_of_tendsto`: a solution tending to `0` at the origin has vanishing Wronskian with the regular solution.
- `eqOn_zero_of_eqOn_Ioo`: a solution of `w'' = q w`, with `q` continuous on `(0, ∞)`, that vanishes on `(0, δ)` vanishes on `(0, ∞)`.
- `radial_regular_solution`: completeness of the regular solutions.
- `radial_quantization_of_tendsto`: quantisation of the hydrogen levels without the ansatz.

## Reviewer map

1. `RadialCompleteness.lean` §A The regular solution: `regCoeff` is defined by the recursion with `c_0 = 1`. Convergence uses the ratio test (`summable_of_ratio_norm_eventually_le`, ratio at most `1/2` once `k ≥ ⌈4(|κ| + 1) r⌉`). `radial_ode_of_radialRec` is the converse of `recursion_of_radial_ode`: it uses the same coefficient series, which now vanishes identically, followed by `radial_identity`.
2. §B Near the origin and the Wronskian: `regSol_near_zero` gives `a ρ^(l+1) ≤ u₁ ρ ≤ b ρ^(l+1)` on `(0, δ]`. `wronskian_const` follows from the helper `exists_const_of_hasDerivAt_zero`.
3. §C Solutions vanishing at the origin: `wronskian_nonpos_of_tendsto` is the long proof. If `W > 0`, then `u/u₁ - K ρ^(-(2l+1))` is antitone on `(0, δ)`, so `u(ρ) ≥ K a - |M| b ρ` for small `ρ`, which contradicts `u → 0`; no integrals are needed. Applying it to `u` and to `-u` gives `W = 0`. Then `exists_eqOn_near_zero_of_tendsto` gives `u = A u₁` on `(0, δ)`.
4. §D Uniqueness away from the origin: `eqOn_zero_of_eqOn_Ioo` applies `ODE_solution_unique_of_mem_Ioo` to the system `(w, w')`. The Lipschitz constant is `max 1 C`, where `C` bounds `|q|` on a compact interval.
5. §E Completeness and quantisation: `radial_regular_solution` and `radial_quantization_of_tendsto`.
6. `RadialQuantization.lean`: module docstring only. The "not formalised" sentence now points to this file.
7. `PhyslibAlpha.lean`: one added import.

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/RadialCompleteness.lean`

All declarations are in the namespace `PhyslibAlpha.Hydrogen`.

| Declaration | Kind | Description |
|---|---|---|
| `radialPot` | def | `q(ρ) = l(l+1)/ρ² - 2/ρ + κ²`, so that the radial equation reads `u'' = q u`. |
| `regCoeff` | def | Coefficients of the regular solution: `c_0 = 1` and the recursion. |
| `regCoeff_zero` | lemma | `regCoeff κ l 0 = 1`. |
| `radialRec_regCoeff` | lemma | `regCoeff κ l` satisfies `RadialRec`. |
| `entireCoeff_regCoeff` | lemma | `regCoeff κ l` defines an everywhere convergent series. |
| `radial_ode_of_radialRec` | lemma | If the coefficients satisfy the recursion, the ansatz solves the radial equation on `(0, ∞)`. |
| `regSol_near_zero` | lemma | Near `0` the regular solution lies between `a ρ^(l+1)` and `b ρ^(l+1)`. |
| `exists_const_of_hasDerivAt_zero` | lemma | Vanishing derivative on an open preconnected set implies constant. |
| `wronskian_const` | lemma | The Wronskian of two solutions of `u'' = q u` on `(0, ∞)` is constant. |
| `wronskian_nonpos_of_tendsto` | lemma | One sign of the Wronskian of a solution tending to `0` with the regular solution. |
| `wronskian_eq_zero_of_tendsto` | lemma | That Wronskian vanishes. |
| `exists_eqOn_near_zero_of_tendsto` | lemma | A solution tending to `0` is a multiple of the regular solution near `0`. |
| `eqOn_zero_of_eqOn_Ioo` | lemma | A solution of `w'' = q w` vanishing on `(0, δ)` vanishes on `(0, ∞)`. |
| `radial_regular_solution` | lemma | Every solution with `u → 0` at `0⁺` is `radialSeries κ l c` for an everywhere convergent `c` satisfying the recursion, with `c_0 ≠ 0` unless `u = 0`. |
| `radial_quantization_of_tendsto` | lemma | Quantisation of the hydrogen levels without the power series ansatz. |

## Notes

- Boundary condition: `u(ρ) → 0` as `ρ → 0⁺`. For `l = 0` the second solution tends to a non-zero constant, so mere boundedness would not exclude it.
- The two main results use the same `deriv` form as `radial_quantization`, plus differentiability hypotheses. The intermediate lemmas use `HasDerivAt` with an explicit `u'`.
- `wronskian_nonpos_of_tendsto` is a single proof of about 90 lines, with comments marking its steps.

---
AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
