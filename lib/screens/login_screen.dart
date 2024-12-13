import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/app_text_form_field.dart';
import 'package:frontend/functions/solicitudes_state.dart';
import 'package:frontend/functions/submit_handler.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/usuarios_service.dart';
import 'package:frontend/values/app_constants.dart';
import 'package:frontend/values/app_theme.dart';
import '../values/app_string.dart';
import 'package:frontend/utils/gradient_background.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final serviceUsuario = UsuariosService();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();

  void initializeControllers() {
    _cedulaController.addListener(controllerListener);
    _passwordController.addListener(controllerListener);
  }

  void disposeControllers() {
    _cedulaController.dispose();
    _passwordController.dispose();
  }

  void controllerListener() {
    final cedula = _cedulaController.text;
    final password = _passwordController.text;

    if (password.isEmpty || cedula.isEmpty ) return;

    if (AppConstants.cedulaRegex.hasMatch(cedula) && password.isNotEmpty) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final solicitudesState = Provider.of<SolicitudesState>(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const GradientBackground(
            children: [
              Text(
                AppStrings.signInToYourNAccount,
                style: AppTheme.titleLarge,
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                AppStrings.signInToYourAccount,
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextFormField(
                    controller: _cedulaController,
                    labelText: AppStrings.cedula,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseEnterCedula
                          : AppConstants.cedulaRegex.hasMatch(value)
                              ? null
                              : AppStrings.onlyNumbersAndMax10Digits;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  ValueListenableBuilder(
                    valueListenable: passwordNotifier,
                    builder: (context, passwordObscure, _) {
                      return AppTextFormField(
                        obscureText: passwordObscure,
                        controller: _passwordController,
                        labelText: AppStrings.password,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          return value!.isEmpty
                              ? AppStrings.pleaseEnterPassword
                              : null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () =>
                              passwordNotifier.value = !passwordObscure,
                          style: IconButton.styleFrom(
                            minimumSize: const Size.square(48),
                          ),
                          icon: Icon(
                            passwordObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: fieldValidNotifier,
                    builder: (context, isValid, _) {
                      return ElevatedButton(
                        onPressed: isValid
                            ? () async {
                                await FormSubmitHandler.loginSubmit(
                                  solicitudesState: solicitudesState,
                                  context: context,
                                  cedulaController: _cedulaController,
                                  passwordController: _passwordController,
                                  authService: authService,
                                  serviceUsuario: serviceUsuario,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.lightGreen.shade300,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(AppStrings.login),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.doNotHaveAnAccount,
                        style: AppTheme.bodySmall.copyWith(color: Colors.black),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(
                              serviceUsuario: serviceUsuario,
                            ),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.lightGreen.shade900,
                        ),
                        child: const Text(AppStrings.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
