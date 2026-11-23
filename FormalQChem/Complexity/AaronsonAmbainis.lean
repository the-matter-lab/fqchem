module

public import FormalQChem.Complexity.AaronsonAmbainisOrbitals
public import AaronsonAmbainisPort.Main
import Mathlib.Tactic

/-!
# Influential oracle inputs in orbital-population measurements

The unconditional [Aaronson–Ambainis proof by David Turturean](https://github.com/physical-superintelligence/aaronson-ambainis/tree/2a6ceaef872ae993708950f951989134084b851a)
is applied to the actual Born probability polynomial of a finite query circuit.
Variance and influence refer to independent, uniform Boolean inputs and to
flipping one encoded input bit. In the orbital model the bits select diagonal
potential pulses, each evolving the one-electron state for one unit of time.

* [Aaronson & Ambainis, The Need for Structure in Quantum Speedups](https://doi.org/10.4086/toc.2014.v010a006)
* [Beals et al., Quantum Lower Bounds by Polynomials](https://arxiv.org/abs/quant-ph/9802049)
-/

@[expose] public section
noncomputable section

namespace FormalQChem.Complexity.PhaseQuery

variable {N t : ℕ} {B : Type*} [Fintype B] [DecidableEq B]

def cubeMean (f : Bits N → ℝ) : ℝ := (∑ x, f x) / 2^N

def cubeVariance (f : Bits N → ℝ) : ℝ := cubeMean (fun x ↦ (f x - cubeMean f)^2)

def influence (f : Bits N → ℝ) (i : Fin N) : ℝ :=
  cubeMean (fun x ↦ (f x - f (Function.update x i (!(x i))))^2)

/-- A variable with large mean squared flip effect exists whenever the circuit's
measured probability varies across the uniform Boolean input ensemble. -/
theorem acceptance_influential (c : Circuit N B t) (accept : Finset B) {ε : ℝ}
    (hε : 0 < ε) (var : ε ≤ cubeVariance (acceptance c accept)) :
    ∃ i, (ε / (2*t : ℕ))^7 ≤ influence (acceptance c accept) i := by
  let p := acceptancePolynomial c accept
  have he (x : Bits N) :
      MvPolynomial.eval (fun k ↦ if x k then (1 : ℝ) else 0) p = acceptance c accept x :=
    acceptancePolynomial_eval c accept x
  have hd := acceptancePolynomial_degree c accept
  have hb (x : Bits N) := acceptance_mem_unitInterval c accept x
  obtain ⟨i, hi⟩ := AaronsonAmbainis.aaronson_ambainis N (2*t) p hd
    (fun x ↦ by simpa only [he] using hb x) ε hε (by simpa only [he, cubeVariance, cubeMean] using var)
  exact ⟨i, by simpa only [he, influence, cubeMean] using hi⟩

/-- Apply the upstream explicit-constant theorem to physical orbital populations after
`t` binary onsite Hamiltonian pulses interspersed with fixed orbital transformations. -/
theorem orbitalPopulation_influential (c : Circuit N B t) (orbitals : Finset B) {ε : ℝ}
    (hε : 0 < ε) (var : ε ≤ cubeVariance (orbitalPopulation c orbitals)) :
    ∃ i, 8 * Real.sqrt 15 / (125 * Real.pi^4) * ε^((5 : ℝ)/2) / ((2*t : ℕ) : ℝ)^6 ≤
      influence (orbitalPopulation c orbitals) i := by
  let p := acceptancePolynomial c orbitals
  have he (x : Bits N) :
      MvPolynomial.eval (fun k ↦ if x k then (1 : ℝ) else 0) p = orbitalPopulation c orbitals x :=
    (acceptancePolynomial_eval c orbitals x).trans (orbitalPopulation_eq c orbitals x).symm
  have hd := acceptancePolynomial_degree c orbitals
  have hb (x : Bits N) : 0 ≤ orbitalPopulation c orbitals x ∧ orbitalPopulation c orbitals x ≤ 1 := by
    rw [orbitalPopulation_eq]
    exact acceptance_mem_unitInterval c orbitals x
  obtain ⟨i, hi⟩ := AaronsonAmbainis.aaronson_ambainis_explicit N (2*t) p hd
    (fun x ↦ by simpa only [he] using hb x) ε hε (by simpa only [he, cubeVariance, cubeMean] using var)
  exact ⟨i, by simpa only [he, influence, cubeMean] using hi⟩

private theorem mean_oneBit (f : Bits 1 → ℝ) :
    cubeMean f = (f (fun _ ↦ true) + f (fun _ ↦ false))/2 := by
  unfold cubeMean
  rw [← (Equiv.funUnique (Fin 1) Bool).symm.sum_comp]
  have hc (v : Bool) : (uniqueElim v : Bits 1) = fun _ ↦ v := funext (uniqueElim_const v)
  simp [hc, add_comm]

theorem antibondingVariance : cubeVariance (orbitalPopulation twoOrbitalProbe {true}) = 1 / 4 := by
  simp only [cubeVariance, mean_oneBit, antibondingPopulation]
  norm_num

theorem antibondingInfluence : influence (orbitalPopulation twoOrbitalProbe {true}) 0 = 1 := by
  simp only [influence, mean_oneBit, antibondingPopulation, Function.update_self]
  norm_num

/-- The two-orbital interference calculation supplies the positive-variance
hypothesis of the explicit influence theorem at ε = 1/4. -/
theorem antibonding_influential :
    ∃ i, 8 * Real.sqrt 15 / (125 * Real.pi^4) * (1/4 : ℝ)^((5 : ℝ)/2) / 2^6 ≤
      influence (orbitalPopulation twoOrbitalProbe {true}) i := by
  simpa using orbitalPopulation_influential twoOrbitalProbe {true} (ε := (1/4 : ℝ))
    (by norm_num) antibondingVariance.ge

end FormalQChem.Complexity.PhaseQuery
