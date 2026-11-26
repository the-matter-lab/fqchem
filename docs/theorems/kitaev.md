# Qatlib integration theorem graph

620 source theorems and lemmas · 8 shared library prerequisites · 159 upstream theorem nodes · 1265 dependency edges.

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
- [reaches_precision](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L68)
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
  n659["FiniteGateDescription.finite_gate_description_rejection_unitarity_and_counts"]
  n744["EventProbability.measureProb_le_one"]
  n754["Qubit.measureProb_nonneg"]
  n756["Qubit.normalized_ket"]
  n763["Circuit.normalized_run"]
  n764["Circuit.run_append"]
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
  n659 --> n60
  n756 --> n60
  n763 --> n60
  n764 --> n60
  n50 -.-> n61
  n207 --> n61
  n217 --> n61
  n50 -.-> n62
  n218 --> n62
  n659 --> n63
  n744 --> n63
  n754 --> n63
  n756 --> n63
  n763 --> n63
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
  n756["Qubit.normalized_ket"]
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
  n756 --> n64
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
- [AmplificationBounds.reaches_precision](../../integrations/qatlib/FQChemKitaev/AmplificationBounds.lean#L68)
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
  n743["QmaCompletenessNumerics.floor_atom"]
  n141 --> n137
  n141 --> n138
  n141 --> n140
  n743 --> n140
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
- [circuit_atom_cost](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L292)
- [gateOutput_spec](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L278)
- [increment_spec](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L192)
- [materialize_floor](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L268)
- [materialize_spec](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L258)
- [next_value](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L128) (private)
- [pow2bits](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L252) (private)
- [propagation_from_bits](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L302)
- [rootOutput_correct](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L220)
- [rootOutput_resources](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L236)
- [run_certificate](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L161)
- [run_isqrt](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L173)
- [run_shape](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L115)
- [subtract_borrow](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L88)
- [subtract_shape](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L63)
- [subtract_value](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L72)
- [value_lt](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L35)
- [value_tail](../../integrations/qatlib/FQChemKitaev/DyadicCoefficients.lean#L199) (private)
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
  n771["QmaCompletenessPadding.paid64_length"]
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
  n771 --> n163
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
- [ElectronicStructureOperators.fermionExpectation](../../FQChem/Complexity/ElectronicStructureOperators.lean#L175)
- [ElectronicStructurePauli.localExpansion_size](../../FQChem/Complexity/ElectronicStructurePauli.lean#L198)
- [ElectronicStructurePauli.localExpansion_strength](../../FQChem/Complexity/ElectronicStructurePauli.lean#L230)
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
  n696["QmaCompletenessRefined.clause3Aux_encNat_selfDelimiting"]
  n697["QmaCompletenessRefined.clause3Aux_toBits_injective"]
  n728["QmaCompletenessNativeOutput.outputTerms_length"]
  n745["EventProbability.measureProb_smul"]
  n753["Qubit.inner_apply"]
  n756["Qubit.normalized_ket"]
  n765["QmaCompleteness.qma_history_locality_description_and_energy_bounds"]
  n766["QmaCompletenessNormalized.denominator_le_poly"]
  n767["QmaCompletenessNormalized.denominator_pos"]
  n768["QmaCompletenessNormalized.gap_inverse_poly"]
  n769["QmaCompletenessNormalized.gap_positive"]
  n770["QmaCompletenessNormalized.padded_normalized_contract"]
  n771["QmaCompletenessPadding.paid64_length"]
  n772["QmaCompletenessSize.encNat_length_le_self"]
  n773["QmaCompletenessSize.termEntries_length"]
  n766 --> n170
  n771 --> n170
  n767 --> n171
  n753 --> n172
  n756 --> n173
  n175 --> n174
  n178 --> n174
  n172 --> n175
  n173 --> n175
  n188 --> n175
  n184 --> n176
  n172 --> n177
  n175 --> n177
  n178 --> n177
  n768 --> n178
  n769 --> n178
  n771 --> n178
  n767 --> n179
  n170 --> n180
  n181 --> n180
  n772 --> n180
  n765 --> n181
  n771 --> n181
  n181 --> n183
  n773 --> n183
  n696 --> n184
  n697 --> n184
  n185 -.-> n186
  n728 --> n186
  n171 --> n187
  n175 --> n187
  n179 --> n187
  n181 --> n187
  n770 --> n188
  n771 --> n188
  n182 --> n189
  n745 --> n189
  n175 --> n190
  n189 --> n190
  n191 --> n190
  n756 --> n190
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
  n695["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n738["FiniteThermalToffoli.thermalToffoliWord_exact"]
  n764["Circuit.run_append"]
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
  n738 --> n204
  n196 --> n205
  n206 --> n205
  n695 --> n205
  n192 --> n206
  n204 --> n206
  n764 --> n206
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
  n662["LocalReflectionGates.applyGate_wireGate_ket"]
  n756["Qubit.normalized_ket"]
  n764["Circuit.run_append"]
  n0 -.-> n209
  n1 -.-> n209
  n158 --> n209
  n181 -.-> n209
  n189 --> n209
  n191 --> n209
  n210 --> n209
  n212 -.-> n209
  n213 --> n209
  n756 --> n209
  n211 --> n210
  n212 -.-> n210
  n216 --> n210
  n212 -.-> n211
  n214 --> n211
  n764 --> n211
  n215 --> n214
  n662 --> n215
  n764 --> n215
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
  n663["LocalReflectionGates.cnotUpdate_involutive"]
  n667["LocalReflectionGates.wireGate_apply"]
  n749["Qubit.applyGate_permMatrix"]
  n222 --> n217
  n221 --> n219
  n224 --> n220
  n220 --> n221
  n223 --> n221
  n663 --> n223
  n749 --> n223
  n667 --> n224
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
  n692["ResidueFactoringAlgorithmShor.residueFactoringAlgorithm"]
  n693["PairLCMOrderRecovery.pair_lcm_order_actual_fresh_success_bound"]
  n775["Theorem32Paper.simonTheorem32"]
  n779["InfiniteOracle.simon_infiniteOracle_separation"]
  n783["Theorem34Separation.simonTheorem33RealBudget"]
  n786["SourceWindowDecode.source_clock_residue_window_actual_decoder_recovery"]
  n692 --> n225
  n693 --> n226
  n786 --> n227
  n783 --> n228
  n775 --> n229
  n779 --> n230
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
  n629["FiniteStoppingTail.expectation_congr"]
  n684["RandomizedCost.expectation_map"]
  n776["InfiniteOracle.exists_good_low"]
  n777["InfiniteOracle.exists_length_of_index"]
  n778["InfiniteOracle.simonQuantumSuccess_good"]
  n233 --> n231
  n234 --> n231
  n684 --> n231
  n776 --> n231
  n232 --> n235
  n629 --> n235
  n231 --> n236
  n235 --> n236
  n777 --> n236
  n778 --> n236
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
  n681["BooleanGaussianDecoder.boolean_gaussian_actual_operation_bound"]
  n684["RandomizedCost.expectation_map"]
  n780["JointSeparation.simonReject_total"]
  n781["SimonRetry.simonExactLedger_eq"]
  n782["Theorem34Separation.simonPaperScheduleLedger"]
  n780 --> n241
  n681 --> n243
  n781 --> n243
  n782 --> n243
  n236 --> n244
  n237 -.-> n244
  n238 -.-> n244
  n239 -.-> n244
  n247 --> n244
  n684 --> n244
  n782 --> n244
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

## FQChemQatlib.Dynamics.AncillaFreeNot

```mermaid
flowchart LR
  n248["conjugate"]
  n249["hadamardColumn"]
  n250["multiControlledNot"]
  n251["readControls"]
  n254["AncillaFreePhase.compose"]
  n259["AncillaFreePhase.multiControlledPhase"]
  n261["AncillaFreePhase.single"]
  n662["LocalReflectionGates.applyGate_wireGate_ket"]
  n667["LocalReflectionGates.wireGate_apply"]
  n249 --> n248
  n251 --> n248
  n667 --> n248
  n662 --> n249
  n248 --> n250
  n254 --> n250
  n259 --> n250
  n261 --> n250
```

- [conjugate](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreeNot.lean#L40) (private)
- [hadamardColumn](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreeNot.lean#L24) (private)
- [multiControlledNot](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreeNot.lean#L73)
- [readControls](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreeNot.lean#L32) (private)
- [AncillaFreePhase.compose](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L59) (private)
- [AncillaFreePhase.multiControlledPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L114)
- [AncillaFreePhase.single](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L56) (private)
- [LocalReflectionGates.applyGate_wireGate_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L343)
- [LocalReflectionGates.wireGate_apply](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L83)

## FQChemQatlib.Dynamics.AncillaFreePhase

```mermaid
flowchart LR
  n252["chain"]
  n253["classicalWord"]
  n254["compose"]
  n255["finiteCertificate"]
  n256["followed"]
  n257["grad"]
  n258["monoIdentity"]
  n259["multiControlledPhase"]
  n260["reverseProduct"]
  n261["single"]
  n290["DirtyIncrement.inverseWord"]
  n300["HalvedIncrement.all_max"]
  n306["HalvedIncrement.modular_read"]
  n307["HalvedIncrement.oneDirty"]
  n581["SingletonPhaseGradient.phase_add"]
  n695["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n581 --> n252
  n255 --> n253
  n260 --> n253
  n695 --> n255
  n252 --> n256
  n254 --> n256
  n256 --> n257
  n258 --> n257
  n261 --> n257
  n253 --> n259
  n256 --> n259
  n257 --> n259
  n261 --> n259
  n290 --> n259
  n300 --> n259
  n306 --> n259
  n307 --> n259
```

- [chain](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L32)
- [classicalWord](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L86) (private)
- [compose](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L59) (private)
- [finiteCertificate](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L69)
- [followed](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L64) (private)
- [grad](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L96) (private)
- [monoIdentity](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L40)
- [multiControlledPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L114)
- [reverseProduct](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L80)
- [single](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L56) (private)
- [DirtyIncrement.inverseWord](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L27)
- [HalvedIncrement.all_max](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L128)
- [HalvedIncrement.modular_read](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L136)
- [HalvedIncrement.oneDirty](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L262)
- [SingletonPhaseGradient.phase_add](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L81)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)

## FQChemQatlib.Dynamics.BorrowedControls

```mermaid
flowchart LR
  n262["allFlip"]
  n263["bit"]
  n264["borrowedMCX"]
  n265["carryFlip"]
  n266["carry_congr"]
  n267["carry_xor"]
  n268["coherentMCX"]
  n269["compose"]
  n270["controlledBit"]
  n271["many"]
  n272["manyFromPath"]
  n273["readCarry"]
  n274["restore"]
  n275["toff"]
  n276["toggleDifference"]
  n277["weaken"]
  n278["zipNames"]
  n661["LocalReflectionGates.applyGate_cnotGate_ket"]
  n662["LocalReflectionGates.applyGate_wireGate_ket"]
  n695["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n738["FiniteThermalToffoli.thermalToffoliWord_exact"]
  n764["Circuit.run_append"]
  n662 --> n263
  n262 --> n264
  n271 --> n264
  n276 --> n264
  n277 --> n264
  n266 --> n265
  n264 --> n268
  n695 --> n268
  n764 --> n269
  n661 --> n270
  n263 --> n271
  n270 --> n271
  n272 --> n271
  n275 --> n271
  n277 --> n271
  n278 --> n271
  n265 --> n272
  n267 --> n272
  n273 --> n272
  n275 --> n272
  n276 --> n272
  n277 --> n272
  n265 --> n273
  n269 --> n273
  n274 --> n273
  n275 --> n273
  n277 --> n273
  n738 --> n275
  n269 --> n276
  n274 --> n276
  n277 --> n276
```

- [allFlip](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L122) (private)
- [bit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L54)
- [borrowedMCX](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L244)
- [carryFlip](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L130) (private)
- [carry_congr](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L78) (private)
- [carry_xor](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L89) (private)
- [coherentMCX](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L274)
- [compose](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L34)
- [controlledBit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L62)
- [many](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L215) (private)
- [manyFromPath](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L182) (private)
- [readCarry](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L141) (private)
- [restore](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L99) (private)
- [toff](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L44)
- [toggleDifference](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L107) (private)
- [weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L41)
- [zipNames](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L203) (private)
- [LocalReflectionGates.applyGate_cnotGate_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L205)
- [LocalReflectionGates.applyGate_wireGate_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L343)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)
- [FiniteThermalToffoli.thermalToffoliWord_exact](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalToffoli.lean#L60)
- [Circuit.run_append](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean#L249)

## FQChemQatlib.Dynamics.BorrowedRipple

```mermaid
flowchart LR
  n269["BorrowedControls.compose"]
  n270["BorrowedControls.controlledBit"]
  n275["BorrowedControls.toff"]
  n277["BorrowedControls.weaken"]
  n279["arithmetic"]
  n280["circuit"]
  n281["finish_action"]
  n282["innerWires"]
  n283["member"]
  n284["prepare_action"]
  n285["read_congr"]
  n286["restored"]
  n282 --> n279
  n283 --> n279
  n285 --> n279
  n269 --> n280
  n270 --> n280
  n277 --> n280
  n281 --> n280
  n284 --> n280
  n269 --> n281
  n270 --> n281
  n275 --> n281
  n283 --> n282
  n286 --> n282
  n269 --> n284
  n270 --> n284
  n275 --> n284
  n283 --> n286
```

- [BorrowedControls.compose](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L34)
- [BorrowedControls.controlledBit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L62)
- [BorrowedControls.toff](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L44)
- [BorrowedControls.weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L41)
- [arithmetic](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L145)
- [circuit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L70)
- [finish_action](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L49) (private)
- [innerWires](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L127) (private)
- [member](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L94)
- [prepare_action](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L35) (private)
- [read_congr](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L89) (private)
- [restored](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L99)

## FQChemQatlib.Dynamics.DirtyIncrement

```mermaid
flowchart LR
  n263["BorrowedControls.bit"]
  n269["BorrowedControls.compose"]
  n270["BorrowedControls.controlledBit"]
  n277["BorrowedControls.weaken"]
  n279["BorrowedRipple.arithmetic"]
  n280["BorrowedRipple.circuit"]
  n283["BorrowedRipple.member"]
  n286["BorrowedRipple.restored"]
  n287["adds"]
  n288["complement_value"]
  n289["controlledNotWord"]
  n290["inverseWord"]
  n291["manyDirty"]
  n292["modulus"]
  n293["projections"]
  n294["read_append"]
  n295["read_complement"]
  n296["read_eq"]
  n297["reflectedCarry"]
  n298["tickCircuit"]
  n660["FiniteGateDescription.finite_gate_word_paid_adjoint_semantics"]
  n764["Circuit.run_append"]
  n279 --> n287
  n292 --> n287
  n294 --> n287
  n292 --> n288
  n295 --> n288
  n296 --> n288
  n269 --> n289
  n270 --> n289
  n660 --> n290
  n764 --> n290
  n269 --> n291
  n277 --> n291
  n280 --> n291
  n283 --> n291
  n286 --> n291
  n287 --> n291
  n288 --> n291
  n289 --> n291
  n290 --> n291
  n293 --> n291
  n296 --> n291
  n297 --> n291
  n298 --> n291
  n263 --> n298
  n270 --> n298
```

- [BorrowedControls.bit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L54)
- [BorrowedControls.compose](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L34)
- [BorrowedControls.controlledBit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L62)
- [BorrowedControls.weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L41)
- [BorrowedRipple.arithmetic](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L145)
- [BorrowedRipple.circuit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L70)
- [BorrowedRipple.member](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L94)
- [BorrowedRipple.restored](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L99)
- [adds](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L96)
- [complement_value](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L112)
- [controlledNotWord](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L51)
- [inverseWord](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L27)
- [manyDirty](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L156)
- [modulus](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L90)
- [projections](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L139)
- [read_append](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L67)
- [read_complement](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L78)
- [read_eq](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L73)
- [reflectedCarry](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L146)
- [tickCircuit](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L130)
- [FiniteGateDescription.finite_gate_word_paid_adjoint_semantics](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/FiniteGateDescription.lean#L206)
- [Circuit.run_append](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean#L249)

## FQChemQatlib.Dynamics.HalvedIncrement

```mermaid
flowchart LR
  n264["BorrowedControls.borrowedMCX"]
  n269["BorrowedControls.compose"]
  n277["BorrowedControls.weaken"]
  n283["BorrowedRipple.member"]
  n288["DirtyIncrement.complement_value"]
  n289["DirtyIncrement.controlledNotWord"]
  n290["DirtyIncrement.inverseWord"]
  n291["DirtyIncrement.manyDirty"]
  n292["DirtyIncrement.modulus"]
  n294["DirtyIncrement.read_append"]
  n296["DirtyIncrement.read_eq"]
  n297["DirtyIncrement.reflectedCarry"]
  n299["all_congr"]
  n300["all_max"]
  n301["emptyInc"]
  n302["evenHalves"]
  n303["evenWidth"]
  n304["join"]
  n305["manyOn"]
  n306["modular_read"]
  n307["oneDirty"]
  n308["readRange"]
  n309["relax"]
  n310["splitValid"]
  n311["target_snoc"]
  n312["transferredControl"]
  n264 --> n302
  n299 --> n302
  n304 --> n302
  n305 --> n302
  n309 --> n302
  n311 --> n302
  n312 --> n302
  n301 --> n303
  n302 --> n303
  n309 --> n303
  n269 --> n304
  n292 --> n304
  n294 --> n304
  n296 --> n304
  n300 --> n304
  n306 --> n304
  n283 -.-> n305
  n291 --> n305
  n310 --> n305
  n311 --> n305
  n308 --> n306
  n264 --> n307
  n292 --> n307
  n303 --> n307
  n304 --> n307
  n309 --> n307
  n311 --> n307
  n277 --> n309
  n283 -.-> n310
  n269 --> n312
  n277 --> n312
  n288 --> n312
  n289 --> n312
  n290 --> n312
  n296 --> n312
  n297 --> n312
```

- [BorrowedControls.borrowedMCX](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L244)
- [BorrowedControls.compose](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L34)
- [BorrowedControls.weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L41)
- [BorrowedRipple.member](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedRipple.lean#L94)
- [DirtyIncrement.complement_value](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L112)
- [DirtyIncrement.controlledNotWord](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L51)
- [DirtyIncrement.inverseWord](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L27)
- [DirtyIncrement.manyDirty](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L156)
- [DirtyIncrement.modulus](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L90)
- [DirtyIncrement.read_append](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L67)
- [DirtyIncrement.read_eq](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L73)
- [DirtyIncrement.reflectedCarry](../../integrations/qatlib/FQChemQatlib/Dynamics/DirtyIncrement.lean#L146)
- [all_congr](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L215) (private)
- [all_max](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L128)
- [emptyInc](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L209)
- [evenHalves](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L220)
- [evenWidth](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L244)
- [join](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L157)
- [manyOn](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L35)
- [modular_read](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L136)
- [oneDirty](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L262)
- [readRange](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L123)
- [relax](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L206) (private)
- [splitValid](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L18) (private)
- [target_snoc](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L29) (private)
- [transferredControl](../../integrations/qatlib/FQChemQatlib/Dynamics/HalvedIncrement.lean#L64)

## FQChemQatlib.Dynamics.LowChuangAllDimensions

```mermaid
flowchart LR
  n313["allFiniteCoordinateSimulation"]
  n314["allFiniteRegisters"]
  n315["allFrameGates"]
  n316["allQubitRegisters"]
  n352["LowChuangElementary.adj_emits"]
  n354["LowChuangElementary.expand"]
  n357["LowChuangElementary.frameGate_emits_of_cubic"]
  n358["LowChuangElementary.mul_emits"]
  n360["LowChuangElementary.scalar_flags"]
  n361["LowChuangElementary.scalar_pair"]
  n362["LowChuangElementary.single"]
  n363["LowChuangElementary.weaken"]
  n374["LowChuangFlagGates.localHadamards"]
  n386["LowChuangPadding.coord_iso"]
  n393["LowChuangPadding.pad_hermitian"]
  n396["LowChuangPadding.pad_unit"]
  n397["LowChuangPadding.padded_signal"]
  n401["LowChuangPadding.unpad_error"]
  n428["LowChuangReadout.coordinate_program"]
  n433["LowChuangReflections.cubic_coordinate"]
  n442["LowChuangSingleton.coordinateMark"]
  n570["LowChuangStandardForm.standardFormProgram"]
  n640["Postselection.normalized_mulVec"]
  n751["Qubit.hadamard_unitary"]
  n762["Tensor.tensorGate_unitary"]
  n314 --> n313
  n428 --> n313
  n316 --> n314
  n386 --> n314
  n393 --> n314
  n396 --> n314
  n397 --> n314
  n401 --> n314
  n640 --> n314
  n352 --> n315
  n357 --> n315
  n358 --> n315
  n360 --> n315
  n361 --> n315
  n362 --> n315
  n363 --> n315
  n374 --> n315
  n433 --> n315
  n442 --> n315
  n751 --> n315
  n762 --> n315
  n315 --> n316
  n354 --> n316
  n570 --> n316
```

- [allFiniteCoordinateSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangAllDimensions.lean#L116)
- [allFiniteRegisters](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangAllDimensions.lean#L79)
- [allFrameGates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangAllDimensions.lean#L35)
- [allQubitRegisters](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangAllDimensions.lean#L52)
- [LowChuangElementary.adj_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L44) (private)
- [LowChuangElementary.expand](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L139) (private)
- [LowChuangElementary.frameGate_emits_of_cubic](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L83) (private)
- [LowChuangElementary.mul_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L38) (private)
- [LowChuangElementary.scalar_flags](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L77) (private)
- [LowChuangElementary.scalar_pair](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L72) (private)
- [LowChuangElementary.single](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L35) (private)
- [LowChuangElementary.weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L55) (private)
- [LowChuangFlagGates.localHadamards](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L149)
- [LowChuangPadding.coord_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L26)
- [LowChuangPadding.pad_hermitian](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L60)
- [LowChuangPadding.pad_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L53)
- [LowChuangPadding.padded_signal](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L142)
- [LowChuangPadding.unpad_error](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L82) (private)
- [LowChuangReadout.coordinate_program](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L47) (private)
- [LowChuangReflections.cubic_coordinate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L111)
- [LowChuangSingleton.coordinateMark](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L160)
- [LowChuangStandardForm.standardFormProgram](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangStandardForm.lean#L32)
- [Postselection.normalized_mulVec](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Postselection.lean#L264)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangBinaryCompare

```mermaid
flowchart LR
  n263["BorrowedControls.bit"]
  n269["BorrowedControls.compose"]
  n275["BorrowedControls.toff"]
  n317["address_mem"]
  n318["carry_order"]
  n319["output_address"]
  n320["result_address"]
  n321["ripple_result"]
  n322["ripple_word"]
  n323["step_exact"]
  n324["step_valid"]
  n325["tail_valid"]
  n326["unchanged"]
  n737["FiniteThermalComparator.thermalLexLess_numeric"]
  n318 --> n321
  n319 --> n321
  n325 --> n321
  n326 --> n321
  n737 --> n321
  n269 --> n322
  n323 --> n322
  n324 --> n322
  n325 --> n322
  n263 --> n323
  n269 --> n323
  n275 --> n323
  n320 --> n324
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
  n321["LowChuangBinaryCompare.ripple_result"]
  n322["LowChuangBinaryCompare.ripple_word"]
  n327["built_adj"]
  n328["built_mul"]
  n329["built_unit"]
  n330["built_weaken"]
  n331["built_word"]
  n332["cartesianDecoder"]
  n333["decoder"]
  n334["filled_pulse"]
  n335["gated_phase"]
  n336["local_unit"]
  n337["outside_col"]
  n338["outside_seed"]
  n339["packed_clean"]
  n340["pulse_word"]
  n341["LowChuangBinaryPhase.averaged_sign"]
  n342["LowChuangBinaryPhase.encoded_diagonal"]
  n349["LowChuangDecoderLayout.digits_read"]
  n350["LowChuangDecoderLayout.digits_valid"]
  n351["LowChuangDecoderLayout.protect_branch"]
  n571["LowChuangUniformBits.fill_at"]
  n572["LowChuangUniformBits.fill_out"]
  n573["LowChuangUniformBits.hWord_cost"]
  n574["LowChuangUniformBits.mean_diagonal"]
  n658["FiniteGateDescription.finiteCodeMatrix_unitary"]
  n336 --> n329
  n333 --> n332
  n339 --> n332
  n327 --> n333
  n328 --> n333
  n329 --> n333
  n330 --> n333
  n331 --> n333
  n334 --> n333
  n340 --> n333
  n341 --> n333
  n573 --> n333
  n574 --> n333
  n321 --> n334
  n337 --> n334
  n338 --> n334
  n349 --> n334
  n350 --> n334
  n571 --> n334
  n572 --> n334
  n658 --> n336
  n322 --> n340
  n327 --> n340
  n328 --> n340
  n330 --> n340
  n331 --> n340
  n335 --> n340
  n342 --> n340
  n350 --> n340
  n351 --> n340
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
  n321["LowChuangBinaryCompare.ripple_result"]
  n322["LowChuangBinaryCompare.ripple_word"]
  n341["averaged_sign"]
  n342["encoded_diagonal"]
  n343["ripple_phase"]
  n694["QmaCompletenessDefs.finiteWordMatrix_unitary"]
  n695["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n736["FiniteThermalComparator.thermalBitValue_bound"]
  n740["FiniteThermalUniformH.thermalUniformBits_less_complex"]
  n736 --> n341
  n740 --> n341
  n694 --> n342
  n695 --> n342
  n321 --> n343
  n322 --> n343
  n342 --> n343
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
  n344["amplifiedTaylorCutoff"]
  n345["doubleTerm"]
  n346["geometricTail"]
  n347["leastCutoff"]
  n348["timeBound"]
  n705["ExponentialPolynomial.exponentialTaylor_eventually_error_lt"]
  n345 --> n344
  n346 --> n344
  n348 --> n344
  n705 --> n347
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
  n326["LowChuangBinaryCompare.unchanged"]
  n349["digits_read"]
  n350["digits_valid"]
  n351["protect_branch"]
  n326 --> n351
```

- [LowChuangBinaryCompare.unchanged](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryCompare.lean#L74)
- [digits_read](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L55)
- [digits_valid](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L31)
- [protect_branch](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangDecoderLayout.lean#L61)

## FQChemQatlib.Dynamics.LowChuangElementary

```mermaid
flowchart LR
  n352["adj_emits"]
  n353["compiles_emits"]
  n354["expand"]
  n355["fixed_program"]
  n356["frameGate_emits"]
  n357["frameGate_emits_of_cubic"]
  n358["mul_emits"]
  n359["qubitRegisterSimulation"]
  n360["scalar_flags"]
  n361["scalar_pair"]
  n362["single"]
  n363["weaken"]
  n366["LowChuangFlagGates.cnotBasis_unit"]
  n369["LowChuangFlagGates.cubic_mark"]
  n373["LowChuangFlagGates.localFlip"]
  n374["LowChuangFlagGates.localHadamards"]
  n375["LowChuangFlagGates.localPhase"]
  n376["LowChuangFlagGates.localScalar"]
  n377["LowChuangFlagGates.onBlocks_apply"]
  n406["LowChuangPhysical.testAncilla_compiles"]
  n407["LowChuangPhysical.testBoth_compiles"]
  n411["LowChuangQueries.cost_append"]
  n416["LowChuangQueries.fixed_append"]
  n422["LowChuangQueries.run_append"]
  n433["LowChuangReflections.cubic_coordinate"]
  n434["LowChuangReflections.fiberPhase_sandwich"]
  n570["LowChuangStandardForm.standardFormProgram"]
  n751["Qubit.hadamard_unitary"]
  n757["Qubit.pauliX_unitary"]
  n762["Tensor.tensorGate_unitary"]
  n358 --> n353
  n362 --> n353
  n363 --> n353
  n355 --> n354
  n411 --> n354
  n416 --> n354
  n422 --> n354
  n352 --> n356
  n353 --> n356
  n357 --> n356
  n358 --> n356
  n360 --> n356
  n361 --> n356
  n362 --> n356
  n363 --> n356
  n366 --> n356
  n369 --> n356
  n374 --> n356
  n407 --> n356
  n433 --> n356
  n751 --> n356
  n762 --> n356
  n352 --> n357
  n353 --> n357
  n358 --> n357
  n362 --> n357
  n363 --> n357
  n373 --> n357
  n375 --> n357
  n376 --> n357
  n406 --> n357
  n434 --> n357
  n757 --> n357
  n762 --> n357
  n354 --> n359
  n356 --> n359
  n570 --> n359
  n377 --> n360
```

- [adj_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L44) (private)
- [compiles_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L59) (private)
- [expand](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L139) (private)
- [fixed_program](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L131) (private)
- [frameGate_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L115)
- [frameGate_emits_of_cubic](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L83) (private)
- [mul_emits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L38) (private)
- [qubitRegisterSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L177)
- [scalar_flags](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L77) (private)
- [scalar_pair](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L72) (private)
- [single](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L35) (private)
- [weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L55) (private)
- [LowChuangFlagGates.cnotBasis_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L79)
- [LowChuangFlagGates.cubic_mark](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L108)
- [LowChuangFlagGates.localFlip](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L153)
- [LowChuangFlagGates.localHadamards](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L149)
- [LowChuangFlagGates.localPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L128)
- [LowChuangFlagGates.localScalar](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L159)
- [LowChuangFlagGates.onBlocks_apply](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L31)
- [LowChuangPhysical.testAncilla_compiles](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L107)
- [LowChuangPhysical.testBoth_compiles](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L127)
- [LowChuangQueries.cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [LowChuangQueries.fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [LowChuangQueries.run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [LowChuangReflections.cubic_coordinate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L111)
- [LowChuangReflections.fiberPhase_sandwich](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L39)
- [LowChuangStandardForm.standardFormProgram](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangStandardForm.lean#L32)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Qubit.pauliX_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L387)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangFlagGates

```mermaid
flowchart LR
  n364["blocks_mul"]
  n365["blocks_star"]
  n366["cnotBasis_unit"]
  n367["cnot_basis_marker"]
  n368["conditionalCnot"]
  n369["cubic_mark"]
  n370["diagonal_flags"]
  n371["flagsTensor"]
  n372["flags_conjugate"]
  n373["localFlip"]
  n374["localHadamards"]
  n375["localPhase"]
  n376["localScalar"]
  n377["onBlocks_apply"]
  n378["onFlags_unit"]
  n379["parallel_tensor"]
  n436["LowChuangReflections.zero_projector"]
  n654["ParallelQSVT.parallel_select_adjoint"]
  n655["ParallelQSVT.parallel_select_mul"]
  n656["ParallelQSVT.parallel_select_one"]
  n751["Qubit.hadamard_unitary"]
  n757["Qubit.pauliX_unitary"]
  n760["Tensor.tensorGate_mul"]
  n761["Tensor.tensorGate_one"]
  n762["Tensor.tensorGate_unitary"]
  n655 --> n364
  n654 --> n365
  n751 --> n366
  n757 --> n366
  n762 --> n366
  n366 --> n367
  n377 --> n368
  n366 --> n369
  n367 --> n369
  n368 --> n369
  n372 --> n369
  n377 --> n369
  n436 --> n369
  n377 --> n370
  n377 --> n371
  n364 --> n372
  n365 --> n372
  n371 --> n373
  n761 --> n373
  n371 --> n374
  n379 --> n374
  n760 --> n374
  n370 --> n375
  n370 --> n376
  n364 --> n378
  n365 --> n378
  n656 --> n378
```

- [blocks_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L35) (private)
- [blocks_star](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L39) (private)
- [cnotBasis_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L79)
- [cnot_basis_marker](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L82) (private)
- [conditionalCnot](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L96)
- [cubic_mark](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L108)
- [diagonal_flags](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L120) (private)
- [flagsTensor](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L139)
- [flags_conjugate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L55) (private)
- [localFlip](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L153)
- [localHadamards](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L149)
- [localPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L128)
- [localScalar](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L159)
- [onBlocks_apply](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L31)
- [onFlags_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L44)
- [parallel_tensor](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L144) (private)
- [LowChuangReflections.zero_projector](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L101)
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
  n380["adjoint_gates"]
  n381["amplification_gates"]
  n382["body_gates"]
  n383["controlled_gates"]
  n384["parallel_phase_gates"]
  n385["swapped_gates"]
  n380 --> n381
  n383 --> n382
  n384 --> n382
  n385 --> n384
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
  n359["LowChuangElementary.qubitRegisterSimulation"]
  n386["coord_iso"]
  n387["evolved_action"]
  n388["exp_action"]
  n389["finiteSimulation"]
  n390["frame_entry"]
  n391["mul_coord"]
  n392["pad_action"]
  n393["pad_hermitian"]
  n394["pad_mul"]
  n395["pad_star"]
  n396["pad_unit"]
  n397["padded_signal"]
  n398["prep_iso"]
  n399["prepared_restrict"]
  n400["star_coord_mul"]
  n401["unpad_error"]
  n632["Basic.compress_norm_le"]
  n634["AncillaErrorLaws.mul"]
  n635["CoordinateFiber.encodingFiber_isIsometry"]
  n640["Postselection.normalized_mulVec"]
  n762["Tensor.tensorGate_unitary"]
  n388 --> n387
  n392 --> n387
  n359 --> n389
  n386 --> n389
  n393 --> n389
  n396 --> n389
  n397 --> n389
  n401 --> n389
  n640 --> n389
  n395 --> n393
  n392 --> n394
  n394 --> n396
  n395 --> n396
  n386 --> n397
  n396 --> n397
  n398 --> n397
  n399 --> n397
  n634 --> n398
  n635 --> n398
  n762 --> n398
  n386 --> n399
  n390 --> n399
  n391 --> n399
  n392 --> n399
  n400 --> n399
  n386 --> n401
  n387 --> n401
  n632 --> n401
```

- [LowChuangElementary.qubitRegisterSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L177)
- [coord_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L26)
- [evolved_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L78)
- [exp_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L63) (private)
- [finiteSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L168)
- [frame_entry](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L111) (private)
- [mul_coord](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L102) (private)
- [pad_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L34) (private)
- [pad_hermitian](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L60)
- [pad_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L44) (private)
- [pad_star](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L41) (private)
- [pad_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L53)
- [padded_signal](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L142)
- [prep_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L136) (private)
- [prepared_restrict](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L118) (private)
- [star_coord_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L107) (private)
- [unpad_error](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L82) (private)
- [Basic.compress_norm_le](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Basic.lean#L207)
- [AncillaErrorLaws.mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/EncodingCore/AncillaErrorLaws.lean#L215)
- [CoordinateFiber.encodingFiber_isIsometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/EncodingCore/CoordinateFiber.lean#L90)
- [Postselection.normalized_mulVec](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Postselection.lean#L264)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangPhysical

```mermaid
flowchart LR
  n264["BorrowedControls.borrowedMCX"]
  n402["compileToggle"]
  n403["distinct_anc"]
  n404["positive_controls"]
  n405["succ_ne_inner"]
  n406["testAncilla_compiles"]
  n407["testBoth_compiles"]
  n695["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n264 --> n402
  n695 --> n402
  n402 --> n406
  n403 --> n406
  n404 --> n406
  n405 --> n406
  n402 --> n407
  n403 --> n407
  n404 --> n407
  n405 --> n407
```

- [BorrowedControls.borrowedMCX](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L244)
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
  n408["broadcast_adjoint"]
  n409["broadcast_mul"]
  n410["controlledSubstitution"]
  n411["cost_append"]
  n412["cost_controlled"]
  n413["cost_inverse"]
  n414["cost_substitute"]
  n415["covers_substitute"]
  n416["fixed_append"]
  n417["fixed_inverse"]
  n418["fixed_substitute"]
  n419["lift_adjoint"]
  n420["lift_conjugate"]
  n421["lift_mul"]
  n422["run_append"]
  n423["run_controlled"]
  n424["run_inverse"]
  n425["run_substitute"]
  n652["ParallelQSVT.parallelOracle_adjoint"]
  n654["ParallelQSVT.parallel_select_adjoint"]
  n655["ParallelQSVT.parallel_select_mul"]
  n656["ParallelQSVT.parallel_select_one"]
  n685["ControlledQueryCircuit.controlOracle_adjoint"]
  n686["ControlledQueryCircuit.controlOracle_mul"]
  n687["ControlledQueryCircuit.controlOracle_one"]
  n652 --> n408
  n655 --> n409
  n412 --> n410
  n414 --> n410
  n423 --> n410
  n425 --> n410
  n411 --> n413
  n411 --> n414
  n413 --> n414
  n416 --> n417
  n416 --> n418
  n417 --> n418
  n652 --> n419
  n685 --> n419
  n654 --> n420
  n655 --> n420
  n656 --> n420
  n655 --> n421
  n686 --> n421
  n419 --> n423
  n421 --> n423
  n656 --> n423
  n687 --> n423
  n422 --> n424
  n422 --> n425
  n424 --> n425
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
  n374["LowChuangFlagGates.localHadamards"]
  n389["LowChuangPadding.finiteSimulation"]
  n411["LowChuangQueries.cost_append"]
  n416["LowChuangQueries.fixed_append"]
  n422["LowChuangQueries.run_append"]
  n426["coordinate_acts"]
  n427["coordinate_iso"]
  n428["coordinate_program"]
  n429["finiteCoordinateSimulation"]
  n435["LowChuangReflections.hamiltonianFrame_coordinates"]
  n635["CoordinateFiber.encodingFiber_isIsometry"]
  n641["Postselection.postselectionProbability_eq_norm_sq"]
  n710["RealPartQSVT.averageFrame_isIsometry"]
  n722["FiniteInversePhaseProgram.coordinatePhaseFrame_isometry"]
  n723["FiniteInversePhaseProgram.inverseLabelPhase_unit"]
  n751["Qubit.hadamard_unitary"]
  n762["Tensor.tensorGate_unitary"]
  n427 --> n426
  n435 --> n426
  n635 --> n426
  n641 --> n426
  n710 --> n426
  n723 --> n426
  n635 --> n427
  n722 --> n427
  n374 --> n428
  n411 --> n428
  n416 --> n428
  n422 --> n428
  n426 --> n428
  n751 --> n428
  n762 --> n428
  n389 --> n429
  n428 --> n429
```

- [LowChuangFlagGates.localHadamards](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L149)
- [LowChuangPadding.finiteSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPadding.lean#L168)
- [LowChuangQueries.cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [LowChuangQueries.fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [LowChuangQueries.run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [coordinate_acts](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L25)
- [coordinate_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L20) (private)
- [coordinate_program](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L47) (private)
- [finiteCoordinateSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L84)
- [LowChuangReflections.hamiltonianFrame_coordinates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L88)
- [CoordinateFiber.encodingFiber_isIsometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/EncodingCore/CoordinateFiber.lean#L90)
- [Postselection.postselectionProbability_eq_norm_sq](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/BlockEncoding/Postselection.lean#L315)
- [RealPartQSVT.averageFrame_isIsometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/RealPartQSVT.lean#L113)
- [FiniteInversePhaseProgram.coordinatePhaseFrame_isometry](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/LinearSystems/FiniteInversePhaseProgram.lean#L294)
- [FiniteInversePhaseProgram.inverseLabelPhase_unit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/LinearSystems/FiniteInversePhaseProgram.lean#L241)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangReflections

```mermaid
flowchart LR
  n430["H_unit"]
  n431["coordinate_parallel"]
  n432["coordinate_smul"]
  n433["cubic_coordinate"]
  n434["fiberPhase_sandwich"]
  n435["hamiltonianFrame_coordinates"]
  n436["zero_projector"]
  n644["FiberBridge.rangeProjector_encodingFiber"]
  n653["ParallelQSVT.parallelOracle_unitary"]
  n720["FiniteInversePhaseProgram.averageFrame_labelH"]
  n721["FiniteInversePhaseProgram.coordinatePhaseFrame_apply"]
  n723["FiniteInversePhaseProgram.inverseLabelPhase_unit"]
  n751["Qubit.hadamard_unitary"]
  n762["Tensor.tensorGate_unitary"]
  n653 --> n430
  n751 --> n430
  n762 --> n430
  n721 --> n431
  n721 --> n432
  n430 --> n433
  n435 --> n433
  n723 --> n433
  n644 --> n434
  n431 --> n435
  n432 --> n435
  n720 --> n435
  n721 --> n436
```

- [H_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L95) (private)
- [coordinate_parallel](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L77) (private)
- [coordinate_smul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L83) (private)
- [cubic_coordinate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L111)
- [fiberPhase_sandwich](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L39)
- [hamiltonianFrame_coordinates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L88)
- [zero_projector](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L101)
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
  n344["LowChuangCutoff.amplifiedTaylorCutoff"]
  n347["LowChuangCutoff.leastCutoff"]
  n381["LowChuangGateWord.amplification_gates"]
  n382["LowChuangGateWord.body_gates"]
  n437["amplifiedLevels"]
  n438["attenuatedBody"]
  n439["optimalCutoffEvolution"]
  n440["uniformCutoffWord"]
  n632["Basic.compress_norm_le"]
  n633["Basic.unitary_norm_le_one"]
  n639["Postselection.postselection_probability_lower"]
  n643["Postselection.normalized_iff_stateVector_norm"]
  n646["RobustCoherentImplementation.coherent_oaa_expanded_subroutine"]
  n647["RobustCoherentImplementation.coherent_oaa_word_correct"]
  n648["ScaleEightCoherentAmplification.scaleEightCubic_lipschitz"]
  n649["ScaleEightCoherentAmplification.scaleEightCubic_sin"]
  n650["ScaleEightCoherentAmplification.scaleEight_clean_from_compression"]
  n651["ScaleEightCoherentAmplification.scaleEight_parameter_bounds"]
  n653["ParallelQSVT.parallelOracle_unitary"]
  n688["ControlledQueryCircuit.controlOracle_unitary"]
  n698["CircuitWellFormed.evaluate_unitary"]
  n700["CountedHamiltonian.compileHamiltonian_wellFormed"]
  n701["CountedHamiltonian.counts_compileHamiltonian"]
  n702["CountedHamiltonian.evaluate_compileHamiltonian"]
  n703["ExponentialPolynomial.exponentialTaylorError_nonneg"]
  n704["ExponentialPolynomial.exponentialTaylorPolynomial_error_le"]
  n706["HamiltonianSimulation.exponentialTaylorPolynomial_eq_trig"]
  n707["HamiltonianSimulation.hamiltonian_phase_projectedEncoding"]
  n708["HamiltonianSimulation.hamiltonian_realPart_of_completion"]
  n709["HamiltonianSimulation.hermitian_realPart_projectedEncoding"]
  n710["RealPartQSVT.averageFrame_isIsometry"]
  n711["RealPartQSVT.average_projectedEncoding"]
  n712["RealPolynomial.exists_phases_of_strict"]
  n713["TrigApproximation.cosineTaylorPolynomial_abs_lt_two"]
  n714["TrigApproximation.cosineTaylorPolynomial_comp_neg_X"]
  n715["TrigApproximation.cosineTaylorPolynomial_natDegree_le"]
  n716["TrigApproximation.sineTaylorPolynomial_abs_lt_two"]
  n717["TrigApproximation.sineTaylorPolynomial_comp_neg_X"]
  n718["TrigApproximation.sineTaylorPolynomial_natDegree_le"]
  n719["ComputedSignalSimulation.computed_signal_hermitian_polynomial_error"]
  n752["Qubit.hamiltonianEvolution_unitary"]
  n755["Qubit.normalized_applyGate"]
  n632 --> n437
  n633 --> n437
  n646 --> n437
  n647 --> n437
  n648 --> n437
  n649 --> n437
  n698 --> n437
  n382 --> n438
  n651 --> n438
  n700 --> n438
  n701 --> n438
  n702 --> n438
  n706 --> n438
  n707 --> n438
  n708 --> n438
  n709 --> n438
  n711 --> n438
  n712 --> n438
  n713 --> n438
  n714 --> n438
  n715 --> n438
  n716 --> n438
  n717 --> n438
  n718 --> n438
  n440 --> n439
  n344 --> n440
  n347 --> n440
  n381 --> n440
  n437 --> n440
  n438 --> n440
  n632 --> n440
  n633 --> n440
  n639 --> n440
  n643 --> n440
  n650 --> n440
  n653 --> n440
  n688 --> n440
  n698 --> n440
  n703 --> n440
  n704 --> n440
  n710 --> n440
  n719 --> n440
  n752 --> n440
  n755 --> n440
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

## FQChemQatlib.Dynamics.LowChuangSingleton

```mermaid
flowchart LR
  n252["AncillaFreePhase.chain"]
  n255["AncillaFreePhase.finiteCertificate"]
  n259["AncillaFreePhase.multiControlledPhase"]
  n260["AncillaFreePhase.reverseProduct"]
  n263["BorrowedControls.bit"]
  n269["BorrowedControls.compose"]
  n270["BorrowedControls.controlledBit"]
  n377["LowChuangFlagGates.onBlocks_apply"]
  n404["LowChuangPhysical.positive_controls"]
  n436["LowChuangReflections.zero_projector"]
  n441["classicalEmits"]
  n442["coordinateMark"]
  n443["diagonalFlags"]
  n444["flagWires"]
  n445["flagsPhase"]
  n446["merge"]
  n447["onlyGate"]
  n448["phasePi"]
  n449["phaseUnit"]
  n450["physicalPhase"]
  n451["relax"]
  n452["routedPhase"]
  n453["swapWord"]
  n255 --> n441
  n260 --> n441
  n252 --> n442
  n263 --> n442
  n269 --> n442
  n404 --> n442
  n436 --> n442
  n441 --> n442
  n444 --> n442
  n446 --> n442
  n448 --> n442
  n450 --> n442
  n377 --> n443
  n443 --> n445
  n447 --> n445
  n449 --> n445
  n259 --> n450
  n445 --> n450
  n446 --> n450
  n447 --> n450
  n451 --> n450
  n452 --> n450
  n252 --> n452
  n441 --> n452
  n445 --> n452
  n446 --> n452
  n451 --> n452
  n453 --> n452
  n269 --> n453
  n270 --> n453
```

- [AncillaFreePhase.chain](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L32)
- [AncillaFreePhase.finiteCertificate](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L69)
- [AncillaFreePhase.multiControlledPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L114)
- [AncillaFreePhase.reverseProduct](../../integrations/qatlib/FQChemQatlib/Dynamics/AncillaFreePhase.lean#L80)
- [BorrowedControls.bit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L54)
- [BorrowedControls.compose](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L34)
- [BorrowedControls.controlledBit](../../integrations/qatlib/FQChemQatlib/Dynamics/BorrowedControls.lean#L62)
- [LowChuangFlagGates.onBlocks_apply](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L31)
- [LowChuangPhysical.positive_controls](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangPhysical.lean#L49)
- [LowChuangReflections.zero_projector](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReflections.lean#L101)
- [classicalEmits](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L35) (private)
- [coordinateMark](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L160)
- [diagonalFlags](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L63) (private)
- [flagWires](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L146) (private)
- [flagsPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L73) (private)
- [merge](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L27) (private)
- [onlyGate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L24) (private)
- [phasePi](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L156) (private)
- [phaseUnit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L69) (private)
- [physicalPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L125)
- [relax](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L32) (private)
- [routedPhase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L94) (private)
- [swapWord](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSingleton.lean#L50) (private)

## FQChemQatlib.Dynamics.LowChuangSparseAccess

```mermaid
flowchart LR
  n409["LowChuangQueries.broadcast_mul"]
  n420["LowChuangQueries.lift_conjugate"]
  n421["LowChuangQueries.lift_mul"]
  n454["body_spec"]
  n653["ParallelQSVT.parallelOracle_unitary"]
  n680["ExecutionSemantics.permMatrix_unitary_of_injective"]
  n762["Tensor.tensorGate_unitary"]
  n409 --> n454
  n420 --> n454
  n421 --> n454
  n653 --> n454
  n680 --> n454
  n762 --> n454
```

- [LowChuangQueries.broadcast_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L95)
- [LowChuangQueries.lift_conjugate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L105)
- [LowChuangQueries.lift_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L80)
- [body_spec](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAccess.lean#L40)
- [ParallelQSVT.parallelOracle_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L120)
- [ExecutionSemantics.permMatrix_unitary_of_injective](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HspRecovery/RecordExtract/ExecutionSemantics.lean#L129)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangSparseAccuracy

```mermaid
flowchart LR
  n455["entryRoundoff"]
  n456["normalize_error"]
  n457["roundedHamiltonian"]
  n458["roundedSparseEvolution"]
  n459["successfulOutput"]
  n460["zeroAccess"]
  n541["LowChuangSparseReadout.zeroHamiltonian"]
  n683["StaticNoncommutingLCHS.static_lchs_hamiltonian_evolution_stability"]
  n689["MixedFidelity.pure_trace_distance_le_re_inner"]
  n729["TensorOperatorNorm.l2_norm_mulVec_fromVec_le"]
  n746["RelabelOperatorNorm.l2_norm_relabelGate"]
  n747["RepresentationBridge.inner_euclidean_fromVec"]
  n748["RepresentationBridge.normalized_iff_norm_toEuclidean_fromVec"]
  n755["Qubit.normalized_applyGate"]
  n785["SourceSpectralBounds.spectral_norm_le_rowCol_sums"]
  n746 --> n455
  n785 --> n455
  n683 --> n457
  n455 --> n458
  n457 --> n458
  n456 --> n459
  n689 --> n459
  n729 --> n459
  n747 --> n459
  n748 --> n459
  n755 --> n459
  n541 --> n460
```

- [entryRoundoff](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAccuracy.lean#L37)
- [normalize_error](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAccuracy.lean#L94) (private)
- [roundedHamiltonian](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAccuracy.lean#L28)
- [roundedSparseEvolution](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAccuracy.lean#L70)
- [successfulOutput](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAccuracy.lean#L113)
- [zeroAccess](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAccuracy.lean#L79)
- [LowChuangSparseReadout.zeroHamiltonian](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseReadout.lean#L98)
- [StaticNoncommutingLCHS.static_lchs_hamiltonian_evolution_stability](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LchsSimulation/StaticLchs/StaticNoncommutingLCHS.lean#L488)
- [MixedFidelity.pure_trace_distance_le_re_inner](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/MixedFidelity/FidelityMetric/MixedFidelity.lean#L781)
- [TensorOperatorNorm.l2_norm_mulVec_fromVec_le](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/ReferenceError/RefTraceError/TensorOperatorNorm.lean#L62)
- [RelabelOperatorNorm.l2_norm_relabelGate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/BornBridge/RelabelOperatorNorm.lean#L101)
- [RepresentationBridge.inner_euclidean_fromVec](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/BornBridge/RepresentationBridge.lean#L90)
- [RepresentationBridge.normalized_iff_norm_toEuclidean_fromVec](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/BornBridge/RepresentationBridge.lean#L116)
- [Qubit.normalized_applyGate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L266)
- [SourceSpectralBounds.spectral_norm_le_rowCol_sums](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/ResolventQPE24/MainResults/SpectralTheory/SourceSpectralBounds.lean#L183)

## FQChemQatlib.Dynamics.LowChuangSparseAssembly

```mermaid
flowchart LR
  n411["LowChuangQueries.cost_append"]
  n413["LowChuangQueries.cost_inverse"]
  n416["LowChuangQueries.fixed_append"]
  n422["LowChuangQueries.run_append"]
  n424["LowChuangQueries.run_inverse"]
  n461["compile_cost"]
  n462["compile_fixed"]
  n463["compile_gates"]
  n464["compile_run"]
  n465["inverse_fixed"]
  n466["push_adj"]
  n467["push_mul"]
  n468["push_one"]
  n469["rename_cost"]
  n470["rename_fixed"]
  n471["rename_run"]
  n472["undo"]
  n411 --> n461
  n413 --> n461
  n416 --> n462
  n465 --> n462
  n422 --> n464
  n424 --> n464
  n416 --> n465
  n467 --> n471
  n468 --> n471
```

- [LowChuangQueries.cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [LowChuangQueries.cost_inverse](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L69)
- [LowChuangQueries.fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [LowChuangQueries.run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [LowChuangQueries.run_inverse](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L56)
- [compile_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L76)
- [compile_fixed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L95)
- [compile_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L106)
- [compile_run](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L66)
- [inverse_fixed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L86) (private)
- [push_adj](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L20)
- [push_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L19)
- [push_one](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L21)
- [rename_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L41)
- [rename_fixed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L48)
- [rename_run](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L30)
- [undo](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L22)

## FQChemQatlib.Dynamics.LowChuangSparseBlock

```mermaid
flowchart LR
  n473["compression"]
  n474["frame_iso"]
  n475["left_col"]
  n476["loaded_col"]
  n477["oracle_unit"]
  n478["permutation_action"]
  n479["prep_col"]
  n480["right_col"]
  n653["ParallelQSVT.parallelOracle_unitary"]
  n680["ExecutionSemantics.permMatrix_unitary_of_injective"]
  n758["Qubit.permMatrix_conjTranspose"]
  n762["Tensor.tensorGate_unitary"]
  n475 --> n473
  n480 --> n473
  n758 --> n473
  n478 --> n475
  n479 --> n475
  n478 --> n476
  n479 --> n476
  n653 --> n477
  n680 --> n477
  n762 --> n477
  n478 --> n479
  n476 --> n480
```

- [compression](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L105)
- [frame_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L25)
- [left_col](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L84) (private)
- [loaded_col](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L76) (private)
- [oracle_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L126)
- [permutation_action](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L63) (private)
- [prep_col](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L69) (private)
- [right_col](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L95) (private)
- [ParallelQSVT.parallelOracle_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L120)
- [ExecutionSemantics.permMatrix_unitary_of_injective](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HspRecovery/RecordExtract/ExecutionSemantics.lean#L129)
- [Qubit.permMatrix_conjTranspose](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L289)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangSparseCartesian

```mermaid
flowchart LR
  n332["LowChuangBinaryDecoder.cartesianDecoder"]
  n473["LowChuangSparseBlock.compression"]
  n474["LowChuangSparseBlock.frame_iso"]
  n477["LowChuangSparseBlock.oracle_unit"]
  n481["cartesianEncoding"]
  n482["padded_slot_bound"]
  n483["slot_supported"]
  n484["slots_column"]
  n485["table_blank"]
  n572["LowChuangUniformBits.fill_out"]
  n573["LowChuangUniformBits.hWord_cost"]
  n694["QmaCompletenessDefs.finiteWordMatrix_unitary"]
  n695["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n742["FiniteThermalUniformH.thermalUniformHWord_zero_column"]
  n332 --> n481
  n473 --> n481
  n474 --> n481
  n477 --> n481
  n483 -.-> n481
  n484 --> n481
  n485 --> n481
  n573 --> n481
  n694 --> n481
  n572 --> n483
  n695 --> n484
  n742 --> n484
```

- [LowChuangBinaryDecoder.cartesianDecoder](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangBinaryDecoder.lean#L188)
- [LowChuangSparseBlock.compression](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L105)
- [LowChuangSparseBlock.frame_iso](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L25)
- [LowChuangSparseBlock.oracle_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseBlock.lean#L126)
- [cartesianEncoding](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCartesian.lean#L73)
- [padded_slot_bound](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCartesian.lean#L56)
- [slot_supported](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCartesian.lean#L53)
- [slots_column](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCartesian.lean#L40)
- [table_blank](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCartesian.lean#L35)
- [LowChuangUniformBits.fill_out](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L28)
- [LowChuangUniformBits.hWord_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L43)
- [QmaCompletenessDefs.finiteWordMatrix_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L158)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)
- [FiniteThermalUniformH.thermalUniformHWord_zero_column](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalUniformH.lean#L302)

## FQChemQatlib.Dynamics.LowChuangSparseControl

```mermaid
flowchart LR
  n419["LowChuangQueries.lift_adjoint"]
  n421["LowChuangQueries.lift_mul"]
  n486["adj"]
  n487["code"]
  n488["concat"]
  n489["controlledCnot"]
  n490["ctrl_mul"]
  n491["ctrl_one"]
  n492["ctrl_star"]
  n493["decoder"]
  n494["empty"]
  n495["localGate"]
  n496["phase"]
  n497["phase_unit"]
  n498["placed"]
  n499["single"]
  n500["toff_invol"]
  n501["weaken"]
  n531["LowChuangSparsePlacement.place_diag"]
  n532["LowChuangSparsePlacement.place_perm"]
  n533["LowChuangSparsePlacement.raw_control_diag"]
  n534["LowChuangSparsePlacement.raw_control_perm"]
  n535["LowChuangSparsePlacement.raw_mul"]
  n569["LowChuangSparseWires.three"]
  n652["ParallelQSVT.parallelOracle_adjoint"]
  n655["ParallelQSVT.parallel_select_mul"]
  n656["ParallelQSVT.parallel_select_one"]
  n665["LocalReflectionGates.tGateAdj_mem_unitary"]
  n666["LocalReflectionGates.tGate_mem_unitary"]
  n687["ControlledQueryCircuit.controlOracle_one"]
  n751["Qubit.hadamard_unitary"]
  n757["Qubit.pauliX_unitary"]
  n759["Qubit.permMatrix_unitary"]
  n489 --> n487
  n499 --> n487
  n501 --> n487
  n665 --> n487
  n666 --> n487
  n751 --> n487
  n757 --> n487
  n498 --> n489
  n500 --> n489
  n532 --> n489
  n534 --> n489
  n569 --> n489
  n759 --> n489
  n421 --> n490
  n535 --> n490
  n655 --> n490
  n656 --> n491
  n687 --> n491
  n419 --> n492
  n652 -.-> n492
  n488 --> n493
  n490 --> n493
  n491 --> n493
  n494 --> n493
  n495 --> n493
  n501 --> n493
  n486 --> n495
  n487 --> n495
  n492 --> n495
  n496 --> n495
  n497 --> n496
  n498 --> n496
  n499 --> n496
  n501 --> n496
  n531 --> n496
  n533 --> n496
  n569 --> n496
```

- [LowChuangQueries.lift_adjoint](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L86)
- [LowChuangQueries.lift_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L80)
- [adj](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L55)
- [code](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L148)
- [concat](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L47)
- [controlledCnot](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L113)
- [ctrl_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L66)
- [ctrl_one](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L75)
- [ctrl_star](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L72)
- [decoder](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L181)
- [empty](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L45)
- [localGate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L172)
- [phase](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L84)
- [phase_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L78) (private)
- [placed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L63)
- [single](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L42)
- [toff_invol](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L109) (private)
- [weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L52)
- [LowChuangSparsePlacement.place_diag](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L35)
- [LowChuangSparsePlacement.place_perm](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L55)
- [LowChuangSparsePlacement.raw_control_diag](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L104)
- [LowChuangSparsePlacement.raw_control_perm](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L117)
- [LowChuangSparsePlacement.raw_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L99)
- [LowChuangSparseWires.three](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L97)
- [ParallelQSVT.parallelOracle_adjoint](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L115)
- [ParallelQSVT.parallel_select_mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L70)
- [ParallelQSVT.parallel_select_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L93)
- [LocalReflectionGates.tGateAdj_mem_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L315)
- [LocalReflectionGates.tGate_mem_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L312)
- [ControlledQueryCircuit.controlOracle_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/ControlledQueryCircuit.lean#L69)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Qubit.pauliX_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L387)
- [Qubit.permMatrix_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L300)

## FQChemQatlib.Dynamics.LowChuangSparseCutoff

```mermaid
flowchart LR
  n502["cartesianCutoff"]
  n503["cutoff_dilation"]
  n504["factorial_block"]
  n505["factorial_dilation"]
  n503 --> n502
  n505 --> n503
  n504 --> n505
```

- [cartesianCutoff](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCutoff.lean#L79)
- [cutoff_dilation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCutoff.lean#L40)
- [factorial_block](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCutoff.lean#L12) (private)
- [factorial_dilation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCutoff.lean#L25) (private)

## FQChemQatlib.Dynamics.LowChuangSparseOracle

```mermaid
flowchart LR
  n409["LowChuangQueries.broadcast_mul"]
  n414["LowChuangQueries.cost_substitute"]
  n420["LowChuangQueries.lift_conjugate"]
  n421["LowChuangQueries.lift_mul"]
  n425["LowChuangQueries.run_substitute"]
  n440["LowChuangSimulation.uniformCutoffWord"]
  n506["blockProgram_spec"]
  n507["frame_iso"]
  n508["permutation_action"]
  n509["prepared_column"]
  n510["right_column"]
  n511["rot_unit"]
  n512["rotation_action"]
  n513["slot_norm"]
  n514["sparseOracleEncoding"]
  n515["sparseQuerySimulation"]
  n516["sparseStandardForm"]
  n517["uniform_unit"]
  n518["value_action"]
  n636["PrepareUnitary.nonnegativePrepare_column"]
  n637["PrepareUnitary.nonnegativePrepare_unitary"]
  n638["LCU.select_unitary"]
  n680["ExecutionSemantics.permMatrix_unitary_of_injective"]
  n758["Qubit.permMatrix_conjTranspose"]
  n759["Qubit.permMatrix_unitary"]
  n762["Tensor.tensorGate_unitary"]
  n409 --> n506
  n420 --> n506
  n421 --> n506
  n517 --> n506
  n680 --> n506
  n758 --> n506
  n759 --> n506
  n508 --> n509
  n636 --> n509
  n508 --> n510
  n509 --> n510
  n518 --> n510
  n507 --> n514
  n509 --> n514
  n510 --> n514
  n511 --> n514
  n517 --> n514
  n638 --> n514
  n680 --> n514
  n414 --> n515
  n425 --> n515
  n440 --> n515
  n506 --> n515
  n507 --> n515
  n514 --> n515
  n506 --> n516
  n514 --> n516
  n513 --> n517
  n637 --> n517
  n638 --> n517
  n762 --> n517
  n508 --> n518
  n512 --> n518
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

## FQChemQatlib.Dynamics.LowChuangSparsePacking

```mermaid
flowchart LR
  n466["LowChuangSparseAssembly.push_adj"]
  n467["LowChuangSparseAssembly.push_mul"]
  n468["LowChuangSparseAssembly.push_one"]
  n519["packed_compression"]
  n520["push_lifted"]
  n521["push_unit"]
  n522["scaledEvolution"]
  n466 --> n521
  n467 --> n521
  n468 --> n521
```

- [LowChuangSparseAssembly.push_adj](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L20)
- [LowChuangSparseAssembly.push_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L19)
- [LowChuangSparseAssembly.push_one](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L21)
- [packed_compression](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePacking.lean#L39)
- [push_lifted](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePacking.lean#L32)
- [push_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePacking.lean#L27)
- [scaledEvolution](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePacking.lean#L56)

## FQChemQatlib.Dynamics.LowChuangSparsePhysicalBlock

```mermaid
flowchart LR
  n409["LowChuangQueries.broadcast_mul"]
  n411["LowChuangQueries.cost_append"]
  n416["LowChuangQueries.fixed_append"]
  n422["LowChuangQueries.run_append"]
  n454["LowChuangSparseAccess.body_spec"]
  n486["LowChuangSparseControl.adj"]
  n488["LowChuangSparseControl.concat"]
  n493["LowChuangSparseControl.decoder"]
  n494["LowChuangSparseControl.empty"]
  n499["LowChuangSparseControl.single"]
  n501["LowChuangSparseControl.weaken"]
  n523["compileFixed"]
  n524["from_raw"]
  n525["physicalBody"]
  n526["raw_from"]
  n527["slot_gates"]
  n528["slot_mul"]
  n529["slot_one"]
  n530["slot_word"]
  n535["LowChuangSparsePlacement.raw_mul"]
  n558["LowChuangSparseSwap.swapGate"]
  n573["LowChuangUniformBits.hWord_cost"]
  n655["ParallelQSVT.parallel_select_mul"]
  n656["ParallelQSVT.parallel_select_one"]
  n694["QmaCompletenessDefs.finiteWordMatrix_unitary"]
  n760["Tensor.tensorGate_mul"]
  n761["Tensor.tensorGate_one"]
  n524 --> n523
  n526 --> n523
  n411 --> n525
  n416 --> n525
  n422 --> n525
  n454 --> n525
  n486 --> n525
  n493 --> n525
  n523 --> n525
  n527 --> n525
  n558 --> n525
  n573 --> n525
  n694 --> n525
  n501 --> n527
  n530 --> n527
  n573 --> n527
  n409 --> n528
  n535 --> n528
  n655 --> n528
  n760 --> n528
  n656 --> n529
  n761 --> n529
  n488 --> n530
  n494 --> n530
  n499 --> n530
  n528 --> n530
  n529 --> n530
```

- [LowChuangQueries.broadcast_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L95)
- [LowChuangQueries.cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [LowChuangQueries.fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [LowChuangQueries.run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [LowChuangSparseAccess.body_spec](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAccess.lean#L40)
- [LowChuangSparseControl.adj](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L55)
- [LowChuangSparseControl.concat](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L47)
- [LowChuangSparseControl.decoder](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L181)
- [LowChuangSparseControl.empty](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L45)
- [LowChuangSparseControl.single](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L42)
- [LowChuangSparseControl.weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L52)
- [compileFixed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L65) (private)
- [from_raw](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L57) (private)
- [physicalBody](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L99)
- [raw_from](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L52) (private)
- [slot_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L44)
- [slot_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L24) (private)
- [slot_one](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L32) (private)
- [slot_word](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L35) (private)
- [LowChuangSparsePlacement.raw_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L99)
- [LowChuangSparseSwap.swapGate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSwap.lean#L86)
- [LowChuangUniformBits.hWord_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L43)
- [ParallelQSVT.parallel_select_mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L70)
- [ParallelQSVT.parallel_select_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L93)
- [QmaCompletenessDefs.finiteWordMatrix_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L158)
- [Tensor.tensorGate_mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L114)
- [Tensor.tensorGate_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L122)

## FQChemQatlib.Dynamics.LowChuangSparsePlacement

```mermaid
flowchart LR
  n531["place_diag"]
  n532["place_perm"]
  n533["raw_control_diag"]
  n534["raw_control_perm"]
  n535["raw_mul"]
  n536["raw_star"]
  n537["triple_range"]
  n565["LowChuangSparseWires.place_apply"]
  n565 --> n531
  n565 --> n532
```

- [place_diag](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L35)
- [place_perm](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L55)
- [raw_control_diag](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L104)
- [raw_control_perm](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L117)
- [raw_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L99)
- [raw_star](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L102)
- [triple_range](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L24)
- [LowChuangSparseWires.place_apply](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L34)

## FQChemQatlib.Dynamics.LowChuangSparseReadout

```mermaid
flowchart LR
  n374["LowChuangFlagGates.localHadamards"]
  n411["LowChuangQueries.cost_append"]
  n416["LowChuangQueries.fixed_append"]
  n422["LowChuangQueries.run_append"]
  n426["LowChuangReadout.coordinate_acts"]
  n538["binaryRange"]
  n539["representable"]
  n540["sparseCoordinateSimulation"]
  n541["zeroHamiltonian"]
  n543["LowChuangSparseResources.sparseResourceBound"]
  n739["FiniteThermalUniformH.thermalBitValue_ofFn"]
  n751["Qubit.hadamard_unitary"]
  n762["Tensor.tensorGate_unitary"]
  n739 --> n539
  n374 --> n540
  n411 --> n540
  n416 --> n540
  n422 --> n540
  n426 --> n540
  n543 --> n540
  n751 --> n540
  n762 --> n540
```

- [LowChuangFlagGates.localHadamards](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangFlagGates.lean#L149)
- [LowChuangQueries.cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [LowChuangQueries.fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [LowChuangQueries.run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [LowChuangReadout.coordinate_acts](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangReadout.lean#L25)
- [binaryRange](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseReadout.lean#L24)
- [representable](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseReadout.lean#L35)
- [sparseCoordinateSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseReadout.lean#L56)
- [zeroHamiltonian](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseReadout.lean#L98)
- [LowChuangSparseResources.sparseResourceBound](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseResources.lean#L57)
- [FiniteThermalUniformH.thermalBitValue_ofFn](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalUniformH.lean#L143)
- [Qubit.hadamard_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L352)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Dynamics.LowChuangSparseResources

```mermaid
flowchart LR
  n347["LowChuangCutoff.leastCutoff"]
  n482["LowChuangSparseCartesian.padded_slot_bound"]
  n503["LowChuangSparseCutoff.cutoff_dilation"]
  n542["budget"]
  n543["sparseResourceBound"]
  n544["time_scale"]
  n551["LowChuangSparseSimulation.elementarySparseSimulation"]
  n347 --> n543
  n503 --> n543
  n542 --> n543
  n544 --> n543
  n551 --> n543
  n482 --> n544
```

- [LowChuangCutoff.leastCutoff](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangCutoff.lean#L21)
- [LowChuangSparseCartesian.padded_slot_bound](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCartesian.lean#L56)
- [LowChuangSparseCutoff.cutoff_dilation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCutoff.lean#L40)
- [budget](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseResources.lean#L36) (private)
- [sparseResourceBound](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseResources.lean#L57)
- [time_scale](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseResources.lean#L25) (private)
- [LowChuangSparseSimulation.elementarySparseSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSimulation.lean#L70)

## FQChemQatlib.Dynamics.LowChuangSparseScalar

```mermaid
flowchart LR
  n411["LowChuangQueries.cost_append"]
  n416["LowChuangQueries.fixed_append"]
  n422["LowChuangQueries.run_append"]
  n545["conjugate"]
  n546["counts"]
  n547["oneWire_unit"]
  n548["pulses_eval"]
  n549["rotor_add"]
  n550["scalarEvolution"]
  n750["Qubit.diagonal_mem_unitaryGroup"]
  n750 --> n547
  n549 --> n548
  n411 --> n550
  n416 --> n550
  n422 --> n550
  n545 --> n550
  n546 --> n550
  n548 --> n550
  n549 --> n550
```

- [LowChuangQueries.cost_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L50)
- [LowChuangQueries.fixed_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L182)
- [LowChuangQueries.run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangQueries.lean#L43)
- [conjugate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseScalar.lean#L68) (private)
- [counts](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseScalar.lean#L49) (private)
- [oneWire_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseScalar.lean#L79)
- [pulses_eval](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseScalar.lean#L39) (private)
- [rotor_add](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseScalar.lean#L20) (private)
- [scalarEvolution](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseScalar.lean#L93)
- [Qubit.diagonal_mem_unitaryGroup](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L682)

## FQChemQatlib.Dynamics.LowChuangSparseSimulation

```mermaid
flowchart LR
  n359["LowChuangElementary.qubitRegisterSimulation"]
  n461["LowChuangSparseAssembly.compile_cost"]
  n462["LowChuangSparseAssembly.compile_fixed"]
  n463["LowChuangSparseAssembly.compile_gates"]
  n464["LowChuangSparseAssembly.compile_run"]
  n469["LowChuangSparseAssembly.rename_cost"]
  n470["LowChuangSparseAssembly.rename_fixed"]
  n471["LowChuangSparseAssembly.rename_run"]
  n481["LowChuangSparseCartesian.cartesianEncoding"]
  n519["LowChuangSparsePacking.packed_compression"]
  n520["LowChuangSparsePacking.push_lifted"]
  n521["LowChuangSparsePacking.push_unit"]
  n522["LowChuangSparsePacking.scaledEvolution"]
  n525["LowChuangSparsePhysicalBlock.physicalBody"]
  n551["elementarySparseSimulation"]
  n552["instantiate"]
  n553["logical_eq"]
  n554["run_physical"]
  n656["ParallelQSVT.parallel_select_one"]
  n761["Tensor.tensorGate_one"]
  n359 --> n551
  n461 --> n551
  n462 --> n551
  n469 --> n551
  n470 --> n551
  n481 --> n551
  n519 --> n551
  n521 --> n551
  n522 --> n551
  n525 --> n551
  n552 --> n551
  n554 --> n551
  n761 --> n551
  n463 --> n552
  n656 --> n553
  n761 --> n553
  n464 --> n554
  n471 --> n554
  n520 --> n554
  n553 --> n554
```

- [LowChuangElementary.qubitRegisterSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangElementary.lean#L177)
- [LowChuangSparseAssembly.compile_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L76)
- [LowChuangSparseAssembly.compile_fixed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L95)
- [LowChuangSparseAssembly.compile_gates](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L106)
- [LowChuangSparseAssembly.compile_run](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L66)
- [LowChuangSparseAssembly.rename_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L41)
- [LowChuangSparseAssembly.rename_fixed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L48)
- [LowChuangSparseAssembly.rename_run](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseAssembly.lean#L30)
- [LowChuangSparseCartesian.cartesianEncoding](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseCartesian.lean#L73)
- [LowChuangSparsePacking.packed_compression](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePacking.lean#L39)
- [LowChuangSparsePacking.push_lifted](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePacking.lean#L32)
- [LowChuangSparsePacking.push_unit](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePacking.lean#L27)
- [LowChuangSparsePacking.scaledEvolution](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePacking.lean#L56)
- [LowChuangSparsePhysicalBlock.physicalBody](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePhysicalBlock.lean#L99)
- [elementarySparseSimulation](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSimulation.lean#L70)
- [instantiate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSimulation.lean#L36) (private)
- [logical_eq](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSimulation.lean#L47) (private)
- [run_physical](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSimulation.lean#L53) (private)
- [ParallelQSVT.parallel_select_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CopyEvolution/Discriminate/ParallelQSVT.lean#L93)
- [Tensor.tensorGate_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L122)

## FQChemQatlib.Dynamics.LowChuangSparseSwap

```mermaid
flowchart LR
  n488["LowChuangSparseControl.concat"]
  n494["LowChuangSparseControl.empty"]
  n498["LowChuangSparseControl.placed"]
  n532["LowChuangSparsePlacement.place_perm"]
  n555["fredkin_inv"]
  n556["insert_swap"]
  n557["perm_comp"]
  n558["swapGate"]
  n559["swapOne"]
  n560["swapSubset"]
  n569["LowChuangSparseWires.three"]
  n759["Qubit.permMatrix_unitary"]
  n560 --> n558
  n498 --> n559
  n532 --> n559
  n555 --> n559
  n569 --> n559
  n759 --> n559
  n488 --> n560
  n494 --> n560
  n556 --> n560
  n557 --> n560
  n559 --> n560
```

- [LowChuangSparseControl.concat](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L47)
- [LowChuangSparseControl.empty](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L45)
- [LowChuangSparseControl.placed](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseControl.lean#L63)
- [LowChuangSparsePlacement.place_perm](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparsePlacement.lean#L55)
- [fredkin_inv](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSwap.lean#L27) (private)
- [insert_swap](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSwap.lean#L54) (private)
- [perm_comp](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSwap.lean#L64) (private)
- [swapGate](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSwap.lean#L86)
- [swapOne](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSwap.lean#L30)
- [swapSubset](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseSwap.lean#L69)
- [LowChuangSparseWires.three](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L97)
- [Qubit.permMatrix_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L300)

## FQChemQatlib.Dynamics.LowChuangSparseWires

```mermaid
flowchart LR
  n561["built_adj"]
  n562["built_mul"]
  n563["built_weaken"]
  n564["place_adjoint"]
  n565["place_apply"]
  n566["place_mul"]
  n567["place_one"]
  n568["reflection_built"]
  n569["three"]
  n657["Section8GrayUniversalityElem.section8GrayUniversality"]
  n664["LocalReflectionGates.run_reflectionCompile"]
  n760["Tensor.tensorGate_mul"]
  n761["Tensor.tensorGate_one"]
  n565 --> n564
  n760 --> n566
  n761 --> n567
  n562 --> n568
  n566 --> n568
  n567 --> n568
  n563 --> n569
  n568 --> n569
  n657 --> n569
  n664 --> n569
```

- [built_adj](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L72)
- [built_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L66)
- [built_weaken](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L80)
- [place_adjoint](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L47)
- [place_apply](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L34)
- [place_mul](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L40)
- [place_one](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L44)
- [reflection_built](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L83) (private)
- [three](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangSparseWires.lean#L97)
- [Section8GrayUniversalityElem.section8GrayUniversality](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateTables/GrayUniversal/Section8GrayUniversalityElem.lean#L51)
- [LocalReflectionGates.run_reflectionCompile](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/GateVocabulary/LocalReflectionGates.lean#L227)
- [Tensor.tensorGate_mul](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L114)
- [Tensor.tensorGate_one](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L122)

## FQChemQatlib.Dynamics.LowChuangStandardForm

```mermaid
flowchart LR
  n414["LowChuangQueries.cost_substitute"]
  n415["LowChuangQueries.covers_substitute"]
  n418["LowChuangQueries.fixed_substitute"]
  n420["LowChuangQueries.lift_conjugate"]
  n425["LowChuangQueries.run_substitute"]
  n440["LowChuangSimulation.uniformCutoffWord"]
  n570["standardFormProgram"]
  n635["CoordinateFiber.encodingFiber_isIsometry"]
  n762["Tensor.tensorGate_unitary"]
  n414 --> n570
  n415 --> n570
  n418 --> n570
  n420 --> n570
  n425 --> n570
  n440 --> n570
  n635 --> n570
  n762 --> n570
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
  n571["fill_at"]
  n572["fill_out"]
  n573["hWord_cost"]
  n574["mean_diagonal"]
  n695["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n741["FiniteThermalUniformH.thermalUniformHWord_legal"]
  n742["FiniteThermalUniformH.thermalUniformHWord_zero_column"]
  n741 --> n573
  n571 -.-> n574
  n572 -.-> n574
  n695 --> n574
  n742 --> n574
```

- [fill_at](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L23)
- [fill_out](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L28)
- [hWord_cost](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L43)
- [mean_diagonal](../../integrations/qatlib/FQChemQatlib/Dynamics/LowChuangUniformBits.lean#L49)
- [QmaCompletenessDefs.run_finiteCodeCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean#L146)
- [FiniteThermalUniformH.thermalUniformHWord_legal](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalUniformH.lean#L168)
- [FiniteThermalUniformH.thermalUniformHWord_zero_column](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalUniformH.lean#L302)

## FQChemQatlib.Dynamics.SingletonPhaseGradient

```mermaid
flowchart LR
  n575["decrement_increment"]
  n576["digitValue_full"]
  n577["gradientCost"]
  n578["incrementValue"]
  n579["matrixWord"]
  n580["maximal"]
  n581["phase_add"]
  n582["runGradient"]
  n583["runWord"]
  n584["run_append"]
  n585["value_lt"]
  n586["wordCost"]
  n585 --> n578
  n583 --> n579
  n575 --> n583
  n576 --> n583
  n578 --> n583
  n580 --> n583
  n582 --> n583
  n584 --> n583
  n577 --> n586
```

- [decrement_increment](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L36)
- [digitValue_full](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L112)
- [gradientCost](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L160)
- [incrementValue](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L49)
- [matrixWord](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L148)
- [maximal](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L59)
- [phase_add](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L81)
- [runGradient](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L120)
- [runWord](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L132)
- [run_append](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L97)
- [value_lt](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L43)
- [wordCost](../../integrations/qatlib/FQChemQatlib/Dynamics/SingletonPhaseGradient.lean#L164)

## FQChemQatlib.Dynamics.SingularValueTransformation

```mermaid
flowchart LR
  n587["polynomialSingularValueTransformation"]
  n588["singularValueTransformationOfPhases"]
  n724["Corollary8ComplexPhaseExistenceGily.corollary8ComplexPhaseExistence"]
  n725["ConventionBridge.source_corner_even_eq"]
  n726["ConventionBridge.source_corner_odd_eq"]
  n588 --> n587
  n724 --> n587
  n725 --> n588
  n726 --> n588
```

- [polynomialSingularValueTransformation](../../integrations/qatlib/FQChemQatlib/Dynamics/SingularValueTransformation.lean#L47)
- [singularValueTransformationOfPhases](../../integrations/qatlib/FQChemQatlib/Dynamics/SingularValueTransformation.lean#L32)
- [Corollary8ComplexPhaseExistenceGily.corollary8ComplexPhaseExistence](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/PhaseExistence/Corollary8ComplexPhaseExistenceGily.lean#L70)
- [ConventionBridge.source_corner_even_eq](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/QsVtMain/ConventionBridge.lean#L241)
- [ConventionBridge.source_corner_odd_eq](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QsvtCore/QsVtMain/ConventionBridge.lean#L224)

## FQChemQatlib.Dynamics.SparseHamiltonianSimulation

```mermaid
flowchart LR
  n589["segmentedSparseEvolution"]
  n590["sparseSignalEncoding"]
  n699["ComputedSignalConsumers.computed_signal_full_segmented_program_and_cost"]
  n784["SourceSparse.lemma6_sparse_standard_form"]
  n590 --> n589
  n699 --> n589
  n784 --> n590
```

- [segmentedSparseEvolution](../../integrations/qatlib/FQChemQatlib/Dynamics/SparseHamiltonianSimulation.lean#L53)
- [sparseSignalEncoding](../../integrations/qatlib/FQChemQatlib/Dynamics/SparseHamiltonianSimulation.lean#L34)
- [ComputedSignalConsumers.computed_signal_full_segmented_program_and_cost](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/ComputedSignalConsumers.lean#L169)
- [SourceSparse.lemma6_sparse_standard_form](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/Qubitization19/SparseSim/SourceSparse.lean#L97)

## FQChemQatlib.Properties.AmplitudeEstimation

```mermaid
flowchart LR
  n591["amplitudeEstimation"]
  n592["amplitudeEstimationTail"]
  n628["ComparativeStrictBounds.preparedAeWindow_strict"]
  n630["PreparedAmplitudeEstimation.prepared_ae_access_ledger"]
  n631["PreparedAmplitudeEstimation.prepared_ae_bhmt_error_and_endpoints"]
  n630 --> n591
  n631 --> n591
  n628 --> n592
```

- [amplitudeEstimation](../../integrations/qatlib/FQChemQatlib/Properties/AmplitudeEstimation.lean#L32)
- [amplitudeEstimationTail](../../integrations/qatlib/FQChemQatlib/Properties/AmplitudeEstimation.lean#L43)
- [ComparativeStrictBounds.preparedAeWindow_strict](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/AEMeanReadout/LocalAEBackend/ComparativeStrictBounds.lean#L282)
- [PreparedAmplitudeEstimation.prepared_ae_access_ledger](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/AmplitudeCore/PreparedReadout/PreparedAmplitudeEstimation.lean#L194)
- [PreparedAmplitudeEstimation.prepared_ae_bhmt_error_and_endpoints](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/AmplitudeCore/PreparedReadout/PreparedAmplitudeEstimation.lean#L692)

## FQChemQatlib.Properties.ClassicalShadows

```mermaid
flowchart LR
  n593["shadowNormSquaredMaximum"]
  n594["simultaneousPrediction"]
  n730["FiniteEnsembleShadows.finite_ensemble_same_records_many_observables"]
  n731["FiniteEnsembleShadows.finite_ensemble_second_moment_spectral_maximum"]
  n731 --> n593
  n730 --> n594
```

- [shadowNormSquaredMaximum](../../integrations/qatlib/FQChemQatlib/Properties/ClassicalShadows.lean#L32)
- [simultaneousPrediction](../../integrations/qatlib/FQChemQatlib/Properties/ClassicalShadows.lean#L46)
- [FiniteEnsembleShadows.finite_ensemble_same_records_many_observables](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/ShadowModels/ShadowChannel/FiniteEnsembleShadows.lean#L509)
- [FiniteEnsembleShadows.finite_ensemble_second_moment_spectral_maximum](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/ShadowModels/ShadowChannel/FiniteEnsembleShadows.lean#L485)

## FQChemQatlib.Properties.LinearSystems

```mermaid
flowchart LR
  n595["signedInverseState"]
  n678["OffGridSignedHHL.uniform_offgrid_signed_hhl_born_and_solution"]
  n679["UniformHHLFilter.uniform_hhl_actual_legal_forward_inverse_ledger"]
  n774["PseudoinverseReadout.pseudoinverse_eq_inv_of_ne_zero"]
  n678 --> n595
  n679 --> n595
  n774 --> n595
```

- [signedInverseState](../../integrations/qatlib/FQChemQatlib/Properties/LinearSystems.lean#L31)
- [OffGridSignedHHL.uniform_offgrid_signed_hhl_born_and_solution](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/UniformHHL/OffGridSignedHHL.lean#L654)
- [UniformHHLFilter.uniform_hhl_actual_legal_forward_inverse_ledger](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/UniformHHL/UniformHHLFilter.lean#L244)
- [PseudoinverseReadout.pseudoinverse_eq_inv_of_ne_zero](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/QLinearSolver18/MainResults/Readout/PseudoinverseReadout.lean#L72)

## FQChemQatlib.Properties.SignedSineAmplification

```mermaid
flowchart LR
  n596["amplifiedSignedSolution"]
  n597["blockSlice"]
  n598["solverMass"]
  n599["solverOutput"]
  n600["solverUnitary"]
  n601["tensorSlice"]
  n625["SignedSineUncompute.clockUnitary"]
  n626["SignedSineUncompute.forwardKernel"]
  n627["SignedSineUncompute.signedSolution"]
  n668["RationalHHLNoiseConsumers.amplified_postMeasure_phase"]
  n669["RationalHHLNoiseConsumers.mixed_window_avg"]
  n675["QlsHhl.canonicalSignedProgram_rotation"]
  n682["PreparedAmplitudeAmplification.prepared_aa_separate_access_word"]
  n727["LocalCapability.blockDiag_unitary"]
  n755["Qubit.normalized_applyGate"]
  n756["Qubit.normalized_ket"]
  n762["Tensor.tensorGate_unitary"]
  n598 --> n596
  n600 --> n596
  n625 -.-> n596
  n627 --> n596
  n668 --> n596
  n669 --> n596
  n682 --> n596
  n727 -.-> n596
  n755 --> n596
  n756 --> n596
  n599 --> n598
  n625 -.-> n598
  n727 -.-> n598
  n597 --> n599
  n601 --> n599
  n625 -.-> n599
  n626 --> n599
  n727 -.-> n599
  n625 --> n600
  n675 --> n600
  n727 --> n600
  n762 --> n600
```

- [amplifiedSignedSolution](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L119)
- [blockSlice](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L60)
- [solverMass](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L107)
- [solverOutput](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L73)
- [solverUnitary](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L50)
- [tensorSlice](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L66)
- [SignedSineUncompute.clockUnitary](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L26)
- [SignedSineUncompute.forwardKernel](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L42)
- [SignedSineUncompute.signedSolution](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L84)
- [RationalHHLNoiseConsumers.amplified_postMeasure_phase](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/Postselection/RationalHHLNoiseConsumers.lean#L1653)
- [RationalHHLNoiseConsumers.mixed_window_avg](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/Postselection/RationalHHLNoiseConsumers.lean#L758)
- [QlsHhl.canonicalSignedProgram_rotation](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvProgram/QlsHhl.lean#L2911)
- [PreparedAmplitudeAmplification.prepared_aa_separate_access_word](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LchsSimulation/StaticLchs/PreparedAmplitudeAmplification.lean#L749)
- [LocalCapability.blockDiag_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QueryComplexity/DegreeMethod/LocalCapability.lean#L83)
- [Qubit.normalized_applyGate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L266)
- [Qubit.normalized_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L152)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)

## FQChemQatlib.Properties.SignedSineClock

```mermaid
flowchart LR
  n602["decodedDistance"]
  n603["normalizedBranch"]
  n604["regularGain"]
  n605["relativeGain"]
  n606["selectedGain"]
  n607["signedRelativeClock"]
  n608["superpositionError"]
  n642["Postselection.normalize_error_of_gap"]
  n670["SinEnvelopeHHL.sin_envelope_kernel_normalized"]
  n671["SinEnvelopeHHL.sin_envelope_kernel_second_moment"]
  n674["QlsHhl.canonicalSignedFilter_consistent"]
  n675["QlsHhl.canonicalSignedProgram_rotation"]
  n608 --> n603
  n642 --> n603
  n670 --> n603
  n604 --> n605
  n674 --> n605
  n675 --> n606
  n602 --> n607
  n605 --> n607
  n671 --> n607
  n606 --> n608
  n607 --> n608
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

## FQChemQatlib.Properties.SignedSineHermitian

```mermaid
flowchart LR
  n601["SignedSineAmplification.tensorSlice"]
  n603["SignedSineClock.normalizedBranch"]
  n609["cleanInverse"]
  n610["clockAction"]
  n611["inverseInBasis"]
  n612["mixClock"]
  n613["mixPowers"]
  n614["oracleConjugation"]
  n615["physicalForward"]
  n616["physicalInverse"]
  n617["physicalSolution"]
  n618["SignedSineQueries.clockUndo"]
  n619["SignedSineQueries.forwardQueries"]
  n624["SignedSineUncompute.cleanClock"]
  n625["SignedSineUncompute.clockUnitary"]
  n673["NearGridHHLOutput.continuous_hhl_oracle_unitary"]
  n677["SinEnvelopeHHLConsumers.sin_envelope_phase_circuit_unitary"]
  n688["ControlledQueryCircuit.controlOracle_unitary"]
  n690["CountedHHLProgram.run_eq_evaluate"]
  n691["CountedHHLProgram.wellFormedAdjointCircuit_stepToAdjoint_reverse"]
  n698["CircuitWellFormed.evaluate_unitary"]
  n727["LocalCapability.blockDiag_unitary"]
  n734["OffGridPhaseReadout.phaseFlagEmbed_phaseGate"]
  n735["OffGridPhaseReadout.phaseThresholdLoop_action"]
  n755["Qubit.normalized_applyGate"]
  n762["Tensor.tensorGate_unitary"]
  n764["Circuit.run_append"]
  n601 --> n609
  n611 --> n609
  n624 --> n609
  n625 -.-> n609
  n727 -.-> n609
  n690 --> n610
  n734 --> n610
  n735 --> n610
  n764 --> n610
  n601 --> n612
  n614 --> n613
  n601 --> n615
  n610 --> n615
  n612 --> n615
  n613 --> n615
  n619 --> n615
  n615 --> n616
  n618 --> n616
  n673 --> n616
  n677 --> n616
  n688 --> n616
  n691 --> n616
  n698 --> n616
  n762 --> n616
  n603 --> n617
  n609 --> n617
  n625 -.-> n617
  n727 -.-> n617
  n755 --> n617
  n762 -.-> n617
```

- [SignedSineAmplification.tensorSlice](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L66)
- [SignedSineClock.normalizedBranch](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L191)
- [cleanInverse](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L173)
- [clockAction](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L82) (private)
- [inverseInBasis](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L136)
- [mixClock](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L55) (private)
- [mixPowers](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L75) (private)
- [oracleConjugation](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L40)
- [physicalForward](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L95)
- [physicalInverse](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L114)
- [physicalSolution](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineHermitian.lean#L206)
- [SignedSineQueries.clockUndo](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineQueries.lean#L80)
- [SignedSineQueries.forwardQueries](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineQueries.lean#L62)
- [SignedSineUncompute.cleanClock](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L62)
- [SignedSineUncompute.clockUnitary](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L26)
- [NearGridHHLOutput.continuous_hhl_oracle_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvProgram/NearGridHHLOutput.lean#L234)
- [SinEnvelopeHHLConsumers.sin_envelope_phase_circuit_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvProgram/SinEnvelopeHHLConsumers.lean#L270)
- [ControlledQueryCircuit.controlOracle_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/ControlledQueryCircuit.lean#L83)
- [CountedHHLProgram.run_eq_evaluate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/NativeNumerics/LayeredMean/CountedHHLProgram.lean#L134)
- [CountedHHLProgram.wellFormedAdjointCircuit_stepToAdjoint_reverse](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/NativeNumerics/LayeredMean/CountedHHLProgram.lean#L120)
- [CircuitWellFormed.evaluate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/CircuitWellFormed.lean#L137)
- [LocalCapability.blockDiag_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QueryComplexity/DegreeMethod/LocalCapability.lean#L83)
- [OffGridPhaseReadout.phaseFlagEmbed_phaseGate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/SpectralReadout/OffGridPhaseReadout.lean#L448)
- [OffGridPhaseReadout.phaseThresholdLoop_action](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/SpectralReadout/OffGridPhaseReadout.lean#L429)
- [Qubit.normalized_applyGate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L266)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)
- [Circuit.run_append](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean#L249)

## FQChemQatlib.Properties.SignedSineQueries

```mermaid
flowchart LR
  n596["SignedSineAmplification.amplifiedSignedSolution"]
  n597["SignedSineAmplification.blockSlice"]
  n601["SignedSineAmplification.tensorSlice"]
  n603["SignedSineClock.normalizedBranch"]
  n618["clockUndo"]
  n619["forwardQueries"]
  n620["inverseQueries"]
  n621["powers"]
  n622["signedOracleResources"]
  n623["unitaryOracle"]
  n625["SignedSineUncompute.clockUnitary"]
  n645["AdjointWord.adjointQueryCount_adjointCircuit"]
  n676["SinEnvelopeHHLConsumers.sin_envelope_forward_word_counts"]
  n677["SinEnvelopeHHLConsumers.sin_envelope_phase_circuit_unitary"]
  n688["ControlledQueryCircuit.controlOracle_unitary"]
  n690["CountedHHLProgram.run_eq_evaluate"]
  n691["CountedHHLProgram.wellFormedAdjointCircuit_stepToAdjoint_reverse"]
  n698["CircuitWellFormed.evaluate_unitary"]
  n727["LocalCapability.blockDiag_unitary"]
  n732["PhaseEstimation.norm_exp_two_pi_I"]
  n734["OffGridPhaseReadout.phaseFlagEmbed_phaseGate"]
  n735["OffGridPhaseReadout.phaseThresholdLoop_action"]
  n755["Qubit.normalized_applyGate"]
  n756["Qubit.normalized_ket"]
  n762["Tensor.tensorGate_unitary"]
  n764["Circuit.run_append"]
  n597 --> n618
  n625 --> n618
  n597 --> n619
  n601 --> n619
  n621 --> n619
  n690 --> n619
  n734 --> n619
  n735 --> n619
  n764 --> n619
  n618 --> n620
  n619 --> n620
  n623 --> n620
  n677 --> n620
  n688 --> n620
  n691 --> n620
  n698 --> n620
  n762 --> n620
  n596 --> n622
  n603 --> n622
  n625 -.-> n622
  n645 --> n622
  n676 --> n622
  n727 -.-> n622
  n755 --> n622
  n756 --> n622
  n732 --> n623
```

- [SignedSineAmplification.amplifiedSignedSolution](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L119)
- [SignedSineAmplification.blockSlice](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L60)
- [SignedSineAmplification.tensorSlice](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineAmplification.lean#L66)
- [SignedSineClock.normalizedBranch](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineClock.lean#L191)
- [clockUndo](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineQueries.lean#L80)
- [forwardQueries](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineQueries.lean#L62)
- [inverseQueries](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineQueries.lean#L92)
- [powers](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineQueries.lean#L52) (private)
- [signedOracleResources](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineQueries.lean#L113)
- [unitaryOracle](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineQueries.lean#L44) (private)
- [SignedSineUncompute.clockUnitary](../../integrations/qatlib/FQChemQatlib/Properties/SignedSineUncompute.lean#L26)
- [AdjointWord.adjointQueryCount_adjointCircuit](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CoherentSim/CoherentOAA/AdjointWord.lean#L70)
- [SinEnvelopeHHLConsumers.sin_envelope_forward_word_counts](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvProgram/SinEnvelopeHHLConsumers.lean#L283)
- [SinEnvelopeHHLConsumers.sin_envelope_phase_circuit_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/HhlAlgorithms/SinEnvProgram/SinEnvelopeHHLConsumers.lean#L270)
- [ControlledQueryCircuit.controlOracle_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/ControlledQueryCircuit.lean#L83)
- [CountedHHLProgram.run_eq_evaluate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/NativeNumerics/LayeredMean/CountedHHLProgram.lean#L134)
- [CountedHHLProgram.wellFormedAdjointCircuit_stepToAdjoint_reverse](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/NativeNumerics/LayeredMean/CountedHHLProgram.lean#L120)
- [CircuitWellFormed.evaluate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QspSimulation/Achievability/CircuitWellFormed.lean#L137)
- [LocalCapability.blockDiag_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QueryComplexity/DegreeMethod/LocalCapability.lean#L83)
- [PhaseEstimation.norm_exp_two_pi_I](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/SpectralFilter/PhaseReadout/PhaseEstimation.lean#L432)
- [OffGridPhaseReadout.phaseFlagEmbed_phaseGate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/SpectralReadout/OffGridPhaseReadout.lean#L448)
- [OffGridPhaseReadout.phaseThresholdLoop_action](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/SpectralReadout/OffGridPhaseReadout.lean#L429)
- [Qubit.normalized_applyGate](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L266)
- [Qubit.normalized_ket](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Qubit.lean#L152)
- [Tensor.tensorGate_unitary](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/PureStateMath/Tensor.lean#L133)
- [Circuit.run_append](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Foundations/QueryWordCore/Circuit.lean#L249)

## FQChemQatlib.Properties.SignedSineUncompute

```mermaid
flowchart LR
  n603["SignedSineClock.normalizedBranch"]
  n624["cleanClock"]
  n625["clockUnitary"]
  n626["forwardKernel"]
  n627["signedSolution"]
  n672["SinEnvelopeHHL.sin_envelope_state_normalized_and_prep"]
  n727["LocalCapability.blockDiag_unitary"]
  n732["PhaseEstimation.norm_exp_two_pi_I"]
  n733["PhaseEstimation.qftMatrix_unitary"]
  n625 --> n624
  n626 --> n624
  n727 -.-> n624
  n672 --> n625
  n732 --> n625
  n733 --> n625
  n672 --> n626
  n603 --> n627
  n624 --> n627
  n625 -.-> n627
  n727 -.-> n627
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
