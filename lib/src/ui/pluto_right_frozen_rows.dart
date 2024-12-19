import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoRightFrozenRows extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoRightFrozenRows(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoRightFrozenRowsState createState() => PlutoRightFrozenRowsState();
}

class PlutoRightFrozenRowsState
    extends PlutoStateWithChange<PlutoRightFrozenRows> {
  List<PlutoColumn> _columns = [];

  List<PlutoRow> _rows = [];

  late final ScrollController _scroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _scroll = stateManager.scroll.vertical!.addAndGet();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _scroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    forceUpdate();

    _columns = stateManager.rightFrozenColumns;

    _rows = stateManager.refRows;
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.configuration.style;

    final bool showColumnFooter = stateManager.showColumnFooter;

    final headerSpacing = stateManager.style.headerSpacing;
    final footerSpacing = stateManager.style.footerSpacing;

    var decoration = style.contentDecoration ??
        BoxDecoration(
          color: style.gridBackgroundColor,
          borderRadius: !showColumnFooter
              ? style.gridBorderRadius.resolve(TextDirection.ltr).copyWith(
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  )
              : null,
          border: Border.all(
            color: style.gridBorderColor,
            width: PlutoGridSettings.gridBorderWidth,
          ),
        );

    BorderRadiusGeometry borderRadius = BorderRadius.zero;

    if (decoration is BoxDecoration) {
      if (decoration.border is Border) {
        final border = decoration.border as Border;

        decoration = decoration.copyWith(
          border: Border(
            top: (headerSpacing == null || headerSpacing <= 0)
                ? BorderSide.none
                : border.top,
            bottom: showColumnFooter &&
                    (footerSpacing == null || footerSpacing <= 0)
                ? BorderSide.none
                : border.bottom,
            left: border.left,
            right: border.right,
          ),
        );
      }

      decoration = decoration.copyWith(
        borderRadius:
            decoration.borderRadius?.resolve(TextDirection.ltr).copyWith(
                  topLeft: Radius.zero,
                  topRight: headerSpacing == null || headerSpacing <= 0
                      ? Radius.zero
                      : null,
                  bottomLeft: Radius.zero,
                  bottomRight: showColumnFooter &&
                          (footerSpacing == null || footerSpacing <= 0)
                      ? Radius.zero
                      : null,
                ),
      );

      borderRadius = decoration.borderRadius ?? BorderRadius.zero;
    }

    return Column(
      children: [
        if (headerSpacing != null && headerSpacing > 0)
          SizedBox(height: headerSpacing),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Container(
                  decoration: decoration,
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: ListView.builder(
                      controller: _scroll,
                      scrollDirection: Axis.vertical,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _rows.length,
                      itemExtent: stateManager.rowTotalHeight,
                      itemBuilder: (ctx, i) {
                        return PlutoBaseRow(
                          key: ValueKey('right_frozen_row_${_rows[i].key}'),
                          rowIdx: i,
                          row: _rows[i],
                          columns: _columns,
                          stateManager: stateManager,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (footerSpacing != null && footerSpacing > 0)
          SizedBox(height: footerSpacing),
      ],
    );
  }
}
