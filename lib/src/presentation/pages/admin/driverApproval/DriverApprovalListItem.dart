import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';

class DriverApprovalListItem extends StatelessWidget {

  final User user;
  final Function() onApprove;

  DriverApprovalListItem(this.user, this.onApprove);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: (user.image != null && user.image!.isNotEmpty)
                ? NetworkImage(user.image!)
                : AssetImage('assets/img/user_image.png') as ImageProvider,
              radius: 30,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${user.name} ${user.lastname}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(user.career ?? 'Sin carrera', style: TextStyle(color: Colors.grey[600])),
                  Text(user.referenceZone ?? 'Sin zona', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.check_circle, color: Colors.green, size: 35),
              onPressed: onApprove,
            )
          ],
        ),
      ),
    );
  }
}
