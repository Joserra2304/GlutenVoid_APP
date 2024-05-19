
import 'package:flutter/material.dart';

class ProductNotFoundDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('No se pudo encontrar el producto escaneado.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Aceptar'),
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el AlertDialog
          },
        ),
      ],
    );
  }
}
