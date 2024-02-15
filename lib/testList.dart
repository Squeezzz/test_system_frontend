// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_test_system/account_screen.dart';
import 'package:student_test_system/passingTest.dart';

void main() {
  runApp(const MaterialApp(home: TestList()));
}

class TestList extends StatefulWidget {
  const TestList({super.key});

  @override
  State<TestList> createState() => _TestListState();
}

class _TestListState extends State<TestList> {
  final List<String> testsObjects = [];
  Map<String, bool> isOpen = {};
  var currentUser = FirebaseAuth.instance.currentUser;

  var baseUrl = "192.168.0.109";

  @override
  void initState() {
    super.initState();
    getMyDisciplines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Список доступных тестов"),
          backgroundColor: Colors.blue,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                signOutUser;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              },
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: testsObjects.length,
            itemBuilder: (context, index) =>
                _buildRow(index, testsObjects[index])));
  }

  void signOutUser() {
    setState(() {
      FirebaseAuth.instance.signOut();
    });
  }

  _buildRow(int index, var nameSubject) {
    bool isOpenTest = false;
    isOpen.forEach((key, value) {
      if (testsObjects[index] == key) {
        print('запретим${testsObjects[index]}');
        isOpenTest = value;
      }
    });
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Название:', style: TextStyle(fontSize: 16)),
            Text(testsObjects[index], style: const TextStyle(fontSize: 16)),
            Visibility(
              visible: isOpenTest,
              replacement: OutlinedButton(
                onPressed: () {},
                child: const Text('Тест закрыт'),
              ),
              child: OutlinedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                onPressed: () async {
                  var passedResult = await Dio().get(
                      "http://$baseUrl:8080/test/passedOrNot/${testsObjects[index]}/${currentUser?.email}");
                      print(passedResult);
                  bool isPassed = bool.parse(passedResult.data);
                  if (isPassed == true) {
                    _dialogBuilder(context);
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PassingTest(testsObjects[index].toString())));
                  }
                },
                child: const Text(
                  'Пройти',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ));
  }

  void getMyDisciplines() async {
    List jsonList;
    Response response;
    try {
      response = await Dio().get(
          "http://$baseUrl:8080/discipline/${currentUser?.email}",
          options: Options(
              sendTimeout: const Duration(minutes: 1),
              receiveTimeout: const Duration(minutes: 1),
              receiveDataWhenStatusError: true));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(e.message);
    }
    setState(() {
      jsonList = response.data as List;
      //print(jsonList);
      jsonList.forEach((item) async {
        var testList = jsonList[jsonList.indexOf(item)]['tests'] as List;
        testList.forEach((element) => setState(() {
              testsObjects.add(testList[testList.indexOf(element)]['title']);
              //print(testList[testList.indexOf(element)]['visible']);
              isOpen.addAll({
                testList[testList.indexOf(element)]['title']:
                    testList[testList.indexOf(element)]['visible']
              });
            }));
      });
    });
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Тест уже пройден!'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Закрыть'),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName("/"));
              },
            ),
          ],
        );
      },
    );
  }
}
