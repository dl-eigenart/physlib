# feat(QuantumMechanics): the hydrogen Hamiltonian is densely defined

Branch: `hydrogen-dense-domain` · Base: master · Depends on: nothing open · Library: **Physlib**

This PR shows that the (unregularised) Hamiltonian `HydrogenAtom.hamiltonianOperator` is densely defined in every dimension. Its domain contains the polynomially-bounded Schwartz maps `PolyBddSchwartzSubmodule`, which are dense, and for `d ≥ 3` it contains all Schwartz maps. Dense definition is the standing hypothesis for taking adjoints and closures, so it is a prerequisite for the existing TODOs on essential self-adjointness and on the spectrum in `Hydrogen/Basic.lean`.

## Main results

- `HydrogenAtom.hamiltonianOperator_hasDenseDomain`: `H.hamiltonianOperator.HasDenseDomain`, for every `d`.
- `HydrogenAtom.polyBddSchwartzSubmodule_le_hamiltonianOperator_domain`: polynomially-bounded Schwartz maps (with the order `⌊2 - d/2⌋` needed for `1/r`) lie in the domain.

## Reviewer map

1. `Physlib/QuantumMechanics/Hydrogen/Basic.lean`, new §C Domain of the Hamiltonian: the domain is the intersection of the kinetic and potential domains; the kinetic part uses `momentumSqOperator_domain_eq`, the potential part `radiusPowOperator_domain_ge` with exponent `-1`.
2. The density follows from `PolyBddSchwartzSubmodule.dense` by monotonicity.
3. The module docstring overview gains one sentence.

## Declarations

### `Physlib/QuantumMechanics/Hydrogen/Basic.lean`

| Declaration | Kind | Description |
|---|---|---|
| `HydrogenAtom.polyBddSchwartzSubmodule_le_hamiltonianOperator_domain` | lemma | `PolyBddSchwartzSubmodule d ⌊2 - d/2⌋ ≤ H.hamiltonianOperator.domain`; for `d ≥ 3` this is all Schwartz maps. |
| `HydrogenAtom.hamiltonianOperator_hasDenseDomain` | lemma | The Hamiltonian of the hydrogen atom has dense domain, in any dimension. |

## Notes

- Only dense definition is shown; (essential) self-adjointness remains the existing TODO.

---
AI use: Claude (Anthropic) wrote the Lean code and this description; I have checked both.
