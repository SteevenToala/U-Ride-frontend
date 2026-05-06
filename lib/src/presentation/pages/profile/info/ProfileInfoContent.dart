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
      child: SingleChildScrollView(
        child: Column(
          children: [
            _headerProfile(context),
            _cardUserInfo(context),
            SizedBox(height: 30),
            
            if (!hasDriverRole && !isAdmin)
              _actionProfile('QUIERO SER CONDUCTOR', Icons.drive_eta_rounded, () {
                if (user?.id != null) {
                  context.read<ProfileInfoBloc>().add(RequestDriverRole(id: user!.id!));
                }
              }, isPrimary: true),
            
            if (hasDriverRole && !isDriverApproved)
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3))
                ),
                child: Text(
                  'SOLICITUD DE CONDUCTOR PENDIENTE',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),

            _actionProfile('EDITAR PERFIL', Icons.edit_rounded, () { 
              Navigator.pushNamed(context, 'profile/update', arguments: user);
            }),
            
            _actionProfile('CERRAR SESIÓN', Icons.logout_rounded, () {
              // Implementar logout logic
            }, isLogout: true),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        margin: EdgeInsets.symmetric(horizontal: 25),
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF00B4D8), width: 3),
              ),
              child: ClipOval(
                child: user?.image != null && user!.image!.isNotEmpty
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/img/user_image.png', 
                      image: user!.image!,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.person, size: 60, color: Colors.white24),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${user?.name} ${user?.lastname}'.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 1
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white10),
            SizedBox(height: 10),
            _infoRow(Icons.alternate_email_rounded, user?.email ?? ''),
            _infoRow(Icons.phone_android_rounded, user?.phone ?? 'Sin teléfono'),
            if (user?.career != null && user!.career!.isNotEmpty)
              _infoRow(Icons.school_rounded, user!.career!),
            if (user?.referenceZone != null && user!.referenceZone!.isNotEmpty)
              _infoRow(Icons.location_on_rounded, user!.referenceZone!),
            SizedBox(height: 20),
            _buildRoleBadges(),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xFF00B4D8)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadges() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: user?.roles?.map((rol) {
        String roleName = rol.id;
        if (rol.id == 'STUDENT') roleName = 'ESTUDIANTE';
        if (rol.id == 'DRIVER') roleName = 'CONDUCTOR';
        if (rol.id == 'ADMIN') roleName = 'ADMINISTRADOR';

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (rol.id == 'ADMIN' ? Colors.redAccent : Color(0xFF00B4D8)).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (rol.id == 'ADMIN' ? Colors.redAccent : Color(0xFF00B4D8)).withOpacity(0.5)),
          ),
          child: Text(
            roleName, 
            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        );
      }).toList() ?? [],
    );
  }

  Widget _actionProfile(String option, IconData icon, Function() function, {bool isPrimary = false, bool isLogout = false}) {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      margin: EdgeInsets.only(left: 25, right: 25, top: 15),
      child: Material(
        color: isPrimary ? Color(0xFF00B4D8) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: function,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: isLogout ? Colors.redAccent.withOpacity(0.3) : Colors.white10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(icon, color: isLogout ? Colors.redAccent : (isPrimary ? Colors.white : Color(0xFF00B4D8)), size: 24),
                SizedBox(width: 20),
                Text(
                  option,
                  style: TextStyle(
                    color: isLogout ? Colors.redAccent : (isPrimary ? Colors.white : Colors.white),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right_rounded, color: Colors.white24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerProfile(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 80, bottom: 40),
      child: Column(
        children: [
          Text(
            'MI PERFIL',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Información de tu cuenta U-RIDE',
            style: TextStyle(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}