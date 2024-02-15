import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_test_system/creatingQuestion.dart';
import 'package:student_test_system/firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
      home: CreatingTest(
          "Не пришел name_test с прошлой страницы (создания предмета)")));
}

class CreatingTest extends StatefulWidget {
  const CreatingTest(this.nameSub, {super.key});

  final String nameSub;

  @override
  State<CreatingTest> createState() => _CreatingTestState(nameSub);
}

class _CreatingTestState extends State<CreatingTest> {
  final testNameController = TextEditingController();
  final String nameSub;
  final List<String> testObjects = [];
  final List<String> studentObjects = [];

  String baseUrl = "192.168.0.109";

  var currentUser = FirebaseAuth.instance.currentUser;

  var addStudentController = TextEditingController();

  bool light = true;
  Map<String, bool> isOpen = {};

  _CreatingTestState(this.nameSub);

  @override
  void initState() {
    super.initState();
    getAllTests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Тесты дисциплины $nameSub"),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text("Слушатели"),
            titleTextStyle:
                TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            tileColor: Color.fromARGB(255, 21, 102, 168),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: addStudentController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Введите email',
                            labelStyle: TextStyle(fontSize: 14.0))),
                  ),
                  FloatingActionButton.extended(
                    onPressed: () async {
                      await Dio().post(
                          "http://$baseUrl:8080/discipline/$nameSub/${addStudentController.text}");
                      addStudentController.clear();
                    },
                    label: const Text('Добавить'),
                  ),
                ],
              )),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: studentObjects.length,
              itemBuilder: (context, index) =>
                  _buildRowStudent(index, studentObjects[index])),
          const ListTile(
            title: Text("Тесты"),
            titleTextStyle:
                TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            tileColor: Color.fromARGB(255, 21, 102, 168),
          ),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: testObjects.length,
              itemBuilder: (context, index) =>
                  _buildRow(index, testObjects[index]))
        ],
      ),
      floatingActionButton: OutlinedButton(
        onPressed: () => _dialogBuilder(context),
        child: const Text('Добавить тест'),
      ),
    );
  }

  _buildRow(int index, var testName) {
    bool isOpenTest = true;
    isOpen.forEach((key, value) {
      if (testObjects[index] == key) {
        //print('запретим${testObjects[index]}');
        isOpenTest = value;
      }
    });

    return Card(
      child: ListTile(
        leading: Switch(
          value: isOpenTest,
          onChanged: (bool thisValue) {
            setState(() {
              isOpenTest = thisValue;
              isOpen.update(testName, (value) => thisValue);
            });
            Dio().post("http://$baseUrl:8080/test/$testName/$thisValue");
          },
        ),
        onTap: () {
          Navigator.of(context).pop;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreatingQuestion(testObjects[index])));
        },
        title: Text(testObjects[index]),
        subtitle: Text('subtitle$index'),
      ),
    );
  }

  _buildRowStudent(int index, var testName) {
    return ListTile(title: Text("Почта студента: ${studentObjects[index]}"));
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Создание теста'),
          content: TextFormField(
            controller: testNameController,
            onFieldSubmitted: (text) {
              Dio().post("http://$baseUrl:8080/test", data: {'title': text});
            },
            decoration: const InputDecoration(
              labelText: 'Название теста',
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Создать'),
              onPressed: () {
                goPush(testNameController.text);
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CreatingQuestion(testNameController.text)))
                    .then((_) => setState(() {
                          testNameController.text = "";
                        }));
              },
            ),
          ],
        );
      },
    );
  }

  goPush(testName) async {
    Navigator.pop(context);
    await Dio().post("http://$baseUrl:8080/test/$nameSub",
        data: {'title': testNameController.text});
    await Dio().post("http://$baseUrl:8080/test/$testName/false");
  }

  void getAllTests() async {
    List jsonList;
    var response;
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
      jsonList.forEach((item) async {
        // print("----------------------------------------------------");
        // print(jsonList[jsonList.indexOf(item)]['id']);
        // print(jsonList[jsonList.indexOf(item)]['tests']);
        // print("----------------------------========------------------------");
        // print(jsonList[jsonList.indexOf(item)]['clients']);
        var testList = jsonList[jsonList.indexOf(item)]['tests'] as List;
        var subTitle = jsonList[jsonList.indexOf(item)]['title'];
        var studentList = jsonList[jsonList.indexOf(item)]['clients'] as List;
        studentList.forEach((element) => setState(() {
              if (subTitle == nameSub) {
                studentObjects
                    .add(studentList[studentList.indexOf(element)]['email']);
              }
            }));
        testList.forEach((element) => setState(() {
              if (subTitle == nameSub) {
                testObjects.add(testList[testList.indexOf(element)]['title']);
                isOpen[testList[testList.indexOf(element)]['title']] =
                    testList[testList.indexOf(element)]['visible'];
                print(isOpen);
              }
            }));
      });
    });
  }
}
