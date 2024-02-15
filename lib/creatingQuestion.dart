import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
      home: CreatingQuestion(
          "Не пришел name_test с прошлой страницы (создания теста)")));
}

class CreatingQuestion extends StatefulWidget {
  const CreatingQuestion(this.testName, {super.key});

  final String testName;

  @override
  State<CreatingQuestion> createState() => _CreatingQuestionState(testName);
}

class _CreatingQuestionState extends State<CreatingQuestion> {
  final String testName;
  int question_counter = 0;
  Map<int, int> questions_answers = {};
  Map<int, TextEditingController> questionControllers =
      <int, TextEditingController>{};
  Map<int, TextEditingController> answerControllers =
      <int, TextEditingController>{};

  var baseUrl = "192.168.0.109";
  var value;
  var currentQuestion;
  String answerText = '';
  String questionText = '';
  
  String currentAnswer = '';

  _CreatingQuestionState(this.testName);

  @override
  void initState() {
    super.initState();
    getAllQuestions();
  }

  
  Future<void> getAllQuestions() async {
    List jsonList;
    var response;
    try {
      response = await Dio().get("http://$baseUrl:8080/question/$testName",
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

      jsonList.forEach((item) async {
        setState(() {
          var answer_len = jsonList[jsonList.indexOf(item)]['answers'] as List;
          questions_answers[questions_answers.length] = answer_len.length;
          question_counter++;
          questionControllers[questions_answers.length - 1] =
              TextEditingController(
                  text: jsonList[jsonList.indexOf(item)]['text'].toString());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(
              child: Text("Создание вопросов", textAlign: TextAlign.center)),
          backgroundColor: Colors.blue,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Questions done',
              onPressed: () {
                setState(() {
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                });
              },
            ),
          ],
        ),
        body: ListView(children: [
          ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int myindex) {
              return Column(
                children: <Widget>[
                  TextFormField(
                    controller: questionControllers[myindex],
                    onFieldSubmitted: (text) {
                      currentQuestion = text;
                      Dio().post("http://$baseUrl:8080/question/${testName}",
                          data: {'text': text});
                    },
                    decoration: InputDecoration(
                      labelText: 'Введите вопрос №${myindex + 1}',
                    ),
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.white38, width: 18.0),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0)),
                                boxShadow: const [
                                  BoxShadow(
                                      blurRadius: 5, color: Colors.black38)
                                ]),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: TextFormField(
                                          onFieldSubmitted: (text) {
                                            setState(() {
                                              currentAnswer = text;
                                            });
                                          },
                                          decoration: InputDecoration(
                                              labelText:
                                                  'Введите ответ №${index + 1}'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: TextFormField(
                                          onFieldSubmitted: (text) {
                                            Dio().post(
                                                "http://$baseUrl:8080/answer/${currentQuestion}",
                                                data: {
                                                  "text": currentAnswer,
                                                  "score": text
                                                });
                                          },
                                          decoration: const InputDecoration(
                                              labelText: 'Балл'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    itemCount: questions_answers[myindex],
                  ),
                  FloatingActionButton(
                      heroTag: "addAnswer$myindex",
                      onPressed: () {
                        setState(() {
                          questions_answers.update(
                            myindex,
                            (value) => ++value,
                            ifAbsent: () => 1,
                          );
                          print(questions_answers);
                        });
                      },
                      backgroundColor: Colors.green,
                      child: const Text('+ ответ',
                          textAlign: TextAlign.center, textScaleFactor: 0.9)),
                  const SizedBox(height: 25),
                ],
              );
            },
            itemCount: question_counter,
          ),
        ]),
        floatingActionButton: FloatingActionButton(
            heroTag: "Добавить вопрос",
            onPressed: () {
              setState(() {
                questions_answers[questions_answers.length] = 2;
                question_counter++;
                questionControllers[questions_answers.length] =
                    TextEditingController();
              });
            },
            splashColor: Colors.grey,
            backgroundColor: Colors.red,
            child: const Text('+ Вопрос', textScaleFactor: 0.7)),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat);
  }
}
