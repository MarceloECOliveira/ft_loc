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
          // 1. O ColorScheme é o cérebro do tema moderno.
          // Usamos ColorScheme.fromSeed para que o Flutter gere uma paleta
          // de cores harmoniosa a partir da sua cor principal.
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF126fa2),
            brightness: Brightness.light,
            // 'surface' agora controla tanto o fundo como as superfícies.
            surface: Colors.white,
            // 'onSurface' agora controla o texto em ambos.
            onSurface: const Color(0xFF1f1a17),
          ),

          // 2. (Opcional mas recomendado) Estilos específicos para widgets
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(
              0xFF126fa2,
            ), // Garante que a AppBar use a cor primária
            foregroundColor: Colors.white, // Texto e ícones brancos na AppBar
            elevation: 2.0,
            titleTextStyle: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF126fa2), // FAB usa a cor primária
            foregroundColor: Colors.white,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF126fa2,
              ), // Botões usam a cor primária
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Define a cor de texto padrão para o corpo da aplicação
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Color(0xFF1f1a17)),
            titleLarge: TextStyle(color: Color(0xFF1f1a17)),
            // ... pode definir outros estilos de texto aqui
          ),
        ),
        home: Wrapper(),
      ),
    );
  }
}
