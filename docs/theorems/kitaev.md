# FormalQChemKitaev theorem graph

37 source theorems and lemmas · 8 shared library prerequisites · 15 upstream theorem nodes · 79 dependency edges.

Arrows point from prerequisite to result. Dashed arrows pass through local definitions or compiler-generated helpers. Each diagram includes the prerequisites used by its module. The links below each diagram open the Lean declarations.

[Graph guide and interactive explorer](README.md)

## FormalQChemKitaev

```mermaid
flowchart LR
  n8["cutoffDen_le"]
  n9["cutoffDen_pos"]
  n10["energy_range_bddBelow"]
  n11["energy_range_nonempty"]
  n12["estimate_decides"]
  n13["groundEnergy_promise"]
  n14["localEnergy_disjoint"]
  n15["preparation_and_measurement_decide"]
  n16["promiseGap"]
  n17["rationalCutoffs"]
  n18["reduction_length"]
  n19["resources"]
  n20["run_scalar"]
  n21["scalarEntries_bound"]
  n22["serialize_injective"]
  n23["termDescriptors_correct"]
  n24["termDescriptors_count"]
  n25["verifier_reduction"]
  n26["witnessEnergy_promise"]
  n27["witnessFree_acceptance"]
  n28["witnessFree_groundEnergy"]
  n29["zero_input_legal"]
  n45["QmaCompletenessRefined.clause3Aux_encNat_selfDelimiting"]
  n46["QmaCompletenessRefined.clause3Aux_toBits_injective"]
  n47["QmaCompletenessNativeOutput.outputTerms_length"]
  n48["EventProbability.measureProb_smul"]
  n49["Qubit.inner_apply"]
  n50["Qubit.normalized_ket"]
  n51["QmaCompleteness.qma_history_locality_description_and_energy_bounds"]
  n52["QmaCompletenessNormalized.denominator_le_poly"]
  n53["QmaCompletenessNormalized.denominator_pos"]
  n54["QmaCompletenessNormalized.gap_inverse_poly"]
  n55["QmaCompletenessNormalized.gap_positive"]
  n56["QmaCompletenessNormalized.padded_normalized_contract"]
  n57["QmaCompletenessPadding.paid64_length"]
  n58["QmaCompletenessSize.encNat_length_le_self"]
  n59["QmaCompletenessSize.termEntries_length"]
  n52 --> n8
  n57 --> n8
  n53 --> n9
  n49 --> n10
  n50 --> n11
  n13 --> n12
  n16 --> n12
  n10 --> n13
  n11 --> n13
  n26 --> n13
  n22 --> n14
  n10 --> n15
  n13 --> n15
  n16 --> n15
  n54 --> n16
  n55 --> n16
  n57 --> n16
  n53 --> n17
  n8 --> n18
  n19 --> n18
  n58 --> n18
  n51 --> n19
  n57 --> n19
  n19 --> n21
  n59 --> n21
  n45 --> n22
  n46 --> n22
  n23 -.-> n24
  n47 --> n24
  n9 --> n25
  n13 --> n25
  n17 --> n25
  n19 --> n25
  n56 --> n26
  n57 --> n26
  n20 --> n27
  n48 --> n27
  n13 --> n28
  n27 --> n28
  n29 --> n28
  n50 --> n28
```

- [cutoffDen_le](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L246)
- [cutoffDen_pos](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L233)
- [energy_range_bddBelow](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L39) (private)
- [energy_range_nonempty](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L35) (private)
- [estimate_decides](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L154)
- [groundEnergy_promise](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L139)
- [localEnergy_disjoint](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L291)
- [preparation_and_measurement_decide](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L389)
- [promiseGap](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L97)
- [rationalCutoffs](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L238)
- [reduction_length](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L274)
- [resources](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L79)
- [run_scalar](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L172) (private)
- [scalarEntries_bound](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L358)
- [serialize_injective](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L268)
- [termDescriptors_correct](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L342)
- [termDescriptors_count](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L350)
- [verifier_reduction](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L300)
- [witnessEnergy_promise](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L123)
- [witnessFree_acceptance](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L187)
- [witnessFree_groundEnergy](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L206)
- [zero_input_legal](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L178) (private)
- [QmaCompletenessRefined.clause3Aux_encNat_selfDelimiting](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessRefined.lean#L1056)
- [QmaCompletenessRefined.clause3Aux_toBits_injective](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessRefined.lean#L1261)
- [QmaCompletenessNativeOutput.outputTerms_length](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QueryComplexity/DegreeMethod/QmaCompletenessNativeOutput.lean#L274)
- [EventProbability.measureProb_smul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/BornMetrics/EventProbability.lean#L62)
- [Qubit.inner_apply](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L639)
- [Qubit.normalized_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L152)
- [QmaCompleteness.qma_history_locality_description_and_energy_bounds](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompleteness.lean#L98)
- [QmaCompletenessNormalized.denominator_le_poly](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean#L313)
- [QmaCompletenessNormalized.denominator_pos](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean#L93)
- [QmaCompletenessNormalized.gap_inverse_poly](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean#L333)
- [QmaCompletenessNormalized.gap_positive](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean#L323)
- [QmaCompletenessNormalized.padded_normalized_contract](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean#L354)
- [QmaCompletenessPadding.paid64_length](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessPadding.lean#L103)
- [QmaCompletenessSize.encNat_length_le_self](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessSize.lean#L97)
- [QmaCompletenessSize.termEntries_length](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessSize.lean#L80)

## FormalQChemKitaev.ElectronicStructure

```mermaid
flowchart LR
  n0["ElectronicStructure.railMove_count"]
  n1["ElectronicStructure.railMove_twice"]
  n2["ElectronicStructureOperators.fermionExpectation"]
  n3["ElectronicStructurePauli.localExpansion_size"]
  n4["ElectronicStructurePauli.localExpansion_strength"]
  n5["ElectronicStructurePauli.localHamiltonian_to_fixedParticle"]
  n6["ElectronicStructurePauli.untouched_eq"]
  n7["RayleighRitz.groundEnergy_le"]
  n9["FormalQChemKitaev.cutoffDen_pos"]
  n16["FormalQChemKitaev.promiseGap"]
  n17["FormalQChemKitaev.rationalCutoffs"]
  n19["FormalQChemKitaev.resources"]
  n26["FormalQChemKitaev.witnessEnergy_promise"]
  n30["circuitFermionResources"]
  n31["circuitPenalty_sufficient"]
  n32["circuitTables"]
  n33["circuit_to_fixedParticle"]
  n34["decodeHamiltonian"]
  n35["decodeTerm_kernel"]
  n36["distinctWire_range"]
  n37["distinctWire_readWire"]
  n38["electronCount"]
  n39["electronicPreparation_decides"]
  n40["entry_norm_bound"]
  n41["ground_le_trial"]
  n42["outside_iff"]
  n43["tableIndex_restrict"]
  n44["table_is_global_entry"]
  n57["QmaCompletenessPadding.paid64_length"]
  n3 --> n30
  n19 -.-> n30
  n32 --> n30
  n4 --> n31
  n9 --> n31
  n17 --> n31
  n19 -.-> n31
  n32 --> n31
  n19 --> n32
  n35 --> n32
  n40 --> n32
  n44 --> n32
  n0 -.-> n33
  n1 -.-> n33
  n5 --> n33
  n19 -.-> n33
  n26 --> n33
  n31 --> n33
  n34 --> n33
  n35 --> n34
  n6 --> n35
  n36 --> n35
  n42 --> n35
  n43 --> n35
  n57 --> n38
  n0 -.-> n39
  n1 -.-> n39
  n16 --> n39
  n19 -.-> n39
  n33 --> n39
  n41 --> n39
  n0 -.-> n41
  n1 -.-> n41
  n2 --> n41
  n7 --> n41
  n19 -.-> n41
  n37 --> n43
  n6 --> n44
```

- [ElectronicStructure.railMove_count](https://github.com/bestquark/formal_qchem/blob/main/FormalQChem/Complexity/ElectronicStructure.lean#L110)
- [ElectronicStructure.railMove_twice](https://github.com/bestquark/formal_qchem/blob/main/FormalQChem/Complexity/ElectronicStructure.lean#L104)
- [ElectronicStructureOperators.fermionExpectation](https://github.com/bestquark/formal_qchem/blob/main/FormalQChem/Complexity/ElectronicStructureOperators.lean#L167)
- [ElectronicStructurePauli.localExpansion_size](https://github.com/bestquark/formal_qchem/blob/main/FormalQChem/Complexity/ElectronicStructurePauli.lean#L198)
- [ElectronicStructurePauli.localExpansion_strength](https://github.com/bestquark/formal_qchem/blob/main/FormalQChem/Complexity/ElectronicStructurePauli.lean#L232)
- [ElectronicStructurePauli.localHamiltonian_to_fixedParticle](https://github.com/bestquark/formal_qchem/blob/main/FormalQChem/Complexity/ElectronicStructurePauli.lean#L209)
- [ElectronicStructurePauli.untouched_eq](https://github.com/bestquark/formal_qchem/blob/main/FormalQChem/Complexity/ElectronicStructurePauli.lean#L114)
- [RayleighRitz.groundEnergy_le](https://github.com/bestquark/formal_qchem/blob/main/FormalQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L49)
- [FormalQChemKitaev.cutoffDen_pos](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L233)
- [FormalQChemKitaev.promiseGap](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L97)
- [FormalQChemKitaev.rationalCutoffs](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L238)
- [FormalQChemKitaev.resources](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L79)
- [FormalQChemKitaev.witnessEnergy_promise](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev.lean#L123)
- [circuitFermionResources](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L187)
- [circuitPenalty_sufficient](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L161) (private)
- [circuitTables](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L150)
- [circuit_to_fixedParticle](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L198)
- [decodeHamiltonian](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L112)
- [decodeTerm_kernel](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L97)
- [distinctWire_range](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L48)
- [distinctWire_readWire](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L43)
- [electronCount](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L176)
- [electronicPreparation_decides](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L224)
- [entry_norm_bound](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L138) (private)
- [ground_le_trial](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L211) (private)
- [outside_iff](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L83) (private)
- [tableIndex_restrict](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L61)
- [table_is_global_entry](https://github.com/bestquark/formal_qchem/blob/main/integrations/qatlib/FormalQChemKitaev/ElectronicStructure.lean#L128) (private)
- [QmaCompletenessPadding.paid64_length](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessPadding.lean#L103)
