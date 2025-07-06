import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final String adminEmail = 'admin@gmail.com';
  final String adminPassword = 'Admin@123';

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'At least 8 characters';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Must contain a capital letter';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Must contain a number';
                  }
                  if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                    return 'Must contain a special character (!@#\$&*~)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          await Future.delayed(Duration(seconds: 2));

                          if (emailController.text.trim() == adminEmail &&
                              passwordController.text.trim() == adminPassword) {
                            setState(() => isLoading = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Login successful')),
                            );
                          } else {
                            setState(() => isLoading = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invalid email or password'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text('Login'),
                    ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
