import 'package:app_video_rehabilitacio_neuromuscular/widgets/sign_up_form_fields_generator.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();

  final nameEditingController = TextEditingController();
  final surnameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  final nhcEditingController = TextEditingController();
  final dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  final SignUpFormFieldsGenerator _textFormFieldGenerator =
      SignUpFormFieldsGenerator();

  @override
  Widget build(BuildContext context) {
    final nameField =
        _textFormFieldGenerator.getNameField(nameEditingController);

    final surnameField =
        _textFormFieldGenerator.getSurnameField(surnameEditingController);

    final emailField =
        _textFormFieldGenerator.getEmailField(emailEditingController);

    final passwordField =
        _textFormFieldGenerator.getPasswordField(passwordEditingController);

    final confirmPasswordField =
        _textFormFieldGenerator.getConfirmPasswordField(
            confirmPasswordEditingController, passwordEditingController);

    final nhcField =
        _textFormFieldGenerator.getNHCField(nhcEditingController);

    final dateField =
        _textFormFieldGenerator.getDate(context, dateController, selectedDate);

    final signUpButton = _textFormFieldGenerator.getSignUpButton(
        context,
        formKey,
        emailEditingController,
        passwordEditingController,
        nameEditingController,
        surnameEditingController,
        nhcEditingController,
        dateController);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Registrar Nou Pacient',
          style: TextStyle(fontSize: 16.0, fontFamily: 'Glacial Indifference'),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 120,
                      child: Image.asset(
                        "images/logoNVR.jpeg",
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    nameField,
                    const SizedBox(height: 10),
                    surnameField,
                    const SizedBox(height: 10),
                    dateField,
                    const SizedBox(height: 10),
                    nhcField,
                    const SizedBox(height: 10),
                    emailField,
                    const SizedBox(height: 10),
                    passwordField,
                    const SizedBox(height: 10),
                    confirmPasswordField,
                    const SizedBox(height: 10),
                    signUpButton,
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
