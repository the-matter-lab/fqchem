module

public import FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassLatticeEncoding
import Mathlib.Tactic

/-! # A negative expansion weight on the hardness instances

Following the six rim bonds of any one clause flips each of its six lattice sites
twice. The path returns to its starting spin configuration; three couplings are
negative, so its signed expansion weight is −1.
-/

@[expose] public section
namespace FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT.Lattice
open IsingSign

def walk {N} (s : Spin N) : List (Spin N) → List (Spin N)
  | [] => []
  | e::es => let t := exchange s e; t :: walk t es

private theorem walkEnd {N} (s : Spin N) (es : List (Spin N)) :
    (s :: walk s es).getLast? = some (es.foldl exchange s) := by
  induction es generalizing s with
  | nil => rfl
  | cons e es ih => simpa [walk] using ih (exchange s e)

private theorem walkWeight {N} (g : Glass N) (s : Spin N) (es : List (Spin N)) :
    pathWeight g s (walk s es) = (es.map (fun e => (g.coupling e:ℝ))).prod := by
  induction es generalizing s with
  | nil => simp [walk, pathWeight]
  | cons e es ih =>
    have cancel : exchange s (exchange s e) = e := by funext i; simp [exchange]
    simp [walk, pathWeight, Glass.hamiltonian, cancel, ih]

private theorem pairParity {N} (a b i : Fin N) (h : a ≠ b) :
    pairMask a b i = (decide (i=a) ^^ decide (i=b)) := by
  by_cases ha : i=a <;> by_cases hb : i=b <;> simp_all [pairMask]

private theorem sixParity : ∀ a b c d e f : Bool,
    ((((((false ^^ (a ^^ b)) ^^ (b ^^ c)) ^^ (c ^^ d)) ^^ (e ^^ d)) ^^ (f ^^ e)) ^^ (a ^^ f)) = false := by
  decide

private theorem rimCloses {n m} (f : Formula n m) (c : Fin m) :
    (List.ofFn (fun i : Fin 6 => bondMask f (.inr (c,i)))).foldl exchange (aligned _) = aligned _ := by
  funext j
  have bit (i : Fin 6) : bondMask f (.inr (c,i)) j =
      (decide (j=siteIndex _ _ _ (asGrid _ (bounds f (.inr (c,i))).1)) ^^
       decide (j=siteIndex _ _ _ (asGrid _ (bounds f (.inr (c,i))).2))) := by
    apply pairParity
    intro h
    have he := congrArg asSite ((siteIndex _ _ _).injective h)
    change (rimPosition c i).start = (rimPosition c i).finish at he
    fin_cases i <;> simp [rimPosition, Position.finish] at he
  simp only [List.ofFn_succ, List.ofFn_zero, List.foldl_cons, List.foldl_nil, exchange, aligned, bit]
  exact sixParity ..

/-- Each nonempty compiled NAE formula has a closed negative path in the signed
model and the same path of positive unit weight in the associated ferromagnet. -/
theorem frustratedInstance {n m} (f : Formula n m) (c : Fin m) :
    ∃ p : List (Spin (size n m)), p.length = 6 ∧ (aligned _ :: p).getLast? = some (aligned _) ∧
      pathWeight (model f) (aligned _) p = -1 ∧ pathWeight (model f).ferro (aligned _) p = 1 := by
  let es := List.ofFn (fun i : Fin 6 => bondMask f (.inr (c,i)))
  refine ⟨walk (aligned _) es, by simp [es, List.ofFn_succ, walk], ?_, ?_⟩
  · rw [walkEnd, rimCloses]
  · have signed : pathWeight (model f) (aligned _) (walk (aligned _) es) = -1 := by
      rw [walkWeight]
      simp [es, List.ofFn_succ, signedCoupling, sign, rimNegative]
    exact ⟨signed, by rw [absolute_path, signed]; norm_num⟩

end FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSAT.Lattice
