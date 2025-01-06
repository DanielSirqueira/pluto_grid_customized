import 'package:flutter/material.dart';
import 'package:pluto_grid_customized/pluto_grid_customized.dart';

class PlutoColumnCustomizedBool extends PlutoColumnTypeCustomized<bool> {
  PlutoColumnCustomizedBool({
    super.defaultValue,
  });

  bool? _value;

  @override
  void initState() {
    _value = cell?.value ?? defaultValue ?? false;
    focusCellNode?.requestFocus();
  }

  @override
  Widget build(BuildContext context, PlutoGridStateManager stateManager) {
    return Checkbox(
      value: _value,
      focusNode: focusCellNode,
      onChanged: (value) {
        setState(() {
          _value = value ?? false;
          setNewValue(_value);
        });
      },
    );
  }

  @override
  String formattedValue(bool? value) {
    return value == true ? 'No' : 'Yes';
  }
}
