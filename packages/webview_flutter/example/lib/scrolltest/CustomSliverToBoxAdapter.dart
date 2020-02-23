import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomSliverToBoxAdapter extends SingleChildRenderObjectWidget {
  const CustomSliverToBoxAdapter({
    Key key,
    Widget child,
  })
      : super(key: key, child: child);

  @override
  CustomRenderSliverToBoxAdapter createRenderObject(BuildContext context) =>
      new CustomRenderSliverToBoxAdapter();
}

class CustomRenderSliverToBoxAdapter extends RenderSliverSingleBoxAdapter {
  CustomRenderSliverToBoxAdapter({
    RenderBox child,
  })
      : super(child: child);

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child.size.width;
        break;
      case Axis.vertical:
        childExtent = child.size.height;
        break;
    }
    assert(childExtent != null);
    final double paintedChildSize =
    calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = new SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child, constraints, geometry);

    // Expose geometry
    _visibleRect = new Rect.fromLTWH(
        constraints.scrollOffset, 0.0, geometry.paintExtent, child.size.height);
  }
}

Rect _visibleRect = Rect.zero;