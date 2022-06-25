import 'package:flutter/material.dart';

class UploadVideo extends StatefulWidget {
  const UploadVideo({Key? key}) : super(key: key);

  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  final _emailController = TextEditingController();
  final _passwdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _validEmail = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 0, bottom: 20),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Correu Electrònic',
                      hintText: "Introdueix l'adreça del teu email"),
                  validator: validateEmail,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 0, bottom: 20),
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
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20)),
                child: FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (true) {
                        /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayPage(
                      arguments: PlayPageArguments(
                        videos: videos
                      ),
                    ),
                  ),
                );*/
                      }
                    }
                  },
                  child: Text(
                    'Iniciar Sessió',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
