import 'package:flutter/material.dart';
import 'package:student_test_system/firebase/register_page.dart';

import 'login_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showingLoginPage = true;

  void togglePages() {
    setState(() {
      showingLoginPage = !showingLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showingLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
}
