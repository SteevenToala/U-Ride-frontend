import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/UserManagementContent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementBloc>().add(GetUsers());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocBuilder<UserManagementBloc, UserManagementState>(
        builder: (context, state) {
          final response = state.response;
          
          if (response is Loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
          } 
          
          if (response is Success<List<User>>) {
            return UserManagementContent(response.data);
          } 
          
          if (response is ErrorData) {
            final error = response as ErrorData;
            return Center(child: Text(error.message, style: const TextStyle(color: AppTheme.textMuted)));
          }

          return Container(color: AppTheme.backgroundDark);
        },
      ),
    );
  }
}
