import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultButton.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextField.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextFieldOutlined.dart';

class RegisterContent extends StatelessWidget {

  RegisterState state;

  static const Map<String, List<String>> _facultadCarreras = {
    'Facultad de Ingenieria en Sistemas, Electronica e Industrial': [
      'Software',
      'Tecnologias de la Informacion',
      'Telecomunicaciones',
      'Ingenieria Industrial',
      'Automatizacion y Robotica'
    ],
    'Facultad de Ingenieria Civil y Mecanica': [
      'Ingenieria Civil',
      'Mecanica'
    ],
    'Facultad de Ciencias Administrativas': [
      'Administracion de Empresas',
      'Mercadotecnia',
      'Marketing Digital'
    ],
    'Facultad de Contabilidad y Auditoria': [
      'Contabilidad y Auditoria',
      'Economia',
      'Auditoria y Gestion Financiera'
    ],
    'Facultad de Ciencias de la Salud': [
      'Medicina',
      'Enfermeria',
      'Fisioterapia',
      'Laboratorio Clinico',
      'Nutricion y Dietetica',
      'Psicologia Clinica'
    ],
    'Facultad de Diseno y Arquitectura': [
      'Arquitectura',
      'Diseno Grafico',
      'Diseno Industrial',
      'Diseno Textil e Indumentaria'
    ],
    'Facultad de Ciencia e Ingenieria en Alimentos y Biotecnologia': [
      'Alimentos',
      'Biotecnologia'
    ],
    'Facultad de Ciencias Agropecuarias': [
      'Agronomia',
      'Medicina Veterinaria'
    ],
    'Facultad de Jurisprudencia y Ciencias Sociales': [
      'Derecho',
      'Trabajo Social',
      'Comunicacion'
    ],
    'Facultad de Ciencias Humanas y de la Educacion': [
      'Educacion Basica',
      'Educacion Inicial',
      'Psicopedagogia',
      'Turismo',
      'Hospitalidad y Hosteria',
      'Pedagogia de los Idiomas Nacionales y Extranjeros',
      'Pedagogia de la Actividad Fisica y el Deporte',
      'Pedagogia de la Lengua y Literatura',
      'Pedagogia de la Historia y Ciencias Sociales'
    ]
  };

  RegisterContent(this.state);

  @override
  Widget build(BuildContext context) {
    final facultades = _facultadCarreras.keys.toList();
    final carreras = state.selectedFacultad == null
        ? <String>[]
        : (_facultadCarreras[state.selectedFacultad] ?? <String>[]);

    return Form(
      key: state.formKey,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(255, 12, 38, 145),
                  Color.fromARGB(255, 34, 156, 249),
                ]
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // HORIZONTAL
              mainAxisAlignment: MainAxisAlignment.center, // VERTICAL
              children: [
                _textLoginRotated(context),
                SizedBox(height: 100),
                _textRegisterRotated(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 60, bottom: 35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                bottomLeft: Radius.circular(35)
              ),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: const [
                  Color.fromARGB(255, 14, 29, 106),
                  Color.fromARGB(255, 30, 112, 227),
                ]
              )
            ),
            child: Stack(
              children: [
                _imageBackground(context),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _imageBanner(),
                      DefaultTextFieldOutlined(
                        text: 'Nombre', 
                        icon: Icons.person_outline,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 50),
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(NameChanged(name: BlocFormItem(value: text)));
                        },
                        validator: (value) {
                          return state.name.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        text: 'Apellido', 
                        icon: Icons.person_2_outlined,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(LastnameChanged(lastname: BlocFormItem(value: text)));
                        },
                        validator: (value) {
                          return state.lastname.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        text: 'Email', 
                        icon: Icons.email_outlined,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(EmailChanged(email: BlocFormItem(value: text)));
                        },
                        validator: (value) {
                          return state.email.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        text: 'Telefono', 
                        icon: Icons.phone_outlined,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(PhoneChanged(phone: BlocFormItem(value: text)));
                        },
                        validator: (value) {
                          return state.phone.error;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        child: DropdownButtonFormField<String>(
                          value: state.selectedFacultad,
                          items: facultades
                              .map(
                                (facultad) => DropdownMenuItem<String>(
                                  value: facultad,
                                  child: Text(
                                    facultad,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            context.read<RegisterBloc>().add(FacultadChanged(facultad: value));
                          },
                          validator: (_) {
                            if (state.selectedFacultad == null || state.selectedFacultad!.isEmpty) {
                              return 'Selecciona una facultad';
                            }
                            return null;
                          },
                          iconEnabledColor: Colors.white,
                          dropdownColor: Color.fromARGB(255, 14, 29, 106),
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Facultad',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.account_balance_outlined, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        child: DropdownButtonFormField<String>(
                          value: state.career.value.isEmpty ? null : state.career.value,
                          items: carreras
                              .map(
                                (carrera) => DropdownMenuItem<String>(
                                  value: carrera,
                                  child: Text(
                                    carrera,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: carreras.isEmpty
                              ? null
                              : (value) {
                                  context.read<RegisterBloc>().add(
                                    CareerChanged(career: BlocFormItem(value: value ?? ''))
                                  );
                                },
                          validator: (_) {
                            if (state.career.value.isEmpty) {
                              return 'Selecciona tu carrera';
                            }
                            return null;
                          },
                          iconEnabledColor: Colors.white,
                          dropdownColor: Color.fromARGB(255, 14, 29, 106),
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Carrera',
                            labelStyle: TextStyle(color: Colors.white),
                            hintText: carreras.isEmpty ? 'Selecciona una facultad' : null,
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.school_outlined, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      DefaultTextFieldOutlined(
                        text: 'Zona de residencia (ej. Conocoto)', 
                        icon: Icons.map_outlined,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(ReferenceZoneChanged(referenceZone: BlocFormItem(value: text)));
                        },
                        validator: (value) {
                          return state.referenceZone.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        text: 'Password', 
                        icon: Icons.lock_outlined,
                        obscureText: state.isPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            context.read<RegisterBloc>().add(TogglePasswordVisibility());
                          },
                          icon: Icon(
                            state.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(PasswordChanged(password: BlocFormItem(value: text)));
                        },
                        validator: (value) {
                          return state.password.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        text: 'Confirmar Password', 
                        icon: Icons.lock_outlined,
                        obscureText: state.isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            context.read<RegisterBloc>().add(ToggleConfirmPasswordVisibility());
                          },
                          icon: Icon(
                            state.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(ConfirmPasswordChanged(confirmPassword: BlocFormItem(value: text)));
                        },
                        validator: (value) {
                          return state.confirmPassword.error;
                        },
                      ),
                      DefaultButton(
                        onPressed: () {
                          if (state.formKey!.currentState!.validate()) {
                            context.read<RegisterBloc>().add(FormSubmit());
                            context.read<RegisterBloc>().add(FormReset());
                          }
                        },
                        text: 'Crear usuario',
                        margin: EdgeInsets.only(top: 30 ,left: 60 ,right: 60),
                      ),
                      SizedBox(height: 25),
                      _separatorOr(),
                       SizedBox(height: 10),
                      _textIAlreadyHaveAccount(context)
                    ],
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _imageBackground(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(bottom: 50),
      child: Image.asset(
        'assets/img/destination.png',
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.4,
        opacity: AlwaysStoppedAnimation(0.3),
      ),
    );
  }

  Widget _textIAlreadyHaveAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ya tienes cuenta?',
          style: TextStyle(
            color: Colors.grey[100],
            fontSize: 16
          ),
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            'Inicia sesion',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          ),
        ),
      ],
    );
  }

  Widget _separatorOr() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 25,
          height: 1,
          color: Colors.white,
          margin: EdgeInsets.only(right: 5),
        ),
        Text(
          'O',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17
          ),
        ),
         Container(
          width: 25,
          height: 1,
          color: Colors.white,
          margin: EdgeInsets.only(left: 5),
        ),
      ],
    );
  }

  Widget _imageBanner() {
    return Container(
      margin: EdgeInsets.only(top: 60),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/img/trip.png',
        width: 180,
        height: 180,
      ),
    );
  }

  Widget _textRegisterRotated() {
    return RotatedBox(
      quarterTurns: 1,
      child: Text(
        'Registro',
        style: TextStyle(
          fontSize: 27,
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _textLoginRotated(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: RotatedBox(
        quarterTurns: 1,
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

}