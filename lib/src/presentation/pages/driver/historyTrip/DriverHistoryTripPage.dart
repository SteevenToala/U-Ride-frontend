import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/historyTrip/DriverHistoryTripItem.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/historyTrip/bloc/DriverHistoryTripBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/historyTrip/bloc/DriverHistoryTripEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/historyTrip/bloc/DriverHistoryTripState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class DriverHistoryTripPage extends StatefulWidget {
  const DriverHistoryTripPage({super.key});

  @override
  State<DriverHistoryTripPage> createState() => _DriverHistoryTripPageState();
}

class _DriverHistoryTripPageState extends State<DriverHistoryTripPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<DriverHistoryTripBloc>().add(GetHistoryTrip());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocBuilder<DriverHistoryTripBloc, DriverHistoryTripState>(
        builder: (context, state) {
          final response = state.response;
          if (response is Loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.driverColor),
            );
          } else if (response is Success) {
            final data = response.data as List<ClientRequestResponse>;
            return RefreshIndicator(
              color: AppTheme.driverColor,
              backgroundColor: AppTheme.backgroundDarkSecondary,
              onRefresh: () async =>
                  context.read<DriverHistoryTripBloc>().add(GetHistoryTrip()),
              child: data.isEmpty ? _emptyState() : _buildContent(context, data),
            );
          } else if (response is ErrorData) {
            return _emptyState(message: response.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ClientRequestResponse> data) {
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
              itemCount: data.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: DriverHistoryTripItem(data[i]),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: data
                  .map((r) => SizedBox(width: cardW, child: DriverHistoryTripItem(r)))
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyState({String? message}) {
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
              child: Icon(Icons.history_rounded,
                  size: 38,
                  color: AppTheme.driverColor.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 18),
            Text(message ?? 'Sin viajes en tu historial',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            if (message == null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text('Aquí aparecerán tus viajes finalizados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 13)),
              ),
            ],
          ]),
        ),
      ],
    );
  }
}
