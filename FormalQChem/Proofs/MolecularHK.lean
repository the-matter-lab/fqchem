module

public import FormalQChem.Theorems.MolecularHK
import FormalQChem.Proofs.DFT
import Mathlib.Tactic

public section
namespace FormalQChem.MolecularHK

open MeasureTheory MeasureTheory.Measure FormalQChem.MolecularDFT

theorem oneBodyRigidity (n : ℕ) : OneBodyRigidity n := by
  intro w c hc
  let e := MeasurableEquiv.piFinSuccAbove (fun _ : Fin (n + 1) => Position) 0
  have hpair : ∀ᵐ p : Position × Configuration n ∂volume.prod volume,
      w p.1 + ∑ j, w (p.2 j) = c := by
    have hp := (volume_preserving_piFinSuccAbove (fun _ : Fin (n + 1) => Position) 0).symm e
    have pull := hp.quasiMeasurePreserving.ae hc
    filter_upwards [pull] with p hp
    simpa only [oneBodyLift, e, MeasurableEquiv.piFinSuccAbove_symm_apply,
      Fin.insertNthEquiv, Fin.sum_univ_succ, Fin.insertNth_zero, Equiv.coe_fn_mk,
      Fin.cons_succ, Fin.zero_succAbove, cast_eq, Fin.cons_zero] using hp
  have hswap : ∀ᵐ p : Configuration n × Position ∂volume.prod volume,
      w p.2 + ∑ j, w (p.1 j) = c := measurePreserving_swap.quasiMeasurePreserving.ae hpair
  obtain ⟨tail, htail⟩ := (ae_ae_of_ae_prod hswap).exists
  refine ⟨c - ∑ j, w (tail j), ?_⟩
  filter_upwards [htail] with x hx
  exact eq_sub_of_add_eq hx

theorem molecularHohenbergKohn (n K J : ℕ) : MolecularHohenbergKohn n K J := by
  intro Z R Z' R' M ψ φ hsep hψ hφ hnorm hd hn
  have htest : DFT.dens M.setting ψ = DFT.dens M.setting φ := by
    funext p
    have hψi := M.setting.int_L p ψ ψ hψ.1 hψ.1
    have hφi := M.setting.int_L p φ φ hφ.1 hφ.1
    simp only [M.lift_eq] at hψi hφi
    simpa only [DFT.dens, DFT.pf, M.lift_eq] using hd _ hψi hφi
  have common := DFT.weak_hk hψ hφ hnorm htest
  obtain ⟨c, hconst⟩ := DFT.commonStateConstantLift hsep hψ common hn
  apply oneBodyRigidity n _ c
  filter_upwards [hconst] with q hq
  simpa [M.lift_eq, sub_eq_add_neg] using hq

end FormalQChem.MolecularHK
