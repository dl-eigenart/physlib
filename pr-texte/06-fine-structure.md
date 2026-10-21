# feat(PhyslibAlpha): fine structure of hydrogen

Branch: `pr/fine-structure` · Base: master, after the spin-orbit and radial functions PRs are merged · Depends on: #1899 (spin-orbit coupling), `pr/hydrogen-radial` (radial functions of the hydrogen atom), and through it #1900

This PR defines the three first-order fine-structure corrections of the hydrogen level `(ν, l)`, relativistic kinetic, spin-orbit and Darwin, in terms of the radial expectation values `⟨1/ρ⟩`, `⟨1/ρ²⟩`, `⟨1/ρ³⟩` and `|R(0)|²`, and proves that their sum equals `E_ν α²/ν² (ν/(j + 1/2) - 3/4)` for `j = l ± 1/2`. Consequently the levels `(ν, l, l + 1/2)` and `(ν, l + 1, l + 1/2)` have the same shift. It builds on the radial integrals of `RadialFunctions.lean` and on the `L · S` eigenvalues `Sl2.spinOrbitValue` of `SpinOrbit.lean`.

## Main results

- `fineStructureShift_upper`: for `d = 3`, `k > 0`, `l < ν` and `ls` equal to the `L · S` eigenvalue on `j = l + 1/2`, the shift is `E_ν α²/ν² (ν/(j + 1/2) - 3/4)`; this includes `l = 0`, where the Darwin term replaces the spin-orbit term.
- `fineStructureShift_lower`: the same formula for `j = l - 1/2`, `1 ≤ l < ν`.
- `fineStructureShift_upper_eq_lower`: for `l + 1 < ν` the shifts of `(ν, l, j = l + 1/2)` and `(ν, l + 1, j = l + 1/2)` coincide; for `ν = 2`, `l = 0` this is the degeneracy of `2s_{1/2}` and `2p_{1/2}`.

## Reviewer map

Only the last commit, `feat(PhyslibAlpha): fine structure of hydrogen`, is new; the earlier commits belong to the PRs listed above.

1. `PhyslibAlpha/QuantumMechanics/Hydrogen/FineStructure.lean` §A The three first-order corrections: check that `relativisticShift`, `spinOrbitShift` and `darwinShift` are the stated physical formulas, including the factors of the Bohr radius and the normalisation `radialMoment ν 0 0` in the Darwin term.
2. `PhyslibAlpha/QuantumMechanics/Hydrogen/FineStructure.lean` §B The fine-structure formula: the helper lemmas `levelIndex_sub_one`, `ls_upper`, `ls_lower`, then the case split `l = 0` / `l ≥ 1` in `fineStructureShift_upper` and the hypotheses on `ls`.
3. `PhyslibAlpha.lean`: the added import.

## Declarations

### `PhyslibAlpha/QuantumMechanics/Hydrogen/FineStructure.lean`

| Declaration | Kind | Description |
|---|---|---|
| `PhyslibAlpha.Hydrogen.fineStructureConstant` | def | The fine-structure constant `α = k/(ℏ c)` of the atom. |
| `PhyslibAlpha.Hydrogen.relativisticShift` | def | `-(E² + 2 E k ⟨1/r⟩ + k² ⟨1/r²⟩)/(2 m c²)`, i.e. `-⟨(E - V)²⟩/(2 m c²)` with `V = -k/r`, in the state `(ν, l)`. |
| `PhyslibAlpha.Hydrogen.spinOrbitShift` | def | `k ℏ² ls/(2 m² c²) · ⟨1/r³⟩`, the spin-orbit correction with `⟨L · S⟩ = ℏ² ls`. |
| `PhyslibAlpha.Hydrogen.darwinShift` | def | For `l = 0`, `k ℏ²/(8 m² c²) · \|R(0)\|²/‖u‖²/a³`, i.e. `π k ℏ²/(2 m² c²) \|ψ(0)\|²`; zero for `l ≠ 0`. |
| `PhyslibAlpha.Hydrogen.fineStructureShift` | def | The sum of the three corrections for the level `(ν, l)` with `⟨L · S⟩ = ℏ² ls`. |
| `PhyslibAlpha.Hydrogen.levelIndex_sub_one` | lemma | For `d = 3` and `ν ≥ 1`, `H.levelIndex (ν - 1) = ν`. |
| `PhyslibAlpha.Hydrogen.ls_upper` | lemma | If `ls = Sl2.spinOrbitValue (2l) 1 0` in `ℂ`, then `ls = l/2`. |
| `PhyslibAlpha.Hydrogen.ls_lower` | lemma | For `l ≥ 1`, if `ls = Sl2.spinOrbitValue (2l) 1 1` in `ℂ`, then `ls = -(l + 1)/2`. |
| `PhyslibAlpha.Hydrogen.fineStructureShift_upper` | lemma | For `j = l + 1/2` the shift equals `E_ν α²/ν² (ν/(j + 1/2) - 3/4)`. |
| `PhyslibAlpha.Hydrogen.fineStructureShift_lower` | lemma | For `j = l - 1/2`, `l ≥ 1`, the shift equals `E_ν α²/ν² (ν/(j + 1/2) - 3/4)`. |
| `PhyslibAlpha.Hydrogen.fineStructureShift_upper_eq_lower` | lemma | The levels `(ν, l, l + 1/2)` and `(ν, l + 1, l + 1/2)` have equal shift. |

## Notes

- Taken as physical input, as stated in the module docstring: the three perturbation operators and the first-order formula `ΔE = ⟨H'⟩`, the identity `⟨p⁴⟩ = 4m²⟨(E - V)²⟩`, and `|ψ(0)|² = |R(0)|²/(4π)`. Proved: the radial equation, the radial integrals, the `L · S` eigenvalues and the algebra that combines them.
- The corrections are defined as real numbers in terms of radial expectation values; `⟨L · S⟩/ℏ²` enters as a real parameter `ls`, tied to the operator eigenvalue only through the hypothesis `(ls : ℂ) = Sl2.spinOrbitValue (2 * l) 1 k`.
- The results assume `H.d = 3` and `0 < H.k`.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
