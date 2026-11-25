module

public import FQChemQatlib.Dynamics.LowChuangSparseSimulation

/-! # Sparse query and elementary-gate bounds at the unpadded physical time -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseAssembly

open Matrix Query SparseBlock SparseWires Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.Execution.WorkspaceCP
open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.BlockEncoding.Postselection.Encoding
open Qatlib.Papers.Qubitization19.MainResults
open Sparse (Access)
open scoped Classical Matrix.Norms.L2Operator

/-- Embed a logical row-slot number in the known low-address register. -/
def slotWires {n d : ℕ} (range : d≤2^n) : Fin (Nat.clog 2 d) ↪ Fin n :=
  ⟨Fin.castLE (Nat.clog_le_of_le_pow range),fun _ _ eq => Fin.ext (congrArg (fun x : Fin n => x.val) eq)⟩

def numberedSlot {n d : ℕ} (range : d≤2^n) (i : Fin d) : Reg n :=
  slotAddress (slotWires range) ((bitVecEquiv _).symm (Fin.castLE (Nat.le_pow_clog (by decide) d) i))

private theorem time_scale {d : ℕ} (hd : 0<d) {b c t : ℝ} (hb : 0<b) (hc : 0<c) (tight : b≤2*c) :
    |t*(2*2^(Nat.clog 2 d)*b)| ≤ (8:ℕ)*|t*(d*c)| := by
  have sup : (2:ℝ)^Nat.clog 2 d ≤ 2*d := by exact_mod_cast (padded_slot_bound hd).2.le
  rw [abs_mul t (2*2^Nat.clog 2 d*b),abs_mul t ((d:ℝ)*c),abs_of_nonneg (by positivity : 0≤2*(2:ℝ)^Nat.clog 2 d*b),
    abs_of_nonneg (by positivity : 0≤ (d:ℝ)*c)]
  norm_num
  calc
    _ ≤ |t| * (2*(2*d)*(2*c)) :=
      mul_le_mul_of_nonneg_left (mul_le_mul (mul_le_mul_of_nonneg_left sup (by norm_num)) tight hb.le (by positivity)) (abs_nonneg t)
    _ = _ := by ring

private theorem budget {n k p q Q : ℕ} (kn : k≤n) (pos : 0<Q) (cut : q≤20*Q) :
    250*(n+Binary.size p+4)*(27*(64*q+8)-2) +
      (2*k+415440*(n+(190*p+4)))*(27*(64*q+1)) ≤
      10000000000000*(n+p+1)*Q := by
  have len : Binary.size p=5*p+3 := by simp [Binary.size,Binary.Key]; omega
  rw [len]
  have a : 250*(n+(5*p+3)+4)≤1750*(n+p+1) := by omega
  have b : 2*k+415440*(n+(190*p+4))≤78933600*(n+p+1) := by nlinarith only [kn]
  have c : 27*(64*q+8)-2 ≤ 34776*Q := by omega
  have d : 27*(64*q+1) ≤ 34587*Q := by omega
  calc
    _ ≤ _ := Nat.add_le_add (Nat.mul_le_mul a c) (Nat.mul_le_mul b d)
    _ = (1750 * 34776 + 78933600 * 34587) * (n+p+1) * Q := by ring
    _ ≤ _ := Nat.mul_le_mul_right _ (Nat.mul_le_mul_right _ (by decide))

/-- The unpadded, unnormalized time is |t|·d·c. Choose the publicly known
coordinate unit b within a factor of two of the desired entry scale c,
for example the next binary power above the maximum norm. Slots 0,...,d-1
are explicitly addressed, including non-power-of-two d. The fixed circuit
uses at most 69,174 Q calls of each kind and O((n+p)Q) one- or two-qubit
gates, and has spectral error ≤ ε²/2 and success ≥ 1−ε². -/
theorem sparseResourceBound {n d : ℕ} (wire : Fin n) (hd : 0<d) (range : d≤2^n)
    (p : ℕ) (b c t ε : ℝ) (hb : 0<b) (hc : 0<c) (tight : b≤2*c) (he : 0<ε) (small : ε<1) :
    ∃ Q : ℕ, IsPaperCutoffQ (t*(d*c)) ε Q ∧
    ∃ program : List (Step (System n (Binary.size p)) Access),
      cost Access.position program ≤ 69174*Q ∧ cost Access.entry program ≤ 69174*Q ∧
      fixedCount program ≤ 10000000000000*(n+p+1)*Q ∧
      (∀ M,.fixed M∈program → Allowed n (Binary.size p) M) ∧
      ∀ (H : Matrix (Reg n) _ ℂ) (pos : Reg n → Equiv.Perm (Reg n)) (re im : Reg n→Reg n→Reg p),
      H.IsHermitian → (∀ i j, H i j≠0 → ∃ u : Fin d, (pos i).symm j=numberedSlot range u) →
      (∀ i j, Binary.signedValue (re i j) + Complex.I*Binary.signedValue (im i j) = (b⁻¹:ℝ) • H i j) →
      let F := encodingFiber (I:=Reg n) (blank (n+Binary.size p))
      let R := hamiltonianFrame F
      let M := run (sparseInputs pos (table re im)) program
      ‖compress R M R-hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
      ∀ ψ : QState (Reg n), Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ := by
  obtain ⟨Q,Qspec⟩ := leastCutoff (t*(d*c)) ε he
  obtain ⟨q,qspec,program,rowQ,entryQ,fixed,legal,sim⟩ :=
    elementarySparseSimulation (slotWires range) wire p b t ε hb he small
  have scale := cutoff_dilation (K:=20) (c:=8) Qspec qspec small.le (by decide) (time_scale hd hb hc tight) (by decide)
  have Qpos := Qspec.1
  refine ⟨Q,Qspec,program,?_,?_,fixed.trans (budget (Nat.clog_le_of_le_pow range) Qpos scale),legal,?_⟩
  · omega
  · omega
  intro H pos re im hH support entry
  apply sim H pos re im hH _ entry
  intro i j h
  obtain ⟨u,e⟩ := support i j h
  exact ⟨_,e⟩

end FQChemQatlib.Dynamics.LowChuang.SparseAssembly
