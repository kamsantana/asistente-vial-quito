import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_notifier.dart';
import 'home_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Clave global para las validaciones del formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para capturar lo que escribe el usuario
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

      // Enviamos 'context' como primer parámetro
      await authNotifier.login(
        context,
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Evaluamos el resultado del estado
      if (mounted) {
        if (authNotifier.status == AuthStatus.authenticated) {
          // Si es correcto, saltamos al Dashboard (HomeView) y limpiamos el historial
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        } else if (authNotifier.status == AuthStatus.error) {
          // Si falla, mostramos el error original del servidor o caso de uso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authNotifier.errorMessage ?? 'Error desconocido'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F3077); // Azul Quito
    const accentColor = Color(0xFFE30613); // Rojo Quito

    // Escuchamos el estado del AuthNotifier para redibujar el botón de carga
    final authStatus = context.watch<AuthNotifier>().status;
    final isLoading = authStatus == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono del Sistema Vehicular
                  const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 80,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // Títulos
                  const Text(
                    "Control Vehicular",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Text(
                    "Inicia sesión para continuar",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Input de Correo Electrónico
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      hintText: 'javier@quito.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: primaryColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu correo';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Input de Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: primaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // 🛠️ BOTÓN CORREGIDO: Enuelto en Center y SizedBox para limitar su tamaño horizontal
                  Center(
                    child: SizedBox(
                      width:
                          300, // Ancho fijo perfecto para cualquier smartphone
                      height: 50, // Altura estándar ergonómica
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'INGRESAR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Enlace para ir al Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes una cuenta? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterView(),
                            ),
                          );
                        },
                        child: const Text(
                          "Regístrate aquí",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
