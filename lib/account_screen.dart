import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

Future<void> updateDisplayedName(user, name) async {
  user!.updateDisplayName(name);
  return;
}

class _AccountScreenState extends State<AccountScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String baseUrl = '192.168.0.109';
  var userRole = 'aboba';

  @override
  void initState() {
    super.initState();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, ModalRoute.withName("/"));
  }

  Future<String> getData() async {
    var response = await Dio().get(
        "http://$baseUrl:8080/client/role/${currentUser?.email}");
    if (mounted) {
    setState(() {
      userRole = response.data;
    });
  }
    return userRole;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Аккаунт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraint) {
        return Center(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                initialValue: FirebaseAuth.instance.currentUser?.email,
                decoration: const InputDecoration(
                  labelText: "Электронная почта",
                ),
              ),
              FutureBuilder<String>(
                future: getData(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    final theText = snapshot.data;
                    return TextFormField(
                      readOnly: true,
                      initialValue: theText,
                      decoration: const InputDecoration(
                        labelText: "Должность",
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator(
                      strokeWidth: 1.0,
                    );
                  }
                },
              ),
            ],
          ),
        ));
      })),
    );
  }
}
