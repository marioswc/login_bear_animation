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
  // 1.1 variable para controlar el estado de la animación
    StateMachineController? _controller;
    // SMI: 
    SMIBool? _isChecking;
    SMIBool? _isHandsUp;
    SMITrigger? _trigSuccess;
    SMITrigger? _trigFail;
    // 1.1 variables parapaara controlar el estado de la animación FocusNode
    final _emailFocus = FocusNode();
    final _passwordFocus = FocusNode();

    // 2.2 Listener para el cosu (chismoso)
    @override
    void initState() {
      super.initState();
      _emailFocus.addListener(() {

        if (_emailFocus.hasFocus){
          // verificamos que no sea nulo
          if (_isHandsUp != null){
            // manos abajo al ver email
            _isHandsUp?.change(false);
          }
        }
      });
      _passwordFocus.addListener(() {
        // manos hacia arriba al ver contraseña
        _isHandsUp?.change(_passwordFocus.hasFocus);
      });
    }

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
                child: RiveAnimation.asset('assets/oso.riv', 
                stateMachines: ['Login Machine'],

                // 1.2 agregamos animacion
                onInit: (artboard){
                  _controller = StateMachineController.fromArtboard(artboard, 
                  'Login Machine');

                  // 1.3 Verificar que inció correctamente el controlador
                  if(_controller == null) return;
                  // agregamos el controlador al escenario
                  artboard.addController(_controller!);
                  // vinculamos variables
                  _isChecking = _controller!.findSMI('isChecking');
                  _isHandsUp = _controller!.findSMI('isHandsUp');
                  _trigSuccess = _controller!.findSMI('trigSuccess');
                  _trigFail = _controller!.findSMI('trigFail');
                },),
              ),
              // sirve para separar espacio de alto
              SizedBox(height: 12),
              // Emai TextField
              TextField(
                // 2.3 asignar foco al campo de email
                focusNode: _emailFocus,
                onChanged: (value){
                  if (_isHandsUp != null){
                    // no tapes los ojos al ver email
                    // _isHandsUp!.change(false);
                  }

                  // si isChecking es nulo
                  if (_isChecking == null) return;
                  // activamos el modo chismoso
                  _isChecking!.change(true);
                },
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
                // 2.3 asignar foco al campo de contraseña
                focusNode: _passwordFocus,
                onChanged: (value){
                  if (_isHandsUp != null){
                    // no tapes los ojos al ver email
                    // _isHandsUp!.change(false);
                  }

                  // si isChecking es nulo
                  if (_isHandsUp == null) return;
                  // activamos el modo chismoso
                  _isHandsUp!.change(true);
                },
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
  // 2.4 liberamos espacio de la memoria
  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}