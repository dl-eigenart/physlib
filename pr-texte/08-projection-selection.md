# feat(PhyslibAlpha): consequences of the sl2 Wigner-Eckart theorem

Branch: `pr/projection-selection` · Base: master after merge of #1876 · Depends on: #1876

This PR derives three consequences of the Wigner-Eckart theorem for `sl₂` from #1876
(`WignerEckart.lean`). Tensor operators of rank `k` from `V(m)` to `V(p)` are unique up to a
scalar, so every vector operator on `V(n)` is a multiple of the `sl₂` action (projection theorem).
A nonzero tensor operator satisfies the triangle rule, which together with a parity rule gives the
selection rules for electromagnetic multipole transitions. Finally, both results are transported
to finite-dimensional irreducible angular momentum representations by conjugating with an
isomorphism to a standard module.

## Main results

- `IsTensorOperator.exists_eq_smul_of_ne_zero`: if `T, S` are tensor operators of rank `k` from `V(m)` to `V(p)` and `S ≠ 0`, then `T = c • S` for some `c`.
- `IsTensorOperator.exists_eq_smul_sl2Operator`: every rank-2 tensor operator `T` on `V(n)` satisfies `T = c • sl2Operator n` (projection theorem).
- `IsTensorOperator.triangleRule`: a nonzero tensor operator of rank `k` from `V(m)` to `V(p)` satisfies `TriangleRule k m p`.
- `parity_eq_of_ne_zero`: if `π_f • T = π_T • πᵢ • T` and `T ≠ 0`, then `π_f = π_T * πᵢ`.
- `AngularMomentumRepresentation.IsTensorOperatorOf.exists_eq_smul_of_ne_zero`: two tensor operators of the same rank between the same finite-dimensional irreducible representations with `Jz ≠ 0` are proportional.
- `AngularMomentumRepresentation.IsTensorOperatorOf.triangleRule`: a nonzero tensor operator between representations isomorphic to `V(n₁)` and `V(n₂)` satisfies `TriangleRule k n₁ n₂`.

## Reviewer map

1. `ProjectionTheorem.lean` §A Uniqueness up to a scalar: the case split on whether `p` occurs in `V(m) ⊗ V(n)`, using `exists_eq_smul_cgProj` and `eq_zero_of_forall_ne` from #1876.
2. `ProjectionTheorem.lean` §B.1 Definition and values: the sign and normalisation convention `v_0 ↦ e`, `v_1 ↦ -h`, `v_2 ↦ -2f` in `sl2Operator`.
3. `ProjectionTheorem.lean` §B.2 Commutation relations: `ρE_mul_ρF'`, `ρH_mul_ρE'`, `ρH_mul_ρF'` restate `rel_ef`, `rel_he`, `rel_hf` as products in `Module.End`; check whether they belong next to `StandardSl2Module`. The case analysis in `isTensorOperator_sl2Operator` is the longest proof of the file.
4. `ProjectionTheorem.lean` §C The projection theorem: the case `n = 0`, where `T = 0` is shown directly.
5. `SelectionRules.lean` §A The triangle rule: `TriangleRule` and its equivalence with the condition `∃ j, k + m - 2j = p` of #1876.
6. `SelectionRules.lean` §B Parity and multipole transitions: the definitions `MultipoleType.parity` and `IsAllowedMultipole`; the multipole parities are taken as input.
7. `SelectionRules.lean` §C Example: the decay of the ¹⁷⁸ᵐ²Hf isomer: the spin and parity data in doubled units against the cited ENSDF evaluation; all proofs are `decide`.
8. `WignerEckartIrreducible.lean` §A Comparison with the standard modules: `exists_isStandardEquiv` extracts from `spin_classification` a linear equivalence intertwining `J₊, J₋, 2Jz` with `e, f, h`.
9. `WignerEckartIrreducible.lean` §B Tensor operators between representations: the definition `IsTensorOperatorOf` and the transport lemma `isTensorOperator_conjStd`.
10. `WignerEckartIrreducible.lean` §C The Wigner-Eckart theorem: the two main statements and their hypotheses.

## Declarations

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/ProjectionTheorem.lean`

| Declaration | Kind | Description |
|---|---|---|
| `IsTensorIntertwiner.exists_eq_smul_of_ne_zero` | lemma | Two tensor intertwiners `V(m) ⊗ V(n) → V(p)` with `ψ ≠ 0` satisfy `φ = c • ψ`, for `0 < m + n`. |
| `IsTensorOperator.exists_eq_smul_of_ne_zero` | lemma | Two tensor operators of rank `k` from `V(m)` to `V(p)` with `S ≠ 0` satisfy `T = c • S`, for `0 < k + m`. |
| `sl2Operator` | def | The `sl₂` action on `V(n)` as a map `V(2) → End(V(n))`: `v_0 ↦ e`, `v_1 ↦ -h`, `v_2 ↦ -2f`. |
| `sl2Operator_vNat_zero` | lemma | `sl2Operator n v_0 = e`. |
| `sl2Operator_vNat_one` | lemma | `sl2Operator n v_1 = -h`. |
| `sl2Operator_vNat_two` | lemma | `sl2Operator n v_2 = -2f`. |
| `sl2Operator_vNat_of_lt` | lemma | `sl2Operator n v_l = 0` for `l > 2`. |
| `ρE_mul_ρF'` | lemma | `e * f = f * e + h` in `End(V(n))`. |
| `ρH_mul_ρE'` | lemma | `h * e = e * h + 2e`. |
| `ρH_mul_ρF'` | lemma | `h * f = f * h - 2f`. |
| `ρE_vNat_two_one` | lemma | `e v_1 = 2 v_0` in `V(2)`. |
| `ρE_vNat_two_two` | lemma | `e v_2 = 2 v_1` in `V(2)`. |
| `ρH_vNat_two_zero` | lemma | `h v_0 = 2 v_0` in `V(2)`. |
| `ρH_vNat_two_one` | lemma | `h v_1 = 0` in `V(2)`. |
| `ρH_vNat_two_two` | lemma | `h v_2 = -2 v_2` in `V(2)`. |
| `comm_of_vNat` | lemma | A relation `Y ∘ A x - A x ∘ Y = A (X x)` holds for all `x` once it holds on the basis vectors `v_l`. |
| `isTensorOperator_sl2Operator` | lemma | `sl2Operator n` is a tensor operator of rank 2. |
| `sl2Operator_ne_zero` | lemma | `sl2Operator n ≠ 0` for `n > 0`. |
| `IsTensorOperator.exists_eq_smul_sl2Operator` | lemma | Projection theorem: every rank-2 tensor operator on `V(n)` equals `c • sl2Operator n`. |

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/SelectionRules.lean`

| Declaration | Kind | Description |
|---|---|---|
| `TriangleRule` | def | `p ≤ k + m`, `k ≤ m + p`, `m ≤ k + p` and `k + m + p` even (triangle rule in doubled units). |
| `instance : Decidable (TriangleRule k m p)` | instance | Decidability of `TriangleRule`. |
| `exists_eq_iff_triangleRule` | lemma | `(∃ j ≤ min k m, k + m - 2j = p) ↔ TriangleRule k m p`. |
| `IsTensorOperator.triangleRule` | lemma | A nonzero tensor operator of rank `k` from `V(m)` to `V(p)` satisfies `TriangleRule k m p`, for `0 < k + m`. |
| `parity_eq_of_ne_zero` | lemma | Parity rule: `π_f • T = π_T • πᵢ • T` and `T ≠ 0` imply `π_f = π_T * πᵢ`. |
| `MultipoleType` | inductive | Electric or magnetic multipole, constructors `electric`, `magnetic`. |
| `MultipoleType.parity` | def | Parity `(-1)^λ` of `Eλ` and `(-1)^(λ+1)` of `Mλ`. |
| `IsAllowedMultipole` | def | `l ≥ 1`, `TriangleRule (2l) twoIi twoIf` and `π_f = t.parity l * πᵢ`. |
| `instance : Decidable (IsAllowedMultipole twoIi twoIf πi πf t l)` | instance | Decidability of `IsAllowedMultipole`. |
| `hf178_primary_branches_allowed` | lemma | The branches `16⁺ → 13⁻` (`E3`), `16⁺ → 12⁻` (`M4`), `16⁺ → 11⁻` (`E5`) are allowed. |
| `hf178_E3_lowest` | lemma | No multipole of order `< 3` is allowed for `16⁺ → 13⁻`. |
| `hf178_M4_lowest` | lemma | No multipole of order `< 4` is allowed for `16⁺ → 12⁻`, and `E4` is forbidden. |
| `hf178_E5_lowest` | lemma | No multipole of order `< 5` is allowed for `16⁺ → 11⁻`, and `M5` is forbidden. |
| `hf178_E1_8minus` | lemma | `8⁻ → 8⁺` is allowed as `E1` and forbidden as `M1`. |

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/WignerEckartIrreducible.lean`

| Declaration | Kind | Description |
|---|---|---|
| `standard_bracket_eSub` | lemma | In the Lie module structure on `V(n)` given by an `sl₂` triple, `⁅eSub t, w⁆ = e w`. |
| `standard_bracket_fSub` | lemma | Same for `fSub` and `f`. |
| `standard_bracket_hSub` | lemma | Same for `hSub` and `h`. |
| `AngularMomentumRepresentation.IsStandardEquiv` | structure | A linear equivalence `ψ : V ≃ V(n)` with `ψ ∘ J₊ = e ∘ ψ`, `ψ ∘ J₋ = f ∘ ψ`, `ψ ∘ 2Jz = h ∘ ψ`. |
| `AngularMomentumRepresentation.exists_isStandardEquiv` | lemma | A finite-dimensional irreducible representation with `Jz ≠ 0` has a standard equivalence to some `V(n)`. |
| `AngularMomentumRepresentation.IsStandardEquiv.pos` | lemma | If `Jz ≠ 0`, a standard equivalence lands in `V(n)` with `n > 0`. |
| `AngularMomentumRepresentation.IsStandardEquiv.symm_ρE` | lemma | `ψ⁻¹ (e y) = J₊ (ψ⁻¹ y)`. |
| `AngularMomentumRepresentation.IsStandardEquiv.symm_ρF` | lemma | `ψ⁻¹ (f y) = J₋ (ψ⁻¹ y)`. |
| `AngularMomentumRepresentation.IsStandardEquiv.symm_ρH` | lemma | `ψ⁻¹ (h y) = 2Jz (ψ⁻¹ y)`. |
| `AngularMomentumRepresentation.IsTensorOperatorOf` | structure | A map `T : V(k) → Hom(V, W)` with `[J₊, T x] = T (e x)`, `[J₋, T x] = T (f x)`, `[2Jz, T x] = T (h x)`. |
| `AngularMomentumRepresentation.conjStd` | def | Conjugation `T ↦ ψ₂ ∘ T x ∘ ψ₁⁻¹` by equivalences `V ≃ V(n₁)`, `W ≃ V(n₂)`. |
| `AngularMomentumRepresentation.conjStd_apply` | lemma | `conjStd ψ₁ ψ₂ T x y = ψ₂ (T x (ψ₁⁻¹ y))`. |
| `AngularMomentumRepresentation.conjStd_injective` | lemma | `conjStd ψ₁ ψ₂` is injective. |
| `AngularMomentumRepresentation.IsTensorOperatorOf.isTensorOperator_conjStd` | lemma | Conjugation by standard equivalences sends tensor operators between representations to tensor operators between standard modules. |
| `AngularMomentumRepresentation.IsTensorOperatorOf.conjStd_zero` | lemma | `conjStd ψ₁ ψ₂ 0 = 0`. |
| `AngularMomentumRepresentation.IsTensorOperatorOf.triangleRule` | lemma | A nonzero tensor operator from `ρ₁ ≅ V(n₁)` to `ρ₂ ≅ V(n₂)` with `ρ₁.Jz ≠ 0` satisfies `TriangleRule k n₁ n₂`. |
| `AngularMomentumRepresentation.IsTensorOperatorOf.exists_eq_smul_of_ne_zero` | lemma | Wigner-Eckart theorem for finite-dimensional irreducible representations with `Jz ≠ 0`: `T = c • S` if `S ≠ 0`. |

## Notes

- All names are in the namespace `PhyslibAlpha.Sl2`.
- `sl2Operator` gives the spherical components of `J` only up to normalisation. The formula `c = ⟨J · V⟩ / (j(j+1))` for the scalar in the projection theorem is not proved.
- That a photon of order `λ` has `λ ≥ 1` and that `Eλ`, `Mλ` have parities `(-1)^λ`, `(-1)^(λ+1)` is built into `IsAllowedMultipole` as input. The hindrance of the ¹⁷⁸Hf transitions by the `K` quantum number is not treated.
- In `WignerEckartIrreducible.lean` the spin-0 representation (`Jz = 0`) is excluded throughout, and the scalars are `ℂ`.
- `IsTensorOperatorOf.conjStd_zero` lies in the namespace `IsTensorOperatorOf` but does not mention the predicate.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
