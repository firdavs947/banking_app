import 'package:banking_app22/core/consts/themes/app_themes.dart';
import 'package:banking_app22/presentation/cubit/register_cubit.dart';
import 'package:banking_app22/screens/reegister_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context)=> RegisterCubit())
    ],
    child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: RegisterScreen(),
    );
  }
}
