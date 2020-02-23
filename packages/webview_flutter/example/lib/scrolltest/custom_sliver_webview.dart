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
  scrollController = UnlimitedScrollController()
    ..addListener(() {
      print("Offset (from scrollable top) = ${scrollController.offset}");
      _webViewController.scrollTo(0, scrollController.offset.toInt());

      print("position = ${scrollController.position}");
      print("Scroll range (native) = ${scrollController.position.maxScrollExtent}");
      print("Screen shown size (in scroll axis) = ${scrollController.position.viewportDimension}");
    });


  /// SCROLL CONTROLLER END ///

  /// ACTUAL APP - START ///
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
//      SliverToBoxAdapter( //replaced by WebViewSliver
              WebViewSliver(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth:400, maxHeight: 800), //TODO: remove hardcoded webview dimensions
                  child: _webView,
                ),
              ),
              SliverToBoxAdapter(
                  child: Container(
                    height: 50.0,
                    color: Colors.amber,
                    child: Center(
                        child: Text(
                          'Card Bellow Feed :/',
                          style: TextStyle(color: Colors.white),
                        )),
                  )
              ),
            ],
          )
      )
  ));
}
  /// ACTUAL APP - END ///


/// Custom ScrollController - Allow endless scrolling downwards - START ///
class UnboundedScrollPosition extends ScrollPositionWithSingleContext {
  UnboundedScrollPosition({
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition oldPosition,
  }) : super(physics: physics, context: context, oldPosition: oldPosition);

//  @override
//  double get minScrollExtent => double.negativeInfinity;

  @override
  double get maxScrollExtent => double.infinity;
}

class UnlimitedScrollController extends ScrollController {
  @override
  UnboundedScrollPosition createScrollPosition(
      ScrollPhysics physics,
      ScrollContext context,
      ScrollPosition oldPosition,
      ) {
    return UnboundedScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
    );
  }
}
/// Custom ScrollController - Allow endless scrolling downwards - END ///

/// "Native" Content START ///
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
/// "Native" Content END ///


/// CUSTOM SLIVER - MEANT TO KEEP WEBVIEW CLAMPED TO TOP - START ///
class WebViewSliver extends SingleChildRenderObjectWidget {
  const WebViewSliver({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  CustomRenderSliverToBoxAdapter createRenderObject(BuildContext context) =>
      CustomRenderSliverToBoxAdapter();
}

// ignore: public_member_api_docs
class CustomRenderSliverToBoxAdapter extends RenderSliverSingleBoxAdapter {
  // ignore: public_member_api_docs
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
    assert(childExtent != null);


    //Set visible dimensions (the size that's actually painted)
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    geometry = SliverGeometry(
      scrollExtent: childExtent, /// The amount of scrolling the user needs to do to get from the beginning of this sliver to the end of this sliver.
      paintExtent: paintedChildSize,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      paintOrigin: constraints.scrollOffset,
      visible: true //force visible = true removes an issue where the WebView used to disappear after reaching screen top.
    );

//    print ("WebViewSliver | maxPaintExtent = $geometry.maxPaintExtent");
//    print ("WebViewSliver | paintExtent = $geometry.paintExtent");
    setChildParentData(child, constraints, geometry);

    // Expose geometry
    _visibleRect = Rect.fromLTWH(
        constraints.scrollOffset, 0.0, geometry.paintExtent, child.size.height);
  }
}

Rect _visibleRect = Rect.zero;
/// CUSTOM SLIVER - MEANT TO KEEP WEBVIEW CLAMPED TO TOP - END ///