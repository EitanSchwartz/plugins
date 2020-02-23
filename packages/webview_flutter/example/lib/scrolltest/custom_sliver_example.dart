import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomSliverExample {}

void main() {
  runApp(MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("CustomSliverExample"),
          ),
          body: CustomScrollView(
            scrollDirection: Axis.horizontal,
            slivers: <Widget>[
              CustomSliverToBoxAdapter(
                child: Tape(),
              )
            ],
          ))));
}

const _width = (_maxValue - _minValue) * spacing;
const spacing = 20.0;
const _minValue = 0;
const _maxValue = 100;

class Tape extends CustomPaint {
  Tape()
      : super(
          size: Size(_width, 60.0),
          painter: _TapePainter(),
        );
}

class _TapePainter extends CustomPainter {
  Paint _tickPaint = Paint();

  _TapePainter() {
    _tickPaint.color = Colors.black;
    _tickPaint.strokeWidth = 2.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;

    // Extend drawing window to compensate for element sizes - avoids lines at either end "popping" into existence
    var extend = _tickPaint.strokeWidth / 2.0;

    // Calculate from which Tick we should start drawing
    var tick = ((_visibleRect.left - extend) / spacing).ceil();

    var startOffset = tick * spacing;
    var o1 = Offset(startOffset, 0.0);
    var o2 = Offset(startOffset, rect.height);

    while (o1.dx < _visibleRect.right + extend) {
      canvas.drawLine(o1, o2, _tickPaint);
      o1 = o1.translate(spacing, 0.0);
      o2 = o2.translate(spacing, 0.0);
    }
  }

  @override
  bool shouldRepaint(_TapePainter oldDelegate) {
    return false;
  }
}

class CustomSliverToBoxAdapter extends SingleChildRenderObjectWidget {
  const CustomSliverToBoxAdapter({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  CustomRenderSliverToBoxAdapter createRenderObject(BuildContext context) =>
      CustomRenderSliverToBoxAdapter();
}

class CustomRenderSliverToBoxAdapter extends RenderSliverSingleBoxAdapter {
  CustomRenderSliverToBoxAdapter({
    RenderBox child,
  }) : super(child: child);

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

//    childExtent - Affects visible dimensions of this view (value used in call to calculatePaintOffset())
//    constraints.scrollOffset - Get scroll position




    print('ahmed | CustomRenderSliverToBoxAdapter | performLayout() | constraints.scrollOffset = ${constraints.scrollOffset}');
    //TODO: THE PLAN IS TO TRY AND STRIP THIS ENTIRE FILE TO A WEBVIEW.scrollTo(constraints.scrollOffset.x, constraints.scrollOffset.y);
    //TODO: constraints.scrollOffset should, theoretically have the right value if the paintedChildSize will be calculated according to WebView content size (lets start from a dummy big number, if works lets see if we can get from mobileLoader)





    //Set visible dimensions (the size that's actually painted)
    assert(childExtent != null);
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child, constraints, geometry);

    // Expose geometry
    _visibleRect = Rect.fromLTWH(
        constraints.scrollOffset, 0.0, geometry.paintExtent, child.size.height);
  }
}

Rect _visibleRect = Rect.zero;
