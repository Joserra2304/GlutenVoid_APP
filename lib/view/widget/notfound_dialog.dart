import 'package:flutter/material.dart';

import '../../flutter_flow/flutter_flow_theme.dart';

class ProductNotFoundDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF7C4DA4).withOpacity(0.9),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'No se pudo encontrar el producto escaneado.',
              style: TextStyle(color: Colors.yellow),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Volver',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
