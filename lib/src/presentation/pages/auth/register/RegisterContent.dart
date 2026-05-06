import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/GalleryOrPhotoDialog.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultButton.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextFieldOutlined.dart';

class RegisterContent extends StatefulWidget {
  final RegisterState state;
  RegisterContent(this.state);

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  String? _selectedFacultad;
  String? _selectedCarrera;

  // Controllers to ensure 100% data capture
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _selectedFacultad = widget.state.selectedFacultad;
    _selectedCarrera = widget.state.career.value.isEmpty ? null : widget.state.career.value;
    
    // Sync controllers with initial state if any
    _nameController.text = widget.state.name.value;
    _lastnameController.text = widget.state.lastname.value;
    _emailController.text = widget.state.email.value;
    _phoneController.text = widget.state.phone.value;
    _zoneController.text = widget.state.referenceZone.value;
    _passwordController.text = widget.state.password.value;
    _confirmPasswordController.text = widget.state.confirmPassword.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _zoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _syncToBloc() {
    final bloc = context.read<RegisterBloc>();
    bloc.add(NameChanged(name: BlocFormItem(value: _nameController.text)));
    bloc.add(LastnameChanged(lastname: BlocFormItem(value: _lastnameController.text)));
    bloc.add(EmailChanged(email: BlocFormItem(value: _emailController.text)));
    bloc.add(PhoneChanged(phone: BlocFormItem(value: _phoneController.text)));
    bloc.add(ReferenceZoneChanged(referenceZone: BlocFormItem(value: _zoneController.text)));
    bloc.add(PasswordChanged(password: BlocFormItem(value: _passwordController.text)));
    bloc.add(ConfirmPasswordChanged(confirmPassword: BlocFormItem(value: _confirmPasswordController.text)));
  }

  @override
  Widget build(BuildContext context) {
    final facultades = _facultadCarreras.keys.toList();
    final carreras = _selectedFacultad == null
        ? <String>[]
        : (_facultadCarreras[_selectedFacultad] ?? <String>[]);

    return Form(
      key: widget.state.formKey,
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
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisAlignment: MainAxisAlignment.center, 
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
                      _imageUser(context),
                      DefaultTextFieldOutlined(
                        controller: _nameController,
                        text: 'Nombre', 
                        icon: Icons.person_outline,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 50),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa tu nombre';
                          return null;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        controller: _lastnameController,
                        text: 'Apellido', 
                        icon: Icons.person_2_outlined,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa tu apellido';
                          return null;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        controller: _emailController,
                        text: 'Email', 
                        icon: Icons.email_outlined,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa tu email';
                          if (!value.contains('.edu')) return 'Debe ser correo institucional (.edu)';
                          return null;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        controller: _phoneController,
                        text: 'Telefono', 
                        icon: Icons.phone_outlined,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa tu telefono';
                          return null;
                        },
                      ),

                      // FACULTAD DROPDOWN
                      Padding(
                        padding: EdgeInsets.only(left: 50, right: 50, top: 15),
                        child: DropdownButtonFormField<String>(
                          value: _selectedFacultad,
                          validator: (value) => value == null ? 'Selecciona una facultad' : null,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_balance_outlined, color: Colors.white),
                            labelText: 'Facultad',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          ),
                          dropdownColor: Color.fromARGB(255, 14, 29, 106),
                          style: TextStyle(color: Colors.white),
                          items: facultades.map((f) => DropdownMenuItem(value: f, child: Text(f, style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedFacultad = val;
                              _selectedCarrera = null;
                            });
                            context.read<RegisterBloc>().add(FacultadChanged(facultad: val));
                          },
                        ),
                      ),

                      // CARRERA DROPDOWN
                      Padding(
                        padding: EdgeInsets.only(left: 50, right: 50, top: 15),
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_selectedFacultad),
                          value: _selectedCarrera,
                          validator: (value) => value == null ? 'Selecciona una carrera' : null,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.school_outlined, color: Colors.white),
                            labelText: 'Carrera',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          ),
                          dropdownColor: Color.fromARGB(255, 14, 29, 106),
                          style: TextStyle(color: Colors.white),
                          items: carreras.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                             setState(() {
                               _selectedCarrera = val;
                             });
                             context.read<RegisterBloc>().add(CareerChanged(career: BlocFormItem(value: val ?? '')));
                          },
                        ),
                      ),

                      DefaultTextFieldOutlined(
                        controller: _zoneController,
                        text: 'Zona de residencia (ej. Conocoto)', 
                        icon: Icons.map_outlined,
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa tu zona';
                          return null;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        controller: _passwordController,
                        text: 'Password', 
                        icon: Icons.lock_outlined,
                        obscureText: widget.state.isPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            context.read<RegisterBloc>().add(TogglePasswordVisibility());
                          },
                          icon: Icon(
                            widget.state.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        validator: (value) {
                          if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        controller: _confirmPasswordController,
                        text: 'Confirmar Password', 
                        icon: Icons.lock_outlined,
                        obscureText: widget.state.isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            context.read<RegisterBloc>().add(ToggleConfirmPasswordVisibility());
                          },
                          icon: Icon(
                            widget.state.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 50, right: 50, top: 15),
                        validator: (value) {
                          if (value != _passwordController.text) return 'Los passwords no coinciden';
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 15),

                      DefaultButton(
                        onPressed: () {
                          if (widget.state.formKey!.currentState!.validate()) {
                            // Build user object DIRECTLY from controllers
                            User userToRegister = User(
                              name: _nameController.text,
                              lastname: _lastnameController.text,
                              email: _emailController.text,
                              phone: _phoneController.text,
                              career: _selectedCarrera ?? '',
                              referenceZone: _zoneController.text,
                              password: _passwordController.text,
                              rolesIds: ['STUDENT']
                            );
                            
                            _syncToBloc(); // Still sync for consistency
                            context.read<RegisterBloc>().add(FormSubmit(user: userToRegister));
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

  Widget _imageUser(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GalleryOrPhotoDialog(
          context, 
          () => { context.read<RegisterBloc>().add(PickImage()) }, 
          () => { context.read<RegisterBloc>().add(TakePhoto()) }
        );
      },
      child: Container(
        width: 115,
        margin: EdgeInsets.only(top: 60, bottom: 0),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipOval(
            child: widget.state.image != null 
            ? kIsWeb 
              ? Image.network(
                widget.state.image!.path,
                fit: BoxFit.cover,
              )
              : Image.file(
                io.File(widget.state.image!.path),
                fit: BoxFit.cover,
              )
            : Image.asset(
              'assets/img/user_image.png',
            ),
          ),
        ),
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