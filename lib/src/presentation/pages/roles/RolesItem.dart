import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/models/Role.dart';

class RolesItem extends StatelessWidget {

  final Role role;

  RolesItem(this.role);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(context, role.route, (route) => false);
      },
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10, top: 25),
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5)
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Usamos un Icono como fallback elegante por si la imagen falla
                  Icon(
                    role.id == 'STUDENT' ? Icons.person : Icons.directions_car,
                    size: 80,
                    color: Colors.white,
                  ),
                  // Intentamos cargar la imagen, pero si falla no mostrará la X roja
                  FadeInImage(
                    image: NetworkImage(role.image),
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 500),
                    placeholder: AssetImage('assets/img/no-image.png'),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Container(); // No mostramos nada si hay error, se queda el icono de fondo
                    },
                  ),
                ],
              ),
            ),
          ),
          Text(
            role.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1
            ),
          )
        ],
      ),
    );
  }
}