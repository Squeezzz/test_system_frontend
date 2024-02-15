import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_test_system/account_screen.dart';
import 'package:student_test_system/creatingTest.dart';

void main() {
  runApp(const MaterialApp(home: CreatingSubject()));
}

class CreatingSubject extends StatefulWidget {
  const CreatingSubject({super.key});

  @override
  State<CreatingSubject> createState() => _CreatingSubjectState();
}

class _CreatingSubjectState extends State<CreatingSubject> {
  final creatingSubjectController = TextEditingController();
  final List<String> subjectObjects = [];
  int value = 2;
  var role = true;
  
  var currentUser = FirebaseAuth.instance.currentUser;

  String baseUrl = "192.168.0.109";

  _addItem() async {
    Navigator.pop(context);
    
      await Dio().post("http://$baseUrl:8080/discipline",
          data: {'title': creatingSubjectController.text});
      subscribe();
    setState(() {
      value = value + 1;
    });
    // ignore: use_build_context_synchronously
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CreatingTest(creatingSubjectController.text)))
        .then((_) => setState(() {
              creatingSubjectController.text = "";
            }));
    ;
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Создание дисциплины'),
          content: TextFormField(
            controller: creatingSubjectController,
            decoration: const InputDecoration(
              labelText: 'Название дисциплины',
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Создать'),
              onPressed: () {
                _addItem();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getAllDisciplines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Дисциплины"),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              signOutUser;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
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
          itemCount: subjectObjects.length,
          itemBuilder: (context, index) =>
              _buildRow(index, subjectObjects[index])),
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          onPressed: () => _dialogBuilder(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void signOutUser() {
    setState(() {
      FirebaseAuth.instance.signOut();
    });
  }

  _buildRow(int index, var nameSubject) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreatingTest(nameSubject)));
        },
        title: Text(subjectObjects[index]),
        subtitle: Text('subtitle$index'),
      ),
    );
  }

  void getAllDisciplines() async {
    List jsonList;
    var response;
    try {
      response = await Dio().get("http://$baseUrl:8080/discipline/${currentUser?.email}",
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
      print(jsonList);
      jsonList.length;

      jsonList.forEach((item) async {
        setState(() {
          value++;
          subjectObjects.add(jsonList[jsonList.indexOf(item)]['title']);
        });
      });
    });
  }
  
  Future<void> subscribe() async {
    await Dio().post("http://$baseUrl:8080/discipline/${creatingSubjectController.text}/${currentUser?.email}");
  }
}
