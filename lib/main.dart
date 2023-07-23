import 'dart:io';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/services/auth/bloc/auth_bloc.dart';
import 'package:zynotes/services/auth/bloc/auth_event.dart';
import 'package:zynotes/services/auth/bloc/auth_state.dart';
import 'package:zynotes/services/auth/firebase_auth_provider.dart';
import 'package:zynotes/utilities/progress_indicator.dart';
import 'package:zynotes/views/login_view.dart';
import 'package:zynotes/views/notes/create_update_note_view.dart';
import 'package:zynotes/views/register_view.dart';
import 'package:zynotes/views/verify_email_view.dart';
import 'package:zynotes/views/notes/notes_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      homePage: (context) => const HomePage(),
      loginView: (context) => const LoginView(),
      registerView: (context) => const RegisterView(),
      verifyEmail: (context) => const VerifyEmail(),
      createUpdateNoteView: (context) => const CreateUpdateNoteView(),
    },
    title: 'ZyNotes',
    theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 11, 11, 11),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 15, 15, 15),
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 167, 166, 166),
            fontSize: 23,
            fontWeight: FontWeight.w500,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
          primary: const Color.fromARGB(255, 221, 220, 220),
        )),
    home: BlocProvider(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    //Setting Progress Indicator according to the Platform
    if (Platform.isIOS) {
      ActivityIndicator.indicator = const CupertinoActivityIndicator();
    } else {
      ActivityIndicator.indicator = const CircularProgressIndicator();
    }

    //Returning screens according to the state
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmail();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return Scaffold(
            body: Center(child: ActivityIndicator.indicator),
          );
        }
      },
    );
  }
}
