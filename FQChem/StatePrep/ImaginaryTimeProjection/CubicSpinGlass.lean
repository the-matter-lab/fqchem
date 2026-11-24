module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticComparison
public import FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassPaths
import Mathlib.Tactic

/-! # Three-dimensional nearest-neighbour sign-problem instances

The lattice counts each possible positive-direction neighbour once. Edges ending
outside the open box are omitted. The finite signed coupling table has one entry
per site and axis, allowing strengths 0 and ±1 as in Troyer and Wiese Eq. (10).
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
open MeasureTheory

abbrev Coord (a b c : ℕ) := Fin a × Fin b × Fin c

def siteIndex (a b c : ℕ) : Coord a b c ≃ Fin (a*(b*c)) :=
  ((Equiv.refl (Fin a)).prodCongr finProdFinEquiv).trans finProdFinEquiv

def forwardCoordinate {a : ℕ} (x : Fin a) : Fin a :=
  if h : x.val + 1 < a then ⟨x.val+1,h⟩ else x

/-- At the upper face a positive coordinate step stays put, and the self-edge is discarded. -/
def forward {a b c : ℕ} (x : Coord a b c) (d : Fin 3) : Coord a b c :=
  ![(forwardCoordinate x.1,x.2.1,x.2.2),(x.1,forwardCoordinate x.2.1,x.2.2),(x.1,x.2.1,forwardCoordinate x.2.2)] d

/-- Zero means that the bond is absent. The sign is stored by its unordered two-site mask,
so the finite input contains at most 3abc occupied bond positions. -/
def cubicGlass {a b c : ℕ} (enabled : Coord a b c → Fin 3 → Bool)
    (negative : Finset (Spin (a*(b*c)))) : Glass (a*(b*c)) :=
  let index := siteIndex a b c
  let active := (Finset.univ : Finset (Coord a b c × Fin 3)).filter
    (fun p => enabled p.1 p.2 ∧ p.1 ≠ forward p.1 p.2)
  let mask := fun p : Coord a b c × Fin 3 => pairMask (index p.1) (index (forward p.1 p.2))
  { bonds := active.image mask
    negative := fun e => decide (e ∈ negative)
    twoSite := by
      intro e he
      obtain ⟨p,hp,rfl⟩ := Finset.mem_image.mp he
      exact ⟨_,_,index.injective.ne (Finset.mem_filter.mp hp).2.2,rfl⟩ }

/-- Only three positive-axis slots are available per lattice site. -/
theorem cubicBondCount {a b c : ℕ} (on : Coord a b c → Fin 3 → Bool)
    (neg : Finset (Spin (a*(b*c)))) : (cubicGlass on neg).bonds.card ≤ 3*(a*(b*c)) := by
  refine Finset.card_image_le.trans (Finset.card_filter_le .. |>.trans ?_)
  simp [Coord, Nat.mul_comm, Nat.mul_assoc]

/-- The signed energy solver decides the cubic-lattice threshold, while the same
temperature and precision for its associated sign-free model are attained by simply
returning the negative occupied-bond count. -/
theorem cubicDecision {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {a b c : ℕ} (on : Coord a b c → Fin 3 → Bool) (neg : Finset (Spin (a*(b*c))))
    (sites : 0 < a*(b*c)) (t : ℤ) (estimate : Ω → ℝ) :
    let n := a*(b*c)
    let g := cubicGlass on neg
    Integrable (fun x => (estimate x-g.quantumThermal (13*n))^2) μ →
    (∫ x, (estimate x-g.quantumThermal (13*n))^2 ∂μ) ≤ (|g.quantumThermal (13*n)|/(24*n))^2 →
      μ.real {x | ¬ ((estimate x < (t:ℝ)+3/4) ↔ feasible g t)} ≤ 1/4 ∧
      |-(g.bonds.card : ℝ)-g.ferro.quantumThermal (13*n)| ≤ |g.ferro.quantumThermal (13*n)|/(24*n) := by
  intro n g hi he
  exact ⟨statisticalDecision μ g sites (cubicBondCount on neg) t estimate hi he,
    bosonicDecisionEstimate g sites⟩

end FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
