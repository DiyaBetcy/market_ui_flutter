import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/admin/dashboardAdmin.dart';
import 'package:flutter_application_1/screens/product_list.dart';

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

                          final email =  emailController.text.trim();
                          final password = passwordController.text.trim();

                          setState(() => isLoading = false);

                          if (email == adminEmail &&
                              password == adminPassword) {

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(' Admin Login successful')),
                            );
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>AdminProductPage()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('User login successful'),
                              ),
                            );
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>ProductListPage()));
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
