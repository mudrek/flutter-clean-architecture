import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import '../../../../injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: _body(context),
    );
  }

  BlocProvider<NumberTriviaBloc> _body(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              _test(),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Placeholder(
                    fallbackHeight: 40,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Placeholder(fallbackHeight: 30),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Placeholder(fallbackHeight: 30),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _test() {
    return BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Placeholder(),
        );
      },
    );
  }
}
