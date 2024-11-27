import 'package:flutter/material.dart';
import 'package:frontend/functions/image_state.dart';
import 'package:frontend/functions/solicitudes_state.dart';
import 'package:frontend/functions/usuarios_state.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SolicitudesState()),
        ChangeNotifierProvider(create: (_) => UsuariosState()),
        ChangeNotifierProvider(create: (_) => ImageState()),
      ],
      child: MaterialApp(
        title: 'Solicitudes de Visitantes - Residentes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
