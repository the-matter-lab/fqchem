# Qatlib integration theorem graph

416 source theorems and lemmas · 8 shared library prerequisites · 132 upstream theorem nodes · 819 dependency edges.

Arrows point from prerequisite to result. Dashed arrows pass through local definitions or compiler-generated helpers. Each diagram includes the prerequisites used by its module. The links below each diagram open the Lean declarations.

[Graph guide and interactive explorer](README.md)

## FQChemKitaev.AmplificationBounds

```mermaid
flowchart LR
  n8["budget"]
  n9["polynomial_size"]
  n10["reaches_precision"]
  n11["size_after"]
  n193["Majority.error_bound"]
  n200["Majority.squared_error_decay"]
  n8 --> n10
  n193 --> n10
  n200 --> n10
```

- [budget](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L43) (private)
- [polynomial_size](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L31)
- [reaches_precision](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L72)
- [size_after](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L20)
- [Majority.error_bound](../../integrations/qatlib/FQChemKitaev/Majority.lean#L220)
- [Majority.squared_error_decay](../../integrations/qatlib/FQChemKitaev/Majority.lean#L247)

## FQChemKitaev.AmplifierCost

```mermaid
flowchart LR
  n9["AmplificationBounds.polynomial_size"]
  n11["AmplificationBounds.size_after"]
  n12["add_spec"]
  n13["amplify_correct"]
  n14["amplify_paid"]
  n15["amplify_time"]
  n16["binary_paid"]
  n17["budget_mono"]
  n18["compile_correct"]
  n19["compile_time"]
  n20["copies_time"]
  n21["depth_spec"]
  n22["emit_paid"]
  n23["emit_time"]
  n24["fromRows_paid"]
  n25["fromRows_time"]
  n26["gateRows_spec"]
  n27["gates_weight"]
  n28["growth"]
  n29["half_spec"]
  n30["indices_spec"]
  n31["layer_correct"]
  n32["layer_time"]
  n33["layers_correct"]
  n34["layers_time"]
  n35["length_le_steps"]
  n36["less_spec"]
  n37["logarithm_spec"]
  n38["output_correct"]
  n39["output_paid"]
  n40["output_time"]
  n41["prepend_cost"]
  n42["prepend_wire"]
  n43["readWord_correct"]
  n44["readWord_legal"]
  n45["readWord_time"]
  n46["row_weight"]
  n47["shift_cost"]
  n48["shift_wire"]
  n49["valid_spec"]
  n50["Amplify.copy_ne"]
  n55["Amplify.repeat_all_zero"]
  n56["Amplify.repeat_gate_count"]
  n58["Amplify.repeat_width"]
  n61["Amplify.word_legal"]
  n81["Compiler.binary_cost"]
  n83["Compiler.binary_roundtrip"]
  n84["Compiler.cell_funded"]
  n85["Compiler.charge_funded"]
  n100["Compiler.count_spec"]
  n103["Compiler.fields_funded"]
  n104["Compiler.fields_steps"]
  n117["Compiler.read_gateRow"]
  n121["Compiler.rowsLength_le"]
  n123["Compiler.scan_budget"]
  n124["Compiler.scan_cost"]
  n128["Compiler.scan_serialize"]
  n134["Compiler.unbinary_cost"]
  n21 --> n13
  n33 --> n13
  n38 --> n13
  n50 -.-> n13
  n55 --> n13
  n61 -.-> n13
  n39 --> n14
  n9 --> n15
  n21 --> n15
  n28 --> n15
  n33 --> n15
  n34 --> n15
  n40 --> n15
  n50 -.-> n15
  n61 -.-> n15
  n13 --> n18
  n36 --> n18
  n43 --> n18
  n50 -.-> n18
  n61 -.-> n18
  n83 --> n18
  n128 --> n18
  n25 --> n19
  n123 --> n19
  n124 --> n19
  n134 --> n19
  n41 --> n20
  n12 --> n21
  n37 --> n21
  n100 --> n21
  n84 --> n22
  n85 --> n22
  n103 --> n22
  n104 --> n23
  n14 --> n24
  n15 --> n25
  n17 --> n25
  n36 --> n25
  n44 --> n25
  n45 --> n25
  n121 --> n25
  n11 --> n28
  n50 -.-> n28
  n56 --> n28
  n58 --> n28
  n61 -.-> n28
  n12 --> n31
  n42 --> n31
  n50 -.-> n31
  n61 -.-> n31
  n12 --> n32
  n20 --> n32
  n31 --> n33
  n50 -.-> n33
  n61 -.-> n33
  n28 --> n34
  n32 --> n34
  n33 --> n34
  n50 -.-> n34
  n61 -.-> n34
  n24 --> n35
  n29 --> n37
  n26 --> n38
  n30 --> n38
  n16 --> n39
  n22 --> n40
  n23 --> n40
  n26 --> n40
  n27 --> n40
  n30 --> n40
  n46 --> n40
  n81 --> n40
  n47 --> n41
  n48 --> n42
  n49 --> n43
  n117 --> n43
  n49 --> n44
  n49 --> n45
  n12 --> n47
  n12 --> n48
  n36 --> n49
```

- [AmplificationBounds.polynomial_size](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L31)
- [AmplificationBounds.size_after](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L20)
- [add_spec](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L34) (private)
- [amplify_correct](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L330)
- [amplify_paid](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L536) (private)
- [amplify_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L341)
- [binary_paid](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L527) (private)
- [budget_mono](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L482) (private)
- [compile_correct](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L473)
- [compile_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L515)
- [copies_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L115) (private)
- [depth_spec](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L211) (private)
- [emit_paid](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L259) (private)
- [emit_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L264) (private)
- [fromRows_paid](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L540) (private)
- [fromRows_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L484) (private)
- [gateRows_spec](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L240) (private)
- [gates_weight](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L282) (private)
- [growth](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L143) (private)
- [half_spec](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L167) (private)
- [indices_spec](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L230) (private)
- [layer_correct](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L102)
- [layer_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L123) (private)
- [layers_correct](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L137)
- [layers_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L148) (private)
- [length_le_steps](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L552)
- [less_spec](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L367) (private)
- [logarithm_spec](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L180) (private)
- [output_correct](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L252) (private)
- [output_paid](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L532) (private)
- [output_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L300) (private)
- [prepend_cost](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L69) (private)
- [prepend_wire](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L78) (private)
- [readWord_correct](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L435) (private)
- [readWord_legal](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L422) (private)
- [readWord_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L445) (private)
- [row_weight](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L273) (private)
- [shift_cost](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L47) (private)
- [shift_wire](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L50) (private)
- [valid_spec](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L387) (private)
- [Amplify.copy_ne](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L31) (private)
- [Amplify.repeat_all_zero](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L243)
- [Amplify.repeat_gate_count](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L236)
- [Amplify.repeat_width](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L240)
- [Amplify.word_legal](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L139)
- [Compiler.binary_cost](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L636) (private)
- [Compiler.binary_roundtrip](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L633)
- [Compiler.cell_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L523) (private)
- [Compiler.charge_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L520) (private)
- [Compiler.count_spec](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L176)
- [Compiler.fields_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L529) (private)
- [Compiler.fields_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L349) (private)
- [Compiler.read_gateRow](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L133)
- [Compiler.rowsLength_le](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L325) (private)
- [Compiler.scan_budget](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L339) (private)
- [Compiler.scan_cost](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L87)
- [Compiler.scan_serialize](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L113)
- [Compiler.unbinary_cost](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L639) (private)

## FQChemKitaev.Amplify

```mermaid
flowchart LR
  n50["copy_ne"]
  n51["joint_product"]
  n52["joint_run"]
  n53["joint_zero"]
  n54["repeat_accept"]
  n55["repeat_all_zero"]
  n56["repeat_gate_count"]
  n57["repeat_reject"]
  n58["repeat_width"]
  n59["step_accept"]
  n60["word_accept"]
  n61["word_legal"]
  n62["word_length"]
  n63["zeroAcceptance_mem"]
  n201["Majority.three_copy_readout"]
  n207["Majority.word_legal"]
  n217["Wiring.onWires_legal"]
  n218["Wiring.onWires_length"]
  n219["Wiring.onWires_run"]
  n452["FiniteGateDescription.finite_gate_description_rejection_unitarity_and_counts"]
  n518["EventProbability.measureProb_le_one"]
  n524["Qubit.measureProb_nonneg"]
  n526["Qubit.normalized_ket"]
  n533["Circuit.normalized_run"]
  n534["Circuit.run_append"]
  n50 --> n52
  n219 --> n52
  n50 -.-> n54
  n59 --> n54
  n61 -.-> n54
  n50 -.-> n55
  n61 -.-> n55
  n50 -.-> n56
  n61 -.-> n56
  n62 --> n56
  n50 -.-> n57
  n59 --> n57
  n61 -.-> n57
  n50 -.-> n58
  n61 -.-> n58
  n50 -.-> n59
  n60 --> n59
  n61 -.-> n59
  n50 -.-> n60
  n51 --> n60
  n52 --> n60
  n53 --> n60
  n201 --> n60
  n452 --> n60
  n526 --> n60
  n533 --> n60
  n534 --> n60
  n50 -.-> n61
  n207 --> n61
  n217 --> n61
  n50 -.-> n62
  n218 --> n62
  n452 --> n63
  n518 --> n63
  n524 --> n63
  n526 --> n63
  n533 --> n63
```

- [copy_ne](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L31) (private)
- [joint_product](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L166) (private)
- [joint_run](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L81) (private)
- [joint_zero](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L146) (private)
- [repeat_accept](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L259)
- [repeat_all_zero](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L243)
- [repeat_gate_count](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L236)
- [repeat_reject](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L265)
- [repeat_width](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L240)
- [step_accept](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L255)
- [word_accept](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L183)
- [word_legal](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L139)
- [word_length](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L136)
- [zeroAcceptance_mem](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L248)
- [Majority.three_copy_readout](../../integrations/qatlib/FQChemKitaev/Majority.lean#L187)
- [Majority.word_legal](../../integrations/qatlib/FQChemKitaev/Majority.lean#L70)
- [Wiring.onWires_legal](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L162)
- [Wiring.onWires_length](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L168)
- [Wiring.onWires_run](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L173)
- [FiniteGateDescription.finite_gate_description_rejection_unitarity_and_counts](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/FiniteGateDescription.lean#L129)
- [EventProbability.measureProb_le_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/BornMetrics/EventProbability.lean#L45)
- [Qubit.measureProb_nonneg](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L167)
- [Qubit.normalized_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L152)
- [Circuit.normalized_run](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean)
- [Circuit.run_append](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean#L249)

## FQChemKitaev.BoundedErrorReduction

```mermaid
flowchart LR
  n0["ElectronicStructure.railMove_count"]
  n1["ElectronicStructure.railMove_twice"]
  n9["AmplificationBounds.polynomial_size"]
  n10["AmplificationBounds.reaches_precision"]
  n11["AmplificationBounds.size_after"]
  n18["AmplifierCost.compile_correct"]
  n19["AmplifierCost.compile_time"]
  n35["AmplifierCost.length_le_steps"]
  n50["Amplify.copy_ne"]
  n54["Amplify.repeat_accept"]
  n55["Amplify.repeat_all_zero"]
  n56["Amplify.repeat_gate_count"]
  n57["Amplify.repeat_reject"]
  n58["Amplify.repeat_width"]
  n61["Amplify.word_legal"]
  n63["Amplify.zeroAcceptance_mem"]
  n64["amplified_promise"]
  n65["amplified_size"]
  n66["circuit_to_electronic_energy"]
  n67["circuit_to_local_energy"]
  n68["denominator_ge_four"]
  n69["growth"]
  n70["initialized_after"]
  n71["size_positive"]
  n72["transducer_correct"]
  n73["transducer_output"]
  n74["transducer_promise_gap"]
  n75["transducer_time"]
  n76["transducer_value"]
  n77["uniform_circuit_to_electronic_energy"]
  n92["Compiler.compileBits_correct"]
  n93["Compiler.compileBits_time"]
  n97["Compiler.compile_energyPromise"]
  n133["Compiler.unbinary_compileBits"]
  n158["ElectronicStructure.circuit_to_fixedParticle"]
  n178["HistoryHamiltonian.promiseGap"]
  n181["HistoryHamiltonian.resources"]
  n189["HistoryHamiltonian.witnessFree_acceptance"]
  n191["HistoryHamiltonian.zero_input_legal"]
  n209["UniformCircuits.generated_electronic_promise"]
  n210["UniformCircuits.history_acceptance"]
  n212["UniformCircuits.inputWord_legal"]
  n526["Qubit.normalized_ket"]
  n10 --> n64
  n50 -.-> n64
  n54 --> n64
  n57 --> n64
  n61 -.-> n64
  n63 --> n64
  n68 --> n64
  n69 --> n64
  n70 --> n64
  n71 --> n64
  n189 --> n64
  n191 --> n64
  n526 --> n64
  n9 --> n65
  n50 -.-> n65
  n61 -.-> n65
  n69 --> n65
  n71 --> n65
  n0 -.-> n66
  n1 -.-> n66
  n50 -.-> n66
  n61 -.-> n66
  n64 --> n66
  n158 --> n66
  n181 -.-> n66
  n50 -.-> n67
  n61 -.-> n67
  n64 --> n67
  n97 --> n67
  n11 --> n69
  n50 -.-> n69
  n56 --> n69
  n58 --> n69
  n61 -.-> n69
  n50 -.-> n70
  n55 --> n70
  n61 -.-> n70
  n50 -.-> n72
  n61 -.-> n72
  n67 --> n72
  n73 --> n72
  n92 --> n72
  n133 --> n72
  n18 --> n73
  n50 -.-> n73
  n61 -.-> n73
  n76 --> n73
  n50 -.-> n74
  n61 -.-> n74
  n65 --> n74
  n71 --> n74
  n178 --> n74
  n19 --> n75
  n35 --> n75
  n93 --> n75
  n0 -.-> n77
  n1 -.-> n77
  n50 -.-> n77
  n61 -.-> n77
  n65 --> n77
  n66 --> n77
  n181 -.-> n77
  n209 --> n77
  n210 --> n77
  n212 -.-> n77
```

- [ElectronicStructure.railMove_count](../../FQChem/Complexity/ElectronicStructure.lean#L110)
- [ElectronicStructure.railMove_twice](../../FQChem/Complexity/ElectronicStructure.lean#L104)
- [AmplificationBounds.polynomial_size](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L31)
- [AmplificationBounds.reaches_precision](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L72)
- [AmplificationBounds.size_after](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L20)
- [AmplifierCost.compile_correct](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L473)
- [AmplifierCost.compile_time](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L515)
- [AmplifierCost.length_le_steps](../../integrations/qatlib/FQChemKitaev/AmplifierCost.lean#L552)
- [Amplify.copy_ne](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L31) (private)
- [Amplify.repeat_accept](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L259)
- [Amplify.repeat_all_zero](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L243)
- [Amplify.repeat_gate_count](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L236)
- [Amplify.repeat_reject](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L265)
- [Amplify.repeat_width](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L240)
- [Amplify.word_legal](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L139)
- [Amplify.zeroAcceptance_mem](../../integrations/qatlib/FQChemKitaev/Amplify.lean#L248)
- [amplified_promise](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L49)
- [amplified_size](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L35)
- [circuit_to_electronic_energy](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L143)
- [circuit_to_local_energy](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L79)
- [denominator_ge_four](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L44) (private)
- [growth](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L29) (private)
- [initialized_after](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L38) (private)
- [size_positive](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L27) (private)
- [transducer_correct](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L116)
- [transducer_output](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L94) (private)
- [transducer_promise_gap](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L130)
- [transducer_time](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L101)
- [transducer_value](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L91) (private)
- [uniform_circuit_to_electronic_energy](../../integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L156)
- [Compiler.compileBits_correct](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L661)
- [Compiler.compileBits_time](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L667)
- [Compiler.compile_energyPromise](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L480)
- [Compiler.unbinary_compileBits](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L656)
- [ElectronicStructure.circuit_to_fixedParticle](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L198)
- [HistoryHamiltonian.promiseGap](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L97)
- [HistoryHamiltonian.resources](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L79)
- [HistoryHamiltonian.witnessFree_acceptance](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L187)
- [HistoryHamiltonian.zero_input_legal](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L178)
- [UniformCircuits.generated_electronic_promise](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L139)
- [UniformCircuits.history_acceptance](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L123)
- [UniformCircuits.inputWord_legal](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L60)
- [Qubit.normalized_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L152)

## FQChemKitaev.Compiler

```mermaid
flowchart LR
  n78["afterBits_reduction"]
  n79["after_energyPromise"]
  n80["after_time"]
  n81["binary_cost"]
  n82["binary_eq_binaryLoop"]
  n83["binary_roundtrip"]
  n84["cell_funded"]
  n85["charge_funded"]
  n86["clock_steps"]
  n87["clocks_funded"]
  n88["clocks_val"]
  n89["cols_funded"]
  n90["cols_steps"]
  n91["cols_val"]
  n92["compileBits_correct"]
  n93["compileBits_time"]
  n94["compileRows_funded"]
  n95["compileRows_steps"]
  n96["compile_correct"]
  n97["compile_energyPromise"]
  n98["compile_tape"]
  n99["compile_time"]
  n100["count_spec"]
  n101["emit_val"]
  n102["energyPromise_disjoint"]
  n103["fields_funded"]
  n104["fields_steps"]
  n105["fields_val"]
  n106["init_funded"]
  n107["init_steps"]
  n108["init_val"]
  n109["length_compile_le_steps"]
  n110["pad_spec"]
  n111["paddedWord"]
  n112["prop_funded"]
  n113["prop_steps"]
  n114["prop_val"]
  n115["readBitPairs_spec"]
  n116["read_descriptorRow"]
  n117["read_gateRow"]
  n118["read_records"]
  n119["rowLength_le"]
  n120["rowMember_le"]
  n121["rowsLength_le"]
  n122["rowsMember_le"]
  n123["scan_budget"]
  n124["scan_cost"]
  n125["scan_emit"]
  n126["scan_eq_scanLoop"]
  n127["scan_fields"]
  n128["scan_serialize"]
  n129["scan_tallies"]
  n130["tallies_funded"]
  n131["tallies_steps"]
  n132["tallies_val"]
  n133["unbinary_compileBits"]
  n134["unbinary_cost"]
  n135["unbinary_eq_unbinaryLoop"]
  n171["HistoryHamiltonian.cutoffDen_pos"]
  n175["HistoryHamiltonian.groundEnergy_promise"]
  n179["HistoryHamiltonian.rationalCutoffs"]
  n181["HistoryHamiltonian.resources"]
  n185["HistoryHamiltonian.termDescriptors_correct"]
  n83 --> n78
  n93 --> n78
  n97 --> n78
  n97 --> n79
  n99 --> n80
  n90 --> n86
  n85 --> n87
  n89 --> n87
  n91 --> n88
  n84 --> n89
  n85 --> n89
  n103 --> n89
  n104 --> n90
  n105 --> n91
  n83 --> n92
  n96 --> n92
  n81 --> n93
  n99 --> n93
  n109 --> n93
  n134 --> n93
  n84 --> n94
  n85 --> n94
  n87 --> n94
  n103 --> n94
  n106 --> n94
  n112 --> n94
  n86 --> n95
  n100 --> n95
  n104 --> n95
  n107 --> n95
  n110 --> n95
  n113 --> n95
  n119 --> n95
  n120 --> n95
  n121 --> n95
  n122 --> n95
  n98 --> n96
  n118 --> n96
  n128 --> n96
  n185 --> n96
  n96 --> n97
  n171 --> n97
  n175 --> n97
  n179 --> n97
  n181 --> n97
  n88 --> n98
  n100 --> n98
  n101 --> n98
  n105 --> n98
  n108 --> n98
  n111 --> n98
  n114 --> n98
  n128 --> n98
  n95 --> n99
  n123 --> n99
  n124 --> n99
  n105 --> n101
  n84 --> n103
  n85 --> n103
  n130 --> n103
  n131 --> n104
  n132 --> n105
  n84 --> n106
  n85 --> n106
  n103 --> n106
  n104 --> n107
  n105 --> n108
  n85 --> n109
  n94 --> n109
  n110 --> n111
  n84 --> n112
  n85 --> n112
  n103 --> n112
  n104 --> n113
  n105 --> n114
  n117 --> n116
  n116 --> n118
  n124 --> n123
  n124 --> n125
  n127 --> n125
  n124 --> n127
  n129 --> n127
  n125 --> n128
  n124 --> n129
  n84 --> n130
  n85 --> n130
  n83 --> n133
  n115 --> n135
```

- [afterBits_reduction](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L683)
- [after_energyPromise](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L512)
- [after_time](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L502)
- [binary_cost](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L636) (private)
- [binary_eq_binaryLoop](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L603)
- [binary_roundtrip](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L633)
- [cell_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L523) (private)
- [charge_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L520) (private)
- [clock_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L392) (private)
- [clocks_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L552) (private)
- [clocks_val](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L261) (private)
- [cols_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L546) (private)
- [cols_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L380) (private)
- [cols_val](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L252) (private)
- [compileBits_correct](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L661)
- [compileBits_time](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L667)
- [compileRows_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L558) (private)
- [compileRows_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L403) (private)
- [compile_correct](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L295)
- [compile_energyPromise](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L480)
- [compile_tape](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L277)
- [compile_time](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L451)
- [count_spec](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L176)
- [emit_val](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L235) (private)
- [energyPromise_disjoint](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L473)
- [fields_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L529) (private)
- [fields_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L349) (private)
- [fields_val](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L231) (private)
- [init_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L540) (private)
- [init_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L368) (private)
- [init_val](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L248) (private)
- [length_compile_le_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L570)
- [pad_spec](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L185)
- [paddedWord](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L271) (private)
- [prop_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L534) (private)
- [prop_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L355) (private)
- [prop_val](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L239) (private)
- [readBitPairs_spec](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L615) (private)
- [read_descriptorRow](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L150)
- [read_gateRow](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L133)
- [read_records](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L289) (private)
- [rowLength_le](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L312) (private)
- [rowMember_le](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L315) (private)
- [rowsLength_le](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L325) (private)
- [rowsMember_le](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L328) (private)
- [scan_budget](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L339) (private)
- [scan_cost](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L87)
- [scan_emit](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L104) (private)
- [scan_eq_scanLoop](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L81)
- [scan_fields](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L97) (private)
- [scan_serialize](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L113)
- [scan_tallies](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L90) (private)
- [tallies_funded](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L526) (private)
- [tallies_steps](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L345) (private)
- [tallies_val](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L227) (private)
- [unbinary_compileBits](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L656)
- [unbinary_cost](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L639) (private)
- [unbinary_eq_unbinaryLoop](../../integrations/qatlib/FQChemKitaev/Compiler.lean#L629)
- [HistoryHamiltonian.cutoffDen_pos](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L233)
- [HistoryHamiltonian.groundEnergy_promise](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L139)
- [HistoryHamiltonian.rationalCutoffs](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L238)
- [HistoryHamiltonian.resources](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L79)
- [HistoryHamiltonian.termDescriptors_correct](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L342)

## FQChemKitaev.DyadicCoefficients

```mermaid
flowchart LR
  n136["bitSubtract"]
  n137["circuit_atom_cost"]
  n138["gateOutput_spec"]
  n139["increment_spec"]
  n140["materialize_floor"]
  n141["materialize_spec"]
  n142["next_value"]
  n143["pow2bits"]
  n144["propagation_from_bits"]
  n145["rootOutput_correct"]
  n146["rootOutput_resources"]
  n147["run_certificate"]
  n148["run_isqrt"]
  n149["run_shape"]
  n150["subtract_borrow"]
  n151["subtract_shape"]
  n152["subtract_value"]
  n153["value_lt"]
  n154["value_tail"]
  n517["QmaCompletenessNumerics.floor_atom"]
  n141 --> n137
  n141 --> n138
  n141 --> n140
  n517 --> n140
  n143 --> n141
  n145 --> n141
  n146 --> n141
  n150 --> n142
  n152 --> n142
  n138 --> n144
  n139 --> n145
  n147 --> n145
  n148 --> n145
  n154 --> n145
  n139 --> n146
  n149 --> n146
  n142 --> n147
  n149 --> n147
  n147 --> n148
  n151 --> n149
  n151 --> n150
  n152 --> n150
  n153 --> n150
  n136 --> n152
```

- [bitSubtract](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L43) (private)
- [circuit_atom_cost](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L296)
- [gateOutput_spec](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L282)
- [increment_spec](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L196)
- [materialize_floor](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L272)
- [materialize_spec](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L262)
- [next_value](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L128) (private)
- [pow2bits](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L256) (private)
- [propagation_from_bits](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L306)
- [rootOutput_correct](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L224)
- [rootOutput_resources](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L240)
- [run_certificate](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L165)
- [run_isqrt](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L177)
- [run_shape](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L115)
- [subtract_borrow](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L88)
- [subtract_shape](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L63)
- [subtract_value](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L72)
- [value_lt](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L35)
- [value_tail](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L203) (private)
- [QmaCompletenessNumerics.floor_atom](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/QmaCompletenessNumerics.lean#L191)

## FQChemKitaev.ElectronicStructure

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
  n155["circuitFermionResources"]
  n156["circuitPenalty_sufficient"]
  n157["circuitTables"]
  n158["circuit_to_fixedParticle"]
  n159["decodeHamiltonian"]
  n160["decodeTerm_kernel"]
  n161["distinctWire_range"]
  n162["distinctWire_readWire"]
  n163["electronCount"]
  n164["electronicPreparation_decides"]
  n165["entry_norm_bound"]
  n166["ground_le_trial"]
  n167["outside_iff"]
  n168["tableIndex_restrict"]
  n169["table_is_global_entry"]
  n171["HistoryHamiltonian.cutoffDen_pos"]
  n178["HistoryHamiltonian.promiseGap"]
  n179["HistoryHamiltonian.rationalCutoffs"]
  n181["HistoryHamiltonian.resources"]
  n188["HistoryHamiltonian.witnessEnergy_promise"]
  n541["QmaCompletenessPadding.paid64_length"]
  n3 --> n155
  n157 --> n155
  n181 -.-> n155
  n4 --> n156
  n157 --> n156
  n171 --> n156
  n179 --> n156
  n181 -.-> n156
  n160 --> n157
  n165 --> n157
  n169 --> n157
  n181 --> n157
  n0 -.-> n158
  n1 -.-> n158
  n5 --> n158
  n156 --> n158
  n159 --> n158
  n181 -.-> n158
  n188 --> n158
  n160 --> n159
  n6 --> n160
  n161 --> n160
  n167 --> n160
  n168 --> n160
  n541 --> n163
  n0 -.-> n164
  n1 -.-> n164
  n158 --> n164
  n166 --> n164
  n178 --> n164
  n181 -.-> n164
  n0 -.-> n166
  n1 -.-> n166
  n2 --> n166
  n7 --> n166
  n181 -.-> n166
  n162 --> n168
  n6 --> n169
```

- [ElectronicStructure.railMove_count](../../FQChem/Complexity/ElectronicStructure.lean#L110)
- [ElectronicStructure.railMove_twice](../../FQChem/Complexity/ElectronicStructure.lean#L104)
- [ElectronicStructureOperators.fermionExpectation](../../FQChem/Complexity/ElectronicStructureOperators.lean#L167)
- [ElectronicStructurePauli.localExpansion_size](../../FQChem/Complexity/ElectronicStructurePauli.lean#L198)
- [ElectronicStructurePauli.localExpansion_strength](../../FQChem/Complexity/ElectronicStructurePauli.lean#L232)
- [ElectronicStructurePauli.localHamiltonian_to_fixedParticle](../../FQChem/Complexity/ElectronicStructurePauli.lean#L209)
- [ElectronicStructurePauli.untouched_eq](../../FQChem/Complexity/ElectronicStructurePauli.lean#L114)
- [RayleighRitz.groundEnergy_le](../../FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L49)
- [circuitFermionResources](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L187)
- [circuitPenalty_sufficient](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L161) (private)
- [circuitTables](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L150)
- [circuit_to_fixedParticle](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L198)
- [decodeHamiltonian](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L112)
- [decodeTerm_kernel](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L97)
- [distinctWire_range](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L48)
- [distinctWire_readWire](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L43)
- [electronCount](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L176)
- [electronicPreparation_decides](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L224)
- [entry_norm_bound](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L138) (private)
- [ground_le_trial](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L211) (private)
- [outside_iff](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L83) (private)
- [tableIndex_restrict](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L61)
- [table_is_global_entry](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L128) (private)
- [HistoryHamiltonian.cutoffDen_pos](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L233)
- [HistoryHamiltonian.promiseGap](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L97)
- [HistoryHamiltonian.rationalCutoffs](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L238)
- [HistoryHamiltonian.resources](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L79)
- [HistoryHamiltonian.witnessEnergy_promise](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L123)
- [QmaCompletenessPadding.paid64_length](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessPadding.lean#L103)

## FQChemKitaev.HistoryHamiltonian

```mermaid
flowchart LR
  n170["cutoffDen_le"]
  n171["cutoffDen_pos"]
  n172["energy_range_bddBelow"]
  n173["energy_range_nonempty"]
  n174["estimate_decides"]
  n175["groundEnergy_promise"]
  n176["localEnergy_disjoint"]
  n177["preparation_and_measurement_decide"]
  n178["promiseGap"]
  n179["rationalCutoffs"]
  n180["reduction_length"]
  n181["resources"]
  n182["run_scalar"]
  n183["scalarEntries_bound"]
  n184["serialize_injective"]
  n185["termDescriptors_correct"]
  n186["termDescriptors_count"]
  n187["verifier_reduction"]
  n188["witnessEnergy_promise"]
  n189["witnessFree_acceptance"]
  n190["witnessFree_groundEnergy"]
  n191["zero_input_legal"]
  n475["QmaCompletenessRefined.clause3Aux_encNat_selfDelimiting"]
  n476["QmaCompletenessRefined.clause3Aux_toBits_injective"]
  n506["QmaCompletenessNativeOutput.outputTerms_length"]
  n519["EventProbability.measureProb_smul"]
  n523["Qubit.inner_apply"]
  n526["Qubit.normalized_ket"]
  n535["QmaCompleteness.qma_history_locality_description_and_energy_bounds"]
  n536["QmaCompletenessNormalized.denominator_le_poly"]
  n537["QmaCompletenessNormalized.denominator_pos"]
  n538["QmaCompletenessNormalized.gap_inverse_poly"]
  n539["QmaCompletenessNormalized.gap_positive"]
  n540["QmaCompletenessNormalized.padded_normalized_contract"]
  n541["QmaCompletenessPadding.paid64_length"]
  n542["QmaCompletenessSize.encNat_length_le_self"]
  n543["QmaCompletenessSize.termEntries_length"]
  n536 --> n170
  n541 --> n170
  n537 --> n171
  n523 --> n172
  n526 --> n173
  n175 --> n174
  n178 --> n174
  n172 --> n175
  n173 --> n175
  n188 --> n175
  n184 --> n176
  n172 --> n177
  n175 --> n177
  n178 --> n177
  n538 --> n178
  n539 --> n178
  n541 --> n178
  n537 --> n179
  n170 --> n180
  n181 --> n180
  n542 --> n180
  n535 --> n181
  n541 --> n181
  n181 --> n183
  n543 --> n183
  n475 --> n184
  n476 --> n184
  n185 -.-> n186
  n506 --> n186
  n171 --> n187
  n175 --> n187
  n179 --> n187
  n181 --> n187
  n540 --> n188
  n541 --> n188
  n182 --> n189
  n519 --> n189
  n175 --> n190
  n189 --> n190
  n191 --> n190
  n526 --> n190
```

- [cutoffDen_le](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L246)
- [cutoffDen_pos](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L233)
- [energy_range_bddBelow](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L39) (private)
- [energy_range_nonempty](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L35) (private)
- [estimate_decides](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L154)
- [groundEnergy_promise](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L139)
- [localEnergy_disjoint](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L291)
- [preparation_and_measurement_decide](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L389)
- [promiseGap](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L97)
- [rationalCutoffs](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L238)
- [reduction_length](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L274)
- [resources](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L79)
- [run_scalar](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L172) (private)
- [scalarEntries_bound](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L358)
- [serialize_injective](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L268)
- [termDescriptors_correct](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L342)
- [termDescriptors_count](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L350)
- [verifier_reduction](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L300)
- [witnessEnergy_promise](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L123)
- [witnessFree_acceptance](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L187)
- [witnessFree_groundEnergy](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L206)
- [zero_input_legal](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L178)
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

## FQChemKitaev.Majority

```mermaid
flowchart LR
  n192["distinct"]
  n193["error_bound"]
  n194["failure_probability"]
  n195["independent_votes"]
  n196["involution"]
  n197["productMass"]
  n198["read_toggle"]
  n199["readout_probability"]
  n200["squared_error_decay"]
  n201["three_copy_readout"]
  n202["three_level_halving"]
  n203["toffoli_legal"]
  n204["toffoli_run"]
  n205["word_amplitude"]
  n206["word_ket"]
  n207["word_legal"]
  n208["word_length"]
  n474["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n513["FiniteThermalToffoli.thermalToffoliWord_exact"]
  n534["Circuit.run_append"]
  n199 --> n195
  n198 --> n196
  n192 --> n198
  n196 --> n199
  n205 --> n199
  n193 --> n200
  n195 --> n201
  n197 --> n201
  n193 --> n202
  n203 --> n204
  n513 --> n204
  n196 --> n205
  n206 --> n205
  n474 --> n205
  n192 --> n206
  n204 --> n206
  n534 --> n206
  n192 --> n207
  n203 --> n207
```

- [distinct](../../integrations/qatlib/FQChemKitaev/Majority.lean#L44) (private)
- [error_bound](../../integrations/qatlib/FQChemKitaev/Majority.lean#L220)
- [failure_probability](../../integrations/qatlib/FQChemKitaev/Majority.lean#L211)
- [independent_votes](../../integrations/qatlib/FQChemKitaev/Majority.lean#L159)
- [involution](../../integrations/qatlib/FQChemKitaev/Majority.lean#L52) (private)
- [productMass](../../integrations/qatlib/FQChemKitaev/Majority.lean#L177) (private)
- [read_toggle](../../integrations/qatlib/FQChemKitaev/Majority.lean#L47) (private)
- [readout_probability](../../integrations/qatlib/FQChemKitaev/Majority.lean#L124)
- [squared_error_decay](../../integrations/qatlib/FQChemKitaev/Majority.lean#L247)
- [three_copy_readout](../../integrations/qatlib/FQChemKitaev/Majority.lean#L187)
- [three_level_halving](../../integrations/qatlib/FQChemKitaev/Majority.lean#L237)
- [toffoli_legal](../../integrations/qatlib/FQChemKitaev/Majority.lean#L63) (private)
- [toffoli_run](../../integrations/qatlib/FQChemKitaev/Majority.lean#L79) (private)
- [word_amplitude](../../integrations/qatlib/FQChemKitaev/Majority.lean#L103)
- [word_ket](../../integrations/qatlib/FQChemKitaev/Majority.lean#L86)
- [word_legal](../../integrations/qatlib/FQChemKitaev/Majority.lean#L70)
- [word_length](../../integrations/qatlib/FQChemKitaev/Majority.lean#L61)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)
- [FiniteThermalToffoli.thermalToffoliWord_exact](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalToffoli.lean#L60)
- [Circuit.run_append](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean#L249)

## FQChemKitaev.UniformCircuits

```mermaid
flowchart LR
  n0["ElectronicStructure.railMove_count"]
  n1["ElectronicStructure.railMove_twice"]
  n158["ElectronicStructure.circuit_to_fixedParticle"]
  n181["HistoryHamiltonian.resources"]
  n189["HistoryHamiltonian.witnessFree_acceptance"]
  n191["HistoryHamiltonian.zero_input_legal"]
  n209["generated_electronic_promise"]
  n210["history_acceptance"]
  n211["initialized_acceptance"]
  n212["inputWord_legal"]
  n213["inputWord_length"]
  n214["inputWord_prepares"]
  n215["load_subset"]
  n216["reject_probability"]
  n454["LocalReflectionGates.applyGate_wireGate_ket"]
  n526["Qubit.normalized_ket"]
  n534["Circuit.run_append"]
  n0 -.-> n209
  n1 -.-> n209
  n158 --> n209
  n181 -.-> n209
  n189 --> n209
  n191 --> n209
  n210 --> n209
  n212 -.-> n209
  n213 --> n209
  n526 --> n209
  n211 --> n210
  n212 -.-> n210
  n216 --> n210
  n212 -.-> n211
  n214 --> n211
  n534 --> n211
  n215 --> n214
  n454 --> n215
  n534 --> n215
```

- [ElectronicStructure.railMove_count](../../FQChem/Complexity/ElectronicStructure.lean#L110)
- [ElectronicStructure.railMove_twice](../../FQChem/Complexity/ElectronicStructure.lean#L104)
- [ElectronicStructure.circuit_to_fixedParticle](../../integrations/qatlib/FQChemKitaev/ElectronicStructure.lean#L198)
- [HistoryHamiltonian.resources](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L79)
- [HistoryHamiltonian.witnessFree_acceptance](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L187)
- [HistoryHamiltonian.zero_input_legal](../../integrations/qatlib/FQChemKitaev/HistoryHamiltonian.lean#L178)
- [generated_electronic_promise](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L139)
- [history_acceptance](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L123)
- [initialized_acceptance](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L82)
- [inputWord_legal](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L60)
- [inputWord_length](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L57)
- [inputWord_prepares](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L63)
- [load_subset](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L33) (private)
- [reject_probability](../../integrations/qatlib/FQChemKitaev/UniformCircuits.lean#L110) (private)
- [LocalReflectionGates.applyGate_wireGate_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L343)
- [Qubit.normalized_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L152)
- [Circuit.run_append](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean#L249)

## FQChemKitaev.Wiring

```mermaid
flowchart LR
  n217["onWires_legal"]
  n218["onWires_length"]
  n219["onWires_run"]
  n220["one_wire"]
  n221["renamedGate_action"]
  n222["renamedGate_legal"]
  n223["two_wires"]
  n224["wireGate_mulVec_update"]
  n455["LocalReflectionGates.cnotUpdate_involutive"]
  n456["LocalReflectionGates.wireGate_apply"]
  n520["Qubit.applyGate_permMatrix"]
  n222 --> n217
  n221 --> n219
  n224 --> n220
  n220 --> n221
  n223 --> n221
  n455 --> n223
  n520 --> n223
  n456 --> n224
```

- [onWires_legal](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L162)
- [onWires_length](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L168)
- [onWires_run](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L173)
- [one_wire](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L115) (private)
- [renamedGate_action](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L145) (private)
- [renamedGate_legal](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L133)
- [two_wires](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L124) (private)
- [wireGate_mulVec_update](../../integrations/qatlib/FQChemKitaev/Wiring.lean#L31) (private)
- [LocalReflectionGates.cnotUpdate_involutive](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L184)
- [LocalReflectionGates.wireGate_apply](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L83)
- [Qubit.applyGate_permMatrix](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L307)

## FQChemQatlib.Complexity.QueryAlgorithms

```mermaid
flowchart LR
  n225["shorFactoringSuccess"]
  n226["shorTwoSampleOrder"]
  n227["shorWindowRecovery"]
  n228["simonClassicalQueryBound"]
  n229["simonMaskRecovery"]
  n230["simonOracleFamilySeparation"]
  n471["ResidueFactoringAlgorithmShor.residueFactoringAlgorithm"]
  n472["PairLCMOrderRecovery.pair_lcm_order_actual_fresh_success_bound"]
  n545["Theorem32Paper.simonTheorem32"]
  n549["InfiniteOracle.simon_infiniteOracle_separation"]
  n553["Theorem34Separation.simonTheorem33RealBudget"]
  n555["SourceWindowDecode.source_clock_residue_window_actual_decoder_recovery"]
  n471 --> n225
  n472 --> n226
  n555 --> n227
  n553 --> n228
  n545 --> n229
  n549 --> n230
```

- [shorFactoringSuccess](../../integrations/qatlib/FQChemQatlib/Complexity/QueryAlgorithms.lean#L79)
- [shorTwoSampleOrder](../../integrations/qatlib/FQChemQatlib/Complexity/QueryAlgorithms.lean#L69)
- [shorWindowRecovery](../../integrations/qatlib/FQChemQatlib/Complexity/QueryAlgorithms.lean#L59)
- [simonClassicalQueryBound](../../integrations/qatlib/FQChemQatlib/Complexity/QueryAlgorithms.lean#L41)
- [simonMaskRecovery](../../integrations/qatlib/FQChemQatlib/Complexity/QueryAlgorithms.lean#L34)
- [simonOracleFamilySeparation](../../integrations/qatlib/FQChemQatlib/Complexity/QueryAlgorithms.lean#L49)
- [ResidueFactoringAlgorithmShor.residueFactoringAlgorithm](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/PeriodSampling/FactorAlgorithm/ResidueFactoringAlgorithmShor.lean#L132)
- [PairLCMOrderRecovery.pair_lcm_order_actual_fresh_success_bound](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/PeriodSampling/OrderRecovery/PairLCMOrderRecovery.lean#L243)
- [Theorem32Paper.simonTheorem32](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/Recovery/Theorem32Paper.lean#L112)
- [InfiniteOracle.simon_infiniteOracle_separation](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/StandardModel/InfiniteOracle.lean#L369)
- [Theorem34Separation.simonTheorem33RealBudget](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/StandardModel/Theorem34Separation.lean#L114)
- [SourceWindowDecode.source_clock_residue_window_actual_decoder_recovery](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/ShorFactoring97/OrderRecovery/SourceWindowDecode.lean#L299)

## FQChemQatlib.Complexity.SimonOracleMachines

```mermaid
flowchart LR
  n231["existsHardAt"]
  n232["outputCongr"]
  n233["restrictBound"]
  n234["restrictOutput"]
  n235["successCongr"]
  n236["oracleSeparation"]
  n425["FiniteStoppingTail.expectation_congr"]
  n466["RandomizedCost.expectation_map"]
  n546["InfiniteOracle.exists_good_low"]
  n547["InfiniteOracle.exists_length_of_index"]
  n548["InfiniteOracle.simonQuantumSuccess_good"]
  n233 --> n231
  n234 --> n231
  n466 --> n231
  n546 --> n231
  n232 --> n235
  n425 --> n235
  n231 --> n236
  n235 --> n236
  n547 --> n236
  n548 --> n236
```

- [existsHardAt](../../integrations/qatlib/FQChemQatlib/Complexity/SimonOracleMachines.lean#L92)
- [outputCongr](../../integrations/qatlib/FQChemQatlib/Complexity/SimonOracleMachines.lean#L74)
- [restrictBound](../../integrations/qatlib/FQChemQatlib/Complexity/SimonOracleMachines.lean#L51)
- [restrictOutput](../../integrations/qatlib/FQChemQatlib/Complexity/SimonOracleMachines.lean#L62)
- [successCongr](../../integrations/qatlib/FQChemQatlib/Complexity/SimonOracleMachines.lean#L84)
- [oracleSeparation](../../integrations/qatlib/FQChemQatlib/Complexity/SimonOracleMachines.lean#L115)
- [FiniteStoppingTail.expectation_congr](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/AEMeanReadout/LocalAEBackend/FiniteStoppingTail.lean#L53)
- [RandomizedCost.expectation_map](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LinearLearning/ConcisePipeline/RandomizedCost.lean#L116)
- [InfiniteOracle.exists_good_low](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/StandardModel/InfiniteOracle.lean#L286)
- [InfiniteOracle.exists_length_of_index](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/StandardModel/InfiniteOracle.lean#L359)
- [InfiniteOracle.simonQuantumSuccess_good](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/StandardModel/InfiniteOracle.lean#L186)

## FQChemQatlib.Complexity.SimonTuringSeparation

```mermaid
flowchart LR
  n236["SimonOracleMachines.oracleSeparation"]
  n237["cellsStep"]
  n238["replyCells"]
  n239["wordLength"]
  n240["padOutput"]
  n241["amplifiedCorrect"]
  n242["clockDominates"]
  n243["polynomialWork"]
  n244["turingSeparation"]
  n245["unaryLabel"]
  n246["unaryLanguageSeparation"]
  n247["unrollOutput"]
  n465["BooleanGaussianDecoder.boolean_gaussian_actual_operation_bound"]
  n466["RandomizedCost.expectation_map"]
  n550["JointSeparation.simonReject_total"]
  n551["SimonRetry.simonExactLedger_eq"]
  n552["Theorem34Separation.simonPaperScheduleLedger"]
  n550 --> n241
  n465 --> n243
  n551 --> n243
  n552 --> n243
  n236 --> n244
  n237 -.-> n244
  n238 -.-> n244
  n239 -.-> n244
  n247 --> n244
  n466 --> n244
  n552 --> n244
  n241 --> n246
  n243 --> n246
  n244 --> n246
  n237 -.-> n247
  n238 -.-> n247
  n239 -.-> n247
  n240 --> n247
```

- [SimonOracleMachines.oracleSeparation](../../integrations/qatlib/FQChemQatlib/Complexity/SimonOracleMachines.lean#L115)
- [cellsStep](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L58)
- [replyCells](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L76)
- [wordLength](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L67)
- [padOutput](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L139)
- [amplifiedCorrect](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L224)
- [clockDominates](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L254)
- [polynomialWork](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L241)
- [turingSeparation](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L191)
- [unaryLabel](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L213)
- [unaryLanguageSeparation](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L273)
- [unrollOutput](../../integrations/qatlib/FQChemQatlib/Complexity/SimonTuringSeparation.lean#L166)
- [BooleanGaussianDecoder.boolean_gaussian_actual_operation_bound](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HspRecovery/Reduction/BooleanGaussianDecoder.lean#L1764)
- [RandomizedCost.expectation_map](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LinearLearning/ConcisePipeline/RandomizedCost.lean#L116)
- [JointSeparation.simonReject_total](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/StandardModel/JointSeparation.lean#L122)
- [SimonRetry.simonExactLedger_eq](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/StandardModel/SimonRetry.lean#L108)
- [Theorem34Separation.simonPaperScheduleLedger](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QPowerSimon97/StandardModel/Theorem34Separation.lean#L64)

## FQChemQatlib.Dynamics.BorrowedControls

```mermaid
flowchart LR
  n248["allFlip"]
  n249["bit"]
  n250["borrowedMCX"]
  n251["carryFlip"]
  n252["carry_congr"]
  n253["carry_xor"]
  n254["coherentMCX"]
  n255["compose"]
  n256["controlledBit"]
  n257["many"]
  n258["manyFromPath"]
  n259["readCarry"]
  n260["restore"]
  n261["toff"]
  n262["toggleDifference"]
  n263["weaken"]
  n264["zipNames"]
  n453["LocalReflectionGates.applyGate_cnotGate_ket"]
  n454["LocalReflectionGates.applyGate_wireGate_ket"]
  n474["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n513["FiniteThermalToffoli.thermalToffoliWord_exact"]
  n534["Circuit.run_append"]
  n454 --> n249
  n248 --> n250
  n257 --> n250
  n262 --> n250
  n263 --> n250
  n252 --> n251
  n250 --> n254
  n474 --> n254
  n534 --> n255
  n453 --> n256
  n249 --> n257
  n256 --> n257
  n258 --> n257
  n261 --> n257
  n263 --> n257
  n264 --> n257
  n251 --> n258
  n253 --> n258
  n259 --> n258
  n261 --> n258
  n262 --> n258
  n263 --> n258
  n252 --> n259
  n255 --> n259
  n261 --> n259
  n263 --> n259
  n513 --> n261
  n255 --> n262
  n260 --> n262
  n263 --> n262
```

- [allFlip](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L163) (private)
- [bit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L54)
- [borrowedMCX](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L245)
- [carryFlip](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L171) (private)
- [carry_congr](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L78) (private)
- [carry_xor](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L89) (private)
- [coherentMCX](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L275)
- [compose](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L34)
- [controlledBit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L62)
- [many](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L216) (private)
- [manyFromPath](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L183) (private)
- [readCarry](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L100) (private)
- [restore](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L140) (private)
- [toff](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L44)
- [toggleDifference](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L148) (private)
- [weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L41)
- [zipNames](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L204) (private)
- [LocalReflectionGates.applyGate_cnotGate_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L205)
- [LocalReflectionGates.applyGate_wireGate_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L343)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)
- [FiniteThermalToffoli.thermalToffoliWord_exact](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalToffoli.lean#L60)
- [Circuit.run_append](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean#L249)

## FQChemQatlib.Dynamics.LowChuangBinaryCompare

```mermaid
flowchart LR
  n249["BorrowedControls.bit"]
  n255["BorrowedControls.compose"]
  n261["BorrowedControls.toff"]
  n265["address_mem"]
  n266["carry_order"]
  n267["output_address"]
  n268["result_address"]
  n269["ripple_result"]
  n270["ripple_word"]
  n271["step_exact"]
  n272["step_valid"]
  n273["tail_valid"]
  n274["unchanged"]
  n512["FiniteThermalComparator.thermalLexLess_numeric"]
  n266 --> n269
  n267 --> n269
  n273 --> n269
  n274 --> n269
  n512 --> n269
  n255 --> n270
  n271 --> n270
  n272 --> n270
  n273 --> n270
  n249 --> n271
  n255 --> n271
  n261 --> n271
  n268 --> n272
```

- [BorrowedControls.bit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L54)
- [BorrowedControls.compose](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L34)
- [BorrowedControls.toff](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L44)
- [address_mem](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L55) (private)
- [carry_order](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L26) (private)
- [output_address](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L94) (private)
- [result_address](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L58) (private)
- [ripple_result](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L101)
- [ripple_word](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L84)
- [step_exact](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L32) (private)
- [step_valid](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L67) (private)
- [tail_valid](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L62) (private)
- [unchanged](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L74)
- [FiniteThermalComparator.thermalLexLess_numeric](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalComparator.lean#L70)

## FQChemQatlib.Dynamics.LowChuangBinaryDecoder

```mermaid
flowchart LR
  n269["LowChuangBinaryCompare.ripple_result"]
  n270["LowChuangBinaryCompare.ripple_word"]
  n275["built_adj"]
  n276["built_mul"]
  n277["built_unit"]
  n278["built_weaken"]
  n279["built_word"]
  n280["cartesianDecoder"]
  n281["decoder"]
  n282["filled_pulse"]
  n283["gated_phase"]
  n284["local_unit"]
  n285["outside_col"]
  n286["outside_seed"]
  n287["packed_clean"]
  n288["pulse_word"]
  n289["LowChuangBinaryPhase.averaged_sign"]
  n290["LowChuangBinaryPhase.encoded_diagonal"]
  n297["LowChuangDecoderLayout.digits_read"]
  n298["LowChuangDecoderLayout.digits_valid"]
  n299["LowChuangDecoderLayout.protect_branch"]
  n400["LowChuangUniformBits.fill_at"]
  n401["LowChuangUniformBits.fill_out"]
  n402["LowChuangUniformBits.hWord_cost"]
  n403["LowChuangUniformBits.mean_diagonal"]
  n451["FiniteGateDescription.finiteCodeMatrix_unitary"]
  n284 --> n277
  n281 --> n280
  n287 --> n280
  n275 --> n281
  n276 --> n281
  n277 --> n281
  n278 --> n281
  n279 --> n281
  n282 --> n281
  n288 --> n281
  n289 --> n281
  n402 --> n281
  n403 --> n281
  n269 --> n282
  n285 --> n282
  n286 --> n282
  n297 --> n282
  n298 --> n282
  n400 --> n282
  n401 --> n282
  n451 --> n284
  n270 --> n288
  n275 --> n288
  n276 --> n288
  n278 --> n288
  n279 --> n288
  n283 --> n288
  n290 --> n288
  n298 --> n288
  n299 --> n288
```

- [LowChuangBinaryCompare.ripple_result](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L101)
- [LowChuangBinaryCompare.ripple_word](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L84)
- [built_adj](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L47) (private)
- [built_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L41) (private)
- [built_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L72) (private)
- [built_weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L56) (private)
- [built_word](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L28) (private)
- [cartesianDecoder](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L188)
- [decoder](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L145)
- [filled_pulse](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L117) (private)
- [gated_phase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L79) (private)
- [local_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L59) (private)
- [outside_col](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L108) (private)
- [outside_seed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L113) (private)
- [packed_clean](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L179)
- [pulse_word](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L92) (private)
- [LowChuangBinaryPhase.averaged_sign](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryPhase.lean#L26)
- [LowChuangBinaryPhase.encoded_diagonal](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryPhase.lean#L40)
- [LowChuangDecoderLayout.digits_read](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L55)
- [LowChuangDecoderLayout.digits_valid](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L31)
- [LowChuangDecoderLayout.protect_branch](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L61)
- [LowChuangUniformBits.fill_at](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L23)
- [LowChuangUniformBits.fill_out](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L28)
- [LowChuangUniformBits.hWord_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L43)
- [LowChuangUniformBits.mean_diagonal](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L49)
- [FiniteGateDescription.finiteCodeMatrix_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/FiniteGateDescription.lean#L100)

## FQChemQatlib.Dynamics.LowChuangBinaryPhase

```mermaid
flowchart LR
  n269["LowChuangBinaryCompare.ripple_result"]
  n270["LowChuangBinaryCompare.ripple_word"]
  n289["averaged_sign"]
  n290["encoded_diagonal"]
  n291["ripple_phase"]
  n473["QmaCompletenessDefs.finiteWordMatrix_unitary"]
  n474["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n511["FiniteThermalComparator.thermalBitValue_bound"]
  n514["FiniteThermalUniformH.thermalUniformBits_less_complex"]
  n511 --> n289
  n514 --> n289
  n473 --> n290
  n474 --> n290
  n269 --> n291
  n270 --> n291
  n290 --> n291
```

- [LowChuangBinaryCompare.ripple_result](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L101)
- [LowChuangBinaryCompare.ripple_word](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L84)
- [averaged_sign](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryPhase.lean#L26)
- [encoded_diagonal](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryPhase.lean#L40)
- [ripple_phase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryPhase.lean#L61)
- [QmaCompletenessDefs.finiteWordMatrix_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L158)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)
- [FiniteThermalComparator.thermalBitValue_bound](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalComparator.lean#L54)
- [FiniteThermalUniformH.thermalUniformBits_less_complex](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalUniformH.lean#L207)

## FQChemQatlib.Dynamics.LowChuangCutoff

```mermaid
flowchart LR
  n292["amplifiedTaylorCutoff"]
  n293["doubleTerm"]
  n294["geometricTail"]
  n295["leastCutoff"]
  n296["timeBound"]
  n484["ExponentialPolynomial.exponentialTaylor_eventually_error_lt"]
  n293 --> n292
  n294 --> n292
  n296 --> n292
  n484 --> n295
```

- [amplifiedTaylorCutoff](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangCutoff.lean#L69)
- [doubleTerm](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangCutoff.lean#L60) (private)
- [geometricTail](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangCutoff.lean#L44) (private)
- [leastCutoff](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangCutoff.lean#L21)
- [timeBound](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangCutoff.lean#L34) (private)
- [ExponentialPolynomial.exponentialTaylor_eventually_error_lt](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/ExponentialPolynomial.lean#L178)

## FQChemQatlib.Dynamics.LowChuangDecoderLayout

```mermaid
flowchart LR
  n274["LowChuangBinaryCompare.unchanged"]
  n297["digits_read"]
  n298["digits_valid"]
  n299["protect_branch"]
  n274 --> n299
```

- [LowChuangBinaryCompare.unchanged](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L74)
- [digits_read](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L55)
- [digits_valid](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L31)
- [protect_branch](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L61)

## FQChemQatlib.Dynamics.LowChuangElementary

```mermaid
flowchart LR
  n300["adj_emits"]
  n301["compiles_emits"]
  n302["expand"]
  n303["fixed_program"]
  n304["frameGate_emits"]
  n305["mul_emits"]
  n306["qubitRegisterSimulation"]
  n307["scalar_flags"]
  n308["scalar_pair"]
  n309["single"]
  n310["weaken"]
  n313["LowChuangFlagGates.cnotBasis_unit"]
  n316["LowChuangFlagGates.cubic_mark"]
  n320["LowChuangFlagGates.localFlip"]
  n321["LowChuangFlagGates.localHadamards"]
  n322["LowChuangFlagGates.localPhase"]
  n323["LowChuangFlagGates.localScalar"]
  n324["LowChuangFlagGates.onBlocks_apply"]
  n352["LowChuangPhysical.testAncilla_compiles"]
  n353["LowChuangPhysical.testBoth_compiles"]
  n357["LowChuangQueries.cost_append"]
  n362["LowChuangQueries.fixed_append"]
  n368["LowChuangQueries.run_append"]
  n378["LowChuangReflections.cubic_coordinate"]
  n379["LowChuangReflections.fiberPhase_sandwich"]
  n399["LowChuangStandardForm.standardFormProgram"]
  n521["Qubit.hadamard_unitary"]
  n527["Qubit.pauliX_unitary"]
  n532["Tensor.tensorGate_unitary"]
  n305 --> n301
  n309 --> n301
  n310 --> n301
  n303 --> n302
  n357 --> n302
  n362 --> n302
  n368 --> n302
  n300 --> n304
  n301 --> n304
  n305 --> n304
  n307 --> n304
  n308 --> n304
  n309 --> n304
  n310 --> n304
  n313 --> n304
  n316 --> n304
  n320 --> n304
  n321 --> n304
  n322 --> n304
  n323 --> n304
  n352 --> n304
  n353 --> n304
  n378 --> n304
  n379 --> n304
  n521 --> n304
  n527 --> n304
  n532 --> n304
  n302 --> n306
  n304 --> n306
  n399 --> n306
  n324 --> n307
```

- [adj_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L44) (private)
- [compiles_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L59) (private)
- [expand](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L127) (private)
- [fixed_program](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L119) (private)
- [frameGate_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L86)
- [mul_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L38) (private)
- [qubitRegisterSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L165)
- [scalar_flags](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L77) (private)
- [scalar_pair](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L72) (private)
- [single](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L35) (private)
- [weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L55) (private)
- [LowChuangFlagGates.cnotBasis_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L79)
- [LowChuangFlagGates.cubic_mark](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L99)
- [LowChuangFlagGates.localFlip](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L140)
- [LowChuangFlagGates.localHadamards](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L136)
- [LowChuangFlagGates.localPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L117)
- [LowChuangFlagGates.localScalar](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L146)
- [LowChuangFlagGates.onBlocks_apply](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L31)
- [LowChuangPhysical.testAncilla_compiles](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L107)
- [LowChuangPhysical.testBoth_compiles](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L127)
- [LowChuangQueries.cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [LowChuangQueries.fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [LowChuangQueries.run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [LowChuangReflections.cubic_coordinate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L104)
- [LowChuangReflections.fiberPhase_sandwich](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L40)
- [LowChuangStandardForm.standardFormProgram](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangStandardForm.lean#L32)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Qubit.pauliX_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L387)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangFlagGates

```mermaid
flowchart LR
  n311["blocks_mul"]
  n312["blocks_star"]
  n313["cnotBasis_unit"]
  n314["cnot_basis_marker"]
  n315["conditionalCnot"]
  n316["cubic_mark"]
  n317["diagonal_flags"]
  n318["flagsTensor"]
  n319["flags_conjugate"]
  n320["localFlip"]
  n321["localHadamards"]
  n322["localPhase"]
  n323["localScalar"]
  n324["onBlocks_apply"]
  n325["onFlags_unit"]
  n326["parallel_tensor"]
  n381["LowChuangReflections.zero_projector"]
  n448["ParallelQSVT.parallel_select_adjoint"]
  n449["ParallelQSVT.parallel_select_mul"]
  n450["ParallelQSVT.parallel_select_one"]
  n521["Qubit.hadamard_unitary"]
  n527["Qubit.pauliX_unitary"]
  n530["Tensor.tensorGate_mul"]
  n531["Tensor.tensorGate_one"]
  n532["Tensor.tensorGate_unitary"]
  n449 --> n311
  n448 --> n312
  n521 --> n313
  n527 --> n313
  n532 --> n313
  n324 --> n315
  n313 --> n316
  n314 --> n316
  n315 --> n316
  n319 --> n316
  n324 --> n316
  n381 --> n316
  n324 --> n317
  n324 --> n318
  n311 --> n319
  n312 --> n319
  n318 --> n320
  n531 --> n320
  n318 --> n321
  n326 --> n321
  n530 --> n321
  n317 --> n322
  n317 --> n323
  n311 --> n325
  n312 --> n325
  n450 --> n325
```

- [blocks_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L35) (private)
- [blocks_star](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L39) (private)
- [cnotBasis_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L79)
- [cnot_basis_marker](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L82) (private)
- [conditionalCnot](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L91)
- [cubic_mark](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L99)
- [diagonal_flags](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L109) (private)
- [flagsTensor](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L126)
- [flags_conjugate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L55) (private)
- [localFlip](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L140)
- [localHadamards](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L136)
- [localPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L117)
- [localScalar](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L146)
- [onBlocks_apply](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L31)
- [onFlags_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L44)
- [parallel_tensor](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L131) (private)
- [LowChuangReflections.zero_projector](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L91)
- [ParallelQSVT.parallel_select_adjoint](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L82)
- [ParallelQSVT.parallel_select_mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L70)
- [ParallelQSVT.parallel_select_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L93)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Qubit.pauliX_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L387)
- [Tensor.tensorGate_mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L114)
- [Tensor.tensorGate_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L122)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangGateWord

```mermaid
flowchart LR
  n327["adjoint_gates"]
  n328["amplification_gates"]
  n329["body_gates"]
  n330["controlled_gates"]
  n331["parallel_phase_gates"]
  n332["swapped_gates"]
  n327 --> n328
  n330 --> n329
  n331 --> n329
  n332 --> n331
```

- [adjoint_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangGateWord.lean#L87) (private)
- [amplification_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangGateWord.lean#L103)
- [body_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangGateWord.lean#L71)
- [controlled_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangGateWord.lean#L60) (private)
- [parallel_phase_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangGateWord.lean#L40) (private)
- [swapped_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangGateWord.lean#L34) (private)

## FQChemQatlib.Dynamics.LowChuangPadding

```mermaid
flowchart LR
  n306["LowChuangElementary.qubitRegisterSimulation"]
  n333["coord_iso"]
  n334["evolved_action"]
  n335["exp_action"]
  n336["finiteSimulation"]
  n337["frame_entry"]
  n338["mul_coord"]
  n339["pad_action"]
  n340["pad_hermitian"]
  n341["pad_mul"]
  n342["pad_star"]
  n343["pad_unit"]
  n344["padded_signal"]
  n345["prep_iso"]
  n346["prepared_restrict"]
  n347["star_coord_mul"]
  n428["Basic.compress_norm_le"]
  n430["CoordinateFiber.encodingFiber_isIsometry"]
  n435["Postselection.normalized_mulVec"]
  n532["Tensor.tensorGate_unitary"]
  n335 --> n334
  n339 --> n334
  n306 --> n336
  n333 --> n336
  n334 --> n336
  n340 --> n336
  n343 --> n336
  n344 --> n336
  n428 --> n336
  n435 --> n336
  n342 --> n340
  n339 --> n341
  n341 --> n343
  n342 --> n343
  n333 --> n344
  n343 --> n344
  n345 --> n344
  n346 --> n344
  n430 --> n345
  n532 --> n345
  n333 --> n346
  n337 --> n346
  n338 --> n346
  n339 --> n346
  n347 --> n346
```

- [LowChuangElementary.qubitRegisterSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L165)
- [coord_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L26)
- [evolved_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L78)
- [exp_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L63) (private)
- [finiteSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L158)
- [frame_entry](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L99) (private)
- [mul_coord](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L90) (private)
- [pad_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L34) (private)
- [pad_hermitian](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L60)
- [pad_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L44) (private)
- [pad_star](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L41) (private)
- [pad_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L53)
- [padded_signal](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L132)
- [prep_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L124) (private)
- [prepared_restrict](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L106) (private)
- [star_coord_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L95) (private)
- [Basic.compress_norm_le](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Basic.lean#L207)
- [CoordinateFiber.encodingFiber_isIsometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/EncodingCore/CoordinateFiber.lean#L90)
- [Postselection.normalized_mulVec](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Postselection.lean#L264)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangPhysical

```mermaid
flowchart LR
  n250["BorrowedControls.borrowedMCX"]
  n348["compileToggle"]
  n349["distinct_anc"]
  n350["positive_controls"]
  n351["succ_ne_inner"]
  n352["testAncilla_compiles"]
  n353["testBoth_compiles"]
  n474["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n250 --> n348
  n474 --> n348
  n348 --> n352
  n349 --> n352
  n350 --> n352
  n351 --> n352
  n348 --> n353
  n349 --> n353
  n350 --> n353
  n351 --> n353
```

- [BorrowedControls.borrowedMCX](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L245)
- [compileToggle](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L79) (private)
- [distinct_anc](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L62) (private)
- [positive_controls](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L49)
- [succ_ne_inner](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L99) (private)
- [testAncilla_compiles](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L107)
- [testBoth_compiles](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L127)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)

## FQChemQatlib.Dynamics.LowChuangQueries

```mermaid
flowchart LR
  n354["broadcast_adjoint"]
  n355["broadcast_mul"]
  n356["controlledSubstitution"]
  n357["cost_append"]
  n358["cost_controlled"]
  n359["cost_inverse"]
  n360["cost_substitute"]
  n361["covers_substitute"]
  n362["fixed_append"]
  n363["fixed_inverse"]
  n364["fixed_substitute"]
  n365["lift_adjoint"]
  n366["lift_conjugate"]
  n367["lift_mul"]
  n368["run_append"]
  n369["run_controlled"]
  n370["run_inverse"]
  n371["run_substitute"]
  n446["ParallelQSVT.parallelOracle_adjoint"]
  n448["ParallelQSVT.parallel_select_adjoint"]
  n449["ParallelQSVT.parallel_select_mul"]
  n450["ParallelQSVT.parallel_select_one"]
  n467["ControlledQueryCircuit.controlOracle_adjoint"]
  n468["ControlledQueryCircuit.controlOracle_mul"]
  n469["ControlledQueryCircuit.controlOracle_one"]
  n446 --> n354
  n449 --> n355
  n358 --> n356
  n360 --> n356
  n369 --> n356
  n371 --> n356
  n357 --> n359
  n357 --> n360
  n359 --> n360
  n362 --> n363
  n362 --> n364
  n363 --> n364
  n446 --> n365
  n467 --> n365
  n448 --> n366
  n449 --> n366
  n450 --> n366
  n449 --> n367
  n468 --> n367
  n365 --> n369
  n367 --> n369
  n450 --> n369
  n469 --> n369
  n368 --> n370
  n368 --> n371
  n370 --> n371
```

- [broadcast_adjoint](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L99)
- [broadcast_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L95)
- [controlledSubstitution](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L206)
- [cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [cost_controlled](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L133) (private)
- [cost_inverse](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L69)
- [cost_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L170)
- [covers_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L146)
- [fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [fixed_inverse](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L188) (private)
- [fixed_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L197)
- [lift_adjoint](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L86)
- [lift_conjugate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L105)
- [lift_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L80)
- [run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [run_controlled](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L119)
- [run_inverse](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L56)
- [run_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L163)
- [ParallelQSVT.parallelOracle_adjoint](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L115)
- [ParallelQSVT.parallel_select_adjoint](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L82)
- [ParallelQSVT.parallel_select_mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L70)
- [ParallelQSVT.parallel_select_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L93)
- [ControlledQueryCircuit.controlOracle_adjoint](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/ControlledQueryCircuit.lean#L75)
- [ControlledQueryCircuit.controlOracle_mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/ControlledQueryCircuit.lean#L59)
- [ControlledQueryCircuit.controlOracle_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/ControlledQueryCircuit.lean#L69)

## FQChemQatlib.Dynamics.LowChuangReadout

```mermaid
flowchart LR
  n321["LowChuangFlagGates.localHadamards"]
  n336["LowChuangPadding.finiteSimulation"]
  n357["LowChuangQueries.cost_append"]
  n362["LowChuangQueries.fixed_append"]
  n368["LowChuangQueries.run_append"]
  n372["coordinate_acts"]
  n373["coordinate_iso"]
  n374["finiteCoordinateSimulation"]
  n380["LowChuangReflections.hamiltonianFrame_coordinates"]
  n430["CoordinateFiber.encodingFiber_isIsometry"]
  n436["Postselection.postselectionProbability_eq_norm_sq"]
  n489["RealPartQSVT.averageFrame_isIsometry"]
  n501["FiniteInversePhaseProgram.inverseLabelPhase_unit"]
  n521["Qubit.hadamard_unitary"]
  n532["Tensor.tensorGate_unitary"]
  n373 --> n372
  n380 --> n372
  n430 --> n372
  n436 --> n372
  n489 --> n372
  n501 --> n372
  n430 --> n373
  n321 --> n374
  n336 --> n374
  n357 --> n374
  n362 --> n374
  n368 --> n374
  n372 --> n374
  n521 --> n374
  n532 --> n374
```

- [LowChuangFlagGates.localHadamards](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L136)
- [LowChuangPadding.finiteSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L158)
- [LowChuangQueries.cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [LowChuangQueries.fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [LowChuangQueries.run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [coordinate_acts](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L29) (private)
- [coordinate_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L20) (private)
- [finiteCoordinateSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L54)
- [LowChuangReflections.hamiltonianFrame_coordinates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L78)
- [CoordinateFiber.encodingFiber_isIsometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/EncodingCore/CoordinateFiber.lean#L90)
- [Postselection.postselectionProbability_eq_norm_sq](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Postselection.lean#L315)
- [RealPartQSVT.averageFrame_isIsometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/RealPartQSVT.lean#L113)
- [FiniteInversePhaseProgram.inverseLabelPhase_unit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/LinearSystems/FiniteInversePhaseProgram.lean#L241)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangReflections

```mermaid
flowchart LR
  n375["H_unit"]
  n376["coordinate_parallel"]
  n377["coordinate_smul"]
  n378["cubic_coordinate"]
  n379["fiberPhase_sandwich"]
  n380["hamiltonianFrame_coordinates"]
  n381["zero_projector"]
  n439["FiberBridge.rangeProjector_encodingFiber"]
  n447["ParallelQSVT.parallelOracle_unitary"]
  n499["FiniteInversePhaseProgram.averageFrame_labelH"]
  n500["FiniteInversePhaseProgram.coordinatePhaseFrame_apply"]
  n501["FiniteInversePhaseProgram.inverseLabelPhase_unit"]
  n521["Qubit.hadamard_unitary"]
  n532["Tensor.tensorGate_unitary"]
  n447 --> n375
  n521 --> n375
  n532 --> n375
  n500 --> n376
  n500 --> n377
  n375 --> n378
  n380 --> n378
  n501 --> n378
  n439 --> n379
  n376 --> n380
  n377 --> n380
  n499 --> n380
  n500 --> n381
```

- [H_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L85) (private)
- [coordinate_parallel](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L67) (private)
- [coordinate_smul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L73) (private)
- [cubic_coordinate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L104)
- [fiberPhase_sandwich](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L40)
- [hamiltonianFrame_coordinates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L78)
- [zero_projector](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L91)
- [FiberBridge.rangeProjector_encodingFiber](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/StateBlockEncoding/FiberBridge.lean#L65)
- [ParallelQSVT.parallelOracle_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L120)
- [FiniteInversePhaseProgram.averageFrame_labelH](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/LinearSystems/FiniteInversePhaseProgram.lean#L259)
- [FiniteInversePhaseProgram.coordinatePhaseFrame_apply](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/LinearSystems/FiniteInversePhaseProgram.lean#L252)
- [FiniteInversePhaseProgram.inverseLabelPhase_unit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/LinearSystems/FiniteInversePhaseProgram.lean#L241)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangSimulation

```mermaid
flowchart LR
  n292["LowChuangCutoff.amplifiedTaylorCutoff"]
  n295["LowChuangCutoff.leastCutoff"]
  n328["LowChuangGateWord.amplification_gates"]
  n329["LowChuangGateWord.body_gates"]
  n382["amplifiedLevels"]
  n383["attenuatedBody"]
  n384["optimalCutoffEvolution"]
  n385["uniformCutoffWord"]
  n428["Basic.compress_norm_le"]
  n429["Basic.unitary_norm_le_one"]
  n434["Postselection.postselection_probability_lower"]
  n438["Postselection.normalized_iff_stateVector_norm"]
  n440["RobustCoherentImplementation.coherent_oaa_expanded_subroutine"]
  n441["RobustCoherentImplementation.coherent_oaa_word_correct"]
  n442["ScaleEightCoherentAmplification.scaleEightCubic_lipschitz"]
  n443["ScaleEightCoherentAmplification.scaleEightCubic_sin"]
  n444["ScaleEightCoherentAmplification.scaleEight_clean_from_compression"]
  n445["ScaleEightCoherentAmplification.scaleEight_parameter_bounds"]
  n447["ParallelQSVT.parallelOracle_unitary"]
  n470["ControlledQueryCircuit.controlOracle_unitary"]
  n477["CircuitWellFormed.evaluate_unitary"]
  n479["CountedHamiltonian.compileHamiltonian_wellFormed"]
  n480["CountedHamiltonian.counts_compileHamiltonian"]
  n481["CountedHamiltonian.evaluate_compileHamiltonian"]
  n482["ExponentialPolynomial.exponentialTaylorError_nonneg"]
  n483["ExponentialPolynomial.exponentialTaylorPolynomial_error_le"]
  n485["HamiltonianSimulation.exponentialTaylorPolynomial_eq_trig"]
  n486["HamiltonianSimulation.hamiltonian_phase_projectedEncoding"]
  n487["HamiltonianSimulation.hamiltonian_realPart_of_completion"]
  n488["HamiltonianSimulation.hermitian_realPart_projectedEncoding"]
  n489["RealPartQSVT.averageFrame_isIsometry"]
  n490["RealPartQSVT.average_projectedEncoding"]
  n491["RealPolynomial.exists_phases_of_strict"]
  n492["TrigApproximation.cosineTaylorPolynomial_abs_lt_two"]
  n493["TrigApproximation.cosineTaylorPolynomial_comp_neg_X"]
  n494["TrigApproximation.cosineTaylorPolynomial_natDegree_le"]
  n495["TrigApproximation.sineTaylorPolynomial_abs_lt_two"]
  n496["TrigApproximation.sineTaylorPolynomial_comp_neg_X"]
  n497["TrigApproximation.sineTaylorPolynomial_natDegree_le"]
  n498["ComputedSignalSimulation.computed_signal_hermitian_polynomial_error"]
  n522["Qubit.hamiltonianEvolution_unitary"]
  n525["Qubit.normalized_applyGate"]
  n428 --> n382
  n429 --> n382
  n440 --> n382
  n441 --> n382
  n442 --> n382
  n443 --> n382
  n477 --> n382
  n329 --> n383
  n445 --> n383
  n479 --> n383
  n480 --> n383
  n481 --> n383
  n485 --> n383
  n486 --> n383
  n487 --> n383
  n488 --> n383
  n490 --> n383
  n491 --> n383
  n492 --> n383
  n493 --> n383
  n494 --> n383
  n495 --> n383
  n496 --> n383
  n497 --> n383
  n385 --> n384
  n292 --> n385
  n295 --> n385
  n328 --> n385
  n382 --> n385
  n383 --> n385
  n428 --> n385
  n429 --> n385
  n434 --> n385
  n438 --> n385
  n444 --> n385
  n447 --> n385
  n470 --> n385
  n477 --> n385
  n482 --> n385
  n483 --> n385
  n489 --> n385
  n498 --> n385
  n522 --> n385
  n525 --> n385
```

- [LowChuangCutoff.amplifiedTaylorCutoff](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangCutoff.lean#L69)
- [LowChuangCutoff.leastCutoff](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangCutoff.lean#L21)
- [LowChuangGateWord.amplification_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangGateWord.lean#L103)
- [LowChuangGateWord.body_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangGateWord.lean#L71)
- [amplifiedLevels](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSimulation.lean#L98) (private)
- [attenuatedBody](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSimulation.lean#L37) (private)
- [optimalCutoffEvolution](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSimulation.lean#L199)
- [uniformCutoffWord](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSimulation.lean#L132)
- [Basic.compress_norm_le](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Basic.lean#L207)
- [Basic.unitary_norm_le_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Basic.lean#L200)
- [Postselection.postselection_probability_lower](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Postselection.lean#L437)
- [Postselection.normalized_iff_stateVector_norm](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Postselection.lean#L125)
- [RobustCoherentImplementation.coherent_oaa_expanded_subroutine](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CoherentSim/CoherentOAA/RobustCoherentImplementation.lean#L376)
- [RobustCoherentImplementation.coherent_oaa_word_correct](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CoherentSim/CoherentOAA/RobustCoherentImplementation.lean#L141)
- [ScaleEightCoherentAmplification.scaleEightCubic_lipschitz](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CoherentSim/CoherentOAA/ScaleEightCoherentAmplification.lean#L230)
- [ScaleEightCoherentAmplification.scaleEightCubic_sin](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CoherentSim/CoherentOAA/ScaleEightCoherentAmplification.lean#L216)
- [ScaleEightCoherentAmplification.scaleEight_clean_from_compression](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CoherentSim/CoherentOAA/ScaleEightCoherentAmplification.lean#L249)
- [ScaleEightCoherentAmplification.scaleEight_parameter_bounds](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CoherentSim/CoherentOAA/ScaleEightCoherentAmplification.lean#L141)
- [ParallelQSVT.parallelOracle_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L120)
- [ControlledQueryCircuit.controlOracle_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/ControlledQueryCircuit.lean#L83)
- [CircuitWellFormed.evaluate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/CircuitWellFormed.lean#L137)
- [CountedHamiltonian.compileHamiltonian_wellFormed](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/CountedHamiltonian.lean#L98)
- [CountedHamiltonian.counts_compileHamiltonian](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/CountedHamiltonian.lean#L85)
- [CountedHamiltonian.evaluate_compileHamiltonian](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/CountedHamiltonian.lean#L73)
- [ExponentialPolynomial.exponentialTaylorError_nonneg](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/ExponentialPolynomial.lean#L135)
- [ExponentialPolynomial.exponentialTaylorPolynomial_error_le](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/ExponentialPolynomial.lean#L152)
- [HamiltonianSimulation.exponentialTaylorPolynomial_eq_trig](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/HamiltonianSimulation.lean#L173)
- [HamiltonianSimulation.hamiltonian_phase_projectedEncoding](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/HamiltonianSimulation.lean#L112)
- [HamiltonianSimulation.hamiltonian_realPart_of_completion](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/HamiltonianSimulation.lean#L123)
- [HamiltonianSimulation.hermitian_realPart_projectedEncoding](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/HamiltonianSimulation.lean#L97)
- [RealPartQSVT.averageFrame_isIsometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/RealPartQSVT.lean#L113)
- [RealPartQSVT.average_projectedEncoding](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/RealPartQSVT.lean#L158)
- [RealPolynomial.exists_phases_of_strict](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/RealPolynomial.lean#L371)
- [TrigApproximation.cosineTaylorPolynomial_abs_lt_two](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/TrigApproximation.lean#L178)
- [TrigApproximation.cosineTaylorPolynomial_comp_neg_X](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/TrigApproximation.lean#L108)
- [TrigApproximation.cosineTaylorPolynomial_natDegree_le](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/TrigApproximation.lean#L122)
- [TrigApproximation.sineTaylorPolynomial_abs_lt_two](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/TrigApproximation.lean#L190)
- [TrigApproximation.sineTaylorPolynomial_comp_neg_X](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/TrigApproximation.lean#L115)
- [TrigApproximation.sineTaylorPolynomial_natDegree_le](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/TrigApproximation.lean#L131)
- [ComputedSignalSimulation.computed_signal_hermitian_polynomial_error](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/JacobiAnger/ComputedSignalSimulation.lean#L309)
- [Qubit.hamiltonianEvolution_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L604)
- [Qubit.normalized_applyGate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L266)

## FQChemQatlib.Dynamics.LowChuangSparseOracle

```mermaid
flowchart LR
  n355["LowChuangQueries.broadcast_mul"]
  n360["LowChuangQueries.cost_substitute"]
  n366["LowChuangQueries.lift_conjugate"]
  n367["LowChuangQueries.lift_mul"]
  n371["LowChuangQueries.run_substitute"]
  n385["LowChuangSimulation.uniformCutoffWord"]
  n386["blockProgram_spec"]
  n387["frame_iso"]
  n388["permutation_action"]
  n389["prepared_column"]
  n390["right_column"]
  n391["rot_unit"]
  n392["rotation_action"]
  n393["slot_norm"]
  n394["sparseOracleEncoding"]
  n395["sparseQuerySimulation"]
  n396["sparseStandardForm"]
  n397["uniform_unit"]
  n398["value_action"]
  n431["PrepareUnitary.nonnegativePrepare_column"]
  n432["PrepareUnitary.nonnegativePrepare_unitary"]
  n433["LCU.select_unitary"]
  n464["ExecutionSemantics.permMatrix_unitary_of_injective"]
  n528["Qubit.permMatrix_conjTranspose"]
  n529["Qubit.permMatrix_unitary"]
  n532["Tensor.tensorGate_unitary"]
  n355 --> n386
  n366 --> n386
  n367 --> n386
  n397 --> n386
  n464 --> n386
  n528 --> n386
  n529 --> n386
  n388 --> n389
  n431 --> n389
  n388 --> n390
  n389 --> n390
  n398 --> n390
  n387 --> n394
  n389 --> n394
  n390 --> n394
  n391 --> n394
  n397 --> n394
  n433 --> n394
  n464 --> n394
  n360 --> n395
  n371 --> n395
  n385 --> n395
  n386 --> n395
  n387 --> n395
  n394 --> n395
  n386 --> n396
  n394 --> n396
  n393 --> n397
  n432 --> n397
  n433 --> n397
  n532 --> n397
  n388 --> n398
  n392 --> n398
```

- [LowChuangQueries.broadcast_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L95)
- [LowChuangQueries.cost_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L170)
- [LowChuangQueries.lift_conjugate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L105)
- [LowChuangQueries.lift_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L80)
- [LowChuangQueries.run_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L163)
- [LowChuangSimulation.uniformCutoffWord](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSimulation.lean#L132)
- [blockProgram_spec](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L236)
- [frame_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L38) (private)
- [permutation_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L77) (private)
- [prepared_column](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L120) (private)
- [right_column](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L149) (private)
- [rot_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L88) (private)
- [rotation_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L132) (private)
- [slot_norm](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L46) (private)
- [sparseOracleEncoding](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L168)
- [sparseQuerySimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L284)
- [sparseStandardForm](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L261)
- [uniform_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L101) (private)
- [value_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseOracle.lean#L137) (private)
- [PrepareUnitary.nonnegativePrepare_column](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/EncodingCore/PrepareUnitary.lean#L135)
- [PrepareUnitary.nonnegativePrepare_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/EncodingCore/PrepareUnitary.lean#L125)
- [LCU.select_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/LCU.lean#L91)
- [ExecutionSemantics.permMatrix_unitary_of_injective](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HspRecovery/RecordExtract/ExecutionSemantics.lean#L129)
- [Qubit.permMatrix_conjTranspose](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L289)
- [Qubit.permMatrix_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L300)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangStandardForm

```mermaid
flowchart LR
  n360["LowChuangQueries.cost_substitute"]
  n361["LowChuangQueries.covers_substitute"]
  n364["LowChuangQueries.fixed_substitute"]
  n366["LowChuangQueries.lift_conjugate"]
  n371["LowChuangQueries.run_substitute"]
  n385["LowChuangSimulation.uniformCutoffWord"]
  n399["standardFormProgram"]
  n430["CoordinateFiber.encodingFiber_isIsometry"]
  n532["Tensor.tensorGate_unitary"]
  n360 --> n399
  n361 --> n399
  n364 --> n399
  n366 --> n399
  n371 --> n399
  n385 --> n399
  n430 --> n399
  n532 --> n399
```

- [LowChuangQueries.cost_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L170)
- [LowChuangQueries.covers_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L146)
- [LowChuangQueries.fixed_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L197)
- [LowChuangQueries.lift_conjugate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L105)
- [LowChuangQueries.run_substitute](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L163)
- [LowChuangSimulation.uniformCutoffWord](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSimulation.lean#L132)
- [standardFormProgram](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangStandardForm.lean#L32)
- [CoordinateFiber.encodingFiber_isIsometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/EncodingCore/CoordinateFiber.lean#L90)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangUniformBits

```mermaid
flowchart LR
  n400["fill_at"]
  n401["fill_out"]
  n402["hWord_cost"]
  n403["mean_diagonal"]
  n474["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n515["FiniteThermalUniformH.thermalUniformHWord_legal"]
  n516["FiniteThermalUniformH.thermalUniformHWord_zero_column"]
  n515 --> n402
  n400 -.-> n403
  n401 -.-> n403
  n474 --> n403
  n516 --> n403
```

- [fill_at](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L23)
- [fill_out](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L28)
- [hWord_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L43)
- [mean_diagonal](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L49)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)
- [FiniteThermalUniformH.thermalUniformHWord_legal](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalUniformH.lean#L168)
- [FiniteThermalUniformH.thermalUniformHWord_zero_column](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalUniformH.lean#L302)

## FQChemQatlib.Dynamics.SingularValueTransformation

```mermaid
flowchart LR
  n404["polynomialSingularValueTransformation"]
  n405["singularValueTransformationOfPhases"]
  n502["Corollary8ComplexPhaseExistenceGily.corollary8ComplexPhaseExistence"]
  n503["ConventionBridge.source_corner_even_eq"]
  n504["ConventionBridge.source_corner_odd_eq"]
  n405 --> n404
  n502 --> n404
  n503 --> n405
  n504 --> n405
```

- [polynomialSingularValueTransformation](../../integrations/qatlib/FQChemQatlib/Dynamics/SingularValueTransformation.lean#L47)
- [singularValueTransformationOfPhases](../../integrations/qatlib/FQChemQatlib/Dynamics/SingularValueTransformation.lean#L32)
- [Corollary8ComplexPhaseExistenceGily.corollary8ComplexPhaseExistence](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/PhaseExistence/Corollary8ComplexPhaseExistenceGily.lean#L70)
- [ConventionBridge.source_corner_even_eq](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/QsVtMain/ConventionBridge.lean#L241)
- [ConventionBridge.source_corner_odd_eq](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/QsVtMain/ConventionBridge.lean#L224)

## FQChemQatlib.Dynamics.SparseHamiltonianSimulation

```mermaid
flowchart LR
  n406["segmentedSparseEvolution"]
  n407["sparseSignalEncoding"]
  n478["ComputedSignalConsumers.computed_signal_full_segmented_program_and_cost"]
  n554["SourceSparse.lemma6_sparse_standard_form"]
  n407 --> n406
  n478 --> n406
  n554 --> n407
```

- [segmentedSparseEvolution](../../integrations/qatlib/FQChemQatlib/Dynamics/SparseHamiltonianSimulation.lean#L53)
- [sparseSignalEncoding](../../integrations/qatlib/FQChemQatlib/Dynamics/SparseHamiltonianSimulation.lean#L34)
- [ComputedSignalConsumers.computed_signal_full_segmented_program_and_cost](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/ComputedSignalConsumers.lean#L169)
- [SourceSparse.lemma6_sparse_standard_form](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/Qubitization19/SparseSim/SourceSparse.lean#L97)

## FQChemQatlib.Properties.AmplitudeEstimation

```mermaid
flowchart LR
  n408["amplitudeEstimation"]
  n409["amplitudeEstimationTail"]
  n424["ComparativeStrictBounds.preparedAeWindow_strict"]
  n426["PreparedAmplitudeEstimation.prepared_ae_access_ledger"]
  n427["PreparedAmplitudeEstimation.prepared_ae_bhmt_error_and_endpoints"]
  n426 --> n408
  n427 --> n408
  n424 --> n409
```

- [amplitudeEstimation](../../integrations/qatlib/FQChemQatlib/Properties/AmplitudeEstimation.lean#L32)
- [amplitudeEstimationTail](../../integrations/qatlib/FQChemQatlib/Properties/AmplitudeEstimation.lean#L43)
- [ComparativeStrictBounds.preparedAeWindow_strict](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/AEMeanReadout/LocalAEBackend/ComparativeStrictBounds.lean#L282)
- [PreparedAmplitudeEstimation.prepared_ae_access_ledger](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/AmplitudeCore/PreparedReadout/PreparedAmplitudeEstimation.lean#L194)
- [PreparedAmplitudeEstimation.prepared_ae_bhmt_error_and_endpoints](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/AmplitudeCore/PreparedReadout/PreparedAmplitudeEstimation.lean#L692)

## FQChemQatlib.Properties.ClassicalShadows

```mermaid
flowchart LR
  n410["shadowNormSquaredMaximum"]
  n411["simultaneousPrediction"]
  n507["FiniteEnsembleShadows.finite_ensemble_same_records_many_observables"]
  n508["FiniteEnsembleShadows.finite_ensemble_second_moment_spectral_maximum"]
  n508 --> n410
  n507 --> n411
```

- [shadowNormSquaredMaximum](../../integrations/qatlib/FQChemQatlib/Properties/ClassicalShadows.lean#L32)
- [simultaneousPrediction](../../integrations/qatlib/FQChemQatlib/Properties/ClassicalShadows.lean#L46)
- [FiniteEnsembleShadows.finite_ensemble_same_records_many_observables](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/ShadowModels/ShadowChannel/FiniteEnsembleShadows.lean#L509)
- [FiniteEnsembleShadows.finite_ensemble_second_moment_spectral_maximum](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/ShadowModels/ShadowChannel/FiniteEnsembleShadows.lean#L485)

## FQChemQatlib.Properties.LinearSystems

```mermaid
flowchart LR
  n412["signedInverseState"]
  n462["OffGridSignedHHL.uniform_offgrid_signed_hhl_born_and_solution"]
  n463["UniformHHLFilter.uniform_hhl_actual_legal_forward_inverse_ledger"]
  n544["PseudoinverseReadout.pseudoinverse_eq_inv_of_ne_zero"]
  n462 --> n412
  n463 --> n412
  n544 --> n412
```

- [signedInverseState](../../integrations/qatlib/FQChemQatlib/Properties/LinearSystems.lean#L31)
- [OffGridSignedHHL.uniform_offgrid_signed_hhl_born_and_solution](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/UniformHHL/OffGridSignedHHL.lean#L654)
- [UniformHHLFilter.uniform_hhl_actual_legal_forward_inverse_ledger](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/UniformHHL/UniformHHLFilter.lean#L244)
- [PseudoinverseReadout.pseudoinverse_eq_inv_of_ne_zero](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QLinearSolver18/MainResults/Readout/PseudoinverseReadout.lean#L72)

## FQChemQatlib.Properties.SignedSineClock

```mermaid
flowchart LR
  n413["decodedDistance"]
  n414["normalizedBranch"]
  n415["regularGain"]
  n416["relativeGain"]
  n417["selectedGain"]
  n418["signedRelativeClock"]
  n419["superpositionError"]
  n437["Postselection.normalize_error_of_gap"]
  n457["SinEnvelopeHHL.sin_envelope_kernel_normalized"]
  n458["SinEnvelopeHHL.sin_envelope_kernel_second_moment"]
  n460["QlsHhl.canonicalSignedFilter_consistent"]
  n461["QlsHhl.canonicalSignedProgram_rotation"]
  n419 --> n414
  n437 --> n414
  n457 --> n414
  n415 --> n416
  n460 --> n416
  n461 --> n417
  n413 --> n418
  n416 --> n418
  n458 --> n418
  n417 --> n419
  n418 --> n419
```

- [decodedDistance](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L55) (private)
- [normalizedBranch](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L191)
- [regularGain](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L27)
- [relativeGain](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L38)
- [selectedGain](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L130)
- [signedRelativeClock](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L92)
- [superpositionError](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L139)
- [Postselection.normalize_error_of_gap](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Postselection.lean#L54)
- [SinEnvelopeHHL.sin_envelope_kernel_normalized](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvFilter/SinEnvelopeHHL.lean#L256)
- [SinEnvelopeHHL.sin_envelope_kernel_second_moment](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvFilter/SinEnvelopeHHL.lean#L890)
- [QlsHhl.canonicalSignedFilter_consistent](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvProgram/QlsHhl.lean#L2863)
- [QlsHhl.canonicalSignedProgram_rotation](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvProgram/QlsHhl.lean#L2911)

## FQChemQatlib.Properties.SignedSineUncompute

```mermaid
flowchart LR
  n414["SignedSineClock.normalizedBranch"]
  n420["cleanClock"]
  n421["clockUnitary"]
  n422["forwardKernel"]
  n423["signedSolution"]
  n459["SinEnvelopeHHL.sin_envelope_state_normalized_and_prep"]
  n505["LocalCapability.blockDiag_unitary"]
  n509["PhaseEstimation.norm_exp_two_pi_I"]
  n510["PhaseEstimation.qftMatrix_unitary"]
  n421 --> n420
  n422 --> n420
  n505 -.-> n420
  n459 --> n421
  n509 --> n421
  n510 --> n421
  n459 --> n422
  n414 --> n423
  n420 --> n423
  n421 -.-> n423
  n505 -.-> n423
```

- [SignedSineClock.normalizedBranch](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L191)
- [cleanClock](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L62)
- [clockUnitary](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L26)
- [forwardKernel](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L42)
- [signedSolution](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L84)
- [SinEnvelopeHHL.sin_envelope_state_normalized_and_prep](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvFilter/SinEnvelopeHHL.lean#L230)
- [LocalCapability.blockDiag_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QueryComplexity/DegreeMethod/LocalCapability.lean#L83)
- [PhaseEstimation.norm_exp_two_pi_I](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/SpectralFilter/PhaseReadout/PhaseEstimation.lean#L432)
- [PhaseEstimation.qftMatrix_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/SpectralFilter/PhaseReadout/PhaseEstimation.lean#L148)
