# feat(PhyslibAlpha): degeneracy of the Bohr levels from Pauli's two su(2)

Branch: `hydrogen-pauli-degeneracy` (1 commit) · Base: master · Depends on: nothing open · Library: PhyslibAlpha

Builds on #1933 (Pauli's algebraic derivation of the hydrogen spectrum) and #1818 (sl2 representation theory), both merged.

#1933 shows that a nonzero finite-dimensional eigenspace of the Hamiltonian of a `PauliSystem` with eigenvalue `E < 0` has `E` equal to a Bohr level. This PR adds the degeneracy: such an eigenspace has dimension at least `(n + 1)²`, where `E = Hy.energyLevel n`. The two copies `J₊ = (L + K)/2` and `J₋ = (L - K)/2` of `su(2)` from #1933 commute and have the same Casimir. A common primitive vector of both therefore has the same highest weight `n`, and its lowering grid `f₊ᵃ f₋ᵇ m₀` (`a, b ≤ n`) consists of `(n + 1)²` linearly independent vectors. Complete reducibility is not needed; the grid argument uses `Sl2.exists_joint_primitive` and `Sl2.grid_linearIndependent` from `BivariateBasis.lean` (#1818).

## Main results

- `PauliSystem.exists_energyLevel_le_finrank`: a nonzero finite-dimensional eigenspace of `H` with eigenvalue `E < 0` has `E = Hy.energyLevel n` and dimension at least `(n + 1)²`, for some `n`.
- `PauliSystem.exists_energyLevel_le_finrank_of_H_eq`: the same on a nonzero finite-dimensional space on which `H = E < 0`.
- `PauliSystem.comm_J_neg`: `[J(κ)ᵢ, J(-κ)ⱼ] = 0` on a space where `H = E < 0`, for `κ² = -2mE`; `PauliSystem.plusRep_comm_minusRep`: the `sl₂` triples of `J₊` and `J₋` commute.

## Reviewer map

All changes are in `PhyslibAlpha/QuantumMechanics/Hydrogen/PauliSpectrum.lean` (131 lines added, 9 removed).

1. §B, after `minusRep_Jsq`: `comm_J_neg_succ` computes `[J(κ)ᵢ, J(-κ)ᵢ₊₁]` from the relations of `PauliSystem` (`match_scalars`, then `field_simp`/`ring` using `κ² = -2mE`); `comm_J_neg` reduces all `(i, j)` to this case and the diagonal; `plusRep_comm_minusRep` restates it for the triples `(2 Jz, Jp, Jm)`, the form needed by `Sl2.exists_joint_primitive`.
2. §C: the Casimir computation at the end of `exists_energyLevel_of_H_eq` is moved into its own lemma `eq_energyLevel_of_casimir`; `exists_energyLevel_of_H_eq` now calls it. Its statement is unchanged.
3. §D (new) The degeneracy: `exists_energyLevel_le_finrank_of_H_eq`. If `Jz` of `J₊` or `J₋` vanishes, the Casimir is `0`, so `n = 0` and `1 ≤ dim`. Otherwise `Sl2.exists_joint_primitive` gives a common primitive vector `m₀` with highest weights `n₁`, `n₂`; equal Casimirs give `n₁ = n₂`; `Sl2.grid_linearIndependent` gives `(n₁ + 1)²` independent vectors. `exists_energyLevel_le_finrank` restricts to the eigenspace via `restrictEigenspace`, as `exists_energyLevel` does.
4. Module docstring: overview, key results and table of contents updated; one added import (`PhyslibAlpha.Mathematics.RepresentationTheory.Sl2.BivariateBasis`).

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/PauliSpectrum.lean` (new declarations)

All declarations are in the namespace `PhyslibAlpha.Hydrogen.PauliSystem`.

| Declaration | Kind | Description |
|---|---|---|
| `comm_J_neg_succ` | lemma | `[J(κ)ᵢ, J(-κ)ᵢ₊₁] = 0` on a space where `H = E < 0`, for `κ² = -2mE`. |
| `comm_J_neg` | lemma | `[J(κ)ᵢ, J(-κ)ⱼ] = 0` on a space where `H = E < 0`, for `κ² = -2mE`. |
| `plusRep_comm_minusRep` | lemma | The `sl₂` triples of `J₊` and `J₋` commute. |
| `eq_energyLevel_of_casimir` | lemma | If the Casimir `(-ℏ² - m k² / (2E)) / (4ℏ²)` equals `j(j+1)` with `n = 2j`, then `E` is the Bohr level `E = -m k² / (2 ℏ² (n + 1)²)`. |
| `exists_energyLevel_le_finrank_of_H_eq` | lemma | On a nonzero finite-dimensional space on which `H = E < 0`, `E` is a Bohr level `E = -m k² / (2 ℏ² (n + 1)²)` and the space has dimension at least `(n + 1)²`. |
| `exists_energyLevel_le_finrank` | lemma | **Degeneracy of the Bohr levels.** A nonzero finite-dimensional eigenspace of the Hamiltonian with eigenvalue `E < 0` has `E = -m k² / (2 ℏ² (n + 1)²)` and dimension at least `(n + 1)²`. |

## Notes

- Only the lower bound `(n + 1)²` is shown. That the dimension is a multiple of `(n + 1)²` would need complete reducibility of the `sl₂ × sl₂` action, which is available neither in Mathlib nor here.
- `exists_energyLevel_le_finrank` is a `lemma` and is not added to `Theorems.txt`; `exists_energyLevel` from #1933 stays the listed theorem.
- The result is purely algebraic. Together with the analytic statement in `BoundStatesAdjoint.lean` (separate PR), which gives at least `(n + 1)²` eigenvectors of the adjoint Hamiltonian in `L²`, the two bounds come from independent arguments; no connection between them is formalised.

---
*Draft for the human author. Check every line before posting; the author is responsible for the content (AI-POLICY.md §1.7).*

AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
