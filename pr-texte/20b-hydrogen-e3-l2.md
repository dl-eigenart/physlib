# feat(PhyslibAlpha): the hydrogen bound states in L²

Branch: `hydrogen-e3-2` (2 commits, 307 + 255 + 2 lines) · Base: `hydrogen-e3-1` (#1996), stacked · Depends on: #1996 (`hydrogen-e3-1`, 20a) · Library: PhyslibAlpha

blocked-by-PR #1996

Second of four stacked PRs (20a–20d).

The bound states of 20a are square integrable and stay linearly independent as vectors of `SpaceDHilbertSpace d`, over `ℝ` and over `ℂ`; in three dimensions the level `n` spans a real and a complex subspace of dimension `(n + 1)²`. The integrability is collected in a small theory of polynomially bounded functions on `Space d` (`IsPolyBounded`), which the next two PRs use again.

## Main results

- `memHS_boundState`, `boundStateHS`: the bound states as vectors of `SpaceDHilbertSpace d`; `boundStateMapHS_injective`: still linearly independent there.
- `finrank_range_boundStateMapHS_three`, `finrank_span_range_boundStateMapHS_three`: in three dimensions the level `n` spans a real, and a complex, subspace of dimension `(n + 1)²`. The complex statement uses `linearIndependent_complex_of_real_inner`: vectors with real Gram matrix that are linearly independent over `ℝ` are linearly independent over `ℂ`.

## Reviewer map

1. `PolyBounded.lean` (307 lines). §A The predicate `IsPolyBounded` and its closure properties. §B Integrability: `integrable_sq_of_le_mul_exp`, products with Schwartz maps, and `integrable_inv_norm_mul_one_add_norm_pow` (polar coordinates) for the extra factor `‖y‖⁻¹` of the Coulomb potential, `d ≥ 2`.
2. `BoundStatesL2.lean` (255 lines). §A `memHS_boundState`, `boundStateHS`. §B Linear independence in the Hilbert space: continuity turns `boundStateMap_injective` into `boundStateMapHS_injective`; the bound states are real valued (`im_inner_boundStateMapHS`), which gives the complex dimension.
3. `PhyslibAlpha.lean`: two added imports.

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/PolyBounded.lean`

Namespace `PhyslibAlpha.Hydrogen` (helpers on `IsPolyBounded` in `PhyslibAlpha.Hydrogen.IsPolyBounded`); 21 declarations.

| Declaration | Kind | Description |
|---|---|---|
| `IsPolyBounded` | def | `f` grows at most polynomially: `|f y| ≤ C (1 + ‖y‖)^k` for some `C ≥ 0` and `k`. |
| `toFun` | lemma | Polynomials in the coordinates are polynomially bounded. |
| `polynomial_eval` | lemma | A polynomial of a polynomially bounded function is polynomially bounded. |
| `one_add_pow_mul_exp_neg_le` | lemma | `(1 + t)^m e^(-c t) ≤ e^c m! / c^m` for `c > 0` and `t ≥ 0`, from `x^m / m! ≤ e^x`. |
| `integrable_sq_of_le_mul_exp` | lemma | If `|f y| ≤ |g y| e^(-c‖y‖)` with `g` polynomially bounded and `c > 0`, then `f²` is integrable: it is bounded by a multiple of `(1 + ‖y‖)^(-(d+1))`. |
| `IsPolyBounded.integrable_ofReal_mul_schwartz` | lemma | A polynomially bounded function times a Schwartz map is integrable. |
| `integrable_inv_norm_mul_one_add_norm_pow` | lemma | `‖y‖⁻¹ (1 + ‖y‖)^(-M)` is integrable on `Space d` for `d ≥ 2` and `M ≥ d`, by polar coordinates: the radial integrand `r^(d-2) (1 + r)^(-M)` is at most `(1 + r)^(-2)`. |
| `Polynomial.exists_abs_eval_le` | lemma | A real polynomial grows at most polynomially: `|p(t)| ≤ C (1 + |t|)^k`. |
| `IsPolyBounded.integrable_abs_mul_norm_schwartz` | lemma | A polynomially bounded function times the norm of a Schwartz map is integrable. |
| `IsPolyBounded.integrable_inv_norm_mul` | lemma | `‖y‖⁻¹` times a polynomially bounded function times the norm of a Schwartz map is integrable in dimension `d ≥ 2`. |

Without docstring (auxiliary): `one_le_one_add_norm`, `const`, `add`, `mul`, `pow`, `coord`, `norm`, `sum`, `mono`, `of_abs_le_const`, `neg`.

### `PhyslibAlpha/QuantumMechanics/Hydrogen/BoundStatesL2.lean`

Namespace `PhyslibAlpha.Hydrogen`; 13 declarations.

| Declaration | Kind | Description |
|---|---|---|
| `boundKappa_pos` | lemma | The decay constant `κ = 1/(a L_n)` of a bound state is positive for `k > 0` and `d ≥ 2`. |
| `memHS_boundState` | lemma | The bound states are square integrable. |
| `boundStateHS` | def | The bound state `boundState H N l P` as a vector of `SpaceDHilbertSpace d`. |
| `boundStateMap_apply` | lemma | `Σ_l boundState H (n - l) l P_l = e^(-κ‖y‖) Σ_l L_l(‖y‖) P_l(y)` with `κ = boundKappa H n`. |
| `memHS_boundStateMap` | lemma | The sums of bound states of one level are square integrable. |
| `boundStateMapHS` | def | The bound states of the level `n` as an `ℝ`-linear map into `SpaceDHilbertSpace d`. |
| `boundStateMapHS_injective` | lemma | The bound states of one level are linearly independent in `SpaceDHilbertSpace d`. |
| `finrank_range_boundStateMapHS_three` | lemma | In three dimensions the bound states of the level `n` span a `(n + 1)²`-dimensional subspace of `SpaceDHilbertSpace 3`. |
| `linearIndependent_complex_of_real_inner` | lemma | Vectors with real Gram matrix that are linearly independent over `ℝ` are linearly independent over `ℂ`. |
| `im_inner_boundStateMapHS` | lemma | The bound states are real valued, so their inner products are real. |
| `finrank_span_range_boundStateMapHS_three` | lemma | In three dimensions the bound states of the level `n` span a complex subspace of dimension `(n + 1)²` of `SpaceDHilbertSpace 3`. |

Without docstring (auxiliary): `continuous_boundState`, `continuous_boundStateMap`.

## Notes

- Results stated for `d = 3` use `H : HydrogenAtom 3`; the general statements carry `hd : 2 ≤ d` and `hk : 0 < H.k`.

---
*Draft for the human author. Check every line before posting; the author is responsible for the content (AI-POLICY.md §1.7).*

AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
