import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_test_system/creatingSubject.dart';
import 'package:student_test_system/testList.dart';
import 'package:student_test_system/userStatistic.dart';
import 'account_screen.dart';
import 'firebase/auth_page.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      routes: {
        '/': (context) => const AuthPage(),
        '/signup': (context) => const AuthPage(),
        '/account': (context) => const AccountScreen(),
        '/createSubject': (context) => const CreatingSubject()
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int index = 0;
  bool userRole = false;

  var baseUrl = '192.168.0.109';
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getRole();
  }

  final screens = [
    const UserStatistic(),
    const CreatingSubject(),
    const TestList(),
  ];

  final screensStudent = [
    const UserStatistic(),
    const TestList(),
  ];

  Future<void> getRole() async {
    var response = await Dio()
        .get("http://$baseUrl:8080/client/role/${currentUser?.email}");
    if (response.data == 'TEACHER') {
      setState(() {
        userRole = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        body: userRole? screens[index] : screensStudent[index],
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.blueAccent,
          height: 55,
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          destinations: userRole
              ? [
                  const NavigationDestination(
                      icon: Icon(Icons.info_outline, color: Colors.white),
                      label: 'Statistic'),
                  const NavigationDestination(
                      icon: Icon(Icons.add, color: Colors.white),
                      label: 'Subjects'),
                  const NavigationDestination(
                      icon: Icon(Icons.table_chart_sharp, color: Colors.white),
                      label: 'Tests')
                ]
              : [
                  const NavigationDestination(
                      icon: Icon(Icons.info_outline, color: Colors.white),
                      label: 'Statistic'),
                  const NavigationDestination(
                      icon: Icon(Icons.table_chart_sharp, color: Colors.white),
                      label: 'Tests'),
                ],
        ),
      );
    } else {
      return const AuthPage();
    }
  }
}
