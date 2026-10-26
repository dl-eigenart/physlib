# feat(PhyslibAlpha): Green's identity and regularised radial functions

Branch: `hydrogen-e3-3` (1 commit, 296 + 1 lines) · Base: master after merge of `hydrogen-e3-2` · Depends on: `hydrogen-e3-2` (20b; uses only `PolyBounded.lean` from it) · Library: PhyslibAlpha

Third of four stacked PRs (20a–20d).

Green's identity `∫ u Δf = ∫ (Δu) f` for a `C²` function `u` with polynomially bounded `u`, `∂ᵢu`, `∂ᵢ∂ᵢu` and a Schwartz map `f`. Functions of the form `R(‖y‖) Q(y)` are in general not smooth at the origin; replacing `‖y‖` by the regularised radius `√(‖y‖² + ε²)` makes them smooth for `ε ≠ 0`. This PR provides the derivatives of `G(‖y‖²) Q(y)` and polynomial bounds, uniform in `|ε| ≤ 1`, needed in 20d to apply Green's identity to the regularised bound states.

## Main results

- `integral_ofReal_mul_sum_deriv_deriv`: Green's identity `∫ u Σᵢ∂ᵢ∂ᵢf = ∫ (Σᵢ∂ᵢ∂ᵢu) f` for `C²` functions `u` with polynomially bounded `u`, `∂ᵢu`, `∂ᵢ∂ᵢu` and Schwartz maps `f`.

## Reviewer map

1. `GreenIdentity.lean` (296 lines). §A Green's identity for smooth functions (two integrations by parts). §B Coordinate derivatives of `G(‖y‖²) Q(y)` at every point. §C The regularised profile `regG f ε : s ↦ f(√(s + ε²))` and polynomial bounds uniform in `|ε| ≤ 1`.
2. `PhyslibAlpha.lean`: one added import.

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/GreenIdentity.lean`

Namespace `PhyslibAlpha.Hydrogen`; 18 declarations.

| Declaration | Kind | Description |
|---|---|---|
| `deriv_ofReal` | lemma | The derivative of a real function, viewed as a complex function. |
| `deriv_schwartz` | lemma | The coordinate derivative of a Schwartz map, as a Schwartz map. |
| `integral_ofReal_mul_sum_deriv_deriv` | lemma | **Green's identity for smooth functions.** If `u` is `C²` and `u`, `∂ᵢu`, `∂ᵢ∂ᵢu` are polynomially bounded, then `∫ u Σᵢ ∂ᵢ∂ᵢ f = ∫ (Σᵢ ∂ᵢ∂ᵢ u) f` for every Schwartz map `f`. |
| `deriv_radial_mul` | lemma | `∂ᵢ (G(‖y‖²) Q) = G ∂ᵢQ + Q G' 2yᵢ` at every point, if `G` is differentiable on `[0, ∞)`. |
| `deriv_deriv_radial_mul` | lemma | `∂ᵢ∂ᵢ (G(‖y‖²) Q) = G ∂ᵢ∂ᵢQ + 4 G' yᵢ ∂ᵢQ + (2 G' + 4 yᵢ² G'') Q` at every point. |
| `regG` | def | The regularised radial profile `s ↦ f(√(s + ε²))`, smooth also at `s = 0`. |
| `regG'` | def | The derivative of `regG f ε`. |
| `regG''` | def | The second derivative of `regG f ε`. |
| `abs_le_regRadius` | lemma | The regularised radius `√(‖y‖² + ε²)` is at least `|ε|`. |
| `isPolyBounded_poly_exp_regRadius` | lemma | A polynomial in the regularised radius times `e^(-κρ)`, `κ ≥ 0`, is polynomially bounded. |
| `isPolyBounded_regG` | lemma | The profiles `G_ε`, `G_ε'`, `G_ε''` of `f(r) = p(r) e^(-κr)` on `‖y‖²` are polynomially bounded for fixed `ε ≠ 0`. |
| `exists_abs_poly_exp_regRadius_le` | lemma | A bound for `p(ρ) e^(-κρ)`, `ρ = √(‖y‖² + ε²)`, uniform in `|ε| ≤ 1`. |

Without docstring (auxiliary): `hasDerivAt_regG`, `hasDerivAt_regG'`, `isPolyBounded_regRadius`, `isPolyBounded_inv_regRadius`, `isPolyBounded_regG'`, `isPolyBounded_regG''`.

---
*Draft for the human author. Check every line before posting; the author is responsible for the content (AI-POLICY.md §1.7).*

AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
