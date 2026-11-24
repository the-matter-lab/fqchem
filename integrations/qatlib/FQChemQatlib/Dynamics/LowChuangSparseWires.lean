module

public import FQChemQatlib.Dynamics.LowChuangBinaryDecoder
public import Qatlib.Concepts.GateTables.GrayUniversal.Section8GrayUniversalityElem

/-! # Placing and synthesizing gates on a specified subset of binary wires -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseWires

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Concepts.GateTables.GrayUniversal
open scoped Classical

variable {T : Type} [Fintype T] [DecidableEq T] {k : ℕ}

def split (w : Fin k ↪ T) : (T→Bool) ≃ Reg k × ({i : T // i ∉ Set.range w} → Bool) where
  toFun x := (x ∘ w,fun i => x i)
  invFun x i := if h : i ∈ Set.range w then x.1 (Classical.choose h) else x.2 ⟨i,h⟩
  left_inv x := by
    funext i
    by_cases h : i ∈ Set.range w
    · simp [h,Function.comp_apply,Classical.choose_spec h]
    · simp [h]
  right_inv x := by
    refine Prod.ext (funext fun i => ?_) (funext fun i => ?_)
    · simp
    · simp [i.2]

def place (w : Fin k ↪ T) (M : Matrix (Reg k) (Reg k) ℂ) : Matrix (T→Bool) (T→Bool) ℂ :=
  Matrix.reindexAlgEquiv ℂ ℂ (split w).symm (TensorGate M (1 : Matrix ({i:T // i∉Set.range w} → Bool) ({i:T // i∉Set.range w} → Bool) ℂ))

theorem place_apply (w : Fin k ↪ T) (M : Matrix (Reg k) (Reg k) ℂ) (x y : T→Bool) :
    place w M x y = if ∀ i, i∉Set.range w → x i=y i then M (x ∘ w) (y ∘ w) else 0 := by
  change M (x ∘ w) (y ∘ w) * (1 : Matrix ({i:T // i∉Set.range w} → Bool) ({i:T // i∉Set.range w} → Bool) ℂ)
      (fun i => x i) (fun i => y i) = _
  simp [Matrix.one_apply,funext_iff,Subtype.forall,mul_ite]

theorem place_mul (w : Fin k ↪ T) (A B : Matrix (Reg k) (Reg k) ℂ) :
    place w (A*B) = place w A * place w B := by
  simp only [place,←map_mul,tensorGate_mul,one_mul]

theorem place_one (w : Fin k ↪ T) : place w (1 : Matrix (Reg k) (Reg k) ℂ) = 1 := by
  simp [place,tensorGate_one]

theorem place_adjoint (w : Fin k ↪ T) (M : Matrix (Reg k) (Reg k) ℂ) : place w Mᴴ = (place w M)ᴴ := by
  ext x y
  simp only [Matrix.conjTranspose_apply,place_apply,apply_ite,star_zero]
  by_cases h : ∀ i, i∉Set.range w → x i=y i
  · rw [ite_eq_left h,ite_eq_left (fun i hi => (h i hi).symm)]
  · have : ¬∀ i, i∉Set.range w → y i=x i := fun g => h (fun i hi => (g i hi).symm)
    rw [ite_eq_right h,ite_eq_right this]

/-- Each allowed item is one arbitrary one-qubit gate or one CNOT on
explicitly selected wires. The untouched coordinates retain their literal
bit values under the placement. -/
inductive Elementary (T : Type) [Fintype T] [DecidableEq T] : Matrix (T→Bool) (T→Bool) ℂ → Prop where
  | wire {k : ℕ} (w : Fin k ↪ T) (g : ReflectionGate k) (legal : reflectionGateLegal g) :
      Elementary T (place w (reflectionGateMatrix g))
  | adj {M : Matrix (T→Bool) (T→Bool) ℂ} : Elementary T M → Elementary T Mᴴ

def Built (M : Matrix (T→Bool) (T→Bool) ℂ) (q : ℕ) :=
  ∃ gs : List (Matrix (T→Bool) (T→Bool) ℂ), gs.length≤q ∧ (∀ g∈gs,Elementary T g) ∧ gs.prod=M

theorem built_mul {A B : Matrix (T→Bool) (T→Bool) ℂ} {a b} (hA : Built A a) (hB : Built B b) :
    Built (A*B) (a+b) := by
  obtain ⟨x,hx,cx,ex⟩ := hA
  obtain ⟨y,hy,cy,ey⟩ := hB
  exact ⟨x++y,by simp;omega,fun g h => (List.mem_append.mp h).elim (cx _) (cy _),by simp [ex,ey]⟩

theorem built_adj {M : Matrix (T→Bool) (T→Bool) ℂ} {a} (h : Built M a) : Built Mᴴ a := by
  obtain ⟨gs,h,c,rfl⟩ := h
  refine ⟨(gs.map Matrix.conjTranspose).reverse,by simpa using h,?_,?_⟩
  · intro G hG
    obtain ⟨g,mem,rfl⟩ := List.mem_map.mp (List.mem_reverse.mp hG)
    exact .adj (c _ mem)
  · clear c h; induction gs <;> simp [*]

theorem built_weaken {M : Matrix (T→Bool) (T→Bool) ℂ} {a b} (h : Built M a) (hle : a≤b) : Built M b := by
  obtain ⟨x,h,r⟩ := h; exact ⟨x,h.trans hle,r⟩

private theorem reflection_built (w : Fin k ↪ T) (gs : List (ReflectionGate k)) (leg : reflectionLegal gs) :
    Built (place w (reflectionProgramMatrix gs)) gs.length := by
  induction gs with
  | nil => exact ⟨[],by simp,by simp,(place_one w).symm⟩
  | cons g gs ih =>
    have one : Built (place w (reflectionGateMatrix g)) 1 :=
      ⟨[_],by simp,by simpa using (Elementary.wire w g (leg g List.mem_cons_self)),by simp⟩
    have prev := ih (fun h hh => leg h (List.mem_cons_of_mem _ hh))
    rw [reflectionProgramMatrix,place_mul]
    exact built_mul prev one

/-- A gate on three specified wires admits a uniform constant bound on the
number of elementary gates on exactly those wires, independent of the size
of its environment. -/
theorem three (w : Fin 3 ↪ T) (V : Matrix (Reg 3) _ ℂ) (unit : V∈Matrix.unitaryGroup _ ℂ) :
    Built (place w V) 415440 := by
  obtain ⟨gs,leg,count,_,_,action⟩ := section8GrayUniversality 3 (by decide) V unit
  have eval : reflectionProgramMatrix gs = V := by
    ext x y
    have h := congrFun (action (Ket y)) x
    rw [run_reflectionCompile] at h
    simpa [ApplyGate,Matrix.mulVec,dotProduct,Qatlib.Foundations.PureStateMath.Ket,mul_ite] using h
  rw [← eval]
  exact built_weaken (reflection_built w gs leg) (by norm_num at count ⊢; omega)

end FQChemQatlib.Dynamics.LowChuang.SparseWires
