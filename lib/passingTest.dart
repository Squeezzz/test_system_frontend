import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_test_system/account_screen.dart';

class PassingTest extends StatefulWidget {
  const PassingTest(this.testId, {super.key});
  final String testId;

  @override
  State<PassingTest> createState() => _PassingTestState(testId);
}

class _PassingTestState extends State<PassingTest> {
  final String testId;

  _PassingTestState(this.testId);

  var baseUrl = "192.168.0.109";
  var currentUser = FirebaseAuth.instance.currentUser;
  List<dynamic> jsonQuestions = [];
  Map<String, int> selectedAnswers = {};
  var lastAnswer;

  int summScore = 0;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    var answers = await Dio().get("http://$baseUrl:8080/answer/$testId");
    List<dynamic> allAnswers = answers.data as List;
    if (allAnswers.isNotEmpty) {
      lastAnswer = allAnswers.last["text"];
    }
    var questions = await Dio().get("http://$baseUrl:8080/question/$testId");
    setState(() {
      jsonQuestions = questions.data as List;
    });
  }

  void signOutUser() {
    setState(() {
      FirebaseAuth.instance.signOut();
    });
  }

  Future<void> _changeColor(
      String question, int index, String answerTitle) async {
    await Dio().post("http://$baseUrl:8080/answer/${currentUser?.email}/${answerTitle}");
    setState(() {
      if (selectedAnswers.containsKey(question) &&
          selectedAnswers[question] != index) {
        return; // ответ уже выбран в текущем вопросе, менять цвет не разрешено
      }
      selectedAnswers[question] = index;
      if (lastAnswer == answerTitle) {
        _dialogBuilder(context);
      }
    });
  }

  Color setColor(int score) {
    summScore += score;
    if (score > 20) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Тест завершен!'),
          content: Text("Набранный результат $summScore"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Закрыть'),
              onPressed: () async {
                await Dio().post(
                    "http://$baseUrl:8080/test/passed/$testId/${currentUser?.email}");
                setState(() {
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Прохождение теста $testId"),
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
        itemCount: jsonQuestions.length,
        itemBuilder: (context, questionIndex) {
          final question = jsonQuestions[questionIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  question['text'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: question['answers'].length,
                itemBuilder: (context, answerIndex) {
                  final answer = question['answers'][answerIndex];
                  return ListTile(
                    tileColor: selectedAnswers[question['text']] == answerIndex
                        ? setColor(answer['score'])
                        : null,
                    title: Text(answer['text']),
                    onTap: () {
                      _changeColor(
                          question['text'], answerIndex, answer['text']);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
