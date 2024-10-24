import 'package:flutter/material.dart';
import 'package:virtual_aquarium/screens/aquarium_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: AquariumScreen.id,
      routes: {
        AquariumScreen.id: (context) => AquariumScreen(),
      },
    );
  }
}
