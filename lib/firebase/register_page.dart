import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String baseUrl = '192.168.0.109';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              const Text("Sign up", style: TextStyle(fontSize: 30)),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Enter email',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter password',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => {signUpUser()},
                child: const Text("Registration"),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: widget.onTap,
                child: const Text("Go to login"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void signUpUser() async {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        await Dio().post("http://$baseUrl:8080/client", data: {
          'login': emailController.text
        });
      } else {
        print("diff pass");
      }
  }
}
