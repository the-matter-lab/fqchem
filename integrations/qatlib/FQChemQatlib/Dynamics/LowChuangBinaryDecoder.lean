module

public import FQChemQatlib.Dynamics.LowChuangUniformBits
public import FQChemQatlib.Dynamics.LowChuangDecoderLayout

/-! # A linear-size quantum decoder for Cartesian binary sparse entries -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Binary

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open scoped Classical

/-- Each instruction is either an addressed Clifford+T instruction or a
diagonal phase depending on at most two designated wires. -/
inductive Local (n : ℕ) : Matrix (Reg n) (Reg n) ℂ → Prop where
  | code (g : FiniteGateCode) (legal : finiteCodeLegal n g=true) : Local n (finiteCodeMatrix n g)
  | phase (a b : Fin n) (f : Bool → Bool → ℂ) (unit : ∀ x y, star (f x y) * f x y=1) :
      Local n (Matrix.diagonal (fun s => f (s a) (s b)))
  | adj {M} : Local n M → Local n Mᴴ

def Built {n} (M : Matrix (Reg n) (Reg n) ℂ) (k : ℕ) : Prop :=
  ∃ xs : List (Matrix (Reg n) (Reg n) ℂ), xs.length≤k ∧ (∀ A∈xs, Local n A) ∧ xs.prod=M

private theorem built_word {n : ℕ} (gs : List FiniteGateCode) (legal : finiteWordLegal n gs=true) :
    Built (finiteWordMatrix n gs) gs.length := by
  induction gs with
  | nil => exact ⟨[],by simp,by simp,rfl⟩
  | cons g gs ih =>
    have ⟨hg,hgs⟩ := Bool.and_eq_true_iff.mp legal
    obtain ⟨xs,len,els,val⟩ := ih hgs
    refine ⟨xs++[finiteCodeMatrix _ g],by simp;omega,?_,by simp [val,finiteWordMatrix]⟩
    intro A mem
    rcases List.mem_append.mp mem with old | new
    · exact els _ old
    · cases List.mem_singleton.mp new; exact .code _ hg

private theorem built_mul {n} {A B : Matrix (Reg n) _ ℂ} {k l}
    (a : Built A k) (b : Built B l) : Built (A*B) (k+l) := by
  obtain ⟨xs,lx,ux,px⟩ := a
  obtain ⟨ys,ly,uy,py⟩ := b
  exact ⟨xs++ys,by simp;omega,fun x m => (List.mem_append.mp m).elim (ux x) (uy x),by simp [px,py]⟩

private theorem built_adj {n} {A : Matrix (Reg n) _ ℂ} {k} (a : Built A k) : Built Aᴴ k := by
  obtain ⟨xs,lx,ux,rfl⟩ := a
  refine ⟨(xs.map Matrix.conjTranspose).reverse,by simpa using lx,?_,?_⟩
  · intro V mem
    obtain ⟨y,hy,rfl⟩ := List.mem_map.mp (List.mem_reverse.mp mem)
    exact .adj (ux _ hy)
  · clear lx ux
    induction xs <;> simp [*]

private theorem built_weaken {n} {A : Matrix (Reg n) _ ℂ} {k l} (a : Built A k) (h : k≤l) : Built A l := by
  obtain ⟨xs,len,rest⟩ := a; exact ⟨xs,len.trans h,rest⟩

private theorem local_unit {n} {M : Matrix (Reg n) _ ℂ} (h : Local n M) :
    M ∈ Matrix.unitaryGroup _ ℂ := by
  induction h with
  | code g hg => exact finiteCodeMatrix_unitary _ _ hg
  | phase a b f h =>
    rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose,Matrix.diagonal_conjTranspose,
      Matrix.diagonal_mul_diagonal]
    conv_rhs => rw [← Matrix.diagonal_one]
    congr 1
    funext s
    exact h _ _
  | adj h ih => exact Unitary.star_mem ih

private theorem built_unit {n} {M : Matrix (Reg n) _ ℂ} {k} (a : Built M k) :
    M ∈ Matrix.unitaryGroup _ ℂ := by
  obtain ⟨xs,_,all,rfl⟩ := a
  exact Submonoid.list_prod_mem _ (fun g h => local_unit (all g h))

def gated (imag b c : Bool) : ℂ := if b=imag then (if imag then Complex.I else 1)*sign c else 1

private theorem gated_phase (imag b c : Bool) : star (gated imag b c)*gated imag b c=1 := by
  cases imag <;> cases b <;> cases c <;> simp [gated,sign]

def clean (p : ℕ) (x : Reg (size p)) : Prop :=
  x (branch p)=false ∧ (∀ i,x (column p 0 i)=false) ∧
  ∀ im, x (seed p im)=false ∧ ∀ t∈digits p im,x t.output=false

def value {p : ℕ} (x : Reg (size p)) : ℂ :=
  (signedValue (threshold false x) + Complex.I * signedValue (threshold true x))/2

def pulse (p : ℕ) (imag : Bool) (x : Reg (size p)) : ℂ :=
  gated imag (x (branch p)) (compute (seed p imag) (digits p imag) x (result (seed p imag) (digits p imag)))

private theorem pulse_word (p : ℕ) (imag : Bool) :
    Built (Matrix.diagonal (pulse p imag)) (94*p+1) := by
  obtain ⟨gs,len,leg,act⟩ := ripple_word (seed p imag) (digits p imag) (digits_valid p imag)
  let f := fun x : Reg (size p) => gated imag (x (branch p)) (x (result (seed p imag) (digits p imag)))
  let C := finiteWordMatrix (size p) gs
  have eq : Cᴴ * Matrix.diagonal f * C = Matrix.diagonal (pulse p imag) := by
    rw [encoded_diagonal leg act]
    simp only [f,protect_branch]; rfl
  have D : Local _ (Matrix.diagonal f) := Local.phase _ _ _ (gated_phase imag)
  have mid : Built (Matrix.diagonal f) 1 := ⟨[_],by simp,by simpa using D,by simp⟩
  have word := built_word _ leg
  rw [← eq]
  apply built_weaken (built_mul (built_mul (built_adj word) mid) word)
  simp only [digits,List.length_ofFn] at len
  omega

private theorem outside_col (p : ℕ) {j : Fin 5} (nz : j≠0) (i : Fin p) :
    column p j i ∉ Set.range (randomBits p) := by
  rintro ⟨k,h⟩
  refine Fin.cases ?_ (fun k => ?_) k h <;> simp [randomBits,branch,extra,column,nz.symm]

private theorem outside_seed (p : ℕ) (im : Bool) : seed p im ∉ Set.range (randomBits p) := by
  rintro ⟨k,h⟩
  refine Fin.cases ?_ (fun k => ?_) k h <;> cases im <;> simp [randomBits,branch,seed,extra,column]

private theorem filled_pulse (p : ℕ) (x : Reg (size p)) (init : clean p x) (u : Reg (p+1)) (im : Bool) :
    pulse p im (fill (randomBits p) x u) =
    gated im (u 0) (decide (thermalBitValue (List.ofFn fun i : Fin p => u i.succ) <
      thermalBitValue (List.ofFn (threshold im x)))) := by
  let y := fill (randomBits p) x u
  have b : y (branch p)=u 0 := fill_at (randomBits p) x u 0
  have c (i : Fin p) : y (column p 0 i)=u i.succ := fill_at (randomBits p) x u i.succ
  have seed0 : y (seed p im)=false := (fill_out _ _ _ (outside_seed p im)).trans (init.2.2 im).1
  have cs (d : Digit (size p)) (h : d∈digits p im) : y d.output=false := by
    obtain ⟨i,eq⟩ := List.mem_ofFn.mp h
    exact (fill_out _ _ _ (eq ▸ outside_col p (show (if im then (4:Fin 5) else 3)≠0 by cases im <;> decide) i)).trans
      ((init.2.2 im).2 d h)
  have routed := ripple_result _ _ (digits_valid p im) y seed0 cs
  have t : threshold im y=threshold im x := funext (fun i =>
    fill_out _ _ _ (outside_col p (by cases im <;> decide) i))
  have q : coins y = fun i => u i.succ := funext c
  rw [(digits_read p im y).1,(digits_read p im y).2,q,t] at routed
  exact congrArg₂ (gated im) b routed

def split (p : ℕ) : Reg (p+1) ≃ Bool × Reg p where
  toFun x := (x 0,fun i=>x i.succ)
  invFun x := Fin.cons x.1 x.2
  left_inv x := by funext i; exact Fin.cases rfl (fun _ => rfl) i
  right_inv _ := rfl

/-- One fixed circuit for every pair of p-bit Cartesian coordinates. It has
at most 190p+4 one- or two-qubit gates. On clean work bits its diagonal
amplitude is exactly (real + i imaginary)/2 in centered binary fixed point. -/
theorem decoder (p : ℕ) : ∃ V : Matrix (Reg (size p)) _ ℂ,
    V ∈ Matrix.unitaryGroup _ ℂ ∧ Built V (190*p+4) ∧
    ∀ x, clean p x → V x x = value x := by
  let H := finiteWordMatrix (size p) (hWord (randomBits p))
  let C := Matrix.diagonal (pulse p false) * Matrix.diagonal (pulse p true)
  let V := Hᴴ*C*H
  have hH := built_word _ (hWord_cost (randomBits p)).2
  have wh : Built H (p+1) := (hWord_cost (randomBits p)).1 ▸ hH
  have circ := built_mul (built_mul (built_adj wh) (built_mul (pulse_word p false) (pulse_word p true))) wh
  have out : Built V (190*p+4) := built_weaken circ (by omega)
  refine ⟨V,built_unit out,out,fun x init => ?_⟩
  have zero (i : Fin (p+1)) : x (randomBits p i)=false := by
    exact Fin.cases init.1 init.2.1 i
  have h := mean_diagonal (randomBits p) x zero (fun s => pulse p false s * pulse p true s)
  change (Hᴴ * (Matrix.diagonal (pulse p false) * Matrix.diagonal (pulse p true)) * H) x x=_
  rw [Matrix.diagonal_mul_diagonal]
  rw [h]
  simp_rw [filled_pulse p x init]
  rw [← (split p).symm.sum_comp _]
  have unpair (b : Bool) (u : Reg p) : (split p).symm (b,u)=Fin.cons b u := rfl
  simp only [Fintype.sum_prod_type,Fintype.sum_bool,unpair,Fin.cons_zero,Fin.cons_succ]
  simp [gated,← Finset.mul_sum]
  have re := averaged_sign (threshold false x)
  have im := averaged_sign (threshold true x)
  unfold value
  rw [← re,← im,pow_succ]
  ring

/-- Load the two binary components; initialize every workspace bit to zero. -/
def packed {p : ℕ} (re im : Reg p) (w : Fin (size p)) : Bool :=
  match (addr p).symm w with
  | .inl (i,k) => if k=1 then re i else if k=2 then im i else false
  | .inr _ => false

theorem packed_clean {p : ℕ} (re im : Reg p) : clean p (packed re im) := by
  refine ⟨by simp [branch,extra,packed],by simp [column,packed],fun b => ⟨by simp [seed,extra,packed],?_⟩⟩
  intro d hd
  obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hd
  cases b <;> simp [column,packed]

/-- The same circuit acts on every pair of input words, uses at most
190p+4 elementary gates, and encodes the indicated complex number exactly
on its clean work coordinates. -/
theorem cartesianDecoder (p : ℕ) : ∃ V : Matrix (Reg (size p)) _ ℂ,
    V ∈ Matrix.unitaryGroup _ ℂ ∧ Built V (190*p+4) ∧
    ∀ re im : Reg p, V (packed re im) (packed re im) =
      (signedValue re + Complex.I*signedValue im)/2 := by
  obtain ⟨V,unit,size,correct⟩ := decoder p
  refine ⟨V,unit,size,fun re im => ?_⟩
  rw [correct _ (packed_clean re im)]
  have re' : threshold false (packed re im)=re := by funext i; simp [threshold,packed,column]
  have im' : threshold true (packed re im)=im := by funext i; simp [threshold,packed,column]
  rw [value,re',im']

end FQChemQatlib.Dynamics.LowChuang.Binary
