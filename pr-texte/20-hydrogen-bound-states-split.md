# feat(PhyslibAlpha): degeneracy of the hydrogen bound states, and the bound states as eigenvectors of the adjoint Hamiltonian

Branch: `hydrogen-bound-states-split` (5 commits) · Base: master · Depends on: nothing open · Library: PhyslibAlpha

Builds on #1948 (bound states of the d-dimensional hydrogen atom) and #1930 (the hydrogen Hamiltonian is densely defined), both merged. Independent of #1963.

#1948 constructs the bound states `boundState H N l P` and shows that, away from the nucleus, they satisfy the eigenvalue equation with the Bohr energy `E_{N+l}`. This PR answers three follow-up questions. How many independent bound states does a level have? For homogeneous harmonic polynomials `P` of degree `l ≤ n`, the bound states of the level `n` are linearly independent and span a space of dimension `Σ_{l ≤ n} dim Harm_l`, which is `(n + 1)²` in three dimensions. Are they vectors of the Hilbert space? They are square integrable and stay linearly independent in `SpaceDHilbertSpace d`, over `ℝ` and over `ℂ`. In what sense are they eigenvectors? They are not smooth at the nucleus and so do not lie in the domain of `H.hamiltonianOperator`, which is defined on Schwartz maps. They satisfy the eigenvalue equation weakly, `⟪E ψ, φ⟫ = ⟪ψ, H φ⟫` for all `φ` in the domain of `H`. Since `H` is densely defined (#1930), this says they are eigenvectors of the adjoint `H†`. In three dimensions `E_n` is therefore an eigenvalue of `H†` of multiplicity at least `(n + 1)²`.

The weak eigenvalue equation comes from Green's identity for the regularised bound states `ψ_ε(y) = R(√(‖y‖² + ε²)) P(y)`, which are smooth for `ε ≠ 0`, and the limit `ε → 0` by dominated convergence. The integrability needed along the way is collected in a small theory of polynomially bounded functions on `Space d`.

## Main results

- `finrank_harmonicSubmodule`: for `d ≥ 2`, the homogeneous harmonic polynomials of degree `l` in `d` variables form a space of dimension `C(l + d - 1, d - 1) - C(l + d - 3, d - 1)`; `finrank_harmonicSubmodule_three`: `2l + 1` for `d = 3`.
- `boundState_eigen_of_mem_harmonicSubmodule`: for `P ∈ harmonicSubmodule d l`, `d ≥ 2`, `k > 0` and `x ≠ 0`, `-ℏ²/(2m) Δψ + V ψ = E_{N+l} ψ` for `ψ = boundState H N l (toFun P)`.
- `boundStateMap_injective`, `finrank_range_boundStateMap`: the map `(P_l)_{l ≤ n} ↦ Σ_l boundState H (n - l) l P_l` is injective, so the level `n` carries a space of bound states of dimension `Σ_{l ≤ n} dim Harm_l`; `finrank_range_boundStateMap_three`: `(n + 1)²` for `H : HydrogenAtom 3`.
- `memHS_boundState`, `boundStateHS`: the bound states as vectors of `SpaceDHilbertSpace d`; `boundStateMapHS_injective`: still linearly independent there.
- `finrank_range_boundStateMapHS_three`, `finrank_span_range_boundStateMapHS_three`: in three dimensions the level `n` spans a real, and a complex, subspace of dimension `(n + 1)²`. The complex statement uses `linearIndependent_complex_of_real_inner`: vectors with real Gram matrix that are linearly independent over `ℝ` are linearly independent over `ℂ`.
- `integral_ofReal_mul_sum_deriv_deriv`: Green's identity `∫ u Σᵢ∂ᵢ∂ᵢf = ∫ (Σᵢ∂ᵢ∂ᵢu) f` for `C²` functions `u` with polynomially bounded `u`, `∂ᵢu`, `∂ᵢ∂ᵢu` and Schwartz maps `f`.
- `integral_boundState_mul_hamiltonian`: Green's identity for a bound state, `∫ ψ (H f) = ∫ (H ψ) f` for every Schwartz map `f`.
- `inner_boundStateHS_hamiltonianOperator`: the weak eigenvalue equation `⟪E_{N+l} ψ, φ⟫ = ⟪ψ, H φ⟫` for every `φ` in `H.hamiltonianOperator.domain`.
- `boundStateHS_mem_adjoint_domain`, `adjoint_boundStateHS`: `ψ` lies in the domain of `H.hamiltonianOperator†` and `H† ψ = E_{N+l} ψ`; `adjoint_boundStateMapHS`: the same for every sum of bound states of one level, with eigenvalue `E_n`.
- `exists_finrank_eigenvectors_adjoint_three`, `exists_finrank_eigenvectors_adjoint_three_complex`: for `H : HydrogenAtom 3` with `k > 0`, there is a real (resp. complex) subspace of dimension `(n + 1)²` of eigenvectors of `H†` with eigenvalue `E_n`.

## Reviewer map

The five commits add one file each, in this order.

1. `Degeneracy.lean` (547 lines). §A Homogeneous harmonic polynomials: `finrank_homogeneousSubmodule` counts monomials as multisets; `finrank_harmonicSubmodule` follows from the surjectivity of the Laplacian `Hom_{l+2} → Hom_l` (`finrank_harmonicSubmodule_add_finrank`), which is shown with the Fischer inner product (`fischer`, `fischer_mul_X`, `fischer_self_pos`, `eq_zero_of_polyLaplacian_eq_zero_of_eq_rSq_mul`). §B Polynomials as functions on space (`toFun`, `deriv_toFun`, `euler_toFun`, `laplacian_toFun`) connects to the hypotheses of `boundState_eigen` from #1948. §C Linear independence: along a ray `y = t ω` the summand of degree `l` behaves like `t^l`, and `eq_zero_of_sum_pow_mul` compares the lowest powers as `t → 0`.
2. `PolyBounded.lean` (307 lines). §A The predicate `IsPolyBounded` and its closure properties. §B Integrability: `integrable_sq_of_le_mul_exp`, products with Schwartz maps, and `integrable_inv_norm_mul_one_add_norm_pow` (polar coordinates) for the extra factor `‖y‖⁻¹` of the Coulomb potential, `d ≥ 2`.
3. `BoundStatesL2.lean` (255 lines). §A `memHS_boundState`, `boundStateHS`. §B Linear independence in the Hilbert space: continuity turns `boundStateMap_injective` into `boundStateMapHS_injective`; the bound states are real valued (`im_inner_boundStateMapHS`), which gives the complex dimension.
4. `GreenIdentity.lean` (296 lines). §A Green's identity for smooth functions (two integrations by parts). §B Coordinate derivatives of `G(‖y‖²) Q(y)` at every point. §C The regularised profile `regG f ε : s ↦ f(√(s + ε²))` and polynomial bounds uniform in `|ε| ≤ 1`.
5. `BoundStatesAdjoint.lean` (741 lines). §A Regularised bound states and their Laplacian (`laplacian_regBoundState`). §B The weak eigenvalue equation: `integral_regBoundState_mul_sum_deriv_deriv`, then `integral_boundState_mul_sum_deriv_deriv` as the limit `ε → 0` by dominated convergence with the bound `exists_abs_laplacian_regBoundState_le`; `hamiltonianOperator_apply_ae` identifies `H φ` for `φ` in the domain. §C Eigenvectors of the adjoint. §D The whole level and the three-dimensional multiplicity.
6. `PhyslibAlpha.lean`: five added imports.

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/Degeneracy.lean`

Namespace `PhyslibAlpha.Hydrogen`; 44 declarations.

| Declaration | Kind | Description |
|---|---|---|
| `polyLaplacian` | def | The Laplacian `Σᵢ ∂ᵢ² P` of a polynomial in `d` variables. |
| `harmonicSubmodule` | def | The homogeneous harmonic polynomials of degree `l` in `d` variables. |
| `finrank_homogeneousSubmodule` | lemma | The homogeneous polynomials of degree `l` in `d ≥ 1` variables form a space of dimension `C(l + d - 1, d - 1)`: their monomials correspond to multisets of size `l` in `d` letters. |
| `polyLaplacian_isHomogeneous` | lemma | The Laplacian lowers the degree of a homogeneous polynomial by two. |
| `pderiv_eq_zero_of_isHomogeneous_zero` | lemma | A homogeneous polynomial of degree `0` is constant, so its derivatives vanish. |
| `polyLaplacian_eq_zero_of_lt_two` | lemma | The Laplacian vanishes on homogeneous polynomials of degree `0` and `1`. |
| `fischerWeight` | def | The weight `m! = Πⱼ mⱼ!` of a monomial exponent `m`. |
| `fischer` | def | The Fischer inner product `Σₘ m! Pₘ Qₘ` of two polynomials. |
| `fischer_mul_X` | lemma | Multiplication by `Xᵢ` is adjoint to `∂ᵢ` for the Fischer inner product. |
| `fischer_self_pos` | lemma | The Fischer inner product is positive definite. |
| `rSq` | def | `r² = Σᵢ Xᵢ²`. |
| `eq_zero_of_polyLaplacian_eq_zero_of_eq_rSq_mul` | lemma | A harmonic polynomial divisible by `r²` vanishes: `⟨r² P, r² P⟩ = ⟨P, Δ(r² P)⟩ = 0`. |
| `finrank_harmonicSubmodule_add_finrank` | lemma | `dim Harm_{l+2} + dim Hom_l = dim Hom_{l+2}`: the Laplacian `Hom_{l+2} → Hom_l` is onto. |
| `finrank_harmonicSubmodule` | lemma | The homogeneous harmonic polynomials of degree `l` in `d ≥ 2` variables form a space of dimension `C(l + d - 1, d - 1) - C(l + d - 3, d - 1)`. |
| `finrank_harmonicSubmodule_three` | lemma | In three variables the homogeneous harmonic polynomials of degree `l` form a space of dimension `2l + 1`. |
| `sum_two_mul_add_one` | lemma | `Σ_{l ≤ n} (2l + 1) = (n + 1)²`. |
| `toFun` | def | A polynomial in `d` variables as a function on `Space d`. |
| `contDiff_toFun_infty` | lemma | Polynomials are smooth. |
| `contDiff_toFun` | lemma | Polynomials are twice continuously differentiable. |
| `deriv_toFun` | lemma | The partial derivative of a polynomial function is the polynomial partial derivative. |
| `euler_toFun` | lemma | Euler's relation `Σᵢ yᵢ ∂ᵢP = l P` for a homogeneous polynomial of degree `l`. |
| `laplacian_toFun` | lemma | The Laplacian of a polynomial function is the polynomial Laplacian. |
| `boundState_eigen_of_mem_harmonicSubmodule` | lemma | A homogeneous harmonic polynomial of degree `l` gives the bound state `boundState H N l P` of energy `E_{N+l}`, away from the nucleus. |
| `toFun_smul_of_isHomogeneous` | lemma | A homogeneous polynomial of degree `l` scales as `P(t y) = t^l P(y)`. |
| `eq_zero_of_sum_pow_mul` | lemma | If `Σ_l c_l t^l f_l(t) = 0` for all `t > 0`, with continuous `f_l` and `f_l(0) ≠ 0`, then all `c_l` vanish: compare the lowest powers of `t` as `t → 0⁺`. |
| `boundStateMap` | def | The bound states of the level `n`: a family `(P_l)_{l ≤ n}` of homogeneous harmonic polynomials gives `Σ_l boundState H (n - l) l P_l`. |
| `boundStateMap_injective` | lemma | The bound states of one level, for different `l` and linearly independent polynomials, are linearly independent. Along a ray `y = t ω` the summand of degree `l` is `e^(-κ t ‖ω‖)` times `t^l P_l(ω)` times a Laguerre polynomial in `t` that does not vanish at `t = 0`. |
| `finrank_range_boundStateMap` | lemma | The bound states of the level `n` span a space of dimension `Σ_{l ≤ n} dim Harm_l`. |
| `finrank_range_boundStateMap_three` | lemma | In three dimensions the level `n` carries `(n + 1)²` linearly independent bound states. |

Without docstring (auxiliary): `polyLaplacian_apply`, `fischerWeight_pos`, `fischerWeight_add_single`, `fischer_eq_sum`, `fischer_zero_left`, `fischer_add_left`, `fischer_sum_left`, `fischer_sum_right`, `fischer_zero_right`, `rSq_isHomogeneous`, `rSq_ne_zero`, `toFun_C` (@[simp]), `toFun_add` (@[simp]), `toFun_mul_X`, `differentiable_toFun`.

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

### `PhyslibAlpha/QuantumMechanics/Hydrogen/BoundStatesAdjoint.lean`

Namespace `PhyslibAlpha.Hydrogen`; 19 declarations.

| Declaration | Kind | Description |
|---|---|---|
| `laplacian_regBoundState` | lemma | Away from the origin, `Δψ_ε = ((4l + 2d) G_ε' + 4‖y‖² G_ε'') P` for a homogeneous harmonic `P` of degree `l` (also for `ε = 0`, where `ψ_0` is the bound state). |
| `boundState_eq_regG` | lemma | The bound state is the regularised bound state at `ε = 0`. |
| `integral_regBoundState_mul_sum_deriv_deriv` | lemma | **Green's identity for the regularised bound state** `ψ_ε(y) = R(√(‖y‖² + ε²)) P(y)`, `R = radialFactor κ N α` with `κ ≥ 0`. |
| `momentumSqOperator_apply_schwartzEquiv` | lemma | On (the class of) a Schwartz map `f`, the momentum squared acts as `Σᵢ 𝐩ᵢ 𝐩ᵢ f`. |
| `hamiltonianOperator_apply_ae` | lemma | A vector `φ` in the domain of the Hamiltonian is (the class of) a Schwartz map `f`, and `H φ = -ℏ²/(2m) Σᵢ ∂ᵢ∂ᵢ f + V f` almost everywhere. |
| `exists_abs_laplacian_regBoundState_le` | lemma | A bound `|Δψ_ε(y)| ≤ (A (1 + ‖y‖)^k₁ ‖y‖⁻¹ + C (1 + ‖y‖)^k₂) |P(y)|` away from the origin, uniform in `|ε| ≤ 1` (including the bound state itself at `ε = 0`). |
| `integral_boundState_mul_sum_deriv_deriv` | lemma | **Green's identity for the kinetic term**: `∫ ψ Σᵢ ∂ᵢ∂ᵢ f = ∫ (Δψ) f` for a bound state `ψ`, the limit `ε → 0` of `integral_regBoundState_mul_sum_deriv_deriv`. |
| `integral_boundState_mul_hamiltonian` | lemma | **Green's identity for a bound state.** Moving the Hamiltonian from a Schwartz map `f` onto the bound state `ψ`, which is smooth away from the nucleus: `∫ ψ (-ℏ²/(2m) Σᵢ ∂ᵢ∂ᵢ f + V f) = ∫ (-ℏ²/(2m) Δψ + V ψ) f`. |
| `inner_boundStateHS_hamiltonianOperator` | lemma | The weak eigenvalue equation `⟪E ψ, φ⟫ = ⟪ψ, H φ⟫` of a bound state `ψ` of the level `N + l`, for every `φ` in the domain of the Hamiltonian. |
| `adjoint_boundStateHS` | lemma | The bound state of the level `N + l` is an eigenvector of the adjoint Hamiltonian with eigenvalue the Bohr energy `E_{N+l}`. |
| `inner_boundStateMapHS_hamiltonianOperator` | lemma | The weak eigenvalue equation `⟪E_n ψ, φ⟫ = ⟪ψ, H φ⟫` for every sum `ψ` of bound states of the level `n` and every `φ` in the domain of the Hamiltonian. |
| `boundStateMapHS_mem_adjoint_domain` | lemma | The sums of bound states of one level lie in the domain of the adjoint Hamiltonian. |
| `adjoint_boundStateMapHS` | lemma | Every sum of bound states of the level `n` is an eigenvector of the adjoint Hamiltonian with eigenvalue `E_n`. |
| `exists_finrank_eigenvectors_adjoint_three` | lemma | In three dimensions the Bohr energy `E_n` is an eigenvalue of the adjoint Hamiltonian whose eigenvectors contain a real subspace of dimension `(n + 1)²`. |
| `exists_finrank_eigenvectors_adjoint_three_complex` | lemma | In three dimensions the Bohr energy `E_n` is an eigenvalue of the adjoint Hamiltonian of (complex) multiplicity at least `(n + 1)²`. |

Without docstring (auxiliary): `momentumOperator_apply_schwartzEquiv`, `boundStateHS_mem_adjoint_domain`, `boundStateMap_single`, `boundStateMapHS_single`.

## Notes

- The results are about the adjoint `H†`, not about `H` itself or its closure: the bound states are not in the domain of `H.hamiltonianOperator`. If `H` is essentially self-adjoint, `H†` is the closure of `H` and the results say that `E_n` is an eigenvalue of the self-adjoint Hamiltonian of multiplicity at least `(n + 1)²`; essential self-adjointness is not proved here.
- Only "at least `(n + 1)²`" is shown; that the multiplicity is exactly `(n + 1)²` is not shown here.
- Results stated for `d = 3` use `H : HydrogenAtom 3`; the general statements carry `hd : 2 ≤ d` and `hk : 0 < H.k`.
- `Degeneracy.lean` cites Axler, Bourdon and Ramey, *Harmonic Function Theory*, chapter 5, for the dimension of the harmonic polynomials.
- The PR is large (2151 added lines). The commits follow the file structure, so it can be split into five PRs along the commits if preferred.

---
*Draft for the human author. Check every line before posting; the author is responsible for the content (AI-POLICY.md §1.7).*

AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
