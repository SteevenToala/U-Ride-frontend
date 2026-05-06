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
              _card(context, facultades, carreras),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 60, bottom: 30),
      child: Column(
        children: [
          _imageUser(context),
          SizedBox(height: 15),
          Text(
            'ÚNETE A U-RIDE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, List<String> facultades, List<String> carreras) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
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
            _loginRegisterToggle(context),
            SizedBox(height: 25),
            _textLabel('Información Personal'),
            DefaultTextFieldOutlined(
              controller: _nameController,
              text: 'Nombre', 
              icon: Icons.person_outline,
              onChanged: (text) => context.read<RegisterBloc>().add(NameChanged(name: BlocFormItem(value: text))),
              margin: EdgeInsets.only(bottom: 15),
            ),
            DefaultTextFieldOutlined(
              controller: _lastnameController,
              text: 'Apellido', 
              icon: Icons.person_2_outlined,
              onChanged: (text) => context.read<RegisterBloc>().add(LastnameChanged(lastname: BlocFormItem(value: text))),
              margin: EdgeInsets.only(bottom: 15),
            ),
            DefaultTextFieldOutlined(
              controller: _emailController,
              text: 'Correo Institucional', 
              icon: Icons.alternate_email_rounded,
              onChanged: (text) => context.read<RegisterBloc>().add(EmailChanged(email: BlocFormItem(value: text))),
              margin: EdgeInsets.only(bottom: 15),
            ),
            DefaultTextFieldOutlined(
              controller: _phoneController,
              text: 'Número de Teléfono', 
              icon: Icons.phone_android_rounded,
              onChanged: (text) => context.read<RegisterBloc>().add(PhoneChanged(phone: BlocFormItem(value: text))),
              margin: EdgeInsets.only(bottom: 15),
            ),
            
            _textLabel('Información Académica'),
            _dropdownFacultad(facultades),
            SizedBox(height: 15),
            _dropdownCarrera(carreras),
            SizedBox(height: 15),
            DefaultTextFieldOutlined(
              controller: _zoneController,
              text: 'Zona de Residencia', 
              icon: Icons.location_on_outlined,
              onChanged: (text) => context.read<RegisterBloc>().add(ReferenceZoneChanged(referenceZone: BlocFormItem(value: text))),
              margin: EdgeInsets.only(bottom: 15),
            ),

            _textLabel('Seguridad'),
            DefaultTextFieldOutlined(
              controller: _passwordController,
              text: 'Contraseña', 
              icon: Icons.lock_outline_rounded,
              obscureText: widget.state.isPasswordVisible,
              onChanged: (text) => context.read<RegisterBloc>().add(PasswordChanged(password: BlocFormItem(value: text))),
              suffixIcon: IconButton(
                onPressed: () => context.read<RegisterBloc>().add(TogglePasswordVisibility()),
                icon: Icon(widget.state.isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white60),
              ),
              margin: EdgeInsets.only(bottom: 15),
            ),
            DefaultTextFieldOutlined(
              controller: _confirmPasswordController,
              text: 'Confirmar Contraseña', 
              icon: Icons.lock_reset_rounded,
              obscureText: widget.state.isConfirmPasswordVisible,
              onChanged: (text) => context.read<RegisterBloc>().add(ConfirmPasswordChanged(confirmPassword: BlocFormItem(value: text))),
              suffixIcon: IconButton(
                onPressed: () => context.read<RegisterBloc>().add(ToggleConfirmPasswordVisibility()),
                icon: Icon(widget.state.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white60),
              ),
              margin: EdgeInsets.only(bottom: 30),
            ),

            DefaultButton(
              text: 'CREAR CUENTA',
              color: Color(0xFF00B4D8),
              onPressed: () {
                if (widget.state.formKey!.currentState!.validate()) {
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
                  _syncToBloc();
                  context.read<RegisterBloc>().add(FormSubmit(user: userToRegister));
                }
              },
            ),
            SizedBox(height: 20),
            _textIAlreadyHaveAccount(context),
          ],
        ),
      ),
    );
  }

  Widget _loginRegisterToggle(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text('Ingreso', style: TextStyle(color: Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registro', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Container(height: 4, width: 40, color: Color(0xFF00B4D8), margin: EdgeInsets.only(top: 4)),
          ],
        ),
      ],
    );
  }

  Widget _textLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 5, bottom: 12, top: 10),
      child: Text(text, style: TextStyle(color: Color(0xFF00B4D8), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _dropdownFacultad(List<String> facultades) {
    return DropdownButtonFormField<String>(
      value: _selectedFacultad,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_balance_outlined, color: Colors.white70),
        labelText: 'Facultad',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white24)),
      ),
      dropdownColor: Color(0xFF1B263B),
      style: TextStyle(color: Colors.white),
      items: facultades.map((f) => DropdownMenuItem(value: f, child: Text(f, style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (val) {
        setState(() { _selectedFacultad = val; _selectedCarrera = null; });
        context.read<RegisterBloc>().add(FacultadChanged(facultad: val));
      },
    );
  }

  Widget _dropdownCarrera(List<String> carreras) {
    return DropdownButtonFormField<String>(
      key: ValueKey(_selectedFacultad),
      value: _selectedCarrera,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.school_outlined, color: Colors.white70),
        labelText: 'Carrera',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white24)),
      ),
      dropdownColor: Color(0xFF1B263B),
      style: TextStyle(color: Colors.white),
      items: carreras.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (val) {
        setState(() { _selectedCarrera = val; });
        context.read<RegisterBloc>().add(CareerChanged(career: BlocFormItem(value: val ?? '')));
      },
    );
  }

  Widget _imageUser(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GalleryOrPhotoDialog(context, 
          () => context.read<RegisterBloc>().add(PickImage()), 
          () => context.read<RegisterBloc>().add(TakePhoto())
        );
      },
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF00B4D8), width: 3),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]
            ),
            child: ClipOval(
              child: widget.state.image != null 
                ? kIsWeb 
                  ? Image.network(widget.state.image!.path, fit: BoxFit.cover)
                  : Image.file(io.File(widget.state.image!.path), fit: BoxFit.cover)
                : Container(color: Colors.white10, child: Icon(Icons.person, size: 60, color: Colors.white24)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Color(0xFF00B4D8), shape: BoxShape.circle),
              child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _textIAlreadyHaveAccount(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            text: '¿Ya tienes cuenta? ',
            style: TextStyle(color: Colors.white60, fontSize: 14),
            children: [
              TextSpan(text: 'Inicia Sesión', style: TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold))
            ]
          ),
        ),
      ),
    );
  }
}