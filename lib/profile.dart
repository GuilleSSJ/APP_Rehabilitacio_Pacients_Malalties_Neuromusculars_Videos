import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/loginForm.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'principal.dart';


class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late TextEditingController _txtControllerNom;
  late TextEditingController _txtControllerTargRef;
  late TextEditingController _txtControllerTelef;
  late AuthProvider authProvider;

  @override
  void initState() {
    authProvider = context.read<AuthProvider>();
    _txtControllerNom = TextEditingController(text: authProvider.getUserFirebaseFullname());
    _txtControllerTargRef = TextEditingController(text: 'Terapeuta1');
    _txtControllerTelef = TextEditingController(text: '935537099');
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: Text(
          'Perfil',
          style: TextStyle(fontSize: 16.0, fontFamily: 'Glacial Indifference'),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 20),
              child: TextField(
                cursorColor: Colors.orange,
                controller: _txtControllerNom,
                readOnly: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Nom d'usuari",
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 20),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                cursorColor: Colors.orange,
                controller: _txtControllerTargRef,
                readOnly: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tarjeta de referència',
                    ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 20),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: _txtControllerTelef,
                readOnly: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Telèfon de contacte',
                    ),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            /*Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.orange, borderRadius: BorderRadius.circular(20)),
              child: FlatButton(
                onPressed: () {
                    Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => LoginForm(),
                              )
                           );
                },
                
                child: Text(
                  'Tancar Sessió',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),*/
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