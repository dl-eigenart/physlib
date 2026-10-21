# feat(QuantumMechanics): cyclic relation of angular momentum and the LRL vector

Branch: `lrl-angular-cyclic` · Base: master · Depends on: nothing open · Library: **Physlib** (not Alpha)

This PR proves that the angular momentum and the (regularised) Laplace-Runge-Lenz vector of the hydrogen atom are orthogonal in the sense of the cyclic relation `𝐋ᵢⱼ𝐀(ε)ₖ + 𝐋ⱼₖ𝐀(ε)ᵢ + 𝐋ₖᵢ𝐀(ε)ⱼ = 0`, for every dimension `d` and every `ε`. In three dimensions this is `𝐋 · 𝐀(ε) = 0` (and `𝐀(ε) · 𝐋 = 0`), the relation that, together with `lrlOperatorSqr_eq`, gives the hydrogen energies in Pauli's algebraic derivation. On the way it adds the corresponding cyclic relations for position and momentum and the fact that angular momentum commutes with the dilation operator `𝐱 · 𝐩`.

## Main results

- `HydrogenAtom.angularMomentum_cyclic_lrl`: `𝐋ᵢⱼ𝐀(ε)ₖ + 𝐋ⱼₖ𝐀(ε)ᵢ + 𝐋ₖᵢ𝐀(ε)ⱼ = 0`.
- `HydrogenAtom.lrl_cyclic_angularMomentum`: `𝐀(ε)ₖ𝐋ᵢⱼ + 𝐀(ε)ᵢ𝐋ⱼₖ + 𝐀(ε)ⱼ𝐋ₖᵢ = 0`.
- `angularMomentum_cyclic_position`, `angularMomentum_cyclic_momentum`: the same cyclic sums with `𝐱` and `𝐩` vanish.
- `angularMomentum_commutation_positionDotMomentum`: `⁅𝐋ᵢⱼ, 𝐱 · 𝐩⁆ = 0`.

## Reviewer map

1. `Physlib/QuantumMechanics/Operators/AngularMomentum.lean` §E.4 Cyclic sums and the dilation operator: three short lemmas from the existing commutators of `𝐋` with `𝐱` and `𝐩`. `angularMomentum_commutation_positionDotMomentum` is tagged `@[simp]`; PhyslibAlpha was rebuilt to check that no existing `simp` call changes.
2. `Physlib/QuantumMechanics/Hydrogen/LaplaceRungeLenzVector.lean`, `angularMomentum_cyclic_lrl`: `𝐀(ε)ₖ` is expanded with `lrlOperator_eq`; `𝐋` is moved past `𝐱 · 𝐩` and past `𝐫₀(ε)⁻¹`, leaving combinations of the two cyclic sums of step 1.
3. Same file, `lrl_cyclic_angularMomentum`: follows from the previous lemma and `angularMomentum_commutation_lrl`; the Kronecker-delta terms cancel cyclically.

## Declarations

### `Physlib/QuantumMechanics/Operators/AngularMomentum.lean`

| Declaration | Kind | Description |
|---|---|---|
| `angularMomentum_cyclic_position` | lemma | `𝐋ᵢⱼ𝐱ₖ + 𝐋ⱼₖ𝐱ᵢ + 𝐋ₖᵢ𝐱ⱼ = 0` (in `d = 3`: `𝐋 · 𝐱 = 0`). |
| `angularMomentum_cyclic_momentum` | lemma | `𝐋ᵢⱼ𝐩ₖ + 𝐋ⱼₖ𝐩ᵢ + 𝐋ₖᵢ𝐩ⱼ = 0` (in `d = 3`: `𝐋 · 𝐩 = 0`). |
| `angularMomentum_commutation_positionDotMomentum` | lemma, `@[simp]` | `⁅𝐋ᵢⱼ, 𝐱 · 𝐩⁆ = 0`. |

### `Physlib/QuantumMechanics/Hydrogen/LaplaceRungeLenzVector.lean`

| Declaration | Kind | Description |
|---|---|---|
| `HydrogenAtom.angularMomentum_cyclic_lrl` | lemma | `𝐋ᵢⱼ𝐀(ε)ₖ + 𝐋ⱼₖ𝐀(ε)ᵢ + 𝐋ₖᵢ𝐀(ε)ⱼ = 0` for all `ε`; in `d = 3` this is `𝐋 · 𝐀(ε) = 0`. |
| `HydrogenAtom.lrl_cyclic_angularMomentum` | lemma | `𝐀(ε)ₖ𝐋ᵢⱼ + 𝐀(ε)ᵢ𝐋ⱼₖ + 𝐀(ε)ⱼ𝐋ₖᵢ = 0`; in `d = 3` this is `𝐀(ε) · 𝐋 = 0`. |

## Notes

- The relations hold for the regularised operators at every `ε`, with no extra hypothesis; no separate `d = 3` corollary is added, since `(i, j, k) = (1, 2, 0)` already gives `𝐋 · 𝐀 = 0`.
- The module docstrings and table of contents of both files are updated.

---
*Draft for the human author. Check every line before posting (AI-POLICY.md §1.7). This PR touches files in `Physlib`, where review is stricter than in `PhyslibAlpha`.*
