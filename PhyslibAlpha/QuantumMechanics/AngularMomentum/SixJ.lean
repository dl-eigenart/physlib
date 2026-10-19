/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
module

public import PhyslibAlpha.QuantumMechanics.AngularMomentum.ClebschGordanFormula

/-!

# Recoupling of three angular momenta and the 6j symbols

The two coupling schemes of `j₁ ⊗ j₂ ⊗ j₃`, the recoupling coefficients between them and the
6j symbols, with their independence of `M` and their orthogonality.

## i. Overview

Three angular momenta `j₁ = a/2`, `j₂ = b/2`, `j₃ = c/2` live on
`V(a) ⊗ V(b) ⊗ V(c)`. A state of total angular momentum `J` and projection `M` can be built in
two ways:

- `|(j₁ j₂) j₁₂, j₃; J M⟩`: first couple `j₁` and `j₂` to `j₁₂`, then `j₁₂` and `j₃` to `J`;
- `|j₁, (j₂ j₃) j₂₃; J M⟩`: first couple `j₂` and `j₃` to `j₂₃`, then `j₁` and `j₂₃` to `J`.

Both are built from the Clebsch–Gordan states `coupledVec` of `ClebschGordanCoefficients`. The
`k`-th irreducible component of `V(m) ⊗ V(n)` is the image of the isometric embedding
`embed : V(m + n - 2k) → V(m) ⊗ V(n)`, `u_l ↦ |J, J - l⟩`, which intertwines `E`, `F` and `H`
(it is a rescaled inverse of `cgEquiv`). The first scheme is `embed ⊗ 1` applied to the coupled
states of `V(a + b - 2k₁) ⊗ V(c)`, the second is `1 ⊗ embed` followed by the associator.

The recoupling coefficient `⟨(j₁ j₂) j₁₂, j₃; J M | j₁, (j₂ j₃) j₂₃; J M⟩` is the contravariant
form between the two (`recoupling`). The main results are:

- both schemes consist of eigenvectors of the total `J²` and `J_z`, so states of different `J` or
  `M` are orthogonal (`tripleForm_stateA_stateB_eq_zero`);
- the first scheme is an orthonormal basis (`eq_sum_vecA`), so the recoupling coefficients form
  an orthogonal matrix (`sum_recoupling_mul_recoupling`);
- the recoupling coefficients do not depend on `M` (`recoupling_eq_recoupling_zero`): the total
  lowering operator moves `M` in both schemes by the same factor `√((J + M)(J - M + 1))`, and it
  is adjoint to the raising operator.

The 6j symbol is defined by
`⟨(j₁ j₂) j₁₂, j₃; J | j₁, (j₂ j₃) j₂₃; J⟩ = (-1)^(j₁ + j₂ + j₃ + J) √((2j₁₂ + 1)(2j₂₃ + 1))
{j₁ j₂ j₁₂; j₃ J j₂₃}` (`sixJ`), and satisfies
`Σ_{j₁₂} (2j₁₂ + 1)(2j₂₃ + 1) {j₁ j₂ j₁₂; j₃ J j₂₃} {j₁ j₂ j₁₂; j₃ J j₂₃'} = δ_{j₂₃ j₂₃'}`
(`sum_sixJ_mul_sixJ`).

Racah's closed formula for the 6j symbols is not proved here.

## ii. Key results

- `embed`, `tensorForm_embed`, `tensorF_embed`: the isometric intertwining embeddings.
- `stateA`, `stateB`: the two coupling schemes.
- `eq_sum_vecA`: completeness of the first scheme.
- `tripleForm_stateA_stateB_eq_zero`: separation by `J` and `M`.
- `recoupling`, `recoupling_eq_recoupling_zero`, `sum_recoupling_mul_recoupling`.
- `sixJ`, `recoupling_eq_sixJ`, `sum_sixJ_mul_sixJ`.

## iii. Table of contents

- A. The irreducible components as isometric embeddings
- B. The triple tensor product
- C. The Casimir operator
- D. The two coupling schemes
- E. Eigenvalues, ladders and orthonormality of the coupled states
  - E.1. Completeness of the first coupling scheme
  - E.2. Separation by `J` and `M`
  - E.3. The recoupling coefficients
  - E.4. Orthogonality
- F. The 6j symbols

## iv. References

- G. Racah, *Theory of complex spectra. II*, Phys. Rev. 62, 438 (1942).
- A. R. Edmonds, *Angular Momentum in Quantum Mechanics*, Princeton University Press (1957),
  chapter 6.

## A. The irreducible components as isometric embeddings

-/

@[expose] public section

noncomputable section

namespace PhyslibAlpha.Sl2

open StandardSl2Module

open scoped TensorProduct

section Embed

variable {m n : ℕ} (hmn : 0 < m + n) (k : Fin (min m n + 1))

/-- The isometric embedding `V(m + n - 2k) → V(m) ⊗ V(n)` onto the `k`-th irreducible component,
`u_l ↦ |J, J - l⟩`. -/
def embed : StandardSl2Module ℝ (m + n - 2 * (k : ℕ)) →ₗ[ℝ]
    StandardSl2Module ℝ m ⊗[ℝ] StandardSl2Module ℝ n :=
  (Real.sqrt (hwNormSq m n k))⁻¹ •
    ((cgEquiv (K := ℝ) hmn).symm.toLinearMap ∘ₗ DirectSum.lof ℝ _ (CGSummand ℝ m n) k)

lemma cgEquiv_symm_sumVec (l : ℕ) :
    (cgEquiv (K := ℝ) hmn).symm (DirectSum.lof ℝ _ (CGSummand ℝ m n) k (vNat _ l)) =
      stringVec m n k l := by
  rw [LinearEquiv.symm_apply_eq, cgEquiv_stringVec, sumVec]

lemma embed_vNat (l : ℕ) :
    embed hmn k (vNat _ l) = (Real.sqrt (hwNormSq m n k))⁻¹ • stringVec m n k l := by
  rw [embed, LinearMap.smul_apply, LinearMap.comp_apply, LinearEquiv.coe_coe,
    cgEquiv_symm_sumVec]

lemma embed_normVec (l : ℕ) : embed hmn k (normVec _ l) = coupledVec m n k l := by
  rw [normVec, map_smul, embed_vNat, smul_smul, coupledVec, Real.sqrt_mul (Nat.cast_nonneg _),
    mul_inv]

lemma tensorF_embed (x : StandardSl2Module ℝ (m + n - 2 * (k : ℕ))) :
    tensorF m n (embed hmn k x) = embed hmn k (ρF x) := by
  simp only [embed, LinearMap.smul_apply, LinearMap.comp_apply, LinearEquiv.coe_coe, map_smul]
  congr 1
  apply (cgEquiv (K := ℝ) hmn).injective
  rw [cgEquiv_tensorF, LinearEquiv.apply_symm_apply, LinearEquiv.apply_symm_apply, sumEnd_lof]

lemma tensorE_embed (x : StandardSl2Module ℝ (m + n - 2 * (k : ℕ))) :
    tensorE m n (embed hmn k x) = embed hmn k (ρE x) := by
  simp only [embed, LinearMap.smul_apply, LinearMap.comp_apply, LinearEquiv.coe_coe, map_smul]
  congr 1
  apply (cgEquiv (K := ℝ) hmn).injective
  rw [cgEquiv_tensorE, LinearEquiv.apply_symm_apply, LinearEquiv.apply_symm_apply, sumEnd_lof]

lemma tensorH_embed (x : StandardSl2Module ℝ (m + n - 2 * (k : ℕ))) :
    tensorH m n (embed hmn k x) = embed hmn k (ρH x) := by
  simp only [embed, LinearMap.smul_apply, LinearMap.comp_apply, LinearEquiv.coe_coe, map_smul]
  congr 1
  apply (cgEquiv (K := ℝ) hmn).injective
  rw [cgEquiv_tensorH, LinearEquiv.apply_symm_apply, LinearEquiv.apply_symm_apply, sumEnd_lof]

/-- The embedding is an isometry. -/
lemma tensorForm_embed (x y : StandardSl2Module ℝ (m + n - 2 * (k : ℕ))) :
    tensorForm m n (embed hmn k x) (embed hmn k y) = invForm ℝ _ x y := by
  have hkm : (k : ℕ) ≤ m := by have := k.isLt; omega
  have hkn : (k : ℕ) ≤ n := by have := k.isLt; omega
  have hw := hwNormSq_pos hkm hkn
  have hs := Real.mul_self_sqrt hw.le
  have h : (tensorForm m n).compl₁₂ (embed hmn k) (embed hmn k) = invForm ℝ _ :=
    bilin_ext_vNat fun a b => by
      simp only [LinearMap.compl₁₂_apply, embed_vNat, map_smul, LinearMap.smul_apply,
        smul_eq_mul]
      rw [tensorForm_stringVec hmn hkm hkn hkm hkn, invForm_vNat, ← hwNormSq]
      by_cases hab : a = b
      · subst hab
        rw [ite_eq_left ⟨rfl, rfl⟩]
        by_cases ha : a ≤ m + n - 2 * (k : ℕ)
        · rw [ite_eq_left ⟨rfl, ha⟩]
          calc (Real.sqrt (hwNormSq m n k))⁻¹ * ((Real.sqrt (hwNormSq m n k))⁻¹ *
                ((normSq (m + n - 2 * (k : ℕ)) a : ℝ) * hwNormSq m n k)) =
              (normSq (m + n - 2 * (k : ℕ)) a : ℝ) *
                (hwNormSq m n k / (Real.sqrt (hwNormSq m n k) * Real.sqrt (hwNormSq m n k))) := by
                ring
            _ = _ := by rw [hs, div_self hw.ne', mul_one]
        · have h0 : (normSq (m + n - 2 * (k : ℕ)) a : ℝ) = 0 := by
            rw [normSq, Nat.descFactorial_eq_zero_iff_lt.mpr (by omega), mul_zero, Nat.cast_zero]
          rw [ite_eq_right (fun h => ha h.2), h0]
          ring
      · rw [ite_eq_right (fun h => hab h.2), ite_eq_right (fun h => hab h.1), mul_zero, mul_zero]
  exact LinearMap.congr_fun (LinearMap.congr_fun h x) y

/-- Different components are orthogonal. -/
lemma tensorForm_embed_of_ne {k' : Fin (min m n + 1)} (hkk : k ≠ k')
    (x : StandardSl2Module ℝ (m + n - 2 * (k : ℕ)))
    (y : StandardSl2Module ℝ (m + n - 2 * (k' : ℕ))) :
    tensorForm m n (embed hmn k x) (embed hmn k' y) = 0 := by
  have hkm : (k : ℕ) ≤ m := by have := k.isLt; omega
  have hkn : (k : ℕ) ≤ n := by have := k.isLt; omega
  have hk'm : (k' : ℕ) ≤ m := by have := k'.isLt; omega
  have hk'n : (k' : ℕ) ≤ n := by have := k'.isLt; omega
  have h : (tensorForm m n).compl₁₂ (embed hmn k) (embed hmn k') = 0 :=
    linearMap_ext_vNat fun a => linearMap_ext_vNat fun b => by
      simp only [LinearMap.compl₁₂_apply, LinearMap.zero_apply, embed_vNat, map_smul,
        LinearMap.smul_apply, smul_eq_mul]
      rw [tensorForm_stringVec hmn hkm hkn hk'm hk'n, ite_eq_right (fun h => hkk (Fin.ext h.1)),
        mul_zero, mul_zero]
  exact LinearMap.congr_fun (LinearMap.congr_fun h x) y

end Embed

/-!

## B. The triple tensor product

-/

section Triple

variable (a b c : ℕ)

/-- `V(a) ⊗ V(b) ⊗ V(c)`, bracketed as `(V(a) ⊗ V(b)) ⊗ V(c)`. -/
abbrev Triple : Type :=
  (StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ b) ⊗[ℝ] StandardSl2Module ℝ c

/-- The contravariant form on the triple product. -/
def tripleForm : LinearMap.BilinForm ℝ (Triple a b c) :=
  LinearMap.BilinForm.tmul (tensorForm a b) (invForm ℝ c)

/-- The total raising operator on the triple product. -/
def tripleE : Module.End ℝ (Triple a b c) := diagEnd (tensorE a b) ρE

/-- The total lowering operator on the triple product. -/
def tripleF : Module.End ℝ (Triple a b c) := diagEnd (tensorF a b) ρF

/-- The total weight operator on the triple product. -/
def tripleH : Module.End ℝ (Triple a b c) := diagEnd (tensorH a b) ρH

variable {a b c}

lemma tripleForm_tmul (x x' : StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ b)
    (y y' : StandardSl2Module ℝ c) :
    tripleForm a b c (x ⊗ₜ y) (x' ⊗ₜ y') = tensorForm a b x x' * invForm ℝ c y y' := by
  rw [tripleForm, LinearMap.BilinForm.tensorDistrib_tmul, smul_eq_mul, mul_comm]

lemma tripleBilin_ext {B B' : LinearMap.BilinForm ℝ (Triple a b c)}
    (h : ∀ x y z x' y' z', B ((x ⊗ₜ y) ⊗ₜ z) ((x' ⊗ₜ y') ⊗ₜ z') =
      B' ((x ⊗ₜ y) ⊗ₜ z) ((x' ⊗ₜ y') ⊗ₜ z')) : B = B' :=
  TensorProduct.ext_threefold fun x y z =>
    TensorProduct.ext_threefold fun x' y' z' => h x y z x' y' z'

lemma invForm_ρF_apply {n : ℕ} (x y : StandardSl2Module ℝ n) :
    invForm ℝ n (ρF x) y = invForm ℝ n x (ρE y) := by
  rw [invForm_comm, ← invForm_ρE_apply, invForm_comm]

lemma tripleForm_tripleF (u v : Triple a b c) :
    tripleForm a b c (tripleF a b c u) v = tripleForm a b c u (tripleE a b c v) := by
  have h : LinearMap.comp (tripleForm a b c) (tripleF a b c) =
      LinearMap.compl₂ (tripleForm a b c) (tripleE a b c) :=
    tripleBilin_ext fun x y z x' y' z' => by
      simp only [LinearMap.comp_apply, LinearMap.compl₂_apply, tripleF, tripleE, diagEnd_tmul,
        map_add, LinearMap.add_apply, tripleForm_tmul, tensorForm_tensorF, invForm_ρF_apply]
  exact LinearMap.congr_fun (LinearMap.congr_fun h u) v

lemma tripleForm_tripleE (u v : Triple a b c) :
    tripleForm a b c (tripleE a b c u) v = tripleForm a b c u (tripleF a b c v) := by
  have h : LinearMap.comp (tripleForm a b c) (tripleE a b c) =
      LinearMap.compl₂ (tripleForm a b c) (tripleF a b c) :=
    tripleBilin_ext fun x y z x' y' z' => by
      simp only [LinearMap.comp_apply, LinearMap.compl₂_apply, tripleF, tripleE, diagEnd_tmul,
        map_add, LinearMap.add_apply, tripleForm_tmul, tensorForm_tensorE, invForm_ρE_apply]
  exact LinearMap.congr_fun (LinearMap.congr_fun h u) v

lemma tripleForm_tripleH (u v : Triple a b c) :
    tripleForm a b c (tripleH a b c u) v = tripleForm a b c u (tripleH a b c v) := by
  have h : LinearMap.comp (tripleForm a b c) (tripleH a b c) =
      LinearMap.compl₂ (tripleForm a b c) (tripleH a b c) :=
    tripleBilin_ext fun x y z x' y' z' => by
      simp only [LinearMap.comp_apply, LinearMap.compl₂_apply, tripleH, diagEnd_tmul,
        map_add, LinearMap.add_apply, tripleForm_tmul, tensorForm_tensorH, invForm_ρH_apply]
  exact LinearMap.congr_fun (LinearMap.congr_fun h u) v

lemma tripleForm_assoc_symm (x x' : StandardSl2Module ℝ a)
    (w w' : StandardSl2Module ℝ b ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleForm a b c ((TensorProduct.assoc ℝ _ _ _).symm (x ⊗ₜ w))
      ((TensorProduct.assoc ℝ _ _ _).symm (x' ⊗ₜ w')) = invForm ℝ a x x' * tensorForm b c w w' := by
  induction w using TensorProduct.inductionOn with
  | tmul y z =>
    induction w' using TensorProduct.inductionOn with
    | tmul y' z' =>
      rw [TensorProduct.assoc_symm_tmul, TensorProduct.assoc_symm_tmul, tripleForm_tmul,
        tensorForm_tmul, tensorForm_tmul]
      ring
    | add w₁ w₂ h₁ h₂ =>
      simp only [TensorProduct.tmul_add, map_add, h₁, h₂]
      ring
  | add w₁ w₂ h₁ h₂ =>
    simp only [TensorProduct.tmul_add, map_add, LinearMap.add_apply, h₁, h₂]
    ring

lemma tripleF_assoc_symm (x : StandardSl2Module ℝ a)
    (w : StandardSl2Module ℝ b ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleF a b c ((TensorProduct.assoc ℝ _ _ _).symm (x ⊗ₜ w)) =
      (TensorProduct.assoc ℝ _ _ _).symm (ρF x ⊗ₜ w + x ⊗ₜ tensorF b c w) := by
  induction w using TensorProduct.inductionOn with
  | tmul y z =>
    simp only [TensorProduct.assoc_symm_tmul, tripleF, tensorF, diagEnd_tmul, map_add,
      TensorProduct.add_tmul, TensorProduct.tmul_add]
    abel
  | add w₁ w₂ h₁ h₂ =>
    simp only [TensorProduct.tmul_add, map_add, h₁, h₂]
    abel

lemma tripleE_assoc_symm (x : StandardSl2Module ℝ a)
    (w : StandardSl2Module ℝ b ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleE a b c ((TensorProduct.assoc ℝ _ _ _).symm (x ⊗ₜ w)) =
      (TensorProduct.assoc ℝ _ _ _).symm (ρE x ⊗ₜ w + x ⊗ₜ tensorE b c w) := by
  induction w using TensorProduct.inductionOn with
  | tmul y z =>
    simp only [TensorProduct.assoc_symm_tmul, tripleE, tensorE, diagEnd_tmul, map_add,
      TensorProduct.add_tmul, TensorProduct.tmul_add]
    abel
  | add w₁ w₂ h₁ h₂ =>
    simp only [TensorProduct.tmul_add, map_add, h₁, h₂]
    abel

lemma tripleH_assoc_symm (x : StandardSl2Module ℝ a)
    (w : StandardSl2Module ℝ b ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleH a b c ((TensorProduct.assoc ℝ _ _ _).symm (x ⊗ₜ w)) =
      (TensorProduct.assoc ℝ _ _ _).symm (ρH x ⊗ₜ w + x ⊗ₜ tensorH b c w) := by
  induction w using TensorProduct.inductionOn with
  | tmul y z =>
    simp only [TensorProduct.assoc_symm_tmul, tripleH, tensorH, diagEnd_tmul, map_add,
      TensorProduct.add_tmul, TensorProduct.tmul_add]
    abel
  | add w₁ w₂ h₁ h₂ =>
    simp only [TensorProduct.tmul_add, map_add, h₁, h₂]
    abel

lemma tripleForm_comm (u v : Triple a b c) : tripleForm a b c u v = tripleForm a b c v u := by
  have h : tripleForm a b c = LinearMap.flip (tripleForm a b c) :=
    tripleBilin_ext fun x y z x' y' z' => by
      rw [LinearMap.flip_apply, tripleForm_tmul, tripleForm_tmul, tensorForm_comm, invForm_comm]
  rw [h, LinearMap.flip_apply, ← h]

end Triple

/-!

## C. The Casimir operator

-/

section Casimir

variable {m n : ℕ}

variable (m n) in
/-- `2 J² = E F + F E + H²/2` on `V(m) ⊗ V(n)`. -/
def tensorCas : Module.End ℝ (StandardSl2Module ℝ m ⊗[ℝ] StandardSl2Module ℝ n) :=
  tensorE m n * tensorF m n + tensorF m n * tensorE m n + (1 / 2 : ℝ) • (tensorH m n * tensorH m n)

/-- `2 J² = N(N + 2)/2 = 2 J(J + 1)` on the `k`-th string, `N = m + n - 2k`. -/
lemma tensorCas_stringVec {k : ℕ} (hmn : 0 < m + n) (hkm : k ≤ m) (hkn : k ≤ n) (l : ℕ) :
    tensorCas m n (stringVec m n k l) =
      (((m + n - 2 * k : ℕ) : ℝ) * (((m + n - 2 * k : ℕ) : ℝ) + 2) / 2) • stringVec m n k l := by
  rcases l with _ | l
  · simp only [tensorCas, LinearMap.add_apply, Module.End.mul_apply, LinearMap.smul_apply,
      tensorF_stringVec, tensorE_stringVec_succ hmn hkm hkn, tensorE_stringVec_zero hkm hkn,
      map_zero, tensorH_stringVec hmn hkm hkn, map_smul, Nat.cast_zero]
    module
  · simp only [tensorCas, LinearMap.add_apply, Module.End.mul_apply, LinearMap.smul_apply,
      tensorF_stringVec, tensorE_stringVec_succ hmn hkm hkn, tensorH_stringVec hmn hkm hkn,
      map_smul, Nat.cast_add, Nat.cast_one]
    module

lemma tensorCas_coupledVec {k : ℕ} (hmn : 0 < m + n) (hkm : k ≤ m) (hkn : k ≤ n) (l : ℕ) :
    tensorCas m n (coupledVec m n k l) =
      (((m + n - 2 * k : ℕ) : ℝ) * (((m + n - 2 * k : ℕ) : ℝ) + 2) / 2) • coupledVec m n k l := by
  rw [coupledVec, map_smul, tensorCas_stringVec hmn hkm hkn, smul_comm]

variable (a b c : ℕ) in
/-- `2 J²` on the triple product. -/
def tripleCas : Module.End ℝ (Triple a b c) :=
  tripleE a b c * tripleF a b c + tripleF a b c * tripleE a b c +
    (1 / 2 : ℝ) • (tripleH a b c * tripleH a b c)

lemma tripleForm_tripleCas {a b c : ℕ} (u v : Triple a b c) :
    tripleForm a b c (tripleCas a b c u) v = tripleForm a b c u (tripleCas a b c v) := by
  simp only [tripleCas, LinearMap.add_apply, Module.End.mul_apply, LinearMap.smul_apply, map_add,
    map_smul, LinearMap.add_apply, LinearMap.smul_apply]
  rw [tripleForm_tripleE, tripleForm_tripleF, tripleForm_tripleF, tripleForm_tripleE,
    tripleForm_tripleH, tripleForm_tripleH]

end Casimir

/-!

## D. The two coupling schemes

-/

section States

variable {a b c : ℕ}

/-- `|(j₁ j₂) j₁₂, j₃; J, M⟩`: `j₁ = a/2`, `j₂ = b/2`, `j₃ = c/2`, `j₁₂ = (a + b)/2 - k₁`,
`J = j₁₂ + j₃ - k₂`, `M = J - l`. -/
def stateA (hab : 0 < a + b) (k₁ : Fin (min a b + 1)) (k₂ l : ℕ) : Triple a b c :=
  (embed hab k₁).rTensor _ (coupledVec (a + b - 2 * (k₁ : ℕ)) c k₂ l)

/-- `V(a) ⊗ V(b + c - 2k₃) → V(a) ⊗ V(b) ⊗ V(c)`, through the `k₃`-th component of
`V(b) ⊗ V(c)`. -/
def assocEmbed (hbc : 0 < b + c) (k₃ : Fin (min b c + 1)) :
    StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ (b + c - 2 * (k₃ : ℕ)) →ₗ[ℝ] Triple a b c :=
  (TensorProduct.assoc ℝ _ _ _).symm.toLinearMap ∘ₗ (embed hbc k₃).lTensor _

/-- `|j₁, (j₂ j₃) j₂₃; J, M⟩`: `j₂₃ = (b + c)/2 - k₃`, `J = j₁ + j₂₃ - k₄`, `M = J - l`. -/
def stateB (hbc : 0 < b + c) (k₃ : Fin (min b c + 1)) (k₄ l : ℕ) : Triple a b c :=
  assocEmbed hbc k₃ (coupledVec a (b + c - 2 * (k₃ : ℕ)) k₄ l)

section A

variable (hab : 0 < a + b) (k₁ : Fin (min a b + 1))

lemma tripleF_rTensor_embed
    (u : StandardSl2Module ℝ (a + b - 2 * (k₁ : ℕ)) ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleF a b c ((embed hab k₁).rTensor _ u) = (embed hab k₁).rTensor _ (tensorF _ c u) := by
  have h : tripleF a b c ∘ₗ (embed hab k₁).rTensor _ = (embed hab k₁).rTensor _ ∘ₗ tensorF _ c :=
    TensorProduct.ext' fun x z => by
      rw [LinearMap.comp_apply, LinearMap.comp_apply, LinearMap.rTensor_tmul, tripleF,
        diagEnd_tmul, tensorF_embed, tensorF, diagEnd_tmul, map_add, LinearMap.rTensor_tmul,
        LinearMap.rTensor_tmul]
  exact LinearMap.congr_fun h u

lemma tripleE_rTensor_embed
    (u : StandardSl2Module ℝ (a + b - 2 * (k₁ : ℕ)) ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleE a b c ((embed hab k₁).rTensor _ u) = (embed hab k₁).rTensor _ (tensorE _ c u) := by
  have h : tripleE a b c ∘ₗ (embed hab k₁).rTensor _ = (embed hab k₁).rTensor _ ∘ₗ tensorE _ c :=
    TensorProduct.ext' fun x z => by
      rw [LinearMap.comp_apply, LinearMap.comp_apply, LinearMap.rTensor_tmul, tripleE,
        diagEnd_tmul, tensorE_embed, tensorE, diagEnd_tmul, map_add, LinearMap.rTensor_tmul,
        LinearMap.rTensor_tmul]
  exact LinearMap.congr_fun h u

lemma tripleH_rTensor_embed
    (u : StandardSl2Module ℝ (a + b - 2 * (k₁ : ℕ)) ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleH a b c ((embed hab k₁).rTensor _ u) = (embed hab k₁).rTensor _ (tensorH _ c u) := by
  have h : tripleH a b c ∘ₗ (embed hab k₁).rTensor _ = (embed hab k₁).rTensor _ ∘ₗ tensorH _ c :=
    TensorProduct.ext' fun x z => by
      rw [LinearMap.comp_apply, LinearMap.comp_apply, LinearMap.rTensor_tmul, tripleH,
        diagEnd_tmul, tensorH_embed, tensorH, diagEnd_tmul, map_add, LinearMap.rTensor_tmul,
        LinearMap.rTensor_tmul]
  exact LinearMap.congr_fun h u

lemma tripleCas_rTensor_embed
    (u : StandardSl2Module ℝ (a + b - 2 * (k₁ : ℕ)) ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleCas a b c ((embed hab k₁).rTensor _ u) = (embed hab k₁).rTensor _ (tensorCas _ c u) := by
  simp only [tripleCas, tensorCas, LinearMap.add_apply, Module.End.mul_apply, LinearMap.smul_apply,
    tripleF_rTensor_embed, tripleE_rTensor_embed, tripleH_rTensor_embed, map_add, map_smul]

lemma tripleForm_rTensor_embed
    (u u' : StandardSl2Module ℝ (a + b - 2 * (k₁ : ℕ)) ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleForm a b c ((embed hab k₁).rTensor _ u) ((embed hab k₁).rTensor _ u') =
      tensorForm _ c u u' := by
  have h : LinearMap.compl₁₂ (tripleForm a b c) ((embed hab k₁).rTensor _)
      ((embed hab k₁).rTensor _) = tensorForm _ c :=
    tensorBilin_ext fun x z x' z' => by
      rw [LinearMap.compl₁₂_apply, LinearMap.rTensor_tmul, LinearMap.rTensor_tmul, tripleForm_tmul,
        tensorForm_embed, tensorForm_tmul]
  exact LinearMap.congr_fun (LinearMap.congr_fun h u) u'

lemma tripleForm_rTensor_embed_of_ne {k₁' : Fin (min a b + 1)} (hk : k₁ ≠ k₁')
    (u : StandardSl2Module ℝ (a + b - 2 * (k₁ : ℕ)) ⊗[ℝ] StandardSl2Module ℝ c)
    (u' : StandardSl2Module ℝ (a + b - 2 * (k₁' : ℕ)) ⊗[ℝ] StandardSl2Module ℝ c) :
    tripleForm a b c ((embed hab k₁).rTensor _ u) ((embed hab k₁').rTensor _ u') = 0 := by
  have h : LinearMap.compl₁₂ (tripleForm a b c) ((embed hab k₁).rTensor _)
      ((embed hab k₁').rTensor _) = 0 :=
    TensorProduct.ext' fun x z => TensorProduct.ext' fun x' z' => by
      rw [LinearMap.compl₁₂_apply, LinearMap.rTensor_tmul, LinearMap.rTensor_tmul, tripleForm_tmul,
        tensorForm_embed_of_ne hab k₁ hk, zero_mul, LinearMap.zero_apply, LinearMap.zero_apply]
  exact LinearMap.congr_fun (LinearMap.congr_fun h u) u'

end A

section B

variable (hbc : 0 < b + c) (k₃ : Fin (min b c + 1))

lemma tripleF_assocEmbed
    (w : StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ (b + c - 2 * (k₃ : ℕ))) :
    tripleF a b c (assocEmbed hbc k₃ w) = assocEmbed hbc k₃ (tensorF a _ w) := by
  have h : tripleF a b c ∘ₗ assocEmbed hbc k₃ = assocEmbed hbc k₃ ∘ₗ tensorF a _ :=
    TensorProduct.ext' fun x y => by
      simp only [assocEmbed, LinearMap.comp_apply, LinearEquiv.coe_coe, LinearMap.lTensor_tmul,
        tripleF_assoc_symm, tensorF_embed]
      rw [tensorF, diagEnd_tmul]
      simp only [map_add, LinearMap.lTensor_tmul]
  exact LinearMap.congr_fun h w

lemma tripleE_assocEmbed
    (w : StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ (b + c - 2 * (k₃ : ℕ))) :
    tripleE a b c (assocEmbed hbc k₃ w) = assocEmbed hbc k₃ (tensorE a _ w) := by
  have h : tripleE a b c ∘ₗ assocEmbed hbc k₃ = assocEmbed hbc k₃ ∘ₗ tensorE a _ :=
    TensorProduct.ext' fun x y => by
      simp only [assocEmbed, LinearMap.comp_apply, LinearEquiv.coe_coe, LinearMap.lTensor_tmul,
        tripleE_assoc_symm, tensorE_embed]
      rw [tensorE, diagEnd_tmul]
      simp only [map_add, LinearMap.lTensor_tmul]
  exact LinearMap.congr_fun h w

lemma tripleH_assocEmbed
    (w : StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ (b + c - 2 * (k₃ : ℕ))) :
    tripleH a b c (assocEmbed hbc k₃ w) = assocEmbed hbc k₃ (tensorH a _ w) := by
  have h : tripleH a b c ∘ₗ assocEmbed hbc k₃ = assocEmbed hbc k₃ ∘ₗ tensorH a _ :=
    TensorProduct.ext' fun x y => by
      simp only [assocEmbed, LinearMap.comp_apply, LinearEquiv.coe_coe, LinearMap.lTensor_tmul,
        tripleH_assoc_symm, tensorH_embed]
      rw [tensorH, diagEnd_tmul]
      simp only [map_add, LinearMap.lTensor_tmul]
  exact LinearMap.congr_fun h w

lemma tripleCas_assocEmbed
    (w : StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ (b + c - 2 * (k₃ : ℕ))) :
    tripleCas a b c (assocEmbed hbc k₃ w) = assocEmbed hbc k₃ (tensorCas a _ w) := by
  simp only [tripleCas, tensorCas, LinearMap.add_apply, Module.End.mul_apply, LinearMap.smul_apply,
    tripleF_assocEmbed, tripleE_assocEmbed, tripleH_assocEmbed, map_add, map_smul]

lemma tripleForm_assocEmbed
    (w w' : StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ (b + c - 2 * (k₃ : ℕ))) :
    tripleForm a b c (assocEmbed hbc k₃ w) (assocEmbed hbc k₃ w') = tensorForm a _ w w' := by
  have h : LinearMap.compl₁₂ (tripleForm a b c) (assocEmbed hbc k₃) (assocEmbed hbc k₃) =
      tensorForm a _ :=
    tensorBilin_ext fun x y x' y' => by
      simp only [assocEmbed, LinearMap.compl₁₂_apply, LinearMap.comp_apply, LinearEquiv.coe_coe,
        LinearMap.lTensor_tmul]
      rw [tripleForm_assoc_symm, tensorForm_embed, tensorForm_tmul]
  exact LinearMap.congr_fun (LinearMap.congr_fun h w) w'

lemma tripleForm_assocEmbed_of_ne {k₃' : Fin (min b c + 1)} (hk : k₃ ≠ k₃')
    (w : StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ (b + c - 2 * (k₃ : ℕ)))
    (w' : StandardSl2Module ℝ a ⊗[ℝ] StandardSl2Module ℝ (b + c - 2 * (k₃' : ℕ))) :
    tripleForm a b c (assocEmbed hbc k₃ w) (assocEmbed hbc k₃' w') = 0 := by
  have h : LinearMap.compl₁₂ (tripleForm a b c) (assocEmbed hbc k₃) (assocEmbed hbc k₃') = 0 :=
    TensorProduct.ext' fun x y => TensorProduct.ext' fun x' y' => by
      simp only [assocEmbed, LinearMap.compl₁₂_apply, LinearMap.comp_apply, LinearEquiv.coe_coe,
        LinearMap.lTensor_tmul, LinearMap.zero_apply]
      rw [tripleForm_assoc_symm, tensorForm_embed_of_ne hbc k₃ hk, mul_zero]
  exact LinearMap.congr_fun (LinearMap.congr_fun h w) w'

end B

end States


/-!

## E. Eigenvalues, ladders and orthonormality of the coupled states

-/

section Coupled

variable {a b c : ℕ}

section A

variable (hab : 0 < a + b) (hc : 0 < c) (k₁ : Fin (min a b + 1)) {k₂ : ℕ}
  (h₁ : k₂ ≤ a + b - 2 * (k₁ : ℕ)) (h₂ : k₂ ≤ c)

include hc h₁ h₂ in
lemma tripleH_stateA (l : ℕ) :
    tripleH a b c (stateA hab k₁ k₂ l) =
      (((a + b - 2 * (k₁ : ℕ) + c - 2 * k₂ : ℕ) : ℝ) - 2 * l) • stateA hab k₁ k₂ l := by
  rw [stateA, tripleH_rTensor_embed, tensorH_coupledVec (by omega) h₁ h₂, map_smul]

include hc h₁ h₂ in
lemma tripleCas_stateA (l : ℕ) :
    tripleCas a b c (stateA hab k₁ k₂ l) =
      (((a + b - 2 * (k₁ : ℕ) + c - 2 * k₂ : ℕ) : ℝ) *
        (((a + b - 2 * (k₁ : ℕ) + c - 2 * k₂ : ℕ) : ℝ) + 2) / 2) • stateA hab k₁ k₂ l := by
  rw [stateA, tripleCas_rTensor_embed, tensorCas_coupledVec (by omega) h₁ h₂, map_smul]

include h₁ h₂ in
lemma tripleF_stateA {l : ℕ} (hl : l < a + b - 2 * (k₁ : ℕ) + c - 2 * k₂) :
    tripleF a b c (stateA hab k₁ k₂ l) =
      Real.sqrt (((l : ℝ) + 1) * (((a + b - 2 * (k₁ : ℕ) + c - 2 * k₂ : ℕ) : ℝ) - l)) •
        stateA hab k₁ k₂ (l + 1) := by
  rw [stateA, stateA, tripleF_rTensor_embed, tensorF_coupledVec h₁ h₂ hl, map_smul]

end A

section B

variable (hbc : 0 < b + c) (ha : 0 < a) (k₃ : Fin (min b c + 1)) {k₄ : ℕ}
  (h₃ : k₄ ≤ a) (h₄ : k₄ ≤ b + c - 2 * (k₃ : ℕ))

include ha h₃ h₄ in
lemma tripleH_stateB (l : ℕ) :
    tripleH a b c (stateB hbc k₃ k₄ l) =
      (((a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄ : ℕ) : ℝ) - 2 * l) • stateB hbc k₃ k₄ l := by
  rw [stateB, tripleH_assocEmbed, tensorH_coupledVec (by omega) h₃ h₄, map_smul]

include ha h₃ h₄ in
lemma tripleCas_stateB (l : ℕ) :
    tripleCas a b c (stateB hbc k₃ k₄ l) =
      (((a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄ : ℕ) : ℝ) *
        (((a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄ : ℕ) : ℝ) + 2) / 2) • stateB hbc k₃ k₄ l := by
  rw [stateB, tripleCas_assocEmbed, tensorCas_coupledVec (by omega) h₃ h₄, map_smul]

include ha h₃ h₄ in
lemma tripleE_stateB_succ {l : ℕ} (hl : l < a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄) :
    tripleE a b c (stateB hbc k₃ k₄ (l + 1)) =
      Real.sqrt (((l : ℝ) + 1) * (((a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄ : ℕ) : ℝ) - l)) •
        stateB hbc k₃ k₄ l := by
  rw [stateB, stateB, tripleE_assocEmbed, tensorE_coupledVec_succ (by omega) h₃ h₄ hl, map_smul]

include ha h₃ h₄ in
lemma tripleForm_stateB_self {l : ℕ} (hl : l ≤ a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄) :
    tripleForm a b c (stateB hbc k₃ k₄ l) (stateB hbc k₃ k₄ l) = 1 := by
  rw [stateB, tripleForm_assocEmbed, tensorForm_coupledVec (by omega) h₃ h₄ h₃ h₄ hl,
    ite_eq_left ⟨rfl, rfl⟩]

lemma tripleForm_stateB_of_ne {k₃' : Fin (min b c + 1)} (hk : k₃ ≠ k₃') (k₄' l l' : ℕ) :
    tripleForm a b c (stateB hbc k₃ k₄ l) (stateB hbc k₃' k₄' l') = 0 := by
  rw [stateB, stateB, tripleForm_assocEmbed_of_ne hbc k₃ hk]

end B

/-!

### E.1. Completeness of the first coupling scheme

-/

/-- An orthonormal family of `finrank` many vectors expands every vector. -/
lemma eq_sum_of_orthonormal {ι M : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι] [AddCommGroup M]
    [Module ℝ M] (B : LinearMap.BilinForm ℝ M) (v : ι → M)
    (hv : ∀ i j, B (v i) (v j) = if i = j then 1 else 0)
    (hcard : Fintype.card ι = Module.finrank ℝ M) (x : M) :
    x = ∑ i, B (v i) x • v i := by
  have hli : LinearIndependent ℝ v := by
    rw [Fintype.linearIndependent_iff]
    intro g hg i
    have h := congrArg (B (v i)) hg
    simp only [map_sum, map_smul, smul_eq_mul, hv, mul_ite, mul_one, mul_zero, Finset.sum_ite_eq,
      Finset.mem_univ, ite_true, map_zero] at h
    exact h
  let bas := basisOfLinearIndependentOfCardEqFinrank hli hcard
  have hx := bas.sum_repr x
  have hrepr : ∀ i, bas.repr x i = B (v i) x := fun i => by
    have h := congrArg (B (v i)) hx
    simp only [map_sum, map_smul, smul_eq_mul, bas, coe_basisOfLinearIndependentOfCardEqFinrank, hv,
      mul_ite, mul_one, mul_zero, Finset.sum_ite_eq, Finset.mem_univ, ite_true] at h
    exact h
  conv_lhs => rw [← hx]
  simp only [hrepr, bas, coe_basisOfLinearIndependentOfCardEqFinrank]

variable (a b c) in
/-- The index set `(k₁, k₂, l)` of the first coupling scheme. -/
abbrev IndexA : Type := Σ k₁ : Fin (min a b + 1), StringIndex (a + b - 2 * (k₁ : ℕ)) c

instance : Nonempty (IndexA a b c) := ⟨⟨0, Classical.arbitrary _⟩⟩

/-- The states of the first coupling scheme, as a family indexed by `IndexA`. -/
def vecA (hab : 0 < a + b) (i : IndexA a b c) : Triple a b c := stateA hab i.1 i.2.1 i.2.2

lemma card_indexA : Fintype.card (IndexA a b c) = Module.finrank ℝ (Triple a b c) := by
  rw [Fintype.card_sigma, Module.finrank_tensorProduct, Module.finrank_tensorProduct,
    finrank_standardSl2Module, finrank_standardSl2Module, finrank_standardSl2Module]
  simp only [card_stringIndex]
  rw [← Finset.sum_mul]
  congr 1
  rw [← card_stringIndex (m := a) (n := b), Fintype.card_sigma]
  simp only [Fintype.card_fin]

lemma tripleForm_vecA (hab : 0 < a + b) (hc : 0 < c) (i j : IndexA a b c) :
    tripleForm a b c (vecA hab i) (vecA hab j) = if i = j then 1 else 0 := by
  obtain ⟨k₁, k₂, l⟩ := i
  obtain ⟨k₁', k₂', l'⟩ := j
  simp only [vecA]
  by_cases hk : k₁ = k₁'
  · subst hk
    have h2 := k₂.isLt
    have h2' := k₂'.isLt
    have hl := l.isLt
    rw [stateA, stateA, tripleForm_rTensor_embed, tensorForm_coupledVec (by omega) (by omega)
      (by omega) (by omega) (by omega) (by omega)]
    refine if_congr ⟨fun h => ?_, fun h => ?_⟩ rfl rfl
    · obtain ⟨hk₂, hl'⟩ := h
      obtain rfl : k₂ = k₂' := Fin.ext hk₂
      obtain rfl : l = l' := Fin.ext hl'
      rfl
    · simp only [Sigma.mk.inj_iff, heq_eq_eq, true_and] at h
      obtain ⟨rfl, h'⟩ := h
      exact ⟨rfl, congrArg Fin.val (eq_of_heq h')⟩
  · rw [stateA, stateA, tripleForm_rTensor_embed_of_ne hab _ hk,
      ite_eq_right (fun h => hk (congrArg Sigma.fst h))]

/-- **Completeness.** The states `|(j₁ j₂) j₁₂, j₃; J, M⟩` form an orthonormal basis. -/
lemma eq_sum_vecA (hab : 0 < a + b) (hc : 0 < c) (x : Triple a b c) :
    x = ∑ i, tripleForm a b c (vecA hab i) x • vecA hab i :=
  eq_sum_of_orthonormal _ _ (tripleForm_vecA hab hc) card_indexA x

/-!

### E.2. Separation by `J` and `M`

-/

lemma nat_eq_of_mul_add_two_eq {p q : ℕ} (h : p * (p + 2) = q * (q + 2)) : p = q := by
  rcases lt_trichotomy p q with hpq | hpq | hpq
  · exfalso
    nlinarith
  · exact hpq
  · exfalso
    nlinarith

/-- States of different total `J` or different `M` are orthogonal. -/
lemma tripleForm_stateA_stateB_eq_zero (hab : 0 < a + b) (hbc : 0 < b + c) (ha : 0 < a)
    (hc : 0 < c) {k₁ : Fin (min a b + 1)} {k₃ : Fin (min b c + 1)} {k₂ k₄ l' l : ℕ}
    (h₁ : k₂ ≤ a + b - 2 * (k₁ : ℕ)) (h₂ : k₂ ≤ c) (h₃ : k₄ ≤ a)
    (h₄ : k₄ ≤ b + c - 2 * (k₃ : ℕ)) (h : ¬((k₁ : ℕ) + k₂ = k₃ + k₄ ∧ l' = l)) :
    tripleForm a b c (stateA hab k₁ k₂ l') (stateB hbc k₃ k₄ l) = 0 := by
  by_contra hne
  have hk₁ := k₁.isLt
  have hk₃ := k₃.isLt
  have hC := tripleForm_tripleCas (stateA hab k₁ k₂ l') (stateB hbc k₃ k₄ l)
  rw [tripleCas_stateA hab hc k₁ h₁ h₂, tripleCas_stateB hbc ha k₃ h₃ h₄, map_smul,
    LinearMap.smul_apply, map_smul, smul_eq_mul, smul_eq_mul] at hC
  have hH := tripleForm_tripleH (stateA hab k₁ k₂ l') (stateB hbc k₃ k₄ l)
  rw [tripleH_stateA hab hc k₁ h₁ h₂, tripleH_stateB hbc ha k₃ h₃ h₄, map_smul,
    LinearMap.smul_apply, map_smul, smul_eq_mul, smul_eq_mul] at hH
  have hC' := mul_right_cancel₀ hne hC
  have hH' := mul_right_cancel₀ hne hH
  have hF : a + b - 2 * (k₁ : ℕ) + c - 2 * k₂ = a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄ :=
    nat_eq_of_mul_add_two_eq (by exact_mod_cast (show
      ((a + b - 2 * (k₁ : ℕ) + c - 2 * k₂ : ℕ) : ℝ) *
        (((a + b - 2 * (k₁ : ℕ) + c - 2 * k₂ : ℕ) : ℝ) + 2) =
      ((a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄ : ℕ) : ℝ) *
        (((a + (b + c - 2 * (k₃ : ℕ)) - 2 * k₄ : ℕ) : ℝ) + 2) by linarith))
  rw [hF] at hH'
  have hl : l' = l := by exact_mod_cast (show (l' : ℝ) = l by linarith)
  exact h ⟨by omega, hl⟩

/-!

### E.3. The recoupling coefficients

-/

variable (a b c) in
/-- `k₁` gives an admissible intermediate `j₁₂` for the total `J = (a + b + c)/2 - K`. -/
abbrev ValidA (K k₁ : ℕ) : Prop := k₁ ≤ K ∧ K - k₁ ≤ a + b - 2 * k₁ ∧ K - k₁ ≤ c

variable (a b c) in
/-- `k₃` gives an admissible intermediate `j₂₃` for the total `J = (a + b + c)/2 - K`. -/
abbrev ValidB (K k₃ : ℕ) : Prop := k₃ ≤ K ∧ K - k₃ ≤ a ∧ K - k₃ ≤ b + c - 2 * k₃

/-- The recoupling coefficient `⟨(j₁ j₂) j₁₂, j₃; J M | j₁, (j₂ j₃) j₂₃; J M⟩` with
`J = (a + b + c)/2 - K`, `M = J - l`, `j₁₂ = (a + b)/2 - k₁` and `j₂₃ = (b + c)/2 - k₃`. -/
def recoupling (hab : 0 < a + b) (hbc : 0 < b + c) (K l : ℕ) (k₁ : Fin (min a b + 1))
    (k₃ : Fin (min b c + 1)) : ℝ :=
  tripleForm a b c (stateA hab k₁ (K - k₁) l) (stateB hbc k₃ (K - k₃) l)

lemma recoupling_succ (hab : 0 < a + b) (hbc : 0 < b + c) (ha : 0 < a) {K l : ℕ}
    {k₁ : Fin (min a b + 1)} {k₃ : Fin (min b c + 1)} (hA : ValidA a b c K k₁)
    (hB : ValidB a b c K k₃) (hl : l < a + b + c - 2 * K) :
    recoupling hab hbc K (l + 1) k₁ k₃ = recoupling hab hbc K l k₁ k₃ := by
  obtain ⟨hA1, hA2, hA3⟩ := hA
  obtain ⟨hB1, hB2, hB3⟩ := hB
  have hk₁ := k₁.isLt
  have hk₃ := k₃.isLt
  have hFA : a + b - 2 * (k₁ : ℕ) + c - 2 * (K - k₁) = a + b + c - 2 * K := by omega
  have hFB : a + (b + c - 2 * (k₃ : ℕ)) - 2 * (K - k₃) = a + b + c - 2 * K := by omega
  have hF := tripleF_stateA hab k₁ hA2 hA3 (l := l) (by omega)
  have hE := tripleE_stateB_succ hbc ha k₃ hB2 hB3 (l := l) (by omega)
  rw [hFA] at hF
  rw [hFB] at hE
  have hlF : (l : ℝ) < ((a + b + c - 2 * K : ℕ) : ℝ) := by exact_mod_cast hl
  have hpos : 0 < Real.sqrt (((l : ℝ) + 1) * (((a + b + c - 2 * K : ℕ) : ℝ) - l)) :=
    Real.sqrt_pos.mpr (mul_pos (by positivity) (by linarith))
  have key := tripleForm_tripleF (stateA hab k₁ (K - k₁) l) (stateB hbc k₃ (K - k₃) (l + 1))
  rw [hF, hE, map_smul, LinearMap.smul_apply, map_smul, smul_eq_mul, smul_eq_mul] at key
  exact mul_left_cancel₀ hpos.ne' key

/-- The recoupling coefficients do not depend on `M`. -/
lemma recoupling_eq_recoupling_zero (hab : 0 < a + b) (hbc : 0 < b + c) (ha : 0 < a)
    {K l : ℕ} {k₁ : Fin (min a b + 1)} {k₃ : Fin (min b c + 1)} (hA : ValidA a b c K k₁)
    (hB : ValidB a b c K k₃) (hl : l ≤ a + b + c - 2 * K) :
    recoupling hab hbc K l k₁ k₃ = recoupling hab hbc K 0 k₁ k₃ := by
  induction l with
  | zero => rfl
  | succ l ih => rw [recoupling_succ hab hbc ha hA hB (by omega), ih (by omega)]

/-!

### E.4. Orthogonality

-/

/-- **Orthogonality of the recoupling coefficients.** For fixed `J` and `M`,
`Σ_{j₁₂} ⟨(j₁ j₂) j₁₂, j₃; J M | j₁, (j₂ j₃) j₂₃; J M⟩ ⟨(j₁ j₂) j₁₂, j₃; J M |
j₁, (j₂ j₃) j₂₃'; J M⟩ = δ_{j₂₃ j₂₃'}`. -/
lemma sum_recoupling_mul_recoupling (hab : 0 < a + b) (hbc : 0 < b + c) (ha : 0 < a)
    (hc : 0 < c) {K l : ℕ} (hl : l ≤ a + b + c - 2 * K) {k₃ k₃' : Fin (min b c + 1)}
    (hB : ValidB a b c K k₃) (hB' : ValidB a b c K k₃') :
    ∑ k₁ : Fin (min a b + 1), (if ValidA a b c K k₁ then
      recoupling hab hbc K l k₁ k₃ * recoupling hab hbc K l k₁ k₃' else 0) =
        if k₃ = k₃' then 1 else 0 := by
  obtain ⟨hB1, hB2, hB3⟩ := hB
  obtain ⟨hB1', hB2', hB3'⟩ := hB'
  have hk₃ := k₃.isLt
  have hk₃' := k₃'.isLt
  have hBB : tripleForm a b c (stateB hbc k₃ (K - k₃) l) (stateB hbc k₃' (K - k₃') l) =
      if k₃ = k₃' then 1 else 0 := by
    by_cases hk : k₃ = k₃'
    · subst hk
      rw [ite_eq_left rfl, tripleForm_stateB_self hbc ha k₃ hB2 hB3 (by omega)]
    · rw [ite_eq_right hk, tripleForm_stateB_of_ne hbc k₃ hk]
  rw [← hBB]
  conv_rhs => rw [eq_sum_vecA hab hc (stateB hbc k₃' (K - k₃') l)]
  rw [map_sum, Fintype.sum_sigma]
  refine Finset.sum_congr rfl fun k₁ _ => ?_
  have hk₁ := k₁.isLt
  rw [Fintype.sum_sigma]
  by_cases hv : ValidA a b c K k₁
  · obtain ⟨hA1, hA2, hA3⟩ := hv
    rw [ite_eq_left ⟨hA1, hA2, hA3⟩]
    have hk₂ : K - (k₁ : ℕ) < min (a + b - 2 * (k₁ : ℕ)) c + 1 := by omega
    rw [Fintype.sum_eq_single ⟨K - k₁, hk₂⟩]
    · have hl' : l < a + b - 2 * (k₁ : ℕ) + c - 2 * (K - k₁) + 1 := by omega
      rw [Fintype.sum_eq_single ⟨l, hl'⟩]
      · simp only [vecA, map_smul, smul_eq_mul, recoupling]
        rw [tripleForm_comm (stateB hbc k₃ (K - k₃) l)]
        ring
      · intro l' hl''
        simp only [vecA, map_smul, smul_eq_mul]
        rw [tripleForm_stateA_stateB_eq_zero hab hbc ha hc hA2 hA3 hB2' hB3'
          (fun h => hl'' (Fin.ext h.2)), zero_mul]
    · intro k₂ hk₂'
      have := k₂.isLt
      refine Finset.sum_eq_zero fun l' _ => ?_
      simp only [vecA, map_smul, smul_eq_mul]
      rw [tripleForm_stateA_stateB_eq_zero hab hbc ha hc (by omega) (by omega) hB2' hB3'
        (fun h => hk₂' (Fin.ext (show (k₂ : ℕ) = K - (k₁ : ℕ) by have := h.1; omega))),
        zero_mul]
  · rw [ite_eq_right hv]
    refine (Finset.sum_eq_zero fun k₂ _ => ?_).symm
    refine Finset.sum_eq_zero fun l' _ => ?_
    have := k₂.isLt
    simp only [vecA, map_smul, smul_eq_mul]
    rw [tripleForm_stateA_stateB_eq_zero hab hbc ha hc (by omega) (by omega) hB2' hB3'
      (fun h => hv (by obtain ⟨h1, _⟩ := h; exact ⟨by omega, by omega, by omega⟩)), zero_mul]

/-!

## F. The 6j symbols

-/

/-- The **6j symbol** `{j₁ j₂ j₁₂; j₃ J j₂₃}`, with `j₁ = a/2`, `j₂ = b/2`, `j₃ = c/2`,
`j₁₂ = (a + b)/2 - k₁`, `j₂₃ = (b + c)/2 - k₃` and `J = (a + b + c)/2 - K`, defined through
`⟨(j₁ j₂) j₁₂, j₃; J | j₁, (j₂ j₃) j₂₃; J⟩ = (-1)^(j₁ + j₂ + j₃ + J) √((2j₁₂ + 1)(2j₂₃ + 1)) {6j}`
(`j₁ + j₂ + j₃ + J = a + b + c - K`), and zero for inadmissible arguments. -/
def sixJ (hab : 0 < a + b) (hbc : 0 < b + c) (K : ℕ) (k₁ : Fin (min a b + 1))
    (k₃ : Fin (min b c + 1)) : ℝ :=
  if ValidA a b c K k₁ ∧ ValidB a b c K k₃ then
    (-1) ^ (a + b + c - K) * recoupling hab hbc K 0 k₁ k₃ /
      Real.sqrt (((a + b - 2 * (k₁ : ℕ) + 1 : ℕ) : ℝ) * ((b + c - 2 * (k₃ : ℕ) + 1 : ℕ) : ℝ))
  else 0

/-- The recoupling coefficients in terms of the 6j symbols, for every `M`. -/
lemma recoupling_eq_sixJ (hab : 0 < a + b) (hbc : 0 < b + c) (ha : 0 < a) {K l : ℕ}
    {k₁ : Fin (min a b + 1)} {k₃ : Fin (min b c + 1)} (hA : ValidA a b c K k₁)
    (hB : ValidB a b c K k₃) (hl : l ≤ a + b + c - 2 * K) :
    recoupling hab hbc K l k₁ k₃ = (-1) ^ (a + b + c - K) *
      Real.sqrt (((a + b - 2 * (k₁ : ℕ) + 1 : ℕ) : ℝ) * ((b + c - 2 * (k₃ : ℕ) + 1 : ℕ) : ℝ)) *
        sixJ hab hbc K k₁ k₃ := by
  have hpos : 0 < Real.sqrt (((a + b - 2 * (k₁ : ℕ) + 1 : ℕ) : ℝ) *
      ((b + c - 2 * (k₃ : ℕ) + 1 : ℕ) : ℝ)) := Real.sqrt_pos.mpr (by positivity)
  have hs : ((-1 : ℝ) ^ (a + b + c - K)) * (-1) ^ (a + b + c - K) = 1 := by
    rw [← pow_add, ← two_mul, pow_mul, neg_one_sq, one_pow]
  rw [sixJ, ite_eq_left ⟨hA, hB⟩, recoupling_eq_recoupling_zero hab hbc ha hA hB hl]
  field_simp
  linear_combination (-(recoupling hab hbc K 0 k₁ k₃)) * hs

lemma mul_mul_div_mul_div_sqrt {s U U' p₁ p₃ p₃' : ℝ} (hs : s * s = 1) (h₁ : 0 < p₁) :
    p₁ * p₃ * (s * U / Real.sqrt (p₁ * p₃)) * (s * U' / Real.sqrt (p₁ * p₃')) =
      Real.sqrt p₃ / Real.sqrt p₃' * (U * U') := by
  rw [Real.sqrt_mul h₁.le, Real.sqrt_mul h₁.le]
  have e₁ := Real.mul_self_sqrt h₁.le
  calc _ = (s * s) * (p₁ / (Real.sqrt p₁ * Real.sqrt p₁)) * (p₃ / Real.sqrt p₃) *
        (U * U' / Real.sqrt p₃') := by ring
    _ = _ := by rw [hs, e₁, div_self h₁.ne', Real.div_sqrt]; ring

/-- **Orthogonality of the 6j symbols.**
`Σ_{j₁₂} (2j₁₂ + 1)(2j₂₃ + 1) {j₁ j₂ j₁₂; j₃ J j₂₃} {j₁ j₂ j₁₂; j₃ J j₂₃'} = δ_{j₂₃ j₂₃'}`. -/
lemma sum_sixJ_mul_sixJ (hab : 0 < a + b) (hbc : 0 < b + c) (ha : 0 < a) (hc : 0 < c)
    {K : ℕ} {k₃ k₃' : Fin (min b c + 1)} (hB : ValidB a b c K k₃)
    (hB' : ValidB a b c K k₃') :
    ∑ k₁ : Fin (min a b + 1), ((a + b - 2 * (k₁ : ℕ) + 1 : ℕ) : ℝ) *
      ((b + c - 2 * (k₃ : ℕ) + 1 : ℕ) : ℝ) * sixJ hab hbc K k₁ k₃ * sixJ hab hbc K k₁ k₃' =
        if k₃ = k₃' then 1 else 0 := by
  have hs : ((-1 : ℝ) ^ (a + b + c - K)) * (-1) ^ (a + b + c - K) = 1 := by
    rw [← pow_add, ← two_mul, pow_mul, neg_one_sq, one_pow]
  have key : ∀ k₁ : Fin (min a b + 1), ((a + b - 2 * (k₁ : ℕ) + 1 : ℕ) : ℝ) *
      ((b + c - 2 * (k₃ : ℕ) + 1 : ℕ) : ℝ) * sixJ hab hbc K k₁ k₃ * sixJ hab hbc K k₁ k₃' =
      Real.sqrt ((b + c - 2 * (k₃ : ℕ) + 1 : ℕ) : ℝ) /
        Real.sqrt ((b + c - 2 * (k₃' : ℕ) + 1 : ℕ) : ℝ) *
        (if ValidA a b c K k₁ then
          recoupling hab hbc K 0 k₁ k₃ * recoupling hab hbc K 0 k₁ k₃' else 0) := fun k₁ => by
    by_cases hv : ValidA a b c K k₁
    · rw [sixJ, sixJ, ite_eq_left ⟨hv, hB⟩, ite_eq_left ⟨hv, hB'⟩, ite_eq_left hv]
      exact mul_mul_div_mul_div_sqrt hs (by positivity)
    · rw [sixJ, ite_eq_right (fun h => hv h.1), ite_eq_right hv]
      ring
  rw [Finset.sum_congr rfl fun k₁ _ => key k₁, ← Finset.mul_sum,
    sum_recoupling_mul_recoupling hab hbc ha hc (Nat.zero_le _) hB hB']
  by_cases hk : k₃ = k₃'
  · subst hk
    have hpos : 0 < Real.sqrt ((b + c - 2 * (k₃ : ℕ) + 1 : ℕ) : ℝ) :=
      Real.sqrt_pos.mpr (by positivity)
    rw [ite_eq_left rfl, div_self hpos.ne', one_mul]
  · rw [ite_eq_right hk, mul_zero]

end Coupled

end PhyslibAlpha.Sl2
