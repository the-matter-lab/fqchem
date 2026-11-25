import FQChemForShor.FactoringLaw
import FQChemForShor.VerifiedOrderFinding
import FQChem.Complexity.FactoringBitCost

/-! # Resource bounds for recursive Shor factorization

The same program and per-shot laws as the success proof are charged at the
actual modulus of each recursively visited node.
-/

namespace FQChem.Complexity.FactoringResources
open Shor Shor.Model Shor.Reference Shor.Model.QuantumLib
open OrderFinding FactoringRecursion

noncomputable def baseGates (m a : ℕ) : ℕ :=
  if h : (0<a ∧ a<m) ∧ a.gcd m = 1 then
    LowGate.gateCount shorGateCostModel (program ⟨a,m,h.1,h.2⟩).circuit
  else 0

/-- Finite majorant over legal unit bases of a modulus; it is used only in
proofs and costs no step in the factoring procedure. -/
noncomputable def gateCap (m : ℕ) := (Finset.range m).sup (baseGates m)

theorem gateCap_covers (inst : ShorOrderFindingInstance) :
    LowGate.gateCount shorGateCostModel (program inst).circuit ≤ gateCap inst.N := by
  obtain ⟨a,m,hr,hc⟩ := inst
  have h := Finset.le_sup (f := baseGates m) (Finset.mem_range.mpr hr.2)
  simpa [baseGates,hr,hc,gateCap] using h

/-- Remove the finite small-width exceptions to the asymptotic circuit bound,
uniformly in both the modulus and the legal base. -/
theorem allWidths : ∃ C : ℕ, ∀ m, gateCap m ≤ C*(m.log2+1)^3 := by
  classical
  obtain ⟨c,n₀,hc,asymptotic⟩ := programGateCount
  let small := (Finset.range (2^n₀)).sup gateCap
  let C := max ⌈c⌉₊ small
  refine ⟨C, fun m => ?_⟩
  by_cases h : n₀ ≤ m.log2+1
  · apply Finset.sup_le
    intro a ha
    unfold baseGates
    split
    next valid =>
      let inst : ShorOrderFindingInstance := ⟨a,m,valid.1,valid.2⟩
      have hm : m≠0 := by have := valid.1; omega
      have hg := asymptotic inst (by change n₀ ≤ (2*m).log2; rwa [Nat.log2_two_mul hm])
      change (_ : ℝ) ≤ c*((2*m).log2:ℝ)^3 at hg
      rw [Nat.log2_two_mul hm] at hg
      have ub : c ≤ (C:ℝ) := (Nat.le_ceil c).trans (by exact_mod_cast Nat.le_max_left ⌈c⌉₊ small)
      exact_mod_cast hg.trans (mul_le_mul_of_nonneg_right ub (by positivity))
    next => exact Nat.zero_le _
  · have hm : m < 2^n₀ := by
      by_cases hz : m = 0
      · simp [hz]
      · exact (Nat.log2_lt hz).mp (by omega)
    have hs : gateCap m ≤ small := Finset.le_sup (Finset.mem_range.mpr hm)
    exact hs.trans ((Nat.le_max_right _ _).trans (Nat.le_mul_of_pos_right C (by positivity)))

/-- Sum a node charge along this exact certified splitting tree, including
prime leaves and composite leaves whose attempts are exhausted. -/
def treeCharge (split : (m : ℕ) → Option (Divisor m)) (charge : ℕ → ℕ) (m : ℕ) : ℕ :=
  if m<2 then 0 else match split m with
  | none => charge m
  | some d => charge m + treeCharge split charge d.val + treeCharge split charge d.other
termination_by m
decreasing_by
  · exact d.smaller
  · exact d.pair.2.2

theorem treeCharge_le (N cap : ℕ) (split : (m : ℕ) → Option (Divisor m)) (charge : ℕ → ℕ)
    (h : ∀ m ≤ N, 2 ≤ m → charge m ≤ cap) (m : ℕ) (hm : m ≤ N) :
    treeCharge split charge m ≤ (factor split m).visits * cap := by
  induction m using Nat.strong_induction_on with
  | h m ih =>
    rw [treeCharge, factor]
    split
    · simp
    · next big =>
      cases hs : split m with
      | none => simpa using h m hm (by omega)
      | some d =>
        have q := h m hm (by omega)
        have hl := ih _ d.smaller (d.smaller.le.trans hm)
        have hr := ih _ d.pair.2.2 (d.pair.2.2.le.trans hm)
        change _ ≤ ((_+_)+1)*cap
        simp only [Nat.add_mul,one_mul]
        omega

private theorem log_mono {m N : ℕ} (h : m ≤ N) : m.log2 ≤ N.log2 := by
  simpa only [Nat.log2_eq_log_two] using Nat.log_mono_right (b := 2) h

/-- Total legal logical gates for all actually visited subproblems and all
candidate sampled bases. This pads each visited node to a complete batch,
including nonunit bases and classical preprocessing branches that need no gates. -/
noncomputable def quantumCharge (N : ℕ) (t : Tape N) :=
  treeCharge (readTape N t) (fun m => shots N * gateCap m) N

theorem totalQuantumGates : ∃ C : ℕ, ∀ N (t : Tape N),
    quantumCharge N t ≤ C*(N.log2+1)^6 := by
  obtain ⟨c,hc⟩ := allWidths
  refine ⟨768*c, fun N t => ?_⟩
  let b := N.log2+1
  have ub : ∀ m ≤ N, 2≤m → shots N * gateCap m ≤ shots N * (c*b^3) := by
    intro m hm _
    exact Nat.mul_le_mul_left _ ((hc m).trans (by dsimp [b]; gcongr; exact log_mono hm))
  have q := treeCharge_le N _ (readTape N t) _ ub N le_rfl
  change treeCharge _ _ _ ≤ _
  apply q.trans ((Nat.mul_le_mul_right _ (visit_bound _ _)).trans ?_)
  dsimp [shots,denominator,b]
  ring_nf
  omega

def clockSize (m : ℕ) := 2^(2*m^2).log2

private theorem wordFits (m : ℕ) (w : Fin (FactoringLaw.words m)) : w.val<2^(m.log2+1) :=
  w.isLt.trans_le (Nat.pow_le_pow_right (by decide) (Nat.add_le_add_right (log_mono (Nat.sub_le m 1)) 1))

private theorem clockFits (m : ℕ) (hm : 2≤m) : clockSize m < 2^(2*(m.log2+1)+2) := by
  let b := m.log2+1
  have h : m < 2^b := Nat.lt_log2_self
  have sq := Nat.pow_lt_pow_left h (by decide : 2 ≠ 0)
  change 2^(2*m^2).log2 < 2^(2*b+2)
  apply (Nat.log2_self_le (by positivity : 2*m^2≠0)).trans_lt
  rw [show 2*b+2=b*2+2 by omega,pow_add,pow_mul]
  nlinarith

/-- Maximum count of the executable Boolean circuit over possible fair words
and measured clock outputs, with correct widths for the physical circuit. -/
def classicalCap (m : ℕ) :=
  Finset.univ.sup fun w : Fin (FactoringLaw.words m) =>
    Finset.univ.sup fun o : Fin (clockSize m) => (FactoringBitCost.bitTrial m w o (clockSize m)).2

theorem recordCost (m : ℕ) (w : Fin (FactoringLaw.words m)) (o : Fin (clockSize m)) :
    (FactoringBitCost.bitTrial m w o (clockSize m)).2 ≤ classicalCap m :=
  (Finset.le_sup (f := fun o : Fin (clockSize m) => (FactoringBitCost.bitTrial m w o (clockSize m)).2)
    (Finset.mem_univ o)).trans (Finset.le_sup (f := fun w : Fin (FactoringLaw.words m) =>
      Finset.univ.sup fun o : Fin (clockSize m) => (FactoringBitCost.bitTrial m w o (clockSize m)).2)
      (Finset.mem_univ w))

theorem classicalCap_le (m : ℕ) (hm : 2≤m) : classicalCap m ≤ 1000000*(m.log2+2)^6 := by
  apply Finset.sup_le
  intro w _
  apply Finset.sup_le
  intro o _
  exact (FactoringBitCost.bitTrial_spec _ _ _ _ hm (wordFits m w) o.isLt (clockFits m hm)).2

/-- The base-specific unit branch of the bit program reads the same physical
clock record as the factoring probability proof, and returns its checked split. -/
theorem measuredRecord (inst : ShorOrderFindingInstance)
    (pre : (FactoringReduction.preprocess inst.N).1 = none)
    (o : Fin (ASize (program inst).output)) :
    (FactoringBitCost.bitTrial inst.N (inst.a-1) o (ASize (program inst).output)).1 =
      (certify inst.N (FactoringLaw.measuredFactor inst o)).map fun d => (d.val,d.other) := by
  have hr := inst.range
  have m : 2≤ inst.N := by omega
  have small : inst.a-1<2^(inst.N.log2+1) := (by omega : inst.a-1≤ inst.N).trans_lt Nat.lt_log2_self
  have size : ASize (program inst).output < 2^(2*(inst.N.log2+1)+2) := by
    rw [VerifiedOrderFinding.physicalClock]; exact clockFits _ m
  rw [(FactoringBitCost.bitTrial_spec _ _ _ _ m small o.isLt size).1]
  simp [FactoringBitCost.raw,pre,FactoringReduction.baseFromBits,show inst.a-1< inst.N-1 by omega,
    show inst.a-1+1=inst.a by omega,FactoringLaw.measuredFactor]

/-- For a nonunit positive base all possible measurement fields produce the
same certified gcd and cofactor used by the classical branch of baseLaw. -/
theorem nonunitRecord (m : ℕ) (hm : 2≤m) (x : Fin (m-1)) (nonunit : ¬(x.val+1).Coprime m)
    (pre : (FactoringReduction.preprocess m).1 = none) (o : Fin (clockSize m)) :
    (FactoringBitCost.bitTrial m x.val o (clockSize m)).1 =
      (certify m (some ((x.val+1).gcd m))).map fun d => (d.val,d.other) := by
  have small := x.isLt
  have hx : x.val<2^(m.log2+1) := (by omega : x.val≤m).trans_lt Nat.lt_log2_self
  rw [(FactoringBitCost.bitTrial_spec _ _ _ _ hm hx o.isLt (clockFits m hm)).1]
  simp only [FactoringBitCost.raw, pre, FactoringReduction.baseFromBits, dite_eq_left small]
  rw [FactoringReduction.extractFactor_nonunit (Nat.succ_pos _) (by omega) nonunit]

theorem rejectedRecord (m : ℕ) (hm : 2≤m) (w : Fin (FactoringLaw.words m))
    (rejected : m-1≤w.val) (pre : (FactoringReduction.preprocess m).1=none) (o : Fin (clockSize m)) :
    (FactoringBitCost.bitTrial m w o (clockSize m)).1 = none := by
  rw [(FactoringBitCost.bitTrial_spec _ _ _ _ hm (wordFits m w) o.isLt (clockFits m hm)).1]
  simp [FactoringBitCost.raw,pre,FactoringReduction.baseFromBits,not_lt.mpr rejected,certify]

theorem preprocessedRecord (m d : ℕ) (hm : 2≤m) (pre : (FactoringReduction.preprocess m).1=some d)
    (w : Fin (FactoringLaw.words m)) (o : Fin (clockSize m)) :
    (FactoringBitCost.bitTrial m w o (clockSize m)).1 = some (d,m/d) := by
  rw [(FactoringBitCost.bitTrial_spec _ _ _ _ hm (wordFits m w) o.isLt (clockFits m hm)).1]
  simp [FactoringBitCost.raw,pre,certify,FactoringReduction.preprocess_sound pre,Divisor.other]

/-- Worst-case data-path work of the same batches on the adaptively visited
nodes, including certification and exact division for both child subproblems. -/
def classicalCharge (N : ℕ) (t : Tape N) :=
  treeCharge (readTape N t) (fun m => shots N * classicalCap m) N

/-- At most log₂(m−1)+1 unbiased random bits form the fair word in each trial
at m. The pad also covers branches which terminate before drawing any bits. -/
def randomCharge (N : ℕ) (t : Tape N) :=
  treeCharge (readTape N t) (fun m => shots N * ((m-1).log2+1)) N

theorem totalClassicalBits (N : ℕ) (t : Tape N) : classicalCharge N t ≤ 768000000*(N.log2+2)^9 := by
  let b := N.log2+2
  have ub : ∀ m ≤ N, 2≤m → shots N * classicalCap m ≤ shots N*(1000000*b^6) := by
    intro m hm h
    exact Nat.mul_le_mul_left _ ((classicalCap_le m h).trans (by dsimp [b];gcongr; exact log_mono hm))
  have z := treeCharge_le N _ (readTape N t) _ ub N le_rfl
  apply z.trans ((Nat.mul_le_mul_right _ (visit_bound _ _)).trans ?_)
  dsimp [shots,denominator,b]
  ring_nf
  omega

theorem totalFairBits (N : ℕ) (t : Tape N) : randomCharge N t ≤ 768*(N.log2+1)^4 := by
  have ub : ∀ m ≤ N, 2≤m → shots N * ((m-1).log2+1) ≤ shots N*(N.log2+1) := by
    intro m hm _
    apply Nat.mul_le_mul_left
    exact Nat.add_le_add_right (log_mono ((Nat.sub_le m 1).trans hm)) _
  have z := treeCharge_le N _ (readTape N t) _ ub N le_rfl
  apply z.trans ((Nat.mul_le_mul_right _ (visit_bound _ _)).trans ?_)
  dsimp [shots,denominator]
  ring_nf
  omega

/-- Binary length of a factor list written in a fixed public width, one end-of-list
tag per entry and one final terminator. This charges even a copy of both
sides of an append. -/
def outputBits (width : ℕ) (ds : List ℕ) := (width+1)*ds.length+1

theorem leavesFit (split : (m : ℕ) → Option (Divisor m)) (m : ℕ) (hm : 2≤m) :
    (factor split m).factors.length ≤ m.log2 ∧
    ∀ d ∈ (factor split m).factors, d < 2^(m.log2+1) := by
  obtain ⟨hp,_,hc⟩ := factor_tree split m hm
  have visits := visit_bound split m
  refine ⟨by omega, fun d hd => ?_⟩
  have hdiv : d ∣ (factor split m).factors.prod := List.dvd_prod hd
  rw [hp] at hdiv
  exact (Nat.le_of_dvd (by omega) hdiv).trans_lt Nat.lt_log2_self

/-- Worst-case number of bit writes if the complete list is materialized at
each recursive return, using the original input width throughout. -/
def outputCharge (N : ℕ) (t : Tape N) :=
  treeCharge (readTape N t) (fun m => outputBits (N.log2+1) (factor (readTape N t) m).factors) N

theorem totalOutputBits (N : ℕ) (t : Tape N) : outputCharge N t ≤ 2*(N.log2+2)^3 := by
  have ub : ∀ m ≤ N, 2≤m →
      outputBits (N.log2+1) (factor (readTape N t) m).factors ≤ (N.log2+2)^2 := by
    intro m hm h
    have z := (leavesFit (readTape N t) m h).1.trans (log_mono hm)
    unfold outputBits
    calc
      _ ≤ (N.log2+1+1)*N.log2+1 := by gcongr
      _ ≤ _ := by ring_nf; omega
  have z := treeCharge_le N _ (readTape N t) _ ub N le_rfl
  apply z.trans ((Nat.mul_le_mul_right _ (visit_bound _ _)).trans ?_)
  ring_nf
  omega

local instance : MeasurableSpace (Option ℕ) := ⊤
local instance : DiscreteMeasurableSpace (Option ℕ) := ⟨fun _ => trivial⟩

/-- Prime factorization in the adaptive logical-circuit model, for every
positive input and every width. The four deterministic budgets are worst-case
bounds. The probability uses the very same physical Fourier-clock circuit,
fair-base law and recursive reports. Gate-array generation is outside these
execution counts. -/
theorem factoringPolynomialResources : ∃ C : ℕ, ∀ N, 1≤N →
    (∀ t : Tape N, (run N t).factors.prod = N ∧
      quantumCharge N t ≤ C*(N.log2+1)^6 ∧
      classicalCharge N t ≤ 768000000*(N.log2+2)^9 ∧
      randomCharge N t ≤ 768*(N.log2+1)^4 ∧
      outputCharge N t ≤ 2*(N.log2+2)^3) ∧
    (2/3 : ℝ) ≤ (tapeLaw N FactoringLaw.law).real
      {t | (run N t).factors.prod = N ∧ ∀ d ∈ (run N t).factors, Nat.Prime d} := by
  obtain ⟨C,gates⟩ := totalQuantumGates
  refine ⟨C, fun N hN => ?_⟩
  obtain ⟨sound,probability⟩ := FactoringLaw.primeFactorization N hN
  exact ⟨fun t => ⟨(sound t).1, gates N t, totalClassicalBits N t, totalFairBits N t,
    totalOutputBits N t⟩, probability⟩

end FQChem.Complexity.FactoringResources
