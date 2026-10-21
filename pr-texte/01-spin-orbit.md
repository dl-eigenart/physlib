# feat(PhyslibAlpha): spin-orbit coupling

Branch: `pr/spin-orbit` · Base: master · Depends on: nothing, applies to master

This PR adds the operator `L · S = Lx ⊗ Sx + Ly ⊗ Sy + Lz ⊗ Sz` on the tensor product of two angular momentum representations and computes its eigenvalues on `V(m) ⊗ V(n)`. From `J² = L² + S² + 2 L · S` and the Casimir value `j(j + 1)` on `V(2j)`, every vector of the `k`-th lowering string, of total angular momentum `J = (m + n)/2 - k`, is an eigenvector of `L · S` with eigenvalue `(J(J + 1) - l(l + 1) - s(s + 1))/2`. As consequences it records the fine-structure doublet for spin `1/2` and Landé's interval rule.

## Main results

- `AngularMomentumRepresentation.Jsq_tensor`: `J² = L² ⊗ 1 + 1 ⊗ S² + 2 L · S` for the tensor product representation.
- `AngularMomentumRepresentation.Jsq_standard`: `J² = (n/2)(n/2 + 1)` on `V(n)`.
- `dot_coupled_stringVec`: for `0 < m + n`, `k ≤ m`, `k ≤ n`, `L · S` acts on `stringVec m n k l` by `spinOrbitValue m n k`.
- `dot_coupled_stringVec_doublet_upper`, `dot_coupled_stringVec_doublet_lower`: for `s = 1/2`, `L · S = m/4 = l/2` on `J = l + 1/2` and `L · S = -(m + 2)/4 = -(l + 1)/2` on `J = l - 1/2`.
- `spinOrbitValue_sub_succ`: the values for `J` and `J - 1` differ by `J`.

## Reviewer map

1. `PhyslibAlpha/QuantumMechanics/AngularMomentum/SpinOrbit.lean` §A The scalar product of two angular momenta: the definition of `dot` and the pure-tensor proof of `Jsq_tensor`.
2. `PhyslibAlpha/QuantumMechanics/AngularMomentum/SpinOrbit.lean` §B The Casimir operator of `V(n)`: `Jsq_standard`, checked on the basis `vNat`.
3. `PhyslibAlpha/QuantumMechanics/AngularMomentum/SpinOrbit.lean` §C Eigenvalues of `L · S`: the definition of `spinOrbitValue` (natural subtraction `m + n - 2 * k`) and the hypotheses of `dot_coupled_stringVec`.
4. `PhyslibAlpha/QuantumMechanics/AngularMomentum/SpinOrbit.lean` §D Fine structure and the interval rule: the specialisations to `n = 1` and the interval rule.
5. `PhyslibAlpha.lean`: the added import.

## Declarations

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/SpinOrbit.lean`

| Declaration | Kind | Description |
|---|---|---|
| `PhyslibAlpha.Sl2.AngularMomentumRepresentation.dot` | def | The operator `L · S = Lx ⊗ Sx + Ly ⊗ Sy + Lz ⊗ Sz` on `V ⊗ W`. |
| `PhyslibAlpha.Sl2.AngularMomentumRepresentation.Jsq_tensor` | lemma | `J²` of the tensor product equals `L².rTensor W + S².lTensor V + 2 • dot`. |
| `PhyslibAlpha.Sl2.AngularMomentumRepresentation.Jsq_standard` | lemma | `J² = (n/2)(n/2 + 1) • 1` on `StandardSl2Module ℂ n`. |
| `PhyslibAlpha.Sl2.spinOrbitValue` | def | The number `(J(J + 1) - l(l + 1) - s(s + 1))/2` for `l = m/2`, `s = n/2`, `J = (m + n)/2 - k`. |
| `PhyslibAlpha.Sl2.dot_coupled_stringVec` | lemma | `L · S` acts on the `k`-th lowering string of `V(m) ⊗ V(n)` by `spinOrbitValue m n k`. |
| `PhyslibAlpha.Sl2.dot_coupled_stringVec_doublet_upper` | lemma | For `n = 1`, `k = 0`, the eigenvalue is `m/4`, i.e. `l/2` for `J = l + 1/2`. |
| `PhyslibAlpha.Sl2.dot_coupled_stringVec_doublet_lower` | lemma | For `n = 1`, `k = 1`, `m ≥ 1`, the eigenvalue is `-(m + 2)/4`, i.e. `-(l + 1)/2` for `J = l - 1/2`. |
| `PhyslibAlpha.Sl2.spinOrbitValue_doublet_sub` | lemma | `spinOrbitValue m 1 0 - spinOrbitValue m 1 1 = (m + 1)/2`, the doublet splitting `(2l + 1)/2`. |
| `PhyslibAlpha.Sl2.spinOrbitValue_sub_succ` | lemma | Landé's interval rule: `spinOrbitValue m n k - spinOrbitValue m n (k + 1) = (m + n - 2k)/2 = J`. |

## Notes

- The eigenvalue statements are proved for the vectors `stringVec m n k l` of the standard representations `V(m) ⊗ V(n)`, under `0 < m + n`, `k ≤ m` and `k ≤ n`; they rely on `Jsq_coupled_stringVec` from `AngularMomentum/Addition.lean`.
- The spin-orbit Hamiltonian `ζ L · S` appears only in the module docstring; the file states results for `L · S` itself.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
