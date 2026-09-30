import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; // 3.1 importar el timer

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

    // 3.2 variable para controlar el recorrido de la mirada
    SMINumber? _numLook;
    // 3.3 Timer para detner la mirada al dejar de escribir
    Timer? _typingDebounce;

    // 2.1 variables parapaara controlar el estado de la animación FocusNode
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
            // 3.4 si el usuario deja de escribir, detenemos la mirada
            _numLook?.value = 50.0;
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
                  // 3.5 vinculamos la variable de mirada
                  _numLook = _controller!.findSMI('numLook');
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
                  // 3.6 implementamos el numLook
                  // ajustes de 0 a 100 izq - der
                  // 80 es la medida de calibracion
                  final look = (value.length / 40.0 * 100).clamp(0.0, 100.0); //clamp abrazadera para ajustar el rango de valores
                  _numLook?.value = look;
                  // 3.7 Debouce si vuelve a escribir, reiniciamos el timer
                  // si el timer no es nulo, lo cancelamos
                  _typingDebounce?.cancel();
                  // iniciamos un nuevo timer de 3 segundo
                  _typingDebounce = Timer(const Duration(seconds: 3), (){
                    // si se cierra la pantalla quitamos el contador
                    if (!mounted) return;
                    // si el usuario deja de escribir, detenemos la mirada
                    _isChecking?.change(false);
                  });

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
    _typingDebounce?.cancel(); // 3.8 cancelamos el timer si no es nulo
    super.dispose();
  }
}