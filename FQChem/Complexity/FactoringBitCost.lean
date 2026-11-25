module

public import FQChem.Complexity.OrderFindingPostprocessing
public import FQChem.Complexity.OrderFindingBitCost
public import FQChem.Complexity.FactoringPreprocessing
public import FQChem.Complexity.FactoringRecursion
import Mathlib.Tactic

/-! # Binary costs of the classical branches in Shor's factoring reduction

These branching programs use the same ripple cells, shift-add multiplication,
restoring division and bitwise equalities as the continued-fraction decoder.
Word addressing, shifts, fan-out and static loop wiring are free in this model.
-/

@[expose] public section
namespace FQChem.Complexity.FactoringBitCost
open OrderFindingBitCost FactoringReduction

/-- The carry from y−x implements x ≤ y on unsigned fixed-width words. -/
def leWord (w x y : ℕ) : Bool × ℕ :=
  let r := ripple true w y x true
  (r.carry,r.gates)

theorem leWord_spec (w x y : ℕ) (hx : x < 2^w) (hy : y < 2^w) :
    leWord w x y = (decide (x≤y),6*w) := by
  have ⟨hb,hw,hs⟩ := ripple_spec true w y x true hy hx
  simp only [ite_true, Bool.toNat_true] at hs
  dsimp only [leWord]
  rw [hw]; congr 1
  cases h : (ripple true w y x true).carry <;> simp [h] at hs <;> simp <;> omega

/-- A saturating decrement; borrow on zero yields zero. -/
def predWord (w x : ℕ) : ℕ × ℕ :=
  let d := ripple true w x 1 true
  (if d.carry then d.word else 0,d.gates)

theorem predWord_spec (w x : ℕ) (hw : 1<2^w) (hx : x<2^w) :
    predWord w x = (x-1,6*w) := by
  have ⟨hb,hg,hs⟩ := ripple_spec true w x 1 true hx hw
  simp only [ite_true, Bool.toNat_true] at hs
  dsimp only [predWord]
  rw [hg]; congr 1
  cases h : (ripple true w x 1 true).carry <;> simp [h] at hs ⊢ <;> omega

/-- Euclid's remainder loop with a fixed public step allowance. -/
def gcdRun (w : ℕ) : ℕ → ℕ → ℕ → ℕ × ℕ
  | 0, x, _ => (x,0)
  | t+1, x, y =>
    let z := equalWord w y 0
    if z.1 then (x,z.2) else
      let d := divide (w+1) w x y
      let h := gcdRun w t y d.rem
      (h.1,z.2+d.gates+h.2)

private theorem gcdRun_spec (w t x y : ℕ) (hx : x<2^w) (hy : y<2^w)
    (ht : OrderFindingPostprocessing.divisions x y ≤ t) :
    (gcdRun w t x y).1 = x.gcd y ∧ (gcdRun w t x y).2 ≤ t*(20*(w+1)^2) := by
  induction t generalizing x y with
  | zero =>
    have hz : y=0 := by
      by_contra hn
      rw [OrderFindingPostprocessing.divisions,dite_eq_right hn] at ht; omega
    simp [gcdRun,hz]
  | succ t ih =>
    rw [gcdRun,equal_spec _ _ _ hy (by positivity)]
    by_cases hz : y=0
    · subst y; simp; nlinarith
    · have spec := divide_spec (w+1) w x y hx (by omega) (by rw [pow_succ]; omega)
      rw [OrderFindingPostprocessing.divisions,dite_eq_right hz] at ht
      have hr := (Nat.mod_lt x (by omega : 0<y)).trans hy
      have ⟨eq,cost⟩ := ih y (x%y) hy hr (by omega)
      simp only [hz,decide_false, Bool.false_eq_true, ite_false, spec, eq]
      refine ⟨?_, ?_⟩
      · rw [Nat.gcd_comm y (x%y), ← Nat.gcd_rec y x, Nat.gcd_comm]
      · nlinarith

def gcdWord (w x y : ℕ) := gcdRun w (2*w) x y

theorem gcdWord_spec (w x y : ℕ) (hx : x<2^w) (hy : y<2^w) :
    (gcdWord w x y).1 = x.gcd y ∧ (gcdWord w x y).2 ≤ 40*(w+1)^3 := by
  have ⟨h,c⟩ := gcdRun_spec w (2*w) x y hx hy (OrderFindingPostprocessing.divisions_bound w x y hy)
  exact ⟨h,c.trans (by nlinarith)⟩

/-- Multiply by the base e times. Only the logarithmically small e from the
perfect-power search is used. W is the output word size and b the base size. -/
def exactPower (W b x : ℕ) : ℕ → ℕ × ℕ
  | 0 => (1,0)
  | e+1 =>
    let h := exactPower W b x e
    let k := multiply W b h.1 x
    (k.1,h.2+k.2)

def wide (b : ℕ) := (b+1)^2
def powerBudget (b : ℕ) := b*(b*(10*wide b))

theorem exactPower_spec (b x e : ℕ) (hx : x<2^b) (he : e≤b) :
    exactPower (wide b) b x e = (x^e,e*(b*(10*wide b))) ∧ x^e<2^(wide b) := by
  have fits (j : ℕ) (hj : j≤b) : x^j<2^(wide b) := by
    calc
      x^j ≤ (2^b)^j := Nat.pow_le_pow_left hx.le _
      _ = 2^(b*j) := (pow_mul _ _ _).symm
      _ < 2^(wide b) := Nat.pow_lt_pow_right (by decide) (by unfold wide; nlinarith [Nat.mul_le_mul_left b hj])
  refine ⟨?_, fits _ he⟩
  induction e with
  | zero => simp [exactPower]
  | succ e ih =>
    rw [exactPower,ih (by omega),multiply_spec _ _ _ _ (fits _ (by omega)) hx
      (by simpa [pow_succ] using fits _ he)]
    simp [pow_succ,Nat.succ_mul]

private theorem root_range (N e j lo : ℕ) :
    (rootBits N e j lo).1 < lo+2^j := by
  induction j generalizing lo with
  | zero => simp [rootBits]
  | succ j ih =>
    rw [rootBits,pow_succ]
    split <;> exact (ih _).trans_le (by omega)

/-- Fixed-width binary digit search for an exact e-th root candidate. -/
def rootRun (N e b : ℕ) : ℕ → ℕ → ℕ × ℕ
  | 0, lo => (lo,0)
  | j+1, lo =>
    let m := ripple false b lo (2^j) false
    let pow := exactPower (wide b) b m.word e
    let cmp := leWord (wide b) pow.1 N
    let rest := rootRun N e b j (if cmp.1 then m.word else lo)
    (rest.1,m.gates+pow.2+cmp.2+rest.2)

def rootStep (b : ℕ) := 6*b+powerBudget b+6*wide b

theorem rootRun_spec (N e b j lo : ℕ) (hN : N<2^b) (he : e≤b) (hlo : lo+2^j≤2^b) :
    (rootRun N e b j lo).1 = (rootBits N e j lo).1 ∧ (rootRun N e b j lo).2 ≤ j*rootStep b := by
  have hw : b ≤ wide b := by unfold wide; nlinarith
  induction j generalizing lo with
  | zero => simp [rootRun,rootBits]
  | succ j ih =>
    rw [pow_succ] at hlo
    have hp := Nat.two_pow_pos j
    have hm : lo+2^j<2^b := by omega
    obtain ⟨rwM, gates⟩ := add_word b lo (2^j) hm
    have pow := exactPower_spec b (lo+2^j) e hm he
    have cmp := leWord_spec (wide b) ((lo+2^j)^e) N pow.2 (hN.trans_le (Nat.pow_le_pow_right (by decide) hw))
    let next := if (lo+2^j)^e≤N then lo+2^j else lo
    have sub :=  ih next (by unfold next; split <;> omega)
    simp only [rootRun,rootBits,rwM,pow.1,cmp,decide_eq_true_eq,gates]
    refine ⟨sub.1,?_⟩
    have ep : e*(b*(10*wide b)) ≤ powerBudget b := Nat.mul_le_mul_right _ he
    change _ + (rootRun N e b j next).2 ≤ _
    rw [Nat.succ_mul j (rootStep b)]
    unfold rootStep at sub ⊢
    omega

/-- Test every possible power exponent with the same digit-by-digit roots as preprocess. -/
def powersRun (N b : ℕ) : ℕ → Option ℕ × ℕ
  | 0 => (none,0)
  | j+1 =>
    let r := rootRun N (j+2) b b 0
    let p := exactPower (wide b) b r.1 (j+2)
    let eq := equalWord (wide b) p.1 N
    let lo := leWord b 2 r.1
    let hi := leWord b N r.1
    let work := r.2+p.2+eq.2+lo.2+hi.2+3
    if lo.1 && !hi.1 && eq.1 then (some r.1,work) else
      let next := powersRun N b j
      (next.1,work+next.2)

def exponentStep (b : ℕ) := b*rootStep b+powerBudget b+3*wide b+12*b+3

theorem powersRun_spec (N b j : ℕ) (hN : N<2^b) (hb : 2≤b) (hj : j<b) :
    (powersRun N b j).1 = (scanPowers N b j).1 ∧ (powersRun N b j).2 ≤ j*exponentStep b := by
  induction j with
  | zero => simp [powersRun,scanPowers]
  | succ j ih =>
    let r := (rootBits N (j+2) b 0).1
    have he : j+2≤b := by omega
    have root := rootRun_spec N (j+2) b b 0 hN he (by simp)
    have hr : r<2^b := by simpa [r] using root_range N (j+2) b 0
    have pow := exactPower_spec b r (j+2) hr he
    have hwide : b ≤ wide b := by unfold wide; nlinarith
    have two : 2<2^b := lt_of_lt_of_le (by decide : 2<2^2) (Nat.pow_le_pow_right (by decide) hb)
    have eq := equal_spec (wide b) (r^(j+2)) N pow.2 (hN.trans_le (Nat.pow_le_pow_right (by decide) hwide))
    have cost : (rootRun N (j+2) b b 0).2+(j+2)*(b*(10*wide b))+3*wide b+6*b+6*b+3 ≤ exponentStep b := by
      have z : (j+2)*(b*(10*wide b)) ≤ powerBudget b := Nat.mul_le_mul_right _ he
      unfold exponentStep
      omega
    have sub := ih (by omega)
    have cond : (2≤r ∧ r<N) ↔ (1<r ∧ r<N) := Iff.rfl
    simp only [powersRun,scanPowers,root.1,← show r=(rootBits N (j+2) b 0).1 from rfl,
      pow.1,eq,leWord_spec b 2 r two hr,leWord_spec b N r hN hr, Bool.and_eq_true,
      Bool.not_eq_true',decide_eq_true_eq,decide_eq_false_iff_not,Nat.not_le]
    by_cases ok : 1<r ∧ r<N ∧ r^(j+2)=N
    · have ok' : (2≤r ∧ r<N) ∧ r^(j+2)=N := ⟨⟨ok.1,ok.2.1⟩,ok.2.2⟩
      simp only [ok,ok',ite_true,true_and]
      exact cost.trans (Nat.le_mul_of_pos_left _ (by omega))
    · have ok' : ¬((2≤r ∧ r<N) ∧ r^(j+2)=N) := fun h => ok ⟨h.1.1,h.1.2,h.2⟩
      simp only [ok,ok',ite_false,sub.1,true_and]
      rw [Nat.succ_mul j (exponentStep b)]; omega

/-- Boolean implementation of the even/perfect-power preprocessor. -/
def preprocessWord (N : ℕ) :=
  let b := N.log2+1
  let large := leWord b 3 N
  if !low N && large.1 then (some 2,large.2+2)
  else
    let p := powersRun N b (N.log2-1)
    (p.1,large.2+2+p.2)

theorem preprocessWord_spec (N : ℕ) (hN : 2≤N) :
    let b := N.log2+1
    (preprocessWord N).1=(preprocess N).1 ∧ (preprocessWord N).2≤100*(b+1)^6 := by
  let b := N.log2+1
  have hb : 2≤b := by
    have := (Nat.le_log2 (by omega : N≠0)).mpr (show 2^1≤N by omega)
    dsimp [b];omega
  have hl : N<2^b := Nat.lt_log2_self
  have h3 : 3<2^b := lt_of_lt_of_le (by decide : 3<2^2) (Nat.pow_le_pow_right (by decide) hb)
  have pp := powersRun_spec N b (N.log2-1) hl hb (by dsimp [b];omega)
  have hc : 6*b+2+(N.log2-1)*exponentStep b ≤ 100*(b+1)^6 := by
    have hj : N.log2-1 ≤ b := by dsimp [b];omega
    calc
      _ ≤ 6*b+2+b*exponentStep b := by gcongr
      _ ≤ _ := by unfold exponentStep rootStep powerBudget wide; ring_nf; omega
  have test : (!low N && decide (3≤N)) = true ↔ N%2=0 ∧ 2<N := by
    simp only [low, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq, Nat.mod_two_eq_zero_iff_testBit_zero]
    rfl
  dsimp only
  simp only [preprocessWord,preprocess,← show b=N.log2+1 from rfl, leWord_spec b 3 N h3 hl,test]
  split
  · exact ⟨rfl, by omega⟩
  · exact ⟨pp.1, by omega⟩

/-- Recheck a proposed divisor and calculate the cofactor with a single
restoring division. The verified recursion subsequently splits on this pair. -/
def checkedPair (w m : ℕ) : Option ℕ → Option (ℕ × ℕ) × ℕ
  | none => (none,0)
  | some d =>
    let lo := leWord w 2 d
    let hi := leWord w m d
    if lo.1 && !hi.1 then
      let div := divide (w+1) w m d
      let eq := equalWord w div.rem 0
      (if eq.1 then some (d,div.quot) else none,lo.2+hi.2+2+div.gates+eq.2)
    else (none,lo.2+hi.2+2)

theorem checkedPair_spec (w m : ℕ) (c : Option ℕ) (hm : 2≤m) (hw : m<2^w)
    (hc : ∀ d ∈ c, d<2^w) :
    (checkedPair w m c).1 = (FactoringRecursion.certify m c).map (fun d => (d.val,d.other)) ∧
      (checkedPair w m c).2 ≤ 50*(w+1)^2 := by
  cases c with
  | none => simp [checkedPair,FactoringRecursion.certify]
  | some d =>
    have hd := hc d (by simp)
    have ha := leWord_spec w 2 d (by omega) hd
    have hb := leWord_spec w m d hw hd
    simp only [checkedPair,ha,hb,Bool.and_eq_true, Bool.not_eq_true',decide_eq_true_eq,decide_eq_false_iff_not,Nat.not_le]
    by_cases ok : 2≤d ∧ d<m
    · have dv := divide_spec (w+1) w m d hw (by omega) (by rw [pow_succ];omega)
      have hr : m%d<2^w := (Nat.mod_lt _ (by omega)).trans hd
      simp only [ok,dv,equal_spec w (m%d) 0 hr (by positivity), decide_eq_true_eq]
      by_cases hdiv : d ∣ m
      · have z := Nat.mod_eq_zero_of_dvd hdiv
        have ht : 1<d ∧ d<m ∧ d∣m := ⟨ok.1,ok.2,hdiv⟩
        simp [z,FactoringRecursion.certify,ht,FactoringRecursion.Divisor.other]; nlinarith
      · have z : m%d ≠ 0 := fun h => hdiv (Nat.dvd_of_mod_eq_zero h)
        simp [z,FactoringRecursion.certify,hdiv]; nlinarith
    · have ht : ¬(1<d ∧ d<m ∧ d∣m) := fun h => ok ⟨h.1,h.2.1⟩
      simp [ok,FactoringRecursion.certify,ht]; nlinarith

/-- Compute the candidate used by extractFactor. Subtraction saturates at zero,
just as natural-number subtraction in the original candidate. -/
def candidate (w m a r : ℕ) :=
  let g := gcdWord w a m
  let e := equalWord w g.1 1
  if e.1 then
    let p := power w m a w (r/2)
    let x := predWord w p.1
    let d := gcdWord w x.1 m
    (d.1,g.2+e.2+p.2+x.2+d.2)
  else (g.1,g.2+e.2)

theorem candidate_spec (w m a r : ℕ) (hm : 1<m) (ha : a<m) (hw : m<2^w) (hr : r<2^w) :
    let d := if a.gcd m=1 then (modPower m a (r/2)-1).gcd m else a.gcd m
    (candidate w m a r).1 = d ∧ d<2^w ∧ (candidate w m a r).2 ≤ 300*(w+1)^3 := by
  let g := a.gcd m
  have hg : g≤m := Nat.gcd_le_right _ (by omega)
  have gs := gcdWord_spec w a m (ha.trans hw) hw
  have eq := equal_spec w g 1 (hg.trans_lt hw) (by omega)
  dsimp only
  simp only [candidate,gs.1,← show g=a.gcd m from rfl,eq,decide_eq_true_eq]
  by_cases h : g=1
  · have ps := power_spec w m a w (r/2) hm hw ha (by omega)
    have hp := Nat.mod_lt (a^(r/2)) (by omega : 0<m)
    have pr := predWord_spec w (a^(r/2)%m) (by omega) (hp.trans hw)
    have gg := gcdWord_spec w (a^(r/2)%m-1) m (by omega) hw
    simp only [h,ite_true,ps.1,pr,gg.1,modPower_spec,true_and]
    refine ⟨(Nat.gcd_le_right _ (by omega)).trans_lt hw,?_⟩
    calc
      _ ≤ 40*(w+1)^3+3*w+w*(150*(w+1)^2)+6*w+40*(w+1)^3 :=
        Nat.add_le_add (Nat.add_le_add_right (Nat.add_le_add (Nat.add_le_add_right gs.2 _) ps.2) _) gg.2
      _ ≤ _ := by ring_nf;omega
  · simp only [h,ite_false,true_and]
    exact ⟨hg.trans_lt hw,(Nat.add_le_add_right gs.2 (3*w)).trans (by ring_nf; omega)⟩

/-- Same successful pair as measuredFactor followed by certify and exact division. -/
def extractPair (w m a r : ℕ) :=
  let d := candidate w m a r
  let p := checkedPair w m (some d.1)
  (p.1,d.2+p.2)

theorem extractPair_spec (w m a r : ℕ) (hm : 1<m) (ha : a<m) (hw : m<2^w) (hr : r<2^w) :
    (extractPair w m a r).1 = (FactoringRecursion.certify m (extractFactor m a r)).map
      (fun d => (d.val,d.other)) ∧ (extractPair w m a r).2 ≤ 400*(w+1)^3 := by
  let d := if a.gcd m=1 then (modPower m a (r/2)-1).gcd m else a.gcd m
  have ⟨deq,dw,dc⟩ := candidate_spec w m a r hm ha hw hr
  change (candidate w m a r).1 = d at deq
  have ch := checkedPair_spec w m (some d) hm hw (by simpa using dw)
  dsimp only [extractPair]
  rw [deq]
  refine ⟨ch.1.trans ?_, (Nat.add_le_add dc ch.2).trans (by ring_nf; omega)⟩
  change _ = (FactoringRecursion.certify m (if 1<d ∧ d<m then some d else none)).map _
  by_cases ok : 1<d ∧ d<m
  · rw [ite_eq_left ok]
  · have invalid : ¬(1<d ∧ d<m ∧ d∣m) := fun h => ok ⟨h.1,h.2.1⟩
    simp [ok, FactoringRecursion.certify,invalid]

/-- Turn a uniform bit word into a positive base or discard it. The carry,
comparison and increment are implemented by the existing fixed-width cells. -/
def readBase (w m x : ℕ) :=
  let hi := predWord w m
  let skip := leWord w hi.1 x
  if skip.1 then (none,hi.2+skip.2)
  else
    let a := ripple false w x 1 false
    (some a.word,hi.2+skip.2+a.gates)

theorem readBase_spec (w m x : ℕ) (hm : 1<m) (hw : m<2^w) (hx : x<2^w) :
    (readBase w m x).1 = (baseFromBits m x).map (fun i => i.val+1) ∧
      (readBase w m x).2 ≤ 18*w := by
  have pr := predWord_spec w m (by omega) hw
  have cmp := leWord_spec w (m-1) x (by omega) hx
  dsimp only [readBase]
  simp only [pr,cmp,decide_eq_true_eq,baseFromBits]
  by_cases ok : x<m-1
  · obtain ⟨word, gates⟩ := add_word w x 1 (by omega)
    simp only [ok,ite_eq_right (by omega : ¬m-1≤x),dite_eq_left,word,gates,Option.map_some,true_and]
    omega
  · simp [ok,show m-1≤x by omega];omega

theorem decoded_bound (m a o Q t : ℕ) (hQ : 0<Q) : (OrderFindingDecoder.scan m a o Q t).order ≤ Q := by
  induction t with
  | zero => simp [OrderFindingDecoder.scan]
  | succ t ih =>
    have bound := (OrderFindingDecoder.convergent_bounds o Q t hQ).2.1
    simp only [OrderFindingDecoder.scan]
    split
    · split <;> omega
    · exact ih

/-- All classical work after accepting the base a, including its first gcd to
decide whether to run the quantum program. Q is the supplied clock size, and
o is the measured outcome, unused on the nonunit branch. -/
def baseRun (w m a o Q : ℕ) :=
  let g := gcdWord w a m
  let test := equalWord w g.1 1
  if test.1 then
    let d := OrderFindingBitCost.scan w m a o Q (2*(Q.log2+1)+1)
    let f := extractPair w m a d.1
    (f.1,g.2+test.2+d.2+f.2+1)
  else
    let f := checkedPair w m (some g.1)
    (f.1,g.2+test.2+f.2+1)

theorem baseRun_spec (w m a o Q : ℕ) (hm : 1<m) (ha : 0<a) (ham : a<m) (ho : o<Q)
    (hw : m<2^w) (hq : Q<2^w) :
    let raw := extractFactor m a (OrderFindingDecoder.decode m a o Q).order
    (baseRun w m a o Q).1 = (FactoringRecursion.certify m raw).map (fun d => (d.val,d.other)) ∧
      (baseRun w m a o Q).2 ≤ 2000*(w+1)^4 := by
  have hQ : 0<Q := by omega
  have gcd := gcdWord_spec w a m (ham.trans hw) hw
  have gw := (Nat.gcd_le_right a (by omega : 0<m)).trans_lt hw
  have eq := equal_spec w (a.gcd m) 1 gw (by omega)
  dsimp only [baseRun]
  simp only [gcd.1,eq,decide_eq_true_eq]
  by_cases unit : a.gcd m=1
  · have dec := decoder_bit_bound w m a o Q hm ham ho hw hq
    have dr : (OrderFindingDecoder.decode m a o Q).order < 2^w := (decoded_bound m a o Q _ hQ).trans_lt hq
    have chk := extractPair_spec w m a (OrderFindingDecoder.decode m a o Q).order hm ham hw dr
    simp only [unit,ite_true,dec.1,chk.1,true_and]
    calc
      _ ≤ 40*(w+1)^3+3*w+1000*(w+1)^4+400*(w+1)^3+1 :=
        Nat.add_le_add_right (Nat.add_le_add (Nat.add_le_add (Nat.add_le_add_right gcd.2 _) dec.2) chk.2) _
      _ ≤ _ := by ring_nf;omega
  · have chk := checkedPair_spec w m (some (a.gcd m)) hm hw (by simpa using gw)
    rw [extractFactor_nonunit ha ham unit]
    simp only [unit,ite_false,chk.1,true_and]
    calc
      _ ≤ 40*(w+1)^3+3*w+50*(w+1)^2+1 :=
        Nat.add_le_add_right (Nat.add_le_add (Nat.add_le_add_right gcd.2 _) chk.2) _
      _ ≤ _ := by ring_nf;omega

/-- The raw classical branch function whose distributions are assembled in the
factoring law: preprocess, discard oversized fair words, then use the measured
record for units or the known gcd for nonunits. -/
def raw (m word o Q : ℕ) : Option ℕ :=
  match (preprocess m).1 with
  | some d => some d
  | none => match baseFromBits m word with
    | none => none
    | some i => extractFactor m (i.val+1) (OrderFindingDecoder.decode m (i.val+1) o Q).order

def bitTrial (m word o Q : ℕ) :=
  let b := m.log2+1
  let pre := preprocessWord m
  match pre.1 with
  | some d =>
    let f := checkedPair b m (some d)
    (f.1,pre.2+f.2+1)
  | none =>
    let base := readBase b m word
    match base.1 with
    | none => (none,pre.2+base.2+2)
    | some a =>
      let f := baseRun (2*b+2) m a o Q
      (f.1,pre.2+base.2+f.2+2)

theorem bitTrial_spec (m word o Q : ℕ) (hm : 2≤m) (hx : word<2^(m.log2+1)) (ho : o<Q)
    (hq : Q<2^(2*(m.log2+1)+2)) :
    (bitTrial m word o Q).1 = (FactoringRecursion.certify m (raw m word o Q)).map
      (fun d => (d.val,d.other)) ∧ (bitTrial m word o Q).2 ≤ 1000000*(m.log2+2)^6 := by
  let b := m.log2+1
  have hw : m<2^b := Nat.lt_log2_self
  have hn := hw.trans_le (Nat.pow_le_pow_right (by decide : 2>0) (show b≤2*b+2 by omega))
  have pre := preprocessWord_spec m hm
  have read := readBase_spec b m word hm hw hx
  simp only [bitTrial,raw,pre.1,← show b=m.log2+1 from rfl]
  cases h : (preprocess m).1 with
  | some d =>
    have hd := preprocess_sound h
    have chk := checkedPair_spec b m (some d) hm hw (by simpa using hd.2.1.trans hw)
    simp only [chk.1,true_and]
    apply (Nat.add_le_add_right (Nat.add_le_add pre.2 chk.2) 1).trans
    change _ ≤ 1000000*(b+1)^6
    change 100*(b+1)^6+50*(b+1)^2+1 ≤ _
    ring_nf;omega
  | none =>
    rw [read.1]
    cases hb : baseFromBits m word with
    | none =>
      simp only [Option.map_none,FactoringRecursion.certify,true_and]
      apply (Nat.add_le_add_right (Nat.add_le_add pre.2 read.2) 2).trans
      change 100*(b+1)^6+18*b+2 ≤ 1000000*(b+1)^6
      ring_nf;omega
    | some i =>
      have bound := baseRun_spec (2*b+2) m (i.val+1) o Q hm (by omega) (by have := i.isLt; omega) ho hn hq
      simp only [Option.map_some,bound.1,true_and]
      apply (Nat.add_le_add_right (Nat.add_le_add (Nat.add_le_add pre.2 read.2) bound.2) 2).trans
      change 100*(b+1)^6+18*b+2000*(2*b+2+1)^4+2 ≤ 1000000*(b+1)^6
      ring_nf;omega

end FQChem.Complexity.FactoringBitCost
