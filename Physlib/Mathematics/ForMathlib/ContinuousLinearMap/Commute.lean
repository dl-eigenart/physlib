/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
module

public import Mathlib.Topology.Algebra.Module.ContinuousLinearMap.Basic
/-!

# Reordering commuting continuous linear maps in compositions

## i. Overview

On `M →L[R] M` multiplication is composition, `f * g = f ∘L g` by `rfl`
(`ContinuousLinearMap.mul_def`). Hence `Commute.left_comm` and `Commute.right_comm` reorder
commuting maps inside a composition, but only in `*` form: `rw` and `simp` do not find the
pattern `a * (b * c)` in a term written with `∘L`. This file restates the two lemmas in `∘L` form.

A vanishing ring commutator gives `Commute` by Mathlib's `commute_iff_lie_eq`.

## ii. Key results

- `ContinuousLinearMap.comp_left_comm_of_commute` : `A ∘L (B ∘L C) = B ∘L (A ∘L C)` if `A` and
  `B` commute.
- `ContinuousLinearMap.comp_right_comm_of_commute` : `(A ∘L B) ∘L C = (A ∘L C) ∘L B` if `B` and
  `C` commute.

## iii. Table of contents

- A. Reordering in compositions

## iv. References

There are no known references for the material in this module.

-/

@[expose] public section

namespace ContinuousLinearMap

variable {R M : Type*} [Semiring R] [TopologicalSpace M] [AddCommMonoid M] [Module R M]

/-!

## A. Reordering in compositions

-/

/-- Commuting maps `A` and `B` can be swapped in `A ∘L (B ∘L C)`. -/
lemma comp_left_comm_of_commute {A B : M →L[R] M} (h : Commute A B) (C : M →L[R] M) :
    A ∘L (B ∘L C) = B ∘L (A ∘L C) :=
  h.left_comm C

/-- Commuting maps `B` and `C` can be swapped in `(A ∘L B) ∘L C`. -/
lemma comp_right_comm_of_commute {B C : M →L[R] M} (h : Commute B C) (A : M →L[R] M) :
    (A ∘L B) ∘L C = (A ∘L C) ∘L B :=
  h.right_comm A

end ContinuousLinearMap
