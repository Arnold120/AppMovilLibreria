import 'package:flutter/material.dart';

class CampoEntradaRedondeado extends StatefulWidget {
  final String placeholder; 
  final ValueChanged<String> alCambiar; 
  final String? Function(String?)? validador; 
  final bool esContrasena; 
  final Widget? iconoFinal; 

  const CampoEntradaRedondeado({
    super.key,
    required this.placeholder,
    required this.alCambiar,
    this.validador,
    this.esContrasena = false,
    this.iconoFinal, required IconButton icono,
  });

  @override
  State<CampoEntradaRedondeado> createState() => _EstadoCampoEntradaRedondeado();
}

class _EstadoCampoEntradaRedondeado extends State<CampoEntradaRedondeado> {
  bool mostrarContrasena = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validador,
      onChanged: widget.alCambiar,
      obscureText: widget.esContrasena && !mostrarContrasena,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        hintText: widget.placeholder,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: widget.esContrasena
            ? IconButton(
                icon: Icon(
                  mostrarContrasena ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF003366),
                ),
                onPressed: () => setState(() {
                  mostrarContrasena = !mostrarContrasena;
                }),
              )
            : widget.iconoFinal,
      ),
    );
  }
}
