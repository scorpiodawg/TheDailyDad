import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_daily_dad/providers/daily_data_provider.dart';
import 'package:the_daily_dad/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:the_daily_dad/utils/logger.dart';

Future<void> main() async {
  setupLogger();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DailyDataProvider(),
      child: MaterialApp(
        title: 'The Daily Dad',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
