# feat(PhyslibAlpha): Wigner-Eckart theorem with Clebsch-Gordan coefficients

Branch: `pr/wigner-eckart-cg` · Base: master after merge of `pr/wigner-3j` and `pr/six-j` · Depends on: `pr/wigner-3j`, `pr/six-j` (and through them `pr/clebsch-gordan-formula`, #1911 and #1876)

This PR writes the Wigner-Eckart theorem of #1876, `T x y = c • cgProj (x ⊗ y)`, in the orthonormal bases: the matrix elements of a tensor operator are one reduced matrix element times a Clebsch-Gordan coefficient, `⟨J' M' | T^κ_μ | J M⟩ = R · ⟨κ μ J M | J' M'⟩`. Combined with the multipole sum rule it shows that the total strength `Σ_{μ M'} |⟨J' M' | T^κ_μ | J M⟩|²` does not depend on `M`. It uses `embed` from `pr/six-j`, and the 3j symmetries and `sum_sq_cgCoefficient_initial` from `pr/wigner-3j`.

## Main results

- `cgCoefficient_swap`: `⟨j₁ m₁ j₂ m₂ | J M⟩ = (-1)^(j₁ + j₂ - J) ⟨j₂ m₂ j₁ m₁ | J M⟩`.
- `invForm_cgProj`: `⟨u, cgProj x⟩ = ⟨w_j, w_j⟩^(-1/2) ⟨embed u, x⟩`.
- `IsTensorOperator.exists_normVec_eq`: there is `R` with `⟨J' M' | T^κ_μ | J M⟩ = R · ⟨κ μ J M | J' M'⟩` for all projections.
- `IsTensorOperator.sum_sq_normVec`: `Σ_{μ M'} |⟨J' M' | T^κ_μ | J M⟩|² = R² (2J' + 1)/(2J + 1)` for every `M`.

## Reviewer map

1. `WignerEckartNormalized.lean` §A Exchanging the coupled angular momenta: `wigner3j_swap` from `threeJR_swap_columns`, and the parity identity behind the phase `(-1)^k` in `cgCoefficient_swap`.
2. `WignerEckartNormalized.lean` §B The projections in the orthonormal bases: `invForm_cgProj` is checked on the basis `tensorStringBasis`, using `tensorForm_embed` and `tensorForm_embed_of_ne`.
3. `WignerEckartNormalized.lean` §C The Wigner-Eckart theorem: the reduced matrix element is `c · (√hwNormSq)⁻¹` with `c` from `IsTensorOperator.exists_eq_smul_cgProj`; the coefficient is coupled in the order `κ ⊗ J`.
4. `WignerEckartNormalized.lean` §D The total strength out of a substate: `cgCoefficient_swap` turns the order `κ ⊗ J` into `J ⊗ κ`, then `sum_sq_cgCoefficient_initial` applies.

## Declarations

All declarations are in the namespace `PhyslibAlpha.Sl2`.

### `PhyslibAlpha/QuantumMechanics/AngularMomentum/WignerEckartNormalized.lean`

| Declaration | Kind | Description |
|---|---|---|
| `neg_one_pow_congr_nat` | lemma | `(-1)^p = (-1)^q` for natural numbers `p ≡ q (mod 2)`. |
| `wigner3j_swap` | lemma | `wigner3j n m k l β α = (-1)^(m + n - k) · wigner3j m n k l α β`, i.e. `(j₂ j₁ J; m₂ m₁ -M) = (-1)^(j₁ + j₂ + J) (j₁ j₂ J; m₁ m₂ -M)`. |
| `cgCoefficient_swap` | lemma | `cgCoefficient m n k l α β = (-1)^k · cgCoefficient n m k l β α`. |
| `stringVec_eq_smul_embed` | lemma | `stringVec m n j l = √(hwNormSq m n j) • embed j (vNat l)`. |
| `invForm_cgProj` | lemma | `invForm y (cgProj j x) = (√hwNormSq)⁻¹ · tensorForm (embed j y) x`. |
| `IsTensorOperator.exists_normVec_eq` | lemma | Wigner-Eckart theorem: `∃ R, ∀ q r s, invForm (normVec s) (T (normVec q) (normVec r)) = R · cgCoefficient k m j s q r`. |
| `IsTensorOperator.sum_sq_normVec` | lemma | Under the conclusion of `exists_normVec_eq` with a given `R`, `Σ_{q, s} invForm (normVec s) (T (normVec q) (normVec r))² = R² (k + m - 2j + 1)/(m + 1)` for `r ≤ m`. |

## Notes

- Spins are doubled: `κ = k/2`, `J = m/2`, `J' = (k + m)/2 - j`; the projections are encoded by `q, r, s` as `μ = κ - q`, `M = J - r`, `M' = J' - s`.
- `exists_normVec_eq` gives the Clebsch-Gordan coefficient in the coupling order `κ ⊗ J`; `cgCoefficient_swap` relates it to `J ⊗ κ` by `(-1)^(J + κ - J')`.
- `sum_sq_normVec` takes the matrix-element formula as the hypothesis `hR` and does not use `IsTensorOperator T`.

---
*Draft for the human author. Check every line before posting; the author is responsible for the
content (AI-POLICY.md §1.7). AI use: Claude (Anthropic) wrote the Lean code and this description.*
