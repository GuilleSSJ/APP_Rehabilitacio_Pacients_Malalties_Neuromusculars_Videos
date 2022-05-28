import 'package:app_video_rehabilitacio_neuromuscular/providers/auth_provider.dart';
import 'package:app_video_rehabilitacio_neuromuscular/services/database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'principal.dart';


class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
// Create a text controller. Later, use it to retrieve the
  // current value of the TextField.
  final _emailController = TextEditingController();
  final _passwdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _validEmail = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  late AuthProvider authProvider;
  
  static Future<bool> login({required String nhc, required BuildContext context}) async {
    var blnRet;
    try{
      DataBaseService dataBaseService = new DataBaseService();
      blnRet = dataBaseService.loginWithNHC(nhc);
    } on Exception catch (e) {
        print("No s'ha trobat cap usuari amb aquest NHC." + "Error: " + e.toString());
      }
    return blnRet;
  }


  @override
  void initState() {
    authProvider = context.read<AuthProvider>();
    super.initState();
  }

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
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
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
                controller: _passwdController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Contrasenya',
                    hintText: "Introdueix la teva contrasenya"
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
                onPressed: () async {/*
                  if (_formKey.currentState!.validate()) {
                  bool isSuccess = await authProvider.handleSignIn();
                  if (isSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PagePrincipal(),
                      ),
                    );
                  }
                 }*/
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
          ],
        ),
      ),
      ),
    );
  }
}