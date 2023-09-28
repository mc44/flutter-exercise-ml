import 'package:flutter/material.dart';
import 'package:flutter_exercise/presentation/users/login_view/login.dart';

import '../../users/register_view/register.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Request An Equipment App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
          buttonColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Request An Equipment App'),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome!",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: Builder(
                    builder: (BuildContext buttonContext) => ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          buttonContext,
                          MaterialPageRoute(builder: (context) => RegisterView()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Register'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Builder(
                    builder: (BuildContext buttonContext) => ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          buttonContext,
                          MaterialPageRoute(builder: (context) => LoginView()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('LogIn'),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}