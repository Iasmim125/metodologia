import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recomenda Metodologias',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recomenda Metodologias'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuizPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.purple,
            onPrimary: Colors.white,
          ),
          child: Text('Iniciar Teste'),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int questionIndex = 0;
  List<String> answers = [];

  final List<Map<String, dynamic>> questions = [
    {
      'questionText': 'Prefere planejamento detalhado ou flexibilidade?',
      'answers': ['Detalhado', 'Flexibilidade'],
    },
    {
      'questionText': 'Gosta de iterações curtas ou longas?',
      'answers': ['Curtas', 'Longas'],
    },
    {
      'questionText': 'Você prefere documentação extensa ou mínima?',
      'answers': ['Extensa', 'Mínima'],
    },
    {
      'questionText': 'Como você lida com mudanças no projeto?',
      'answers': ['Adapto facilmente', 'Prefiro evitar mudanças'],
    },
    {
      'questionText': 'Como você se sente em relação à colaboração em equipe?',
      'answers': ['Adoro trabalhar em equipe', 'Prefiro trabalhar sozinho'],
    },
    {
      'questionText': 'Você gosta de definir metas específicas para o projeto?',
      'answers': ['Sim, metas claras são essenciais', 'Não, prefiro flexibilidade'],
    },
  ];

  void answerQuestion(String answer) {
    answers.add(answer);

    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
      });
    } else {
      saveUserPreferences();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultsPage(answers, restartTest)),
      );
    }
  }

  Future<void> saveUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userAnswers', answers);
  }

  void restartTest() {
    setState(() {
      questionIndex = 0;
      answers = [];
    });
    Navigator.pop(context); // Pop the results page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recomenda Metodologias'),
      ),
      body: questionIndex < questions.length
          ? QuestionWidget(
              questionText: questions[questionIndex]['questionText'],
              answers: questions[questionIndex]['answers'],
              answerCallback: answerQuestion,
            )
          : Center(
              child: Text('Carregando...'),
            ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final String questionText;
  final List<String> answers;
  final Function answerCallback;

  QuestionWidget({
    required this.questionText,
    required this.answers,
    required this.answerCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            questionText,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
        ),
        ...answers.map(
          (answer) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => answerCallback(answer),
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
                onPrimary: Colors.white,
              ),
              child: Text(
                answer,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ResultsPage extends StatelessWidget {
  final List<String> userAnswers;
  final VoidCallback restartCallback;

  ResultsPage(this.userAnswers, this.restartCallback);

  String calculateRecommendedMethodology() {
    int scoreCascata = 0;
    int scoreScrum = 0;
    int scoreKanban = 0;
    int scoreScrumban = 0;

    for (String answer in userAnswers) {
      if (answer == 'Detalhado') {
        scoreCascata++;
      } else if (answer == 'Flexibilidade') {
        scoreScrum++;
      }
      if (answer == 'Curtas') {
        scoreScrum++;
      } else if (answer == 'Longas') {
        scoreKanban++;
      }
      if (answer == 'Extensa') {
        scoreCascata++;
      } else if (answer == 'Mínima') {
        scoreKanban++;
      }
      if (answer == 'Adapto facilmente') {
        scoreScrum++;
      } else if (answer == 'Prefiro evitar mudanças') {
        scoreCascata++;
      }
      if (answer == 'Adoro trabalhar em equipe') {
        scoreScrumban++;
      } else if (answer == 'Prefiro trabalhar sozinho') {
        scoreKanban++;
      }
      if (answer == 'Sim, metas claras são essenciais') {
        scoreCascata++;
      } else if (answer == 'Não, prefiro flexibilidade') {
        scoreScrumban++;
      }
    }

    if (scoreScrum > scoreCascata && scoreScrum > scoreKanban && scoreScrum > scoreScrumban) {
      return 'Scrum';
    } else if (scoreCascata > scoreKanban && scoreCascata > scoreScrumban) {
      return 'Cascata';
    } else if (scoreKanban > scoreScrumban) {
      return 'Kanban';
    } else {
      return 'Scrumban';
    }
  }

  String getMethodologyDescription(String methodology) {
    switch (methodology) {
      case 'Cascata':
        return 'A metodologia Cascata é conhecida por seu foco em planejamento detalhado e documentação extensa. Ela é adequada para projetos com requisitos bem definidos desde o início.';
      case 'Scrum':
        return 'Scrum é uma metodologia ágil que enfatiza a flexibilidade e iterações curtas. É ideal para projetos que podem se adaptar a mudanças frequentes e feedback contínuo.';
      case 'Kanban':
        return 'Kanban é uma abordagem visual que se concentra na gestão do fluxo de trabalho. É recomendada para projetos que exigem um controle rigoroso do trabalho em andamento.';
      case 'Scrumban':
        return 'Scrumban combina elementos do Scrum e do Kanban, oferecendo flexibilidade e controle do fluxo. É uma escolha sólida para projetos que desejam uma abordagem híbrida.';
      default:
        return 'Descrição não disponível';
    }
  }

  String getMethodologyTips(String methodology) {
    switch (methodology) {
      case 'Cascata':
        return 'Dicas para usar Cascata:\n1. Certifique-se de ter requisitos bem definidos antes de começar o projeto.\n2. Faça um planejamento detalhado desde o início.\n3. Documente cada fase do projeto minuciosamente.';
      case 'Scrum':
        return 'Dicas para usar Scrum:\n1. Mantenha iterações curtas e regulares (sprints).\n2. Priorize a flexibilidade para se adaptar a mudanças durante o desenvolvimento.\n3. Realize reuniões diárias para manter a equipe alinhada.';
      case 'Kanban':
        return 'Dicas para usar Kanban:\n1. Visualize seu fluxo de trabalho com um quadro Kanban.\n2. Limite o trabalho em andamento para evitar sobrecarga.\n3. Otimize continuamente seu processo com base nos dados do quadro.';
      case 'Scrumban':
        return 'Dicas para usar Scrumban:\n1. Combine elementos do Scrum e do Kanban conforme necessário.\n2. Mantenha um equilíbrio entre flexibilidade e controle do fluxo.\n3. Ajuste suas práticas de acordo com as necessidades específicas do projeto.';
      default:
        return 'Dicas não disponíveis';
    }
  }

  @override
  Widget build(BuildContext context) {
    String recommendedMethodology = calculateRecommendedMethodology();
    String methodologyDescription = getMethodologyDescription(recommendedMethodology);
    String methodologyTips = getMethodologyTips(recommendedMethodology);

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Metodologia recomendada para você: $recommendedMethodology',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            SizedBox(height: 20),
            Text(
              'Descrição:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                methodologyDescription,
                style: TextStyle(fontSize: 18, color: Colors.purple),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Dicas práticas:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                methodologyTips,
                style: TextStyle(fontSize: 18, color: Colors.purple),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: restartCallback,
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
                onPrimary: Colors.white,
              ),
              child: Text('Reiniciar Teste'),
            ),
          ],
        ),
      ),
    );
  }
}
