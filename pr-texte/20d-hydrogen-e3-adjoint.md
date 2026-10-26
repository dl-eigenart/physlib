# feat(PhyslibAlpha): the hydrogen bound states are eigenvectors of the adjoint Hamiltonian

Branch: `hydrogen-e3-4` (1 commit, 741 + 1 lines) · Base: master after merge of `hydrogen-e3-3` · Depends on: `hydrogen-e3-3` (20c) and through it 20a, 20b · Library: PhyslibAlpha

Builds on #1930 (the hydrogen Hamiltonian is densely defined), merged. Last of four stacked PRs (20a–20d). Independent of #1963.

The bound states are not smooth at the nucleus, so they do not lie in the domain of `H.hamiltonianOperator`, which is defined on Schwartz maps. They satisfy the eigenvalue equation weakly, `⟪E ψ, φ⟫ = ⟪ψ, H φ⟫` for all `φ` in the domain of `H`: Green's identity (20c) for the regularised bound states `ψ_ε(y) = R(√(‖y‖² + ε²)) P(y)` and the limit `ε → 0` by dominated convergence. Since `H` is densely defined (#1930), this says that the bound states are eigenvectors of the adjoint `H†`; with 20b, in three dimensions `E_n` is an eigenvalue of `H†` of multiplicity at least `(n + 1)²`.

## Main results

- `integral_boundState_mul_hamiltonian`: Green's identity for a bound state, `∫ ψ (H f) = ∫ (H ψ) f` for every Schwartz map `f`.
- `inner_boundStateHS_hamiltonianOperator`: the weak eigenvalue equation `⟪E_{N+l} ψ, φ⟫ = ⟪ψ, H φ⟫` for every `φ` in `H.hamiltonianOperator.domain`.
- `boundStateHS_mem_adjoint_domain`, `adjoint_boundStateHS`: `ψ` lies in the domain of `H.hamiltonianOperator†` and `H† ψ = E_{N+l} ψ`; `adjoint_boundStateMapHS`: the same for every sum of bound states of one level, with eigenvalue `E_n`.
- `exists_finrank_eigenvectors_adjoint_three`, `exists_finrank_eigenvectors_adjoint_three_complex`: for `H : HydrogenAtom 3` with `k > 0`, there is a real (resp. complex) subspace of dimension `(n + 1)²` of eigenvectors of `H†` with eigenvalue `E_n`.

## Reviewer map

1. `BoundStatesAdjoint.lean` (741 lines). §A Regularised bound states and their Laplacian (`laplacian_regBoundState`). §B The weak eigenvalue equation: `integral_regBoundState_mul_sum_deriv_deriv`, then `integral_boundState_mul_sum_deriv_deriv` as the limit `ε → 0` by dominated convergence with the bound `exists_abs_laplacian_regBoundState_le`; `hamiltonianOperator_apply_ae` identifies `H φ` for `φ` in the domain. §C Eigenvectors of the adjoint. §D The whole level and the three-dimensional multiplicity.
2. `PhyslibAlpha.lean`: one added import.

## Declarations

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

---
*Draft for the human author. Check every line before posting; the author is responsible for the content (AI-POLICY.md §1.7).*

AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
