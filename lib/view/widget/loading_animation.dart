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
      duration: Duration(seconds: 3),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RotationTransition(
              turns: Tween(begin: 1.0, end: 0.0).animate(_animationController), // Invertir la dirección
              child: Transform.scale(
                scale: 0.4,
                child: Image.asset('assets/images/gluten_void_logo.png'),
              ),
            ),
            const Text(
              'Absorbiendo gluten...',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
