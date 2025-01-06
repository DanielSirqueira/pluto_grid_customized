import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid_customized/pluto_grid_customized.dart';

import 'ui.dart';

class PlutoRightFrozenColumnsFooter extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoRightFrozenColumnsFooter(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoRightFrozenColumnsFooterState createState() =>
      PlutoRightFrozenColumnsFooterState();
}

class PlutoRightFrozenColumnsFooterState
    extends PlutoStateWithChange<PlutoRightFrozenColumnsFooter> {
  List<PlutoColumn> _columns = [];

  int _itemCount = 0;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _columns = update<List<PlutoColumn>>(
      _columns,
      stateManager.rightFrozenColumns,
      compare: listEquals,
    );

    _itemCount = update<int>(_itemCount, _columns.length);
  }

  Widget _makeColumn(PlutoColumn e) {
    return LayoutId(
      id: e.field,
      child: PlutoBaseColumnFooter(
        stateManager: stateManager,
        column: e,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.configuration.style;

    bool showRightFrozen =
        stateManager.showFrozenColumn && stateManager.hasRightFrozenColumns;

    final bool showColumnFooter = stateManager.showColumnFooter;

    final footerSpacing = stateManager.style.footerSpacing;

    var decoration = style.rightFrozenDecoration ??
        style.footerDecoration ??
        BoxDecoration(
          color: style.gridBackgroundColor,
          borderRadius:
              style.gridBorderRadius.resolve(TextDirection.ltr).copyWith(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: showRightFrozen ? Radius.zero : null,
                  ),
          border: Border.all(
            color: style.gridBorderColor,
            width: PlutoGridSettings.gridBorderWidth,
          ),
        );

    BorderRadiusGeometry borderRadius = BorderRadius.zero;
    List<BoxShadow>? boxShadow;
    Border borderGradient = Border(
      bottom: BorderSide(
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
      if (decoration.border is Border &&
          boxShadow != null &&
          boxShadow.isNotEmpty) {
        final decorationFooter =
            (stateManager.style.footerDecoration is BoxDecoration?)
                ? stateManager.style.footerDecoration as BoxDecoration?
                : null;

        final border = decorationFooter?.border is Border
            ? decorationFooter?.border as Border
            : null;
        if (decorationFooter != null) {
          borderGradient = Border(
            bottom: BorderSide(
              color: border?.bottom.color ?? Colors.transparent,
              width: border?.bottom.width ?? 0,
            ),
          );
        }
      }

      decoration = decoration.copyWith(
        boxShadow: [],
        borderRadius:
            decoration.borderRadius?.resolve(TextDirection.ltr).copyWith(
                  topLeft: Radius.zero,
                  topRight: showColumnFooter &&
                          (footerSpacing == null || footerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  bottomLeft: showRightFrozen ? Radius.zero : null,
                ),
      );

      borderRadius = decoration.borderRadius ?? BorderRadius.zero;
    }

    return Stack(
      children: [
        if (boxShadow != null && boxShadow.isNotEmpty)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(
              width: boxShadow.first.blurRadius,
              decoration: BoxDecoration(
                border: borderGradient,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    stateManager.style.footerDecoration is BoxDecoration?
                        ? (stateManager.style.footerDecoration
                                    as BoxDecoration?)
                                ?.color ??
                            Colors.transparent
                        : style.gridBorderColor,
                    boxShadow.first.color,
                  ],
                ),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (boxShadow != null && boxShadow.isNotEmpty)
              SizedBox(width: boxShadow.first.blurRadius - 2),
            Flexible(
              child: Container(
                height: stateManager.configuration.style.footerHeight,
                decoration: decoration,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: CustomMultiChildLayout(
                    delegate: ColumnFooterLayoutDelegate(
                      stateManager: stateManager,
                      columns: _columns,
                      textDirection: stateManager.textDirection,
                    ),
                    children: _columns.map(_makeColumn).toList(growable: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
