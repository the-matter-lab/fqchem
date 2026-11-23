/-
The private wireGate_mulVec_update lemma is adapted from Qatlib.
Copyright (c) 2026 Qatlib Contributors. All rights reserved.
Released under Apache 2.0 license as described in the repository LICENSE.
-/
module

public import FQChemKitaev.Majority

/-!
# Embedding a finite Clifford+T word in a larger register

Rewriting the wire addresses of a legal gate word permits the same verifier to run
on independently prepared registers. The proof tracks the full quantum amplitudes.
The single-wire amplitude expansion is adapted from
[Qatlib Contributors](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvFilter/SignedLowerBoundAuxiliary.lean#L204).
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.Kitaev.Wiring

open Qatlib.Foundations.QueryWordCore.Circuit Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Matrix
open scoped Classical

private theorem wireGate_mulVec_update {n : ℕ} (w : Fin n) (U : Matrix Bool Bool ℂ)
    (ψ : QState (Reg n)) (z : Reg n) :
    (wireGate n w U *ᵥ ψ) z = ∑ b : Bool, U (z w) b * ψ (Function.update z w b) := by
  have hexp : (wireGate n w U *ᵥ ψ) z = ∑ y : Reg n, wireGate n w U z y * ψ y := by
    simp [Matrix.mulVec, dotProduct]
  rw [hexp]
  have hcond : ∀ y : Reg n, (∀ k : Fin n, k ≠ w → z k = y k) →
      y = Function.update z w (y w) := by
    intro y hy
    funext i
    by_cases hi : i = w
    · subst hi
      simp
    · have h1 : Function.update z w (y w) i = z i := by
        simp [Function.update_of_ne hi]
      rw [h1, hy i hi]
  have hinj : Set.InjOn (fun b : Bool => Function.update z w b)
      (Finset.univ : Finset Bool) := by
    intro b₁ _ b₂ _ h
    have := congrFun h w
    simp at this
    exact this
  have hfilter : (Finset.univ : Finset (Reg n)).filter (fun y => ∀ k : Fin n, k ≠ w → z k = y k)
      = (Finset.univ : Finset Bool).image (fun b => Function.update z w b) := by
    ext y
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · intro hy
      exact Exists.intro (y w) ((hcond y hy).symm)
    · intro hy
      obtain ⟨b, hb⟩ := hy
      have hyz : y = Function.update z w b := hb.symm
      subst hyz
      intro k hk
      simp [Function.update_of_ne hk]
  have houtside : ∀ y : Reg n, ¬(∀ k : Fin n, k ≠ w → z k = y k) →
      wireGate n w U z y * ψ y = 0 := by
    intro y hy
    rw [wireGate_apply, ite_eq_right hy, zero_mul]
  have hpart : (∑ y : Reg n, wireGate n w U z y * ψ y)
      = ∑ y ∈ (Finset.univ : Finset (Reg n)).filter (fun y => ∀ k : Fin n, k ≠ w → z k = y k),
        wireGate n w U z y * ψ y := by
    have hz : (∑ y ∈ (Finset.univ : Finset (Reg n)).filter
        (fun y => ¬(∀ k : Fin n, k ≠ w → z k = y k)), wireGate n w U z y * ψ y) = 0 :=
      Finset.sum_eq_zero (fun y hy => houtside y (by simpa using! hy))
    conv_lhs => rw [← Finset.sum_filter_add_sum_filter_not (s := (Finset.univ : Finset (Reg n)))
      (p := fun y : Reg n => ∀ k : Fin n, k ≠ w → z k = y k)]
    rw [hz, add_zero]
  rw [hpart]
  have hstep : (∑ y ∈ (Finset.univ : Finset (Reg n)).filter
        (fun y => ∀ k : Fin n, k ≠ w → z k = y k), wireGate n w U z y * ψ y)
      = ∑ y ∈ (Finset.univ : Finset Bool).image (fun b => Function.update z w b),
        U (z w) (y w) * ψ y := by
    rw [hfilter]
    refine Finset.sum_congr rfl ?_
    intro y hy
    have hy' : ∀ k : Fin n, k ≠ w → z k = y k := by
      obtain ⟨b, _, hb⟩ := by simpa only [Finset.mem_image] using! hy
      intro k hk
      rw [← hb]
      simp [Function.update_of_ne hk]
    rw [wireGate_apply, ite_eq_left hy']
  rw [hstep, Finset.sum_image hinj]
  simp only [Function.update_self]

variable {n N : ℕ}

/-- Address substitution for all five instructions, including both CNOT wires. -/
def renameGate (f : ℕ → ℕ) : FiniteGateCode → FiniteGateCode
  | .h i => .h (f i)
  | .x i => .x (f i)
  | .t i => .t (f i)
  | .tdg i => .tdg (f i)
  | .cx i j => .cx (f i) (f j)

def address (e : Fin n ↪ Fin N) (i : ℕ) : ℕ := if h : i < n then (e ⟨i,h⟩).val else N

/-- Multiplying a local amplitude by a factor depending only on the other wires. -/
def extendState (e : Fin n ↪ Fin N) (ψ : QState (Reg n)) (spectator : QState (Reg N)) :
    QState (Reg N) := fun x => ψ (x ∘ e) * spectator x

def OffWires (e : Fin n ↪ Fin N) (f : QState (Reg N)) : Prop :=
  ∀ x i b, f (Function.update x (e i) b) = f x

private theorem one_wire (e : Fin n ↪ Fin N) (i : Fin n) (U : Matrix Bool Bool ℂ)
    (ψ : QState (Reg n)) (r : QState (Reg N)) (hr : OffWires e r) :
    ApplyGate (wireGate N (e i) U) (extendState e ψ r) =
      extendState e (ApplyGate (wireGate n i U) ψ) r := by
  funext x
  unfold ApplyGate extendState
  rw [wireGate_mulVec_update, wireGate_mulVec_update, Finset.sum_mul]
  simp only [Function.update_comp_eq_of_injective x e.injective, hr x i, mul_assoc, Function.comp_apply]

private theorem two_wires (e : Fin n ↪ Fin N) (c t : Fin n) (hne : c ≠ t)
    (ψ : QState (Reg n)) (r : QState (Reg N)) (hr : OffWires e r) :
    ApplyGate (cnotGate N (e c) (e t)) (extendState e ψ r) =
      extendState e (ApplyGate (cnotGate n c t) ψ) r := by
  funext x
  simp only [cnotGate, applyGate_permMatrix (cnotUpdate_involutive _ _ _ (e.injective.ne hne)),
    extendState, applyGate_permMatrix (cnotUpdate_involutive _ _ _ hne),
    Function.update_comp_eq_of_injective x e.injective, hr x t, Function.comp_apply]

theorem renamedGate_legal (e : Fin n ↪ Fin N) (g : FiniteGateCode) (h : finiteCodeLegal n g = true) :
    finiteCodeLegal N (renameGate (address e) g) = true := by
  cases g with
  | h i | x i | t i | tdg i =>
    have hi : i < n := of_decide_eq_true h
    simp [renameGate, finiteCodeLegal, address, hi]
  | cx c t =>
    obtain ⟨hc, ht, hct⟩ : c < n ∧ t < n ∧ c ≠ t := of_decide_eq_true h
    have ne : (e ⟨c,hc⟩).val ≠ (e ⟨t,ht⟩).val :=
      fun eq => hct (congrArg Fin.val (e.injective (Fin.ext eq)))
    simp [renameGate, finiteCodeLegal, address, hc, ht, ne]

private theorem renamedGate_action (e : Fin n ↪ Fin N) (g : FiniteGateCode)
    (h : finiteCodeLegal n g = true) (ψ : QState (Reg n)) (r : QState (Reg N)) (hr : OffWires e r) :
    ApplyGate (finiteCodeMatrix N (renameGate (address e) g)) (extendState e ψ r) =
      extendState e (ApplyGate (finiteCodeMatrix n g) ψ) r := by
  cases g with
  | h i | x i | t i | tdg i =>
    have hi : i < n := of_decide_eq_true h
    simpa [renameGate, finiteCodeMatrix, address, hi] using one_wire e ⟨i,hi⟩ _ ψ r hr
  | cx c t =>
    obtain ⟨hc, ht, hct⟩ : c < n ∧ t < n ∧ c ≠ t := of_decide_eq_true h
    have ne : (e ⟨c,hc⟩).val ≠ (e ⟨t,ht⟩).val :=
      fun eq => hct (congrArg Fin.val (e.injective (Fin.ext eq)))
    simpa [renameGate, finiteCodeMatrix, address, hc, ht, hct, ne] using
      two_wires e ⟨c,hc⟩ ⟨t,ht⟩ (fun eq => hct (congrArg Fin.val eq)) ψ r hr

def onWires (e : Fin n ↪ Fin N) (gs : List FiniteGateCode) := gs.map (renameGate (address e))

theorem onWires_legal (e : Fin n ↪ Fin N) (gs : List FiniteGateCode) (h : finiteWordLegal n gs = true) :
    finiteWordLegal N (onWires e gs) = true := by
  simp only [finiteWordLegal, List.all_eq_true, onWires, List.mem_map] at h ⊢
  rintro _ ⟨g, hg, rfl⟩
  exact renamedGate_legal e g (h g hg)

theorem onWires_length (e : Fin n ↪ Fin N) (gs : List FiniteGateCode) :
    (onWires e gs).length = gs.length := List.length_map _

/-- The renamed finite gate word acts on its selected register and preserves the
amplitude factor of all other registers. The original word may entangle its wires. -/
theorem onWires_run (e : Fin n ↪ Fin N) (gs : List FiniteGateCode) (h : finiteWordLegal n gs = true)
    (ψ : QState (Reg n)) (r : QState (Reg N)) (hr : OffWires e r) :
    Run 1 (finiteCodeCircuit N (onWires e gs)) (extendState e ψ r) =
      extendState e (Run 1 (finiteCodeCircuit n gs) ψ) r := by
  induction gs generalizing ψ with
  | nil => rfl
  | cons g gs ih =>
    have ⟨hg,hgs⟩ : finiteCodeLegal n g = true ∧ finiteWordLegal n gs = true := by
      simpa only [finiteWordLegal, List.all_cons, Bool.and_eq_true] using h
    simp only [onWires, List.map_cons, finiteCodeCircuit, Run]
    rw [renamedGate_action e g hg ψ r hr]
    exact ih hgs _

end FQChem.Complexity.Kitaev.Wiring
