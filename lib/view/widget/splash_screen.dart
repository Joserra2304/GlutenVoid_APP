import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../flutter_flow/flutter_flow_theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..repeat(period: Duration(seconds: 3));

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        context.pushNamed('MainMenu');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: const Text(
          "Gluten Void",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: Tween(begin: 1.0, end: 0.0).animate(_animationController), // Invertir la dirección
                child: Transform.scale(
                  scale: 0.4,
                  child: Image.asset('assets/images/gluten_void_logo.png'),
                ),
              ),
              const Text('Absorbiendo gluten...',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
