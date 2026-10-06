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
  // 5.1 variable para controlar el estado del checkbox y el estado de la animación
  bool rememberMe = false;
  bool isAnimating = false;
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

    // 4.1 Controllers para manipular los TextField
    final _emailCtrl = TextEditingController();
    final _passCtrl = TextEditingController();
    //Errores para mostrar en pantalla
    String? emailError;
    String? passError;

    // 4.3 funcion para validar errores
    bool isValidEmail(String email){
      final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      return re.hasMatch(email);
    }

    bool isValidPassword(String password){
      final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',);
      return re.hasMatch(password);
    }

    //5.3 función para escuchar el cambio de estado de la aniamción
    void _onStateChange(String stateMachineName, String stateName){
      // si el estado es idle, desactivamos la animación
      if (stateName == 'idle'){
        setState(() {
          isAnimating = false;
        });
      }
    }

    // 4.4 dar accion
    void _onLogin(){
      // 4.5 quitar espacios en blanco
      final email = _emailCtrl.text.trim();
      final pass = _passCtrl.text;

      // 4.6 sEvauluar errores
      final eError = isValidEmail(email) ? null : 'Invalid email';
      final pError = isValidPassword(pass) ? null : 'Invalid password';

      // 4.7 actualizar estado de errores
      setState(() {
        emailError = eError;
        passError = pError;
      });

      // 4.8 cerrar el teclado y bajar las manos del oso
      FocusScope.of(context).unfocus();
      _typingDebounce?.cancel();
      _isChecking?.change(false);
      _isHandsUp?.change(false);
      _numLook?.value = 50.0;
      // 5.2 si el usuario presiona el boton de login, desactivamos el boton de login para evitar multiples clicks
      setState(() {
        isAnimating = true;
      });
      // 4.9 activar trigger
      if (eError == null && pError == null){
        _trigSuccess?.fire();
      } else {
        _trigFail?.fire();
      }
    }

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
      body: SingleChildScrollView(
        child: SafeArea(
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
                    'Login Machine',
                    // 5.2 agregamos el listener para el estado de la animación
                    onStateChange: _onStateChange,
                    );
        
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
                  // 4.10 asignamos los controladores a los TextField
                  controller: _emailCtrl,
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
                    // 4.11 agregamos el errorText
                    errorText: emailError,
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
                  // 4.10 asignamos los controladores a los TextField
                  controller: _passCtrl,
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
                    // 4.11 agregamos el errorText
                    errorText: passError,
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
                  SizedBox(height: 12),
                  // 4.12 Remember and Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value){
                              setState(() {
                                // 5.5 actualizamos el estado del checkbox
                                rememberMe = value ?? false;
                              });
                            }
                          ),
                          const Text('Remember me')
                        ],
                      ),

                      TextButton(
                        onPressed: (){},
                        child: Text(
                        'Forgot Password?', 
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    ]
                  ),
                  const SizedBox(height: 10),
                  // 4.13 Boton de login
                  MaterialButton(
                    minWidth: size.width,
                    height: 50,
                    color: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)
                    ),
                    onPressed: isAnimating ? null : _onLogin, // 5.4 desactivamos el boton de login si isAnimating es true
                    child: Text(
                      'Login', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 18
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 4.14 Boton de register
                  SizedBox(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: (){}, 
                          child: Text(
                            'Register', 
                            style: TextStyle(
                              color: Colors.black, 
                              decoration: TextDecoration.underline, 
                              fontWeight: FontWeight.bold),
                            )
                          )
                      ],
                    ),
                  )
              ],
            ),
            ),
        ),
      ),
    );
  }
  // 2.4 liberamos espacio de la memoria
  @override
  void dispose() {
    // 4.15 liberamos los controladores de los TextField
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel(); // 3.8 cancelamos el timer si no es nulo
    super.dispose();
  }
}