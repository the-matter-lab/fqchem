module

public import FQChem.Complexity.SlaterIntegerVerifier
import Mathlib.Tactic

/-! # Arithmetic work of the Slater verifier

A division-free arithmetic expression over Gaussian integers describes each
comparison made by the fixed-precision verifier. The bounds count the
arithmetic necessary even when every density entry is recomputed. -/

@[expose] public section
namespace FQChem.Complexity.SlaterVerifierWork
open SlaterCertificate SlaterIntegerVerifier
local notation "ℤ[i]" => GaussianInt

inductive Expr where
  | input (z : ℤ[i])
  | add (a b : Expr)
  | sub (a b : Expr)
  | mul (a b : Expr)
  | conj (a : Expr)
  | real (a : Expr)
  | imag (a : Expr)
deriving Inhabited

def Expr.eval : Expr → ℤ[i]
  | .input z => z
  | .add a b => a.eval+b.eval
  | .sub a b => a.eval-b.eval
  | .mul a b => a.eval*b.eval
  | .conj a => star a.eval
  | .real a => (a.eval.re:ℤ[i])
  | .imag a => (a.eval.im:ℤ[i])

/-- Number of leaves and arithmetic instructions in an expression tree. -/
def Expr.work : Expr → ℕ
  | .input _ => 1
  | .add a b | .sub a b | .mul a b => 1+a.work+b.work
  | .conj a | .real a | .imag a => 1+a.work

def Expr.inputs (b : ℕ) : Expr → Prop
  | .input z => z.re.natAbs+z.im.natAbs+1≤2^b
  | .add x y | .sub x y | .mul x y => x.inputs b ∧ y.inputs b
  | .conj x | .real x | .imag x => x.inputs b

def magnitude (z : ℤ[i]) := z.re.natAbs+z.im.natAbs

private theorem mag_add (a b : ℤ[i]) : magnitude (a+b)≤magnitude a+magnitude b := by
  dsimp [magnitude]
  have x := Int.natAbs_add_le a.re b.re
  have y := Int.natAbs_add_le a.im b.im
  omega

private theorem mag_sub (a b : ℤ[i]) : magnitude (a-b)≤magnitude a+magnitude b := by
  dsimp [magnitude]
  have x := Int.natAbs_add_le a.re (-b.re)
  have y := Int.natAbs_add_le a.im (-b.im)
  simp only [Int.natAbs_neg] at x y
  simpa [sub_eq_add_neg] using (by omega : (a.re + -b.re).natAbs+(a.im + -b.im).natAbs≤
    a.re.natAbs+a.im.natAbs+(b.re.natAbs+b.im.natAbs))

private theorem mag_mul (a b : ℤ[i]) : magnitude (a*b)≤magnitude a*magnitude b := by
  change (a.re*b.re+-1*a.im*b.im).natAbs+(a.re*b.im+a.im*b.re).natAbs≤_
  calc
    _ ≤ ((a.re*b.re).natAbs+(-1*a.im*b.im).natAbs)+((a.re*b.im).natAbs+(a.im*b.re).natAbs) :=
      Nat.add_le_add (Int.natAbs_add_le _ _) (Int.natAbs_add_le _ _)
    _ = _ := by simp [magnitude,Int.natAbs_mul]; ring

/-- Every intermediate value satisfies a bit bound, including operands in
both subexpressions of a binary instruction. -/
def Expr.allSmall (w : ℕ) (e : Expr) : Prop :=
  magnitude e.eval+1≤2^w ∧ match e with
    | .input _ => True
    | .add x y | .sub x y | .mul x y => x.allSmall w ∧ y.allSmall w
    | .conj x | .real x | .imag x => x.allSmall w

private theorem smallValue (e : Expr) (w : ℕ) (h : e.allSmall w) : magnitude e.eval+1≤2^w := by
  cases e <;> exact h.1

private theorem smallMono {w v : ℕ} (h : w≤v) (e : Expr) (he : e.allSmall w) : e.allSmall v := by
  induction e with
  | input => exact ⟨he.1.trans (Nat.pow_le_pow_right (by decide) h),True.intro⟩
  | add a b ia ib | sub a b ia ib | mul a b ia ib =>
    exact ⟨he.1.trans (Nat.pow_le_pow_right (by decide) h),ia he.2.1,ib he.2.2⟩
  | conj a ia | real a ia | imag a ia => exact ⟨he.1.trans (Nat.pow_le_pow_right (by decide) h),ia he.2⟩

private theorem binaryCap (b m n x y z : ℕ) (hx : x+1≤2^(b*m)) (hy : y+1≤2^(b*n))
    (hz : z+1≤(x+1)*(y+1)) : z+1≤2^(b*(1+m+n)) := by
  have t := Nat.mul_le_mul hx hy
  rw [←pow_add] at t
  exact (hz.trans t).trans (Nat.pow_le_pow_right (by decide) (by ring_nf; omega))

theorem operandWidth (e : Expr) (b : ℕ) (h : e.inputs b) : e.allSmall (b*e.work) := by
  induction e with
  | input => exact ⟨by simpa [magnitude,Expr.work,Expr.eval] using (show _+1≤_ from h),True.intro⟩
  | add a c ia ic | sub a c ia ic | mul a c ia ic =>
    obtain ⟨ha,hc⟩ := h
    have x := ia ha
    have y := ic hc
    refine ⟨binaryCap b a.work c.work _ _ _ (smallValue _ _ x) (smallValue _ _ y) ?_,
      smallMono (Nat.mul_le_mul_left _ (by simp only [Expr.work];omega)) a x,
      smallMono (Nat.mul_le_mul_left _ (by simp only [Expr.work];omega)) c y⟩
    simp only [Expr.eval]
    first
    | nlinarith only [mag_add a.eval c.eval,show 0≤magnitude a.eval*magnitude c.eval by omega]
    | nlinarith only [mag_sub a.eval c.eval,show 0≤magnitude a.eval*magnitude c.eval by omega]
    | nlinarith only [mag_mul a.eval c.eval,show 0≤magnitude a.eval by omega,show 0≤magnitude c.eval by omega]
  | conj a ia | real a ia | imag a ia =>
    have x := smallMono (Nat.mul_le_mul_left b (Nat.le_add_left a.work 1)) a (ia h)
    refine ⟨?_,x⟩
    apply le_trans _ (smallValue _ _ x)
    cases eq : a.eval with | mk r i =>
      simp [magnitude,Expr.eval,eq]

def total : (n : ℕ) → (Fin n → Expr) → Expr
  | 0, _ => .input 0
  | n+1, f => .add (total n fun i => f i.castSucc) (f (Fin.last n))

theorem total_eval (n : ℕ) (f : Fin n → Expr) : (total n f).eval=∑ i, (f i).eval := by
  induction n with
  | zero => simp [total,Expr.eval]
  | succ n ih => rw [Fin.sum_univ_castSucc,total,Expr.eval,ih]

def sumWork (n a : ℕ) := 1+n*(1+a)

theorem total_work (n : ℕ) (f : Fin n → Expr) (w : ℕ) (h : ∀ i, (f i).work≤w) :
    (total n f).work≤sumWork n w := by
  induction n with
  | zero => simp [total,Expr.work,sumWork]
  | succ n ih =>
    have u := ih (fun i => f i.castSucc) (fun i => h i.castSucc)
    have v := h (Fin.last n)
    simp only [total,Expr.work,sumWork,Nat.add_mul,one_mul] at u ⊢
    omega

variable {d k : ℕ}
def orbital (a : Digits d k) (p : Fin d) (i : Fin k) : Expr := .input (raw a p i)
def densityExpr (a : Digits d k) (p q : Fin d) : Expr :=
  total k fun j => .mul (orbital a p j) (.conj (orbital a q j))
def gramExpr (D : ℕ) (a : Digits d k) (i j : Fin k) : Expr :=
  .sub (total d fun p => .mul (.conj (orbital a p i)) (orbital a p j))
    (if i=j then .mul (.input D) (.input D) else .input 0)
def normExpr (x : Expr) : Expr := .mul x (.conj x)
def scoreExpr (I : Integrals d) (D : ℕ) (a : Digits d k) : Expr :=
  .add (.mul (.mul (.input D) (.input D))
         (total d fun p => total d fun q => .mul (.input (I.h p q)) (densityExpr a q p)))
    (total d fun p => total d fun q => total d fun r => total d fun s =>
      .mul (.input (I.u p q r s)) (.sub (.mul (densityExpr a q p) (densityExpr a s r))
        (.mul (densityExpr a s p) (densityExpr a q r))))

theorem density_eval (a : Digits d k) (p q) : (densityExpr a p q).eval=projector a p q := by
  simp [densityExpr,total_eval,Expr.eval,orbital,projector]

theorem gram_eval (D : ℕ) (a : Digits d k) (i j) : (gramExpr D a i j).eval=residual D a i j := by
  by_cases e : i=j <;> simp [gramExpr,e,total_eval,Expr.eval,orbital,SlaterIntegerVerifier.residual,sq]

theorem score_eval (I : Integrals d) (D : ℕ) (a : Digits d k) : (scoreExpr I D a).eval=integerScore I D a := by
  simp [scoreExpr,total_eval,Expr.eval,density_eval,integerScore,sq]

def densityWork (k : ℕ) := sumWork k 4
def gramWork (d : ℕ) := 4+sumWork d 4
def scoreWork (d k : ℕ) :=
  5+sumWork d (sumWork d (2+densityWork k)) +
    sumWork d (sumWork d (sumWork d (sumWork d (5+4*densityWork k))))

theorem density_work (a : Digits d k) (p q) : (densityExpr a p q).work≤densityWork k :=
  total_work _ _ _ fun _ => by simp [orbital,Expr.work]

theorem gram_work (D : ℕ) (a : Digits d k) (i j) : (gramExpr D a i j).work≤gramWork d := by
  have b := total_work d (fun p => Expr.mul (.conj (orbital a p i)) (orbital a p j)) 4
    (fun _ => by simp [Expr.work,orbital])
  by_cases e : i=j
  · subst i; simp [gramExpr,Expr.work,gramWork]; omega
  · simp [gramExpr,e,Expr.work,gramWork]; omega

theorem score_work (I : Integrals d) (D : ℕ) (a : Digits d k) : (scoreExpr I D a).work≤scoreWork d k := by
  unfold scoreExpr scoreWork
  simp only [Expr.work]
  have one := total_work d _ (sumWork d (2+densityWork k)) fun p => total_work d
    (fun q => Expr.mul (.input (I.h p q)) (densityExpr a q p)) (2+densityWork k) fun q =>
      by simpa [Expr.work] using Nat.add_le_add_left (density_work a q p) 2
  have two := total_work d _ _ fun p => total_work d _ _ fun q => total_work d _ _ fun r => total_work d
    (fun s => Expr.mul (.input (I.u p q r s)) (.sub (.mul (densityExpr a q p) (densityExpr a s r))
      (.mul (densityExpr a s p) (densityExpr a q r)))) (5+4*densityWork k) fun s => by
        simp only [Expr.work]
        linarith [density_work a q p,density_work a s r,density_work a s p,density_work a q r]
  omega

structure Comparison where
  left : Expr
  right : Expr

def Comparison.check (c : Comparison) : Bool := decide (c.left.eval.re≤c.right.eval.re)
def Comparison.work (c : Comparison) := 1+c.left.work+c.right.work

def digitCheck (D : ℕ) (a : Digits d k) (p : Fin d) (i : Fin k) (s : Bool) : Comparison :=
  let x := if s then Expr.imag (orbital a p i) else Expr.real (orbital a p i)
  ⟨.mul x x,.mul (.input D) (.input D)⟩

def gramCheck (D : ℕ) (a : Digits d k) (i j : Fin k) : Comparison :=
  let scale := Expr.mul (.mul (.input 8) (.input d)) (.input D)
  ⟨normExpr (gramExpr D a i j),.mul scale scale⟩

def energyCheck (I : Integrals d) (D M : ℕ) (lo : ℚ) (a : Digits d k) : Comparison :=
  let z := Expr.input (D:ℤ[i])
  let c := Expr.input (I.common:ℤ[i])
  let m := Expr.input (lo.num:ℤ[i])
  let n := Expr.input (lo.den:ℤ[i])
  let l := Expr.input (constant d k M:ℤ[i])
  ⟨.mul (.real (scoreExpr I D a)) n,
    .mul (.add (.mul m z) (.mul (.mul (.input 2) l) n)) (.mul (.mul (.mul c z) z) z)⟩

private theorem scalar_square (x : ℤ) (D : ℕ) : x*x≤(D:ℤ)*D ↔ |x|≤(D:ℤ) := by
  rw [←sq,←sq,←sq_abs x,sq_le_sq₀ (abs_nonneg _) (by positivity)]

theorem digit_check (D : ℕ) (a : Digits d k) (p i) (s : Bool) :
    (digitCheck D a p i s).check=true ↔ |if s then a.im p i else a.re p i|≤(D:ℤ) := by
  cases s <;> simp [digitCheck,Comparison.check,Expr.eval,orbital,raw,Zsqrtd.re_mul,scalar_square]

theorem gram_check (D : ℕ) (a : Digits d k) (i j) :
    (gramCheck D a i j).check=true ↔ (SlaterIntegerVerifier.residual D a i j).norm≤(8*(d:ℤ)*D)^2 := by
  simp only [gramCheck,Comparison.check,normExpr,Expr.eval,gram_eval,decide_eq_true_eq]
  rw [←Zsqrtd.norm_eq_mul_conj]
  simp [Zsqrtd.re_mul,sq]

theorem energy_check (I : Integrals d) (D M : ℕ) (pos : 0<D) (lo : ℚ) (a : Digits d k) :
    (energyCheck I D M lo a).check=true ↔ rationalScore I D a≤lo+(constant d k M:ℚ)*(2/D) := by
  simp only [energyCheck,Comparison.check,Expr.eval,score_eval,decide_eq_true_eq]
  simp [Zsqrtd.re_mul,Zsqrtd.re_add]
  unfold rationalScore
  have dp : 0<(D:ℚ) := by exact_mod_cast pos
  have cp : 0<(I.common:ℚ) := by exact_mod_cast I.common_pos
  have nd : 0<(lo.den:ℚ) := by exact_mod_cast lo.den_pos
  have eq := Rat.num_div_den lo
  conv_rhs => rw [←eq]
  push_cast
  field_simp
  norm_cast
  ring_nf

/-- A family of integer comparisons. Finite conjunctions can short-circuit
or evaluate all 2dk+k²+1 comparisons. -/
def run (I : Integrals d) (D M : ℕ) (lo : ℚ) (a : Digits d k) : Bool :=
  decide (∀ p i s, (digitCheck D a p i s).check=true) &&
  decide (∀ i j, (gramCheck D a i j).check=true) &&
  (energyCheck I D M lo a).check

theorem run_eq (I : Integrals d) (D M : ℕ) (hD : 0<D) (lo : ℚ) (a : Digits d k) :
    run I D M lo a=accept I D M lo a := by
  apply Bool.eq_iff_iff.mpr
  simp [run,accept,digit_check,gram_check,energy_check I D M hD,Bool.forall_bool]

def work (I : Integrals d) (D M : ℕ) (lo : ℚ) (a : Digits d k) :=
  (∑ p, ∑ i, ((digitCheck D a p i false).work+(digitCheck D a p i true).work))+
  (∑ i, ∑ j, (gramCheck D a i j).work)+(energyCheck I D M lo a).work

/-- Closed polynomial in the numbers of modes and electrons. Each Gaussian
integer arithmetic operation, input read, and scalar comparison costs one. -/
def budget (d k : ℕ) := d*k*18+k*k*(14+2*gramWork d)+21+scoreWork d k

theorem verifierWork (I : Integrals d) (D M : ℕ) (lo : ℚ) (a : Digits d k) :
    work I D M lo a≤budget d k := by
  have digit (p i) : (digitCheck D a p i false).work+(digitCheck D a p i true).work=18 := by rfl
  have gram (i j) : (gramCheck D a i j).work≤14+2*gramWork d := by
    dsimp [gramCheck,Comparison.work,normExpr,Expr.work]
    have h := gram_work D a i j
    omega
  have en : (energyCheck I D M lo a).work≤21+scoreWork d k := by
    dsimp [energyCheck,Comparison.work,Expr.work]
    have h := score_work I D a
    omega
  unfold work budget
  simp_rw [digit]
  calc
    _ ≤ (∑ _p : Fin d, ∑ _i : Fin k, 18)+(∑ _i : Fin k, ∑ _j : Fin k, (14+2*gramWork d))+(21+scoreWork d k) :=
      Nat.add_le_add (Nat.add_le_add_left (Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => gram i j) _) en
    _ = _ := by simp;ring

/-- Bounds on the actual input words and the two precomputed integer
parameters D and the orbital Lipschitz constant. -/
structure InputBounds (I : Integrals d) (D M b : ℕ) (lo : ℚ) (a : Digits d k) : Prop where
  eight : 9≤2^b
  modes : d+1≤2^b
  grid : D+1≤2^b
  lipschitz : constant d k M+1≤2^b
  common : I.common+1≤2^b
  lowNum : lo.num.natAbs+1≤2^b
  lowDen : lo.den+1≤2^b
  orbitals : ∀ p i, magnitude (raw a p i)+1≤2^b
  oneBody : ∀ p q, magnitude (I.h p q)+1≤2^b
  twoBody : ∀ p q r s, magnitude (I.u p q r s)+1≤2^b

private theorem sum_inputs (n b : ℕ) (f : Fin n → Expr) (h : ∀ i, (f i).inputs b) : (total n f).inputs b := by
  induction n with
  | zero => simpa [total,Expr.inputs] using (Nat.one_le_two_pow (n:=b))
  | succ n ih => exact ⟨ih _ fun i => h i.castSucc,h _⟩

private theorem density_inputs {a : Digits d k} {b : ℕ} (h : ∀ p i, magnitude (raw a p i)+1≤2^b)
    (p q) : (densityExpr a p q).inputs b :=
  sum_inputs _ _ _ fun i => ⟨h p i,h q i⟩

private theorem within {x : ℕ} {b : ℕ} (hx : x+1≤2^b) : (Expr.input (x:ℤ[i])).inputs b := by
  simpa [Expr.inputs] using hx

private theorem allInputs (I : Integrals d) (D M b : ℕ) (lo : ℚ) (a : Digits d k)
    (h : InputBounds I D M b lo a) :
    (∀ p i s, let c := digitCheck D a p i s; c.left.inputs b ∧ c.right.inputs b) ∧
    (∀ i j, let c := gramCheck D a i j; c.left.inputs b ∧ c.right.inputs b) ∧
    (let c := energyCheck I D M lo a; c.left.inputs b ∧ c.right.inputs b) := by
  have hd := within h.grid
  have di := within h.modes
  have ei : (Expr.input 8).inputs b := by simpa [Expr.inputs] using h.eight
  have tw : (Expr.input 2).inputs b := by have he := h.eight; simp [Expr.inputs]; omega
  have zero : (Expr.input 0).inputs b := by simpa [Expr.inputs] using (Nat.one_le_two_pow (n:=b))
  have den := within h.lowDen
  have num : (Expr.input (lo.num:ℤ[i])).inputs b := by simpa [Expr.inputs] using h.lowNum
  have rho := density_inputs h.orbitals
  have gs (i j : Fin k) : (gramExpr D a i j).inputs b := by
    refine ⟨sum_inputs _ _ _ fun p => ⟨h.orbitals p i,h.orbitals p j⟩,?_⟩
    split <;> first | exact ⟨hd,hd⟩ | exact zero
  have sc : (scoreExpr I D a).inputs b := by
    refine ⟨⟨⟨hd,hd⟩,sum_inputs _ _ _ fun p => sum_inputs _ _ _ fun q => ⟨h.oneBody p q,rho q p⟩⟩,?_⟩
    exact sum_inputs _ _ _ fun p => sum_inputs _ _ _ fun q => sum_inputs _ _ _ fun r =>
      sum_inputs _ _ _ fun s => ⟨h.twoBody p q r s,⟨rho q p,rho s r⟩,⟨rho s p,rho q r⟩⟩
  refine ⟨?_,?_,?_⟩
  · intro p i s; cases s <;> exact ⟨⟨h.orbitals p i,h.orbitals p i⟩,hd,hd⟩
  · exact fun i j => ⟨⟨gs i j,gs i j⟩,⟨⟨ei,di⟩,hd⟩,⟨ei,di⟩,hd⟩
  · exact ⟨⟨sc,den⟩,⟨⟨num,hd⟩,⟨tw,within h.lipschitz⟩,den⟩,⟨⟨within h.common,hd⟩,hd⟩,hd⟩

def Comparison.small (c : Comparison) (w : ℕ) := c.left.allSmall w ∧ c.right.allSmall w

private theorem cmpSmall (c : Comparison) (b w : ℕ) (h : c.left.inputs b ∧ c.right.inputs b)
    (hw : c.work≤w) : c.small (b*w) := by
  unfold Comparison.work at hw
  exact ⟨smallMono (Nat.mul_le_mul_left b (by omega)) _ (operandWidth _ _ h.1),
    smallMono (Nat.mul_le_mul_left b (by omega)) _ (operandWidth _ _ h.2)⟩

/-- Each intermediate Gaussian integer in all compiled comparisons has
polynomially many bits. The bound applies to the operands of additions,
multiplications, subtractions, and conjugations at every tree depth. -/
theorem verifierWidth (I : Integrals d) (D M b : ℕ) (lo : ℚ) (a : Digits d k)
    (h : InputBounds I D M b lo a) :
    let w := b*(21+2*gramWork d+scoreWork d k)
    (∀ p i s, (digitCheck D a p i s).small w) ∧ (∀ i j, (gramCheck D a i j).small w) ∧
      (energyCheck I D M lo a).small w := by
  obtain ⟨digit,gram,en⟩ := allInputs I D M b lo a h
  refine ⟨fun p i s => cmpSmall _ _ _ (digit p i s) ?_,fun i j => cmpSmall _ _ _ (gram i j) ?_,
    cmpSmall _ _ _ en ?_⟩
  · cases s <;> simp [digitCheck,Comparison.work,orbital,Expr.work] <;> omega
  · dsimp [gramCheck,Comparison.work,normExpr,Expr.work]
    have hg := gram_work D a i j
    omega
  · dsimp [energyCheck,Comparison.work,Expr.work]
    have he := score_work I D a
    omega

end FQChem.Complexity.SlaterVerifierWork
