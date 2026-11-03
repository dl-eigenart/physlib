/-
Copyright (c) 2025 Alex Meiburg. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alex Meiburg
-/
module

public import Mathlib.Basic.Complex.Basic
public import Mathlib.LinearAlgebra.UnitaryGroup

/-!

# Unitary matrices and their Kronecker products

The notation `𝐔[n]` for the unitary group of complex matrices indexed by `n`, and the Kronecker
product of two unitary matrices as a unitary matrix.

## i. Overview

`𝐔[n]` is `Matrix.unitaryGroup n ℂ`. The Kronecker product `a ⊗ₖ b` of two unitary matrices is
unitary (`kron_unitary`), which gives the product `a ⊗ᵤ b` in `𝐔[α × β]` (`unitaryKron`).

## ii. Key results

- `𝐔[n]`: notation for `Matrix.unitaryGroup n ℂ`.
- `kron_unitary`, `unitaryKron`, `⊗ᵤ`: the Kronecker product of unitary matrices.

## iii. Table of contents

- A. Unitary matrices and their Kronecker products

## iv. References

## A. Unitary matrices and their Kronecker products

-/

@[expose] public section

/-- `𝐔[n]` is the unitary group `Matrix.unitaryGroup n ℂ` of complex matrices indexed by `n`. -/
notation "𝐔[" n "]" => Matrix.unitaryGroup n ℂ

namespace Matrix

variable {α : Type*} [NonUnitalNonAssocSemiring α] [StarRing α]

variable {α β : Type*} [DecidableEq α] [Fintype α] [DecidableEq β] [Fintype β]

@[simp]
lemma neg_unitary_val (u : 𝐔[α]) : (-u).val = -u := by
  rfl

omit [DecidableEq α] [Fintype α] [DecidableEq β] [Fintype β] in
open Kronecker in
@[simp]
lemma star_kron (a : Matrix α α ℂ) (b : Matrix β β ℂ) : star (a ⊗ₖ b) = (star a) ⊗ₖ (star b) := by
  ext _ _
  simp

open Kronecker in
lemma kron_unitary (a : 𝐔[α]) (b : 𝐔[β]) : a.val ⊗ₖ b.val ∈ 𝐔[α × β] := by
  simp [Matrix.mem_unitaryGroup_iff, ← Matrix.mul_kronecker_mul]

open Kronecker in
/-- The Kronecker product of two unitary matrices, as a unitary matrix. -/
def unitaryKron (a : 𝐔[α]) (b : 𝐔[β]) : 𝐔[α × β] :=
  ⟨_, kron_unitary a b⟩

/-- `a ⊗ᵤ b` is the Kronecker product `unitaryKron a b` of two unitary matrices. -/
scoped infixl:60 " ⊗ᵤ " => unitaryKron

@[simp]
lemma unitary_kron_apply (a : 𝐔[α]) (b : 𝐔[β]) (i₁ i₂ : α) (j₁ j₂ : β) :
    (a ⊗ᵤ b) (i₁, j₁) (i₂, j₂) = (a i₁ i₂) * (b j₁ j₂) := by
  rfl

@[simp]
lemma unitary_kron_one_one : (1 : 𝐔[α]) ⊗ᵤ (1 : 𝐔[β]) = (1 : 𝐔[α × β]) := by
  simp [Matrix.unitaryKron]

end Matrix
