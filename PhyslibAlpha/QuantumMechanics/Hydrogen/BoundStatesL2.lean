/-
Copyright (c) 2026 Daniel Leonforte. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Leonforte
-/
module

public import PhyslibAlpha.QuantumMechanics.Hydrogen.Degeneracy
public import Physlib.QuantumMechanics.HilbertSpaces.SpaceD.Basic
public import Mathlib.Analysis.SpecialFunctions.JapaneseBracket

/-!
# The hydrogen bound states in `L²`

## i. Overview

The bound states `boundState H N l P` of `Eigenfunctions.lean` are square integrable: they are a
polynomial in the coordinates and in `‖y‖` times `e^(-κ‖y‖)`, and such functions decay faster than
any power of `1 + ‖y‖`. They therefore define vectors of the Hilbert space `SpaceDHilbertSpace d`.
Since they are continuous, the linear independence of the bound states of one level
(`boundStateMap_injective`) carries over to the Hilbert space.

## ii. Key results

- `IsPolyBounded` : at most polynomial growth `|f y| ≤ C (1 + ‖y‖)^k`.
- `integrable_sq_of_le_mul_exp` : `f²` is integrable if `|f| ≤ |g| e^(-c‖y‖)` with `g` polynomially
  bounded and `c > 0`.
- `memHS_boundState`, `boundStateHS` : the bound states as vectors of `SpaceDHilbertSpace d`.
- `boundStateMapHS_injective` : the bound states of one level are linearly independent in
  `SpaceDHilbertSpace d`.
- `finrank_range_boundStateMapHS_three` : in three dimensions they span a space of
  dimension `(n + 1)²`.

## iii. Table of contents

- A. Polynomially bounded functions
- B. Exponential decay and integrability
- C. The bound states in the Hilbert space
- D. Linear independence in the Hilbert space

## iv. References

- None.
-/

@[expose] public section

noncomputable section

namespace PhyslibAlpha.Hydrogen

open MeasureTheory Space

/-!

## A. Polynomially bounded functions

-/

/-- `f` grows at most polynomially: `|f y| ≤ C (1 + ‖y‖)^k` for some `C ≥ 0` and `k`. -/
def IsPolyBounded {d : ℕ} (f : Space d → ℝ) : Prop :=
  ∃ (C : ℝ) (k : ℕ), 0 ≤ C ∧ ∀ y, |f y| ≤ C * (1 + ‖y‖) ^ k

namespace IsPolyBounded

variable {d : ℕ} {f g : Space d → ℝ}

lemma one_le_one_add_norm (y : Space d) : 1 ≤ 1 + ‖y‖ :=
  le_add_of_nonneg_right (norm_nonneg _)

lemma const (a : ℝ) : IsPolyBounded (fun _ : Space d => a) :=
  ⟨|a|, 0, abs_nonneg a, fun y => by simp⟩

lemma add (hf : IsPolyBounded f) (hg : IsPolyBounded g) :
    IsPolyBounded (fun y => f y + g y) := by
  obtain ⟨C₁, k₁, hC₁, h₁⟩ := hf
  obtain ⟨C₂, k₂, hC₂, h₂⟩ := hg
  refine ⟨C₁ + C₂, max k₁ k₂, by positivity, fun y => ?_⟩
  have e₁ : (1 + ‖y‖) ^ k₁ ≤ (1 + ‖y‖) ^ max k₁ k₂ :=
    pow_le_pow_right₀ (one_le_one_add_norm y) (le_max_left _ _)
  have e₂ : (1 + ‖y‖) ^ k₂ ≤ (1 + ‖y‖) ^ max k₁ k₂ :=
    pow_le_pow_right₀ (one_le_one_add_norm y) (le_max_right _ _)
  calc |f y + g y| ≤ |f y| + |g y| := abs_add_le _ _
    _ ≤ C₁ * (1 + ‖y‖) ^ k₁ + C₂ * (1 + ‖y‖) ^ k₂ := add_le_add (h₁ y) (h₂ y)
    _ ≤ C₁ * (1 + ‖y‖) ^ max k₁ k₂ + C₂ * (1 + ‖y‖) ^ max k₁ k₂ := by gcongr
    _ = (C₁ + C₂) * (1 + ‖y‖) ^ max k₁ k₂ := by ring

lemma mul (hf : IsPolyBounded f) (hg : IsPolyBounded g) :
    IsPolyBounded (fun y => f y * g y) := by
  obtain ⟨C₁, k₁, hC₁, h₁⟩ := hf
  obtain ⟨C₂, k₂, hC₂, h₂⟩ := hg
  refine ⟨C₁ * C₂, k₁ + k₂, mul_nonneg hC₁ hC₂, fun y => ?_⟩
  rw [abs_mul, pow_add]
  calc |f y| * |g y| ≤ (C₁ * (1 + ‖y‖) ^ k₁) * (C₂ * (1 + ‖y‖) ^ k₂) :=
        mul_le_mul (h₁ y) (h₂ y) (abs_nonneg _) (by positivity)
    _ = C₁ * C₂ * ((1 + ‖y‖) ^ k₁ * (1 + ‖y‖) ^ k₂) := by ring

lemma pow (hf : IsPolyBounded f) (n : ℕ) : IsPolyBounded (fun y => f y ^ n) := by
  induction n with
  | zero => exact ⟨1, 0, zero_le_one, fun y => by simp⟩
  | succ n ih => simpa only [pow_succ] using ih.mul hf

lemma coord (i : Fin d) : IsPolyBounded (fun y : Space d => y i) :=
  ⟨1, 1, zero_le_one, fun y => by
    have := Space.abs_eval_le_norm y i
    simp only [one_mul, pow_one]
    linarith [norm_nonneg y]⟩

lemma norm : IsPolyBounded (fun y : Space d => ‖y‖) :=
  ⟨1, 1, zero_le_one, fun y => by
    rw [abs_of_nonneg (norm_nonneg y), one_mul, pow_one]
    linarith⟩

/-- Polynomials in the coordinates are polynomially bounded. -/
lemma toFun (P : MvPolynomial (Fin d) ℝ) : IsPolyBounded (toFun P) := by
  induction P using MvPolynomial.induction_on with
  | C a => rw [toFun_C]; exact const a
  | add P Q hP hQ => rw [toFun_add]; exact hP.add hQ
  | mul_X P j hP => rw [toFun_mul_X]; exact hP.mul (coord j)

/-- A polynomial of a polynomially bounded function is polynomially bounded. -/
lemma polynomial_eval (p : Polynomial ℝ) (hf : IsPolyBounded f) :
    IsPolyBounded (fun y => p.eval (f y)) := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq => simpa only [Polynomial.eval_add] using hp.add hq
  | monomial n a =>
    simp only [Polynomial.eval_monomial]
    exact (const a).mul (hf.pow n)

lemma sum {ι : Type*} (s : Finset ι) {F : ι → Space d → ℝ} (h : ∀ i ∈ s, IsPolyBounded (F i)) :
    IsPolyBounded (fun y => ∑ i ∈ s, F i y) := by
  classical
  induction s using Finset.induction_on with
  | empty => exact ⟨0, 0, le_rfl, fun y => by simp⟩
  | insert a s ha ih =>
    simp only [Finset.sum_insert ha]
    exact (h a (Finset.mem_insert_self a s)).add
      (ih fun i hi => h i (Finset.mem_insert_of_mem hi))

end IsPolyBounded

/-!

## B. Exponential decay and integrability

-/

/-- `(1 + t)^m e^(-c t) ≤ e^c m! / c^m` for `c > 0` and `t ≥ 0`, from `x^m / m! ≤ e^x`. -/
lemma one_add_pow_mul_exp_neg_le {c : ℝ} (hc : 0 < c) (m : ℕ) {t : ℝ} (ht : 0 ≤ t) :
    (1 + t) ^ m * Real.exp (-(c * t)) ≤ Real.exp c * m.factorial / c ^ m := by
  have h := Real.pow_div_factorial_le_exp (x := c * (1 + t)) (by positivity) m
  rw [mul_pow, div_le_iff₀ (by positivity), show c * (1 + t) = c + c * t by ring,
    Real.exp_add] at h
  rw [le_div_iff₀ (by positivity)]
  calc (1 + t) ^ m * Real.exp (-(c * t)) * c ^ m
      = c ^ m * (1 + t) ^ m * Real.exp (-(c * t)) := by ring
    _ ≤ Real.exp c * Real.exp (c * t) * m.factorial * Real.exp (-(c * t)) := by gcongr
    _ = Real.exp c * m.factorial := by
      rw [mul_right_comm _ (m.factorial : ℝ), mul_assoc _ (Real.exp (c * t)), ← Real.exp_add,
        add_neg_cancel, Real.exp_zero, mul_one]

/-- If `|f y| ≤ |g y| e^(-c‖y‖)` with `g` polynomially bounded and `c > 0`, then `f²` is
integrable: it is bounded by a multiple of `(1 + ‖y‖)^(-(d+1))`. -/
lemma integrable_sq_of_le_mul_exp {d : ℕ} {f g : Space d → ℝ} {c : ℝ} (hc : 0 < c)
    (hfm : AEStronglyMeasurable f) (hg : IsPolyBounded g)
    (hfg : ∀ y, |f y| ≤ |g y| * Real.exp (-(c * ‖y‖))) :
    Integrable (fun y => f y ^ 2) := by
  obtain ⟨C, k, hC, hgC⟩ := hg
  set m := 2 * k + (d + 1)
  set B := C ^ 2 * (Real.exp (2 * c) * m.factorial / (2 * c) ^ m)
  have hint : Integrable (fun y : Space d => B * (1 + ‖y‖) ^ (-((d + 1 : ℕ) : ℝ))) :=
    (integrable_one_add_norm (by simp [Space.finrank_eq_dim])).const_mul B
  refine hint.mono' (hfm.pow 2) (Filter.Eventually.of_forall fun y => ?_)
  have hpos : 0 < 1 + ‖y‖ := by linarith [norm_nonneg y]
  have hdec := one_add_pow_mul_exp_neg_le (c := 2 * c) (by positivity) m (norm_nonneg y)
  rw [Real.rpow_neg hpos.le, Real.rpow_natCast]
  have hf2 : f y ^ 2 ≤ (C * (1 + ‖y‖) ^ k) ^ 2 * Real.exp (-(2 * c * ‖y‖)) := by
    have h1 : |f y| ≤ C * (1 + ‖y‖) ^ k * Real.exp (-(c * ‖y‖)) :=
      (hfg y).trans (by gcongr; exact hgC y)
    have h2 : f y ^ 2 ≤ (C * (1 + ‖y‖) ^ k * Real.exp (-(c * ‖y‖))) ^ 2 := by
      rw [← sq_abs]; gcongr
    rw [mul_pow, ← Real.exp_nat_mul] at h2
    convert h2 using 3
    push_cast; ring
  rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
  calc f y ^ 2 ≤ (C * (1 + ‖y‖) ^ k) ^ 2 * Real.exp (-(2 * c * ‖y‖)) := hf2
    _ = C ^ 2 * ((1 + ‖y‖) ^ m * Real.exp (-(2 * c * ‖y‖))) * ((1 + ‖y‖) ^ (d + 1))⁻¹ := by
      field_simp
      ring
    _ ≤ B * ((1 + ‖y‖) ^ (d + 1))⁻¹ := by
      simp only [B]
      gcongr

/-!

## C. The bound states in the Hilbert space

-/

open QuantumMechanics

/-- The decay constant `κ = 1/(a L_n)` of a bound state is positive for `k > 0` and `d ≥ 2`. -/
lemma boundKappa_pos (H : HydrogenAtom) (hd : 2 ≤ H.d) (hk : 0 < H.k) (n : ℕ) :
    0 < boundKappa H n :=
  one_div_pos.mpr (mul_pos (bohrRadius_pos H hk) (H.levelIndex_pos hd n))

lemma continuous_boundState (H : HydrogenAtom) (N l : ℕ) (P : MvPolynomial (Fin H.d) ℝ) :
    Continuous (boundState H N l (toFun P)) := by
  have hP : Continuous (toFun P) := (contDiff_toFun_infty P).continuous
  unfold boundState radialFactor
  fun_prop

/-- The bound states are square integrable. -/
lemma memHS_boundState (H : HydrogenAtom) (hd : 2 ≤ H.d) (hk : 0 < H.k) (N l : ℕ)
    (P : MvPolynomial (Fin H.d) ℝ) :
    SpaceDHilbertSpace.MemHS (fun y => (boundState H N l (toFun P) y : ℂ)) := by
  have hc : Continuous fun y => (boundState H N l (toFun P) y : ℂ) :=
    Complex.continuous_ofReal.comp (continuous_boundState H N l P)
  rw [SpaceDHilbertSpace.MemHS, memLp_two_iff_integrable_sq_norm hc.aestronglyMeasurable]
  have hint := integrable_sq_of_le_mul_exp (boundKappa_pos H hd hk (N + l))
    (continuous_boundState H N l P).aestronglyMeasurable
    ((IsPolyBounded.norm.polynomial_eval (laguerreScaled (boundKappa H (N + l)) N
      (2 * l + H.d - 2))).mul (IsPolyBounded.toFun P))
    (fun y => by
      simp only [boundState, radialFactor, abs_mul, abs_of_pos (Real.exp_pos _)]
      exact le_of_eq (by ring))
  simpa [Complex.norm_real, sq_abs] using hint

/-- The bound state `boundState H N l P` as a vector of `SpaceDHilbertSpace d`. -/
def boundStateHS (H : HydrogenAtom) (hd : 2 ≤ H.d) (hk : 0 < H.k) (N l : ℕ)
    (P : MvPolynomial (Fin H.d) ℝ) : SpaceDHilbertSpace H.d :=
  SpaceDHilbertSpace.mk (memHS_boundState H hd hk N l P)

/-!

## D. Linear independence in the Hilbert space

All bound states of the level `n` share the decay constant `κ = boundKappa H n`, so their sums
are again `e^(-κ‖y‖)` times a polynomially bounded function.

-/

/-- `Σ_l boundState H (n - l) l P_l = e^(-κ‖y‖) Σ_l L_l(‖y‖) P_l(y)` with `κ = boundKappa H n`. -/
lemma boundStateMap_apply (H : HydrogenAtom) (n : ℕ)
    (Ps : (l : Fin (n + 1)) → harmonicSubmodule H.d l) (y : Space H.d) :
    boundStateMap H n Ps y = Real.exp (-(boundKappa H n * ‖y‖)) *
      ∑ l : Fin (n + 1), (laguerreScaled (boundKappa H n) (n - l) (2 * l + H.d - 2)).eval ‖y‖ *
        toFun (Ps l : MvPolynomial (Fin H.d) ℝ) y := by
  simp only [boundStateMap, LinearMap.coe_mk, AddHom.coe_mk, Finset.sum_apply, Finset.mul_sum]
  refine Finset.sum_congr rfl fun l _ => ?_
  rw [boundState, Nat.sub_add_cancel (Nat.lt_succ_iff.mp l.isLt), radialFactor]
  ring

lemma continuous_boundStateMap (H : HydrogenAtom) (n : ℕ)
    (Ps : (l : Fin (n + 1)) → harmonicSubmodule H.d l) : Continuous (boundStateMap H n Ps) := by
  have h : boundStateMap H n Ps = fun y => ∑ l : Fin (n + 1),
      boundState H (n - l) l (toFun (Ps l : MvPolynomial (Fin H.d) ℝ)) y := by
    funext y
    simp [boundStateMap, Finset.sum_apply]
  rw [h]
  exact continuous_finsetSum _ fun l _ => continuous_boundState H _ _ _

/-- The sums of bound states of one level are square integrable. -/
lemma memHS_boundStateMap (H : HydrogenAtom) (hd : 2 ≤ H.d) (hk : 0 < H.k) (n : ℕ)
    (Ps : (l : Fin (n + 1)) → harmonicSubmodule H.d l) :
    SpaceDHilbertSpace.MemHS (fun y => (boundStateMap H n Ps y : ℂ)) := by
  have hc : Continuous fun y => (boundStateMap H n Ps y : ℂ) :=
    Complex.continuous_ofReal.comp (continuous_boundStateMap H n Ps)
  rw [SpaceDHilbertSpace.MemHS, memLp_two_iff_integrable_sq_norm hc.aestronglyMeasurable]
  have hint := integrable_sq_of_le_mul_exp (boundKappa_pos H hd hk n)
    (continuous_boundStateMap H n Ps).aestronglyMeasurable
    (IsPolyBounded.sum Finset.univ fun l _ =>
      (IsPolyBounded.norm.polynomial_eval _).mul (IsPolyBounded.toFun _))
    (fun y => by
      rw [boundStateMap_apply, abs_mul, abs_of_pos (Real.exp_pos _), mul_comm])
  simpa [Complex.norm_real, sq_abs] using hint

/-- The bound states of the level `n` as an `ℝ`-linear map into `SpaceDHilbertSpace d`. -/
def boundStateMapHS (H : HydrogenAtom) (hd : 2 ≤ H.d) (hk : 0 < H.k) (n : ℕ) :
    ((l : Fin (n + 1)) → harmonicSubmodule H.d l) →ₗ[ℝ] SpaceDHilbertSpace H.d where
  toFun Ps := SpaceDHilbertSpace.mk (memHS_boundStateMap H hd hk n Ps)
  map_add' Ps Qs := by
    rw [SpaceDHilbertSpace.ext_iff]
    filter_upwards [SpaceDHilbertSpace.coeFn_mk (memHS_boundStateMap H hd hk n (Ps + Qs)),
      SpaceDHilbertSpace.coeFn_mk (memHS_boundStateMap H hd hk n Ps),
      SpaceDHilbertSpace.coeFn_mk (memHS_boundStateMap H hd hk n Qs),
      Lp.coeFn_add (SpaceDHilbertSpace.mk (memHS_boundStateMap H hd hk n Ps))
        (SpaceDHilbertSpace.mk (memHS_boundStateMap H hd hk n Qs))] with y h₁ h₂ h₃ h₄
    rw [h₁, h₄, Pi.add_apply, h₂, h₃, map_add, Pi.add_apply, Complex.ofReal_add]
  map_smul' c Ps := by
    rw [SpaceDHilbertSpace.ext_iff]
    filter_upwards [SpaceDHilbertSpace.coeFn_mk (memHS_boundStateMap H hd hk n (c • Ps)),
      SpaceDHilbertSpace.coeFn_mk (memHS_boundStateMap H hd hk n Ps),
      Lp.coeFn_smul c (SpaceDHilbertSpace.mk (memHS_boundStateMap H hd hk n Ps))] with y h₁ h₂ h₃
    rw [h₁, RingHom.id_apply, h₃, Pi.smul_apply, h₂, map_smul, Pi.smul_apply, smul_eq_mul,
      Complex.ofReal_mul, Complex.real_smul]

/-- The bound states of one level are linearly independent in `SpaceDHilbertSpace d`. -/
lemma boundStateMapHS_injective (H : HydrogenAtom) (hd : 2 ≤ H.d) (hk : 0 < H.k) (n : ℕ) :
    Function.Injective (boundStateMapHS H hd hk n) := by
  rw [← LinearMap.ker_eq_bot, LinearMap.ker_eq_bot']
  intro Ps h
  apply boundStateMap_injective H n
  rw [map_zero]
  have hae : (fun y => (boundStateMap H n Ps y : ℂ)) =ᵐ[volume] 0 :=
    (SpaceDHilbertSpace.coeFn_mk (memHS_boundStateMap H hd hk n Ps)).symm.trans
      ((show SpaceDHilbertSpace.mk (memHS_boundStateMap H hd hk n Ps) = 0 from h) ▸
        Lp.coeFn_zero ℂ 2 volume)
  have hcont := Complex.continuous_ofReal.comp (continuous_boundStateMap H n Ps)
  have h0 := (hcont.ae_eq_iff_eq volume continuous_const).mp hae
  funext y
  simpa using (Complex.ext_iff.mp (congr_fun h0 y)).1

/-- In three dimensions the bound states of the level `n` span a `(n + 1)²`-dimensional subspace
of `SpaceDHilbertSpace 3`. -/
lemma finrank_range_boundStateMapHS_three (H : HydrogenAtom) (hd : H.d = 3) (hk : 0 < H.k)
    (n : ℕ) :
    Module.finrank ℝ (LinearMap.range (boundStateMapHS H (by omega) hk n)) = (n + 1) ^ 2 := by
  rw [LinearMap.finrank_range_of_inj (boundStateMapHS_injective H _ hk n),
    ← LinearMap.finrank_range_of_inj (boundStateMap_injective H n),
    finrank_range_boundStateMap_three H hd n]

end PhyslibAlpha.Hydrogen
