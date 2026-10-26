# feat(QuantumMechanics): Commute from a vanishing commutator, reordering of commuting operators

Branch: `opalg-commute` · Base: master · Depends on: nothing open · Library: **Physlib** (not Alpha)

This PR is a small first step towards the operator algebra automation asked for in the review of #1932. There, two local `have`s (`hxp`, `hr`) state `A ∘ (B ∘ C) = B ∘ (A ∘ C)` when `⁅A, B⁆ = 0`. Such reorderings are proved throughout the operator files by chains of `← comp_assoc`, `comp_eq_comp_add_commute`, the commutator lemma and `add_zero`.

The commutator `⁅A, B⁆` on `𝓢(Space d, ℂ) →L[ℂ] 𝓢(Space d, ℂ)` is Mathlib's ring bracket (`Ring.lie_def : ⁅x, y⁆ = x * y - y * x`), and `A * B = A ∘L B` holds by `rfl` (`ContinuousLinearMap.mul_def`). Mathlib's `commute_iff_lie_eq` therefore applies directly, and `Commute.left_comm` / `Commute.right_comm` give the reorderings. They cannot be used with `rw` or `simp` on terms written with `∘L`, because `*` and `∘L` agree only up to definitional unfolding. This PR adds the bridge and the two reordering lemmas in `∘L` form.

## Main results

- `commute_of_commutation_eq_zero`: `⁅A, B⁆ = 0 → Commute A B`.
- `Commute.comp_left_comm`: if `A` and `B` commute, then `A ∘ (B ∘ C) = B ∘ (A ∘ C)`.
- `Commute.comp_right_comm`: if `B` and `C` commute, then `(A ∘ B) ∘ C = (A ∘ C) ∘ B`.

With these, `hxp` from #1932 becomes `(commute_of_commutation_eq_zero (angularMomentum_commutation_positionDotMomentum a b)).comp_left_comm Z`, and the reordering can be passed to `rw` or `simp only` directly.

## Reviewer map

1. `Physlib/QuantumMechanics/Operators/Commutation.lean` §A General: three lemmas after `comp_eq_comp_sub_commute`, each a one-line term proof from `commute_iff_lie_eq`, `Commute.left_comm` and `Commute.right_comm`. The overview in the module docstring mentions them.

## Declarations

### `Physlib/QuantumMechanics/Operators/Commutation.lean`

| Declaration | Kind | Description |
|---|---|---|
| `commute_of_commutation_eq_zero` | lemma | Operators whose commutator vanishes commute, in the sense of `Commute`. |
| `Commute.comp_left_comm` | lemma | `Commute A B → A ∘L (B ∘L C) = B ∘L (A ∘L C)`. |
| `Commute.comp_right_comm` | lemma | `Commute B C → (A ∘L B) ∘L C = (A ∘L C) ∘L B`. |

## Notes

- No existing proof is changed. `hxp` and `hr` in `LaplaceRungeLenzVector.lean` are simplified in a follow-up commit after #1932 is merged.
- Naming: the two reordering lemmas live in the `Commute` namespace so that dot notation `h.comp_left_comm` works, although they are stated only for operators on Schwartz maps. If `ContinuousLinearMap.comp_left_comm_of_commute` (or similar) is preferred, they can be renamed.
- `commute_of_commutation_eq_zero` is `commute_iff_lie_eq.mpr`; it is added under a physlib name for discoverability, next to `comp_eq_comp_add_commute`. PhyslibAlpha has an analogous `commute_of_lie_eq_zero` for `Module.End` in `Sl2/BivariateBasis.lean`.
- Not tagged `@[simp]`: as permutation lemmas they are meant as explicit `simp` arguments.

---
*Draft for the human author. Check every line before posting (AI-POLICY.md §1.7). This PR touches files in `Physlib`, where review is stricter than in `PhyslibAlpha`.*

AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
