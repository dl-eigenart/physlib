# feat(PhyslibAlpha): degeneracy of the hydrogen bound states

Branch: `hydrogen-e3-1` (1 commit, 547 + 1 lines) · Base: master · Depends on: nothing open · Library: PhyslibAlpha

Builds on #1948 (bound states of the d-dimensional hydrogen atom), merged. First of four stacked PRs (20a–20d).

#1948 constructs the bound states `boundState H N l P` and shows that, away from the nucleus, they satisfy the eigenvalue equation with the Bohr energy `E_{N+l}`. This PR counts them. For homogeneous harmonic polynomials `P` of degree `l ≤ n`, the bound states of the level `n` are linearly independent and span a space of dimension `Σ_{l ≤ n} dim Harm_l`, which is `(n + 1)²` in three dimensions. The statements are about functions on `Space d`; the Hilbert space comes in the next PR.

## Main results

- `finrank_harmonicSubmodule`: for `d ≥ 2`, the homogeneous harmonic polynomials of degree `l` in `d` variables form a space of dimension `C(l + d - 1, d - 1) - C(l + d - 3, d - 1)`; `finrank_harmonicSubmodule_three`: `2l + 1` for `d = 3`.
- `boundState_eigen_of_mem_harmonicSubmodule`: for `P ∈ harmonicSubmodule d l`, `d ≥ 2`, `k > 0` and `x ≠ 0`, `-ℏ²/(2m) Δψ + V ψ = E_{N+l} ψ` for `ψ = boundState H N l (toFun P)`.
- `boundStateMap_injective`, `finrank_range_boundStateMap`: the map `(P_l)_{l ≤ n} ↦ Σ_l boundState H (n - l) l P_l` is injective, so the level `n` carries a space of bound states of dimension `Σ_{l ≤ n} dim Harm_l`; `finrank_range_boundStateMap_three`: `(n + 1)²` for `H : HydrogenAtom 3`.

## Reviewer map

1. `Degeneracy.lean` (547 lines). §A Homogeneous harmonic polynomials: `finrank_homogeneousSubmodule` counts monomials as multisets; `finrank_harmonicSubmodule` follows from the surjectivity of the Laplacian `Hom_{l+2} → Hom_l` (`finrank_harmonicSubmodule_add_finrank`), which is shown with the Fischer inner product (`fischer`, `fischer_mul_X`, `fischer_self_pos`, `eq_zero_of_polyLaplacian_eq_zero_of_eq_rSq_mul`). §B Polynomials as functions on space (`toFun`, `deriv_toFun`, `euler_toFun`, `laplacian_toFun`) connects to the hypotheses of `boundState_eigen` from #1948. §C Linear independence: along a ray `y = t ω` the summand of degree `l` behaves like `t^l`, and `eq_zero_of_sum_pow_mul` compares the lowest powers as `t → 0`.
2. `PhyslibAlpha.lean`: one added import.

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

## Notes

- Results stated for `d = 3` use `H : HydrogenAtom 3`; the general statements carry `hd : 2 ≤ d` and `hk : 0 < H.k`.
- `Degeneracy.lean` cites Axler, Bourdon and Ramey, *Harmonic Function Theory*, chapter 5, for the dimension of the harmonic polynomials.

---
*Draft for the human author. Check every line before posting; the author is responsible for the content (AI-POLICY.md §1.7).*

AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
