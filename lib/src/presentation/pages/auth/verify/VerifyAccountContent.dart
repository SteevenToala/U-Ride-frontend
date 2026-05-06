import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/bloc/VerifyAccountBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/bloc/VerifyAccountEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/bloc/VerifyAccountState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultButton.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextField.dart';

class VerifyAccountContent extends StatelessWidget {
  final VerifyAccountState state;

  const VerifyAccountContent(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.mark_email_read_rounded, size: 80, color: Color(0xFF00B4D8)),
          SizedBox(height: 15),
          Text(
            'VERIFICACIÓN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Hemos enviado un código a ${state.email}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      margin: EdgeInsets.symmetric(horizontal: 25),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Form(
        key: state.formKey,
        child: Column(
          children: [
            Text(
              'Ingresa el código de 6 dígitos',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            DefaultTextField(
              text: 'Código de verificación',
              icon: Icons.vpn_key_rounded,
              onChanged: (text) {
                context.read<VerifyAccountBloc>().add(CodeChanged(code: BlocFormItem(value: text)));
              },
              validator: (value) => state.code.error,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 40),
            DefaultButton(
              text: 'VERIFICAR CUENTA',
              onPressed: () {
                context.read<VerifyAccountBloc>().add(VerifyAccountSubmit());
              },
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false),
              child: Text(
                'VOLVER AL LOGIN',
                style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
