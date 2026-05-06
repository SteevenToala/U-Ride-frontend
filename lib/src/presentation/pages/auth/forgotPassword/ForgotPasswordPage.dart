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
  final AuthUseCases authUseCases = locator<AuthUseCases>();

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

    try {
      // Método de nuestro propio Backend (NestJS + Nodemailer)
      final response = await authUseCases.forgotPassword.run(email.trim().toLowerCase());
      
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (response is Success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se te ha enviado un código de recuperación. Revisa tu correo.'))
        );
        // Navegar a la página de validación de código
        Navigator.pushNamed(context, 'reset_password', arguments: email.trim().toLowerCase());
      } else if (response is ErrorData) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${(response as ErrorData).message}'))
        );
      }

    } catch (e) {
      if (!mounted) return;
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(context),
              _card(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 80, bottom: 40),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Icon(Icons.lock_reset_rounded, size: 80, color: Color(0xFF00B4D8)),
          SizedBox(height: 15),
          Text(
            'RECUPERACIÓN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'Ingresa tu correo para recibir un código de recuperación.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 40 : 25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textLabel('Correo Electrónico'),
            DefaultTextField(
              onChanged: (text) {
                setState(() { email = text; });
              },
              text: 'ejemplo@uta.edu.ec', 
              icon: Icons.alternate_email_rounded,
            ),
            SizedBox(height: 40),
            isLoading 
              ? Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8))) 
              : DefaultButton(
                  text: 'ENVIAR ENLACE',
                  color: Color(0xFF00B4D8),
                  onPressed: () => _sendEmail(),
                ),
          ],
        ),
      ),
    );
  }

  Widget _textLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }
}