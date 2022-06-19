import 'package:app_video_rehabilitacio_neuromuscular/models/models.dart';
import 'package:app_video_rehabilitacio_neuromuscular/principal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/app_constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/color_constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _validEmail = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  late AuthProvider authProvider;
  bool _isObscure = true;

   @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _emailController.dispose();
    _passwdController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    String valueString = value as String;
    if (valueString.isEmpty) {
      return "* Camp Requerit";
    } else if (!_validEmail.hasMatch(valueString)) {
      return "Introdueix un correu vàlid";
    } else
      return null;
  }

    String? validatePassword(String? value) {
    String valueString = value as String;
    if (valueString.isEmpty) {
      return "* Camp Requerit";
    } else if (valueString.length < 6) {
      return "La contrasenya ha de tenir almenys 6 caràcters";
    } else
      return null;
  }


  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Error en l'autenticació");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Email o paraula clau incorrectes");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Has iniciat sessió amb èxit");
        break;
      default:
        break;
    }
     return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 60),
              child: Center(
                child: Container(
                    width: 200,
                    height: 150,
                    child: Image.asset('images/stPau_logo.jpg'),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 20),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Correu Electrònic',
                    hintText: "Introdueix l'adreça del teu email"
                    ),
                validator: validateEmail,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 20),
              child: TextFormField(
                obscureText: _isObscure,
                controller: _passwdController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Contrasenya',
                    hintText: "Introdueix la teva contrasenya",
                    suffixIcon: IconButton(
                          icon: Icon(_isObscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          }),
                    ),
                validator: validatePassword,
              ),
            ),
            SizedBox(
              height: 110,
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.orange, borderRadius: BorderRadius.circular(20)),
              child: FlatButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                  bool isSuccess = await authProvider.handleSignIn(_emailController.text, _passwdController.text);
                  if (isSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PagePrincipal(),
                      ),
                    );
                  }
                 }
                },
                
                child: Text(
                  'Iniciar Sessió',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            /*SizedBox(
              height: 110,
            ),
            FlatButton(
              onPressed: (){
                 Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => RegisterForm(),
                              ),
                 );
              },
              child: Text(
                'Nuevo Usuario? Regístrate gratis.',
                style: TextStyle(color: Colors.orange, fontSize: 15),
              ),
            ),*/
               // Loading
            Positioned(
              child: authProvider.status == Status.authenticating ? LoadingView() : SizedBox.shrink(),
            ),

          ],
        ),
      ),
      ),
    );
  }
}
        