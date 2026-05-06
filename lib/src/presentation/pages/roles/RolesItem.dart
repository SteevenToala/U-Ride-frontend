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
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Color(0xFF00B4D8).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF00B4D8), width: 2),
              ),
              child: Icon(
                role.id == 'STUDENT' ? Icons.school_rounded : Icons.directions_car_rounded,
                size: 35,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    role.id == 'STUDENT' ? 'Viaja con tus compañeros' : 'Genera ingresos conduciendo',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00B4D8), size: 20),
          ],
        ),
      ),
    );
  }
}