import 'package:flutter/material.dart';

class LoadingAnimationWidget extends StatefulWidget {
  @override
  _LoadingAnimationWidgetState createState() => _LoadingAnimationWidgetState();
}

class _LoadingAnimationWidgetState extends State<LoadingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RotationTransition(
            turns: _animationController,
            child: Transform.scale(
              scale: 0.4,
              child: Image.asset('assets/images/gluten_void_logo.png'),
            ),
          ),
          Text('Absorbiendo gluten...', style: TextStyle(
              fontSize: 20,
              color: Colors.black),
          )
        ],
      ),
    );
  }
}