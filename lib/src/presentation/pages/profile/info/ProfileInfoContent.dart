import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoEvent.dart';

class ProfileInfoContent extends StatelessWidget {

  User? user;

  ProfileInfoContent(this.user);

  @override
  Widget build(BuildContext context) {
    bool hasDriverRole = user?.roles?.any((rol) => rol.id == 'DRIVER') ?? false;
    bool isAdmin = user?.roles?.any((rol) => rol.id == 'ADMIN') ?? false;
    bool isDriverApproved = user?.isDriverApproved ?? false;

    return Stack(
      children: [
        Column(
          children: [
            _headerProfile(context),
            Spacer(),
            // Solo mostrar si NO es admin y NO tiene el rol de conductor aún
            if (!hasDriverRole && !isAdmin)
              _actionProfile('QUIERO SER CONDUCTOR', Icons.drive_eta, () {
                if (user?.id != null) {
                  context.read<ProfileInfoBloc>().add(RequestDriverRole(id: user!.id!));
                }
              }),
            if (hasDriverRole && !isDriverApproved)
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Text(
                  'SOLICITUD DE CONDUCTOR PENDIENTE',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            _actionProfile('EDITAR PERFIL', Icons.edit, () { 
              Navigator.pushNamed(context, 'profile/update', arguments: user);
             }),
            _actionProfile('CERRAR SESION', Icons.settings_power, () {
              // TODO: Implementar logout si es necesario aquí o en el widget padre
            }),
            SizedBox(height: 35,)
          ],
        ),
        _cardUserInfo(context)
      ],
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 35, right: 35, top: 100),
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.white,
        elevation: 10,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajustar al contenido
            children: [
              Container(
                width: 115,
                margin: EdgeInsets.only(top: 25, bottom: 15),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipOval(
                    child: user != null 
                    ? (user!.image != null && user!.image!.isNotEmpty) 
                      ? FadeInImage.assetNetwork(
                        placeholder: 'assets/img/user_image.png', 
                        image: user!.image!,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(seconds: 1),
                      )
                      : Image.asset(
                        'assets/img/user_image.png',
                      )
                    : Image.asset(
                      'assets/img/user_image.png',
                    ),
                  ),
                ),
              ),
              Text(
                '${user?.name} ${user?.lastname}' ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              ),
              const SizedBox(height: 10),
              _infoRow(Icons.email_outlined, user?.email ?? ''),
              _infoRow(Icons.phone_android_outlined, user?.phone ?? 'Sin teléfono'),
              
              if (user?.career != null && user!.career!.isNotEmpty)
                _infoRow(Icons.school_outlined, user!.career!),
                
              if (user?.referenceZone != null && user!.referenceZone!.isNotEmpty)
                _infoRow(Icons.location_on_outlined, user!.referenceZone!),
                
              const SizedBox(height: 5),
              _buildRoleBadges(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadges() {
    return Wrap(
      spacing: 8,
      children: user?.roles?.map((rol) {
        return Chip(
          label: Text(
            rol.id, 
            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: rol.id == 'ADMIN' ? Colors.redAccent : Colors.blueAccent,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }).toList() ?? [],
    );
  }

  Widget _actionProfile(String option, IconData icon, Function() function) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 15),
        child: ListTile(
          title: Text(
            option,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(255, 19, 58, 213),
                  Color.fromARGB(255, 65, 173, 255),
                ]
              ),
              borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerProfile(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 40),
      height: MediaQuery.of(context).size.height * 0.33,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 19, 58, 213),
                Color.fromARGB(255, 65, 173, 255),
          ]
        ),
      ),
      child: Text(
        'PERFIL DE USUARIO',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 19
        ),
      ),
    );
  }

}