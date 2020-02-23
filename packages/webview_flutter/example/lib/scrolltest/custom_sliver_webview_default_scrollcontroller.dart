import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:webview_flutter/webview_flutter.dart';

class CustomSliverWebView {}

void main() {

  /// WEBVIEW_CONTROLLER START ///
  WebViewController _webViewController;

  /// WEBVIEW_CONTROLLER END ///

  /// WEBVIEW START ///
  WebView _webView = WebView(
    initialUrl: "https://news.google.com",
    debuggingEnabled: true,
    onWebViewCreated: (WebViewController webViewController) {
      _webViewController = webViewController;
    },
  );

  /// WEBVIEW END ///

  /// SCROLL CONTROLLER START ///
  ScrollController scrollController;

  //1st way of listening to scroll position
  scrollController = ScrollController()
    ..addListener(() {
      print("Offset (from scrollable top) = ${scrollController.offset}");
      _webViewController.scrollTo(0, scrollController.offset.toInt());

      print("position = ${scrollController.position}");
      print("Scroll range (native) = ${scrollController.position.maxScrollExtent}");
      print("Screen shown size (in scroll axis) = ${scrollController.position.viewportDimension}");
      //TODO: maybe create a new ScrollPosition where the scroll delta is added to the minScrollExtent & maxScrollExtent?
      //TODO: maybe find a way to change scroll physics to not stop scrolling when reaching bottom overscroll
//      scrollController.attach(position)
    });


  /// SCROLL CONTROLLER END ///

  runApp(MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("CustomSliverExample"),
          ),
          body: CustomScrollView(
            physics: BouncingScrollPhysics(),
            controller: scrollController,
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              SliverList(
                  delegate: SliverChildListDelegate(_buildList(20)) //dummy text list to simulate publisher content
              ),
              SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth:400, maxHeight: 800), //TODO: remove hardcoded webview dimensions
                  child: _webView,
                ),
              )
            ],
          ))));
}

List _buildList(int count) {
  List<Widget> listItems = List();

  for (int i = 0; i < count; i++) {
    listItems.add(Padding(
        padding: EdgeInsets.all(2),
        child: Container(
          height: 50.0,
          color: Colors.blue.withGreen(i * 10),
          child: Center(
              child: Text(
            'Card $i',
            style: TextStyle(color: Colors.white),
          )),
        )));
  }

  return listItems;
}
const _width = (_maxValue - _minValue) * spacing;
const spacing = 20.0;
const _minValue = 0;
const _maxValue = 100;

//PUT FRAMELAYOUT: TAPE on top of W.V., Then move W.V. according to tape scrolling

class Tape extends CustomPaint {
  Tape()
      : super(
          size: Size(_width, 20), //TODO: Full screen
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

  static final double WEBVIEW_HEIGHT = 800;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
//    switch (constraints.axis) {
//      case Axis.horizontal:
//        childExtent = child.size.width;
//        break;
//      case Axis.vertical:
//        childExtent = child.size.height;
//        break;
//    }
childExtent = WEBVIEW_HEIGHT;
//    GUIDE:
//    childExtent - Affects visible dimensions of this view (value used in call to calculatePaintOffset())
//    constraints.scrollOffset - Get scroll position



    //2nd way of listening to scroll position
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
