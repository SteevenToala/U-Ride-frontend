import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/injection.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultButton.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextField.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String email = "";
  bool isLoading = false;
  AuthUseCases authUseCases = locator<AuthUseCases>();

  void _sendEmail() async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un correo electrónico'))
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    Resource<bool> response = await authUseCases.forgotPassword.run(email);

    if (!mounted) return;

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response is Success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se han enviado las instrucciones de recuperación si el correo existe.'))
      );
      Navigator.pop(context);
    } else if (response is ErrorData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((response as ErrorData).message))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 12, 38, 145),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 12, 38, 145),
              Color.fromARGB(255, 34, 156, 249),
            ]
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40, left: 30, right: 30),
                child: const Text(
                  'Ingresa tu correo para recuperar tu contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 40, left: 25, right: 25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15)
                ),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    DefaultTextField(
                      text: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      onChanged: (text) {
                        setState(() {
                          email = text;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    isLoading 
                      ? const CircularProgressIndicator() 
                      : DefaultButton(
                          text: 'ENVIAR ENLACE',
                          onPressed: () {
                            _sendEmail();
                          },
                        )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}