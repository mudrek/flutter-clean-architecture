import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection_container.dart' as di;

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: NumberTriviaPage(),
    );
  }
}
