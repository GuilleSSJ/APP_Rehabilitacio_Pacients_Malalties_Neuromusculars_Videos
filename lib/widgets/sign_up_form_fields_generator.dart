import 'package:app_video_rehabilitacio_neuromuscular/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpFormFieldsGenerator {
  late AuthProvider loginController;

  _selectDate(BuildContext context, TextEditingController dateController,
      DateTime selectedDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale("es", "ES"),
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      var date =
          "${picked.toLocal().day}/${picked.toLocal().month}/${picked.toLocal().year}";
      dateController.text = date;
    }
  }

  getNameField(TextEditingController nameEditingController) {
    return TextFormField(
      autofocus: false,
      controller: nameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Camp obligatori *");
        }
        if (!regex.hasMatch(value)) {
          return ("Introdueix un nom vàlid (mín. 3 caràcters)");
        }
        return null;
      },
      onSaved: (value) {
        nameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Nom",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  getSurnameField(TextEditingController surnameEditingController) {
    return TextFormField(
      autofocus: false,
      controller: surnameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Camp obligatori *");
        }
        return null;
      },
      onSaved: (value) {
        surnameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Cognoms",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  getDate(BuildContext context, TextEditingController dateEditingController,
      DateTime selectedDate) {
    return TextFormField(
        controller: dateEditingController,
        decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_today),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Data de naixement",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onTap: () => _selectDate(context, dateEditingController, selectedDate),
        validator: (value) {
          if (value!.isEmpty) return "Camp obligatori *";
          return null;
        },
      );
  }

  getNHCField(TextEditingController nhcEditingController) {
    return TextFormField(
      autofocus: false,
      controller: nhcEditingController,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Camp obligatori *");
        } else if (!RegExp("^[A-Z]{4}[0-9]{12}").hasMatch(value)) {
          return ("Introdueix un número d'història clínic vàlid");
        } else {
          return null;
        }
      },
      onSaved: (value) {
        nhcEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.card_membership),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "NHC",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  getEmailField(TextEditingController emailEditingController) {
    return TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Introdueix el teu correu");
        }
        // reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Introdueix un email vàlid");
        }
        return null;
      },
      onSaved: (value) {
        emailEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Correu Electrònic",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  getPasswordField(TextEditingController passwordEditingController) {
    return TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Camp obligatori *");
        }
        if (!regex.hasMatch(value)) {
          return ("Introdueix una contrasenya vàlida (mín. 6 characters)");
        }
        return null;
      },
      onSaved: (value) {
        passwordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Contrasenya",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  getConfirmPasswordField(
      TextEditingController confirmPasswordEditingController,
      TextEditingController passwordEditingController) {
    return TextFormField(
      autofocus: false,
      controller: confirmPasswordEditingController,
      obscureText: true,
      validator: (value) {
        if (confirmPasswordEditingController.text !=
            passwordEditingController.text) {
          return "Les contrasenyes no coincideixen";
        }
        return null;
      },
      onSaved: (value) {
        confirmPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Confirma la contrasenya",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  getSignUpButton(
      BuildContext context,
      GlobalKey<FormState> formkey,
      TextEditingController email,
      TextEditingController password,
      TextEditingController firstName,
      TextEditingController secondName,
      TextEditingController nhc,
      TextEditingController date) {
      loginController = context.read<AuthProvider>();
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      color: Colors.orange,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          if (formkey.currentState!.validate()) {
          loginController.signUp(
              context, formkey, email, password, firstName, secondName, nhc, date);
          Navigator.of(context).pop();
        }
        },
        child: const Text(
          "Registrar Pacient",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
