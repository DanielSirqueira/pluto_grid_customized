import 'package:pluto_grid_customized/pluto_grid_customized.dart';

/// Event issued when the sort state of a column is changed.
class PlutoGridChangeColumnSortEvent extends PlutoGridEvent {
  PlutoGridChangeColumnSortEvent({
    required this.column,
    required this.oldSort,
  });

  final PlutoColumn column;

  final PlutoColumnSort oldSort;

  @override
  void handler(PlutoGridStateManager stateManager) {}
}
