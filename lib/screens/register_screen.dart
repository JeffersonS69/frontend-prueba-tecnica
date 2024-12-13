import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/app_text_form_field.dart';
import 'package:frontend/functions/submit_handler.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/usuarios_service.dart';
import 'package:frontend/utils/gradient_background.dart';
import 'package:frontend/values/app_constants.dart';
import 'package:frontend/values/app_string.dart';
import 'package:frontend/values/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  final UsuariosService serviceUsuario;
  const RegisterScreen({super.key, required this.serviceUsuario});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();
  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);
  final List<String> rol = ['visitante', 'residente'];

  String? selectedRol;

  void initializeControllers() {
    _nombresController.addListener(controllerListener);
    _apellidosController.addListener(controllerListener);
    _cedulaController.addListener(controllerListener);
    _passwordController.addListener(controllerListener);
    selectedRol = null;
  }

  void disposeControllers() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _cedulaController.dispose();
    _passwordController.dispose();
    selectedRol = null;
  }

  void controllerListener() {
    final nombres = _nombresController.text;
    final apellidos = _apellidosController.text;
    final cedula = _cedulaController.text;
    final password = _passwordController.text;
    final SelectedRol = selectedRol;

    if (nombres.isEmpty ||
        apellidos.isEmpty ||
        cedula.isEmpty ||
        password.isEmpty ||
        (SelectedRol == null || SelectedRol.isEmpty)) return;

    if (nombres.isNotEmpty &&
        apellidos.isNotEmpty &&
        AppConstants.cedulaRegex.hasMatch(cedula) &&
        password.isNotEmpty &&
        selectedRol != null) {
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
    return Scaffold(
      body: ListView(
        children: [
          const GradientBackground(
            children: [
              Text(AppStrings.register, style: AppTheme.titleLarge),
              SizedBox(height: 6),
              Text(AppStrings.createYourAccount, style: AppTheme.bodySmall),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DropdownButtonFormField<String>(
                    padding: const EdgeInsets.only(bottom: 20),
                    hint: const Text('Rol'),
                    value: selectedRol,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRol = newValue;
                      });
                    },
                    items: rol.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) {
                      return value!.isEmpty ? AppStrings.pleaseSelectRol : null;
                    },
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  AppTextFormField(
                    controller: _nombresController,
                    labelText: AppStrings.name,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseEnterName
                          : value.length < 4
                              ? AppStrings.invalidName
                              : null;
                    },
                  ),
                  AppTextFormField(
                    controller: _apellidosController,
                    labelText: AppStrings.lastName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseEnterLastName
                          : value.length < 4
                              ? AppStrings.invalidLastName
                              : null;
                    },
                  ),
                  AppTextFormField(
                    controller: _cedulaController,
                    labelText: AppStrings.cedula,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseEnterCedula
                          : AppConstants.cedulaRegex.hasMatch(value)
                              ? null
                              : AppStrings.onlyNumbersAndMax10Digits;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)
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
                        onChanged: (value) => _formKey.currentState?.validate(),
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
                                await FormSubmitHandler.registerSubmit(
                                  context: context,
                                  nombresController: _nombresController,
                                  apellidosController: _apellidosController,
                                  cedulaController: _cedulaController,
                                  passwordController: _passwordController,
                                  serviceUsuario: widget.serviceUsuario,
                                  selectedRol: selectedRol,
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
                        child: const Text(AppStrings.register),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.iHaveAnAccount,
                  style: AppTheme.bodySmall.copyWith(color: Colors.black)),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.lightGreen.shade900,
                ),
                child: const Text(AppStrings.login),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
