import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // variable para ocultar/mostrar la contraseña
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset('assets/oso.riv',),
              ),
              // sirve para separar espacio de alto
              SizedBox(height: 12),
              // Emai TextField
              TextField(
                // mejoramos el tipo de teclado
                keyboardType: TextInputType.emailAddress, 
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    ),
                ) 
                ),
                SizedBox(height: 12),
              // Contraseña TextField 
              TextField(
                obscureText: _obscure,
                // para teclado de contraseña
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off
                  ), onPressed: (){
                    // cambiamos el estado de la variable _obscure
                    setState(() {
                      _obscure = !_obscure;
                    });
                  }),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6)
                    ),
                  
                ) 
                ),
            ]
          ),
          ),
      ),
    );
  }
}