// ignore_for_file: deprecated_member_use

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:application_library/ui/authentication/logic/validaciones_login.dart';
import 'package:application_library/ui/core/routes/app_router.gr.dart';
import 'package:application_library/ui/core/widgets/campo_formulario_login.dart';
import 'package:application_library/data/services/autenticacion_servicio_login.dart';

@RoutePage()
class PantallaInicioSesion extends StatefulWidget {
  static const String nombreRuta = '/login';

  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _EstadoPantallaInicioSesion();
}

class _EstadoPantallaInicioSesion extends State<PantallaInicioSesion> {
  final Map<String, String> datosFormulario = {};
  final estadoFormulario = GlobalKey<FormState>();
  bool mostrarContrasena = false;
  bool _isLoading = false;

  Future<void> _iniciarSesion(BuildContext context) async {
    if (estadoFormulario.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final resultado = await AuthService.login(
          datosFormulario['email'] ?? '',
          datosFormulario['password'] ?? '',
        );

        if (resultado['success'] == true) {
          if (context.mounted) {
            AutoRouter.of(context).push(const RoutePrincipal());
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resultado['message'] ?? 'Error en el login'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } finally {
        if (context.mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.network(
              'https://lh3.googleusercontent.com/gps-cs-s/AG0ilSzdW0wkw_MyJgM6YSteaJkafg6LiQ69zcIiReNuNcOlT_TpSbg8x-Sv1--iEAx3Ijv-7uXQ0Z0R0BdqavyPGa_w5lZhvjKYlQU0_c4Vz8ccK9y3CWuHYBrKen5uaSE4luNMWO_Q=w408-h306-k-no',
              fit: BoxFit.cover,
            ),
          ),

          Container(color: Colors.white.withOpacity(0.85)),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          Column(
            children: [
              Container(
                width: double.infinity,
                height: 60,
                color: const Color(0xFF003366).withOpacity(0.85),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Librería El Estudiante',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: estadoFormulario,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: Text(
                              'Inicio de Sesión',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          CampoEntradaRedondeado(
                            placeholder: "Ingrese su correo electrónico",
                            alCambiar: (valor) => datosFormulario['email'] = valor,
                            validador: ValidadorDeInicioSesion.validarCorreo, 
                            icono: IconButton(
                              icon: const Icon(Icons.email, color: Color(0xFF003366)),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(height: 15),

                          CampoEntradaRedondeado(
                            placeholder: "Ingresa tu contraseña",
                            esContrasena: !mostrarContrasena,
                            alCambiar: (valor) => datosFormulario['password'] = valor,
                            validador: ValidadorDeInicioSesion.validarContrasena,
                            icono: IconButton(
                              icon: Icon(
                                mostrarContrasena ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF003366),
                              ),
                              onPressed: () {
                                setState(() {
                                  mostrarContrasena = !mostrarContrasena;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _iniciarSesion(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Iniciar sesión'),
                            ),
                          ),
                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "¿No tienes una cuenta?",
                                style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                              ),
                              const SizedBox(width: 5),
                              InkWell(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                        AutoRouter.of(context).push(const RouteRegistro());
                                      },
                                child: Text(
                                  'Regístrate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isLoading ? Colors.grey : Colors.blueAccent,
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
              )
            ],
          ),
        ],
      ),
    );
  }
}