# feat(PhyslibAlpha): bound states of the d-dimensional hydrogen atom

Branch: `pr/hydrogen-bound-states` · Base: master, after the radial functions PR is merged (parallel to the quantisation PR) · Depends on: `pr/hydrogen-radial` (radial functions of the hydrogen atom), and through it `pr/laguerre`

This PR gives explicit bound-state wave functions of physlib's `HydrogenAtom` in `d ≥ 2` dimensions and proves that, away from the nucleus, they are eigenfunctions of `-ℏ²/(2m) Δ - k/r` with the Bohr energies `HydrogenAtom.energyLevel`. The angular part is a homogeneous harmonic polynomial `P` of degree `l`, and the Laplacian of `f(‖y‖) P(y)` is reduced to `(f'' + (d - 1 + 2l) f'/r) P` without angular coordinates. The radial factor is `e^(-κr) L_N^(2l+d-2)(2κr)`. It builds on `hasDerivAt_eval_mul_exp` and `bohrRadius` from the radial functions PR and on `laguerre_ode` from the Laguerre PR.

## Main results

- `laplacian_radial_mul`: for `x ≠ 0`, `Δ(G(‖y‖²) P) = G ΔP + 4 G' Σᵢ yᵢ ∂ᵢP + (2d G' + 4‖y‖² G'') P`.
- `laplacian_radial_harmonic`: for `P` with `Σᵢ yᵢ ∂ᵢP = l P` and `ΔP = 0`, `Δ(f(‖y‖) P) = (f'' + (d - 1 + 2l) f'/r) P` at `x ≠ 0`.
- `radialFactor_ode`: `r f'' + (α + 1) f' + (2κ(N + (α + 1)/2) - κ² r) f = 0` for `f = e^(-κr) L_N^(α)(2κr)`.
- `boundState_eigen`: for `d ≥ 2`, `k > 0` and `x ≠ 0`, `-ℏ²/(2m) Δψ + V ψ = E_{N+l} ψ` for `ψ = boundState H N l P`.
- `boundState_eigen_s`, `boundState_eigen_p`: the cases `P = 1` and `P = yⱼ`.

## Reviewer map

1. `Eigenfunctions.lean` §A The Laplacian of a radial function times a polynomial: the helper lemmas on `‖y‖²` and on `∂[i]` of sums and products, then `laplacian_radial_mul`; its proof computes `∂[i]` near `x` on the open set `0 < ‖y‖²` and then sums the second derivatives.
2. `Eigenfunctions.lean` §B Radial functions of `‖y‖`: the chain rule through `√s` and `laplacian_radial_harmonic`, which writes `f(‖y‖) = f(√(‖y‖²))`.
3. `Eigenfunctions.lean` §C The radial factor: the definitions `laguerreScaled`, `radialFactor`, `radialFactor'`, `radialFactor''` and `radialFactor_ode`, a `linear_combination` of `laguerre_ode`.
4. `Eigenfunctions.lean` §D The bound states of the `d`-dimensional hydrogen atom: `boundKappa`, `boundState`, `boundState_eigen`; check the index `α = 2l + d - 2` (natural subtraction, with `d ≥ 2`) and the identification `N + (α + 1)/2 = H.levelIndex (N + l)`.
5. `PhyslibAlpha.lean`: one added import.

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/Eigenfunctions.lean`

All declarations are in the namespace `PhyslibAlpha.Hydrogen`.

| Declaration | Kind | Description |
|---|---|---|
| `isOpen_normSq_pos` | lemma | `{y : Space d \| 0 < ‖y‖²}` is open. |
| `differentiableAt_normSq` | lemma | `y ↦ ‖y‖²` is differentiable at every point. |
| `deriv_comp_normSq` | lemma | `∂ᵢ G(‖y‖²) = G'(‖y‖²) 2 yᵢ` at `x`, given `HasDerivAt G g (‖x‖²)`. |
| `differentiableAt_comp_normSq` | lemma | `y ↦ G(‖y‖²)` is differentiable at `x` under the same hypothesis. |
| `deriv_add_apply` | lemma | `∂[i] (A + B) x = ∂[i] A x + ∂[i] B x` for `A`, `B` differentiable at `x`. |
| `deriv_mul_apply` | lemma | `∂[i] (A B) x = A x ∂[i] B x + B x ∂[i] A x` for `A`, `B` differentiable at `x`. |
| `laplacian_radial_mul` | lemma | For `P` of class `C²` and `x ≠ 0`, `Δ(G(‖y‖²) P) = G ΔP + 4 G' Σᵢ yᵢ ∂ᵢP + (2d G' + 4‖y‖² G'') P`. |
| `hasDerivAt_comp_sqrt` | lemma | For `s > 0`, the derivative of `s ↦ f(√s)` is `f'(√s)/(2√s)`. |
| `hasDerivAt_comp_sqrt'` | lemma | For `s > 0`, the derivative of `s ↦ f'(√s)/(2√s)` is `(f''(√s) - f'(√s)/√s)/(4s)`. |
| `laplacian_radial_harmonic` | lemma | For a homogeneous harmonic `P` of degree `l` and `x ≠ 0`, `Δ(f(‖y‖) P) = (f'' + (d - 1 + 2l) f'/r) P`. |
| `laguerreScaled` | def | The polynomial `L_N^(α)(2κr)` in `r`. |
| `radialFactor` | def | The radial factor `e^(-κr) L_N^(α)(2κr)`. |
| `radialFactor'` | def | The first derivative of `radialFactor`, as a polynomial times `e^(-κr)`. |
| `radialFactor''` | def | The second derivative of `radialFactor`, as a polynomial times `e^(-κr)`. |
| `hasDerivAt_radialFactor` | lemma | `radialFactor'` is the derivative of `radialFactor`. |
| `hasDerivAt_radialFactor'` | lemma | `radialFactor''` is the derivative of `radialFactor'`. |
| `radialFactor_ode` | lemma | `r f'' + (α + 1) f' + (2κ(N + (α + 1)/2) - κ² r) f = 0` for `f = radialFactor κ N α`. |
| `boundKappa` | def | The decay constant `κ = 1/(a L_n)` of the level `n`, with `L_n = H.levelIndex n = n + (d - 1)/2`. |
| `boundState` | def | `ψ(y) = e^(-κ r) L_N^(2l+d-2)(2κ r) P(y)` with `r = ‖y‖` and `κ = boundKappa H (N + l)`. |
| `boundState_eigen` | lemma | For `d ≥ 2`, `k > 0`, homogeneous harmonic `P` of degree `l` and `x ≠ 0`, `-ℏ²/(2m) Δψ + H.potential ψ = H.energyLevel (N + l) ψ`. |
| `boundState_eigen_s` | lemma | The case `P = 1`, `l = 0`, with energy `H.energyLevel N`. |
| `boundState_eigen_p` | lemma | The case `P = yⱼ`, `l = 1`, with energy `H.energyLevel (N + 1)`. |

## Notes

- The eigenvalue equation is proved pointwise away from the nucleus, where `ψ` is smooth.
- It is not shown that these are all eigenfunctions, nor that they lie in the domain of the self-adjoint Hamiltonian; the module docstring refers these spectral statements to the TODOs of `Physlib.QuantumMechanics.Hydrogen.Basic`.
- This PR does not depend on the quantisation PR; the two can be reviewed in either order.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
