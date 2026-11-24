module

public import FQChem.Complexity.FixedBasisIntegrals
public import FQChem.Complexity.OrderFindingBitCost
import all FQChem.Complexity.OrderFindingBitCost
import Mathlib.Data.Nat.Size
import Mathlib.Tactic

/-! # Exact bit arithmetic for the compact basis integrals

The accumulator uses unreduced nonnegative numerator–denominator pairs. A
merge consists of three schoolbook products and one ripple-carry addition.
No gcd or rational-division cost is hidden inside the merge. -/

@[expose] public section
namespace FQChem.Complexity.FixedBasisArithmetic
open OrderFindingBitCost FixedBasisIntegrals FixedBasisGeometry

structure Fraction where
  num : ℕ
  den : ℕ
  deriving Repr, DecidableEq

def value (q : Fraction) : ℚ := q.num / (q.den : ℚ)

def merge (w : ℕ) (a b : Fraction) : Fraction × ℕ :=
  let x := multiply w w a.num b.den
  let y := multiply w w b.num a.den
  let d := multiply w w a.den b.den
  let s := ripple false w x.1 y.1 false
  (⟨s.word,d.1⟩,x.2+y.2+d.2+s.gates)

private theorem merge_spec {w : ℕ} {a b : Fraction}
    (ha : a.num<2^w ∧ a.den<2^w) (hb : b.num<2^w ∧ b.den<2^w)
    (hs : a.num*b.den+b.num*a.den<2^w) (hd : a.den*b.den<2^w) :
    merge w a b = (⟨a.num*b.den+b.num*a.den,a.den*b.den⟩,3*(w*(10*w))+6*w) := by
  have hx : a.num*b.den<2^w := by omega
  have hy : b.num*a.den<2^w := by omega
  unfold merge
  rw [multiply_spec _ _ _ _ ha.1 hb.2 hx,multiply_spec _ _ _ _ hb.1 ha.2 hy,
    multiply_spec _ _ _ _ ha.2 hb.2 hd]
  have e := ripple_spec false w (a.num*b.den) (b.num*a.den) false hx hy
  simp only [Bool.false_eq_true, ↓reduceIte,Bool.toNat_false,add_zero] at e
  have hw : (ripple false w (a.num*b.den) (b.num*a.den) false).word=a.num*b.den+b.num*a.den := by
    cases h : (ripple false w (a.num*b.den) (b.num*a.den) false).carry <;> simp [h] at e <;> omega
  simp [hw,e.2.1]
  ring

/-- Fixed-width bit evaluator, recursively merging the entries in index order. -/
def accumulate (w : ℕ) : (m : ℕ) → (Fin m → Fraction) → Fraction × ℕ
  | 0, _ => (⟨0,1⟩,0)
  | m+1, f =>
    let s := accumulate w m (fun i => f i.castSucc)
    let q := merge w s.1 (f (Fin.last m))
    (q.1,s.2+q.2)

private theorem product_lt {a b A B : ℕ} (ha : a<A) (hb : b<B) : a*b<A*B := by
  calc
    _ ≤ A*b := Nat.mul_le_mul_right _ ha.le
    _ < _ := Nat.mul_lt_mul_of_pos_left hb (Nat.zero_lt_of_lt ha)

/-- Correct exact rational result, output width, positive denominator and
physical gate count on the accumulator. The bit-width hypothesis applies
once to each input integer. -/
theorem accumulate_spec (w b m : ℕ) (f : Fin m → Fraction)
    (h : ∀ i, (f i).num<2^b ∧ (f i).den<2^b ∧ 0<(f i).den)
    (hw : (m+1)*(b+1)≤w) :
    let s := accumulate w m f
    value s.1=∑ i, value (f i) ∧
      s.1.num<2^((m+1)*(b+1)) ∧ s.1.den<2^((m+1)*(b+1)) ∧ 0<s.1.den ∧
      s.2=m*(3*(w*(10*w))+6*w) := by
  induction m with
  | zero => simp [accumulate,value]
  | succ m ih =>
    let s := accumulate w m (fun i => f i.castSucc)
    let t := f (Fin.last m)
    let W := (m+1)*(b+1)
    have hW : W+(b+1)=(m+1+1)*(b+1) := by dsimp [W]; ring
    obtain ⟨eq,hn,hd,hp,cost⟩ := ih (fun i => f i.castSucc) (fun i => h _) (by omega)
    change value s.1 = _ at eq
    change s.1.num<2^W at hn
    change s.1.den<2^W at hd
    change 0<s.1.den at hp
    change s.2=_ at cost
    obtain ⟨an,ad,ap⟩ := h (Fin.last m)
    change t.num<2^b at an
    change t.den<2^b at ad
    change 0<t.den at ap
    have cap : 2^((m+1+1)*(b+1))≤2^w := Nat.pow_le_pow_right (by decide) hw
    have p₁ := product_lt hn ad
    have p₂ := product_lt hd an
    have p₃ := product_lt hd ad
    have mx : s.1.num*t.den+t.num*s.1.den<2^((m+1+1)*(b+1)) := by
      rw [←hW,pow_add,pow_succ,←mul_assoc (2^W),Nat.mul_comm t.num]
      omega
    have md : s.1.den*t.den<2^((m+1+1)*(b+1)) := by
      rw [←hW,pow_add,pow_succ]
      nlinarith [p₃]
    have qs := merge_spec (w:=w) (a:=s.1) (b:=t)
      ⟨hn.trans_le (Nat.pow_le_pow_right (by decide) (by omega)),hd.trans_le (Nat.pow_le_pow_right (by decide) (by omega))⟩
      ⟨an.trans_le (Nat.pow_le_pow_right (by decide) (by omega)),ad.trans_le (Nat.pow_le_pow_right (by decide) (by omega))⟩
      (mx.trans_le cap) (md.trans_le cap)
    change value (merge w s.1 t).1=(∑ i, value (f i)) ∧ (merge w s.1 t).1.num<_ ∧ (merge w s.1 t).1.den<_ ∧ 0<(merge w s.1 t).1.den ∧ s.2+(merge w s.1 t).2=_
    rw [qs,Fin.sum_univ_castSucc]
    refine ⟨?_,mx,md,Nat.mul_pos hp ap,?_⟩
    · rw [←eq]
      change ((s.1.num*t.den+t.num*s.1.den : ℕ):ℚ)/(s.1.den*t.den:ℕ) = value s.1 + value t
      unfold value
      push_cast
      field_simp [Nat.ne_of_gt hp,Nat.ne_of_gt ap]
    · rw [cost]; ring

variable {n : ℕ}

def separation (a b : ℕ) := if a≤b then b-a else a-b

private theorem separation_cast (a b : ℕ) : (separation a b : ℚ)=|(a:ℚ)-b| := by
  by_cases h : a≤b
  · have q : (a:ℚ)≤b := by exact_mod_cast h
    simp [separation,h,Nat.cast_sub h,abs_of_nonpos (sub_nonpos.mpr q)]
  · have q : (b:ℚ)≤a := by exact_mod_cast (le_of_not_ge h)
    simp [separation,h,Nat.cast_sub (le_of_not_ge h),abs_of_nonneg (sub_nonneg.mpr q)]

def atom (adj : Fin n → Fin n → Bool) (R : ℕ) (i j : Fin n) (p : Fin n × Fin n) : Fraction :=
  if (i,p.1)=(j,p.2) then ⟨396396,185725⟩ else
    ⟨1,separation (coordinateCode adj R i p.1) (coordinateCode adj R j p.2)⟩

private theorem atom_value (adj : Fin n → Fin n → Bool) (R : ℕ) (i j : Fin n) (p : Fin n × Fin n) :
    value (atom adj R i j p) =
      if (i,p.1)=(j,p.2) then 396396/185725 else reciprocal adj R i p.1 j p.2 := by
  unfold atom
  split <;> simp [value,reciprocal,separation_cast]

/-- A polynomial word width in the input dimensions, with slack for the fixed
self-coefficient constants and the final n² normalization. -/
def inputWidth (n R : ℕ) := (396397+3*R*n^2+R+n*n).size

def width (n R : ℕ) := (n*n+2)*(inputWidth n R+1)

private theorem atom_bound (adj : Fin n → Fin n → Bool) (G : SimpleGraph (Fin n))
    (h : ∀ i j, adj i j=true ↔ G.Adj i j) (R : ℕ) (hR : 4≤R) (i j : Fin n) (p : Fin n × Fin n) :
    let x := atom adj R i j p
    x.num<2^(inputWidth n R) ∧ x.den<2^(inputWidth n R) ∧ 0<x.den := by
  have u := coordinateBound G R hR i p.1
  have v := coordinateBound G R hR j p.2
  rw [←coordinate_eq adj G h] at u v
  have large := Nat.lt_size_self (396397+3*R*n^2+R+n*n)
  unfold inputWidth at *
  unfold atom
  split
  · dsimp; omega
  next ne =>
    have different : coordinateCode adj R i p.1 ≠ coordinateCode adj R j p.2 := by
      intro eq
      have sep := separated G R hR i p.1 j p.2 ne
      have pt : FixedBasisGeometry.center G R i p.1=FixedBasisGeometry.center G R j p.2 := by
        simp only [FixedBasisGeometry.center,←coordinate_eq adj G h,eq]
      rw [pt,dist_self] at sep
      norm_num at sep
    dsimp only
    unfold separation
    split <;> omega

/-- Returns the two nonnegative integers of the spatial coefficient and the
number of Boolean arithmetic gates consumed after preparing its n² input
fractions. -/
def coefficient (adj : Fin n → Fin n → Bool) (R : ℕ) (i j : Fin n) : Fraction × ℕ :=
  let w := width n R
  let s := accumulate w (n*n) fun t => atom adj R i j (finProdFinEquiv.symm t)
  let normal := multiply w w s.1.den (n*n)
  (⟨s.1.num,normal.1⟩,s.2+normal.2)

theorem coefficient_spec (adj : Fin n → Fin n → Bool) (G : SimpleGraph (Fin n))
    (h : ∀ i j, adj i j=true ↔ G.Adj i j) (R : ℕ) (hR : 4≤R) (i j : Fin n) :
    let s := coefficient adj R i j
    let w := width n R
    (value s.1 : ℝ)=SlaterEnergyOrbitals.direct G R i j ∧ s.1.num<2^w ∧ s.1.den<2^w ∧
      0<s.1.den ∧ s.2=n*n*(3*(w*(10*w))+6*w)+w*(10*w) := by
  let w := width n R
  let b := inputWidth n R
  let f := fun t : Fin (n*n) => atom adj R i j (finProdFinEquiv.symm t)
  let s := accumulate w (n*n) f
  have cap : (n*n+1)*(b+1)+(b+1)=w := by dsimp [w,width,b]; ring
  have bw : b≤w := by omega
  have sz := accumulate_spec w b (n*n) f (fun t => atom_bound adj G h R hR i j _) (by omega)
  obtain ⟨val,hn,hd,hp,cost⟩ := sz
  change value s.1=_ at val
  change s.1.num<_ at hn
  change s.1.den<_ at hd
  change 0<s.1.den at hp
  change s.2=_ at cost
  have npos : 0<n := i.pos
  have nmax : n*n<2^b := by
    have be := Nat.lt_size_self (396397+3*R*n^2+R+n*n)
    dsimp [b,inputWidth]; omega
  have md : s.1.den*(n*n)<2^w := by
    rw [←cap,pow_add]
    exact product_lt hd (nmax.trans_le (Nat.pow_le_pow_right (by decide) (by omega)))
  have prod := multiply_spec w w s.1.den (n*n)
    (hd.trans_le (Nat.pow_le_pow_right (by decide) (by omega)))
    (nmax.trans_le (Nat.pow_le_pow_right (by decide) bw)) md
  change (value ⟨s.1.num,(multiply w w s.1.den (n*n)).1⟩:ℝ)=_ ∧ _ ∧ _ ∧ _ ∧ _=_
  simp only [coefficient,show width n R=w by rfl,show accumulate w (n*n) (fun t => atom adj R i j (finProdFinEquiv.symm t))=s by rfl,prod]
  refine ⟨?_,hn.trans_le (Nat.pow_le_pow_right (by decide) (by omega)),md,Nat.mul_pos hp (Nat.mul_pos npos npos),by rw [cost]⟩
  have sumEq : (∑ t, value (f t)) = ∑ u, ∑ v, if (i,u)=(j,v) then 396396/185725 else reciprocal adj R i u j v := by
    rw [←Equiv.sum_comp finProdFinEquiv, Fintype.sum_prod_type]
    simp only [f,Equiv.symm_apply_apply,atom_value]
  rw [←directCode_correct adj G h R hR (396396/185725) i j (Or.inr (by norm_num [FixedBasisSelfEnergy.self_value]))]
  congr 1
  rw [directCode,←sumEq,←val]
  unfold value
  push_cast
  ring

private theorem coordinate_bound (adj : Fin n → Fin n → Bool) (R : ℕ) (hR : 4≤R) (i j : Fin n) :
    coordinateCode adj R i j<2^(inputWidth n R) := by
  have blk : (max i j).val+n*(min i j).val < n*n := (finProdFinEquiv (min i j,max i j)).isLt
  have h := Nat.mul_lt_mul_of_pos_right blk (show 0<3*R by omega)
  have cap := Nat.lt_size_self (396397+3*R*n^2+R+n*n)
  unfold coordinateCode inputWidth
  split <;> first | (split <;> nlinarith) | nlinarith

/-- The two possible integer coordinates of a component are hardwired constants.
The corresponding input adjacency bit chooses between them. -/
def readCenter (adj : Fin n → Fin n → Bool) (R : ℕ) (i j : Fin n) :=
  selectWord (adj i j) (inputWidth n R)
    (coordinateCode (fun _ _ => true) R i j) (coordinateCode (fun _ _ => false) R i j)

private theorem read_spec (adj : Fin n → Fin n → Bool) (R : ℕ) (hR : 4≤R) (i j : Fin n) :
    readCenter adj R i j=(coordinateCode adj R i j,4*inputWidth n R) := by
  have s := select_spec (adj i j) _ _ _ (coordinate_bound (fun _ _ => true) R hR i j) (coordinate_bound (fun _ _ => false) R hR i j)
  apply Prod.ext
  · unfold readCenter
    rw [s.1]
    cases h : adj i j <;> simp [coordinateCode,h]
  · exact s.2

def difference (b x y : ℕ) : ℕ × ℕ :=
  let xy := ripple true b x y true
  let yx := ripple true b y x true
  let d := selectWord xy.carry b xy.word yx.word
  (d.1,xy.gates+yx.gates+d.2)

private theorem difference_spec {b x y : ℕ} (hx : x<2^b) (hy : y<2^b) :
    difference b x y=(separation x y,16*b) := by
  let xy := ripple true b x y true
  let yx := ripple true b y x true
  obtain ⟨xw,xg,xe⟩ := ripple_spec true b x y true hx hy
  obtain ⟨yw,yg,ye⟩ := ripple_spec true b y x true hy hx
  change xy.word<2^b at xw
  change yx.word<2^b at yw
  change xy.gates=6*b at xg
  change yx.gates=6*b at yg
  change xy.word+2^b*xy.carry.toNat+y+1=x+2^b+1 at xe
  change yx.word+2^b*yx.carry.toNat+x+1=y+2^b+1 at ye
  have sel := select_spec xy.carry b xy.word yx.word xw yw
  change ((selectWord xy.carry b xy.word yx.word).1,xy.gates+yx.gates+(selectWord xy.carry b xy.word yx.word).2)=_
  rw [sel.1,sel.2,xg,yg]
  apply Prod.ext
  · unfold separation
    cases hc : xy.carry <;> cases hc' : yx.carry <;> simp [hc,hc'] at * <;> split <;> omega
  · dsimp; ring

/-- Computes the integer pair for a requested component interaction from the
input adjacency bits. The same-component test depends only on fixed indices. -/
def readAtom (adj : Fin n → Fin n → Bool) (R : ℕ) (i j : Fin n) (p : Fin n × Fin n) : Fraction × ℕ :=
  if (i,p.1)=(j,p.2) then (⟨396396,185725⟩,0) else
    let x := readCenter adj R i p.1
    let y := readCenter adj R j p.2
    let d := difference (inputWidth n R) x.1 y.1
    (⟨1,d.1⟩,x.2+y.2+d.2)

private theorem readAtom_spec (adj : Fin n → Fin n → Bool) (R : ℕ) (hR : 4≤R) (i j : Fin n) (p) :
    (readAtom adj R i j p).1=atom adj R i j p ∧ (readAtom adj R i j p).2≤24*inputWidth n R := by
  unfold readAtom atom
  split
  · simp
  next =>
    rw [read_spec adj R hR i p.1,read_spec adj R hR j p.2]
    dsimp only
    rw [difference_spec (coordinate_bound adj R hR i p.1) (coordinate_bound adj R hR j p.2)]
    exact ⟨rfl,by dsimp; omega⟩

/-- Gate evaluator for all input-dependent operations of a spatial Coulomb
coefficient. The input is the graph's Boolean adjacency table. The indices,
graph size and spacing specify the circuit and its integer constants. -/
def electronicIntegral (adj : Fin n → Fin n → Bool) (R : ℕ) (i l j k : Fin n) : Fraction × ℕ :=
  if i=l ∧ j=k then
    let w := width n R
    let atoms := fun t : Fin (n*n) => readAtom adj R i j (finProdFinEquiv.symm t)
    let s := accumulate w (n*n) fun t => (atoms t).1
    let normal := multiply w w s.1.den (n*n)
    (⟨s.1.num,normal.1⟩,(∑ t, (atoms t).2)+s.2+normal.2)
  else (⟨0,1⟩,0)

theorem electronicIntegral_spec (adj : Fin n → Fin n → Bool) (G : SimpleGraph (Fin n))
    (h : ∀ i j, adj i j=true ↔ G.Adj i j) (R : ℕ) (hR : 4≤R) (i l j k : Fin n) :
    let s := electronicIntegral adj R i l j k
    let b := inputWidth n R
    let w := width n R
    (value s.1 : ℝ)=SlaterEnergyOrbitals.coefficient G R i l j k ∧ s.1.num<2^w ∧ s.1.den<2^w ∧
      0<s.1.den ∧ s.2≤n*n*(24*b+3*(w*(10*w))+6*w)+w*(10*w) := by
  by_cases ij : i=l ∧ j=k
  · obtain ⟨rfl,rfl⟩ := ij
    have base := coefficient_spec adj G h R hR i j
    have v (p) := (readAtom_spec adj R hR i j p).1
    have cost : (∑ t : Fin (n*n), (readAtom adj R i j (finProdFinEquiv.symm t)).2) ≤ n*n*(24*inputWidth n R) := by
      simpa using Finset.sum_le_sum (s:=Finset.univ) (fun t _ => (readAtom_spec adj R hR i j (finProdFinEquiv.symm t)).2)
    dsimp only [coefficient] at base
    dsimp only [electronicIntegral]
    simp only [and_self,ite_true,v]
    exact ⟨base.1,base.2.1,base.2.2.1,base.2.2.2.1,by linarith only [base.2.2.2.2,cost]⟩
  · rw [SlaterEnergyOrbitals.coefficient_offdiag G R hR (by tauto)]
    simp [electronicIntegral,ij,value,width]

/-- A polynomial upper envelope in the graph size and integer spacing. At the
reduction spacing R=12n⁴+2 this is an explicit polynomial in n. -/
theorem polynomialBudget (n R : ℕ) :
    let b := inputWidth n R
    let w := width n R
    let B := 396397+3*R*n^2+R+n*n
    let W := (n*n+2)*(B+1)
    n*n*(24*b+3*(w*(10*w))+6*w)+w*(10*w) ≤
      n*n*(24*B+3*(W*(10*W))+6*W)+W*(10*W) := by
  dsimp only
  have h : inputWidth n R ≤ 396397+3*R*n^2+R+n*n := Nat.size_le.mpr Nat.lt_two_pow_self
  have hw : width n R≤(n*n+2)*(396397+3*R*n^2+R+n*n+1) :=
    Nat.mul_le_mul_left _ (Nat.add_le_add_right h 1)
  gcongr

end FQChem.Complexity.FixedBasisArithmetic
