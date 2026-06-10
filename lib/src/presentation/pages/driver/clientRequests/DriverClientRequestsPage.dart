import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/clientRequests/DriverClientRequestsItem.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class DriverClientRequestsPage extends StatefulWidget {
  const DriverClientRequestsPage({super.key});

  @override
  State<DriverClientRequestsPage> createState() =>
      _DriverClientRequestsPageState();
}

class _DriverClientRequestsPageState extends State<DriverClientRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<DriverClientRequestsBloc>().add(InitDriverClientRequest());
      context.read<DriverClientRequestsBloc>().add(ListenNewClientRequestSocketIO());
      // context.read<DriverClientRequestsBloc>().add(GetNearbyTripRequest());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocListener<DriverClientRequestsBloc, DriverClientRequestsState>(
        listener: (context, state) {
          final responseCreateTripRequest = state.responseCreateDriverTripRequest;
          if (responseCreateTripRequest is Success) {
            Fluttertoast.showToast(msg: 'La oferta se ha enviado correctamente', toastLength: Toast.LENGTH_LONG);
          }
          else if (responseCreateTripRequest is ErrorData) {
            Fluttertoast.showToast(msg: responseCreateTripRequest.message, toastLength: Toast.LENGTH_LONG);
          }
        },
        child: BlocBuilder<DriverClientRequestsBloc, DriverClientRequestsState>(
            builder: (context, state) {
          final response = state.response;
          if (response is Loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.driverColor),
            );
          }
          else if (response is Success) {
            final clientRequests = response.data as List<ClientRequestResponse>;
            if (clientRequests.isEmpty) {
              return _emptyState();
            }
            return _buildContent(context, state, clientRequests);
          }
          return _emptyState();
        }),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DriverClientRequestsState state, List<ClientRequestResponse> clientRequests) {
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
              itemCount: clientRequests.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: DriverClientRequestsItem(state, clientRequests[i]),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: clientRequests
                  .map((r) => SizedBox(width: cardW, child: DriverClientRequestsItem(state, r)))
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
                color: AppTheme.driverColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_rounded,
                  size: 38,
                  color: AppTheme.driverColor.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 18),
            const Text('Sin solicitudes cercanas',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text('Las solicitudes de pasajeros cercanos aparecerán aquí',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 13)),
            ),
          ]),
        ),
      ],
    );
  }
}
