# fqchem theorem graph

1365 source theorems and lemmas · 0 shared library prerequisites · 30 upstream theorem nodes · 1938 dependency edges.

Arrows point from prerequisite to result. Dashed arrows pass through local definitions or compiler-generated helpers. Each diagram includes the prerequisites used by its module. The links below each diagram open the Lean declarations.

[Graph guide and interactive explorer](README.md)

## FQChem.Complexity.AaronsonAmbainis

```mermaid
flowchart LR
  n0["Main.aaronson_ambainis"]
  n1["Main.aaronson_ambainis_explicit"]
  n2["acceptance_influential"]
  n3["antibondingInfluence"]
  n4["antibondingVariance"]
  n5["antibonding_influential"]
  n6["mean_oneBit"]
  n7["orbitalPopulation_influential"]
  n8["AaronsonAmbainisOrbitals.antibondingPopulation"]
  n9["AaronsonAmbainisOrbitals.bondingNormalized"]
  n10["AaronsonAmbainisOrbitals.bondingReadout_unitary"]
  n15["AaronsonAmbainisOrbitals.orbitalPopulation_eq"]
  n16["AaronsonAmbainisQuery.acceptancePolynomial_degree"]
  n17["AaronsonAmbainisQuery.acceptancePolynomial_eval"]
  n18["AaronsonAmbainisQuery.acceptance_mem_unitInterval"]
  n0 --> n2
  n16 --> n2
  n17 --> n2
  n18 --> n2
  n6 --> n3
  n8 --> n3
  n9 -.-> n3
  n10 -.-> n3
  n6 --> n4
  n8 --> n4
  n9 -.-> n4
  n10 -.-> n4
  n4 --> n5
  n7 --> n5
  n9 -.-> n5
  n10 -.-> n5
  n1 --> n7
  n15 --> n7
  n16 --> n7
  n17 --> n7
  n18 --> n7
```

- [Main.aaronson_ambainis](https://github.com/physical-superintelligence/aaronson-ambainis/blob/2a6ceaef872ae993708950f951989134084b851a/AaronsonAmbainis/Main.lean#L33)
- [Main.aaronson_ambainis_explicit](https://github.com/physical-superintelligence/aaronson-ambainis/blob/2a6ceaef872ae993708950f951989134084b851a/AaronsonAmbainis/Main.lean#L38)
- [acceptance_influential](../../FQChem/Complexity/AaronsonAmbainis.lean#L36)
- [antibondingInfluence](../../FQChem/Complexity/AaronsonAmbainis.lean#L78)
- [antibondingVariance](../../FQChem/Complexity/AaronsonAmbainis.lean#L74)
- [antibonding_influential](../../FQChem/Complexity/AaronsonAmbainis.lean#L84)
- [mean_oneBit](../../FQChem/Complexity/AaronsonAmbainis.lean#L67) (private)
- [orbitalPopulation_influential](../../FQChem/Complexity/AaronsonAmbainis.lean#L51)
- [AaronsonAmbainisOrbitals.antibondingPopulation](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L106)
- [AaronsonAmbainisOrbitals.bondingNormalized](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L86)
- [AaronsonAmbainisOrbitals.bondingReadout_unitary](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L93)
- [AaronsonAmbainisOrbitals.orbitalPopulation_eq](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L74)
- [AaronsonAmbainisQuery.acceptancePolynomial_degree](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L180)
- [AaronsonAmbainisQuery.acceptancePolynomial_eval](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L171)
- [AaronsonAmbainisQuery.acceptance_mem_unitInterval](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L188)

## FQChem.Complexity.AaronsonAmbainisOrbitals

```mermaid
flowchart LR
  n8["antibondingPopulation"]
  n9["bondingNormalized"]
  n10["bondingReadout_unitary"]
  n11["halfAmplitude_sq"]
  n12["onsiteHamiltonian_isHermitian"]
  n13["onsite_evolution"]
  n14["orbitalEvolution_eq"]
  n15["orbitalPopulation_eq"]
  n9 --> n8
  n10 --> n8
  n11 --> n8
  n15 --> n8
  n11 --> n9
  n11 --> n10
  n13 --> n14
  n14 --> n15
```

- [antibondingPopulation](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L106)
- [bondingNormalized](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L86)
- [bondingReadout_unitary](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L93)
- [halfAmplitude_sq](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L80) (private)
- [onsiteHamiltonian_isHermitian](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L37)
- [onsite_evolution](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L42)
- [orbitalEvolution_eq](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L61)
- [orbitalPopulation_eq](../../FQChem/Complexity/AaronsonAmbainisOrbitals.lean#L74)

## FQChem.Complexity.AaronsonAmbainisQuery

```mermaid
flowchart LR
  n16["acceptancePolynomial_degree"]
  n17["acceptancePolynomial_eval"]
  n18["acceptance_mem_unitInterval"]
  n19["amplitudePolynomials"]
  n20["amplitudes_degree"]
  n21["amplitudes_normalized"]
  n22["amplitudes_value"]
  n23["mix_degree"]
  n24["mix_value"]
  n25["phaseScale_degree"]
  n26["phaseScale_value"]
  n27["phase_degree"]
  n28["phase_eval"]
  n29["sqnorm_eq"]
  n30["unitary_preserves"]
  n20 --> n16
  n22 --> n17
  n21 --> n18
  n20 --> n19
  n22 --> n19
  n23 --> n20
  n25 --> n20
  n30 --> n21
  n24 --> n22
  n26 --> n22
  n27 --> n25
  n28 --> n26
  n29 --> n30
```

- [acceptancePolynomial_degree](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L180)
- [acceptancePolynomial_eval](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L171)
- [acceptance_mem_unitInterval](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L188)
- [amplitudePolynomials](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L158)
- [amplitudes_degree](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L149) (private)
- [amplitudes_normalized](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L78)
- [amplitudes_value](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L142) (private)
- [mix_degree](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L128) (private)
- [mix_value](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L121) (private)
- [phaseScale_degree](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L109) (private)
- [phaseScale_value](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L104) (private)
- [phase_degree](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L46) (private)
- [phase_eval](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L40) (private)
- [sqnorm_eq](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L68) (private)
- [unitary_preserves](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L72) (private)

## FQChem.Complexity.BlockSimulationPrecision

```mermaid
flowchart LR
  n19["AaronsonAmbainisQuery.amplitudePolynomials"]
  n31["blockEncoding"]
  n32["parityCoefficient"]
  n33["precisionBarrier"]
  n34["worstCaseBlockCutoff"]
  n35["zeroCoefficient"]
  n276["OrbitalSimulation.parity_orthogonal"]
  n502["SparseSimulationPrecision.cutoffFromSignal"]
  n32 --> n33
  n35 --> n33
  n33 --> n34
  n502 --> n34
  n19 --> n35
  n276 --> n35
```

- [AaronsonAmbainisQuery.amplitudePolynomials](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L158)
- [blockEncoding](../../FQChem/Complexity/BlockSimulationPrecision.lean#L34)
- [parityCoefficient](../../FQChem/Complexity/BlockSimulationPrecision.lean#L59)
- [precisionBarrier](../../FQChem/Complexity/BlockSimulationPrecision.lean#L95)
- [worstCaseBlockCutoff](../../FQChem/Complexity/BlockSimulationPrecision.lean#L111)
- [zeroCoefficient](../../FQChem/Complexity/BlockSimulationPrecision.lean#L79) (private)
- [OrbitalSimulation.parity_orthogonal](../../FQChem/Complexity/OrbitalSimulation.lean#L35)
- [SparseSimulationPrecision.cutoffFromSignal](../../FQChem/Complexity/SparseSimulationPrecision.lean#L61)

## FQChem.Complexity.ElectronicStructure

```mermaid
flowchart LR
  n36["railMove_count"]
  n37["railMove_twice"]
  n38["defects_zero_iff"]
  n39["encodeState_energy"]
  n40["encodeState_mass"]
  n41["encode_legal"]
  n42["energyPromise_transfer"]
  n43["expectation_bound"]
  n44["expectation_scale"]
  n45["homogeneous_lower"]
  n46["interactionError"]
  n47["leakagePart_encodeState"]
  n48["leakagePenalty"]
  n49["leakage_expectation"]
  n50["lowerBound_transfer"]
  n51["mass_nonneg"]
  n52["mass_scale"]
  n53["mass_split"]
  n54["move_encode"]
  n55["phase_encode"]
  n56["physicalMove_legal"]
  n57["physicalPhase_norm"]
  n58["spinEnergy_scale"]
  n59["spinPart_encodeState"]
  n60["splitSum"]
  n36 -.-> n39
  n37 -.-> n39
  n38 --> n39
  n41 --> n39
  n46 --> n39
  n47 --> n39
  n59 --> n39
  n60 --> n39
  n41 -.-> n40
  n47 --> n40
  n53 --> n40
  n59 --> n40
  n36 -.-> n42
  n37 -.-> n42
  n39 --> n42
  n40 --> n42
  n41 -.-> n42
  n45 --> n42
  n50 --> n42
  n52 --> n45
  n58 --> n45
  n36 -.-> n46
  n37 -.-> n46
  n43 --> n46
  n49 --> n46
  n56 -.-> n46
  n57 --> n46
  n41 -.-> n47
  n38 --> n48
  n41 --> n48
  n60 --> n48
  n36 -.-> n49
  n37 -.-> n49
  n56 -.-> n49
  n60 --> n49
  n36 -.-> n50
  n37 -.-> n50
  n46 --> n50
  n48 --> n50
  n51 --> n50
  n53 --> n50
  n60 --> n53
  n36 -.-> n54
  n37 -.-> n54
  n36 -.-> n56
  n37 -.-> n56
  n44 --> n58
  n41 -.-> n59
  n41 -.-> n60
```

- [railMove_count](../../FQChem/Complexity/ElectronicStructure.lean#L110)
- [railMove_twice](../../FQChem/Complexity/ElectronicStructure.lean#L104)
- [defects_zero_iff](../../FQChem/Complexity/ElectronicStructure.lean#L81)
- [encodeState_energy](../../FQChem/Complexity/ElectronicStructure.lean#L251)
- [encodeState_mass](../../FQChem/Complexity/ElectronicStructure.lean#L247)
- [encode_legal](../../FQChem/Complexity/ElectronicStructure.lean#L58)
- [energyPromise_transfer](../../FQChem/Complexity/ElectronicStructure.lean#L318)
- [expectation_bound](../../FQChem/Complexity/ElectronicStructure.lean#L166) (private)
- [expectation_scale](../../FQChem/Complexity/ElectronicStructure.lean#L281) (private)
- [homogeneous_lower](../../FQChem/Complexity/ElectronicStructure.lean#L299) (private)
- [interactionError](../../FQChem/Complexity/ElectronicStructure.lean#L213)
- [leakagePart_encodeState](../../FQChem/Complexity/ElectronicStructure.lean#L242)
- [leakagePenalty](../../FQChem/Complexity/ElectronicStructure.lean#L224)
- [leakage_expectation](../../FQChem/Complexity/ElectronicStructure.lean#L208) (private)
- [lowerBound_transfer](../../FQChem/Complexity/ElectronicStructure.lean#L267)
- [mass_nonneg](../../FQChem/Complexity/ElectronicStructure.lean#L262) (private)
- [mass_scale](../../FQChem/Complexity/ElectronicStructure.lean#L277) (private)
- [mass_split](../../FQChem/Complexity/ElectronicStructure.lean#L192)
- [move_encode](../../FQChem/Complexity/ElectronicStructure.lean#L127)
- [phase_encode](../../FQChem/Complexity/ElectronicStructure.lean#L149)
- [physicalMove_legal](../../FQChem/Complexity/ElectronicStructure.lean#L130)
- [physicalPhase_norm](../../FQChem/Complexity/ElectronicStructure.lean#L152) (private)
- [spinEnergy_scale](../../FQChem/Complexity/ElectronicStructure.lean#L292) (private)
- [spinPart_encodeState](../../FQChem/Complexity/ElectronicStructure.lean#L237)
- [splitSum](../../FQChem/Complexity/ElectronicStructure.lean#L187) (private)

## FQChem.Complexity.ElectronicStructureOperators

```mermaid
flowchart LR
  n36["ElectronicStructure.railMove_count"]
  n37["ElectronicStructure.railMove_twice"]
  n42["ElectronicStructure.energyPromise_transfer"]
  n61["encodingResources"]
  n62["fermionExpectation"]
  n63["fermionKernel_expectation"]
  n64["fermionKernel_hermitian"]
  n65["kernelSum_expectation"]
  n66["numberPenalty"]
  n67["oneBody_apply"]
  n68["railMatrix_secondQuantized"]
  n69["railPhase_reverse"]
  n70["spinKernel_expectation"]
  n71["sum_rail"]
  n72["variationalThreshold"]
  n73["variationalUpperBound"]
  n1273["VQE.vqe"]
  n36 -.-> n62
  n37 -.-> n62
  n63 --> n62
  n36 -.-> n63
  n37 -.-> n63
  n65 --> n63
  n36 -.-> n64
  n37 -.-> n64
  n69 --> n64
  n71 --> n66
  n71 --> n68
  n65 --> n70
  n36 -.-> n72
  n37 -.-> n72
  n42 --> n72
  n70 --> n72
  n36 -.-> n73
  n37 -.-> n73
  n62 --> n73
  n1273 --> n73
```

- [ElectronicStructure.railMove_count](../../FQChem/Complexity/ElectronicStructure.lean#L110)
- [ElectronicStructure.railMove_twice](../../FQChem/Complexity/ElectronicStructure.lean#L104)
- [ElectronicStructure.energyPromise_transfer](../../FQChem/Complexity/ElectronicStructure.lean#L318)
- [encodingResources](../../FQChem/Complexity/ElectronicStructureOperators.lean#L80)
- [fermionExpectation](../../FQChem/Complexity/ElectronicStructureOperators.lean#L175)
- [fermionKernel_expectation](../../FQChem/Complexity/ElectronicStructureOperators.lean#L158)
- [fermionKernel_hermitian](../../FQChem/Complexity/ElectronicStructureOperators.lean#L138)
- [kernelSum_expectation](../../FQChem/Complexity/ElectronicStructureOperators.lean#L98) (private)
- [numberPenalty](../../FQChem/Complexity/ElectronicStructureOperators.lean#L57)
- [oneBody_apply](../../FQChem/Complexity/ElectronicStructureOperators.lean#L31) (private)
- [railMatrix_secondQuantized](../../FQChem/Complexity/ElectronicStructureOperators.lean#L45)
- [railPhase_reverse](../../FQChem/Complexity/ElectronicStructureOperators.lean#L130) (private)
- [spinKernel_expectation](../../FQChem/Complexity/ElectronicStructureOperators.lean#L122)
- [sum_rail](../../FQChem/Complexity/ElectronicStructureOperators.lean#L37) (private)
- [variationalThreshold](../../FQChem/Complexity/ElectronicStructureOperators.lean#L198)
- [variationalUpperBound](../../FQChem/Complexity/ElectronicStructureOperators.lean#L188)
- [VQE.vqe](../../FQChem/StatePrep/VariationalOptimization/VQE.lean#L28)

## FQChem.Complexity.ElectronicStructurePauli

```mermaid
flowchart LR
  n36["ElectronicStructure.railMove_count"]
  n37["ElectronicStructure.railMove_twice"]
  n42["ElectronicStructure.energyPromise_transfer"]
  n70["ElectronicStructureOperators.spinKernel_expectation"]
  n74["dualEntry_conj"]
  n75["dualEntry_norm"]
  n76["entry_norm_le_one"]
  n77["extendWord_entry"]
  n78["extendWord_support"]
  n79["localExpansion_kernel"]
  n80["localExpansion_size"]
  n81["localExpansion_strength"]
  n82["localHamiltonian_to_fixedParticle"]
  n83["localHermitianExpansion"]
  n84["localTerm_expansion"]
  n85["pauliCoefficient_real"]
  n86["pauliEntry_conj"]
  n87["pauliExpansion"]
  n88["pauliResolution"]
  n89["spinResolution"]
  n90["untouched_eq"]
  n91["wordEntry_conj"]
  n92["wordEntry_eq"]
  n86 --> n74
  n76 --> n75
  n84 --> n79
  n92 -.-> n79
  n78 --> n80
  n75 --> n81
  n80 --> n81
  n36 -.-> n82
  n37 -.-> n82
  n42 --> n82
  n70 --> n82
  n79 --> n82
  n85 --> n83
  n87 --> n83
  n77 --> n84
  n85 --> n84
  n87 --> n84
  n74 --> n85
  n88 --> n87
  n89 --> n88
  n86 --> n91
```

- [ElectronicStructure.railMove_count](../../FQChem/Complexity/ElectronicStructure.lean#L110)
- [ElectronicStructure.railMove_twice](../../FQChem/Complexity/ElectronicStructure.lean#L104)
- [ElectronicStructure.energyPromise_transfer](../../FQChem/Complexity/ElectronicStructure.lean#L318)
- [ElectronicStructureOperators.spinKernel_expectation](../../FQChem/Complexity/ElectronicStructureOperators.lean#L122)
- [dualEntry_conj](../../FQChem/Complexity/ElectronicStructurePauli.lean#L80) (private)
- [dualEntry_norm](../../FQChem/Complexity/ElectronicStructurePauli.lean#L222) (private)
- [entry_norm_le_one](../../FQChem/Complexity/ElectronicStructurePauli.lean#L219) (private)
- [extendWord_entry](../../FQChem/Complexity/ElectronicStructurePauli.lean#L126)
- [extendWord_support](../../FQChem/Complexity/ElectronicStructurePauli.lean#L139)
- [localExpansion_kernel](../../FQChem/Complexity/ElectronicStructurePauli.lean#L184)
- [localExpansion_size](../../FQChem/Complexity/ElectronicStructurePauli.lean#L198)
- [localExpansion_strength](../../FQChem/Complexity/ElectronicStructurePauli.lean#L230)
- [localHamiltonian_to_fixedParticle](../../FQChem/Complexity/ElectronicStructurePauli.lean#L209)
- [localHermitianExpansion](../../FQChem/Complexity/ElectronicStructurePauli.lean#L97)
- [localTerm_expansion](../../FQChem/Complexity/ElectronicStructurePauli.lean#L175) (private)
- [pauliCoefficient_real](../../FQChem/Complexity/ElectronicStructurePauli.lean#L84)
- [pauliEntry_conj](../../FQChem/Complexity/ElectronicStructurePauli.lean#L29)
- [pauliExpansion](../../FQChem/Complexity/ElectronicStructurePauli.lean#L67)
- [pauliResolution](../../FQChem/Complexity/ElectronicStructurePauli.lean#L54)
- [spinResolution](../../FQChem/Complexity/ElectronicStructurePauli.lean#L33) (private)
- [untouched_eq](../../FQChem/Complexity/ElectronicStructurePauli.lean#L114)
- [wordEntry_conj](../../FQChem/Complexity/ElectronicStructurePauli.lean#L48)
- [wordEntry_eq](../../FQChem/Complexity/ElectronicStructurePauli.lean#L42)

## FQChem.Complexity.FactoringBitCost

```mermaid
flowchart LR
  n93["baseRun_spec"]
  n94["bitTrial_spec"]
  n95["candidate_spec"]
  n96["checkedPair_spec"]
  n97["decoded_bound"]
  n98["exactPower_spec"]
  n99["extractPair_spec"]
  n100["gcdRun_spec"]
  n101["gcdWord_spec"]
  n102["leWord_spec"]
  n103["powersRun_spec"]
  n104["predWord_spec"]
  n105["preprocessWord_spec"]
  n106["readBase_spec"]
  n107["rootRun_spec"]
  n108["root_range"]
  n112["FactoringPreprocessing.preprocess_sound"]
  n139["FactoringReduction.extractFactor_nonunit"]
  n147["FactoringReduction.modPower_spec"]
  n279["OrderFindingBitCost.add_word"]
  n282["OrderFindingBitCost.decoder_bit_bound"]
  n283["OrderFindingBitCost.divide_spec"]
  n284["OrderFindingBitCost.equal_spec"]
  n287["OrderFindingBitCost.multiply_spec"]
  n288["OrderFindingBitCost.power_spec"]
  n290["OrderFindingBitCost.ripple_spec"]
  n294["OrderFindingDecoder.convergent_bounds"]
  n304["OrderFindingPostprocessing.divisions_bound"]
  n96 --> n93
  n97 --> n93
  n99 --> n93
  n101 --> n93
  n139 --> n93
  n282 --> n93
  n284 --> n93
  n93 --> n94
  n96 --> n94
  n105 --> n94
  n106 --> n94
  n112 --> n94
  n101 --> n95
  n104 --> n95
  n147 --> n95
  n284 --> n95
  n288 --> n95
  n102 --> n96
  n283 --> n96
  n284 --> n96
  n294 --> n97
  n287 --> n98
  n95 --> n99
  n96 --> n99
  n283 --> n100
  n284 --> n100
  n100 --> n101
  n304 --> n101
  n290 --> n102
  n98 --> n103
  n102 --> n103
  n107 --> n103
  n108 --> n103
  n284 --> n103
  n290 --> n104
  n102 --> n105
  n103 --> n105
  n102 --> n106
  n104 --> n106
  n279 --> n106
  n98 --> n107
  n102 --> n107
  n279 --> n107
```

- [baseRun_spec](../../FQChem/Complexity/FactoringBitCost.lean#L374)
- [bitTrial_spec](../../FQChem/Complexity/FactoringBitCost.lean#L427)
- [candidate_spec](../../FQChem/Complexity/FactoringBitCost.lean#L282)
- [checkedPair_spec](../../FQChem/Complexity/FactoringBitCost.lean#L246)
- [decoded_bound](../../FQChem/Complexity/FactoringBitCost.lean#L350)
- [exactPower_spec](../../FQChem/Complexity/FactoringBitCost.lean#L97)
- [extractPair_spec](../../FQChem/Complexity/FactoringBitCost.lean#L311)
- [gcdRun_spec](../../FQChem/Complexity/FactoringBitCost.lean#L56) (private)
- [gcdWord_spec](../../FQChem/Complexity/FactoringBitCost.lean#L80)
- [leWord_spec](../../FQChem/Complexity/FactoringBitCost.lean#L25)
- [powersRun_spec](../../FQChem/Complexity/FactoringBitCost.lean#L170)
- [predWord_spec](../../FQChem/Complexity/FactoringBitCost.lean#L38)
- [preprocessWord_spec](../../FQChem/Complexity/FactoringBitCost.lean#L209)
- [readBase_spec](../../FQChem/Complexity/FactoringBitCost.lean#L337)
- [rootRun_spec](../../FQChem/Complexity/FactoringBitCost.lean#L132)
- [root_range](../../FQChem/Complexity/FactoringBitCost.lean#L112) (private)
- [FactoringPreprocessing.preprocess_sound](../../FQChem/Complexity/FactoringPreprocessing.lean#L103)
- [FactoringReduction.extractFactor_nonunit](../../FQChem/Complexity/FactoringReduction.lean#L349)
- [FactoringReduction.modPower_spec](../../FQChem/Complexity/FactoringReduction.lean#L52)
- [OrderFindingBitCost.add_word](../../FQChem/Complexity/OrderFindingBitCost.lean#L251)
- [OrderFindingBitCost.decoder_bit_bound](../../FQChem/Complexity/OrderFindingBitCost.lean#L443)
- [OrderFindingBitCost.divide_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L161)
- [OrderFindingBitCost.equal_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L209)
- [OrderFindingBitCost.multiply_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L115)
- [OrderFindingBitCost.power_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L319)
- [OrderFindingBitCost.ripple_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L51)
- [OrderFindingDecoder.convergent_bounds](../../FQChem/Complexity/OrderFindingDecoder.lean#L62)
- [OrderFindingPostprocessing.divisions_bound](../../FQChem/Complexity/OrderFindingPostprocessing.lean#L32)

## FQChem.Complexity.FactoringPreprocessing

```mermaid
flowchart LR
  n109["preprocess_even"]
  n110["preprocess_miss"]
  n111["preprocess_power"]
  n112["preprocess_sound"]
  n113["preprocess_tests"]
  n114["preprocessingPowerWidth"]
  n115["rootBits_exact"]
  n116["rootBits_tests"]
  n117["rootTestsFit_width"]
  n118["scanPowers_complete"]
  n119["scanPowers_sound"]
  n120["scanPowers_tests"]
  n109 --> n110
  n111 --> n110
  n118 --> n111
  n119 --> n112
  n120 --> n113
  n117 --> n114
  n115 --> n118
  n116 --> n120
```

- [preprocess_even](../../FQChem/Complexity/FactoringPreprocessing.lean#L112)
- [preprocess_miss](../../FQChem/Complexity/FactoringPreprocessing.lean#L139)
- [preprocess_power](../../FQChem/Complexity/FactoringPreprocessing.lean#L115)
- [preprocess_sound](../../FQChem/Complexity/FactoringPreprocessing.lean#L103)
- [preprocess_tests](../../FQChem/Complexity/FactoringPreprocessing.lean#L130)
- [preprocessingPowerWidth](../../FQChem/Complexity/FactoringPreprocessing.lean#L183)
- [rootBits_exact](../../FQChem/Complexity/FactoringPreprocessing.lean#L34) (private)
- [rootBits_tests](../../FQChem/Complexity/FactoringPreprocessing.lean#L29)
- [rootTestsFit_width](../../FQChem/Complexity/FactoringPreprocessing.lean#L168) (private)
- [scanPowers_complete](../../FQChem/Complexity/FactoringPreprocessing.lean#L70) (private)
- [scanPowers_sound](../../FQChem/Complexity/FactoringPreprocessing.lean#L56) (private)
- [scanPowers_tests](../../FQChem/Complexity/FactoringPreprocessing.lean#L88) (private)

## FQChem.Complexity.FactoringRecursion

```mermaid
flowchart LR
  n121["pair"]
  n122["aggregate_failure"]
  n123["block_failure"]
  n124["certify_isSome_iff"]
  n125["certify_some"]
  n126["factor_tree"]
  n127["first_none"]
  n128["prime_leaves"]
  n129["prime_stops"]
  n130["product_always"]
  n131["recursiveFactorization"]
  n132["row_failure"]
  n133["trial_budget"]
  n134["two_pow_length"]
  n135["visit_bound"]
  n121 --> n126
  n121 --> n128
  n121 -.-> n129
  n121 -.-> n130
  n126 --> n130
  n121 -.-> n131
  n122 --> n131
  n123 --> n131
  n128 --> n131
  n130 --> n131
  n132 --> n131
  n133 --> n131
  n127 -.-> n132
  n121 -.-> n133
  n135 --> n133
  n121 -.-> n135
  n126 --> n135
  n134 --> n135
```

- [pair](../../FQChem/Complexity/FactoringRecursion.lean#L41)
- [aggregate_failure](../../FQChem/Complexity/FactoringRecursion.lean#L231) (private)
- [block_failure](../../FQChem/Complexity/FactoringRecursion.lean#L216)
- [certify_isSome_iff](../../FQChem/Complexity/FactoringRecursion.lean#L187)
- [certify_some](../../FQChem/Complexity/FactoringRecursion.lean#L36)
- [factor_tree](../../FQChem/Complexity/FactoringRecursion.lean#L104)
- [first_none](../../FQChem/Complexity/FactoringRecursion.lean#L58)
- [prime_leaves](../../FQChem/Complexity/FactoringRecursion.lean#L148)
- [prime_stops](../../FQChem/Complexity/FactoringRecursion.lean#L89)
- [product_always](../../FQChem/Complexity/FactoringRecursion.lean#L123)
- [recursiveFactorization](../../FQChem/Complexity/FactoringRecursion.lean#L246)
- [row_failure](../../FQChem/Complexity/FactoringRecursion.lean#L204)
- [trial_budget](../../FQChem/Complexity/FactoringRecursion.lean#L182)
- [two_pow_length](../../FQChem/Complexity/FactoringRecursion.lean#L129) (private)
- [visit_bound](../../FQChem/Complexity/FactoringRecursion.lean#L136)

## FQChem.Complexity.FactoringReduction

```mermaid
flowchart LR
  n136["badUnitCount"]
  n137["bad_projection"]
  n138["constant_label_count"]
  n139["extractFactor_nonunit"]
  n140["extractFactor_of_good"]
  n141["extractFactor_sound"]
  n142["failedRetryCount"]
  n143["fairBitBaseSampler"]
  n144["generator_shift"]
  n145["goodUnitFraction"]
  n146["modPower_multiplications"]
  n147["modPower_spec"]
  n148["odd_quotient"]
  n149["randomBaseFailure"]
  n137 --> n136
  n138 --> n136
  n144 --> n136
  n148 --> n137
  n147 --> n140
  n136 --> n142
  n140 --> n142
  n148 --> n144
  n136 --> n145
  n136 --> n149
  n139 --> n149
  n140 --> n149
```

- [badUnitCount](../../FQChem/Complexity/FactoringReduction.lean#L197)
- [bad_projection](../../FQChem/Complexity/FactoringReduction.lean#L162) (private)
- [constant_label_count](../../FQChem/Complexity/FactoringReduction.lean#L125) (private)
- [extractFactor_nonunit](../../FQChem/Complexity/FactoringReduction.lean#L349)
- [extractFactor_of_good](../../FQChem/Complexity/FactoringReduction.lean#L273)
- [extractFactor_sound](../../FQChem/Complexity/FactoringReduction.lean#L74)
- [failedRetryCount](../../FQChem/Complexity/FactoringReduction.lean#L327)
- [fairBitBaseSampler](../../FQChem/Complexity/FactoringReduction.lean#L401)
- [generator_shift](../../FQChem/Complexity/FactoringReduction.lean#L99) (private)
- [goodUnitFraction](../../FQChem/Complexity/FactoringReduction.lean#L244)
- [modPower_multiplications](../../FQChem/Complexity/FactoringReduction.lean#L37)
- [modPower_spec](../../FQChem/Complexity/FactoringReduction.lean#L52)
- [odd_quotient](../../FQChem/Complexity/FactoringReduction.lean#L88) (private)
- [randomBaseFailure](../../FQChem/Complexity/FactoringReduction.lean#L359)

## FQChem.Complexity.FastForwarding

```mermaid
flowchart LR
  n150["byConcatenation"]
  n151["copies_length"]
  n152["repeat_error"]
  n153["run_append"]
  n579["SchrodingerGroup.unitaryEvolution"]
  n151 --> n150
  n152 --> n150
  n153 --> n152
  n579 --> n152
```

- [byConcatenation](../../FQChem/Complexity/FastForwarding.lean#L81)
- [copies_length](../../FQChem/Complexity/FastForwarding.lean#L37)
- [repeat_error](../../FQChem/Complexity/FastForwarding.lean#L58)
- [run_append](../../FQChem/Complexity/FastForwarding.lean#L42) (private)
- [SchrodingerGroup.unitaryEvolution](../../FQChem/Dynamics/RealTimePropagation/SchrodingerGroup.lean#L41)

## FQChem.Complexity.FermionicMarginals

```mermaid
flowchart LR
  n154["anyPairExpectation"]
  n155["convexRepresentable"]
  n156["energyRange"]
  n157["invariant"]
  n158["marginal_apply"]
  n159["marginal_positive"]
  n160["marginal_trace"]
  n161["pairExpectation"]
  n162["pairTrace"]
  n163["representable_density"]
  n164["representable_previous"]
  n165["snoc_relabel"]
  n166["traceLast_state"]
  n167["trace_relabel"]
  n157 --> n154
  n161 --> n154
  n167 --> n154
  n158 --> n155
  n154 --> n156
  n158 --> n160
  n158 --> n161
  n162 --> n161
  n167 --> n161
  n159 --> n163
  n160 --> n163
  n158 --> n164
  n166 --> n164
  n165 --> n166
```

- [anyPairExpectation](../../FQChem/Complexity/FermionicMarginals.lean#L185)
- [convexRepresentable](../../FQChem/Complexity/FermionicMarginals.lean#L68)
- [energyRange](../../FQChem/Complexity/FermionicMarginals.lean#L203)
- [invariant](../../FQChem/Complexity/FermionicMarginals.lean#L172) (private)
- [marginal_apply](../../FQChem/Complexity/FermionicMarginals.lean#L42)
- [marginal_positive](../../FQChem/Complexity/FermionicMarginals.lean#L46)
- [marginal_trace](../../FQChem/Complexity/FermionicMarginals.lean#L51)
- [pairExpectation](../../FQChem/Complexity/FermionicMarginals.lean#L157)
- [pairTrace](../../FQChem/Complexity/FermionicMarginals.lean#L146) (private)
- [representable_density](../../FQChem/Complexity/FermionicMarginals.lean#L61)
- [representable_previous](../../FQChem/Complexity/FermionicMarginals.lean#L121)
- [snoc_relabel](../../FQChem/Complexity/FermionicMarginals.lean#L91) (private)
- [traceLast_state](../../FQChem/Complexity/FermionicMarginals.lean#L101)
- [trace_relabel](../../FQChem/Complexity/FermionicMarginals.lean#L135) (private)

## FQChem.Complexity.FixedBasisArithmetic

```mermaid
flowchart LR
  n168["accumulate_spec"]
  n169["atom_bound"]
  n170["atom_value"]
  n171["coefficient_spec"]
  n172["coordinate_bound"]
  n173["difference_spec"]
  n174["electronicIntegral_spec"]
  n175["merge_spec"]
  n176["polynomialBudget"]
  n177["product_lt"]
  n178["readAtom_spec"]
  n179["read_spec"]
  n180["separation_cast"]
  n191["FixedBasisGeometry.coordinateBound"]
  n199["FixedBasisGeometry.separated"]
  n204["FixedBasisIntegrals.coordinate_eq"]
  n205["FixedBasisIntegrals.directCode_correct"]
  n231["FixedBasisSelfEnergy.self_value"]
  n287["OrderFindingBitCost.multiply_spec"]
  n290["OrderFindingBitCost.ripple_spec"]
  n292["OrderFindingBitCost.select_spec"]
  n405["SlaterEnergyOrbitals.coefficient_offdiag"]
  n175 --> n168
  n177 --> n168
  n191 --> n169
  n199 --> n169
  n204 --> n169
  n180 --> n170
  n168 --> n171
  n169 --> n171
  n170 --> n171
  n177 --> n171
  n205 --> n171
  n231 --> n171
  n287 --> n171
  n290 --> n173
  n292 --> n173
  n171 --> n174
  n178 --> n174
  n405 --> n174
  n287 --> n175
  n290 --> n175
  n172 --> n178
  n173 --> n178
  n179 --> n178
  n172 --> n179
  n292 --> n179
```

- [accumulate_spec](../../FQChem/Complexity/FixedBasisArithmetic.lean#L65)
- [atom_bound](../../FQChem/Complexity/FixedBasisArithmetic.lean#L140) (private)
- [atom_value](../../FQChem/Complexity/FixedBasisArithmetic.lean#L128) (private)
- [coefficient_spec](../../FQChem/Complexity/FixedBasisArithmetic.lean#L173)
- [coordinate_bound](../../FQChem/Complexity/FixedBasisArithmetic.lean#L215) (private)
- [difference_spec](../../FQChem/Complexity/FixedBasisArithmetic.lean#L244) (private)
- [electronicIntegral_spec](../../FQChem/Complexity/FixedBasisArithmetic.lean#L296)
- [merge_spec](../../FQChem/Complexity/FixedBasisArithmetic.lean#L33) (private)
- [polynomialBudget](../../FQChem/Complexity/FixedBasisArithmetic.lean#L318)
- [product_lt](../../FQChem/Complexity/FixedBasisArithmetic.lean#L57) (private)
- [readAtom_spec](../../FQChem/Complexity/FixedBasisArithmetic.lean#L273) (private)
- [read_spec](../../FQChem/Complexity/FixedBasisArithmetic.lean#L229) (private)
- [separation_cast](../../FQChem/Complexity/FixedBasisArithmetic.lean#L117) (private)
- [FixedBasisGeometry.coordinateBound](../../FQChem/Complexity/FixedBasisGeometry.lean#L109)
- [FixedBasisGeometry.separated](../../FQChem/Complexity/FixedBasisGeometry.lean#L80)
- [FixedBasisIntegrals.coordinate_eq](../../FQChem/Complexity/FixedBasisIntegrals.lean#L30)
- [FixedBasisIntegrals.directCode_correct](../../FQChem/Complexity/FixedBasisIntegrals.lean#L50)
- [FixedBasisSelfEnergy.self_value](../../FQChem/Complexity/FixedBasisSelfEnergy.lean#L97)
- [OrderFindingBitCost.multiply_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L115)
- [OrderFindingBitCost.ripple_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L51)
- [OrderFindingBitCost.select_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L93) (private)
- [SlaterEnergyOrbitals.coefficient_offdiag](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L70)

## FQChem.Complexity.FixedBasisCoulomb

```mermaid
flowchart LR
  n181["fourthMoment"]
  n182["onsite"]
  n183["radialKernel"]
  n189["FixedBasisGaussians.pairDensity"]
  n181 --> n182
  n183 --> n182
  n189 --> n182
```

- [fourthMoment](../../FQChem/Complexity/FixedBasisCoulomb.lean#L40) (private)
- [onsite](../../FQChem/Complexity/FixedBasisCoulomb.lean#L56)
- [radialKernel](../../FQChem/Complexity/FixedBasisCoulomb.lean#L22)
- [FixedBasisGaussians.pairDensity](../../FQChem/Complexity/FixedBasisGaussians.lean#L75)

## FQChem.Complexity.FixedBasisGaussians

```mermaid
flowchart LR
  n184["completeSquare"]
  n185["normalization"]
  n186["orbital_normalized"]
  n187["overlap"]
  n188["overlap_same"]
  n189["pairDensity"]
  n190["repulsion_reduction"]
  n188 --> n186
  n184 --> n187
  n185 --> n188
  n187 --> n188
  n184 --> n189
  n189 --> n190
```

- [completeSquare](../../FQChem/Complexity/FixedBasisGaussians.lean#L26) (private)
- [normalization](../../FQChem/Complexity/FixedBasisGaussians.lean#L56) (private)
- [orbital_normalized](../../FQChem/Complexity/FixedBasisGaussians.lean#L69)
- [overlap](../../FQChem/Complexity/FixedBasisGaussians.lean#L35)
- [overlap_same](../../FQChem/Complexity/FixedBasisGaussians.lean#L64)
- [pairDensity](../../FQChem/Complexity/FixedBasisGaussians.lean#L75)
- [repulsion_reduction](../../FQChem/Complexity/FixedBasisGaussians.lean#L100)

## FQChem.Complexity.FixedBasisGeometry

```mermaid
flowchart LR
  n191["coordinateBound"]
  n192["edgeDistance"]
  n193["lineDistance"]
  n194["nonedgeDistance"]
  n195["offset_le"]
  n196["partnerDistance"]
  n197["sameBlock"]
  n198["separateBlocks"]
  n199["separated"]
  n195 --> n191
  n196 --> n192
  n196 --> n194
  n197 --> n194
  n198 --> n194
  n193 --> n196
  n193 --> n198
  n195 --> n198
  n196 --> n199
  n197 --> n199
  n198 --> n199
```

- [coordinateBound](../../FQChem/Complexity/FixedBasisGeometry.lean#L109)
- [edgeDistance](../../FQChem/Complexity/FixedBasisGeometry.lean#L71)
- [lineDistance](../../FQChem/Complexity/FixedBasisGeometry.lean#L40) (private)
- [nonedgeDistance](../../FQChem/Complexity/FixedBasisGeometry.lean#L95)
- [offset_le](../../FQChem/Complexity/FixedBasisGeometry.lean#L46) (private)
- [partnerDistance](../../FQChem/Complexity/FixedBasisGeometry.lean#L62) (private)
- [sameBlock](../../FQChem/Complexity/FixedBasisGeometry.lean#L23) (private)
- [separateBlocks](../../FQChem/Complexity/FixedBasisGeometry.lean#L49) (private)
- [separated](../../FQChem/Complexity/FixedBasisGeometry.lean#L80)

## FQChem.Complexity.FixedBasisHopping

```mermaid
flowchart LR
  n200["chooseDistance"]
  n201["matchCoefficients"]
  n202["profile_decay"]
  n203["profile_eq_sqrt"]
  n202 --> n200
  n200 --> n201
```

- [chooseDistance](../../FQChem/Complexity/FixedBasisHopping.lean#L45)
- [matchCoefficients](../../FQChem/Complexity/FixedBasisHopping.lean#L70)
- [profile_decay](../../FQChem/Complexity/FixedBasisHopping.lean#L33) (private)
- [profile_eq_sqrt](../../FQChem/Complexity/FixedBasisHopping.lean#L24)

## FQChem.Complexity.FixedBasisIntegrals

```mermaid
flowchart LR
  n199["FixedBasisGeometry.separated"]
  n204["coordinate_eq"]
  n205["directCode_correct"]
  n206["evaluate_correct"]
  n207["self_translation"]
  n231["FixedBasisSelfEnergy.self_value"]
  n242["FixedBasisShell.separatedInteraction"]
  n405["SlaterEnergyOrbitals.coefficient_offdiag"]
  n408["SlaterEnergyOrbitals.direct_formula"]
  n199 --> n205
  n204 --> n205
  n207 --> n205
  n242 --> n205
  n408 --> n205
  n205 --> n206
  n231 --> n206
  n405 --> n206
```

- [FixedBasisGeometry.separated](../../FQChem/Complexity/FixedBasisGeometry.lean#L80)
- [coordinate_eq](../../FQChem/Complexity/FixedBasisIntegrals.lean#L30)
- [directCode_correct](../../FQChem/Complexity/FixedBasisIntegrals.lean#L50)
- [evaluate_correct](../../FQChem/Complexity/FixedBasisIntegrals.lean#L75)
- [self_translation](../../FQChem/Complexity/FixedBasisIntegrals.lean#L37) (private)
- [FixedBasisSelfEnergy.self_value](../../FQChem/Complexity/FixedBasisSelfEnergy.lean#L97)
- [FixedBasisShell.separatedInteraction](../../FQChem/Complexity/FixedBasisShell.lean#L284)
- [SlaterEnergyOrbitals.coefficient_offdiag](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L70)
- [SlaterEnergyOrbitals.direct_formula](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L74)

## FQChem.Complexity.FixedBasisOrthonormalization

```mermaid
flowchart LR
  n208["globalTransform"]
  n209["oneBodyError"]
  n210["orthonormalColumns"]
  n211["pairTransform"]
  n212["sandwichError"]
  n213["spectralDistance"]
  n214["squareRootBound"]
  n215["twoBodyError"]
  n213 --> n208
  n214 --> n208
  n208 --> n209
  n212 --> n209
  n208 --> n210
  n208 --> n211
  n213 --> n211
  n211 --> n215
  n212 --> n215
```

- [globalTransform](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L58)
- [oneBodyError](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L127)
- [orthonormalColumns](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L97)
- [pairTransform](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L136)
- [sandwichError](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L108) (private)
- [spectralDistance](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L26) (private)
- [squareRootBound](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L39) (private)
- [twoBodyError](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L175)

## FQChem.Complexity.FixedBasisRadial

```mermaid
flowchart LR
  n216["bounds"]
  n217["cumulative"]
  n218["first"]
  n219["kineticNumerator"]
  n220["radialBall"]
  n221["radialBallOfRadius"]
  n222["second"]
  n223["shape_laplacian"]
  n224["smooth"]
  n225["squared"]
  n226["volumeMass"]
  n227["zero"]
  n227 --> n216
  n220 --> n219
  n223 --> n219
  n221 --> n220
  n218 --> n222
  n222 --> n223
  n227 --> n223
  n227 --> n225
  n217 --> n226
  n220 --> n226
  n225 --> n226
```

- [bounds](../../FQChem/Complexity/FixedBasisRadial.lean#L37)
- [cumulative](../../FQChem/Complexity/FixedBasisRadial.lean#L120)
- [first](../../FQChem/Complexity/FixedBasisRadial.lean#L51) (private)
- [kineticNumerator](../../FQChem/Complexity/FixedBasisRadial.lean#L134)
- [radialBall](../../FQChem/Complexity/FixedBasisRadial.lean#L108)
- [radialBallOfRadius](../../FQChem/Complexity/FixedBasisRadial.lean#L95)
- [second](../../FQChem/Complexity/FixedBasisRadial.lean#L61) (private)
- [shape_laplacian](../../FQChem/Complexity/FixedBasisRadial.lean#L76)
- [smooth](../../FQChem/Complexity/FixedBasisRadial.lean#L26)
- [squared](../../FQChem/Complexity/FixedBasisRadial.lean#L43)
- [volumeMass](../../FQChem/Complexity/FixedBasisRadial.lean#L129)
- [zero](../../FQChem/Complexity/FixedBasisRadial.lean#L30)

## FQChem.Complexity.FixedBasisSelfEnergy

```mermaid
flowchart LR
  n217["FixedBasisRadial.cumulative"]
  n220["FixedBasisRadial.radialBall"]
  n221["FixedBasisRadial.radialBallOfRadius"]
  n225["FixedBasisRadial.squared"]
  n226["FixedBasisRadial.volumeMass"]
  n228["density_sq"]
  n229["halfValue"]
  n230["half_integrable"]
  n231["self_value"]
  n232["swapHalves"]
  n233["truncated"]
  n237["FixedBasisShell.exteriorReal"]
  n373["SlaterEnergyCoulomb.kernel_integrable"]
  n379["SlaterEnergyCoulomb.weight_pos"]
  n225 --> n228
  n379 --> n228
  n228 --> n229
  n233 --> n229
  n373 --> n230
  n220 --> n231
  n226 --> n231
  n228 --> n231
  n229 --> n231
  n230 --> n231
  n232 --> n231
  n230 --> n232
  n217 --> n233
  n221 --> n233
  n228 --> n233
  n237 --> n233
  n379 --> n233
```

- [FixedBasisRadial.cumulative](../../FQChem/Complexity/FixedBasisRadial.lean#L120)
- [FixedBasisRadial.radialBall](../../FQChem/Complexity/FixedBasisRadial.lean#L108)
- [FixedBasisRadial.radialBallOfRadius](../../FQChem/Complexity/FixedBasisRadial.lean#L95)
- [FixedBasisRadial.squared](../../FQChem/Complexity/FixedBasisRadial.lean#L43)
- [FixedBasisRadial.volumeMass](../../FQChem/Complexity/FixedBasisRadial.lean#L129)
- [density_sq](../../FQChem/Complexity/FixedBasisSelfEnergy.lean#L20) (private)
- [halfValue](../../FQChem/Complexity/FixedBasisSelfEnergy.lean#L78) (private)
- [half_integrable](../../FQChem/Complexity/FixedBasisSelfEnergy.lean#L53) (private)
- [self_value](../../FQChem/Complexity/FixedBasisSelfEnergy.lean#L97)
- [swapHalves](../../FQChem/Complexity/FixedBasisSelfEnergy.lean#L57) (private)
- [truncated](../../FQChem/Complexity/FixedBasisSelfEnergy.lean#L24) (private)
- [FixedBasisShell.exteriorReal](../../FQChem/Complexity/FixedBasisShell.lean#L227)
- [SlaterEnergyCoulomb.kernel_integrable](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L76)
- [SlaterEnergyCoulomb.weight_pos](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L42)

## FQChem.Complexity.FixedBasisShell

```mermaid
flowchart LR
  n234["axisDist"]
  n235["exteriorAxis"]
  n236["exteriorPoint"]
  n237["exteriorReal"]
  n238["mass_one"]
  n239["potential"]
  n240["profile_density"]
  n241["radialHeight"]
  n242["separatedInteraction"]
  n243["shellHeight"]
  n244["shellHeight_lintegral"]
  n245["sliceArea"]
  n246["split_sq"]
  n247["split_volume"]
  n248["transverseArea"]
  n369["SlaterEnergyCoulomb.density_normalized"]
  n373["SlaterEnergyCoulomb.kernel_integrable"]
  n375["SlaterEnergyCoulomb.nonnegative"]
  n377["SlaterEnergyCoulomb.wave_smooth"]
  n378["SlaterEnergyCoulomb.wave_zero"]
  n234 --> n235
  n241 --> n235
  n244 --> n235
  n235 --> n236
  n236 --> n237
  n369 --> n238
  n236 --> n239
  n238 --> n239
  n240 --> n239
  n377 --> n239
  n378 --> n239
  n245 --> n241
  n246 --> n241
  n247 --> n241
  n239 --> n242
  n373 --> n242
  n375 --> n242
  n377 --> n242
  n378 --> n242
  n243 --> n244
  n248 --> n245
```

- [axisDist](../../FQChem/Complexity/FixedBasisShell.lean#L162) (private)
- [exteriorAxis](../../FQChem/Complexity/FixedBasisShell.lean#L183)
- [exteriorPoint](../../FQChem/Complexity/FixedBasisShell.lean#L213)
- [exteriorReal](../../FQChem/Complexity/FixedBasisShell.lean#L227)
- [mass_one](../../FQChem/Complexity/FixedBasisShell.lean#L250) (private)
- [potential](../../FQChem/Complexity/FixedBasisShell.lean#L258)
- [profile_density](../../FQChem/Complexity/FixedBasisShell.lean#L246) (private)
- [radialHeight](../../FQChem/Complexity/FixedBasisShell.lean#L118)
- [separatedInteraction](../../FQChem/Complexity/FixedBasisShell.lean#L284)
- [shellHeight](../../FQChem/Complexity/FixedBasisShell.lean#L24)
- [shellHeight_lintegral](../../FQChem/Complexity/FixedBasisShell.lean#L169) (private)
- [sliceArea](../../FQChem/Complexity/FixedBasisShell.lean#L88) (private)
- [split_sq](../../FQChem/Complexity/FixedBasisShell.lean#L111) (private)
- [split_volume](../../FQChem/Complexity/FixedBasisShell.lean#L106) (private)
- [transverseArea](../../FQChem/Complexity/FixedBasisShell.lean#L55)
- [SlaterEnergyCoulomb.density_normalized](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L55)
- [SlaterEnergyCoulomb.kernel_integrable](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L76)
- [SlaterEnergyCoulomb.nonnegative](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L161)
- [SlaterEnergyCoulomb.wave_smooth](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L64)
- [SlaterEnergyCoulomb.wave_zero](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L60)

## FQChem.Complexity.GroundStateSearch

```mermaid
flowchart LR
  n249["energy_eq_failure"]
  n250["energy_query_lower_bound"]
  n251["groundSpace"]
  n252["hybrid_bound"]
  n253["hybrid_step"]
  n254["mark_eq_neg_reflection"]
  n255["orthonormal_addresses"]
  n256["orthonormal_energy_lower_bound"]
  n257["queried_norm"]
  n258["query_lower_bound"]
  n259["reference_norm"]
  n260["sum_amplitudes_le"]
  n249 --> n250
  n257 --> n250
  n258 --> n250
  n253 --> n252
  n259 --> n252
  n260 --> n252
  n254 --> n253
  n250 --> n256
  n255 --> n256
  n254 --> n257
  n252 --> n258
  n259 --> n258
  n260 --> n258
```

- [energy_eq_failure](../../FQChem/Complexity/GroundStateSearch.lean#L35)
- [energy_query_lower_bound](../../FQChem/Complexity/GroundStateSearch.lean#L141)
- [groundSpace](../../FQChem/Complexity/GroundStateSearch.lean#L30)
- [hybrid_bound](../../FQChem/Complexity/GroundStateSearch.lean#L103)
- [hybrid_step](../../FQChem/Complexity/GroundStateSearch.lean#L69) (private)
- [mark_eq_neg_reflection](../../FQChem/Complexity/GroundStateSearch.lean#L44) (private)
- [orthonormal_addresses](../../FQChem/Complexity/GroundStateSearch.lean#L86)
- [orthonormal_energy_lower_bound](../../FQChem/Complexity/GroundStateSearch.lean#L154)
- [queried_norm](../../FQChem/Complexity/GroundStateSearch.lean#L64)
- [query_lower_bound](../../FQChem/Complexity/GroundStateSearch.lean#L116)
- [reference_norm](../../FQChem/Complexity/GroundStateSearch.lean#L59)
- [sum_amplitudes_le](../../FQChem/Complexity/GroundStateSearch.lean#L92) (private)

## FQChem.Complexity.LocalHamiltonianVerification

```mermaid
flowchart LR
  n261["acceptance_eq"]
  n262["maximumAcceptance"]
  n263["termEffects"]
  n1159["RayleighRitz.groundEnergyPrinciple"]
  n263 --> n261
  n261 --> n262
  n1159 --> n262
```

- [acceptance_eq](../../FQChem/Complexity/LocalHamiltonianVerification.lean#L43)
- [maximumAcceptance](../../FQChem/Complexity/LocalHamiltonianVerification.lean#L66)
- [termEffects](../../FQChem/Complexity/LocalHamiltonianVerification.lean#L31)
- [RayleighRitz.groundEnergyPrinciple](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L59)

## FQChem.Complexity.MarginalVerification

```mermaid
flowchart LR
  n155["FermionicMarginals.convexRepresentable"]
  n163["FermionicMarginals.representable_density"]
  n264["measurableDiscrepancy"]
  n265["observableReadout"]
  n266["rejectionProbability"]
  n267["traceNormBound"]
  n155 --> n264
  n163 --> n264
  n265 --> n264
  n267 --> n264
```

- [FermionicMarginals.convexRepresentable](../../FQChem/Complexity/FermionicMarginals.lean#L68)
- [FermionicMarginals.representable_density](../../FQChem/Complexity/FermionicMarginals.lean#L61)
- [measurableDiscrepancy](../../FQChem/Complexity/MarginalVerification.lean#L68)
- [observableReadout](../../FQChem/Complexity/MarginalVerification.lean#L56)
- [rejectionProbability](../../FQChem/Complexity/MarginalVerification.lean#L97)
- [traceNormBound](../../FQChem/Complexity/MarginalVerification.lean#L30)

## FQChem.Complexity.ModularInverse

```mermaid
flowchart LR
  n268["inverse_spec"]
  n269["remainderCoefficient"]
  n270["run_spec"]
  n271["subtractMod_spec"]
  n279["OrderFindingBitCost.add_word"]
  n283["OrderFindingBitCost.divide_spec"]
  n284["OrderFindingBitCost.equal_spec"]
  n289["OrderFindingBitCost.productMod_spec"]
  n290["OrderFindingBitCost.ripple_spec"]
  n304["OrderFindingPostprocessing.divisions_bound"]
  n270 --> n268
  n304 --> n268
  n269 --> n270
  n271 --> n270
  n283 --> n270
  n284 --> n270
  n289 --> n270
  n279 --> n271
  n283 --> n271
  n290 --> n271
```

- [inverse_spec](../../FQChem/Complexity/ModularInverse.lean#L99)
- [remainderCoefficient](../../FQChem/Complexity/ModularInverse.lean#L52) (private)
- [run_spec](../../FQChem/Complexity/ModularInverse.lean#L62) (private)
- [subtractMod_spec](../../FQChem/Complexity/ModularInverse.lean#L25)
- [OrderFindingBitCost.add_word](../../FQChem/Complexity/OrderFindingBitCost.lean#L251)
- [OrderFindingBitCost.divide_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L161)
- [OrderFindingBitCost.equal_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L209)
- [OrderFindingBitCost.productMod_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L296)
- [OrderFindingBitCost.ripple_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L51)
- [OrderFindingPostprocessing.divisions_bound](../../FQChem/Complexity/OrderFindingPostprocessing.lean#L32)

## FQChem.Complexity.OrbitalSimulation

```mermaid
flowchart LR
  n16["AaronsonAmbainisQuery.acceptancePolynomial_degree"]
  n17["AaronsonAmbainisQuery.acceptancePolynomial_eval"]
  n272["evolution"]
  n273["hermitian"]
  n274["onsite_bounds"]
  n275["parity_cases"]
  n276["parity_orthogonal"]
  n277["population_parity"]
  n278["simulation_query_lower_bound"]
  n272 --> n277
  n275 --> n277
  n16 --> n278
  n17 --> n278
  n275 --> n278
  n276 --> n278
  n277 --> n278
```

- [AaronsonAmbainisQuery.acceptancePolynomial_degree](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L180)
- [AaronsonAmbainisQuery.acceptancePolynomial_eval](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L171)
- [evolution](../../FQChem/Complexity/OrbitalSimulation.lean#L77)
- [hermitian](../../FQChem/Complexity/OrbitalSimulation.lean#L71)
- [onsite_bounds](../../FQChem/Complexity/OrbitalSimulation.lean#L57)
- [parity_cases](../../FQChem/Complexity/OrbitalSimulation.lean#L29) (private)
- [parity_orthogonal](../../FQChem/Complexity/OrbitalSimulation.lean#L35)
- [population_parity](../../FQChem/Complexity/OrbitalSimulation.lean#L101)
- [simulation_query_lower_bound](../../FQChem/Complexity/OrbitalSimulation.lean#L113)

## FQChem.Complexity.OrderFindingBitCost

```mermaid
flowchart LR
  n147["FactoringReduction.modPower_spec"]
  n279["add_word"]
  n280["cell"]
  n281["decode_input_bound"]
  n282["decoder_bit_bound"]
  n283["divide_spec"]
  n284["equal_spec"]
  n285["fraction_spec"]
  n286["low_split"]
  n287["multiply_spec"]
  n288["power_spec"]
  n289["productMod_spec"]
  n290["ripple_spec"]
  n291["scan_spec"]
  n292["select_spec"]
  n293["update_spec"]
  n294["OrderFindingDecoder.convergent_bounds"]
  n290 --> n279
  n282 --> n281
  n291 --> n282
  n286 --> n283
  n290 --> n283
  n292 --> n283
  n286 --> n284
  n279 --> n285
  n283 --> n285
  n284 --> n285
  n287 --> n285
  n294 --> n285
  n286 --> n287
  n290 --> n287
  n292 --> n287
  n286 --> n288
  n289 --> n288
  n292 --> n288
  n283 --> n289
  n287 --> n289
  n280 --> n290
  n286 --> n290
  n147 --> n291
  n285 --> n291
  n288 --> n291
  n293 --> n291
  n294 --> n291
  n286 --> n292
  n284 --> n293
  n290 --> n293
  n292 --> n293
```

- [FactoringReduction.modPower_spec](../../FQChem/Complexity/FactoringReduction.lean#L52)
- [add_word](../../FQChem/Complexity/OrderFindingBitCost.lean#L251)
- [cell](../../FQChem/Complexity/OrderFindingBitCost.lean#L44) (private)
- [decode_input_bound](../../FQChem/Complexity/OrderFindingBitCost.lean#L461)
- [decoder_bit_bound](../../FQChem/Complexity/OrderFindingBitCost.lean#L443)
- [divide_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L161)
- [equal_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L209)
- [fraction_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L257)
- [low_split](../../FQChem/Complexity/OrderFindingBitCost.lean#L20) (private)
- [multiply_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L115)
- [power_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L319)
- [productMod_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L296)
- [ripple_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L51)
- [scan_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L402) (private)
- [select_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L93) (private)
- [update_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L357)
- [OrderFindingDecoder.convergent_bounds](../../FQChem/Complexity/OrderFindingDecoder.lean#L62)

## FQChem.Complexity.OrderFindingDecoder

```mermaid
flowchart LR
  n146["FactoringReduction.modPower_multiplications"]
  n147["FactoringReduction.modPower_spec"]
  n294["convergent_bounds"]
  n295["convergent_eq_real"]
  n296["convergent_invariants"]
  n297["decode_work"]
  n298["denominator_eq_real"]
  n299["euclidean_width"]
  n300["least_insert"]
  n301["modular_product_width"]
  n302["scan_eq_reference"]
  n303["scan_work"]
  n296 --> n294
  n296 --> n295
  n303 --> n297
  n295 --> n298
  n296 --> n298
  n294 --> n299
  n147 --> n301
  n147 --> n302
  n294 --> n302
  n298 --> n302
  n300 --> n302
  n146 --> n303
  n294 --> n303
```

- [FactoringReduction.modPower_multiplications](../../FQChem/Complexity/FactoringReduction.lean#L37)
- [FactoringReduction.modPower_spec](../../FQChem/Complexity/FactoringReduction.lean#L52)
- [convergent_bounds](../../FQChem/Complexity/OrderFindingDecoder.lean#L62)
- [convergent_eq_real](../../FQChem/Complexity/OrderFindingDecoder.lean#L70)
- [convergent_invariants](../../FQChem/Complexity/OrderFindingDecoder.lean#L36) (private)
- [decode_work](../../FQChem/Complexity/OrderFindingDecoder.lean#L180)
- [denominator_eq_real](../../FQChem/Complexity/OrderFindingDecoder.lean#L90)
- [euclidean_width](../../FQChem/Complexity/OrderFindingDecoder.lean#L199)
- [least_insert](../../FQChem/Complexity/OrderFindingDecoder.lean#L128)
- [modular_product_width](../../FQChem/Complexity/OrderFindingDecoder.lean#L216)
- [scan_eq_reference](../../FQChem/Complexity/OrderFindingDecoder.lean#L140)
- [scan_work](../../FQChem/Complexity/OrderFindingDecoder.lean#L163)

## FQChem.Complexity.OrderFindingPostprocessing

```mermaid
flowchart LR
  n304["divisions_bound"]
  n305["logarithmic_scan"]
  n306["stream_terminates"]
  n307["two_steps_halve"]
  n307 --> n304
  n304 --> n305
  n306 --> n305
```

- [divisions_bound](../../FQChem/Complexity/OrderFindingPostprocessing.lean#L32)
- [logarithmic_scan](../../FQChem/Complexity/OrderFindingPostprocessing.lean#L73)
- [stream_terminates](../../FQChem/Complexity/OrderFindingPostprocessing.lean#L56) (private)
- [two_steps_halve](../../FQChem/Complexity/OrderFindingPostprocessing.lean#L23) (private)

## FQChem.Complexity.SearchOptimality

```mermaid
flowchart LR
  n308["angle_formula"]
  n309["angle_map"]
  n310["coordinateProjection"]
  n311["grover_attains"]
  n312["grover_is_optimal"]
  n313["grover_run"]
  n314["near_certain_queries"]
  n315["optimal_average_success"]
  n316["query_angle_bound"]
  n317["reference_angle"]
  n318["reflection_angle"]
  n319["run_norm"]
  n320["success_mem"]
  n321["uniform_norm"]
  n736["AmplitudeAmplification.success_law"]
  n308 --> n309
  n310 --> n311
  n313 --> n311
  n321 --> n311
  n736 --> n311
  n310 --> n312
  n311 --> n312
  n315 --> n312
  n319 --> n312
  n320 --> n312
  n316 --> n314
  n316 --> n315
  n319 --> n315
  n320 --> n315
  n309 --> n316
  n317 --> n316
  n318 --> n316
  n319 --> n316
  n318 --> n317
  n308 --> n318
  n320 --> n318
```

- [angle_formula](../../FQChem/Complexity/SearchOptimality.lean#L52) (private)
- [angle_map](../../FQChem/Complexity/SearchOptimality.lean#L65) (private)
- [coordinateProjection](../../FQChem/Complexity/SearchOptimality.lean#L200) (private)
- [grover_attains](../../FQChem/Complexity/SearchOptimality.lean#L242)
- [grover_is_optimal](../../FQChem/Complexity/SearchOptimality.lean#L295)
- [grover_run](../../FQChem/Complexity/SearchOptimality.lean#L225) (private)
- [near_certain_queries](../../FQChem/Complexity/SearchOptimality.lean#L319)
- [optimal_average_success](../../FQChem/Complexity/SearchOptimality.lean#L181)
- [query_angle_bound](../../FQChem/Complexity/SearchOptimality.lean#L132)
- [reference_angle](../../FQChem/Complexity/SearchOptimality.lean#L109) (private)
- [reflection_angle](../../FQChem/Complexity/SearchOptimality.lean#L80) (private)
- [run_norm](../../FQChem/Complexity/SearchOptimality.lean#L125) (private)
- [success_mem](../../FQChem/Complexity/SearchOptimality.lean#L71) (private)
- [uniform_norm](../../FQChem/Complexity/SearchOptimality.lean#L216) (private)
- [AmplitudeAmplification.success_law](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L110)

## FQChem.Complexity.SlaterCertificate

```mermaid
flowchart LR
  n208["FixedBasisOrthonormalization.globalTransform"]
  n210["FixedBasisOrthonormalization.orthonormalColumns"]
  n322["completeness"]
  n323["constant_cast"]
  n324["corrected"]
  n325["digits_norm"]
  n326["entryNorm"]
  n327["entry_of_unit"]
  n328["finiteWitness"]
  n329["floor_bound"]
  n330["floor_error"]
  n331["gram_error"]
  n332["gram_iff"]
  n333["matrixNorm"]
  n334["productError"]
  n335["score_error"]
  n336["soundness"]
  n337["sumBound"]
  n338["vectorBound"]
  n341["SlaterContraction.energy"]
  n343["SlaterContraction.normalized"]
  n325 --> n322
  n327 --> n322
  n328 --> n322
  n331 --> n322
  n335 --> n322
  n341 --> n322
  n208 --> n324
  n210 --> n324
  n326 --> n324
  n332 --> n324
  n333 --> n324
  n337 --> n324
  n327 --> n328
  n329 --> n328
  n330 --> n328
  n327 --> n331
  n332 --> n331
  n334 --> n331
  n337 --> n331
  n337 --> n333
  n338 --> n333
  n334 --> n335
  n337 --> n335
  n323 --> n336
  n324 --> n336
  n325 --> n336
  n327 --> n336
  n335 --> n336
  n341 --> n336
  n343 --> n336
```

- [FixedBasisOrthonormalization.globalTransform](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L58)
- [FixedBasisOrthonormalization.orthonormalColumns](../../FQChem/Complexity/FixedBasisOrthonormalization.lean#L97)
- [completeness](../../FQChem/Complexity/SlaterCertificate.lean#L229)
- [constant_cast](../../FQChem/Complexity/SlaterCertificate.lean#L220) (private)
- [corrected](../../FQChem/Complexity/SlaterCertificate.lean#L127)
- [digits_norm](../../FQChem/Complexity/SlaterCertificate.lean#L188)
- [entryNorm](../../FQChem/Complexity/SlaterCertificate.lean#L56)
- [entry_of_unit](../../FQChem/Complexity/SlaterCertificate.lean#L65) (private)
- [finiteWitness](../../FQChem/Complexity/SlaterCertificate.lean#L177)
- [floor_bound](../../FQChem/Complexity/SlaterCertificate.lean#L158) (private)
- [floor_error](../../FQChem/Complexity/SlaterCertificate.lean#L167) (private)
- [gram_error](../../FQChem/Complexity/SlaterCertificate.lean#L200)
- [gram_iff](../../FQChem/Complexity/SlaterCertificate.lean#L25)
- [matrixNorm](../../FQChem/Complexity/SlaterCertificate.lean#L44)
- [productError](../../FQChem/Complexity/SlaterCertificate.lean#L68) (private)
- [score_error](../../FQChem/Complexity/SlaterCertificate.lean#L80)
- [soundness](../../FQChem/Complexity/SlaterCertificate.lean#L245)
- [sumBound](../../FQChem/Complexity/SlaterCertificate.lean#L33) (private)
- [vectorBound](../../FQChem/Complexity/SlaterCertificate.lean#L37) (private)
- [SlaterContraction.energy](../../FQChem/Complexity/SlaterContraction.lean#L234)
- [SlaterContraction.normalized](../../FQChem/Complexity/SlaterContraction.lean#L40)

## FQChem.Complexity.SlaterContraction

```mermaid
flowchart LR
  n339["absent_move"]
  n340["braCoefficient"]
  n341["energy"]
  n342["ket_update_pair"]
  n343["normalized"]
  n344["oneAbsent"]
  n345["oneAction"]
  n346["oneBody"]
  n347["overlap"]
  n348["physicalBra"]
  n349["rankOneBasis"]
  n350["twoAbsent"]
  n351["twoAction"]
  n352["twoBody"]
  n353["twoRepeated"]
  n354["twoSymm"]
  n346 --> n341
  n352 --> n341
  n339 --> n344
  n349 --> n345
  n343 --> n346
  n347 --> n346
  n340 --> n348
  n339 --> n350
  n344 --> n350
  n354 --> n350
  n342 --> n351
  n345 --> n351
  n349 --> n351
  n343 --> n352
  n346 --> n352
  n347 --> n352
  n345 --> n353
  n349 --> n353
```

- [absent_move](../../FQChem/Complexity/SlaterContraction.lean#L172) (private)
- [braCoefficient](../../FQChem/Complexity/SlaterContraction.lean#L71)
- [energy](../../FQChem/Complexity/SlaterContraction.lean#L234)
- [ket_update_pair](../../FQChem/Complexity/SlaterContraction.lean#L136) (private)
- [normalized](../../FQChem/Complexity/SlaterContraction.lean#L40)
- [oneAbsent](../../FQChem/Complexity/SlaterContraction.lean#L177)
- [oneAction](../../FQChem/Complexity/SlaterContraction.lean#L122)
- [oneBody](../../FQChem/Complexity/SlaterContraction.lean#L99)
- [overlap](../../FQChem/Complexity/SlaterContraction.lean#L49)
- [physicalBra](../../FQChem/Complexity/SlaterContraction.lean#L84)
- [rankOneBasis](../../FQChem/Complexity/SlaterContraction.lean#L112) (private)
- [twoAbsent](../../FQChem/Complexity/SlaterContraction.lean#L192)
- [twoAction](../../FQChem/Complexity/SlaterContraction.lean#L151)
- [twoBody](../../FQChem/Complexity/SlaterContraction.lean#L104)
- [twoRepeated](../../FQChem/Complexity/SlaterContraction.lean#L210)
- [twoSymm](../../FQChem/Complexity/SlaterContraction.lean#L185) (private)

## FQChem.Complexity.SlaterEnergy

```mermaid
flowchart LR
  n355["diagonal_energy"]
  n356["expectationPerturbation"]
  n357["independent_sites"]
  n358["injective_sites"]
  n359["noInstance"]
  n360["occupation_slater"]
  n361["polarized_zero"]
  n362["robustSlaterReduction"]
  n363["slaterDecisionGap"]
  n357 --> n359
  n358 --> n359
  n356 --> n362
  n363 --> n362
  n355 --> n363
  n359 --> n363
  n360 --> n363
  n361 --> n363
```

- [diagonal_energy](../../FQChem/Complexity/SlaterEnergy.lean#L142)
- [expectationPerturbation](../../FQChem/Complexity/SlaterEnergy.lean#L187)
- [independent_sites](../../FQChem/Complexity/SlaterEnergy.lean#L86) (private)
- [injective_sites](../../FQChem/Complexity/SlaterEnergy.lean#L71) (private)
- [noInstance](../../FQChem/Complexity/SlaterEnergy.lean#L102)
- [occupation_slater](../../FQChem/Complexity/SlaterEnergy.lean#L128)
- [polarized_zero](../../FQChem/Complexity/SlaterEnergy.lean#L51)
- [robustSlaterReduction](../../FQChem/Complexity/SlaterEnergy.lean#L207)
- [slaterDecisionGap](../../FQChem/Complexity/SlaterEnergy.lean#L155)

## FQChem.Complexity.SlaterEnergyCoulomb

```mermaid
flowchart LR
  n216["FixedBasisRadial.bounds"]
  n224["FixedBasisRadial.smooth"]
  n227["FixedBasisRadial.zero"]
  n364["bump_bounds"]
  n365["bump_compact"]
  n366["bump_smooth"]
  n367["bump_zero"]
  n368["density_le"]
  n369["density_normalized"]
  n370["density_value"]
  n371["joint_integrable"]
  n372["joint_normalized"]
  n373["kernel_integrable"]
  n374["lower"]
  n375["nonnegative"]
  n376["upper"]
  n377["wave_smooth"]
  n378["wave_zero"]
  n379["weight_pos"]
  n1141["CoulombIntegrability.coulombLocallyIntegrable"]
  n216 --> n364
  n367 --> n365
  n224 --> n366
  n227 --> n367
  n364 --> n368
  n370 --> n368
  n379 --> n368
  n370 --> n369
  n379 --> n369
  n379 --> n370
  n372 --> n371
  n369 --> n372
  n368 --> n373
  n377 --> n373
  n378 --> n373
  n379 --> n373
  n1141 --> n373
  n371 --> n374
  n372 --> n374
  n373 --> n374
  n378 --> n374
  n374 --> n375
  n371 --> n376
  n372 --> n376
  n373 --> n376
  n378 --> n376
  n366 --> n377
  n367 --> n378
  n365 --> n379
  n366 --> n379
```

- [FixedBasisRadial.bounds](../../FQChem/Complexity/FixedBasisRadial.lean#L37)
- [FixedBasisRadial.smooth](../../FQChem/Complexity/FixedBasisRadial.lean#L26)
- [FixedBasisRadial.zero](../../FQChem/Complexity/FixedBasisRadial.lean#L30)
- [bump_bounds](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L29) (private)
- [bump_compact](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L33) (private)
- [bump_smooth](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L27) (private)
- [bump_zero](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L31) (private)
- [density_le](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L68) (private)
- [density_normalized](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L55)
- [density_value](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L52) (private)
- [joint_integrable](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L122) (private)
- [joint_normalized](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L118) (private)
- [kernel_integrable](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L76)
- [lower](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L128)
- [nonnegative](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L161)
- [upper](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L145)
- [wave_smooth](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L64)
- [wave_zero](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L60)
- [weight_pos](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L42)
- [CoulombIntegrability.coulombLocallyIntegrable](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/CoulombIntegrability.lean#L38)

## FQChem.Complexity.SlaterEnergyHamiltonian

```mermaid
flowchart LR
  n380["coulomb_delta"]
  n381["electronic_eq"]
  n382["kinetic_delta"]
  n383["mode_ext"]
  n384["occupied_iff"]
  n385["occupied_spec"]
  n386["pairSum"]
  n387["pair_delta"]
  n388["physicalReduction"]
  n389["rationalThresholds"]
  n390["sameResidual"]
  n391["sign_sq"]
  n392["singleSum"]
  n393["sum_direct"]
  n396["SlaterEnergyKinetic.kinetic_matrix"]
  n403["SlaterEnergyKinetic.primitive_value"]
  n405["SlaterEnergyOrbitals.coefficient_offdiag"]
  n416["SlaterEnergyReduction.coulombDecisionGap"]
  n383 --> n380
  n405 --> n380
  n386 --> n381
  n392 --> n381
  n383 --> n382
  n396 --> n382
  n385 --> n384
  n385 --> n386
  n387 --> n386
  n390 --> n386
  n391 --> n386
  n393 --> n386
  n380 --> n387
  n381 --> n388
  n416 --> n388
  n388 --> n389
  n403 --> n389
  n382 --> n392
  n390 --> n392
  n391 --> n392
```

- [coulomb_delta](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L96) (private)
- [electronic_eq](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L187)
- [kinetic_delta](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L87) (private)
- [mode_ext](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L50) (private)
- [occupied_iff](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L37)
- [occupied_spec](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L26)
- [pairSum](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L155) (private)
- [pair_delta](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L113)
- [physicalReduction](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L198)
- [rationalThresholds](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L211)
- [sameResidual](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L65) (private)
- [sign_sq](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L57) (private)
- [singleSum](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L128) (private)
- [sum_direct](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L144) (private)
- [SlaterEnergyKinetic.kinetic_matrix](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L110)
- [SlaterEnergyKinetic.primitive_value](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L27)
- [SlaterEnergyOrbitals.coefficient_offdiag](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L70)
- [SlaterEnergyReduction.coulombDecisionGap](../../FQChem/Complexity/SlaterEnergyReduction.lean#L116)

## FQChem.Complexity.SlaterEnergyKinetic

```mermaid
flowchart LR
  n199["FixedBasisGeometry.separated"]
  n219["FixedBasisRadial.kineticNumerator"]
  n224["FixedBasisRadial.smooth"]
  n226["FixedBasisRadial.volumeMass"]
  n377["SlaterEnergyCoulomb.wave_smooth"]
  n378["SlaterEnergyCoulomb.wave_zero"]
  n379["SlaterEnergyCoulomb.weight_pos"]
  n394["compact_wave"]
  n395["disjoint_kinetic"]
  n396["kinetic_matrix"]
  n397["lap_continuous"]
  n398["lap_spatial"]
  n399["lap_sum"]
  n400["lap_zero"]
  n401["physicalSlaterGap"]
  n402["primitive_integral"]
  n403["primitive_value"]
  n404["translated"]
  n405["SlaterEnergyOrbitals.coefficient_offdiag"]
  n416["SlaterEnergyReduction.coulombDecisionGap"]
  n378 --> n394
  n199 --> n395
  n378 --> n395
  n400 --> n395
  n377 --> n396
  n394 --> n396
  n395 --> n396
  n397 --> n396
  n398 --> n396
  n402 --> n396
  n377 --> n397
  n377 --> n398
  n399 --> n398
  n378 --> n400
  n396 --> n401
  n405 --> n401
  n416 --> n401
  n404 --> n402
  n219 --> n403
  n224 --> n403
  n226 --> n403
  n379 --> n403
```

- [FixedBasisGeometry.separated](../../FQChem/Complexity/FixedBasisGeometry.lean#L80)
- [FixedBasisRadial.kineticNumerator](../../FQChem/Complexity/FixedBasisRadial.lean#L134)
- [FixedBasisRadial.smooth](../../FQChem/Complexity/FixedBasisRadial.lean#L26)
- [FixedBasisRadial.volumeMass](../../FQChem/Complexity/FixedBasisRadial.lean#L129)
- [SlaterEnergyCoulomb.wave_smooth](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L64)
- [SlaterEnergyCoulomb.wave_zero](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L60)
- [SlaterEnergyCoulomb.weight_pos](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L42)
- [compact_wave](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L44) (private)
- [disjoint_kinetic](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L70) (private)
- [kinetic_matrix](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L110)
- [lap_continuous](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L51) (private)
- [lap_spatial](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L92) (private)
- [lap_sum](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L80) (private)
- [lap_zero](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L63) (private)
- [physicalSlaterGap](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L140)
- [primitive_integral](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L104) (private)
- [primitive_value](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L27)
- [translated](../../FQChem/Complexity/SlaterEnergyKinetic.lean#L56) (private)
- [SlaterEnergyOrbitals.coefficient_offdiag](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L70)
- [SlaterEnergyReduction.coulombDecisionGap](../../FQChem/Complexity/SlaterEnergyReduction.lean#L116)

## FQChem.Complexity.SlaterEnergyOrbitals

```mermaid
flowchart LR
  n192["FixedBasisGeometry.edgeDistance"]
  n194["FixedBasisGeometry.nonedgeDistance"]
  n199["FixedBasisGeometry.separated"]
  n369["SlaterEnergyCoulomb.density_normalized"]
  n373["SlaterEnergyCoulomb.kernel_integrable"]
  n374["SlaterEnergyCoulomb.lower"]
  n375["SlaterEnergyCoulomb.nonnegative"]
  n376["SlaterEnergyCoulomb.upper"]
  n378["SlaterEnergyCoulomb.wave_zero"]
  n405["coefficient_offdiag"]
  n406["component_le_sum"]
  n407["direct_edge"]
  n408["direct_formula"]
  n409["direct_nonedge"]
  n410["direct_nonneg"]
  n411["direct_onsite"]
  n412["disjoint_components"]
  n413["disjoint_sites"]
  n414["spatial_density"]
  n415["spatial_orthonormal"]
  n413 --> n405
  n375 --> n406
  n192 --> n407
  n374 --> n407
  n406 --> n407
  n408 --> n407
  n373 --> n408
  n414 --> n408
  n194 --> n409
  n376 --> n409
  n408 --> n409
  n375 --> n410
  n408 --> n410
  n374 --> n411
  n406 --> n411
  n408 --> n411
  n199 --> n412
  n378 --> n412
  n412 --> n413
  n412 --> n414
  n369 --> n415
  n413 --> n415
  n414 --> n415
```

- [FixedBasisGeometry.edgeDistance](../../FQChem/Complexity/FixedBasisGeometry.lean#L71)
- [FixedBasisGeometry.nonedgeDistance](../../FQChem/Complexity/FixedBasisGeometry.lean#L95)
- [FixedBasisGeometry.separated](../../FQChem/Complexity/FixedBasisGeometry.lean#L80)
- [SlaterEnergyCoulomb.density_normalized](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L55)
- [SlaterEnergyCoulomb.kernel_integrable](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L76)
- [SlaterEnergyCoulomb.lower](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L128)
- [SlaterEnergyCoulomb.nonnegative](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L161)
- [SlaterEnergyCoulomb.upper](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L145)
- [SlaterEnergyCoulomb.wave_zero](../../FQChem/Complexity/SlaterEnergyCoulomb.lean#L60)
- [coefficient_offdiag](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L70)
- [component_le_sum](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L95) (private)
- [direct_edge](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L118)
- [direct_formula](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L74)
- [direct_nonedge](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L129)
- [direct_nonneg](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L90)
- [direct_onsite](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L109)
- [disjoint_components](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L23)
- [disjoint_sites](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L33)
- [spatial_density](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L38)
- [spatial_orthonormal](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L51)

## FQChem.Complexity.SlaterEnergyReduction

```mermaid
flowchart LR
  n359["SlaterEnergy.noInstance"]
  n360["SlaterEnergy.occupation_slater"]
  n361["SlaterEnergy.polarized_zero"]
  n407["SlaterEnergyOrbitals.direct_edge"]
  n409["SlaterEnergyOrbitals.direct_nonedge"]
  n410["SlaterEnergyOrbitals.direct_nonneg"]
  n411["SlaterEnergyOrbitals.direct_onsite"]
  n416["coulombDecisionGap"]
  n417["dependent_lower"]
  n418["expectation"]
  n419["four_le_spacing"]
  n420["independent_upper"]
  n360 --> n416
  n417 --> n416
  n418 --> n416
  n420 --> n416
  n359 --> n417
  n407 --> n417
  n410 --> n417
  n411 --> n417
  n419 --> n417
  n361 --> n420
  n409 --> n420
  n419 --> n420
```

- [SlaterEnergy.noInstance](../../FQChem/Complexity/SlaterEnergy.lean#L102)
- [SlaterEnergy.occupation_slater](../../FQChem/Complexity/SlaterEnergy.lean#L128)
- [SlaterEnergy.polarized_zero](../../FQChem/Complexity/SlaterEnergy.lean#L51)
- [SlaterEnergyOrbitals.direct_edge](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L118)
- [SlaterEnergyOrbitals.direct_nonedge](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L129)
- [SlaterEnergyOrbitals.direct_nonneg](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L90)
- [SlaterEnergyOrbitals.direct_onsite](../../FQChem/Complexity/SlaterEnergyOrbitals.lean#L109)
- [coulombDecisionGap](../../FQChem/Complexity/SlaterEnergyReduction.lean#L116)
- [dependent_lower](../../FQChem/Complexity/SlaterEnergyReduction.lean#L67)
- [expectation](../../FQChem/Complexity/SlaterEnergyReduction.lean#L104)
- [four_le_spacing](../../FQChem/Complexity/SlaterEnergyReduction.lean#L24) (private)
- [independent_upper](../../FQChem/Complexity/SlaterEnergyReduction.lean#L37)

## FQChem.Complexity.SlaterEnergyThreeSAT

```mermaid
flowchart LR
  n388["SlaterEnergyHamiltonian.physicalReduction"]
  n421["clauseTrue"]
  n422["formulaEnergyGap"]
  n423["independentIff"]
  n388 --> n422
  n423 -.-> n422
  n421 --> n423
```

- [SlaterEnergyHamiltonian.physicalReduction](../../FQChem/Complexity/SlaterEnergyHamiltonian.lean#L198)
- [clauseTrue](../../FQChem/Complexity/SlaterEnergyThreeSAT.lean#L38) (private)
- [formulaEnergyGap](../../FQChem/Complexity/SlaterEnergyThreeSAT.lean#L108)
- [independentIff](../../FQChem/Complexity/SlaterEnergyThreeSAT.lean#L52)

## FQChem.Complexity.SlaterIntegerVerifier

```mermaid
flowchart LR
  n322["SlaterCertificate.completeness"]
  n336["SlaterCertificate.soundness"]
  n424["accept_iff"]
  n425["decode_raw"]
  n426["energy_test"]
  n427["gram_test"]
  n428["pack"]
  n429["proj_spec"]
  n430["residual_spec"]
  n431["score_spec"]
  n432["verifies"]
  n433["witnessWidth"]
  n426 --> n424
  n427 --> n424
  n431 --> n426
  n430 --> n427
  n425 --> n429
  n425 --> n430
  n429 --> n431
  n322 --> n432
  n336 --> n432
  n424 --> n432
  n428 --> n432
```

- [SlaterCertificate.completeness](../../FQChem/Complexity/SlaterCertificate.lean#L229)
- [SlaterCertificate.soundness](../../FQChem/Complexity/SlaterCertificate.lean#L245)
- [accept_iff](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L119)
- [decode_raw](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L53) (private)
- [energy_test](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L110)
- [gram_test](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L76)
- [pack](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L136) (private)
- [proj_spec](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L58) (private)
- [residual_spec](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L65) (private)
- [score_spec](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L90) (private)
- [verifies](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L157)
- [witnessWidth](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L182)

## FQChem.Complexity.SlaterIntegralPrecision

```mermaid
flowchart LR
  n341["SlaterContraction.energy"]
  n432["SlaterIntegerVerifier.verifies"]
  n434["integralError"]
  n435["sumBound"]
  n436["verifiesApproximations"]
  n341 --> n434
  n435 --> n434
  n432 --> n436
  n434 --> n436
```

- [SlaterContraction.energy](../../FQChem/Complexity/SlaterContraction.lean#L234)
- [SlaterIntegerVerifier.verifies](../../FQChem/Complexity/SlaterIntegerVerifier.lean#L157)
- [integralError](../../FQChem/Complexity/SlaterIntegralPrecision.lean#L27)
- [sumBound](../../FQChem/Complexity/SlaterIntegralPrecision.lean#L19) (private)
- [verifiesApproximations](../../FQChem/Complexity/SlaterIntegralPrecision.lean#L62)

## FQChem.Complexity.SlaterVerifierWork

```mermaid
flowchart LR
  n437["allInputs"]
  n438["binaryCap"]
  n439["cmpSmall"]
  n440["density_eval"]
  n441["density_inputs"]
  n442["density_work"]
  n443["digit_check"]
  n444["energy_check"]
  n445["gram_check"]
  n446["gram_eval"]
  n447["gram_work"]
  n448["mag_add"]
  n449["mag_mul"]
  n450["mag_sub"]
  n451["operandWidth"]
  n452["run_eq"]
  n453["scalar_square"]
  n454["score_eval"]
  n455["score_work"]
  n456["smallMono"]
  n457["smallValue"]
  n458["sum_inputs"]
  n459["total_eval"]
  n460["total_work"]
  n461["verifierWidth"]
  n462["verifierWork"]
  n463["within"]
  n441 --> n437
  n458 --> n437
  n463 --> n437
  n451 --> n439
  n456 --> n439
  n459 --> n440
  n458 --> n441
  n460 --> n442
  n453 -.-> n443
  n454 --> n444
  n446 --> n445
  n459 --> n446
  n460 --> n447
  n438 --> n451
  n448 --> n451
  n449 --> n451
  n450 --> n451
  n456 --> n451
  n457 --> n451
  n443 -.-> n452
  n444 --> n452
  n445 -.-> n452
  n440 --> n454
  n459 --> n454
  n442 --> n455
  n460 --> n455
  n437 --> n461
  n439 --> n461
  n447 --> n461
  n455 --> n461
  n447 --> n462
  n455 --> n462
```

- [allInputs](../../FQChem/Complexity/SlaterVerifierWork.lean#L306) (private)
- [binaryCap](../../FQChem/Complexity/SlaterVerifierWork.lean#L88) (private)
- [cmpSmall](../../FQChem/Complexity/SlaterVerifierWork.lean#L333) (private)
- [density_eval](../../FQChem/Complexity/SlaterVerifierWork.lean#L152)
- [density_inputs](../../FQChem/Complexity/SlaterVerifierWork.lean#L299) (private)
- [density_work](../../FQChem/Complexity/SlaterVerifierWork.lean#L167)
- [digit_check](../../FQChem/Complexity/SlaterVerifierWork.lean#L217)
- [energy_check](../../FQChem/Complexity/SlaterVerifierWork.lean#L227)
- [gram_check](../../FQChem/Complexity/SlaterVerifierWork.lean#L221)
- [gram_eval](../../FQChem/Complexity/SlaterVerifierWork.lean#L155)
- [gram_work](../../FQChem/Complexity/SlaterVerifierWork.lean#L170)
- [mag_add](../../FQChem/Complexity/SlaterVerifierWork.lean#L49) (private)
- [mag_mul](../../FQChem/Complexity/SlaterVerifierWork.lean#L63) (private)
- [mag_sub](../../FQChem/Complexity/SlaterVerifierWork.lean#L55) (private)
- [operandWidth](../../FQChem/Complexity/SlaterVerifierWork.lean#L94)
- [run_eq](../../FQChem/Complexity/SlaterVerifierWork.lean#L249)
- [scalar_square](../../FQChem/Complexity/SlaterVerifierWork.lean#L214) (private)
- [score_eval](../../FQChem/Complexity/SlaterVerifierWork.lean#L158)
- [score_work](../../FQChem/Complexity/SlaterVerifierWork.lean#L177)
- [smallMono](../../FQChem/Complexity/SlaterVerifierWork.lean#L81) (private)
- [smallValue](../../FQChem/Complexity/SlaterVerifierWork.lean#L78) (private)
- [sum_inputs](../../FQChem/Complexity/SlaterVerifierWork.lean#L294) (private)
- [total_eval](../../FQChem/Complexity/SlaterVerifierWork.lean#L120)
- [total_work](../../FQChem/Complexity/SlaterVerifierWork.lean#L127)
- [verifierWidth](../../FQChem/Complexity/SlaterVerifierWork.lean#L342)
- [verifierWork](../../FQChem/Complexity/SlaterVerifierWork.lean#L262)
- [within](../../FQChem/Complexity/SlaterVerifierWork.lean#L303) (private)

## FQChem.Complexity.SparseNoFastForwarding

```mermaid
flowchart LR
  n21["AaronsonAmbainisQuery.amplitudes_normalized"]
  n464["diagonal_bound"]
  n465["difference_hermitian"]
  n466["evolved_density"]
  n467["evolved_state"]
  n468["no_fast_forwarding"]
  n469["readout"]
  n470["reduced_hermitian"]
  n471["trace_reduced"]
  n476["SparseParityNorm.spectral_norm"]
  n480["SparseParityPath.evolution_lifts"]
  n484["SparseParityPath.twoSparse"]
  n488["SparseParityQueries.compile"]
  n491["SparseParityQueries.parity_query_lower_bound"]
  n510["SpinPathEvolution.evolution_column"]
  n470 --> n465
  n467 --> n466
  n480 --> n467
  n510 --> n467
  n21 --> n468
  n464 --> n468
  n465 --> n468
  n469 --> n468
  n471 --> n468
  n476 --> n468
  n484 --> n468
  n488 --> n468
  n491 --> n468
```

- [AaronsonAmbainisQuery.amplitudes_normalized](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L78)
- [diagonal_bound](../../FQChem/Complexity/SparseNoFastForwarding.lean#L30) (private)
- [difference_hermitian](../../FQChem/Complexity/SparseNoFastForwarding.lean#L106)
- [evolved_density](../../FQChem/Complexity/SparseNoFastForwarding.lean#L96)
- [evolved_state](../../FQChem/Complexity/SparseNoFastForwarding.lean#L73)
- [no_fast_forwarding](../../FQChem/Complexity/SparseNoFastForwarding.lean#L119)
- [readout](../../FQChem/Complexity/SparseNoFastForwarding.lean#L111) (private)
- [reduced_hermitian](../../FQChem/Complexity/SparseNoFastForwarding.lean#L64) (private)
- [trace_reduced](../../FQChem/Complexity/SparseNoFastForwarding.lean#L68) (private)
- [SparseParityNorm.spectral_norm](../../FQChem/Complexity/SparseParityNorm.lean#L81)
- [SparseParityPath.evolution_lifts](../../FQChem/Complexity/SparseParityPath.lean#L131)
- [SparseParityPath.twoSparse](../../FQChem/Complexity/SparseParityPath.lean#L74)
- [SparseParityQueries.compile](../../FQChem/Complexity/SparseParityQueries.lean#L144)
- [SparseParityQueries.parity_query_lower_bound](../../FQChem/Complexity/SparseParityQueries.lean#L243)
- [SpinPathEvolution.evolution_column](../../FQChem/Complexity/SpinPathEvolution.lean#L177)

## FQChem.Complexity.SparseParityNorm

```mermaid
flowchart LR
  n472["eigen"]
  n473["eigenvalue_bound"]
  n474["positive_entries"]
  n475["row_mass"]
  n476["spectral_norm"]
  n477["w_pos"]
  n478["SparseParityPath.crossed_eq_lift"]
  n481["SparseParityPath.hermitian"]
  n508["SpinPathEvolution.binomial_eigenvector"]
  n478 --> n472
  n508 --> n472
  n475 --> n473
  n477 --> n473
  n472 --> n475
  n474 --> n475
  n472 --> n476
  n473 --> n476
  n477 --> n476
  n481 --> n476
```

- [eigen](../../FQChem/Complexity/SparseParityNorm.lean#L28) (private)
- [eigenvalue_bound](../../FQChem/Complexity/SparseParityNorm.lean#L55) (private)
- [positive_entries](../../FQChem/Complexity/SparseParityNorm.lean#L43) (private)
- [row_mass](../../FQChem/Complexity/SparseParityNorm.lean#L48) (private)
- [spectral_norm](../../FQChem/Complexity/SparseParityNorm.lean#L81)
- [w_pos](../../FQChem/Complexity/SparseParityNorm.lean#L25) (private)
- [SparseParityPath.crossed_eq_lift](../../FQChem/Complexity/SparseParityPath.lean#L116)
- [SparseParityPath.hermitian](../../FQChem/Complexity/SparseParityPath.lean#L49)
- [SpinPathEvolution.binomial_eigenvector](../../FQChem/Complexity/SpinPathEvolution.lean#L108)

## FQChem.Complexity.SparseParityPath

```mermaid
flowchart LR
  n478["crossed_eq_lift"]
  n479["endpoint_amplitude"]
  n480["evolution_lifts"]
  n481["hermitian"]
  n482["lift_entry"]
  n483["row_from_adjacent_bits"]
  n484["twoSparse"]
  n480 --> n479
  n482 --> n479
  n478 --> n480
```

- [crossed_eq_lift](../../FQChem/Complexity/SparseParityPath.lean#L116)
- [endpoint_amplitude](../../FQChem/Complexity/SparseParityPath.lean#L151)
- [evolution_lifts](../../FQChem/Complexity/SparseParityPath.lean#L131)
- [hermitian](../../FQChem/Complexity/SparseParityPath.lean#L49)
- [lift_entry](../../FQChem/Complexity/SparseParityPath.lean#L109) (private)
- [row_from_adjacent_bits](../../FQChem/Complexity/SparseParityPath.lean#L61)
- [twoSparse](../../FQChem/Complexity/SparseParityPath.lean#L74)

## FQChem.Complexity.SparseParityQueries

```mermaid
flowchart LR
  n16["AaronsonAmbainisQuery.acceptancePolynomial_degree"]
  n17["AaronsonAmbainisQuery.acceptancePolynomial_eval"]
  n21["AaronsonAmbainisQuery.amplitudes_normalized"]
  n276["OrbitalSimulation.parity_orthogonal"]
  n277["OrbitalSimulation.population_parity"]
  n278["OrbitalSimulation.simulation_query_lower_bound"]
  n479["SparseParityPath.endpoint_amplitude"]
  n485["apply_gate"]
  n486["basis_unitary"]
  n487["coherent_lookup"]
  n488["compile"]
  n489["endpoint_query_lower_bound"]
  n490["parity_eq"]
  n491["parity_query_lower_bound"]
  n492["response_decodes"]
  n493["row_character"]
  n494["separatedParity"]
  n495["sign_prefixParity"]
  n496["unitary_product"]
  n497["walsh_adjoint"]
  n498["walsh_lookup"]
  n499["walsh_square"]
  n500["xor_character"]
  n501["xor_step"]
  n512["SpinPathEvolution.perfect_transfer"]
  n21 --> n485
  n496 --> n485
  n497 --> n486
  n499 --> n486
  n498 --> n487
  n493 --> n488
  n479 --> n489
  n491 --> n489
  n512 --> n489
  n495 --> n490
  n277 --> n491
  n278 --> n491
  n488 --> n491
  n490 --> n491
  n16 --> n494
  n17 --> n494
  n276 --> n494
  n488 --> n494
  n490 --> n494
  n499 --> n498
  n500 --> n498
  n500 -.-> n499
  n485 --> n501
  n486 --> n501
  n487 --> n501
  n496 --> n501
```

- [AaronsonAmbainisQuery.acceptancePolynomial_degree](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L180)
- [AaronsonAmbainisQuery.acceptancePolynomial_eval](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L171)
- [AaronsonAmbainisQuery.amplitudes_normalized](../../FQChem/Complexity/AaronsonAmbainisQuery.lean#L78)
- [OrbitalSimulation.parity_orthogonal](../../FQChem/Complexity/OrbitalSimulation.lean#L35)
- [OrbitalSimulation.population_parity](../../FQChem/Complexity/OrbitalSimulation.lean#L101)
- [OrbitalSimulation.simulation_query_lower_bound](../../FQChem/Complexity/OrbitalSimulation.lean#L113)
- [SparseParityPath.endpoint_amplitude](../../FQChem/Complexity/SparseParityPath.lean#L151)
- [apply_gate](../../FQChem/Complexity/SparseParityQueries.lean#L163) (private)
- [basis_unitary](../../FQChem/Complexity/SparseParityQueries.lean#L188) (private)
- [coherent_lookup](../../FQChem/Complexity/SparseParityQueries.lean#L193) (private)
- [compile](../../FQChem/Complexity/SparseParityQueries.lean#L144)
- [endpoint_query_lower_bound](../../FQChem/Complexity/SparseParityQueries.lean#L281)
- [parity_eq](../../FQChem/Complexity/SparseParityQueries.lean#L236) (private)
- [parity_query_lower_bound](../../FQChem/Complexity/SparseParityQueries.lean#L243)
- [response_decodes](../../FQChem/Complexity/SparseParityQueries.lean#L63)
- [row_character](../../FQChem/Complexity/SparseParityQueries.lean#L118)
- [separatedParity](../../FQChem/Complexity/SparseParityQueries.lean#L260)
- [sign_prefixParity](../../FQChem/Complexity/SparseParityQueries.lean#L227) (private)
- [unitary_product](../../FQChem/Complexity/SparseParityQueries.lean#L158) (private)
- [walsh_adjoint](../../FQChem/Complexity/SparseParityQueries.lean#L83) (private)
- [walsh_lookup](../../FQChem/Complexity/SparseParityQueries.lean#L107)
- [walsh_square](../../FQChem/Complexity/SparseParityQueries.lean#L88) (private)
- [xor_character](../../FQChem/Complexity/SparseParityQueries.lean#L46)
- [xor_step](../../FQChem/Complexity/SparseParityQueries.lean#L203)
- [SpinPathEvolution.perfect_transfer](../../FQChem/Complexity/SpinPathEvolution.lean#L197)

## FQChem.Complexity.SparseSimulationPrecision

```mermaid
flowchart LR
  n479["SparseParityPath.endpoint_amplitude"]
  n494["SparseParityQueries.separatedParity"]
  n502["cutoffFromSignal"]
  n503["endpointProbability"]
  n504["factorialBound"]
  n505["factorialObstruction"]
  n506["shortTimeLowerBound"]
  n507["worstCaseCutoff"]
  n516["SpinPathEvolution.transfer_amplitude"]
  n504 --> n502
  n479 --> n503
  n516 --> n503
  n502 --> n505
  n506 --> n505
  n494 --> n506
  n503 --> n506
  n505 --> n507
  n506 --> n507
```

- [SparseParityPath.endpoint_amplitude](../../FQChem/Complexity/SparseParityPath.lean#L151)
- [SparseParityQueries.separatedParity](../../FQChem/Complexity/SparseParityQueries.lean#L260)
- [cutoffFromSignal](../../FQChem/Complexity/SparseSimulationPrecision.lean#L61)
- [endpointProbability](../../FQChem/Complexity/SparseSimulationPrecision.lean#L30)
- [factorialBound](../../FQChem/Complexity/SparseSimulationPrecision.lean#L47) (private)
- [factorialObstruction](../../FQChem/Complexity/SparseSimulationPrecision.lean#L97)
- [shortTimeLowerBound](../../FQChem/Complexity/SparseSimulationPrecision.lean#L37)
- [worstCaseCutoff](../../FQChem/Complexity/SparseSimulationPrecision.lean#L110)
- [SpinPathEvolution.transfer_amplitude](../../FQChem/Complexity/SpinPathEvolution.lean#L190)

## FQChem.Complexity.SpinPathEvolution

```mermaid
flowchart LR
  n508["binomial_eigenvector"]
  n509["couplings"]
  n510["evolution_column"]
  n511["exp_column"]
  n512["perfect_transfer"]
  n513["row_action"]
  n514["state_deriv"]
  n515["state_zero"]
  n516["transfer_amplitude"]
  n513 --> n508
  n511 --> n510
  n514 --> n510
  n515 --> n510
  n516 --> n512
  n509 --> n513
  n513 --> n514
  n510 --> n516
```

- [binomial_eigenvector](../../FQChem/Complexity/SpinPathEvolution.lean#L108)
- [couplings](../../FQChem/Complexity/SpinPathEvolution.lean#L28) (private)
- [evolution_column](../../FQChem/Complexity/SpinPathEvolution.lean#L177)
- [exp_column](../../FQChem/Complexity/SpinPathEvolution.lean#L144) (private)
- [perfect_transfer](../../FQChem/Complexity/SpinPathEvolution.lean#L197)
- [row_action](../../FQChem/Complexity/SpinPathEvolution.lean#L55) (private)
- [state_deriv](../../FQChem/Complexity/SpinPathEvolution.lean#L120) (private)
- [state_zero](../../FQChem/Complexity/SpinPathEvolution.lean#L168) (private)
- [transfer_amplitude](../../FQChem/Complexity/SpinPathEvolution.lean#L190)

## FQChem.Complexity.WitnessMajority

```mermaid
flowchart LR
  n517["boundOfWitnesses"]
  n518["entangledAcceptance"]
  n519["monotone"]
  n520["scalarMajority"]
  n521["soundness"]
  n522["threeWitnessSoundness"]
  n521 --> n518
  n519 --> n521
  n520 --> n521
  n517 --> n522
  n518 --> n522
```

- [boundOfWitnesses](../../FQChem/Complexity/WitnessMajority.lean#L82)
- [entangledAcceptance](../../FQChem/Complexity/WitnessMajority.lean#L73)
- [monotone](../../FQChem/Complexity/WitnessMajority.lean#L30)
- [scalarMajority](../../FQChem/Complexity/WitnessMajority.lean#L52) (private)
- [soundness](../../FQChem/Complexity/WitnessMajority.lean#L62)
- [threeWitnessSoundness](../../FQChem/Complexity/WitnessMajority.lean#L107)

## FQChem.Dynamics.DigitalAlgorithms.CommutingTerms

```mermaid
flowchart LR
  n523["commutingProductFormula"]
```

- [commutingProductFormula](../../FQChem/Dynamics/DigitalAlgorithms/CommutingTerms.lean#L18)

## FQChem.Dynamics.DigitalAlgorithms.LieTrotter

```mermaid
flowchart LR
  n524["exp_norm_bound"]
  n525["globalStepError"]
  n526["lieTrotter"]
  n527["power_defect"]
  n527 --> n525
  n524 --> n526
  n527 --> n526
```

- [exp_norm_bound](../../FQChem/Dynamics/DigitalAlgorithms/LieTrotter.lean#L62) (private)
- [globalStepError](../../FQChem/Dynamics/DigitalAlgorithms/LieTrotter.lean#L55)
- [lieTrotter](../../FQChem/Dynamics/DigitalAlgorithms/LieTrotter.lean#L73)
- [power_defect](../../FQChem/Dynamics/DigitalAlgorithms/LieTrotter.lean#L36) (private)

## FQChem.Dynamics.DigitalAlgorithms.LinearCombinationOfUnitaries

```mermaid
flowchart LR
  n528["blockEncodes"]
  n529["circuit_unitary"]
  n530["postselectionWeight"]
  n531["referenceBlock"]
  n532["select_prepare"]
  n533["select_unitary"]
  n531 --> n528
  n533 --> n529
  n528 --> n530
  n532 --> n531
```

- [blockEncodes](../../FQChem/Dynamics/DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L69)
- [circuit_unitary](../../FQChem/Dynamics/DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L40)
- [postselectionWeight](../../FQChem/Dynamics/DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L81)
- [referenceBlock](../../FQChem/Dynamics/DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L55)
- [select_prepare](../../FQChem/Dynamics/DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L47) (private)
- [select_unitary](../../FQChem/Dynamics/DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L30)

## FQChem.Dynamics.DigitalAlgorithms.Qubitization

```mermaid
flowchart LR
  n534["block_recurrence"]
  n535["chebyshev_block"]
  n536["eigenphase_cosine"]
  n537["eigenvalue_abs_le_one"]
  n538["eigenvector_amplitude"]
  n539["involution_inner"]
  n540["proj_reflection"]
  n541["quadratic_simulation_bound"]
  n542["reflection_sq"]
  n543["simulation_error"]
  n544["walk_preserves_inner"]
  n540 --> n534
  n542 --> n534
  n534 --> n535
  n540 --> n535
  n537 --> n536
  n538 --> n536
  n539 --> n537
  n535 --> n538
  n537 --> n541
  n538 --> n541
  n538 --> n543
  n539 --> n544
  n542 --> n544
```

- [block_recurrence](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L74) (private)
- [chebyshev_block](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L100)
- [eigenphase_cosine](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L150)
- [eigenvalue_abs_le_one](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L135)
- [eigenvector_amplitude](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L115)
- [involution_inner](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L62) (private)
- [proj_reflection](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L59) (private)
- [quadratic_simulation_bound](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L169)
- [reflection_sq](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L55) (private)
- [simulation_error](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L125)
- [walk_preserves_inner](../../FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L67)

## FQChem.Dynamics.DigitalAlgorithms.TruncatedTaylor

```mermaid
flowchart LR
  n545["generator_norm"]
  n546["power_error"]
  n547["realTime_segment"]
  n548["realTime_segmented"]
  n549["realTime_state_error"]
  n550["segment_error"]
  n551["segment_tendsto"]
  n545 --> n547
  n550 --> n547
  n546 --> n548
  n547 --> n548
  n548 --> n549
```

- [generator_norm](../../FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L89) (private)
- [power_error](../../FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L59) (private)
- [realTime_segment](../../FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L94)
- [realTime_segmented](../../FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L101)
- [realTime_state_error](../../FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L125)
- [segment_error](../../FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L41)
- [segment_tendsto](../../FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L55)

## FQChem.Dynamics.LearnedSurrogates

```mermaid
flowchart LR
  n552["invariantDirectionalForce"]
```

- [invariantDirectionalForce](../../FQChem/Dynamics/LearnedSurrogates.lean#L28)

## FQChem.Dynamics.OpenSystems.Kraus

```mermaid
flowchart LR
  n553["completePositivity"]
  n554["complexLinearity"]
  n555["jointDensityPreservation"]
  n556["lifted_operation"]
  n557["tracePreservation"]
  n556 --> n553
  n553 --> n555
  n557 --> n555
```

- [completePositivity](../../FQChem/Dynamics/OpenSystems/Kraus.lean#L74)
- [complexLinearity](../../FQChem/Dynamics/OpenSystems/Kraus.lean#L69)
- [jointDensityPreservation](../../FQChem/Dynamics/OpenSystems/Kraus.lean#L86)
- [lifted_operation](../../FQChem/Dynamics/OpenSystems/Kraus.lean#L59) (private)
- [tracePreservation](../../FQChem/Dynamics/OpenSystems/Kraus.lean#L79)

## FQChem.Dynamics.OpenSystems.TracePreservation

```mermaid
flowchart LR
  n558["krausTrace"]
  n559["lindbladTrace"]
```

- [krausTrace](../../FQChem/Dynamics/OpenSystems/TracePreservation.lean#L37)
- [lindbladTrace](../../FQChem/Dynamics/OpenSystems/TracePreservation.lean#L30)

## FQChem.Dynamics.RealTimePropagation.BornOppenheimer

```mermaid
flowchart LR
  n560["bornOppenheimerEnergy"]
```

- [bornOppenheimerEnergy](../../FQChem/Dynamics/RealTimePropagation/BornOppenheimer.lean#L27)

## FQChem.Dynamics.RealTimePropagation.ClusterExpansions

```mermaid
flowchart LR
  n561["linkedClusterInversion"]
```

- [linkedClusterInversion](../../FQChem/Dynamics/RealTimePropagation/ClusterExpansions.lean#L20)

## FQChem.Dynamics.RealTimePropagation.HeisenbergPicture

```mermaid
flowchart LR
  n562["pauliRotation"]
  n563["pictureDuality"]
```

- [pauliRotation](../../FQChem/Dynamics/RealTimePropagation/HeisenbergPicture.lean#L38)
- [pictureDuality](../../FQChem/Dynamics/RealTimePropagation/HeisenbergPicture.lean#L33)

## FQChem.Dynamics.RealTimePropagation.KrylovPropagation

```mermaid
flowchart LR
  n564["krylovExact"]
  n565["krylovMoment"]
```

- [krylovExact](../../FQChem/Dynamics/RealTimePropagation/KrylovPropagation.lean#L34)
- [krylovMoment](../../FQChem/Dynamics/RealTimePropagation/KrylovPropagation.lean#L42)

## FQChem.Dynamics.RealTimePropagation.OutOfTimeOrder

```mermaid
flowchart LR
  n85["ElectronicStructurePauli.pauliCoefficient_real"]
  n86["ElectronicStructurePauli.pauliEntry_conj"]
  n87["ElectronicStructurePauli.pauliExpansion"]
  n92["ElectronicStructurePauli.wordEntry_eq"]
  n566["butterflyMass"]
  n567["discardedWeightError"]
  n568["dualEntry_trace"]
  n569["expansion"]
  n570["firstOrder_eq_anticommutingMass"]
  n571["invariantTails"]
  n572["swapTrace"]
  n573["traceCoefficient"]
  n574["traceExpansion"]
  n575["twoCopyReadout"]
  n576["zConjugation"]
  n85 --> n566
  n569 --> n566
  n574 --> n566
  n570 --> n567
  n86 --> n568
  n87 --> n569
  n85 --> n570
  n566 --> n570
  n569 --> n570
  n574 --> n570
  n576 --> n570
  n568 --> n573
  n573 --> n574
  n572 --> n575
  n92 --> n576
```

- [ElectronicStructurePauli.pauliCoefficient_real](../../FQChem/Complexity/ElectronicStructurePauli.lean#L84)
- [ElectronicStructurePauli.pauliEntry_conj](../../FQChem/Complexity/ElectronicStructurePauli.lean#L29)
- [ElectronicStructurePauli.pauliExpansion](../../FQChem/Complexity/ElectronicStructurePauli.lean#L67)
- [ElectronicStructurePauli.wordEntry_eq](../../FQChem/Complexity/ElectronicStructurePauli.lean#L42)
- [butterflyMass](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L79)
- [discardedWeightError](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L117)
- [dualEntry_trace](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L38) (private)
- [expansion](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L49) (private)
- [firstOrder_eq_anticommutingMass](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L91)
- [invariantTails](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L154)
- [swapTrace](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L140)
- [traceCoefficient](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L43)
- [traceExpansion](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L71) (private)
- [twoCopyReadout](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L146)
- [zConjugation](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L57)

## FQChem.Dynamics.RealTimePropagation.PathSampling

```mermaid
flowchart LR
  n577["realTimeReweighting"]
```

- [realTimeReweighting](../../FQChem/Dynamics/RealTimePropagation/PathSampling.lean#L22)

## FQChem.Dynamics.RealTimePropagation.RingPolymer

```mermaid
flowchart LR
  n578["ringPolymerSpringForce"]
```

- [ringPolymerSpringForce](../../FQChem/Dynamics/RealTimePropagation/RingPolymer.lean#L26)

## FQChem.Dynamics.RealTimePropagation.SchrodingerGroup

```mermaid
flowchart LR
  n579["unitaryEvolution"]
```

- [unitaryEvolution](../../FQChem/Dynamics/RealTimePropagation/SchrodingerGroup.lean#L41)

## FQChem.Dynamics.RealTimePropagation.SplitOperator

```mermaid
flowchart LR
  n580["splitOperator"]
```

- [splitOperator](../../FQChem/Dynamics/RealTimePropagation/SplitOperator.lean#L26)

## FQChem.Dynamics.RealTimePropagation.TimeDependentCI

```mermaid
flowchart LR
  n581["tdConfigurationInteraction"]
```

- [tdConfigurationInteraction](../../FQChem/Dynamics/RealTimePropagation/TimeDependentCI.lean#L28)

## FQChem.Dynamics.RealTimePropagation.VariationalEvolution

```mermaid
flowchart LR
  n582["mcLachlanProjection"]
  n583["sampledTangentMetric"]
```

- [mcLachlanProjection](../../FQChem/Dynamics/RealTimePropagation/VariationalEvolution.lean#L56)
- [sampledTangentMetric](../../FQChem/Dynamics/RealTimePropagation/VariationalEvolution.lean#L38)

## FQChem.Multiscale.ChoosingLayers.ClassicalEnvironments

```mermaid
flowchart LR
  n584["layeredForce"]
```

- [layeredForce](../../FQChem/Multiscale/ChoosingLayers/ClassicalEnvironments.lean#L26)

## FQChem.Multiscale.ChoosingLayers.Fragments

```mermaid
flowchart LR
  n585["pairReconstruction"]
```

- [pairReconstruction](../../FQChem/Multiscale/ChoosingLayers/Fragments.lean#L27)

## FQChem.Multiscale.ChoosingLayers.FrozenMolecularDensity

```mermaid
flowchart LR
  n586["frozenMolecularEnergy"]
  n590["QuantumEnvironments.frozenSearch"]
  n1140["CoulombIntegrability.coulombConstrainedSearch"]
  n590 --> n586
  n1140 --> n586
```

- [frozenMolecularEnergy](../../FQChem/Multiscale/ChoosingLayers/FrozenMolecularDensity.lean#L15)
- [QuantumEnvironments.frozenSearch](../../FQChem/Multiscale/ChoosingLayers/QuantumEnvironments.lean#L41)
- [CoulombIntegrability.coulombConstrainedSearch](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/CoulombIntegrability.lean#L88)

## FQChem.Multiscale.ChoosingLayers.LearnedEnvironments

```mermaid
flowchart LR
  n587["deltaLearningGap"]
```

- [deltaLearningGap](../../FQChem/Multiscale/ChoosingLayers/LearnedEnvironments.lean#L23)

## FQChem.Multiscale.ChoosingLayers.Partitions

```mermaid
flowchart LR
  n588["overlapAccounting"]
```

- [overlapAccounting](../../FQChem/Multiscale/ChoosingLayers/Partitions.lean#L36)

## FQChem.Multiscale.ChoosingLayers.QuantumEnvironments

```mermaid
flowchart LR
  n589["frozenDensityDerivative"]
  n590["frozenSearch"]
```

- [frozenDensityDerivative](../../FQChem/Multiscale/ChoosingLayers/QuantumEnvironments.lean#L37)
- [frozenSearch](../../FQChem/Multiscale/ChoosingLayers/QuantumEnvironments.lean#L41)

## FQChem.Multiscale.StitchingSolutions.EmbeddedSolvers

```mermaid
flowchart LR
  n591["feshbachReduction"]
```

- [feshbachReduction](../../FQChem/Multiscale/StitchingSolutions/EmbeddedSolvers.lean#L30)

## FQChem.Multiscale.StitchingSolutions.ErrorPropagation

```mermaid
flowchart LR
  n592["barrierRateError"]
```

- [barrierRateError](../../FQChem/Multiscale/StitchingSolutions/ErrorPropagation.lean#L23)

## FQChem.Multiscale.StitchingSolutions.LayeredQM

```mermaid
flowchart LR
  n560["BornOppenheimer.bornOppenheimerEnergy"]
  n584["ClassicalEnvironments.layeredForce"]
  n593["layeredBornOppenheimerEnergy"]
  n594["layeredEigenForce"]
  n595["layeredProjectionError"]
  n596["layeredProjectionLimit"]
  n597["projectedLayeredEnergy_eq"]
  n653["HellmannFeynman.hellmannFeynman"]
  n953["GroundStateProjection.energyBound"]
  n954["GroundStateProjection.energyLimit"]
  n560 --> n593
  n594 --> n593
  n584 --> n594
  n653 --> n594
  n597 --> n595
  n953 --> n595
  n597 --> n596
  n954 --> n596
```

- [BornOppenheimer.bornOppenheimerEnergy](../../FQChem/Dynamics/RealTimePropagation/BornOppenheimer.lean#L27)
- [ClassicalEnvironments.layeredForce](../../FQChem/Multiscale/ChoosingLayers/ClassicalEnvironments.lean#L26)
- [layeredBornOppenheimerEnergy](../../FQChem/Multiscale/StitchingSolutions/LayeredQM.lean#L73)
- [layeredEigenForce](../../FQChem/Multiscale/StitchingSolutions/LayeredQM.lean#L61)
- [layeredProjectionError](../../FQChem/Multiscale/StitchingSolutions/LayeredQM.lean#L34)
- [layeredProjectionLimit](../../FQChem/Multiscale/StitchingSolutions/LayeredQM.lean#L44)
- [projectedLayeredEnergy_eq](../../FQChem/Multiscale/StitchingSolutions/LayeredQM.lean#L26)
- [HellmannFeynman.hellmannFeynman](../../FQChem/Properties/ResponseAndEstimation/HellmannFeynman.lean#L39)
- [GroundStateProjection.energyBound](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L139)
- [GroundStateProjection.energyLimit](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L150)

## FQChem.Multiscale.StitchingSolutions.Observables

```mermaid
flowchart LR
  n598["zwanzig"]
```

- [zwanzig](../../FQChem/Multiscale/StitchingSolutions/Observables.lean#L33)

## FQChem.Properties.AtomicBinding

```mermaid
flowchart LR
  n599["consecutiveBinding_of_convexity"]
  n600["convexity_implies_consecutiveBinding"]
  n607["AtomicTrialStates.trialSpinor_nonempty"]
  n599 --> n600
  n607 --> n600
```

- [consecutiveBinding_of_convexity](../../FQChem/Properties/AtomicBinding.lean#L14)
- [convexity_implies_consecutiveBinding](../../FQChem/Properties/AtomicBinding.lean#L29)
- [AtomicTrialStates.trialSpinor_nonempty](../../FQChem/Properties/AtomicTrialStates.lean#L197)

## FQChem.Properties.AtomicTrialStates

```mermaid
flowchart LR
  n601["finiteEnergy_of_regularSupport"]
  n602["firstElectronBinds"]
  n603["integrableKinetic"]
  n604["kinetic_dilate"]
  n605["normalizedPacket"]
  n606["permutationPacket"]
  n607["trialSpinor_nonempty"]
  n603 --> n601
  n603 --> n602
  n604 --> n602
  n605 --> n602
  n606 --> n602
  n601 --> n605
  n605 --> n607
  n606 --> n607
```

- [finiteEnergy_of_regularSupport](../../FQChem/Properties/AtomicTrialStates.lean#L123) (private)
- [firstElectronBinds](../../FQChem/Properties/AtomicTrialStates.lean#L216)
- [integrableKinetic](../../FQChem/Properties/AtomicTrialStates.lean#L110) (private)
- [kinetic_dilate](../../FQChem/Properties/AtomicTrialStates.lean#L202) (private)
- [normalizedPacket](../../FQChem/Properties/AtomicTrialStates.lean#L144) (private)
- [permutationPacket](../../FQChem/Properties/AtomicTrialStates.lean#L29) (private)
- [trialSpinor_nonempty](../../FQChem/Properties/AtomicTrialStates.lean#L197)

## FQChem.Properties.LinearSystems.DirichletPoisson

```mermaid
flowchart LR
  n608["dirichletPoissonMode"]
```

- [dirichletPoissonMode](../../FQChem/Properties/LinearSystems/DirichletPoisson.lean#L20)

## FQChem.Properties.LinearSystems.HHL

```mermaid
flowchart LR
  n609["hhlSpectralInversion"]
```

- [hhlSpectralInversion](../../FQChem/Properties/LinearSystems/HHL.lean#L18)

## FQChem.Properties.LinearSystems.MolecularResponse

```mermaid
flowchart LR
  n609["HHL.hhlSpectralInversion"]
  n610["dampingIdentity"]
  n611["hermitianResponseSystem"]
  n612["polarizability"]
  n613["residualError"]
  n614["spectralResponse"]
  n615["uniqueResponse"]
  n610 --> n613
  n609 --> n614
  n613 --> n615
```

- [HHL.hhlSpectralInversion](../../FQChem/Properties/LinearSystems/HHL.lean#L18)
- [dampingIdentity](../../FQChem/Properties/LinearSystems/MolecularResponse.lean#L28)
- [hermitianResponseSystem](../../FQChem/Properties/LinearSystems/MolecularResponse.lean#L57)
- [polarizability](../../FQChem/Properties/LinearSystems/MolecularResponse.lean#L90)
- [residualError](../../FQChem/Properties/LinearSystems/MolecularResponse.lean#L36)
- [spectralResponse](../../FQChem/Properties/LinearSystems/MolecularResponse.lean#L78)
- [uniqueResponse](../../FQChem/Properties/LinearSystems/MolecularResponse.lean#L45)

## FQChem.Properties.MeasurementTheory

```mermaid
flowchart LR
  n616["bornCompleteness"]
  n617["projectiveRepeatability"]
  n618["unsharpQubit"]
```

- [bornCompleteness](../../FQChem/Properties/MeasurementTheory.lean#L69)
- [projectiveRepeatability](../../FQChem/Properties/MeasurementTheory.lean#L78)
- [unsharpQubit](../../FQChem/Properties/MeasurementTheory.lean#L96)

## FQChem.Properties.PhaseEstimation

```mermaid
flowchart LR
  n619["exactGridQPE"]
```

- [exactGridQPE](../../FQChem/Properties/PhaseEstimation.lean#L17)

## FQChem.Properties.ResponseAndEstimation.AdaptivePauliPrediction

```mermaid
flowchart LR
  n620["alternativeNonneg"]
  n621["bornHard"]
  n622["bornSum"]
  n623["copyLowerBound"]
  n624["leafError"]
  n625["leafNormalization"]
  n626["massRatio"]
  n627["mixtureLower"]
  n628["nullIndependent"]
  n629["nullNonnegative"]
  n630["pathPositive"]
  n631["productLoss"]
  n632["randomizedCopyLowerBound"]
  n633["signMixture"]
  n658["PauliPrediction.nonidentityCount"]
  n659["PauliPrediction.nonidentitySecondMoment"]
  n665["PauliPrediction.responseAbs"]
  n626 --> n620
  n629 --> n620
  n630 --> n620
  n665 --> n620
  n624 --> n623
  n625 --> n623
  n629 --> n623
  n630 --> n623
  n658 --> n623
  n659 --> n623
  n620 --> n624
  n627 --> n624
  n628 --> n624
  n629 --> n624
  n622 --> n625
  n621 --> n626
  n630 --> n626
  n626 --> n627
  n629 --> n627
  n630 --> n627
  n633 --> n627
  n665 --> n627
  n621 --> n629
  n630 --> n629
  n623 --> n632
  n631 --> n633
```

- [alternativeNonneg](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L171) (private)
- [bornHard](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L73) (private)
- [bornSum](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L54) (private)
- [copyLowerBound](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L201)
- [leafError](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L181) (private)
- [leafNormalization](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L59)
- [massRatio](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L90) (private)
- [mixtureLower](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L148) (private)
- [nullIndependent](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L104) (private)
- [nullNonnegative](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L96) (private)
- [pathPositive](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L42) (private)
- [productLoss](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L108) (private)
- [randomizedCopyLowerBound](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L240)
- [signMixture](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L122) (private)
- [PauliPrediction.nonidentityCount](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L99)
- [PauliPrediction.nonidentitySecondMoment](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L111)
- [PauliPrediction.responseAbs](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L128)

## FQChem.Properties.ResponseAndEstimation.BellConfidence

```mermaid
flowchart LR
  n92["ElectronicStructurePauli.wordEntry_eq"]
  n634["clipped_error"]
  n635["hiddenMagnitude"]
  n636["meanFailure"]
  n637["predictMagnitude"]
  n638["projector_gram"]
  n639["score_mean"]
  n640["score_sign"]
  n641["selectHiddenWord"]
  n642["traceDifferent"]
  n643["weight_nonneg"]
  n644["weight_sum"]
  n646["BellSampling.magnitudeSquaredPauliExpectation"]
  n647["BellSampling.squaredPauliExpectation"]
  n654["PauliPrediction.hardStatePositive"]
  n655["PauliPrediction.hardStateTrace"]
  n656["PauliPrediction.hardStateTracePairing"]
  n663["PauliPrediction.pauliTrace"]
  n642 --> n635
  n654 -.-> n635
  n655 -.-> n635
  n656 --> n635
  n663 --> n635
  n639 --> n636
  n640 --> n636
  n643 -.-> n636
  n644 -.-> n636
  n634 --> n637
  n636 --> n637
  n643 -.-> n637
  n644 -.-> n637
  n640 --> n639
  n643 --> n639
  n644 -.-> n639
  n646 --> n639
  n635 --> n641
  n636 --> n641
  n643 -.-> n641
  n644 -.-> n641
  n654 -.-> n641
  n655 -.-> n641
  n638 --> n643
  n92 --> n644
  n647 --> n644
```

- [ElectronicStructurePauli.wordEntry_eq](../../FQChem/Complexity/ElectronicStructurePauli.lean#L42)
- [clipped_error](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L162) (private)
- [hiddenMagnitude](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L226)
- [meanFailure](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L110)
- [predictMagnitude](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L178)
- [projector_gram](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L36) (private)
- [score_mean](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L89)
- [score_sign](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L78) (private)
- [selectHiddenWord](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L244)
- [traceDifferent](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L200) (private)
- [weight_nonneg](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L43)
- [weight_sum](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L62)
- [BellSampling.magnitudeSquaredPauliExpectation](../../FQChem/Properties/ResponseAndEstimation/BellSampling.lean#L88)
- [BellSampling.squaredPauliExpectation](../../FQChem/Properties/ResponseAndEstimation/BellSampling.lean#L56)
- [PauliPrediction.hardStatePositive](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L167)
- [PauliPrediction.hardStateTrace](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L154)
- [PauliPrediction.hardStateTracePairing](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L160)
- [PauliPrediction.pauliTrace](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L53)

## FQChem.Properties.ResponseAndEstimation.BellSampling

```mermaid
flowchart LR
  n91["ElectronicStructurePauli.wordEntry_conj"]
  n645["bellResolution"]
  n646["magnitudeSquaredPauliExpectation"]
  n647["squaredPauliExpectation"]
  n91 --> n646
  n647 --> n646
  n645 --> n647
```

- [ElectronicStructurePauli.wordEntry_conj](../../FQChem/Complexity/ElectronicStructurePauli.lean#L48)
- [bellResolution](../../FQChem/Properties/ResponseAndEstimation/BellSampling.lean#L40)
- [magnitudeSquaredPauliExpectation](../../FQChem/Properties/ResponseAndEstimation/BellSampling.lean#L88)
- [squaredPauliExpectation](../../FQChem/Properties/ResponseAndEstimation/BellSampling.lean#L56)

## FQChem.Properties.ResponseAndEstimation.ClassicalShadows

```mermaid
flowchart LR
  n648["projector_sum"]
  n649["secondMoment"]
  n650["signed_projector_sum"]
  n651["unbiased"]
  n652["weighted_sum"]
  n648 --> n649
  n652 --> n649
  n650 --> n651
  n652 --> n651
```

- [projector_sum](../../FQChem/Properties/ResponseAndEstimation/ClassicalShadows.lean#L33) (private)
- [secondMoment](../../FQChem/Properties/ResponseAndEstimation/ClassicalShadows.lean#L91)
- [signed_projector_sum](../../FQChem/Properties/ResponseAndEstimation/ClassicalShadows.lean#L38) (private)
- [unbiased](../../FQChem/Properties/ResponseAndEstimation/ClassicalShadows.lean#L71)
- [weighted_sum](../../FQChem/Properties/ResponseAndEstimation/ClassicalShadows.lean#L56) (private)

## FQChem.Properties.ResponseAndEstimation.HellmannFeynman

```mermaid
flowchart LR
  n653["hellmannFeynman"]
```

- [hellmannFeynman](../../FQChem/Properties/ResponseAndEstimation/HellmannFeynman.lean#L39)

## FQChem.Properties.ResponseAndEstimation.PauliPrediction

```mermaid
flowchart LR
  n85["ElectronicStructurePauli.pauliCoefficient_real"]
  n87["ElectronicStructurePauli.pauliExpansion"]
  n91["ElectronicStructurePauli.wordEntry_conj"]
  n92["ElectronicStructurePauli.wordEntry_eq"]
  n573["OutOfTimeOrder.traceCoefficient"]
  n654["hardStatePositive"]
  n655["hardStateTrace"]
  n656["hardStateTracePairing"]
  n657["identityMatrix"]
  n658["nonidentityCount"]
  n659["nonidentitySecondMoment"]
  n660["parseval"]
  n661["pauliHermitian"]
  n662["pauliSquare"]
  n663["pauliTrace"]
  n664["purityBound"]
  n665["responseAbs"]
  n661 --> n654
  n662 --> n654
  n663 --> n655
  n662 --> n656
  n663 --> n656
  n92 --> n657
  n657 --> n659
  n660 --> n659
  n664 --> n659
  n85 --> n660
  n87 --> n660
  n573 --> n660
  n91 --> n661
  n661 --> n665
  n662 --> n665
```

- [ElectronicStructurePauli.pauliCoefficient_real](../../FQChem/Complexity/ElectronicStructurePauli.lean#L84)
- [ElectronicStructurePauli.pauliExpansion](../../FQChem/Complexity/ElectronicStructurePauli.lean#L67)
- [ElectronicStructurePauli.wordEntry_conj](../../FQChem/Complexity/ElectronicStructurePauli.lean#L48)
- [ElectronicStructurePauli.wordEntry_eq](../../FQChem/Complexity/ElectronicStructurePauli.lean#L42)
- [OutOfTimeOrder.traceCoefficient](../../FQChem/Dynamics/RealTimePropagation/OutOfTimeOrder.lean#L43)
- [hardStatePositive](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L167)
- [hardStateTrace](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L154)
- [hardStateTracePairing](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L160)
- [identityMatrix](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L32)
- [nonidentityCount](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L99)
- [nonidentitySecondMoment](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L111)
- [parseval](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L75) (private)
- [pauliHermitian](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L38)
- [pauliSquare](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L41)
- [pauliTrace](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L53)
- [purityBound](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L62) (private)
- [responseAbs](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L128)

## FQChem.Properties.ResponseAndEstimation.QuantumMemorySeparation

```mermaid
flowchart LR
  n632["AdaptivePauliPrediction.randomizedCopyLowerBound"]
  n635["BellConfidence.hiddenMagnitude"]
  n637["BellConfidence.predictMagnitude"]
  n643["BellConfidence.weight_nonneg"]
  n644["BellConfidence.weight_sum"]
  n654["PauliPrediction.hardStatePositive"]
  n655["PauliPrediction.hardStateTrace"]
  n666["separation"]
  n632 --> n666
  n635 --> n666
  n637 --> n666
  n643 -.-> n666
  n644 -.-> n666
  n654 -.-> n666
  n655 -.-> n666
```

- [AdaptivePauliPrediction.randomizedCopyLowerBound](../../FQChem/Properties/ResponseAndEstimation/AdaptivePauliPrediction.lean#L240)
- [BellConfidence.hiddenMagnitude](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L226)
- [BellConfidence.predictMagnitude](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L178)
- [BellConfidence.weight_nonneg](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L43)
- [BellConfidence.weight_sum](../../FQChem/Properties/ResponseAndEstimation/BellConfidence.lean#L62)
- [PauliPrediction.hardStatePositive](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L167)
- [PauliPrediction.hardStateTrace](../../FQChem/Properties/ResponseAndEstimation/PauliPrediction.lean#L154)
- [separation](../../FQChem/Properties/ResponseAndEstimation/QuantumMemorySeparation.lean#L30)

## FQChem.Properties.ResponseAndEstimation.ShadowConfidence

```mermaid
flowchart LR
  n667["blockChebyshev"]
  n668["blockFailure"]
  n669["blocks_pos"]
  n670["confidence"]
  n671["medianFailure"]
  n672["medianWitness"]
  n673["productDraw"]
  n674["simultaneousConfidence"]
  n667 --> n668
  n672 --> n671
  n668 --> n674
  n669 --> n674
  n670 --> n674
  n671 --> n674
```

- [blockChebyshev](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L69)
- [blockFailure](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L101) (private)
- [blocks_pos](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L181)
- [confidence](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L188) (private)
- [medianFailure](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L140) (private)
- [medianWitness](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L113) (private)
- [productDraw](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L39)
- [simultaneousConfidence](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L204)

## FQChem.Properties.ResponseAndEstimation.ShadowMeasurement

```mermaid
flowchart LR
  n669["ShadowConfidence.blocks_pos"]
  n673["ShadowConfidence.productDraw"]
  n674["ShadowConfidence.simultaneousConfidence"]
  n675["basisEntry"]
  n676["bornSecondMoment"]
  n677["centeredVariance"]
  n678["channelOne"]
  n679["channelSymmetric"]
  n680["hermitianScore"]
  n681["iidSampleComplexity"]
  n682["inverseHermitian"]
  n683["inverseSnapshotScore"]
  n684["moment_le"]
  n685["pairingAdjoint"]
  n686["pairingBound"]
  n687["pairingMeasurable"]
  n688["projectorHermitian"]
  n689["projectorMeasurable"]
  n690["sampleComplexity"]
  n691["scoreCentered"]
  n692["scoreLp"]
  n693["scoreMean"]
  n694["scoreMeasurable"]
  n695["sumProjector"]
  n696["traceProjector"]
  n696 --> n675
  n680 --> n676
  n686 --> n676
  n694 --> n676
  n684 --> n677
  n691 --> n677
  n692 --> n677
  n694 --> n677
  n695 --> n678
  n696 --> n678
  n682 --> n680
  n685 --> n680
  n688 --> n680
  n669 --> n681
  n673 --> n681
  n690 --> n681
  n685 --> n682
  n688 --> n682
  n679 --> n683
  n686 --> n684
  n692 --> n684
  n675 --> n686
  n689 --> n687
  n669 --> n690
  n674 --> n690
  n677 --> n690
  n692 --> n690
  n693 --> n690
  n694 --> n690
  n678 --> n691
  n696 --> n691
  n686 --> n692
  n694 --> n692
  n686 --> n693
  n687 --> n693
  n687 --> n694
```

- [ShadowConfidence.blocks_pos](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L181)
- [ShadowConfidence.productDraw](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L39)
- [ShadowConfidence.simultaneousConfidence](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L204)
- [basisEntry](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L69) (private)
- [bornSecondMoment](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L193)
- [centeredVariance](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L226)
- [channelOne](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L136) (private)
- [channelSymmetric](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L106) (private)
- [hermitianScore](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L185)
- [iidSampleComplexity](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L262)
- [inverseHermitian](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L120) (private)
- [inverseSnapshotScore](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L150)
- [moment_le](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L211) (private)
- [pairingAdjoint](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L112) (private)
- [pairingBound](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L94) (private)
- [pairingMeasurable](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L88) (private)
- [projectorHermitian](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L116) (private)
- [projectorMeasurable](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L80) (private)
- [sampleComplexity](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L242)
- [scoreCentered](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L179) (private)
- [scoreLp](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L158) (private)
- [scoreMean](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L163)
- [scoreMeasurable](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L155) (private)
- [sumProjector](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L63) (private)
- [traceProjector](../../FQChem/Properties/ResponseAndEstimation/ShadowMeasurement.lean#L58) (private)

## FQChem.Properties.ResponseAndEstimation.ShadowPrediction

```mermaid
flowchart LR
  n649["ClassicalShadows.secondMoment"]
  n651["ClassicalShadows.unbiased"]
  n667["ShadowConfidence.blockChebyshev"]
  n697["blockPrediction"]
  n698["estimate_real"]
  n699["median_failure"]
  n700["median_witness"]
  n701["predictionAtConfidence"]
  n702["simultaneousPrediction"]
  n649 --> n697
  n651 --> n697
  n667 --> n697
  n698 --> n697
  n700 --> n699
  n702 --> n701
  n697 --> n702
  n699 --> n702
```

- [ClassicalShadows.secondMoment](../../FQChem/Properties/ResponseAndEstimation/ClassicalShadows.lean#L91)
- [ClassicalShadows.unbiased](../../FQChem/Properties/ResponseAndEstimation/ClassicalShadows.lean#L71)
- [ShadowConfidence.blockChebyshev](../../FQChem/Properties/ResponseAndEstimation/ShadowConfidence.lean#L69)
- [blockPrediction](../../FQChem/Properties/ResponseAndEstimation/ShadowPrediction.lean#L71)
- [estimate_real](../../FQChem/Properties/ResponseAndEstimation/ShadowPrediction.lean#L63) (private)
- [median_failure](../../FQChem/Properties/ResponseAndEstimation/ShadowPrediction.lean#L128) (private)
- [median_witness](../../FQChem/Properties/ResponseAndEstimation/ShadowPrediction.lean#L97) (private)
- [predictionAtConfidence](../../FQChem/Properties/ResponseAndEstimation/ShadowPrediction.lean#L205)
- [simultaneousPrediction](../../FQChem/Properties/ResponseAndEstimation/ShadowPrediction.lean#L175)

## FQChem.Properties.ResponseAndEstimation.SpectralReconstruction

```mermaid
flowchart LR
  n703["spectralIdentification"]
```

- [spectralIdentification](../../FQChem/Properties/ResponseAndEstimation/SpectralReconstruction.lean#L21)

## FQChem.Properties.ResponseAndEstimation.VQEMeasurement

```mermaid
flowchart LR
  n704["energyReconstruction"]
  n705["finiteShotVQE"]
  n706["shotStatistics"]
  n704 --> n705
  n706 --> n705
```

- [energyReconstruction](../../FQChem/Properties/ResponseAndEstimation/VQEMeasurement.lean#L67)
- [finiteShotVQE](../../FQChem/Properties/ResponseAndEstimation/VQEMeasurement.lean#L115)
- [shotStatistics](../../FQChem/Properties/ResponseAndEstimation/VQEMeasurement.lean#L74)

## FQChem.StatePrep.AdiabaticPreparation.AdiabaticTheorem

```mermaid
flowchart LR
  n707["adiabaticIntertwining"]
  n708["gappedBandPreparation"]
  n709["gappedBandPreparation_limit"]
  n710["katoTransport"]
  n711["leakage_le_intertwining"]
  n712["projectionDerivative"]
  n713["reducedResolventPreparation"]
  n714["sandwichBound"]
  n715["transportedDerivative"]
  n714 --> n707
  n715 --> n707
  n707 --> n708
  n711 --> n708
  n712 --> n708
  n708 --> n709
  n712 --> n710
  n715 --> n710
  n707 --> n713
  n711 --> n713
  n712 --> n713
```

- [adiabaticIntertwining](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L135)
- [gappedBandPreparation](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L227)
- [gappedBandPreparation_limit](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L309)
- [katoTransport](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L186)
- [leakage_le_intertwining](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L213) (private)
- [projectionDerivative](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L174) (private)
- [reducedResolventPreparation](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L267)
- [sandwichBound](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L129)
- [transportedDerivative](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L119)

## FQChem.StatePrep.AdiabaticPreparation.ApproximateCommutator

```mermaid
flowchart LR
  n714["AdiabaticTheorem.sandwichBound"]
  n715["AdiabaticTheorem.transportedDerivative"]
  n716["approximateCommutatorTransport"]
  n717["interval_defect"]
  n717 --> n716
  n714 --> n717
  n715 --> n717
```

- [AdiabaticTheorem.sandwichBound](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L129)
- [AdiabaticTheorem.transportedDerivative](../../FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L119)
- [approximateCommutatorTransport](../../FQChem/StatePrep/AdiabaticPreparation/ApproximateCommutator.lean#L63)
- [interval_defect](../../FQChem/StatePrep/AdiabaticPreparation/ApproximateCommutator.lean#L22) (private)

## FQChem.StatePrep.AdiabaticPreparation.GaplessAdiabatic

```mermaid
flowchart LR
  n716["ApproximateCommutator.approximateCommutatorTransport"]
  n718["approximateSpectralCommutator"]
  n719["band_commutes"]
  n720["band_idempotent"]
  n721["band_selfAdjoint"]
  n722["comm_rankOne"]
  n723["gaplessAdiabatic"]
  n724["gaplessAdiabaticDistance"]
  n725["rankOne_comm_closure"]
  n726["star_comm_closure"]
  n720 --> n718
  n721 --> n718
  n725 --> n718
  n726 --> n718
  n722 --> n719
  n716 --> n723
  n718 --> n723
  n719 --> n723
  n720 --> n723
  n721 --> n723
  n723 --> n724
  n722 --> n725
```

- [ApproximateCommutator.approximateCommutatorTransport](../../FQChem/StatePrep/AdiabaticPreparation/ApproximateCommutator.lean#L63)
- [approximateSpectralCommutator](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L107)
- [band_commutes](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L65) (private)
- [band_idempotent](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L47) (private)
- [band_selfAdjoint](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L40) (private)
- [comm_rankOne](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L56) (private)
- [gaplessAdiabatic](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L143)
- [gaplessAdiabaticDistance](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L203)
- [rankOne_comm_closure](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L87) (private)
- [star_comm_closure](../../FQChem/StatePrep/AdiabaticPreparation/GaplessAdiabatic.lean#L78) (private)

## FQChem.StatePrep.AdiabaticPreparation.RydbergBlockade

```mermaid
flowchart LR
  n727["rydbergBlockade"]
```

- [rydbergBlockade](../../FQChem/StatePrep/AdiabaticPreparation/RydbergBlockade.lean#L28)

## FQChem.StatePrep.CircuitPreparation.AmplitudeAmplification

```mermaid
flowchart LR
  n728["inner_states"]
  n729["inverse_sqrt_queries"]
  n730["iterate_state"]
  n731["mark_state"]
  n732["project_state"]
  n733["rounded_success"]
  n734["state_normalized"]
  n735["step_rotates"]
  n736["success_law"]
  n733 --> n729
  n736 --> n729
  n735 --> n730
  n732 --> n731
  n736 --> n733
  n728 --> n734
  n728 --> n735
  n731 --> n735
  n730 --> n736
  n732 --> n736
```

- [inner_states](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L52) (private)
- [inverse_sqrt_queries](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L138)
- [iterate_state](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L98)
- [mark_state](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L70) (private)
- [project_state](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L46) (private)
- [rounded_success](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L117)
- [state_normalized](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L63)
- [step_rotates](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L77)
- [success_law](../../FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L110)

## FQChem.StatePrep.CircuitPreparation.ControlledRotations

```mermaid
flowchart LR
  n737["blockCount"]
  n738["normalized"]
  n739["preservesNorm"]
  n740["exactPreparation"]
  n741["preparePair_correct"]
  n742["radius_sq"]
  n743["registerCard"]
  n743 --> n737
  n739 --> n738
  n741 --> n740
  n742 --> n740
  n742 --> n741
```

- [blockCount](../../FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L113)
- [normalized](../../FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L87)
- [preservesNorm](../../FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L42)
- [exactPreparation](../../FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L122)
- [preparePair_correct](../../FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L64)
- [radius_sq](../../FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L54) (private)
- [registerCard](../../FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L107) (private)

## FQChem.StatePrep.CircuitPreparation.SlaterDeterminants

```mermaid
flowchart LR
  n744["coordinate_of_fixed"]
  n745["eliminateCoefficient"]
  n746["existsOrbitalUnitary"]
  n747["existsSlaterPreparation"]
  n748["existsTwoModeFactorization"]
  n749["existsTwoModeSlaterPreparation"]
  n750["exteriorGate_product"]
  n751["gateForPair"]
  n752["listProduct_fixed"]
  n753["occupationAmplitude"]
  n754["prepareVector"]
  n751 --> n745
  n746 --> n747
  n752 --> n748
  n754 --> n748
  n747 --> n749
  n748 --> n749
  n750 --> n749
  n744 --> n754
  n745 --> n754
  n751 --> n754
```

- [coordinate_of_fixed](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L89) (private)
- [eliminateCoefficient](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L131) (private)
- [existsOrbitalUnitary](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L39)
- [existsSlaterPreparation](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L60)
- [existsTwoModeFactorization](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L198)
- [existsTwoModeSlaterPreparation](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L248)
- [exteriorGate_product](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L236)
- [gateForPair](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L94) (private)
- [listProduct_fixed](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L188) (private)
- [occupationAmplitude](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L71)
- [prepareVector](../../FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L152) (private)

## FQChem.StatePrep.ImaginaryTimeProjection.AFQMC

```mermaid
flowchart LR
  n755["exactTrialLocalEnergy"]
  n756["fieldHistoryExpansion"]
  n757["freeProjection"]
  n758["hirschLattice"]
  n759["hirschLocal"]
  n760["hubbardFreeProjection"]
  n761["mixedEstimator"]
  n762["phaselessWeightLoss"]
  n763["projectedOverlap"]
  n764["realHirschParameter"]
  n765["slaterHistory"]
  n766["spinOrbitalFactorization"]
  n756 --> n757
  n765 --> n757
  n759 --> n758
  n756 --> n760
  n758 --> n760
  n757 --> n763
```

- [exactTrialLocalEnergy](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L176)
- [fieldHistoryExpansion](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L83)
- [freeProjection](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L139)
- [hirschLattice](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L68)
- [hirschLocal](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L44)
- [hubbardFreeProjection](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L103)
- [mixedEstimator](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L163)
- [phaselessWeightLoss](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L187)
- [projectedOverlap](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L148)
- [realHirschParameter](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L39)
- [slaterHistory](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L124)
- [spinOrbitalFactorization](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L58)

## FQChem.StatePrep.ImaginaryTimeProjection.CubicSpinGlass

```mermaid
flowchart LR
  n767["cubicBondCount"]
  n768["cubicDecision"]
  n799["FerromagneticComparison.bosonicDecisionEstimate"]
  n993["SignDecisionEstimator.statisticalDecision"]
  n767 --> n768
  n799 --> n768
  n993 --> n768
```

- [cubicBondCount](../../FQChem/StatePrep/ImaginaryTimeProjection/CubicSpinGlass.lean#L47)
- [cubicDecision](../../FQChem/StatePrep/ImaginaryTimeProjection/CubicSpinGlass.lean#L55)
- [FerromagneticComparison.bosonicDecisionEstimate](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticComparison.lean#L50)
- [SignDecisionEstimator.statisticalDecision](../../FQChem/StatePrep/ImaginaryTimeProjection/SignDecisionEstimator.lean#L38)

## FQChem.StatePrep.ImaginaryTimeProjection.DiffusionMonteCarlo

```mermaid
flowchart LR
  n769["branchingLocalEnergy"]
  n770["constantBranchingIff"]
  n771["exactFixedNode"]
  n772["exactGuideGroundEnergy"]
  n773["exactGuideStationarity"]
  n774["fixedNodeEqualityIff"]
  n775["fixedNodeShift"]
  n776["fixedNodeUpperBound"]
  n777["guidedFeynmanKac"]
  n778["penalty_nonneg"]
  n779["transitionMarkov"]
  n774 --> n771
  n776 --> n771
  n771 --> n772
  n779 --> n773
  n775 --> n774
  n778 --> n774
  n775 --> n776
  n778 --> n776
```

- [branchingLocalEnergy](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L95)
- [constantBranchingIff](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L68)
- [exactFixedNode](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L186)
- [exactGuideGroundEnergy](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L197)
- [exactGuideStationarity](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L75)
- [fixedNodeEqualityIff](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L153)
- [fixedNodeShift](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L132)
- [fixedNodeUpperBound](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L176)
- [guidedFeynmanKac](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L50)
- [penalty_nonneg](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L145) (private)
- [transitionMarkov](../../FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L32)

## FQChem.StatePrep.ImaginaryTimeProjection.FCIQMC

```mermaid
flowchart LR
  n780["annihilationPreserves"]
  n781["outcomeMass_nonneg"]
  n782["outcomeMass_sum"]
  n783["populationFirstMoment"]
  n784["populationMass_probability"]
  n785["productMarginal"]
  n786["roundedCounts"]
  n787["roundingFirstMoment"]
  n788["roundingMass_nonneg"]
  n789["roundingMass_sum"]
  n790["survivorsSignedCount"]
  n791["walkerFirstMoment"]
  n788 --> n781
  n789 --> n782
  n782 --> n783
  n785 --> n783
  n791 --> n783
  n781 --> n784
  n782 --> n784
  n780 --> n790
  n786 --> n791
```

- [annihilationPreserves](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L142)
- [outcomeMass_nonneg](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L81)
- [outcomeMass_sum](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L85)
- [populationFirstMoment](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L184)
- [populationMass_probability](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L174)
- [productMarginal](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L150) (private)
- [roundedCounts](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L94) (private)
- [roundingFirstMoment](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L39)
- [roundingMass_nonneg](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L30)
- [roundingMass_sum](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L35)
- [survivorsSignedCount](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L215)
- [walkerFirstMoment](../../FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L102)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticApproximation

```mermaid
flowchart LR
  n792["allTemperatureEnergy"]
  n793["burnInAccuracy"]
  n794["emptyEnergy"]
  n795["halving"]
  n796["infiniteTemperature"]
  n797["rateBudget"]
  n816["FerromagneticEnergySampling.energySamplingRMS"]
  n843["FerromagneticMixing.mixingDistance"]
  n886["FerromagneticReadout.tanhPositive"]
  n907["FerromagneticSubgraphs.boundary_empty"]
  n911["FerromagneticSubgraphs.energySectors"]
  n994["SignDecisionEstimator.thermalBound"]
  n793 --> n792
  n816 --> n792
  n795 --> n793
  n797 --> n793
  n843 --> n793
  n886 --> n793
  n994 --> n794
  n907 --> n796
  n911 --> n796
```

- [allTemperatureEnergy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticApproximation.lean#L89)
- [burnInAccuracy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticApproximation.lean#L54)
- [emptyEnergy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticApproximation.lean#L114)
- [halving](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticApproximation.lean#L26) (private)
- [infiniteTemperature](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticApproximation.lean#L121)
- [rateBudget](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticApproximation.lean#L33)
- [FerromagneticEnergySampling.energySamplingRMS](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L149)
- [FerromagneticMixing.mixingDistance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L154)
- [FerromagneticReadout.tanhPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L97)
- [FerromagneticSubgraphs.boundary_empty](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L25)
- [FerromagneticSubgraphs.energySectors](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L137)
- [SignDecisionEstimator.thermalBound](../../FQChem/StatePrep/ImaginaryTimeProjection/SignDecisionEstimator.lean#L21)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticComparison

```mermaid
flowchart LR
  n798["aligned_energy"]
  n799["bosonicDecisionEstimate"]
  n800["exponentBudget"]
  n801["ferromagneticGround"]
  n971["IsingSign.energy_bound"]
  n994["SignDecisionEstimator.thermalBound"]
  n1004["SpinGlassDecision.energyRange"]
  n1005["SpinGlassDecision.excitationEstimate"]
  n798 --> n799
  n800 --> n799
  n801 --> n799
  n994 --> n799
  n1004 --> n799
  n1005 --> n799
  n798 --> n801
  n971 --> n801
```

- [aligned_energy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticComparison.lean#L22)
- [bosonicDecisionEstimate](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticComparison.lean#L50)
- [exponentBudget](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticComparison.lean#L31) (private)
- [ferromagneticGround](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticComparison.lean#L26)
- [IsingSign.energy_bound](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L65)
- [SignDecisionEstimator.thermalBound](../../FQChem/StatePrep/ImaginaryTimeProjection/SignDecisionEstimator.lean#L21)
- [SpinGlassDecision.energyRange](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L95)
- [SpinGlassDecision.excitationEstimate](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L61)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticCongestion

```mermaid
flowchart LR
  n802["beforeSubset"]
  n803["cancelBoth"]
  n804["cancelRight"]
  n805["congestion"]
  n806["differenceSubset"]
  n807["encodedDifference"]
  n808["encodingInjective"]
  n809["routeSpec"]
  n864["FerromagneticPathWeights.weightComparison"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n932["FerromagneticTrails.canonicalOrdering"]
  n809 --> n802
  n932 -.-> n802
  n802 --> n805
  n806 --> n805
  n808 --> n805
  n809 --> n805
  n864 --> n805
  n893 --> n805
  n932 -.-> n805
  n802 -.-> n807
  n803 --> n807
  n806 -.-> n807
  n932 -.-> n807
  n802 -.-> n808
  n804 --> n808
  n806 -.-> n808
  n807 --> n808
  n932 -.-> n808
  n932 --> n809
```

- [beforeSubset](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L33)
- [cancelBoth](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L53) (private)
- [cancelRight](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L60) (private)
- [congestion](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L86)
- [differenceSubset](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L30)
- [encodedDifference](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L56) (private)
- [encodingInjective](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L63)
- [routeSpec](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L23)
- [FerromagneticPathWeights.weightComparison](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L72)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)
- [FerromagneticTrails.canonicalOrdering](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L115)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticDirichlet

```mermaid
flowchart LR
  n810["edgeGradient"]
  n811["edgePower"]
  n812["moveFloor"]
  n813["oddTransition"]
  n814["poincare"]
  n815["toggleComparison"]
  n854["FerromagneticPathComparison.flipSet"]
  n856["FerromagneticPathComparison.pathComparison"]
  n858["FerromagneticPathWeights.boundaryDifference"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n811 --> n812
  n813 --> n812
  n893 --> n812
  n854 --> n813
  n858 --> n813
  n815 --> n814
  n856 --> n814
  n893 --> n814
  n810 --> n815
  n812 --> n815
```

- [edgeGradient](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticDirichlet.lean#L60) (private)
- [edgePower](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticDirichlet.lean#L21) (private)
- [moveFloor](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticDirichlet.lean#L47)
- [oddTransition](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticDirichlet.lean#L29) (private)
- [poincare](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticDirichlet.lean#L88)
- [toggleComparison](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticDirichlet.lean#L65) (private)
- [FerromagneticPathComparison.flipSet](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathComparison.lean#L23)
- [FerromagneticPathComparison.pathComparison](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathComparison.lean#L94)
- [FerromagneticPathWeights.boundaryDifference](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L41)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticEnergySampling

```mermaid
flowchart LR
  n816["energySamplingRMS"]
  n817["fromEmptyProbability"]
  n818["lawMean"]
  n819["ratioEnergyMSE"]
  n820["ratioError"]
  n825["FerromagneticImportance.observationBounds"]
  n826["FerromagneticImportance.proposalMeans"]
  n836["FerromagneticMetropolis.kernelProbability"]
  n886["FerromagneticReadout.tanhPositive"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n898["FerromagneticSamples.batchError"]
  n902["FerromagneticSamples.expectationLinear"]
  n817 --> n816
  n819 --> n816
  n886 --> n816
  n898 --> n816
  n836 --> n817
  n818 --> n819
  n820 --> n819
  n825 --> n819
  n826 --> n819
  n886 --> n819
  n893 --> n819
  n902 --> n819
```

- [energySamplingRMS](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L149)
- [fromEmptyProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L30)
- [lawMean](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L21)
- [ratioEnergyMSE](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L85)
- [ratioError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L53)
- [FerromagneticImportance.observationBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L86)
- [FerromagneticImportance.proposalMeans](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L127)
- [FerromagneticMetropolis.kernelProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L71)
- [FerromagneticReadout.tanhPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L97)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)
- [FerromagneticSamples.batchError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L106)
- [FerromagneticSamples.expectationLinear](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L36)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticImportance

```mermaid
flowchart LR
  n821["allSubsets"]
  n822["boostCorrection"]
  n823["emptyLower"]
  n824["evenAtLeastTwo"]
  n825["observationBounds"]
  n826["proposalMeans"]
  n827["proposalRange"]
  n828["temperatureBoost"]
  n883["FerromagneticReadout.readoutBounds"]
  n886["FerromagneticReadout.tanhPositive"]
  n887["FerromagneticReadout.thermalReadout"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n894["FerromagneticRejection.evenAcceptance"]
  n907["FerromagneticSubgraphs.boundary_empty"]
  n912["FerromagneticSubgraphs.evenPositive"]
  n907 --> n823
  n824 --> n825
  n827 --> n825
  n883 --> n825
  n907 --> n825
  n822 --> n826
  n827 --> n826
  n828 --> n826
  n886 --> n826
  n887 --> n826
  n893 --> n826
  n894 --> n826
  n912 --> n826
  n821 --> n828
  n823 --> n828
```

- [allSubsets](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L44) (private)
- [boostCorrection](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L68) (private)
- [emptyLower](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L38) (private)
- [evenAtLeastTwo](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L74) (private)
- [observationBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L86)
- [proposalMeans](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L127)
- [proposalRange](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L33) (private)
- [temperatureBoost](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticImportance.lean#L50) (private)
- [FerromagneticReadout.readoutBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L111)
- [FerromagneticReadout.tanhPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L97)
- [FerromagneticReadout.thermalReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L103)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)
- [FerromagneticRejection.evenAcceptance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L49)
- [FerromagneticSubgraphs.boundary_empty](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L25)
- [FerromagneticSubgraphs.evenPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L128)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticMetropolis

```mermaid
flowchart LR
  n829["acceptanceBounds"]
  n830["detailedBalance"]
  n831["edgeBalance"]
  n832["edgeProbability"]
  n833["flipDifferent"]
  n834["flipTwice"]
  n835["kernelLazy"]
  n836["kernelProbability"]
  n837["stationary"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n831 --> n830
  n893 --> n830
  n833 --> n831
  n834 --> n831
  n829 --> n832
  n829 --> n835
  n833 --> n835
  n893 --> n835
  n832 --> n836
  n893 --> n836
  n830 --> n837
  n836 --> n837
```

- [acceptanceBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L41) (private)
- [detailedBalance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L104)
- [edgeBalance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L56) (private)
- [edgeProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L47) (private)
- [flipDifferent](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L30) (private)
- [flipTwice](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L26) (private)
- [kernelLazy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L90)
- [kernelProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L71)
- [stationary](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L116)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticMixing

```mermaid
flowchart LR
  n814["FerromagneticDirichlet.poincare"]
  n817["FerromagneticEnergySampling.fromEmptyProbability"]
  n830["FerromagneticMetropolis.detailedBalance"]
  n835["FerromagneticMetropolis.kernelLazy"]
  n836["FerromagneticMetropolis.kernelProbability"]
  n837["FerromagneticMetropolis.stationary"]
  n838["centered"]
  n839["contraction"]
  n840["densityStep"]
  n841["initialSquare"]
  n842["lawProbability"]
  n843["mixingDistance"]
  n844["pairMoment"]
  n845["totalPositive"]
  n846["weightSum"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n907["FerromagneticSubgraphs.boundary_empty"]
  n817 --> n838
  n842 --> n838
  n814 --> n839
  n835 --> n839
  n836 --> n839
  n837 --> n839
  n842 --> n839
  n844 --> n839
  n830 --> n840
  n836 --> n840
  n842 --> n840
  n842 --> n841
  n845 --> n841
  n907 --> n841
  n845 --> n842
  n846 --> n842
  n893 --> n842
  n838 --> n843
  n839 --> n843
  n840 --> n843
  n841 --> n843
  n842 --> n843
  n844 --> n843
  n893 --> n845
```

- [FerromagneticDirichlet.poincare](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticDirichlet.lean#L88)
- [FerromagneticEnergySampling.fromEmptyProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L30)
- [FerromagneticMetropolis.detailedBalance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L104)
- [FerromagneticMetropolis.kernelLazy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L90)
- [FerromagneticMetropolis.kernelProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L71)
- [FerromagneticMetropolis.stationary](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L116)
- [centered](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L101) (private)
- [contraction](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L45)
- [densityStep](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L108) (private)
- [initialSquare](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L126) (private)
- [lawProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L27)
- [mixingDistance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L154)
- [pairMoment](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L34) (private)
- [totalPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L24) (private)
- [weightSum](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L20) (private)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)
- [FerromagneticSubgraphs.boundary_empty](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L25)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticMonteCarlo

```mermaid
flowchart LR
  n767["CubicSpinGlass.cubicBondCount"]
  n793["FerromagneticApproximation.burnInAccuracy"]
  n797["FerromagneticApproximation.rateBudget"]
  n817["FerromagneticEnergySampling.fromEmptyProbability"]
  n819["FerromagneticEnergySampling.ratioEnergyMSE"]
  n836["FerromagneticMetropolis.kernelProbability"]
  n847["cubicPolynomialComparison"]
  n848["latticeBudget"]
  n849["polynomialComparison"]
  n850["singleChainEnergy"]
  n851["singleChainWork"]
  n852["trajectoryEnergyRMS"]
  n886["FerromagneticReadout.tanhPositive"]
  n942["FerromagneticTrajectory.trajectoryProbability"]
  n948["FerromagneticTrajectoryVariance.trajectoryError"]
  n767 --> n847
  n848 --> n847
  n849 --> n847
  n850 --> n849
  n851 --> n849
  n793 --> n850
  n797 --> n850
  n852 --> n850
  n886 --> n850
  n797 --> n852
  n817 --> n852
  n819 --> n852
  n836 --> n852
  n886 --> n852
  n942 --> n852
  n948 --> n852
```

- [CubicSpinGlass.cubicBondCount](../../FQChem/StatePrep/ImaginaryTimeProjection/CubicSpinGlass.lean#L47)
- [FerromagneticApproximation.burnInAccuracy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticApproximation.lean#L54)
- [FerromagneticApproximation.rateBudget](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticApproximation.lean#L33)
- [FerromagneticEnergySampling.fromEmptyProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L30)
- [FerromagneticEnergySampling.ratioEnergyMSE](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticEnergySampling.lean#L85)
- [FerromagneticMetropolis.kernelProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L71)
- [cubicPolynomialComparison](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMonteCarlo.lean#L170)
- [latticeBudget](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMonteCarlo.lean#L151) (private)
- [polynomialComparison](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMonteCarlo.lean#L116)
- [singleChainEnergy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMonteCarlo.lean#L57)
- [singleChainWork](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMonteCarlo.lean#L96)
- [trajectoryEnergyRMS](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMonteCarlo.lean#L21)
- [FerromagneticReadout.tanhPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L97)
- [FerromagneticTrajectory.trajectoryProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L29)
- [FerromagneticTrajectoryVariance.trajectoryError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectoryVariance.lean#L113)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticPathComparison

```mermaid
flowchart LR
  n802["FerromagneticCongestion.beforeSubset"]
  n805["FerromagneticCongestion.congestion"]
  n806["FerromagneticCongestion.differenceSubset"]
  n809["FerromagneticCongestion.routeSpec"]
  n853["endSet"]
  n854["flipSet"]
  n855["pathBound"]
  n856["pathComparison"]
  n857["telescope"]
  n862["FerromagneticPathWeights.toggleAbsent"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n932["FerromagneticTrails.canonicalOrdering"]
  n802 -.-> n855
  n806 --> n855
  n809 --> n855
  n853 --> n855
  n854 --> n855
  n857 --> n855
  n862 --> n855
  n932 -.-> n855
  n802 -.-> n856
  n805 --> n856
  n806 -.-> n856
  n855 --> n856
  n893 --> n856
  n932 -.-> n856
```

- [FerromagneticCongestion.beforeSubset](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L33)
- [FerromagneticCongestion.congestion](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L86)
- [FerromagneticCongestion.differenceSubset](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L30)
- [FerromagneticCongestion.routeSpec](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticCongestion.lean#L23)
- [endSet](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathComparison.lean#L34) (private)
- [flipSet](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathComparison.lean#L23)
- [pathBound](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathComparison.lean#L37) (private)
- [pathComparison](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathComparison.lean#L94)
- [telescope](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathComparison.lean#L27) (private)
- [FerromagneticPathWeights.toggleAbsent](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L23)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)
- [FerromagneticTrails.canonicalOrdering](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L115)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticPathWeights

```mermaid
flowchart LR
  n858["boundaryDifference"]
  n859["boundaryToggle"]
  n860["partitionCard"]
  n861["siteFactor"]
  n862["toggleAbsent"]
  n863["togglePresent"]
  n864["weightComparison"]
  n907["FerromagneticSubgraphs.boundary_empty"]
  n908["FerromagneticSubgraphs.boundary_insert"]
  n859 --> n858
  n862 --> n858
  n907 --> n858
  n862 --> n859
  n863 --> n859
  n908 --> n859
  n858 --> n864
  n860 --> n864
  n861 --> n864
```

- [boundaryDifference](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L41)
- [boundaryToggle](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L29) (private)
- [partitionCard](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L50) (private)
- [siteFactor](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L62) (private)
- [toggleAbsent](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L23)
- [togglePresent](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L26) (private)
- [weightComparison](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticPathWeights.lean#L72)
- [FerromagneticSubgraphs.boundary_empty](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L25)
- [FerromagneticSubgraphs.boundary_insert](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L27)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticRandomBits

```mermaid
flowchart LR
  n836["FerromagneticMetropolis.kernelProbability"]
  n865["acceptanceError"]
  n866["acceptedStrings"]
  n867["choiceSum"]
  n868["cutoffLe"]
  n869["finiteAcceptance"]
  n870["finiteStepError"]
  n871["finiteTrajectory"]
  n872["graphReadout"]
  n873["integerRatio"]
  n874["integerWeightSpec"]
  n875["kernelReadout"]
  n876["pairProbability"]
  n877["pairReadout"]
  n878["rowL1"]
  n879["trajectoryError"]
  n880["wordAverage"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n938["FerromagneticTrajectory.initialDrift"]
  n940["FerromagneticTrajectory.trajectoryCons"]
  n868 --> n866
  n865 --> n869
  n866 --> n869
  n873 --> n869
  n865 --> n870
  n866 --> n870
  n867 --> n870
  n868 --> n870
  n880 --> n870
  n836 --> n871
  n872 --> n871
  n876 --> n871
  n878 --> n871
  n879 --> n871
  n870 --> n872
  n873 --> n872
  n875 --> n872
  n877 --> n872
  n874 --> n873
  n893 --> n873
  n877 --> n876
  n938 --> n879
  n940 --> n879
```

- [FerromagneticMetropolis.kernelProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L71)
- [acceptanceError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L50)
- [acceptedStrings](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L30)
- [choiceSum](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L90) (private)
- [cutoffLe](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L24) (private)
- [finiteAcceptance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L230)
- [finiteStepError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L99)
- [finiteTrajectory](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L348)
- [graphReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L319)
- [integerRatio](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L211)
- [integerWeightSpec](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L188)
- [kernelReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L305)
- [pairProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L294)
- [pairReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L283)
- [rowL1](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L332)
- [trajectoryError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L246)
- [wordAverage](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L77)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)
- [FerromagneticTrajectory.initialDrift](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L68)
- [FerromagneticTrajectory.trajectoryCons](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L22)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticReadout

```mermaid
flowchart LR
  n881["edgeReadout"]
  n882["occupancyInsert"]
  n883["readoutBounds"]
  n884["sectorInsert"]
  n885["sumReadout"]
  n886["tanhPositive"]
  n887["thermalReadout"]
  n888["toggleBoundary"]
  n889["totalOccupancy"]
  n908["FerromagneticSubgraphs.boundary_insert"]
  n911["FerromagneticSubgraphs.energySectors"]
  n882 --> n881
  n884 --> n881
  n888 -.-> n882
  n908 --> n882
  n888 -.-> n884
  n908 --> n884
  n881 --> n885
  n889 --> n885
  n885 --> n887
  n886 --> n887
  n911 --> n887
```

- [edgeReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L59)
- [occupancyInsert](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L44) (private)
- [readoutBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L111)
- [sectorInsert](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L27) (private)
- [sumReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L84) (private)
- [tanhPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L97)
- [thermalReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L103)
- [toggleBoundary](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L21) (private)
- [totalOccupancy](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L73) (private)
- [FerromagneticSubgraphs.boundary_insert](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L27)
- [FerromagneticSubgraphs.energySectors](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L137)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticRejection

```mermaid
flowchart LR
  n886["FerromagneticReadout.tanhPositive"]
  n890["acceptanceMass"]
  n891["boostPositive"]
  n892["boostedExpansion"]
  n893["boostedWeightPositive"]
  n894["evenAcceptance"]
  n895["factorPositive"]
  n896["rejectionLaw"]
  n897["sumOddFactor"]
  n912["FerromagneticSubgraphs.evenPositive"]
  n915["FerromagneticSubgraphs.sectorDomination"]
  n893 --> n891
  n895 --> n893
  n886 --> n894
  n891 --> n894
  n892 --> n894
  n895 --> n894
  n897 --> n894
  n912 --> n894
  n915 --> n894
  n891 --> n896
```

- [FerromagneticReadout.tanhPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L97)
- [acceptanceMass](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L79)
- [boostPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L45) (private)
- [boostedExpansion](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L39) (private)
- [boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)
- [evenAcceptance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L49)
- [factorPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L31) (private)
- [rejectionLaw](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L70)
- [sumOddFactor](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L26) (private)
- [FerromagneticSubgraphs.evenPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L128)
- [FerromagneticSubgraphs.sectorDomination](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L118)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSamples

```mermaid
flowchart LR
  n898["batchError"]
  n899["batchNormalized"]
  n900["batchSucc"]
  n901["empiricalVariance"]
  n902["expectationLinear"]
  n903["expectedBounds"]
  n904["expectedDrift"]
  n905["secondMoment"]
  n899 --> n898
  n901 --> n898
  n902 --> n898
  n904 --> n898
  n903 --> n901
  n905 --> n901
  n900 --> n905
```

- [batchError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L106)
- [batchNormalized](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L30) (private)
- [batchSucc](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L24) (private)
- [empiricalVariance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L74) (private)
- [expectationLinear](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L36)
- [expectedBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L59)
- [expectedDrift](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L66)
- [secondMoment](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L40) (private)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs

```mermaid
flowchart LR
  n906["boltzmannExpansion"]
  n907["boundary_empty"]
  n908["boundary_insert"]
  n909["characterProduct"]
  n910["edgeFactor"]
  n911["energySectors"]
  n912["evenPositive"]
  n913["orthogonal"]
  n914["partitionExpansion"]
  n915["sectorDomination"]
  n916["transform"]
  n966["IsingSign.abs_character"]
  n977["IsingSign.thermal_identity"]
  n979["IsingSign.walsh_square"]
  n909 --> n906
  n910 --> n906
  n907 --> n909
  n908 --> n909
  n966 --> n910
  n914 --> n911
  n916 --> n911
  n977 --> n911
  n914 --> n912
  n979 --> n913
  n916 --> n914
  n914 --> n915
  n916 --> n915
  n966 --> n915
  n906 --> n916
  n913 --> n916
```

- [boltzmannExpansion](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L73) (private)
- [boundary_empty](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L25)
- [boundary_insert](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L27)
- [characterProduct](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L34) (private)
- [edgeFactor](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L61) (private)
- [energySectors](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L137)
- [evenPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L128)
- [orthogonal](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L44) (private)
- [partitionExpansion](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L112)
- [sectorDomination](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L118)
- [transform](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L86) (private)
- [IsingSign.abs_character](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L45)
- [IsingSign.thermal_identity](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L209)
- [IsingSign.walsh_square](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L148)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticThermalBits

```mermaid
flowchart LR
  n836["FerromagneticMetropolis.kernelProbability"]
  n872["FerromagneticRandomBits.graphReadout"]
  n875["FerromagneticRandomBits.kernelReadout"]
  n876["FerromagneticRandomBits.pairProbability"]
  n878["FerromagneticRandomBits.rowL1"]
  n879["FerromagneticRandomBits.trajectoryError"]
  n886["FerromagneticReadout.tanhPositive"]
  n893["FerromagneticRejection.boostedWeightPositive"]
  n917["boundedRatio"]
  n918["powerError"]
  n919["proposalAcceptance"]
  n920["scaleBudget"]
  n921["scaleSpec"]
  n922["thermalRow"]
  n923["thermalTrajectory"]
  n924["trajectoryWithProposal"]
  n925["weightRatio"]
  n893 --> n919
  n917 --> n919
  n918 --> n919
  n925 --> n919
  n875 --> n922
  n919 --> n922
  n921 --> n922
  n886 --> n923
  n924 --> n923
  n836 --> n924
  n872 --> n924
  n876 --> n924
  n878 --> n924
  n879 --> n924
  n886 --> n924
  n920 --> n924
  n922 --> n924
  n893 --> n925
```

- [FerromagneticMetropolis.kernelProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L71)
- [FerromagneticRandomBits.graphReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L319)
- [FerromagneticRandomBits.kernelReadout](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L305)
- [FerromagneticRandomBits.pairProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L294)
- [FerromagneticRandomBits.rowL1](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L332)
- [FerromagneticRandomBits.trajectoryError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRandomBits.lean#L246)
- [FerromagneticReadout.tanhPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticReadout.lean#L97)
- [FerromagneticRejection.boostedWeightPositive](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticRejection.lean#L36)
- [boundedRatio](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L35) (private)
- [powerError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L63) (private)
- [proposalAcceptance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L77)
- [scaleBudget](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L129) (private)
- [scaleSpec](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L103) (private)
- [thermalRow](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L106) (private)
- [thermalTrajectory](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L182)
- [trajectoryWithProposal](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L141)
- [weightRatio](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L20) (private)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticThermalParameter

```mermaid
flowchart LR
  n924["FerromagneticThermalBits.trajectoryWithProposal"]
  n926["computedThermalTrajectory"]
  n927["tailBound"]
  n928["tanhForm"]
  n929["thermalUpperSpec"]
  n924 --> n926
  n929 --> n926
  n927 --> n929
  n928 --> n929
```

- [FerromagneticThermalBits.trajectoryWithProposal](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalBits.lean#L141)
- [computedThermalTrajectory](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalParameter.lean#L111)
- [tailBound](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalParameter.lean#L25) (private)
- [tanhForm](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalParameter.lean#L56) (private)
- [thermalUpperSpec](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticThermalParameter.lean#L62)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticTrails

```mermaid
flowchart LR
  n907["FerromagneticSubgraphs.boundary_empty"]
  n908["FerromagneticSubgraphs.boundary_insert"]
  n930["boundaryQuiet"]
  n931["boundaryUnion"]
  n932["canonicalOrdering"]
  n933["joinEnds"]
  n934["maximalTrail"]
  n935["otherEnd"]
  n936["sameEnds"]
  n937["startingVertex"]
  n907 --> n930
  n908 --> n930
  n907 --> n931
  n908 --> n931
  n907 -.-> n932
  n930 -.-> n932
  n931 -.-> n932
  n934 -.-> n932
  n936 -.-> n932
  n937 -.-> n932
  n907 -.-> n934
  n908 -.-> n934
  n933 -.-> n934
  n935 -.-> n934
  n936 -.-> n934
  n930 --> n937
```

- [FerromagneticSubgraphs.boundary_empty](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L25)
- [FerromagneticSubgraphs.boundary_insert](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSubgraphs.lean#L27)
- [boundaryQuiet](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L47) (private)
- [boundaryUnion](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L38)
- [canonicalOrdering](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L115)
- [joinEnds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L23) (private)
- [maximalTrail](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L67) (private)
- [otherEnd](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L27) (private)
- [sameEnds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L22) (private)
- [startingVertex](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrails.lean#L101) (private)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticTrajectory

```mermaid
flowchart LR
  n837["FerromagneticMetropolis.stationary"]
  n903["FerromagneticSamples.expectedBounds"]
  n904["FerromagneticSamples.expectedDrift"]
  n938["initialDrift"]
  n939["stationaryMean"]
  n940["trajectoryCons"]
  n941["trajectoryMoment"]
  n942["trajectoryProbability"]
  n903 --> n938
  n904 --> n938
  n940 --> n938
  n942 --> n938
  n837 --> n939
  n940 --> n941
  n940 --> n942
```

- [FerromagneticMetropolis.stationary](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L116)
- [FerromagneticSamples.expectedBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L59)
- [FerromagneticSamples.expectedDrift](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L66)
- [initialDrift](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L68)
- [stationaryMean](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L82)
- [trajectoryCons](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L22)
- [trajectoryMoment](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L50)
- [trajectoryProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L29)

## FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticTrajectoryVariance

```mermaid
flowchart LR
  n836["FerromagneticMetropolis.kernelProbability"]
  n839["FerromagneticMixing.contraction"]
  n842["FerromagneticMixing.lawProbability"]
  n902["FerromagneticSamples.expectationLinear"]
  n903["FerromagneticSamples.expectedBounds"]
  n938["FerromagneticTrajectory.initialDrift"]
  n939["FerromagneticTrajectory.stationaryMean"]
  n941["FerromagneticTrajectory.trajectoryMoment"]
  n943["expectedMono"]
  n944["expectedScale"]
  n945["futureCentered"]
  n946["futureSumBound"]
  n947["futureVariance"]
  n948["trajectoryError"]
  n939 --> n945
  n839 --> n946
  n842 --> n946
  n902 --> n946
  n943 --> n946
  n944 --> n946
  n945 --> n946
  n839 --> n947
  n842 --> n947
  n902 --> n947
  n939 --> n947
  n943 --> n947
  n944 --> n947
  n945 --> n947
  n946 --> n947
  n836 --> n948
  n842 --> n948
  n903 --> n948
  n938 --> n948
  n941 --> n948
  n947 --> n948
```

- [FerromagneticMetropolis.kernelProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMetropolis.lean#L71)
- [FerromagneticMixing.contraction](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L45)
- [FerromagneticMixing.lawProbability](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticMixing.lean#L27)
- [FerromagneticSamples.expectationLinear](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L36)
- [FerromagneticSamples.expectedBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticSamples.lean#L59)
- [FerromagneticTrajectory.initialDrift](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L68)
- [FerromagneticTrajectory.stationaryMean](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L82)
- [FerromagneticTrajectory.trajectoryMoment](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectory.lean#L50)
- [expectedMono](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectoryVariance.lean#L24) (private)
- [expectedScale](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectoryVariance.lean#L18) (private)
- [futureCentered](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectoryVariance.lean#L27) (private)
- [futureSumBound](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectoryVariance.lean#L40)
- [futureVariance](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectoryVariance.lean#L76)
- [trajectoryError](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticTrajectoryVariance.lean#L113)

## FQChem.StatePrep.ImaginaryTimeProjection.GaussianAuxiliaryField

```mermaid
flowchart LR
  n949["gaussianHubbardStratonovich"]
  n950["gaussianPhaseAverage"]
  n950 --> n949
```

- [gaussianHubbardStratonovich](../../FQChem/StatePrep/ImaginaryTimeProjection/GaussianAuxiliaryField.lean#L46)
- [gaussianPhaseAverage](../../FQChem/StatePrep/ImaginaryTimeProjection/GaussianAuxiliaryField.lean#L34)

## FQChem.StatePrep.ImaginaryTimeProjection.GroundStateProjection

```mermaid
flowchart LR
  n951["bornWeight"]
  n952["boundTendstoZero"]
  n953["energyBound"]
  n954["energyLimit"]
  n955["excitedBound"]
  n956["excited_nonneg"]
  n957["infidelity"]
  n958["normalization"]
  n959["projectionBound"]
  n960["projectionLimit"]
  n961["total_pos"]
  n961 --> n951
  n951 --> n953
  n957 --> n953
  n959 --> n953
  n952 --> n954
  n953 --> n954
  n951 --> n957
  n961 --> n957
  n951 --> n958
  n961 --> n958
  n955 --> n959
  n956 --> n959
  n957 --> n959
  n961 --> n959
  n952 --> n960
  n959 --> n960
  n956 --> n961
```

- [bornWeight](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L78) (private)
- [boundTendstoZero](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L121) (private)
- [energyBound](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L139)
- [energyLimit](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L150)
- [excitedBound](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L95) (private)
- [excited_nonneg](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L72) (private)
- [infidelity](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L89) (private)
- [normalization](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L83)
- [projectionBound](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L106)
- [projectionLimit](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L132)
- [total_pos](../../FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L75) (private)

## FQChem.StatePrep.ImaginaryTimeProjection.HubbardProjection

```mermaid
flowchart LR
  n526["LieTrotter.lieTrotter"]
  n760["AFQMC.hubbardFreeProjection"]
  n962["hirschHistoryMean_eq_split"]
  n963["hirschHistoryMean_mulVec_tendsto"]
  n964["hirschHistoryMean_tendsto"]
  n965["interactionStep_eq_exp"]
  n760 --> n962
  n965 --> n962
  n964 --> n963
  n526 --> n964
  n962 --> n964
```

- [LieTrotter.lieTrotter](../../FQChem/Dynamics/DigitalAlgorithms/LieTrotter.lean#L73)
- [AFQMC.hubbardFreeProjection](../../FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L103)
- [hirschHistoryMean_eq_split](../../FQChem/StatePrep/ImaginaryTimeProjection/HubbardProjection.lean#L69)
- [hirschHistoryMean_mulVec_tendsto](../../FQChem/StatePrep/ImaginaryTimeProjection/HubbardProjection.lean#L93)
- [hirschHistoryMean_tendsto](../../FQChem/StatePrep/ImaginaryTimeProjection/HubbardProjection.lean#L78)
- [interactionStep_eq_exp](../../FQChem/StatePrep/ImaginaryTimeProjection/HubbardProjection.lean#L42)

## FQChem.StatePrep.ImaginaryTimeProjection.IsingSign

```mermaid
flowchart LR
  n966["abs_character"]
  n967["abs_kernel"]
  n968["absolute_path"]
  n969["character_exchange"]
  n970["character_pair"]
  n971["energy_bound"]
  n972["ferro_coupling"]
  n973["frustratedSquare"]
  n974["hamiltonian_conjugate"]
  n975["path_cast"]
  n976["pauliExpansion"]
  n977["thermal_identity"]
  n978["walsh_eigen"]
  n979["walsh_square"]
  n972 --> n967
  n967 --> n968
  n966 --> n971
  n968 --> n973
  n975 --> n973
  n978 --> n974
  n979 -.-> n974
  n974 --> n977
  n979 -.-> n977
  n969 --> n978
```

- [abs_character](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L45)
- [abs_kernel](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L90)
- [absolute_path](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L100)
- [character_exchange](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L139) (private)
- [character_pair](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L50)
- [energy_bound](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L65)
- [ferro_coupling](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L36)
- [frustratedSquare](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L130)
- [hamiltonian_conjugate](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L193)
- [path_cast](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L110) (private)
- [pauliExpansion](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L80)
- [thermal_identity](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L209)
- [walsh_eigen](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L167)
- [walsh_square](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L148)

## FQChem.StatePrep.ImaginaryTimeProjection.PhaseEstimationFilter

```mermaid
flowchart LR
  n980["branchWeight"]
  n981["branch_normalized"]
  n982["conditional_amplitudes"]
  n983["exact_grid_preparation"]
  n984["fidelity_eq"]
  n985["heralding_pos"]
  n986["heralding_probability"]
  n987["kernel_at_distinct_grid_phase"]
  n988["kernel_at_target"]
  n989["kernel_norm_le_one"]
  n990["kernel_suppression"]
  n991["leakage_nonneg"]
  n992["separated_preparation"]
  n985 --> n980
  n980 --> n981
  n985 --> n981
  n988 --> n982
  n984 --> n983
  n987 --> n983
  n980 --> n984
  n991 --> n985
  n985 --> n986
  n989 --> n986
  n984 --> n992
  n985 --> n992
  n990 --> n992
  n991 --> n992
```

- [branchWeight](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L88) (private)
- [branch_normalized](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L93)
- [conditional_amplitudes](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L71)
- [exact_grid_preparation](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L122)
- [fidelity_eq](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L99)
- [heralding_pos](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L85) (private)
- [heralding_probability](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L104)
- [kernel_at_distinct_grid_phase](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L28)
- [kernel_at_target](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L25)
- [kernel_norm_le_one](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L34)
- [kernel_suppression](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L41)
- [leakage_nonneg](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L82) (private)
- [separated_preparation](../../FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L137)

## FQChem.StatePrep.ImaginaryTimeProjection.SignDecisionEstimator

```mermaid
flowchart LR
  n971["IsingSign.energy_bound"]
  n977["IsingSign.thermal_identity"]
  n993["statisticalDecision"]
  n994["thermalBound"]
  n1009["SpinGlassDecision.polynomialTemperature"]
  n1011["SpinGlassDecision.thermalSeparation"]
  n994 --> n993
  n1009 --> n993
  n1011 --> n993
  n971 --> n994
  n977 --> n994
```

- [IsingSign.energy_bound](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L65)
- [IsingSign.thermal_identity](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L209)
- [statisticalDecision](../../FQChem/StatePrep/ImaginaryTimeProjection/SignDecisionEstimator.lean#L38)
- [thermalBound](../../FQChem/StatePrep/ImaginaryTimeProjection/SignDecisionEstimator.lean#L21)
- [SpinGlassDecision.polynomialTemperature](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L165)
- [SpinGlassDecision.thermalSeparation](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L127)

## FQChem.StatePrep.ImaginaryTimeProjection.SignProblem

```mermaid
flowchart LR
  n706["VQEMeasurement.shotStatistics"]
  n995["absMean_sign"]
  n996["abs_mul_sign"]
  n997["factorizedSign"]
  n998["productMeanSign"]
  n999["productSampleCost"]
  n1000["reweighting"]
  n1001["signStatistics"]
  n996 --> n995
  n997 --> n998
  n998 --> n999
  n1001 --> n999
  n996 --> n1000
  n706 --> n1001
  n995 --> n1001
```

- [VQEMeasurement.shotStatistics](../../FQChem/Properties/ResponseAndEstimation/VQEMeasurement.lean#L74)
- [absMean_sign](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L33)
- [abs_mul_sign](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L28) (private)
- [factorizedSign](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L48)
- [productMeanSign](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L56)
- [productSampleCost](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L96)
- [reweighting](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L38)
- [signStatistics](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L78)

## FQChem.StatePrep.ImaginaryTimeProjection.SpectralFiltering

```mermaid
flowchart LR
  n1002["geometricFiltering"]
```

- [geometricFiltering](../../FQChem/StatePrep/ImaginaryTimeProjection/SpectralFiltering.lean#L45)

## FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassDecision

```mermaid
flowchart LR
  n971["IsingSign.energy_bound"]
  n977["IsingSign.thermal_identity"]
  n1003["coldEnergy"]
  n1004["energyRange"]
  n1005["excitationEstimate"]
  n1006["minimum"]
  n1007["physicalScaling"]
  n1008["physicalSeparation"]
  n1009["polynomialTemperature"]
  n1010["shiftedThermal"]
  n1011["thermalSeparation"]
  n1012["weightSum"]
  n1004 --> n1003
  n1005 --> n1003
  n971 --> n1004
  n977 --> n1005
  n1010 --> n1005
  n1012 --> n1005
  n1007 --> n1008
  n1011 --> n1008
  n1012 --> n1010
  n1003 --> n1011
  n1006 --> n1011
```

- [IsingSign.energy_bound](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L65)
- [IsingSign.thermal_identity](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L209)
- [coldEnergy](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L102)
- [energyRange](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L95)
- [excitationEstimate](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L61)
- [minimum](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L20) (private)
- [physicalScaling](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L146)
- [physicalSeparation](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L152)
- [polynomialTemperature](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L165)
- [shiftedThermal](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L34)
- [thermalSeparation](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L127)
- [weightSum](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassDecision.lean#L27) (private)

## FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassFrustration

```mermaid
flowchart LR
  n968["IsingSign.absolute_path"]
  n1013["frustratedInstance"]
  n1014["pairParity"]
  n1015["rimCloses"]
  n1016["sixParity"]
  n1017["walkEnd"]
  n1018["walkWeight"]
  n1035["SpinGlassLatticeEncoding.bounds"]
  n1050["SpinGlassLatticeEncoding.signedCoupling"]
  n968 --> n1013
  n1015 --> n1013
  n1017 --> n1013
  n1018 --> n1013
  n1035 -.-> n1013
  n1050 --> n1013
  n1014 --> n1015
  n1016 --> n1015
  n1035 --> n1015
```

- [IsingSign.absolute_path](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L100)
- [frustratedInstance](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassFrustration.lean#L59)
- [pairParity](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassFrustration.lean#L35) (private)
- [rimCloses](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassFrustration.lean#L43) (private)
- [sixParity](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassFrustration.lean#L39) (private)
- [walkEnd](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassFrustration.lean#L21) (private)
- [walkWeight](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassFrustration.lean#L27) (private)
- [SpinGlassLatticeEncoding.bounds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L64)
- [SpinGlassLatticeEncoding.signedCoupling](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L152)

## FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassLatticeDecision

```mermaid
flowchart LR
  n767["CubicSpinGlass.cubicBondCount"]
  n799["FerromagneticComparison.bosonicDecisionEstimate"]
  n993["SignDecisionEstimator.statisticalDecision"]
  n1013["SpinGlassFrustration.frustratedInstance"]
  n1019["compactEq"]
  n1020["compiledComparison"]
  n1021["compiledThreshold"]
  n1022["compilerLength"]
  n1023["compilerSpecification"]
  n1024["decisionInstanceFrustrated"]
  n1025["firstOccurrenceSpec"]
  n1026["listComplete"]
  n1027["namePresent"]
  n1028["oracleWork"]
  n1029["pairMem"]
  n1030["renameEquivalence"]
  n1031["renamingComparisons"]
  n1032["signedEnergyDecidesThreeSAT"]
  n1033["siteCount"]
  n1035["SpinGlassLatticeEncoding.bounds"]
  n1037["SpinGlassLatticeEncoding.compiledBondCount"]
  n1038["SpinGlassLatticeEncoding.cubicThreshold"]
  n1050["SpinGlassLatticeEncoding.signedCoupling"]
  n1051["SpinGlassLatticeEncoding.sparseBonds"]
  n1081["SpinGlassThreeSAT.splitEquivalence"]
  n1025 -.-> n1019
  n1027 -.-> n1019
  n767 --> n1020
  n799 --> n1020
  n1022 --> n1020
  n1035 -.-> n1020
  n1022 --> n1021
  n1035 -.-> n1021
  n1037 --> n1021
  n1035 -.-> n1022
  n1037 --> n1022
  n1026 --> n1023
  n1035 -.-> n1023
  n1050 --> n1023
  n1051 --> n1023
  n1013 --> n1024
  n1025 -.-> n1024
  n1027 -.-> n1024
  n1035 -.-> n1024
  n1029 --> n1026
  n1033 --> n1028
  n1025 --> n1030
  n1027 -.-> n1030
  n1025 --> n1031
  n767 --> n1032
  n993 --> n1032
  n1019 --> n1032
  n1020 --> n1032
  n1021 --> n1032
  n1025 -.-> n1032
  n1027 -.-> n1032
  n1030 --> n1032
  n1035 -.-> n1032
  n1038 --> n1032
  n1081 --> n1032
```

- [CubicSpinGlass.cubicBondCount](../../FQChem/StatePrep/ImaginaryTimeProjection/CubicSpinGlass.lean#L47)
- [FerromagneticComparison.bosonicDecisionEstimate](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticComparison.lean#L50)
- [SignDecisionEstimator.statisticalDecision](../../FQChem/StatePrep/ImaginaryTimeProjection/SignDecisionEstimator.lean#L38)
- [SpinGlassFrustration.frustratedInstance](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassFrustration.lean#L59)
- [compactEq](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L77)
- [compiledComparison](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L143)
- [compiledThreshold](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L157)
- [compilerLength](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L132)
- [compilerSpecification](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L120)
- [decisionInstanceFrustrated](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L210)
- [firstOccurrenceSpec](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L35)
- [listComplete](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L107)
- [namePresent](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L24) (private)
- [oracleWork](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L166)
- [pairMem](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L94) (private)
- [renameEquivalence](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L53)
- [renamingComparisons](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L86)
- [signedEnergyDecidesThreeSAT](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L183)
- [siteCount](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeDecision.lean#L152)
- [SpinGlassLatticeEncoding.bounds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L64)
- [SpinGlassLatticeEncoding.compiledBondCount](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L148)
- [SpinGlassLatticeEncoding.cubicThreshold](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L187)
- [SpinGlassLatticeEncoding.signedCoupling](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L152)
- [SpinGlassLatticeEncoding.sparseBonds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L132)
- [SpinGlassThreeSAT.splitEquivalence](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassThreeSAT.lean#L44)

## FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassLatticeEncoding

```mermaid
flowchart LR
  n970["IsingSign.character_pair"]
  n1034["asSite_asGrid"]
  n1035["bounds"]
  n1036["colInjective"]
  n1037["compiledBondCount"]
  n1038["cubicThreshold"]
  n1039["finiteEnergy"]
  n1040["forwardStep"]
  n1041["indexedNe"]
  n1042["maskUnique"]
  n1043["neverReverse"]
  n1044["orderedEdge"]
  n1045["permitted"]
  n1046["positionInjective"]
  n1047["restrictExtend"]
  n1048["rimBounds"]
  n1049["rimInjective"]
  n1050["signedCoupling"]
  n1051["sparseBonds"]
  n1052["stepNe"]
  n1053["wireBounds"]
  n1054["wireInjective"]
  n1058["SpinGlassLatticeGadgets.latticeThreshold"]
  n1071["SpinGlassSatisfiability.bondCharacter"]
  n1079["SpinGlassSatisfiability.maskUnordered"]
  n1048 --> n1035
  n1053 --> n1035
  n1035 -.-> n1037
  n1042 --> n1037
  n1051 --> n1037
  n1035 -.-> n1038
  n1039 --> n1038
  n1047 --> n1038
  n1058 --> n1038
  n970 --> n1039
  n1035 --> n1039
  n1041 --> n1039
  n1042 --> n1039
  n1050 --> n1039
  n1051 --> n1039
  n1071 --> n1039
  n1035 --> n1041
  n1052 --> n1041
  n1035 --> n1042
  n1041 --> n1042
  n1043 --> n1042
  n1044 --> n1042
  n1046 --> n1042
  n1079 --> n1042
  n1035 --> n1045
  n1040 --> n1045
  n1052 --> n1045
  n1049 --> n1046
  n1054 --> n1046
  n1035 -.-> n1050
  n1042 --> n1050
  n1051 --> n1050
  n1035 --> n1051
  n1040 --> n1051
  n1045 --> n1051
  n1036 --> n1054
```

- [IsingSign.character_pair](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L50)
- [asSite_asGrid](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L75) (private)
- [bounds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L64)
- [colInjective](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L18) (private)
- [compiledBondCount](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L148)
- [cubicThreshold](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L187)
- [finiteEnergy](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L161)
- [forwardStep](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L82) (private)
- [indexedNe](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L105) (private)
- [maskUnique](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L109) (private)
- [neverReverse](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L97) (private)
- [orderedEdge](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L92) (private)
- [permitted](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L127) (private)
- [positionInjective](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L39) (private)
- [restrictExtend](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L177) (private)
- [rimBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L60) (private)
- [rimInjective](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L34) (private)
- [signedCoupling](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L152)
- [sparseBonds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L132)
- [stepNe](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L88) (private)
- [wireBounds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L55) (private)
- [wireInjective](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeEncoding.lean#L25) (private)
- [SpinGlassLatticeGadgets.latticeThreshold](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L178)
- [SpinGlassSatisfiability.bondCharacter](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L93)
- [SpinGlassSatisfiability.maskUnordered](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L56)

## FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassLatticeGadgets

```mermaid
flowchart LR
  n1055["columnAgreement"]
  n1056["cycleMinimum"]
  n1057["decodedLiteral"]
  n1058["latticeThreshold"]
  n1059["liftedBase"]
  n1060["liftedOccurrence"]
  n1061["liftedReturn"]
  n1062["optimal"]
  n1063["rimFormula"]
  n1064["rowAgreement"]
  n1065["wireMinimum"]
  n1065 --> n1055
  n1055 --> n1057
  n1064 --> n1057
  n1065 --> n1057
  n1056 --> n1058
  n1057 --> n1058
  n1059 --> n1058
  n1060 --> n1058
  n1061 --> n1058
  n1062 --> n1058
  n1063 --> n1058
  n1056 --> n1062
  n1063 --> n1062
  n1065 --> n1062
  n1065 --> n1064
```

- [columnAgreement](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L132) (private)
- [cycleMinimum](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L85) (private)
- [decodedLiteral](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L145) (private)
- [latticeThreshold](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L178)
- [liftedBase](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L162) (private)
- [liftedOccurrence](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L165) (private)
- [liftedReturn](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L171) (private)
- [optimal](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L93) (private)
- [rimFormula](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L79) (private)
- [rowAgreement](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L119) (private)
- [wireMinimum](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassLatticeGadgets.lean#L90) (private)

## FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassPaths

```mermaid
flowchart LR
  n968["IsingSign.absolute_path"]
  n995["SignProblem.absMean_sign"]
  n1000["SignProblem.reweighting"]
  n1066["kernelPaths"]
  n1067["taylorAbsolute"]
  n1068["taylorPartition"]
  n1069["taylorReweighting"]
  n1070["taylorTrace"]
  n968 --> n1067
  n1070 --> n1068
  n995 --> n1069
  n1000 --> n1069
  n1067 --> n1069
  n1066 --> n1070
```

- [IsingSign.absolute_path](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L100)
- [SignProblem.absMean_sign](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L33)
- [SignProblem.reweighting](../../FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L38)
- [kernelPaths](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassPaths.lean#L22)
- [taylorAbsolute](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassPaths.lean#L72)
- [taylorPartition](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassPaths.lean#L51)
- [taylorReweighting](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassPaths.lean#L82)
- [taylorTrace](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassPaths.lean#L43)

## FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassSatisfiability

```mermaid
flowchart LR
  n970["IsingSign.character_pair"]
  n1071["bondCharacter"]
  n1072["clauseMinimum"]
  n1073["coupling"]
  n1074["distinctEnds"]
  n1075["edgeCount"]
  n1076["energyDecomposition"]
  n1077["literalBond"]
  n1078["maskInjective"]
  n1079["maskUnordered"]
  n1080["thresholdEquivalence"]
  n1074 -.-> n1073
  n1078 --> n1073
  n1074 -.-> n1075
  n1078 --> n1075
  n970 --> n1076
  n1071 --> n1076
  n1073 --> n1076
  n1074 --> n1076
  n1077 --> n1076
  n1078 --> n1076
  n1074 --> n1078
  n1079 --> n1078
  n1072 --> n1080
  n1074 -.-> n1080
  n1076 --> n1080
```

- [IsingSign.character_pair](../../FQChem/StatePrep/ImaginaryTimeProjection/IsingSign.lean#L50)
- [bondCharacter](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L93)
- [clauseMinimum](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L101)
- [coupling](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L82) (private)
- [distinctEnds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L52) (private)
- [edgeCount](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L77)
- [energyDecomposition](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L111)
- [literalBond](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L97) (private)
- [maskInjective](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L62) (private)
- [maskUnordered](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L56)
- [thresholdEquivalence](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L127)

## FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassThreeSAT

```mermaid
flowchart LR
  n799["FerromagneticComparison.bosonicDecisionEstimate"]
  n993["SignDecisionEstimator.statisticalDecision"]
  n1074["SpinGlassSatisfiability.distinctEnds"]
  n1075["SpinGlassSatisfiability.edgeCount"]
  n1080["SpinGlassSatisfiability.thresholdEquivalence"]
  n1081["splitEquivalence"]
  n1082["splitTest"]
  n1083["splitWitness"]
  n1084["switchLiteral"]
  n1085["threeSATEnergyDecision"]
  n1086["threeSATThreshold"]
  n1082 --> n1081
  n1083 --> n1081
  n1084 --> n1081
  n799 --> n1085
  n993 --> n1085
  n1074 -.-> n1085
  n1086 --> n1085
  n1074 -.-> n1086
  n1075 --> n1086
  n1080 --> n1086
  n1081 --> n1086
```

- [FerromagneticComparison.bosonicDecisionEstimate](../../FQChem/StatePrep/ImaginaryTimeProjection/FerromagneticComparison.lean#L50)
- [SignDecisionEstimator.statisticalDecision](../../FQChem/StatePrep/ImaginaryTimeProjection/SignDecisionEstimator.lean#L38)
- [SpinGlassSatisfiability.distinctEnds](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L52) (private)
- [SpinGlassSatisfiability.edgeCount](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L77)
- [SpinGlassSatisfiability.thresholdEquivalence](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassSatisfiability.lean#L127)
- [splitEquivalence](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassThreeSAT.lean#L44)
- [splitTest](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassThreeSAT.lean#L34) (private)
- [splitWitness](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassThreeSAT.lean#L39) (private)
- [switchLiteral](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassThreeSAT.lean#L42) (private)
- [threeSATEnergyDecision](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassThreeSAT.lean#L85)
- [threeSATThreshold](../../FQChem/StatePrep/ImaginaryTimeProjection/SpinGlassThreeSAT.lean#L74)

## FQChem.StatePrep.PerturbationTheory.CoupledCluster

```mermaid
flowchart LR
  n1087["coupledCluster"]
  n1088["expClusterInverse"]
  n1088 --> n1087
```

- [coupledCluster](../../FQChem/StatePrep/PerturbationTheory/CoupledCluster.lean#L27)
- [expClusterInverse](../../FQChem/StatePrep/PerturbationTheory/CoupledCluster.lean#L17)

## FQChem.StatePrep.PerturbationTheory.CoupledClusterReplicas

```mermaid
flowchart LR
  n1088["CoupledCluster.expClusterInverse"]
  n1089["expRight"]
  n1090["expSeparated"]
  n1091["groundCopies"]
  n1092["groundSeparated"]
  n1093["projectedCopies"]
  n1094["projectedSeparated"]
  n1095["replicaScaling"]
  n1096["tensorAction"]
  n1097["transformedSeparated"]
  n1089 --> n1090
  n1092 --> n1091
  n1096 --> n1092
  n1094 --> n1093
  n1097 --> n1094
  n1091 --> n1095
  n1093 --> n1095
  n1088 --> n1097
  n1090 --> n1097
```

- [CoupledCluster.expClusterInverse](../../FQChem/StatePrep/PerturbationTheory/CoupledCluster.lean#L17)
- [expRight](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L29) (private)
- [expSeparated](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L46)
- [groundCopies](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L154)
- [groundSeparated](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L100)
- [projectedCopies](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L147)
- [projectedSeparated](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L75)
- [replicaScaling](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L173)
- [tensorAction](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L87) (private)
- [transformedSeparated](../../FQChem/StatePrep/PerturbationTheory/CoupledClusterReplicas.lean#L61)

## FQChem.StatePrep.PerturbationTheory.IndependentOrbitals

```mermaid
flowchart LR
  n1098["fill_spec"]
  n1099["filled_eq"]
  n1100["fillingConsecutiveBinding"]
  n1101["fillingConvex"]
  n1102["fillingGround"]
  n1103["filling_minimum"]
  n1104["polynomialWork"]
  n1105["repulsiveLowerBound"]
  n1106["twoElectronConvexity"]
  n1101 --> n1100
  n1099 --> n1102
  n1103 --> n1102
  n1098 --> n1104
  n1099 --> n1104
  n1102 --> n1104
  n1102 --> n1105
  n1101 --> n1106
  n1105 --> n1106
```

- [fill_spec](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L139)
- [filled_eq](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L33) (private)
- [fillingConsecutiveBinding](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L98)
- [fillingConvex](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L92)
- [fillingGround](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L69)
- [filling_minimum](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L38) (private)
- [polynomialWork](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L159)
- [repulsiveLowerBound](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L105)
- [twoElectronConvexity](../../FQChem/StatePrep/PerturbationTheory/IndependentOrbitals.lean#L125)

## FQChem.StatePrep.PerturbationTheory.Multireference

```mermaid
flowchart LR
  n1107["mrpt2Shift"]
```

- [mrpt2Shift](../../FQChem/StatePrep/PerturbationTheory/Multireference.lean#L17)

## FQChem.StatePrep.PerturbationTheory.RayleighSchrodinger

```mermaid
flowchart LR
  n1108["gap_ne_zero"]
  n1109["nondegenerateExpansion"]
  n1110["residualIdentity_of_coefficients"]
  n1111["secondOrderQuasimode"]
  n1112["shift_sum"]
  n1108 --> n1109
  n1112 --> n1109
  n1109 --> n1111
  n1110 --> n1111
```

- [gap_ne_zero](../../FQChem/StatePrep/PerturbationTheory/RayleighSchrodinger.lean#L81) (private)
- [nondegenerateExpansion](../../FQChem/StatePrep/PerturbationTheory/RayleighSchrodinger.lean#L95)
- [residualIdentity_of_coefficients](../../FQChem/StatePrep/PerturbationTheory/RayleighSchrodinger.lean#L144)
- [secondOrderQuasimode](../../FQChem/StatePrep/PerturbationTheory/RayleighSchrodinger.lean#L165)
- [shift_sum](../../FQChem/StatePrep/PerturbationTheory/RayleighSchrodinger.lean#L85) (private)

## FQChem.StatePrep.PerturbationTheory.TruncationScaling

```mermaid
flowchart LR
  n1113["fixedRankBoundsDoNotGiveJointPolynomial"]
```

- [fixedRankBoundsDoNotGiveJointPolynomial](../../FQChem/StatePrep/PerturbationTheory/TruncationScaling.lean#L21)

## FQChem.StatePrep.SubspaceDiagonalization.ConfigurationInteraction

```mermaid
flowchart LR
  n1114["sampledDiagonalization"]
  n1115["selectedCI"]
  n1158["RayleighRitz.basisEnlargement"]
  n1162["RayleighRitz.ritzEnergy_le"]
  n1158 --> n1114
  n1162 --> n1114
  n1158 --> n1115
```

- [sampledDiagonalization](../../FQChem/StatePrep/SubspaceDiagonalization/ConfigurationInteraction.lean#L33)
- [selectedCI](../../FQChem/StatePrep/SubspaceDiagonalization/ConfigurationInteraction.lean#L27)
- [RayleighRitz.basisEnlargement](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L65)
- [RayleighRitz.ritzEnergy_le](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L54)

## FQChem.StatePrep.SubspaceDiagonalization.Interlacing

```mermaid
flowchart LR
  n1116["ritzInterlacing"]
  n1117["spectral_lower"]
  n1118["spectral_upper"]
  n1119["spectral_witness"]
  n1157["GapCertificate.spectralExpectation"]
  n1117 --> n1116
  n1118 --> n1116
  n1119 --> n1116
  n1157 --> n1117
  n1157 --> n1118
```

- [ritzInterlacing](../../FQChem/StatePrep/SubspaceDiagonalization/Interlacing.lean#L97)
- [spectral_lower](../../FQChem/StatePrep/SubspaceDiagonalization/Interlacing.lean#L73) (private)
- [spectral_upper](../../FQChem/StatePrep/SubspaceDiagonalization/Interlacing.lean#L85) (private)
- [spectral_witness](../../FQChem/StatePrep/SubspaceDiagonalization/Interlacing.lean#L48) (private)
- [GapCertificate.spectralExpectation](../../FQChem/StatePrep/VariationalOptimization/GapCertificate.lean#L38)

## FQChem.StatePrep.SubspaceDiagonalization.Krylov

```mermaid
flowchart LR
  n1120["classicalKrylov"]
  n1121["orbit_step"]
  n1122["quantumKrylov"]
  n1158["RayleighRitz.basisEnlargement"]
  n1121 --> n1120
  n1158 --> n1121
  n1121 --> n1122
```

- [classicalKrylov](../../FQChem/StatePrep/SubspaceDiagonalization/Krylov.lean#L32)
- [orbit_step](../../FQChem/StatePrep/SubspaceDiagonalization/Krylov.lean#L26) (private)
- [quantumKrylov](../../FQChem/StatePrep/SubspaceDiagonalization/Krylov.lean#L35)
- [RayleighRitz.basisEnlargement](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L65)

## FQChem.StatePrep.SubspaceDiagonalization.RitzGalerkin

```mermaid
flowchart LR
  n1123["residualCriterion"]
```

- [residualCriterion](../../FQChem/StatePrep/SubspaceDiagonalization/RitzGalerkin.lean#L32)

## FQChem.StatePrep.VariationalOptimization.DensityFunctionals.Continuum

```mermaid
flowchart LR
  n1124["commonStateConstantLift"]
  n1125["energy_le_functional_add"]
  n1126["energy_le_trial"]
  n1127["euler_lagrange"]
  n1128["functional_le_internal"]
  n1129["groundDensityExactness"]
  n1130["h0_expand"]
  n1131["hohenbergKohn"]
  n1132["integral_expand"]
  n1133["ip_expand"]
  n1134["liebVariationalPrinciple"]
  n1135["lin_coeff_zero"]
  n1136["pf_expand"]
  n1137["strong_hk_of_ucp"]
  n1138["universalFunctionalExists"]
  n1139["weak_hk"]
  n1127 --> n1124
  n1130 --> n1127
  n1133 --> n1127
  n1135 --> n1127
  n1136 --> n1127
  n1126 --> n1128
  n1126 --> n1129
  n1128 --> n1129
  n1137 --> n1131
  n1139 --> n1131
  n1132 --> n1133
  n1125 --> n1134
  n1128 --> n1134
  n1132 --> n1136
  n1124 --> n1137
  n1134 --> n1138
```

- [commonStateConstantLift](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L214)
- [energy_le_functional_add](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L261) (private)
- [energy_le_trial](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L258) (private)
- [euler_lagrange](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L173)
- [functional_le_internal](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L266) (private)
- [groundDensityExactness](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L288)
- [h0_expand](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L162)
- [hohenbergKohn](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L254)
- [integral_expand](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L130)
- [ip_expand](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L149)
- [liebVariationalPrinciple](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L273)
- [lin_coeff_zero](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L119) (private)
- [pf_expand](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L157)
- [strong_hk_of_ucp](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L246)
- [universalFunctionalExists](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L285)
- [weak_hk](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L194)

## FQChem.StatePrep.VariationalOptimization.DensityFunctionals.CoulombIntegrability

```mermaid
flowchart LR
  n1140["coulombConstrainedSearch"]
  n1141["coulombLocallyIntegrable"]
  n1142["locallyIntegrable_coordinate"]
  n1143["nuclearAttractionIntegrable"]
  n1145["MolecularConstrainedSearch.constrainedSearch"]
  n1143 --> n1140
  n1145 --> n1140
  n1141 --> n1143
  n1142 --> n1143
```

- [coulombConstrainedSearch](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/CoulombIntegrability.lean#L88)
- [coulombLocallyIntegrable](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/CoulombIntegrability.lean#L38)
- [locallyIntegrable_coordinate](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/CoulombIntegrability.lean#L54) (private)
- [nuclearAttractionIntegrable](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/CoulombIntegrability.lean#L70)
- [MolecularConstrainedSearch.constrainedSearch](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularConstrainedSearch.lean#L104)

## FQChem.StatePrep.VariationalOptimization.DensityFunctionals.MolecularConstrainedSearch

```mermaid
flowchart LR
  n1144["born_mass"]
  n1145["constrainedSearch"]
  n1146["density_mass"]
  n1147["density_pairing"]
  n1148["molecularConstrainedSearch"]
  n1147 --> n1145
  n1144 --> n1146
  n1145 --> n1148
```

- [born_mass](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularConstrainedSearch.lean#L81)
- [constrainedSearch](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularConstrainedSearch.lean#L104)
- [density_mass](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularConstrainedSearch.lean#L89)
- [density_pairing](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularConstrainedSearch.lean#L94)
- [molecularConstrainedSearch](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularConstrainedSearch.lean#L127)

## FQChem.StatePrep.VariationalOptimization.DensityFunctionals.MolecularHohenbergKohn

```mermaid
flowchart LR
  n1124["Continuum.commonStateConstantLift"]
  n1139["Continuum.weak_hk"]
  n1149["molecularHohenbergKohn"]
  n1150["oneBodyRigidity"]
  n1124 --> n1149
  n1139 --> n1149
  n1150 --> n1149
```

- [Continuum.commonStateConstantLift](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L214)
- [Continuum.weak_hk](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L194)
- [molecularHohenbergKohn](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularHohenbergKohn.lean#L84)
- [oneBodyRigidity](../../FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularHohenbergKohn.lean#L66)

## FQChem.StatePrep.VariationalOptimization.ExcitedStates

```mermaid
flowchart LR
  n1151["excitedStateBound"]
  n1152["quantumDeflation"]
  n1153["weighted_bound"]
  n1153 --> n1151
  n1153 --> n1152
```

- [excitedStateBound](../../FQChem/StatePrep/VariationalOptimization/ExcitedStates.lean#L31)
- [quantumDeflation](../../FQChem/StatePrep/VariationalOptimization/ExcitedStates.lean#L39)
- [weighted_bound](../../FQChem/StatePrep/VariationalOptimization/ExcitedStates.lean#L26) (private)

## FQChem.StatePrep.VariationalOptimization.FermionicAnsatz

```mermaid
flowchart LR
  n1154["neuralAntisymmetry"]
  n1155["slaterTrialBound"]
  n1162["RayleighRitz.ritzEnergy_le"]
  n1162 --> n1155
```

- [neuralAntisymmetry](../../FQChem/StatePrep/VariationalOptimization/FermionicAnsatz.lean#L54)
- [slaterTrialBound](../../FQChem/StatePrep/VariationalOptimization/FermionicAnsatz.lean#L47)
- [RayleighRitz.ritzEnergy_le](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L54)

## FQChem.StatePrep.VariationalOptimization.GapCertificate

```mermaid
flowchart LR
  n1156["gapCertificate"]
  n1157["spectralExpectation"]
  n1157 --> n1156
```

- [gapCertificate](../../FQChem/StatePrep/VariationalOptimization/GapCertificate.lean#L48)
- [spectralExpectation](../../FQChem/StatePrep/VariationalOptimization/GapCertificate.lean#L38)

## FQChem.StatePrep.VariationalOptimization.RayleighRitz

```mermaid
flowchart LR
  n1158["basisEnlargement"]
  n1159["groundEnergyPrinciple"]
  n1160["groundEnergy_le"]
  n1161["rayleigh_bddBelow"]
  n1162["ritzEnergy_le"]
  n1160 --> n1158
  n1161 --> n1158
  n1160 --> n1159
  n1161 --> n1160
  n1161 --> n1162
```

- [basisEnlargement](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L65)
- [groundEnergyPrinciple](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L59)
- [groundEnergy_le](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L49)
- [rayleigh_bddBelow](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L42) (private)
- [ritzEnergy_le](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L54)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitMeasurement

```mermaid
flowchart LR
  n1163["final_measurement"]
  n1164["final_width"]
  n1165["measurement_work"]
  n1166["readout_scratch"]
  n1167["total_space"]
  n1171["CircuitReadout.readout_exact"]
  n1172["CircuitReadout.readout_work"]
  n1175["CircuitSimulation.left_le_width"]
  n1176["CircuitSimulation.simulate_exact"]
  n1177["CircuitSimulation.simulate_work"]
  n1178["CircuitSimulation.stored_le"]
  n1263["Storage.simulate_space"]
  n1171 --> n1163
  n1176 --> n1163
  n1164 --> n1165
  n1172 --> n1165
  n1177 --> n1165
  n1175 --> n1166
  n1164 --> n1167
  n1166 --> n1167
  n1178 --> n1167
  n1263 --> n1167
```

- [final_measurement](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitMeasurement.lean#L19)
- [final_width](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitMeasurement.lean#L30)
- [measurement_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitMeasurement.lean#L38)
- [readout_scratch](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitMeasurement.lean#L52)
- [total_space](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitMeasurement.lean#L73)
- [CircuitReadout.readout_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitReadout.lean#L87)
- [CircuitReadout.readout_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitReadout.lean#L112)
- [CircuitSimulation.left_le_width](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L41)
- [CircuitSimulation.simulate_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L142)
- [CircuitSimulation.simulate_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L157)
- [CircuitSimulation.stored_le](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L48)
- [Storage.simulate_space](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/Storage.lean#L73)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitReadout

```mermaid
flowchart LR
  n1168["localTransfer_eq"]
  n1169["mulTable_eq"]
  n1170["pattern_bits"]
  n1171["readout_exact"]
  n1172["readout_work"]
  n1175["CircuitSimulation.left_le_width"]
  n1228["RankRevealing.table_apply"]
  n1169 --> n1168
  n1228 --> n1168
  n1228 --> n1169
  n1168 --> n1171
  n1175 --> n1172
```

- [localTransfer_eq](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitReadout.lean#L73)
- [mulTable_eq](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitReadout.lean#L60)
- [pattern_bits](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitReadout.lean#L45)
- [readout_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitReadout.lean#L87)
- [readout_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitReadout.lean#L112)
- [CircuitSimulation.left_le_width](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L41)
- [RankRevealing.table_apply](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L52)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitSimulation

```mermaid
flowchart LR
  n1173["advance_exact"]
  n1174["advance_work"]
  n1175["left_le_width"]
  n1176["simulate_exact"]
  n1177["simulate_work"]
  n1178["stored_le"]
  n1181["CircuitUpdate.pair_entry"]
  n1182["CircuitUpdate.pair_work"]
  n1181 --> n1173
  n1175 --> n1174
  n1182 --> n1174
  n1173 --> n1176
  n1174 --> n1177
  n1175 --> n1178
```

- [advance_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L81)
- [advance_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L118)
- [left_le_width](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L41)
- [simulate_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L142)
- [simulate_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L157)
- [stored_le](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L48)
- [CircuitUpdate.pair_entry](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L91)
- [CircuitUpdate.pair_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L110)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitUpdate

```mermaid
flowchart LR
  n1179["newBond"]
  n1180["oneSite_amplitude"]
  n1181["pair_entry"]
  n1182["pair_work"]
  n1183["physicalBond"]
  n1184["theta_entry"]
  n1221["RankRevealing.factor_matrix"]
  n1222["RankRevealing.factor_minimal"]
  n1224["RankRevealing.factor_work"]
  n1228["RankRevealing.table_apply"]
  n1222 --> n1179
  n1228 --> n1180
  n1184 --> n1181
  n1221 --> n1181
  n1228 --> n1181
  n1224 --> n1182
  n1179 --> n1183
  n1228 --> n1184
```

- [newBond](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L87)
- [oneSite_amplitude](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L29)
- [pair_entry](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L91)
- [pair_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L110)
- [physicalBond](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L122)
- [theta_entry](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L61)
- [RankRevealing.factor_matrix](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L154)
- [RankRevealing.factor_minimal](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L168)
- [RankRevealing.factor_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L179)
- [RankRevealing.table_apply](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L52)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.DMRG

```mermaid
flowchart LR
  n1159["RayleighRitz.groundEnergyPrinciple"]
  n1185["canonicalUpdate"]
  n1186["effective_symmetric"]
  n1187["energy_identity"]
  n1188["environmentMap_apply"]
  n1189["oneSiteUpdate"]
  n1159 --> n1185
  n1186 --> n1185
  n1187 --> n1185
  n1187 --> n1189
```

- [RayleighRitz.groundEnergyPrinciple](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L59)
- [canonicalUpdate](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/DMRG.lean#L100)
- [effective_symmetric](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/DMRG.lean#L93) (private)
- [energy_identity](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/DMRG.lean#L80)
- [environmentMap_apply](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/DMRG.lean#L68)
- [oneSiteUpdate](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/DMRG.lean#L86)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.GateRouting

```mermaid
flowchart LR
  n1190["coverage"]
  n1191["exact"]
  n1192["exact_window"]
  n1193["gate_count"]
  n1194["exchange_twice"]
  n1195["input_eq"]
  n1196["invertible"]
  n1197["swap_act"]
  n1198["at_gap"]
  n1199["exact_window"]
  n1200["hops_le"]
  n1201["exact"]
  n1202["gate_count"]
  n1203["invertible"]
  n1204["lift_hops"]
  n1205["lift_window"]
  n1206["dense_append"]
  n1207["swap_inverse"]
  n1198 --> n1190
  n1192 --> n1191
  n1201 --> n1191
  n1199 --> n1192
  n1205 --> n1192
  n1200 --> n1193
  n1202 --> n1193
  n1204 --> n1193
  n1205 --> n1199
  n1204 --> n1200
  n1195 --> n1201
  n1197 --> n1201
  n1206 --> n1201
  n1196 --> n1203
  n1207 --> n1203
```

- [coverage](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L213)
- [exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L236)
- [exact_window](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L183)
- [gate_count](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L189)
- [exchange_twice](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L62)
- [input_eq](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L56)
- [invertible](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L49)
- [swap_act](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L67)
- [at_gap](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L204)
- [exact_window](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L154)
- [hops_le](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L165)
- [exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L133)
- [gate_count](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L109)
- [invertible](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L115)
- [lift_hops](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L104)
- [lift_window](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L90)
- [dense_append](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L127)
- [swap_inverse](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L41)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.MatrixProductStates

```mermaid
flowchart LR
  n1208["exactCutFactorization"]
  n1209["mpsCutBound"]
```

- [exactCutFactorization](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MatrixProductStates.lean#L41)
- [mpsCutBound](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MatrixProductStates.lean#L30)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.MinimalBonds

```mermaid
flowchart LR
  n1179["CircuitUpdate.newBond"]
  n1181["CircuitUpdate.pair_entry"]
  n1184["CircuitUpdate.theta_entry"]
  n1210["advance_full"]
  n1211["fullPair"]
  n1212["injective_of_rank"]
  n1213["innerFull"]
  n1214["left_of_rank"]
  n1215["recover_slices"]
  n1216["right_of_rank"]
  n1217["slice_update"]
  n1211 --> n1210
  n1213 --> n1211
  n1215 --> n1211
  n1179 --> n1213
  n1181 --> n1213
  n1184 --> n1213
  n1214 --> n1213
  n1216 --> n1213
  n1212 --> n1214
  n1217 --> n1215
  n1212 --> n1216
  n1181 --> n1217
```

- [CircuitUpdate.newBond](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L87)
- [CircuitUpdate.pair_entry](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L91)
- [CircuitUpdate.theta_entry](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L61)
- [advance_full](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L126)
- [fullPair](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L93)
- [injective_of_rank](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L32) (private)
- [innerFull](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L69)
- [left_of_rank](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L41) (private)
- [recover_slices](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L84) (private)
- [right_of_rank](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L51) (private)
- [slice_update](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L61)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.RankRevealing

```mermaid
flowchart LR
  n1218["expand_succ"]
  n1219["expand_zero"]
  n1220["factor_exact"]
  n1221["factor_matrix"]
  n1222["factor_minimal"]
  n1223["factor_rank"]
  n1224["factor_work"]
  n1225["pivot_none"]
  n1226["pivot_nonzero"]
  n1227["residual_rank"]
  n1228["table_apply"]
  n1218 --> n1220
  n1219 --> n1220
  n1225 --> n1220
  n1228 --> n1220
  n1220 --> n1221
  n1221 --> n1222
  n1223 --> n1222
  n1226 --> n1223
  n1227 --> n1223
  n1228 --> n1227
```

- [expand_succ](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L40) (private)
- [expand_zero](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L35) (private)
- [factor_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L98)
- [factor_matrix](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L154)
- [factor_minimal](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L168)
- [factor_rank](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L140)
- [factor_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L179)
- [pivot_none](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L89) (private)
- [pivot_nonzero](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L84) (private)
- [residual_rank](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L118) (private)
- [table_apply](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L52)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.RoutedSimulation

```mermaid
flowchart LR
  n1191["GateRouting.exact"]
  n1193["GateRouting.gate_count"]
  n1194["GateRouting.exchange_twice"]
  n1197["GateRouting.swap_act"]
  n1203["GateRouting.invertible"]
  n1206["GateRouting.dense_append"]
  n1229["physical"]
  n1230["swap"]
  n1231["exchange_digit"]
  n1232["index_involutive"]
  n1233["trajectory"]
  n1234["compile_exact"]
  n1235["compile_invertible"]
  n1236["compile_length"]
  n1237["compile_trajectory"]
  n1238["digit_tabulate"]
  n1239["promised_first"]
  n1240["tabulate_digit"]
  n1241["trajectory_append"]
  n1240 --> n1229
  n1197 --> n1230
  n1231 --> n1230
  n1232 -.-> n1230
  n1238 --> n1230
  n1240 --> n1230
  n1194 --> n1233
  n1197 --> n1233
  n1206 --> n1233
  n1229 --> n1233
  n1230 --> n1233
  n1241 --> n1233
  n1191 --> n1234
  n1206 --> n1234
  n1203 --> n1235
  n1193 --> n1236
  n1191 --> n1237
  n1229 --> n1237
  n1233 --> n1237
  n1239 --> n1237
  n1241 --> n1237
```

- [GateRouting.exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L236)
- [GateRouting.gate_count](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L189)
- [GateRouting.exchange_twice](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L62)
- [GateRouting.swap_act](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L67)
- [GateRouting.invertible](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L115)
- [GateRouting.dense_append](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/GateRouting.lean#L127)
- [physical](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L67)
- [swap](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L70)
- [exchange_digit](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L49)
- [index_involutive](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L41)
- [trajectory](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L90)
- [compile_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L129)
- [compile_invertible](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L146)
- [compile_length](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L137)
- [compile_trajectory](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L153)
- [digit_tabulate](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L25)
- [promised_first](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L123)
- [tabulate_digit](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L31)
- [trajectory_append](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L81)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.SchmidtSimulation

```mermaid
flowchart LR
  n1173["CircuitSimulation.advance_exact"]
  n1176["CircuitSimulation.simulate_exact"]
  n1177["CircuitSimulation.simulate_work"]
  n1210["MinimalBonds.advance_full"]
  n1242["current_cut"]
  n1243["frame_injective"]
  n1244["front_dim"]
  n1245["initialWidth"]
  n1246["product_amplitude"]
  n1247["product_full"]
  n1248["rank_of_kernel"]
  n1249["schmidtCircuit"]
  n1250["suffix_injective"]
  n1251["suffix_rank"]
  n1252["trajectory_width"]
  n1253["width_of_cuts"]
  n1242 --> n1244
  n1248 --> n1244
  n1251 --> n1244
  n1253 --> n1245
  n1176 --> n1249
  n1177 --> n1249
  n1247 --> n1249
  n1252 --> n1249
  n1248 --> n1251
  n1250 --> n1251
  n1173 --> n1252
  n1210 --> n1252
  n1245 --> n1252
  n1243 --> n1253
  n1244 --> n1253
```

- [CircuitSimulation.advance_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L81)
- [CircuitSimulation.simulate_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L142)
- [CircuitSimulation.simulate_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L157)
- [MinimalBonds.advance_full](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/MinimalBonds.lean#L126)
- [current_cut](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L72) (private)
- [frame_injective](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L61) (private)
- [front_dim](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L79) (private)
- [initialWidth](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L115) (private)
- [product_amplitude](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L151)
- [product_full](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L161)
- [rank_of_kernel](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L21) (private)
- [schmidtCircuit](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L183)
- [suffix_injective](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L33) (private)
- [suffix_rank](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L46) (private)
- [trajectory_width](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L127)
- [width_of_cuts](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L93)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.SingleSiteGates

```mermaid
flowchart LR
  n1228["RankRevealing.table_apply"]
  n1254["encoded_exact"]
  n1255["encoded_inverse"]
  n1256["embedLeft_act"]
  n1257["embedRight_act"]
  n1258["oneWire"]
  n1259["oneWireCircuit"]
  n1256 --> n1254
  n1257 --> n1254
  n1228 --> n1259
```

- [RankRevealing.table_apply](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RankRevealing.lean#L52)
- [encoded_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L74)
- [encoded_inverse](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L93)
- [embedLeft_act](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L61) (private)
- [embedRight_act](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L67) (private)
- [oneWire](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L31)
- [oneWireCircuit](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L43)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.Storage

```mermaid
flowchart LR
  n1175["CircuitSimulation.left_le_width"]
  n1178["CircuitSimulation.stored_le"]
  n1179["CircuitUpdate.newBond"]
  n1260["elimination_space"]
  n1261["gate_space"]
  n1262["pair_space"]
  n1263["simulate_space"]
  n1175 --> n1261
  n1262 --> n1261
  n1179 --> n1262
  n1260 --> n1262
  n1178 --> n1263
  n1261 --> n1263
```

- [CircuitSimulation.left_le_width](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L41)
- [CircuitSimulation.stored_le](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitSimulation.lean#L48)
- [CircuitUpdate.newBond](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitUpdate.lean#L87)
- [elimination_space](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/Storage.lean#L23)
- [gate_space](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/Storage.lean#L57) (private)
- [pair_space](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/Storage.lean#L37)
- [simulate_space](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/Storage.lean#L73)

## FQChem.StatePrep.VariationalOptimization.TensorNetworks.VidalSimulation

```mermaid
flowchart LR
  n1163["CircuitMeasurement.final_measurement"]
  n1165["CircuitMeasurement.measurement_work"]
  n1167["CircuitMeasurement.total_space"]
  n1234["RoutedSimulation.compile_exact"]
  n1235["RoutedSimulation.compile_invertible"]
  n1236["RoutedSimulation.compile_length"]
  n1237["RoutedSimulation.compile_trajectory"]
  n1249["SchmidtSimulation.schmidtCircuit"]
  n1254["SingleSiteGates.encoded_exact"]
  n1255["SingleSiteGates.encoded_inverse"]
  n1259["SingleSiteGates.oneWireCircuit"]
  n1264["encode_exact"]
  n1265["encode_invertible"]
  n1266["chainMeasurement_spec"]
  n1267["encode_promise"]
  n1268["encode_reference"]
  n1269["oneMatrix_act"]
  n1270["oneState_spec"]
  n1271["vidal_simulation"]
  n1254 --> n1264
  n1255 --> n1265
  n1163 --> n1266
  n1165 --> n1266
  n1167 --> n1266
  n1234 --> n1266
  n1235 --> n1266
  n1236 --> n1266
  n1237 --> n1266
  n1249 --> n1266
  n1265 --> n1266
  n1267 --> n1266
  n1268 --> n1266
  n1264 --> n1267
  n1264 --> n1268
  n1259 --> n1270
  n1269 --> n1270
  n1266 --> n1271
  n1270 --> n1271
```

- [CircuitMeasurement.final_measurement](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitMeasurement.lean#L19)
- [CircuitMeasurement.measurement_work](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitMeasurement.lean#L38)
- [CircuitMeasurement.total_space](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/CircuitMeasurement.lean#L73)
- [RoutedSimulation.compile_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L129)
- [RoutedSimulation.compile_invertible](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L146)
- [RoutedSimulation.compile_length](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L137)
- [RoutedSimulation.compile_trajectory](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/RoutedSimulation.lean#L153)
- [SchmidtSimulation.schmidtCircuit](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SchmidtSimulation.lean#L183)
- [SingleSiteGates.encoded_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L74)
- [SingleSiteGates.encoded_inverse](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L93)
- [SingleSiteGates.oneWireCircuit](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/SingleSiteGates.lean#L43)
- [encode_exact](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/VidalSimulation.lean#L37)
- [encode_invertible](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/VidalSimulation.lean#L43)
- [chainMeasurement_spec](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/VidalSimulation.lean#L93)
- [encode_promise](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/VidalSimulation.lean#L66)
- [encode_reference](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/VidalSimulation.lean#L57)
- [oneMatrix_act](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/VidalSimulation.lean#L121) (private)
- [oneState_spec](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/VidalSimulation.lean#L131) (private)
- [vidal_simulation](../../FQChem/StatePrep/VariationalOptimization/TensorNetworks/VidalSimulation.lean#L160)

## FQChem.StatePrep.VariationalOptimization.VQE

```mermaid
flowchart LR
  n1160["RayleighRitz.groundEnergy_le"]
  n1272["reachableVQEMinimum"]
  n1273["vqe"]
  n1273 --> n1272
  n1160 --> n1273
```

- [RayleighRitz.groundEnergy_le](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L49)
- [reachableVQEMinimum](../../FQChem/StatePrep/VariationalOptimization/VQE.lean#L38)
- [vqe](../../FQChem/StatePrep/VariationalOptimization/VQE.lean#L28)

## FQChem.StatePrep.VariationalOptimization.VariationalMonteCarlo

```mermaid
flowchart LR
  n1159["RayleighRitz.groundEnergyPrinciple"]
  n1274["variationalMonteCarlo"]
  n1275["acceptedFlow"]
  n1276["bornMean"]
  n1277["bornStationary"]
  n1278["detailedBalance"]
  n1279["eigenstateZeroVariance"]
  n1280["energyGradient"]
  n1281["residualDecomposition"]
  n1282["rowSum"]
  n1283["stationary"]
  n1284["sum_weight"]
  n1285["transitionNonnegative"]
  n1286["variationalBound"]
  n1287["zeroVarianceIff"]
  n1282 --> n1277
  n1283 --> n1277
  n1284 --> n1277
  n1285 --> n1277
  n1275 --> n1278
  n1287 --> n1279
  n1278 --> n1283
  n1282 --> n1283
  n1159 --> n1286
  n1276 --> n1286
  n1281 --> n1287
```

- [RayleighRitz.groundEnergyPrinciple](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L59)
- [variationalMonteCarlo](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L38)
- [acceptedFlow](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L141) (private)
- [bornMean](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L66)
- [bornStationary](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L186)
- [detailedBalance](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L147)
- [eigenstateZeroVariance](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L123)
- [energyGradient](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L209)
- [residualDecomposition](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L95)
- [rowSum](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L155)
- [stationary](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L180)
- [sum_weight](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L60)
- [transitionNonnegative](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L160)
- [variationalBound](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L77)
- [zeroVarianceIff](../../FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L110)

## FQChemForShor.CompiledSampling

```mermaid
flowchart LR
  n1288["mass_pos"]
  n1289["normalized"]
  n1390["Workspace.workspace"]
  n1391["Denote.denote_unitary"]
  n1393["Measure.proj_mul_apply"]
  n1394["Basis.mToNat_lt"]
  n1390 -.-> n1288
  n1390 -.-> n1289
  n1391 --> n1289
  n1393 --> n1289
  n1394 --> n1289
```

- [mass_pos](../../integrations/forshor/FQChemForShor/CompiledSampling.lean#L39)
- [normalized](../../integrations/forshor/FQChemForShor/CompiledSampling.lean#L12)
- [Workspace.workspace](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Workspace.lean#L793)
- [Denote.denote_unitary](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Model/QuantumLib/Denote.lean#L491)
- [Measure.proj_mul_apply](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Model/QuantumLib/Measure.lean#L37)
- [Basis.mToNat_lt](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Model/Standard/Basis.lean#L177)

## FQChemForShor.FactoringLaw

```mermaid
flowchart LR
  n110["FactoringPreprocessing.preprocess_miss"]
  n112["FactoringPreprocessing.preprocess_sound"]
  n121["FactoringRecursion.pair"]
  n125["FactoringRecursion.certify_some"]
  n131["FactoringRecursion.recursiveFactorization"]
  n139["FactoringReduction.extractFactor_nonunit"]
  n141["FactoringReduction.extractFactor_sound"]
  n1288["CompiledSampling.mass_pos"]
  n1289["CompiledSampling.normalized"]
  n1290["baseLaw_certified"]
  n1291["compositeShot"]
  n1292["drawLaw_certified"]
  n1293["input_ext"]
  n1294["primeFactorization"]
  n1295["unitLaw_certified"]
  n1296["unitLaw_success"]
  n1297["wordBounds"]
  n1351["QuantumFactoring.positiveBaseFactorProbability"]
  n1378["Correctness.κ_pos"]
  n1390["Workspace.workspace"]
  n125 --> n1290
  n139 --> n1290
  n141 --> n1290
  n1288 -.-> n1290
  n1289 -.-> n1290
  n1293 --> n1290
  n1295 --> n1290
  n1390 -.-> n1290
  n110 --> n1291
  n112 --> n1291
  n125 --> n1291
  n1288 -.-> n1291
  n1289 -.-> n1291
  n1292 --> n1291
  n1378 --> n1291
  n1390 -.-> n1291
  n1288 -.-> n1292
  n1289 -.-> n1292
  n1290 --> n1292
  n1297 --> n1292
  n1351 --> n1292
  n1378 --> n1292
  n1390 -.-> n1292
  n121 -.-> n1294
  n131 --> n1294
  n1288 -.-> n1294
  n1289 -.-> n1294
  n1291 --> n1294
  n1297 -.-> n1294
  n1390 -.-> n1294
  n141 --> n1295
  n1288 -.-> n1295
  n1289 -.-> n1295
  n1296 --> n1295
  n1390 -.-> n1295
  n1288 -.-> n1296
  n1289 -.-> n1296
  n1390 -.-> n1296
```

- [FactoringPreprocessing.preprocess_miss](../../FQChem/Complexity/FactoringPreprocessing.lean#L139)
- [FactoringPreprocessing.preprocess_sound](../../FQChem/Complexity/FactoringPreprocessing.lean#L103)
- [FactoringRecursion.pair](../../FQChem/Complexity/FactoringRecursion.lean#L41)
- [FactoringRecursion.certify_some](../../FQChem/Complexity/FactoringRecursion.lean#L36)
- [FactoringRecursion.recursiveFactorization](../../FQChem/Complexity/FactoringRecursion.lean#L246)
- [FactoringReduction.extractFactor_nonunit](../../FQChem/Complexity/FactoringReduction.lean#L349)
- [FactoringReduction.extractFactor_sound](../../FQChem/Complexity/FactoringReduction.lean#L74)
- [CompiledSampling.mass_pos](../../integrations/forshor/FQChemForShor/CompiledSampling.lean#L39)
- [CompiledSampling.normalized](../../integrations/forshor/FQChemForShor/CompiledSampling.lean#L12)
- [baseLaw_certified](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L93) (private)
- [compositeShot](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L155)
- [drawLaw_certified](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L111)
- [input_ext](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L90) (private)
- [primeFactorization](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L205)
- [unitLaw_certified](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L76) (private)
- [unitLaw_success](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L26)
- [wordBounds](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L52) (private)
- [QuantumFactoring.positiveBaseFactorProbability](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L131)
- [Correctness.κ_pos](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Correctness.lean#L1089)
- [Workspace.workspace](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Workspace.lean#L793)

## FQChemForShor.FactoringResources

```mermaid
flowchart LR
  n94["FactoringBitCost.bitTrial_spec"]
  n112["FactoringPreprocessing.preprocess_sound"]
  n121["FactoringRecursion.pair"]
  n126["FactoringRecursion.factor_tree"]
  n135["FactoringRecursion.visit_bound"]
  n139["FactoringReduction.extractFactor_nonunit"]
  n1288["CompiledSampling.mass_pos"]
  n1289["CompiledSampling.normalized"]
  n1294["FactoringLaw.primeFactorization"]
  n1298["allWidths"]
  n1299["classicalCap_le"]
  n1300["clockFits"]
  n1301["factoringPolynomialResources"]
  n1302["gateCap_covers"]
  n1303["leavesFit"]
  n1304["log_mono"]
  n1305["measuredRecord"]
  n1306["nonunitRecord"]
  n1307["preprocessedRecord"]
  n1308["recordCost"]
  n1309["rejectedRecord"]
  n1310["totalClassicalBits"]
  n1311["totalFairBits"]
  n1312["totalOutputBits"]
  n1313["totalQuantumGates"]
  n1314["treeCharge_le"]
  n1315["wordFits"]
  n1342["OrderFinding.programGateCount"]
  n1360["VerifiedOrderFinding.physicalClock"]
  n1390["Workspace.workspace"]
  n1342 --> n1298
  n1390 -.-> n1298
  n94 --> n1299
  n1300 --> n1299
  n1315 --> n1299
  n121 -.-> n1301
  n1288 -.-> n1301
  n1289 -.-> n1301
  n1294 --> n1301
  n1310 --> n1301
  n1311 --> n1301
  n1312 --> n1301
  n1313 --> n1301
  n1390 -.-> n1301
  n1390 -.-> n1302
  n121 -.-> n1303
  n126 --> n1303
  n135 --> n1303
  n94 --> n1305
  n1300 --> n1305
  n1360 --> n1305
  n1390 -.-> n1305
  n94 --> n1306
  n139 --> n1306
  n1300 --> n1306
  n94 --> n1307
  n112 --> n1307
  n1300 --> n1307
  n1315 --> n1307
  n94 --> n1309
  n1300 --> n1309
  n1315 --> n1309
  n121 -.-> n1310
  n135 --> n1310
  n1299 --> n1310
  n1304 --> n1310
  n1314 --> n1310
  n121 -.-> n1311
  n135 --> n1311
  n1304 --> n1311
  n1314 --> n1311
  n121 -.-> n1312
  n135 --> n1312
  n1303 --> n1312
  n1304 --> n1312
  n1314 --> n1312
  n121 -.-> n1313
  n135 --> n1313
  n1298 --> n1313
  n1304 --> n1313
  n1314 --> n1313
  n1390 -.-> n1313
  n121 --> n1314
  n1304 --> n1315
```

- [FactoringBitCost.bitTrial_spec](../../FQChem/Complexity/FactoringBitCost.lean#L427)
- [FactoringPreprocessing.preprocess_sound](../../FQChem/Complexity/FactoringPreprocessing.lean#L103)
- [FactoringRecursion.pair](../../FQChem/Complexity/FactoringRecursion.lean#L41)
- [FactoringRecursion.factor_tree](../../FQChem/Complexity/FactoringRecursion.lean#L104)
- [FactoringRecursion.visit_bound](../../FQChem/Complexity/FactoringRecursion.lean#L136)
- [FactoringReduction.extractFactor_nonunit](../../FQChem/Complexity/FactoringReduction.lean#L349)
- [CompiledSampling.mass_pos](../../integrations/forshor/FQChemForShor/CompiledSampling.lean#L39)
- [CompiledSampling.normalized](../../integrations/forshor/FQChemForShor/CompiledSampling.lean#L12)
- [FactoringLaw.primeFactorization](../../integrations/forshor/FQChemForShor/FactoringLaw.lean#L205)
- [allWidths](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L32)
- [classicalCap_le](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L140)
- [clockFits](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L118) (private)
- [factoringPolynomialResources](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L261)
- [gateCap_covers](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L24)
- [leavesFit](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L224)
- [log_mono](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L89) (private)
- [measuredRecord](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L149)
- [nonunitRecord](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L165)
- [preprocessedRecord](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L181)
- [recordCost](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L133)
- [rejectedRecord](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L175)
- [totalClassicalBits](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L197)
- [totalFairBits](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L208)
- [totalOutputBits](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L239)
- [totalQuantumGates](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L98)
- [treeCharge_le](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L70)
- [wordFits](../../integrations/forshor/FQChemForShor/FactoringResources.lean#L115) (private)
- [OrderFinding.programGateCount](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L203)
- [VerifiedOrderFinding.physicalClock](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L49)
- [Workspace.workspace](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Workspace.lean#L793)

## FQChemForShor.FourierOrbit

```mermaid
flowchart LR
  n302["OrderFindingDecoder.scan_eq_reference"]
  n305["OrderFindingPostprocessing.logarithmic_scan"]
  n1316["amplitude_expand"]
  n1317["amplitude_label"]
  n1318["born_eq_period_formula"]
  n1319["born_normalized"]
  n1320["good_decodes"]
  n1321["idealRecovery"]
  n1322["inverseFourier_unitary"]
  n1323["label_injective"]
  n1324["omega_norm"]
  n1325["paperClock_bounds"]
  n1326["phase_cross"]
  n1327["powerRegister_normalized"]
  n1328["power_residue"]
  n1329["publishedClockRecovery"]
  n1330["scale_sq"]
  n1331["total_trace"]
  n1369["QftPhase.norm_qftPhase_one_shor"]
  n1382["OrderFindingAnalysis.goodOutcome_card_ge_totient"]
  n1383["OrderFindingAnalysis.goodOutcome_mass_lower_bound_from_card_and_pointwise"]
  n1385["OrderFindingAnalysis.shor_paper_goodOutcome_lower_bound"]
  n1388["Preliminaries.goodOutcome_r_found_one"]
  n1330 --> n1316
  n1316 --> n1317
  n1323 --> n1317
  n1328 --> n1317
  n1316 --> n1318
  n1317 --> n1318
  n1323 --> n1318
  n1328 --> n1318
  n1322 --> n1319
  n1327 --> n1319
  n1331 --> n1319
  n302 --> n1320
  n305 --> n1320
  n1388 --> n1320
  n1318 --> n1321
  n1320 --> n1321
  n1382 --> n1321
  n1383 --> n1321
  n1385 --> n1321
  n1326 --> n1322
  n1330 --> n1322
  n1369 --> n1324
  n1324 --> n1326
  n1330 --> n1327
  n1321 --> n1329
  n1325 --> n1329
```

- [OrderFindingDecoder.scan_eq_reference](../../FQChem/Complexity/OrderFindingDecoder.lean#L140)
- [OrderFindingPostprocessing.logarithmic_scan](../../FQChem/Complexity/OrderFindingPostprocessing.lean#L73)
- [amplitude_expand](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L68) (private)
- [amplitude_label](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L80) (private)
- [born_eq_period_formula](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L95)
- [born_normalized](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L169)
- [good_decodes](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L177) (private)
- [idealRecovery](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L191)
- [inverseFourier_unitary](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L144)
- [label_injective](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L56) (private)
- [omega_norm](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L114) (private)
- [paperClock_bounds](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L223)
- [phase_cross](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L117) (private)
- [powerRegister_normalized](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L37)
- [power_residue](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L64) (private)
- [publishedClockRecovery](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L237)
- [scale_sq](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L33) (private)
- [total_trace](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L157) (private)
- [QftPhase.norm_qftPhase_one_shor](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/QFT/Proofs/QftPhase.lean#L54)
- [OrderFindingAnalysis.goodOutcome_card_ge_totient](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/OrderFindingAnalysis.lean#L1041)
- [OrderFindingAnalysis.goodOutcome_mass_lower_bound_from_card_and_pointwise](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/OrderFindingAnalysis.lean#L1115)
- [OrderFindingAnalysis.shor_paper_goodOutcome_lower_bound](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/OrderFindingAnalysis.lean#L735)
- [Preliminaries.goodOutcome_r_found_one](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/Preliminaries.lean#L52)

## FQChemForShor.ModularConstants

```mermaid
flowchart LR
  n268["ModularInverse.inverse_spec"]
  n271["ModularInverse.subtractMod_spec"]
  n289["OrderFindingBitCost.productMod_spec"]
  n1332["cleanup_constant"]
  n1333["compile_constants"]
  n1334["steps_spec"]
  n268 --> n1333
  n1334 --> n1333
  n271 --> n1334
  n289 --> n1334
  n1332 --> n1334
```

- [ModularInverse.inverse_spec](../../FQChem/Complexity/ModularInverse.lean#L99)
- [ModularInverse.subtractMod_spec](../../FQChem/Complexity/ModularInverse.lean#L25)
- [OrderFindingBitCost.productMod_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L296)
- [cleanup_constant](../../integrations/forshor/FQChemForShor/ModularConstants.lean#L14) (private)
- [compile_constants](../../integrations/forshor/FQChemForShor/ModularConstants.lean#L97)
- [steps_spec](../../integrations/forshor/FQChemForShor/ModularConstants.lean#L53) (private)

## FQChemForShor.OrderFinding

```mermaid
flowchart LR
  n302["OrderFindingDecoder.scan_eq_reference"]
  n305["OrderFindingPostprocessing.logarithmic_scan"]
  n1335["compiledRecovery"]
  n1336["complete"]
  n1337["executableDecoder"]
  n1338["extraBits_linear"]
  n1339["fourierRecovery"]
  n1340["independentTrialBound"]
  n1341["oneRun"]
  n1342["programGateCount"]
  n1343["programRecovery"]
  n1344["referencePrecision_le"]
  n1367["Policy.constPolicy_admissible"]
  n1368["Policy.table_admissible"]
  n1370["Main.referenceSubmittedProgram_correct"]
  n1371["Layout.algorithm1ExtraBits_referencePrecision"]
  n1372["Layout.allocateReferenceLayout_data_width"]
  n1373["Layout.allocateReferenceLayout_x_width"]
  n1375["Success.referenceSuccessProbability_pos"]
  n1376["Main.Shor_correct_approx_lowered"]
  n1377["Main.shorGateCountBound_of_setup"]
  n1378["Correctness.κ_pos"]
  n1379["GateCount.shorPrecision_inv_le"]
  n1380["TotientBoundsLarge.shor_totient_ratio"]
  n1381["GoodOutcomeMassLowerBound.eval_orderFindingIdeal_prefix"]
  n1382["OrderFindingAnalysis.goodOutcome_card_ge_totient"]
  n1383["OrderFindingAnalysis.goodOutcome_mass_lower_bound_from_card_and_pointwise"]
  n1385["OrderFindingAnalysis.shor_paper_goodOutcome_lower_bound"]
  n1386["PhaseEstimation.measProbAfter_orderFindingIdeal_eq_paper_formula"]
  n1387["Preliminaries.goodOutcome_mass_le_probability_of_success"]
  n1389["Preliminaries.shor_order_parameter_bounds"]
  n1390["Workspace.workspace"]
  n1392["Measure.probability_of_success_eq"]
  n1336 --> n1335
  n1367 --> n1335
  n1368 --> n1335
  n1370 --> n1335
  n1375 --> n1335
  n1392 --> n1335
  n305 --> n1336
  n302 --> n1337
  n1371 --> n1338
  n1336 --> n1339
  n1381 --> n1339
  n1382 --> n1339
  n1383 --> n1339
  n1385 --> n1339
  n1386 --> n1339
  n1387 --> n1339
  n1389 --> n1339
  n1380 --> n1340
  n1339 --> n1341
  n1338 --> n1342
  n1372 --> n1342
  n1373 --> n1342
  n1377 --> n1342
  n1390 --> n1342
  n1336 --> n1343
  n1344 --> n1343
  n1367 --> n1343
  n1368 --> n1343
  n1372 --> n1343
  n1373 --> n1343
  n1376 --> n1343
  n1390 --> n1343
  n1392 --> n1343
  n1378 --> n1344
  n1379 --> n1344
```

- [OrderFindingDecoder.scan_eq_reference](../../FQChem/Complexity/OrderFindingDecoder.lean#L140)
- [OrderFindingPostprocessing.logarithmic_scan](../../FQChem/Complexity/OrderFindingPostprocessing.lean#L73)
- [compiledRecovery](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L113)
- [complete](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L22)
- [executableDecoder](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L27)
- [extraBits_linear](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L156) (private)
- [fourierRecovery](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L35)
- [independentTrialBound](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L80)
- [oneRun](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L58)
- [programGateCount](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L203)
- [programRecovery](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L185)
- [referencePrecision_le](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L129) (private)
- [Policy.constPolicy_admissible](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Framework/Policy.lean#L254)
- [Policy.table_admissible](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Framework/Policy.lean#L105)
- [Main.referenceSubmittedProgram_correct](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Reference/Standard/Main.lean#L144)
- [Layout.algorithm1ExtraBits_referencePrecision](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Reference/Standard/Proofs/Layout.lean#L29)
- [Layout.allocateReferenceLayout_data_width](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Reference/Standard/Proofs/Layout.lean#L76)
- [Layout.allocateReferenceLayout_x_width](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Reference/Standard/Proofs/Layout.lean#L72)
- [Success.referenceSuccessProbability_pos](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Reference/Standard/Proofs/Success.lean#L187)
- [Main.Shor_correct_approx_lowered](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Main.lean#L38)
- [Main.shorGateCountBound_of_setup](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Main.lean#L59)
- [Correctness.κ_pos](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Correctness.lean#L1089)
- [GateCount.shorPrecision_inv_le](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/GateCount.lean#L2276)
- [TotientBoundsLarge.shor_totient_ratio](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Math/TotientBoundsLarge.lean#L273)
- [GoodOutcomeMassLowerBound.eval_orderFindingIdeal_prefix](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/GoodOutcomeMassLowerBound.lean#L578)
- [OrderFindingAnalysis.goodOutcome_card_ge_totient](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/OrderFindingAnalysis.lean#L1041)
- [OrderFindingAnalysis.goodOutcome_mass_lower_bound_from_card_and_pointwise](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/OrderFindingAnalysis.lean#L1115)
- [OrderFindingAnalysis.shor_paper_goodOutcome_lower_bound](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/OrderFindingAnalysis.lean#L735)
- [PhaseEstimation.measProbAfter_orderFindingIdeal_eq_paper_formula](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/PhaseEstimation.lean#L1164)
- [Preliminaries.goodOutcome_mass_le_probability_of_success](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/Preliminaries.lean#L449)
- [Preliminaries.shor_order_parameter_bounds](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/Preliminaries.lean#L518)
- [Workspace.workspace](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Workspace.lean#L793)
- [Measure.probability_of_success_eq](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Model/QuantumLib/Measure.lean#L94)

## FQChemForShor.OrderFindingTrials

```mermaid
flowchart LR
  n1319["FourierOrbit.born_normalized"]
  n1325["FourierOrbit.paperClock_bounds"]
  n1329["FourierOrbit.publishedClockRecovery"]
  n1337["OrderFinding.executableDecoder"]
  n1340["OrderFinding.independentTrialBound"]
  n1345["boundedErrorOrderFinding"]
  n1346["selected_if_hit"]
  n1384["OrderFindingAnalysis.ord_le_of_pow_mod_eq_one"]
  n1319 --> n1345
  n1325 --> n1345
  n1329 --> n1345
  n1340 --> n1345
  n1346 --> n1345
  n1337 --> n1346
  n1384 --> n1346
```

- [FourierOrbit.born_normalized](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L169)
- [FourierOrbit.paperClock_bounds](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L223)
- [FourierOrbit.publishedClockRecovery](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L237)
- [OrderFinding.executableDecoder](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L27)
- [OrderFinding.independentTrialBound](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L80)
- [boundedErrorOrderFinding](../../integrations/forshor/FQChemForShor/OrderFindingTrials.lean#L54)
- [selected_if_hit](../../integrations/forshor/FQChemForShor/OrderFindingTrials.lean#L19)
- [OrderFindingAnalysis.ord_le_of_pow_mod_eq_one](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/NaiveShor/OrderFindingAnalysis.lean#L46)

## FQChemForShor.QuantumFactoring

```mermaid
flowchart LR
  n140["FactoringReduction.extractFactor_of_good"]
  n145["FactoringReduction.goodUnitFraction"]
  n149["FactoringReduction.randomBaseFailure"]
  n1337["OrderFinding.executableDecoder"]
  n1343["OrderFinding.programRecovery"]
  n1347["acceptedOrder"]
  n1348["factorProbability_nonneg"]
  n1349["goodBaseRecovery"]
  n1350["mass_nonneg"]
  n1351["positiveBaseFactorProbability"]
  n1352["representative"]
  n1353["uniformFactorProbability"]
  n1354["unitOrder"]
  n1378["Correctness.κ_pos"]
  n1390["Workspace.workspace"]
  n1337 --> n1347
  n1343 --> n1347
  n1350 -.-> n1347
  n1354 --> n1347
  n1390 -.-> n1347
  n1350 -.-> n1348
  n1390 -.-> n1348
  n140 --> n1349
  n1347 --> n1349
  n1390 -.-> n1349
  n1390 -.-> n1350
  n149 --> n1351
  n1347 --> n1351
  n1348 -.-> n1351
  n1352 --> n1351
  n1378 --> n1351
  n1390 -.-> n1351
  n145 --> n1353
  n1348 --> n1353
  n1349 --> n1353
  n1378 --> n1353
  n1390 -.-> n1353
```

- [FactoringReduction.extractFactor_of_good](../../FQChem/Complexity/FactoringReduction.lean#L273)
- [FactoringReduction.goodUnitFraction](../../FQChem/Complexity/FactoringReduction.lean#L244)
- [FactoringReduction.randomBaseFailure](../../FQChem/Complexity/FactoringReduction.lean#L359)
- [OrderFinding.executableDecoder](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L27)
- [OrderFinding.programRecovery](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L185)
- [acceptedOrder](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L50) (private)
- [factorProbability_nonneg](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L32) (private)
- [goodBaseRecovery](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L77)
- [mass_nonneg](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L28) (private)
- [positiveBaseFactorProbability](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L131)
- [representative](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L116) (private)
- [uniformFactorProbability](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L84)
- [unitOrder](../../integrations/forshor/FQChemForShor/QuantumFactoring.lean#L43) (private)
- [Correctness.κ_pos](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Correctness.lean#L1089)
- [Workspace.workspace](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Workspace.lean#L793)

## FQChemForShor.VerifiedOrderFinding

```mermaid
flowchart LR
  n281["OrderFindingBitCost.decode_input_bound"]
  n284["OrderFindingBitCost.equal_spec"]
  n293["OrderFindingBitCost.update_spec"]
  n294["OrderFindingDecoder.convergent_bounds"]
  n300["OrderFindingDecoder.least_insert"]
  n1288["CompiledSampling.mass_pos"]
  n1289["CompiledSampling.normalized"]
  n1329["FourierOrbit.publishedClockRecovery"]
  n1337["OrderFinding.executableDecoder"]
  n1342["OrderFinding.programGateCount"]
  n1343["OrderFinding.programRecovery"]
  n1345["OrderFindingTrials.boundedErrorOrderFinding"]
  n1346["OrderFindingTrials.selected_if_hit"]
  n1355["compiledError"]
  n1356["decoded_le_clock"]
  n1357["expNegTwo_lt_third"]
  n1358["joint_born_mass"]
  n1359["oneShot"]
  n1360["physicalClock"]
  n1361["physical_bounded_error"]
  n1362["polynomialWork"]
  n1363["records_spec"]
  n1364["select_cons"]
  n1365["shorOrderFinding"]
  n1366["trial_inverse"]
  n1374["Layout.regSize_interval"]
  n1390["Workspace.workspace"]
  n1288 -.-> n1355
  n1289 --> n1355
  n1346 --> n1355
  n1359 --> n1355
  n1390 -.-> n1355
  n294 --> n1356
  n1289 --> n1358
  n1390 -.-> n1358
  n1337 --> n1359
  n1343 --> n1359
  n1366 --> n1359
  n1390 -.-> n1359
  n1374 --> n1360
  n1390 -.-> n1360
  n1355 --> n1361
  n1357 --> n1361
  n1363 --> n1361
  n1390 -.-> n1361
  n1342 --> n1362
  n1360 --> n1362
  n1363 --> n1362
  n1390 -.-> n1362
  n281 --> n1363
  n284 --> n1363
  n293 --> n1363
  n1356 --> n1363
  n1364 --> n1363
  n300 --> n1364
  n1329 --> n1365
  n1345 --> n1365
  n1358 --> n1365
  n1361 --> n1365
  n1362 --> n1365
  n1390 -.-> n1365
```

- [OrderFindingBitCost.decode_input_bound](../../FQChem/Complexity/OrderFindingBitCost.lean#L461)
- [OrderFindingBitCost.equal_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L209)
- [OrderFindingBitCost.update_spec](../../FQChem/Complexity/OrderFindingBitCost.lean#L357)
- [OrderFindingDecoder.convergent_bounds](../../FQChem/Complexity/OrderFindingDecoder.lean#L62)
- [OrderFindingDecoder.least_insert](../../FQChem/Complexity/OrderFindingDecoder.lean#L128)
- [CompiledSampling.mass_pos](../../integrations/forshor/FQChemForShor/CompiledSampling.lean#L39)
- [CompiledSampling.normalized](../../integrations/forshor/FQChemForShor/CompiledSampling.lean#L12)
- [FourierOrbit.publishedClockRecovery](../../integrations/forshor/FQChemForShor/FourierOrbit.lean#L237)
- [OrderFinding.executableDecoder](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L27)
- [OrderFinding.programGateCount](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L203)
- [OrderFinding.programRecovery](../../integrations/forshor/FQChemForShor/OrderFinding.lean#L185)
- [OrderFindingTrials.boundedErrorOrderFinding](../../integrations/forshor/FQChemForShor/OrderFindingTrials.lean#L54)
- [OrderFindingTrials.selected_if_hit](../../integrations/forshor/FQChemForShor/OrderFindingTrials.lean#L19)
- [compiledError](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L75)
- [decoded_le_clock](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L118) (private)
- [expNegTwo_lt_third](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L112) (private)
- [joint_born_mass](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L236)
- [oneShot](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L56) (private)
- [physicalClock](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L49)
- [physical_bounded_error](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L226)
- [polynomialWork](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L244)
- [records_spec](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L162) (private)
- [select_cons](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L141) (private)
- [shorOrderFinding](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L325)
- [trial_inverse](../../integrations/forshor/FQChemForShor/VerifiedOrderFinding.lean#L22) (private)
- [Layout.regSize_interval](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Reference/Standard/Proofs/Layout.lean#L55)
- [Workspace.workspace](https://github.com/VerifiedQC/ForShor/blob/a4628e560f4082df75491b9490b0585013bf99ac/ForShor/ShorVerification/Implementation/Shor/Proofs/Workspace.lean#L793)
