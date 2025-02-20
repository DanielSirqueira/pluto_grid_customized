import 'package:flutter/material.dart';
import 'package:pluto_grid_customized/pluto_grid_customized.dart';

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

    var decoration = style.rightFrozenDecoration ??
        style.contentDecoration ??
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
    List<BoxShadow>? boxShadow;
    Border borderGradient = Border(
      top: (headerSpacing == null || headerSpacing <= 0)
          ? BorderSide.none
          : BorderSide(
              color: style.gridBorderColor,
              width: PlutoGridSettings.gridBorderWidth,
            ),
      bottom: (footerSpacing == null || footerSpacing <= 0)
          ? BorderSide.none
          : BorderSide(
              color: style.gridBorderColor,
              width: PlutoGridSettings.gridBorderWidth,
            ),
    );

    if (stateManager.style.rightFrozenDecoration != null &&
        stateManager.style.rightFrozenDecoration is BoxDecoration) {
      boxShadow =
          (stateManager.style.rightFrozenDecoration as BoxDecoration).boxShadow;
    }

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

        if (boxShadow != null && boxShadow.isNotEmpty) {
          final decorationContent =
              (stateManager.style.contentDecoration is BoxDecoration?)
                  ? stateManager.style.contentDecoration as BoxDecoration?
                  : null;

          final border = decorationContent?.border is Border
              ? decorationContent?.border as Border
              : null;

          if (decorationContent != null) {
            borderGradient = Border(
              top: (headerSpacing == null || headerSpacing <= 0)
                  ? BorderSide.none
                  : BorderSide(
                      color: border?.top.color ?? Colors.transparent,
                      width: border?.top.width ?? 0,
                    ),
              bottom: (footerSpacing == null || footerSpacing <= 0)
                  ? BorderSide.none
                  : BorderSide(
                      color: border?.bottom.color ?? Colors.transparent,
                      width: border?.bottom.width ?? 0,
                    ),
            );
          }
        }
      }

      decoration = decoration.copyWith(
        boxShadow: [],
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
          child: Stack(
            children: [
              if (boxShadow != null && boxShadow.isNotEmpty)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: boxShadow.first.blurRadius,
                    decoration: BoxDecoration(
                      color:
                          stateManager.style.contentDecoration is BoxDecoration?
                              ? (stateManager.style.contentDecoration
                                      as BoxDecoration?)
                                  ?.color
                              : style.gridBorderColor,
                      border: borderGradient,
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          boxShadow.first.color,
                        ],
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  if (boxShadow != null && boxShadow.isNotEmpty)
                    SizedBox(width: boxShadow.first.blurRadius - 2),
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
            ],
          ),
        ),
        if (footerSpacing != null && footerSpacing > 0)
          SizedBox(height: footerSpacing),
      ],
    );
  }
}
