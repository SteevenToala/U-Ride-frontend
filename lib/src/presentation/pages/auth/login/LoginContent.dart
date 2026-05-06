import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/login/bloc/LoginBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/login/bloc/LoginEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/login/bloc/LoginState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultButton.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextField.dart';

class LoginContent extends StatelessWidget {
  final LoginState state;
  LoginContent(this.state);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.formKey,
      child: Container(
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
          Icon(Icons.directions_car_filled_rounded, size: 80, color: Color(0xFF00B4D8)),
          SizedBox(height: 15),
          Text(
            'U-RIDE',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          Text(
            'Transporte Académico Compartido',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 1
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
            _loginRegisterToggle(context),
            SizedBox(height: 30),
            _textLabel('Correo Electrónico'),
            DefaultTextField(
              onChanged: (text) {
                context.read<LoginBloc>().add(EmailChanged(email: BlocFormItem(value: text)));
              },
              validator: (value) => state.email.error,
              text: 'ejemplo@uta.edu.ec', 
              icon: Icons.alternate_email_rounded,
            ),
            SizedBox(height: 20),
            _textLabel('Contraseña'),
            DefaultTextField(
              onChanged: (text) {
                context.read<LoginBloc>().add(PasswordChanged(password: BlocFormItem(value: text)));
              },
              validator: (value) => state.password.error,
              obscureText: state.isPasswordVisible,
              suffixIcon: IconButton(
                onPressed: () {
                  context.read<LoginBloc>().add(TogglePasswordVisibility());
                },
                icon: Icon(
                  state.isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Color(0xFF00B4D8),
                ),
              ),
              text: 'Tu contraseña', 
              icon: Icons.lock_open_rounded,
            ),
            SizedBox(height: 10),
            _textForgotPassword(context),
            SizedBox(height: 40),
            DefaultButton(
              text: 'ENTRAR',
              onPressed: () {
                if (state.formKey!.currentState!.validate()) {
                  context.read<LoginBloc>().add(FormSubmit());
                }
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _loginRegisterToggle(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingreso', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Container(height: 4, width: 40, color: Color(0xFF00B4D8), margin: EdgeInsets.only(top: 4)),
          ],
        ),
        SizedBox(width: 30),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, 'register'),
          child: Text('Registro', style: TextStyle(color: Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _textLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }



  Widget _textForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, 'forgot_password'),
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}