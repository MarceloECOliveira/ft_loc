import 'package:flutter/material.dart';
import 'package:ft_loc/blocs/firebase_auth_bloc.dart';
import 'package:ft_loc/blocs/firebase_store_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ft_loc/services/firebase_auth_service.dart';
import 'package:ft_loc/services/firebase_store_service.dart';
import 'package:ft_loc/views/wrapper.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuthService = FirebaseAuthService();
    final firebaseStoreService = FirebaseStoreService(
      authService: firebaseAuthService,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              FirebaseAuthBloc(authService: firebaseAuthService),
        ),
        BlocProvider(
          create: (context) =>
              FirebaseStoreBloc(storeService: firebaseStoreService),
        ),
      ],
      child: MaterialApp(
        title: 'FT Loc',
        theme: ThemeData(
          useMaterial3: true,

          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF126fa2),
            brightness: Brightness.light,

            surface: Colors.white,

            onSurface: const Color(0xFF1f1a17),
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF126fa2),
            foregroundColor: Colors.white,
            elevation: 2.0,
            titleTextStyle: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF126fa2),
            foregroundColor: Colors.white,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF126fa2),
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Color(0xFF1f1a17)),
            titleLarge: TextStyle(color: Color(0xFF1f1a17)),
          ),
        ),
        home: Wrapper(),
      ),
    );
  }
}
