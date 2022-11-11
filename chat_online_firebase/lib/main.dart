import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
 
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.blue,
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

