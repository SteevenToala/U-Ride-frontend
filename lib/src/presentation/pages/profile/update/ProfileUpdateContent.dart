import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/GalleryOrPhotoDialog.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultIconBack.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextField.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultButton.dart';

class ProfileUpdateContent extends StatelessWidget {
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

  User? user;
  ProfileUpdateState state;

  ProfileUpdateContent(this.state, this.user);

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
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _headerProfile(context),
                  _cardUserInfo(context),
                  SizedBox(height: 30),
                  _actionProfile(context, 'ACTUALIZAR DATOS', Icons.save_rounded),
                  SizedBox(height: 40)
                ],
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageUser(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GalleryOrPhotoDialog(context, 
          () => context.read<ProfileUpdateBloc>().add(PickImage()), 
          () => context.read<ProfileUpdateBloc>().add(TakePhoto())
        );
      },
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF00B4D8), width: 3),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]
            ),
            child: ClipOval(
              child: state.image != null 
                ? kIsWeb
                  ? Image.network(state.image!.path, fit: BoxFit.cover)
                  : Image.file(io.File(state.image!.path), fit: BoxFit.cover)
                : user?.image != null && user!.image!.isNotEmpty
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/img/user_image.png', 
                      image: user!.image!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.white10, child: Icon(Icons.person, size: 60, color: Colors.white24)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Color(0xFF00B4D8), shape: BoxShape.circle),
              child: Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 40 : 25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            _imageUser(context),
            SizedBox(height: 30),
            _textLabel('Información Personal'),
            DefaultTextField(
              text: 'Nombre', 
              icon: Icons.person_rounded, 
              initialValue: user?.name,
              onChanged: (text) => context.read<ProfileUpdateBloc>().add(NameChanged(name: BlocFormItem(value: text))),
              validator: (value) => state.name.error,
            ),
            SizedBox(height: 15),
            DefaultTextField(
              text: 'Apellido', 
              icon: Icons.person_outline_rounded, 
              initialValue: user?.lastname,
              onChanged: (text) => context.read<ProfileUpdateBloc>().add(LastNameChanged(lastname: BlocFormItem(value: text))),
              validator: (value) => state.lastname.error,
            ),
            SizedBox(height: 15),
            DefaultTextField(
              text: 'Teléfono', 
              icon: Icons.phone_android_rounded,
              initialValue: user?.phone,
              onChanged: (text) => context.read<ProfileUpdateBloc>().add(PhoneChanged(phone: BlocFormItem(value: text))),
              validator: (value) => state.phone.error,
            ),
            if (user?.roles?.any((role) => role.id == 'STUDENT') ?? false) ...[
              SizedBox(height: 25),
              _textLabel('Información Académica'),
              _dropdownFacultad(context),
              SizedBox(height: 15),
              _dropdownCarrera(context),
              SizedBox(height: 15),
              DefaultTextField(
                text: 'Zona de residencia', 
                icon: Icons.map_rounded,
                initialValue: user?.referenceZone,
                onChanged: (text) => context.read<ProfileUpdateBloc>().add(ReferenceZoneChanged(referenceZone: BlocFormItem(value: text))),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dropdownFacultad(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedFacultad,
          hint: Text('Selecciona tu facultad', style: TextStyle(color: Colors.white60, fontSize: 14)),
          isExpanded: true,
          dropdownColor: Color(0xFF1B263B),
          style: TextStyle(color: Colors.white),
          items: _facultadCarreras.keys.map((f) => DropdownMenuItem(value: f, child: Text(f, style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (val) => context.read<ProfileUpdateBloc>().add(FacultadChanged(facultad: val)),
        ),
      ),
    );
  }

  Widget _dropdownCarrera(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (state.selectedFacultad != null && _facultadCarreras[state.selectedFacultad]!.contains(state.career.value)) ? state.career.value : null,
          hint: Text('Selecciona tu carrera', style: TextStyle(color: Colors.white60, fontSize: 14)),
          isExpanded: true,
          dropdownColor: Color(0xFF1B263B),
          style: TextStyle(color: Colors.white),
          items: state.selectedFacultad != null
              ? _facultadCarreras[state.selectedFacultad]!.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList()
              : [],
          onChanged: (val) => context.read<ProfileUpdateBloc>().add(CareerChanged(career: BlocFormItem(value: val ?? ''))),
        ),
      ),
    );
  }

  Widget _actionProfile(BuildContext context, String option, IconData icon) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: DefaultButton(
          text: option,
          color: Color(0xFF00B4D8),
          onPressed: () {
            if (state.formKey!.currentState?.validate() ?? true) {
              context.read<ProfileUpdateBloc>().add(FormSubmit());
            }
          },
        ),
      ),
    );
  }

  Widget _headerProfile(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05, bottom: 20),
      child: Column(
        children: [
          Text(
            'MI PERFIL',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Actualiza tu información de usuario',
            style: TextStyle(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _textLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 5, bottom: 12),
        child: Text(
          text, 
          style: TextStyle(color: Color(0xFF00B4D8), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)
        ),
      ),
    );
  }
}