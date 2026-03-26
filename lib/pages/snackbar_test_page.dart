import 'package:flutter/material.dart';

class SnackbarTestPage extends StatelessWidget {
  const SnackbarTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snackbar Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SNACKBAR TEST OK'),
                backgroundColor: Colors.blue,
              ),
            );
          },
          child: const Text('Show Snackbar'),
        ),
      ),
    );
  }
}