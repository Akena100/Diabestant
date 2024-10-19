import 'package:flutter/material.dart';

class CircularChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: 0.75,
            strokeWidth: 10,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            backgroundColor: Colors.grey[200],
          ),
        ),
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: 0.6,
            strokeWidth: 10,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            backgroundColor: Colors.grey[200],
          ),
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('50.0',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('118/78.0',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
