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
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Wrapper(),
      ),
    );
  }
}
