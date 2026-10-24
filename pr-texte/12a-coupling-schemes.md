# feat(PhyslibAlpha): the two coupling schemes of three angular momenta

Branch: `pr/coupling-schemes` · Base: master after merge of `pr/clebsch-gordan-formula` · Depends on: `pr/clebsch-gordan-formula` (#1911 and #1876 are merged; independent of `pr/wigner-3j`)

This PR constructs the two coupling schemes `|(j₁ j₂) j₁₂, j₃; J M⟩` and `|j₁, (j₂ j₃) j₂₃; J M⟩` on `V(a) ⊗ V(b) ⊗ V(c)`. It repackages the isomorphism `cgEquiv` as isometric intertwining embeddings `embed : V(m + n - 2k) → V(m) ⊗ V(n)` of the irreducible components, introduces the triple tensor product with its contravariant form, total `E`, `F`, `H` and Casimir operator, and shows that these structures are transported through both schemes. The recoupling coefficients and 6j symbols follow in the next PR (`pr/six-j`).

## Main results

- `tensorForm_embed`, `tensorForm_embed_of_ne`: `embed` is an isometry, and different components are orthogonal.
- `tensorF_embed`, `tensorE_embed`, `tensorH_embed`: `embed` intertwines `E`, `F`, `H`.
- `tripleForm_tripleF`, `tripleForm_tripleE`, `tripleForm_tripleH`, `tripleForm_tripleCas`: adjointness on the triple product.
- `tensorCas_stringVec`: the Casimir eigenvalue `N(N + 2)/2` on the `k`-th lowering string.
- `stateA`, `stateB` with `tripleForm_rTensor_embed` and `tripleForm_assocEmbed`: the two schemes, isometrically embedded.

## Reviewer map

1. `CouplingSchemes.lean` §A The irreducible components as isometric embeddings: the normalisation `(√hwNormSq)⁻¹` in `embed`, `embed_normVec` (`u_l` normalised goes to `coupledVec`), and the three intertwining lemmas.
2. `CouplingSchemes.lean` §B The triple tensor product: `Triple` is bracketed as `(V(a) ⊗ V(b)) ⊗ V(c)`; check the adjointness lemmas `tripleForm_tripleF`, `tripleForm_tripleE`, `tripleForm_tripleH` and the `…_assoc_symm` lemmas for the other bracketing.
3. `CouplingSchemes.lean` §C The Casimir operator: `tensorCas` and `tripleCas` are `2 J²`; `tensorCas_stringVec` gives the eigenvalue `N(N + 2)/2`.
4. `CouplingSchemes.lean` §D The two coupling schemes: the index conventions of `stateA` (`k₁, k₂, l`) and `stateB` (`k₃, k₄, l`), and the transport of `E, F, H`, the Casimir and the form through `rTensor embed` and `assocEmbed`.
5. `PhyslibAlpha.lean`: the added import.

## Declarations

All declarations are in the namespace `PhyslibAlpha.Sl2`.

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/CouplingSchemes.lean`

| Declaration | Kind | Description |
|---|---|---|
| `embed` | def | The embedding `V(m + n - 2k) → V(m) ⊗ V(n)` onto the `k`-th component, `(√hwNormSq)⁻¹ · cgEquiv⁻¹ ∘ lof k`. |
| `cgEquiv_symm_sumVec` | lemma | `cgEquiv⁻¹` sends `u_l` in the `k`-th summand to `stringVec m n k l`. |
| `embed_vNat` | lemma | `embed (vNat l) = (√hwNormSq)⁻¹ • stringVec m n k l`. |
| `embed_normVec` | lemma | `embed (normVec l) = coupledVec m n k l`. |
| `tensorF_embed` | lemma | `embed` intertwines `ρF` and `tensorF`. |
| `tensorE_embed` | lemma | `embed` intertwines `ρE` and `tensorE`. |
| `tensorH_embed` | lemma | `embed` intertwines `ρH` and `tensorH`. |
| `tensorForm_embed` | lemma | `tensorForm (embed x) (embed y) = invForm x y`. |
| `tensorForm_embed_of_ne` | lemma | Images of `embed` for `k ≠ k'` are orthogonal under `tensorForm`. |
| `Triple` | abbrev | `(V(a) ⊗ V(b)) ⊗ V(c)`. |
| `tripleForm` | def | The contravariant form `tensorForm a b ⊗ invForm c` on `Triple a b c`. |
| `tripleE` | def | The total raising operator on `Triple a b c`. |
| `tripleF` | def | The total lowering operator on `Triple a b c`. |
| `tripleH` | def | The total weight operator on `Triple a b c`. |
| `tripleForm_tmul` | lemma | `tripleForm (x ⊗ y) (x' ⊗ y') = tensorForm x x' · invForm y y'`. |
| `tripleBilin_ext` | lemma | Two bilinear forms on `Triple a b c` agree if they agree on pure tensors `(x ⊗ y) ⊗ z`. |
| `invForm_ρF_apply` | lemma | `invForm (ρF x) y = invForm x (ρE y)`. |
| `tripleForm_tripleF` | lemma | `tripleF` is adjoint to `tripleE` for `tripleForm`. |
| `tripleForm_tripleE` | lemma | `tripleE` is adjoint to `tripleF` for `tripleForm`. |
| `tripleForm_tripleH` | lemma | `tripleH` is self-adjoint for `tripleForm`. |
| `tripleForm_assoc_symm` | lemma | `tripleForm` in the bracketing `V(a) ⊗ (V(b) ⊗ V(c))` is `invForm a · tensorForm b c`. |
| `tripleF_assoc_symm` | lemma | `tripleF` in the bracketing `V(a) ⊗ (V(b) ⊗ V(c))` is `ρF ⊗ 1 + 1 ⊗ tensorF`. |
| `tripleE_assoc_symm` | lemma | `tripleE` in the bracketing `V(a) ⊗ (V(b) ⊗ V(c))` is `ρE ⊗ 1 + 1 ⊗ tensorE`. |
| `tripleH_assoc_symm` | lemma | `tripleH` in the bracketing `V(a) ⊗ (V(b) ⊗ V(c))` is `ρH ⊗ 1 + 1 ⊗ tensorH`. |
| `tripleForm_comm` | lemma | `tripleForm` is symmetric. |
| `tensorCas` | def | `2 J² = E F + F E + H²/2` on `V(m) ⊗ V(n)`. |
| `tensorCas_stringVec` | lemma | `tensorCas (stringVec m n k l) = N(N + 2)/2 • stringVec m n k l`, `N = m + n - 2k`. |
| `tensorCas_coupledVec` | lemma | The same eigenvalue equation for `coupledVec`. |
| `tripleCas` | def | `2 J²` on `Triple a b c`. |
| `tripleForm_tripleCas` | lemma | `tripleCas` is self-adjoint for `tripleForm`. |
| `stateA` | def | `\|(j₁ j₂) j₁₂, j₃; J M⟩ = (embed k₁ ⊗ 1)(coupledVec (a + b - 2k₁) c k₂ l)`. |
| `assocEmbed` | def | `V(a) ⊗ V(b + c - 2k₃) → Triple a b c`, `1 ⊗ embed k₃` followed by the associator. |
| `stateB` | def | `\|j₁, (j₂ j₃) j₂₃; J M⟩ = assocEmbed k₃ (coupledVec a (b + c - 2k₃) k₄ l)`. |
| `tripleF_rTensor_embed` | lemma | `tripleF ∘ (embed ⊗ 1) = (embed ⊗ 1) ∘ tensorF`. |
| `tripleE_rTensor_embed` | lemma | `tripleE ∘ (embed ⊗ 1) = (embed ⊗ 1) ∘ tensorE`. |
| `tripleH_rTensor_embed` | lemma | `tripleH ∘ (embed ⊗ 1) = (embed ⊗ 1) ∘ tensorH`. |
| `tripleCas_rTensor_embed` | lemma | `tripleCas ∘ (embed ⊗ 1) = (embed ⊗ 1) ∘ tensorCas`. |
| `tripleForm_rTensor_embed` | lemma | `embed ⊗ 1` is an isometry from `tensorForm` to `tripleForm`. |
| `tripleForm_rTensor_embed_of_ne` | lemma | Images of `embed k₁ ⊗ 1` and `embed k₁' ⊗ 1` are orthogonal for `k₁ ≠ k₁'`. |
| `tripleF_assocEmbed` | lemma | `assocEmbed` intertwines `tensorF` and `tripleF`. |
| `tripleE_assocEmbed` | lemma | `assocEmbed` intertwines `tensorE` and `tripleE`. |
| `tripleH_assocEmbed` | lemma | `assocEmbed` intertwines `tensorH` and `tripleH`. |
| `tripleCas_assocEmbed` | lemma | `assocEmbed` intertwines `tensorCas` and `tripleCas`. |
| `tripleForm_assocEmbed` | lemma | `assocEmbed` is an isometry from `tensorForm` to `tripleForm`. |
| `tripleForm_assocEmbed_of_ne` | lemma | Images of `assocEmbed k₃` and `assocEmbed k₃'` are orthogonal for `k₃ ≠ k₃'`. |

## Notes

- Spins are doubled: `j₁ = a/2`, `j₂ = b/2`, `j₃ = c/2`.
- `invForm_ρF_apply` is a general auxiliary result.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
