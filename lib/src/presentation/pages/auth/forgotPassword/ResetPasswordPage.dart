import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/injection.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultButton.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextField.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  String code = "";
  String newPassword = "";
  String confirmPassword = "";
  bool isLoading = false;
  final AuthUseCases authUseCases = locator<AuthUseCases>();
  String email = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recuperamos el email que le mandamos desde la pantalla anterior
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is String) {
      email = arguments;
    }
  }

  void _resetPassword() async {
    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos'))
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden'))
      );
      return;
    }
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código debe tener 6 dígitos'))
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Método de nuestro propio Backend (NestJS -> resetPassword)
      final response = await authUseCases.resetPassword.run(email, code.trim(), newPassword);
      
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (response is Success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Contraseña actualizada correctamente!'))
        );
        
        // Volvemos al Login eliminando todo el historial hasta usar pushNamedAndRemoveUntil
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

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
      appBar: AppBar(
        title: const Text('Restablecer contraseña', style: TextStyle(color: Colors.white)),
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
                child: Text(
                  'Ingresa el código que enviamos a $email y tu nueva contraseña.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
                      text: 'Código de 6 dígitos',
                      icon: Icons.numbers,
                      onChanged: (text) {
                        setState(() {
                          code = text;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    DefaultTextField(
                      text: 'Nueva contraseña',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      onChanged: (text) {
                        setState(() {
                          newPassword = text;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    DefaultTextField(
                      text: 'Confirmar nueva contraseña',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      onChanged: (text) {
                        setState(() {
                          confirmPassword = text;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    isLoading 
                      ? const CircularProgressIndicator() 
                      : DefaultButton(
                          text: 'CAMBIAR CONTRASEÑA',
                          onPressed: () {
                            _resetPassword();
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
