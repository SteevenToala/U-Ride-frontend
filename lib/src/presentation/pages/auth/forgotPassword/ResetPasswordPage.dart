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
  bool isPasswordVisible = true;
  bool isConfirmPasswordVisible = true;
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
      padding: EdgeInsets.only(top: 60, bottom: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Icon(Icons.mark_email_read_rounded, size: 70, color: Color(0xFF00B4D8)),
          SizedBox(height: 15),
          Text(
            'RESTABLECER',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'Ingresa el código enviado a $email y tu nueva contraseña.',
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
        margin: EdgeInsets.only(left: 25, right: 25, bottom: 40),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 40 : 25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textLabel('Código de 6 dígitos'),
            DefaultTextField(
              onChanged: (text) { setState(() { code = text; }); },
              text: '123456', 
              icon: Icons.numbers_rounded,
            ),
            SizedBox(height: 20),
            _textLabel('Nueva Contraseña'),
            DefaultTextField(
              onChanged: (text) { setState(() { newPassword = text; }); },
              obscureText: isPasswordVisible,
              suffixIcon: IconButton(
                onPressed: () => setState(() { isPasswordVisible = !isPasswordVisible; }),
                icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Color(0xFF00B4D8)),
              ),
              text: 'Mínimo 6 caracteres', 
              icon: Icons.lock_outline_rounded,
            ),
            SizedBox(height: 20),
            _textLabel('Confirmar Contraseña'),
            DefaultTextField(
              onChanged: (text) { setState(() { confirmPassword = text; }); },
              obscureText: isConfirmPasswordVisible,
              suffixIcon: IconButton(
                onPressed: () => setState(() { isConfirmPasswordVisible = !isConfirmPasswordVisible; }),
                icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Color(0xFF00B4D8)),
              ),
              text: 'Repite tu contraseña', 
              icon: Icons.lock_reset_rounded,
            ),
            SizedBox(height: 40),
            isLoading 
              ? Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8))) 
              : DefaultButton(
                  text: 'CAMBIAR CONTRASEÑA',
                  color: Color(0xFF00B4D8),
                  onPressed: () => _resetPassword(),
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
