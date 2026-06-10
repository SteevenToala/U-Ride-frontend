import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/UserManagementItem.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class UserManagementContent extends StatelessWidget {
  final List<User> users;

  const UserManagementContent(this.users, {super.key});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return _emptyState();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final cols = w >= 960 ? 3 : w >= 580 ? 2 : 1;
          final hPad = w >= 580 ? 20.0 : 16.0;
          final spacing = 14.0;
          final cardW = cols == 1
              ? double.infinity
              : (w - hPad * 2 - spacing * (cols - 1)) / cols;

          if (cols == 1) {
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
              itemCount: users.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: UserManagementItem(users[i]),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: users
                  .map((u) => SizedBox(width: cardW, child: UserManagementItem(u)))
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded,
                  size: 38,
                  color: AppTheme.accentColor.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 18),
            const Text('Sin usuarios registrados',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ],
    );
  }
}
