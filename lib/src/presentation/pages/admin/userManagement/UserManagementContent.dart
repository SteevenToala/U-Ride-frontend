import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/UserManagementItem.dart';

class UserManagementContent extends StatelessWidget {
  final List<User> users;

  const UserManagementContent(this.users, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserManagementItem(users[index]);
      },
    );
  }
}
