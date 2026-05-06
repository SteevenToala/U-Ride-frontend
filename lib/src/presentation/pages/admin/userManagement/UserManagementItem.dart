import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementEvent.dart';

class UserManagementItem extends StatelessWidget {
  final User user;

  const UserManagementItem(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    bool isDriver = user.isDriverApproved ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
            child: user.image == null ? Icon(Icons.person, color: Colors.blue.shade800, size: 30) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name} ${user.lastname}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  user.email ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _buildBadge(
                      label: 'Estudiante',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 5),
                    if (isDriver)
                      _buildBadge(
                        label: 'Conductor',
                        color: Colors.green,
                      ),
                  ],
                )
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.block, color: Colors.redAccent, size: 20),
                onPressed: () {
                   _showSuspendDialog(context);
                },
                tooltip: 'Suspender Usuario',
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                onPressed: () {
                   _showDetailsDialog(context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showSuspendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return AlertDialog(
          title: const Text('Confirmar Suspensión'),
          content: Text('¿Estás seguro de que deseas suspender a ${user.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                context.read<UserManagementBloc>().add(SuspendUser(user.id!));
                Navigator.pop(contextDialog);
              },
              child: const Text('SUSPENDER', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      }
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return AlertDialog(
          title: Text('${user.name} ${user.lastname}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user.email}'),
              Text('Teléfono: ${user.phone ?? 'N/A'}'),
              Text('Carrera: ${user.career ?? 'N/A'}'),
              Text('Zona: ${user.referenceZone ?? 'N/A'}'),
              const SizedBox(height: 10),
              Text('Estado Conductor: ${user.isDriverApproved == true ? 'APROBADO' : 'PENDIENTE / NO SOLICITADO'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: const Text('CERRAR'),
            ),
          ],
        );
      }
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
