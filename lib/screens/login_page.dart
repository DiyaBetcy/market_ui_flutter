import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    @override
    Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            TextField(
                decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
                decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                ),
                obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
                onPressed: () {
                // Add basic login validation logic here
                // Example: navigate to product listing if inputs are valid
                },
                child: Text('Login'),
            ),
            ],
        ),
        ),
    );
    }
} 