import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class XToast {
  static void showText(
    BuildContext context,
    String msg, {
    int duration = 2,
    Color maskColor,
  }) {
    _ToastView.dismiss();
    Widget content = _buildContainer(
      child: Text(
        msg,
        softWrap: true,
        textAlign: TextAlign.center,
        style: _textStyle(),
      ),
      minHeight: 1,
    );
    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom > 10 ? media.viewInsets.bottom : 0;
    _ToastView.createView(
        context: context,
        child: content,
        duration: duration,
        maskColor: maskColor,
        margin: EdgeInsets.only(bottom: -media.size.height/2 + keyboardHeight));
  }

  static void showError(
    BuildContext context,
    String msg, {
    int duration = 2,
    Color maskColor,
  }) {
    showSuccess(context, msg,
        duration: duration, maskColor: maskColor, isSuccess: false);
  }

  static void showSuccess(
    BuildContext context,
    String msg, {
    int duration = 2,
    Color maskColor,
    bool isSuccess = true,
  }) {
    _ToastView.dismiss();
    Widget content = _buildContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            isSuccess
                ? 'images/global_toast_success@3x.png'
                : 'images/global_toast_fail@3x.png',
            width: 36,
            height: 36,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            msg,
            style: _textStyle(),
          ),
        ],
      ),
    );
    _ToastView.createView(
        context: context,
        child: content,
        duration: duration,
        maskColor: maskColor);
  }

  static void showLoading(
    BuildContext context, {
    String msg = '加载中...',
    int maxDuration = 15,
    Color maskColor,
  }) {
    _ToastView.dismiss();
    Widget content = _buildContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _XLoadingAnimate(),
          SizedBox(
            height: 8,
          ),
          Text(
            msg,
            style: _textStyle(),
          ),
        ],
      ),
    );
    _ToastView.createView(
        context: context,
        child: content,
        duration: maxDuration,
        maskColor: maskColor);
  }

  static void dismiss() {
    _ToastView.dismiss();
  }

  static Widget _buildContainer({Widget child, double minWidth = 90, double minHeight = 90}) {
    Widget content = Container(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight, maxWidth: 300),
        decoration: BoxDecoration(
          color: Color(0xD9000000),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: child,
      ),
    );
    return content;
  }

  static TextStyle _textStyle() {
    return TextStyle(
        fontSize: 14,
        color: Colors.white,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w400);
  }
}

/// 控制居中和大小
class _ToastView {
  static final _ToastView _singleton = new _ToastView._internal();

  factory _ToastView() {
    return _singleton;
  }

  _ToastView._internal();

  static OverlayState overlayState;
  static OverlayEntry _overlayEntry;
  static bool _isVisible = false;
  static Timer dismissTimer;

  static void createView({
    BuildContext context,
    int duration,
    Color maskColor,
    Widget child,
    EdgeInsets margin = const EdgeInsets.all(0.0),
  }) async {
    overlayState = Overlay.of(context);

    _overlayEntry = new OverlayEntry(
      builder: (BuildContext context) => _XToastWidget(
        maskColor: maskColor,
        widget: child,
        margin: margin,
      ),
    );
    _isVisible = true;
    overlayState.insert(_overlayEntry);
    dismissTimer = Timer(Duration(seconds: duration), () {
      dismiss();
    });
  }

  static dismiss() async {
    dismissTimer?.cancel();
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _overlayEntry?.remove();
  }
}

/// 设置背景和屏蔽触摸
class _XToastWidget extends StatelessWidget {
  _XToastWidget({
    Key key,
    @required this.widget,
    this.maskColor,
    this.margin,
  }) : super(key: key);

  final Widget widget;
  final Color maskColor;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    if (maskColor == null) {
      return Positioned(
        left: margin.left,
        right: margin.right,
        top: margin.top,
        bottom: margin.bottom,
        child: Container(
          child: widget,
        ),
      );
    } else {
      return Positioned(
        left: margin.left,
        right: margin.right,
        top: margin.top,
        bottom: margin.bottom,
        child: Material(
          color: maskColor,
          child: widget,
        ),
      );
    }
  }
}

class _XLoadingAnimate extends StatefulWidget {
  _XLoadingAnimate({Key key}) : super(key: key);

  __XLoadingAnimateState createState() => __XLoadingAnimateState();
}

class __XLoadingAnimateState extends State<_XLoadingAnimate>
    with SingleTickerProviderStateMixin {
  __XLoadingAnimateState() : super() {
    controller = AnimationController(vsync: this);
  }
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller.repeat(min: 0, max: 1, period: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      alignment: Alignment.center,
      turns: controller,
      child: Image.asset(
        'images/global_toast_loading@3x.png',
        width: 36,
        height: 36,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
