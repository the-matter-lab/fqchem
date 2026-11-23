# Kitaev integration theorem graph

217 source theorems and lemmas · 8 shared library prerequisites · 27 upstream theorem nodes · 423 dependency edges.

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
  n225["FiniteGateDescription.finite_gate_description_rejection_unitarity_and_counts"]
  n235["EventProbability.measureProb_le_one"]
  n239["Qubit.measureProb_nonneg"]
  n240["Qubit.normalized_ket"]
  n241["Circuit.normalized_run"]
  n242["Circuit.run_append"]
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
  n225 --> n60
  n240 --> n60
  n241 --> n60
  n242 --> n60
  n50 -.-> n61
  n207 --> n61
  n217 --> n61
  n50 -.-> n62
  n218 --> n62
  n225 --> n63
  n235 --> n63
  n239 --> n63
  n240 --> n63
  n241 --> n63
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
  n240["Qubit.normalized_ket"]
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
  n240 --> n64
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
  n234["QmaCompletenessNumerics.floor_atom"]
  n141 --> n137
  n141 --> n138
  n141 --> n140
  n234 --> n140
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
  n249["QmaCompletenessPadding.paid64_length"]
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
  n249 --> n163
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
  n230["QmaCompletenessRefined.clause3Aux_encNat_selfDelimiting"]
  n231["QmaCompletenessRefined.clause3Aux_toBits_injective"]
  n232["QmaCompletenessNativeOutput.outputTerms_length"]
  n236["EventProbability.measureProb_smul"]
  n238["Qubit.inner_apply"]
  n240["Qubit.normalized_ket"]
  n243["QmaCompleteness.qma_history_locality_description_and_energy_bounds"]
  n244["QmaCompletenessNormalized.denominator_le_poly"]
  n245["QmaCompletenessNormalized.denominator_pos"]
  n246["QmaCompletenessNormalized.gap_inverse_poly"]
  n247["QmaCompletenessNormalized.gap_positive"]
  n248["QmaCompletenessNormalized.padded_normalized_contract"]
  n249["QmaCompletenessPadding.paid64_length"]
  n250["QmaCompletenessSize.encNat_length_le_self"]
  n251["QmaCompletenessSize.termEntries_length"]
  n244 --> n170
  n249 --> n170
  n245 --> n171
  n238 --> n172
  n240 --> n173
  n175 --> n174
  n178 --> n174
  n172 --> n175
  n173 --> n175
  n188 --> n175
  n184 --> n176
  n172 --> n177
  n175 --> n177
  n178 --> n177
  n246 --> n178
  n247 --> n178
  n249 --> n178
  n245 --> n179
  n170 --> n180
  n181 --> n180
  n250 --> n180
  n243 --> n181
  n249 --> n181
  n181 --> n183
  n251 --> n183
  n230 --> n184
  n231 --> n184
  n185 -.-> n186
  n232 --> n186
  n171 --> n187
  n175 --> n187
  n179 --> n187
  n181 --> n187
  n248 --> n188
  n249 --> n188
  n182 --> n189
  n236 --> n189
  n175 --> n190
  n189 --> n190
  n191 --> n190
  n240 --> n190
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
  n229["QmaCompletenessDefs.run_finiteCodeCircuit"]
  n233["FiniteThermalToffoli.thermalToffoliWord_exact"]
  n242["Circuit.run_append"]
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
  n233 --> n204
  n196 --> n205
  n206 --> n205
  n229 --> n205
  n192 --> n206
  n204 --> n206
  n242 --> n206
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
  n226["LocalReflectionGates.applyGate_wireGate_ket"]
  n240["Qubit.normalized_ket"]
  n242["Circuit.run_append"]
  n0 -.-> n209
  n1 -.-> n209
  n158 --> n209
  n181 -.-> n209
  n189 --> n209
  n191 --> n209
  n210 --> n209
  n212 -.-> n209
  n213 --> n209
  n240 --> n209
  n211 --> n210
  n212 -.-> n210
  n216 --> n210
  n212 -.-> n211
  n214 --> n211
  n242 --> n211
  n215 --> n214
  n226 --> n215
  n242 --> n215
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
  n227["LocalReflectionGates.cnotUpdate_involutive"]
  n228["LocalReflectionGates.wireGate_apply"]
  n237["Qubit.applyGate_permMatrix"]
  n222 --> n217
  n221 --> n219
  n224 --> n220
  n220 --> n221
  n223 --> n221
  n227 --> n223
  n237 --> n223
  n228 --> n224
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
