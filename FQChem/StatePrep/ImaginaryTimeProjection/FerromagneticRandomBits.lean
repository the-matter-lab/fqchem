module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticMonteCarlo
import Mathlib.Tactic

/-! # Finite random bits for subgraphs-world Metropolis trajectories

For integer weights the lazy Metropolis comparison is implemented by integer
division and a uniform bit string. A one-step comparison with the ideal transition
controls every bounded readout of the entire trajectory, including correlated
samples after burn-in.
-/

@[expose] public section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs.RandomBits
open IsingSign

/-- Number of accepted strings in the lazy Metropolis decision with positive
integer weights before and after the proposed flip. -/
def cutoff (bits w v : ℕ) := 2^bits * min w v / (2*w)

def accepts (bits w v : ℕ) (coin : Fin (2^bits)) := decide (coin.val < cutoff bits w v)

private theorem cutoffLe (bits w v : ℕ) (hw : 0 < w) : cutoff bits w v ≤ 2^bits := by
  apply Nat.le_of_mul_le_mul_right (c:=2*w) _ (by omega)
  calc cutoff bits w v * (2*w) ≤ 2^bits * min w v := Nat.div_mul_le_self _ _
       _ ≤ 2^bits * (2*w) := Nat.mul_le_mul_left _ (by omega)

/-- Exact probability of the executable threshold comparison. -/
theorem acceptedStrings (bits w v : ℕ) (hw : 0 < w) :
    (Finset.univ.filter (fun coin : Fin (2^bits) => accepts bits w v coin)).card = cutoff bits w v := by
  let N := 2^bits
  let a := cutoff bits w v
  let inc : Fin a ↪ Fin N := Fin.castLEEmb (cutoffLe bits w v hw)
  have all : (Finset.univ.filter (fun coin : Fin N => accepts bits w v coin)) = Finset.univ.map inc := by
    ext i
    simp only [Finset.mem_filter,Finset.mem_univ,true_and,Finset.mem_map,accepts,decide_eq_true_eq]
    exact ⟨fun hi => ⟨⟨i.val,hi⟩,Fin.ext rfl⟩, fun ⟨j,hj⟩ => hj ▸ j.isLt⟩
  rw [all,Finset.card_map,Finset.card_univ,Fintype.card_fin]

/-- Clear a common denominator from every boosted subgraph weight. The edge
count and odd-vertex flags are computed from the occupied bonds. -/
def integerWeight {n : ℕ} (m a b u k : ℕ) (odd : Fin n → Bool) : ℕ :=
  a^k * b^(m-k) * ∏ i, if odd i then 1 else u

noncomputable section

/-- Finite random bits change the acceptance probability by strictly less
than one unit in the last place. -/
theorem acceptanceError (bits w v : ℕ) (hw : 0 < w) :
    let p := (min w v : ℝ)/(2*w)
    let q := (cutoff bits w v : ℝ)/(2^bits)
    q ≤ p ∧ p < q + 1/2^bits := by
  let a := 2^bits * min w v
  let b := 2*w
  have hb : 0 < b := by dsimp [b]; omega
  have lo : cutoff bits w v * b ≤ a := Nat.div_mul_le_self _ _
  have hi : a < (cutoff bits w v + 1)*b := by
    exact (Nat.div_lt_iff_lt_mul hb).mp (Nat.lt_succ_self _)
  have lo' : (cutoff bits w v : ℝ)*(2*w) ≤ 2^(bits : ℕ)*(min w v : ℝ) := by exact_mod_cast lo
  have hi' : (2:ℝ)^bits*(min w v : ℝ) < ((cutoff bits w v : ℝ)+1)*(2*w) := by exact_mod_cast hi
  have bpos : 0 < 2*(w:ℝ) := by positivity
  have dpos : 0 < (2:ℝ)^bits := by positivity
  constructor
  · exact (div_le_div_iff₀ dpos bpos).mpr (by linarith)
  · rw [← add_div]; exact (div_lt_div_iff₀ bpos dpos).mpr (by linarith)

/-- A word is split into complete batches covering every edge once, with a
short final batch held as a no-move outcome. No rejection loop is needed. -/
def decodeWord (bits m : ℕ) :
    Fin (2^bits) ≃ (Fin m × Fin (2^bits / m)) ⊕ Fin (2^bits % m) :=
  (finCongr (Nat.div_add_mod (2^bits) m).symm).trans
    (finSumFinEquiv.symm.trans (Equiv.sumCongr finProdFinEquiv.symm (Equiv.refl _)))

/-- Sampling from the complete batches is exactly uniform over their edge
labels. The unused mass is the remainder divided by the number of strings. -/
theorem wordAverage (bits m : ℕ) (f : Fin m → ℝ) (stay : ℝ) :
    (∑ s : Fin (2^bits), (decodeWord bits m s).elim (fun p => f p.1) (fun _ => stay)) =
      (2^bits / m : ℕ) * ∑ e, f e + (2^bits % m : ℕ)*stay := by
  rw [Equiv.sum_comp (decodeWord bits m),Fintype.sum_sum_type,Fintype.sum_prod_type]
  simp [Finset.mul_sum]

/-- One complete finite-coin update on the input edge list. Each of the
two arguments is a word of exactly `bits` independent fair bits. -/
def chooseMove {m : ℕ} {α : Type*} (bits : ℕ) (w : ℕ) (v : Fin m → ℕ)
    (stay : α) (move : Fin m → α) (edge coin : Fin (2^bits)) : α :=
  (decodeWord bits m edge).elim
    (fun p => if accepts bits w (v p.1) coin then move p.1 else stay) (fun _ => stay)

private theorem choiceSum {k : ℕ} {P : Fin k → Bool} (a b : ℝ) :
    (∑ i, (if P i then a else b)) = (k:ℝ)*b + ((Finset.univ.filter (fun i => P i)).card:ℝ)*(a-b) := by
  have eq (i : Fin k) : (if P i then a else b) = b + (if P i then a-b else 0) := by
    cases P i <;> simp
  simp only [eq, Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, ← Finset.sum_filter]

/-- For an observable in [0,1], a complete finite-bit update differs from
the uniform-edge ideal Metropolis expectation by at most (m+1)/2^bits. -/
theorem finiteStepError {m : ℕ} {α : Type*} (bits : ℕ) (hm : 0 < m)
    (w : ℕ) (hw : 0 < w) (v : Fin m → ℕ) (stay : α) (move : Fin m → α)
    (f : α → ℝ) (bound : ∀ A, 0 ≤ f A ∧ f A ≤ 1) :
    let D := ((2:ℝ)^bits)
    let p := fun e => (min w (v e) : ℝ)/(2*w)
    let ideal := (∑ e, ((1-p e)*f stay + p e*f (move e)))/m
    let sampled := (∑ edge, ∑ coin, f (chooseMove bits w v stay move edge coin))/(D*D)
    |sampled-ideal| ≤ ((m:ℝ)+1)/D := by
  intro D p ideal sampled
  let q := fun e => (cutoff bits w (v e):ℝ)/D
  let Q : ℝ := (2^bits / m : ℕ)
  let R : ℝ := (2^bits % m : ℕ)
  let diff := fun e => f (move e)-f stay
  have dp : 0 < D := by dsimp [D]; positivity
  have mp : 0 < (m:ℝ) := by exact_mod_cast hm
  have split : (m:ℝ)*Q+R=D := by dsimp [Q,R,D]; exact_mod_cast Nat.div_add_mod (2^bits) m
  have rem : R ≤ m := by dsimp [R]; exact_mod_cast (Nat.mod_lt (2^bits) hm).le
  have rem0 : 0 ≤ R := by dsimp [R]; positivity
  -- Only complete batches propose a move; the residual edge strings stay put.
  let batchMass := (m : ℝ) * Q / D
  have totalMass : batchMass + R/D = 1 := by
    dsimp only [batchMass]
    rw [← add_div, split, div_self dp.ne']
  have mass_le_one : batchMass ≤ 1 := totalMass ▸ le_add_of_nonneg_right (div_nonneg rem0 dp.le)
  have coin (e : Fin m) : (∑ i, f (if accepts bits w (v e) i then move e else stay)) =
      D * (f stay + q e*diff e) := by
    simp only [apply_ite f]
    rw [choiceSum,acceptedStrings _ _ _ hw]
    dsimp [q,diff,D]
    push_cast
    field_simp
  have eqSample : sampled = (Q/D)*(∑ e, (f stay + q e*diff e)) + (R/D)*f stay := by
    have swap : (∑ edge, ∑ coin, f (chooseMove bits w v stay move edge coin)) =
        ∑ edge : Fin (2^bits), (decodeWord bits m edge).elim (fun p => D*(f stay+q p.1*diff p.1)) (fun _ => D*f stay) := by
      apply Finset.sum_congr rfl
      intro e _
      unfold chooseMove
      cases decodeWord bits m e with
      | inl p => exact coin p.1
      | inr r => simp [D]
    dsimp only [sampled]
    rw [swap,wordAverage bits m (fun e => D*(f stay+q e*diff e)) (D*f stay),← Finset.mul_sum]
    change (Q*(D*_)+R*(D*_))/(D*D) = _
    field_simp
  have idealForm : ideal = (∑ e, (f stay+p e*diff e))/m := by
    dsimp only [ideal]; congr 1; apply Finset.sum_congr rfl; intro e _; dsimp [diff]; ring
  -- Centering at the stay outcome leaves only the change in the move probabilities.
  have centered : sampled-ideal = (∑ e, (batchMass*q e-p e)*diff e)/m := by
    rw [eqSample, idealForm]
    simp_rw [sub_mul, mul_assoc batchMass]
    simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    dsimp only [batchMass]
    field_simp [mp.ne', dp.ne']
    linear_combination f stay * (m:ℝ) * split
  have loss (e : Fin m) : |batchMass*q e-p e| ≤ ((m:ℝ)+1)/D := by
    obtain ⟨lower, upper⟩ := acceptanceError bits w (v e) hw
    change q e ≤ p e at lower
    change p e < q e + 1/D at upper
    have q0 : 0 ≤ q e := div_nonneg (Nat.cast_nonneg _) dp.le
    have q1 : q e ≤ 1 := (div_le_one dp).mpr (by
      dsimp only [D]
      exact_mod_cast cutoffLe bits w (v e) hw)
    rw [abs_of_nonpos (sub_nonpos.mpr ((mul_le_of_le_one_left q0 mass_le_one).trans lower)), neg_sub]
    calc
      p e - batchMass * q e = (p e - q e) + R / D * q e := by
        linear_combination -q e * totalMass
      _ ≤ 1 / D + R / D :=
        add_le_add (by linarith only [upper]) (mul_le_of_le_one_right (div_nonneg rem0 dp.le) q1)
      _ ≤ _ := by
        rw [← add_div, add_comm]
        exact div_le_div_of_nonneg_right (add_le_add rem le_rfl) dp.le
  rw [centered, abs_div, abs_of_pos mp]
  apply (div_le_iff₀ mp).mpr
  calc _ ≤ _ := Finset.abs_sum_le_sum_abs _ _
       _ ≤ ∑ _e : Fin m, (((m:ℝ)+1)/D) := by
          apply Finset.sum_le_sum
          intro e _
          rw [abs_mul]
          have hf : |diff e| ≤ 1 := abs_sub_le_iff.mpr
            ⟨(sub_le_self _ (bound stay).1).trans (bound _).2,
             (sub_le_self _ (bound _).1).trans (bound stay).2⟩
          exact (mul_le_of_le_one_right (abs_nonneg _) hf).trans (loss e)
       _ = _ := by simp [mul_comm]

variable {n : ℕ}

/-- On a positive rational proposal parameter a/b and boost 1/u, all
Metropolis weights have the same denominator b^m u^n. -/
theorem integerWeightSpec (B : Finset (Spin n)) (A : Config B) {a b u : ℕ}
    (hb : 0 < b) (hu : 0 < u) :
    (integerWeight B.card a b u A.val.card (boundary A.val) : ℝ) =
      ((b:ℝ)^B.card*(u:ℝ)^n) * boostedWeight ((a:ℝ)/b) (u:ℝ)⁻¹ A.val := by
  have hk : A.val.card ≤ B.card := Finset.card_le_card (Finset.mem_powerset.mp A.property)
  have bp : (0:ℝ) < b := by exact_mod_cast hb
  have up : (0:ℝ) < u := by exact_mod_cast hu
  have bonds : (b:ℝ)^B.card * ((a:ℝ)/b)^A.val.card = (a:ℝ)^A.val.card * (b:ℝ)^(B.card-A.val.card) := by
    conv_lhs => lhs; rw [← Nat.sub_add_cancel hk, pow_add]
    rw [div_pow]
    field_simp
  have parity : (u:ℝ)^n * oddFactor (u:ℝ)⁻¹ (boundary A.val) =
      ∏ i, if boundary A.val i then (1:ℝ) else u := by
    have common : (u:ℝ)^n = ∏ _ : Fin n, (u:ℝ) := by simp
    rw [common,oddFactor, ← Finset.prod_mul_distrib]
    apply Finset.prod_congr rfl
    intro i _
    cases (boundary A.val i) <;> simp [up.ne']
  simp only [integerWeight,Nat.cast_mul,Nat.cast_pow,Nat.cast_prod,Nat.cast_ite,Nat.cast_one]
  unfold boostedWeight
  rw [← bonds,← parity]
  ring

theorem integerRatio (B : Finset (Spin n)) (A : Config B) (e : ↥B)
    {a b u : ℕ} (ha : 0 < a) (hb : 0 < b) (hu : 0 < u) :
    let w := fun p : Config B => integerWeight B.card a b u p.val.card (boundary p.val)
    let p := acceptance (fun p : Config B => boostedWeight ((a:ℝ)/b) (u:ℝ)⁻¹ p.val) e A
    0 < w A ∧ p = (min (w A) (w (flip e A)) : ℝ)/(2*(w A : ℝ)) := by
  intro w p
  let Z := (b:ℝ)^B.card * (u:ℝ)^n
  let W := fun p : Config B => boostedWeight ((a:ℝ)/b) (u:ℝ)⁻¹ p.val
  have wz (T : Config B) : (w T : ℝ) = Z*W T := integerWeightSpec B T hb hu
  have zp : 0 < Z := by dsimp [Z]; positivity
  have wp (T : Config B) : 0 < W T := boostedWeightPositive (by positivity) (by positivity) _
  have whole : 0 < w A := by exact_mod_cast (wz A ▸ mul_pos zp (wp A) : 0 < (w A : ℝ))
  refine ⟨whole,?_⟩
  change min (W A) (W (flip e A)) / (2*W A) = _
  rw [wz,wz,← mul_min_of_nonneg _ _ zp.le]
  field_simp [zp.ne',(wp A).ne']

/-- The integer comparison implements the physical Metropolis ratio for a
proposed bond flip with probability error less than 2⁻ᵇⁱᵗˢ. -/
theorem finiteAcceptance (B : Finset (Spin n)) (A : Config B) (e : ↥B)
    {a b u : ℕ} (ha : 0 < a) (hb : 0 < b) (hu : 0 < u) (bits : ℕ) :
    let w := fun p : Config B => integerWeight B.card a b u p.val.card (boundary p.val)
    let p := acceptance (fun p : Config B => boostedWeight ((a:ℝ)/b) (u:ℝ)⁻¹ p.val) e A
    let q := ((Finset.univ.filter (fun i : Fin (2^bits) => accepts bits (w A) (w (flip e A)) i)).card : ℝ) / 2^bits
    q ≤ p ∧ p < q + 1/2^bits := by
  intro w p q
  obtain ⟨whole,prob⟩ := integerRatio B A e ha hb hu
  dsimp only [q,p]
  rw [acceptedStrings _ _ _ whole,prob]
  exact acceptanceError _ _ _ whole

variable {α : Type*} [Fintype α]

/-- Error propagation for a bounded readout of a complete Markov path.
The initial law and each transition row may have separate L¹ tolerances. -/
theorem trajectoryError (K J : α → α → ℝ)
    (hK : ∀ a, (∀ b, 0 ≤ K a b) ∧ ∑ b, K a b = 1)
    (hJ : ∀ a, (∀ b, 0 ≤ J a b) ∧ ∑ b, J a b = 1)
    {δ L : ℝ} (hδ : 0 ≤ δ) (hL : 0 ≤ L) (op : ∀ a, ∑ b, |J a b - K a b| ≤ δ)
    (k : ℕ) (q p : α → ℝ) (hq : (∀ a, 0 ≤ q a) ∧ ∑ a, q a = 1)
    (hp : (∀ a, 0 ≤ p a) ∧ ∑ a, p a = 1) (F : (Fin k → α) → ℝ) (range : ∀ ω, 0 ≤ F ω ∧ F ω ≤ L) :
    |expected (trajectory J k q) F - expected (trajectory K k p) F| ≤
      ((∑ a, |q a-p a|) + (k:ℝ)*δ)*L := by
  induction k generalizing q p with
  | zero =>
    simp only [trajectory,sub_self,abs_zero]
    positivity
  | succ k ih =>
    have middle := trajectoryCons K q k F
    have delta : |expected (trajectory J (k+1) q) F - expected (trajectory K (k+1) q) F| ≤ ((k:ℝ)+1)*δ*L := by
      rw [trajectoryCons,middle,expected,expected,← Finset.sum_sub_distrib]
      apply (Finset.abs_sum_le_sum_abs ..).trans
      calc _ ≤ ∑ a, q a*(((k:ℝ)+1)*δ*L) := by
            apply Finset.sum_le_sum
            intro a _
            rw [← mul_sub,abs_mul,abs_of_nonneg (hq.1 a)]
            apply mul_le_mul_of_nonneg_left _ (hq.1 a)
            have smaller := ih (J a) (K a) (hJ a) (hK a) (fun ω => F (Fin.cons a ω)) (fun _ => range _)
            refine smaller.trans (mul_le_mul_of_nonneg_right ?_ hL)
            linarith [op a]
           _ = _ := by rw [← Finset.sum_mul,hq.2,one_mul]
    have init := initialDrift K hK q p (Nat.zero_lt_succ k) F range
    calc _ ≤ _ := abs_sub_le _ (expected (trajectory K (k+1) q) F) _
         _ ≤ _ := add_le_add delta init
         _ = _ := by push_cast; ring

variable {m : ℕ}

/-- The empirical law of a full uniform pair of bit words. -/
def pairLaw {S : Type*} [DecidableEq S] (bits : ℕ) (update : Fin (2^bits) → Fin (2^bits) → S) (T : S) : ℝ :=
  (∑ i, ∑ j, if T = update i j then (1:ℝ) else 0) / ((2:ℝ)^bits*(2:ℝ)^bits)

theorem pairReadout {S : Type*} [Fintype S] [DecidableEq S] (bits : ℕ)
    (update : Fin (2^bits) → Fin (2^bits) → S) (f : S → ℝ) :
    expected (pairLaw bits update) f = (∑ i, ∑ j, f (update i j))/((2:ℝ)^bits*(2:ℝ)^bits) := by
  simp only [expected,pairLaw,div_mul_eq_mul_div,← Finset.sum_div,Finset.sum_mul]
  congr 1
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  rw [Finset.sum_comm]
  simp [ite_mul]

theorem pairProbability {S : Type*} [Fintype S] [DecidableEq S] (bits : ℕ)
    (update : Fin (2^bits) → Fin (2^bits) → S) :
    (∀ T, 0 ≤ pairLaw bits update T) ∧ ∑ T, pairLaw bits update T = 1 := by
  refine ⟨fun T => by unfold pairLaw; positivity,?_⟩
  simpa [expected,mul_self_eq_one_iff,ne_of_gt (by positivity : 0<(2:ℝ)^bits)] using pairReadout bits update (fun _ => 1)

def graphUpdate (B : Finset (Spin n)) (order : Fin m ≃ ↥B) (a b u bits : ℕ) (A : Config B) :=
  let w := fun T : Config B => integerWeight B.card a b u T.val.card (boundary T.val)
  let move := fun i => flip (order i) A
  chooseMove bits (w A) (fun i => w (move i)) A move

theorem kernelReadout (g : Glass n) (order : Fin m ≃ ↥g.bonds) (hm : 0<m) (x u : ℝ)
    (A : Config g.bonds) (f : Config g.bonds → ℝ) :
    let p := fun i => acceptance (fun T : Config g.bonds => boostedWeight x u T.val) (order i) A
    expected (kernel g x u A) f = (∑ i, ((1-p i)*f A + p i*f (flip (order i) A)))/m := by
  have size : m = g.bonds.card := by simpa using Fintype.card_congr order
  simp only [expected,kernel,← size,ite_eq_right hm.ne',div_mul_eq_mul_div,← Finset.sum_div,Finset.sum_mul]
  congr 1
  rw [Finset.sum_comm,← Equiv.sum_comp order]
  apply Finset.sum_congr rfl
  intro i _
  simp [edgeStep,add_mul,Finset.sum_add_distrib,ite_mul]

/-- Every bounded test of a physical integer-weight update obeys the stated
finite-word error, independent of the number of subgraph configurations. -/
theorem graphReadout (g : Glass n) (order : Fin m ≃ ↥g.bonds) (hm : 0<m)
    {a b u : ℕ} (ha : 0<a) (hb : 0<b) (hu : 0<u) (bits : ℕ)
    (A : Config g.bonds) (f : Config g.bonds → ℝ) (range : ∀ T, 0≤f T ∧ f T≤1) :
    let J := pairLaw bits (graphUpdate g.bonds order a b u bits A)
    |expected J f - expected (kernel g ((a:ℝ)/b) (u:ℝ)⁻¹ A) f| ≤ ((m:ℝ)+1)/2^bits := by
  let w := fun T : Config g.bonds => integerWeight g.bonds.card a b u T.val.card (boundary T.val)
  let move := fun i => flip (order i) A
  have hw : 0<w A := (integerRatio g.bonds A (order ⟨0,hm⟩) ha hb hu).1
  have test := finiteStepError bits hm (w A) hw (fun i => w (move i)) A move f range
  dsimp only
  rw [pairReadout,kernelReadout g order hm]
  simpa only [graphUpdate,w,move,fun i => (integerRatio g.bonds A (order i) ha hb hu).2] using test

theorem rowL1 {S : Type*} [Fintype S] (j k : S → ℝ) (hj : ∑ s, j s = 1) (hk : ∑ s, k s=1)
    (δ : ℝ) (every : ∀ f : S → ℝ, (∀ s, 0≤f s ∧ f s≤1) → |expected j f - expected k f| ≤ δ) :
    ∑ s, |j s - k s| ≤ 2*δ := by
  classical
  let f := fun s => if k s ≤ j s then (1:ℝ) else 0
  have test := (le_abs_self _).trans (every f fun s => by dsimp [f]; split <;> norm_num)
  have eq (s : S) : |j s-k s| = 2*(j s*f s-k s*f s)-(j s-k s) := by
    by_cases h : k s ≤ j s
    · rw [abs_of_nonneg (sub_nonneg.mpr h)]; simp [f,h]; ring
    · rw [abs_of_nonpos (sub_nonpos.mpr (le_of_not_ge h))]; simp [f,h]
  simp only [eq,Finset.sum_sub_distrib,← Finset.mul_sum,hj,hk,sub_self,sub_zero]
  exact mul_le_mul_of_nonneg_left test (by norm_num)

/-- Over a whole trajectory from an arbitrary initial distribution, the
finite-word simulator of the rational-proposal chain changes a bounded
readout in [0,L] by at most 2k(m+1)L/2^bits, using two words per update. -/
theorem finiteTrajectory (g : Glass n) (order : Fin m ≃ ↥g.bonds) (hm : 0<m)
    {a b u : ℕ} (ha : 0<a) (hb : 0<b) (hu : 0<u) (bits k : ℕ)
    (q : Config g.bonds → ℝ) (hq : (∀ A, 0≤q A) ∧ ∑ A,q A=1)
    (F : (Fin k → Config g.bonds) → ℝ) {L : ℝ} (hL : 0≤L) (range : ∀ ω, 0≤F ω ∧ F ω≤L) :
    let J := fun A => pairLaw bits (graphUpdate g.bonds order a b u bits A)
    let K := kernel g ((a:ℝ)/b) (u:ℝ)⁻¹
    |expected (trajectory J k q) F - expected (trajectory K k q) F| ≤ k*(2*((m:ℝ)+1)/2^bits)*L := by
  intro J K
  have hJ (A : Config g.bonds) := pairProbability bits (graphUpdate g.bonds order a b u bits A)
  have hK := kernelProbability g (x:=(a:ℝ)/b) (u:=(u:ℝ)⁻¹) (by positivity) (by positivity)
  have d (A : Config g.bonds) : ∑ T, |J A T-K A T| ≤ 2*((m:ℝ)+1)/2^bits := by
    simpa [mul_div_assoc] using rowL1 (J A) (K A) (hJ A).2 (hK A).2 _
      (fun f => graphReadout g order hm ha hb hu bits A f)
  simpa using trajectoryError K J hK hJ (by positivity) hL d k q q hq hq F range

end
end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs.RandomBits
