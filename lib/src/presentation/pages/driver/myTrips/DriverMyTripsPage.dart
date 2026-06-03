import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripStatus.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'bloc/DriverMyTripsBloc.dart';
import 'bloc/DriverMyTripsEvent.dart';
import 'bloc/DriverMyTripsState.dart';

class DriverMyTripsPage extends StatefulWidget {
  const DriverMyTripsPage({super.key});

  @override
  State<DriverMyTripsPage> createState() => _DriverMyTripsPageState();
}

class _DriverMyTripsPageState extends State<DriverMyTripsPage> {
  int? _driverId;

  @override
  void initState() {
    super.initState();
    _loadDriver();
  }

  Future<void> _loadDriver() async {
    final pref = SharefPref();
    final session = await pref.read('user');
    if (session != null) {
      final auth = AuthResponse.fromJson(session);
      setState(() => _driverId = auth.user.id);
      if (mounted) {
        context.read<DriverMyTripsBloc>().add(LoadMyTrips(idDriver: auth.user.id!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Column(
        children: [
          _pageHeader(),
          Expanded(
            child: BlocListener<DriverMyTripsBloc, DriverMyTripsState>(
              listener: (context, state) {
                if (state.response is ErrorData) {
                  Fluttertoast.showToast(
                    msg: (state.response as ErrorData).message,
                    backgroundColor: Colors.red,
                  );
                }
              },
              child: BlocBuilder<DriverMyTripsBloc, DriverMyTripsState>(
                builder: (context, state) {
                  if (state.isLoading && state.trips.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.driverColor),
                    );
                  }
                  if (state.trips.isEmpty) return _emptyState();
                  return RefreshIndicator(
                    color: AppTheme.driverColor,
                    backgroundColor: AppTheme.backgroundDarkSecondary,
                    onRefresh: () async {
                      if (_driverId != null) {
                        context
                            .read<DriverMyTripsBloc>()
                            .add(LoadMyTrips(idDriver: _driverId!));
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: state.trips.length,
                      itemBuilder: (context, i) {
                        final t = state.trips[i];
                        return _TripCard(
                          trip: t,
                          onStart: () => _confirm(
                            context,
                            title: '¿Iniciar viaje?',
                            message: 'El viaje comenzará y no podrás editar la información.',
                            onConfirm: () => context
                                .read<DriverMyTripsBloc>()
                                .add(StartTrip(idTrip: t.id!)),
                            confirmColor: AppTheme.accentColor,
                          ),
                          onCancel: () => _confirm(
                            context,
                            title: '¿Cancelar viaje?',
                            message: 'Los pasajeros confirmados serán notificados.',
                            onConfirm: () => context
                                .read<DriverMyTripsBloc>()
                                .add(CancelDriverTrip(idTrip: t.id!)),
                            isDestructive: true,
                          ),
                          onFinish: () => _confirm(
                            context,
                            title: '¿Finalizar viaje?',
                            message: 'Marca el viaje como completado.',
                            onConfirm: () => context
                                .read<DriverMyTripsBloc>()
                                .add(FinishTrip(idTrip: t.id!)),
                            confirmColor: AppTheme.accentColor,
                          ),
                          onDelete: () => _confirm(
                            context,
                            title: '¿Eliminar viaje?',
                            message: 'Esta acción no se puede deshacer.',
                            onConfirm: () => context
                                .read<DriverMyTripsBloc>()
                                .add(DeleteTrip(idTrip: t.id!)),
                            isDestructive: true,
                          ),
                          onEdit: () => Navigator.pushNamed(
                            context,
                            'driver/shared-trips/publish',
                            arguments: {'idDriver': _driverId, 'tripToEdit': t},
                          ).then((_) {
                            if (mounted && _driverId != null) {
                              context
                                  .read<DriverMyTripsBloc>()
                                  .add(LoadMyTrips(idDriver: _driverId!));
                            }
                          }),
                          onViewReservations: () => Navigator.pushNamed(
                            context,
                            'driver/shared-trips/reservations',
                            arguments: {'trip': t},
                          ).then((_) {
                            if (mounted && _driverId != null) {
                              context
                                  .read<DriverMyTripsBloc>()
                                  .add(LoadMyTrips(idDriver: _driverId!));
                            }
                          }),
                          onViewRoute: (t.originLat != null && t.originLat != 0.0)
                              ? () => Navigator.pushNamed(
                                    context,
                                    'driver/shared-trips/route-map',
                                    arguments: {'trip': t},
                                  )
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _publishFab(),
    );
  }

  Widget _pageHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.driverColor.withValues(alpha: 0.25),
            AppTheme.backgroundDarkSecondary,
          ],
        ),
        border: Border(
          bottom: BorderSide(
              color: AppTheme.driverColor.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppTheme.driverGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.driverColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Viajes',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              Text(
                'Gestiona tus rutas publicadas',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _publishFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.driverGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.driverColor.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => Navigator.pushNamed(
          context,
          'driver/shared-trips/publish',
          arguments: {'idDriver': _driverId},
        ).then((_) {
          if (mounted && _driverId != null) {
            context.read<DriverMyTripsBloc>().add(LoadMyTrips(idDriver: _driverId!));
          }
        }),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nuevo Viaje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.driverColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 46,
              color: AppTheme.driverColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No tienes viajes publicados',
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para publicar tu primer viaje',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
    Color? confirmColor,
  }) async {
    final color = isDestructive ? Colors.redAccent : (confirmColor ?? AppTheme.driverColor);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(message,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }
}

// ── Trip card ────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final SharedTrip trip;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final VoidCallback onFinish;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onViewReservations;
  final VoidCallback? onViewRoute;

  const _TripCard({
    required this.trip,
    required this.onStart,
    required this.onCancel,
    required this.onFinish,
    required this.onDelete,
    required this.onEdit,
    required this.onViewReservations,
    this.onViewRoute,
  });

  Color get _sc => switch (trip.status) {
        TripStatus.SCHEDULED => const Color(0xFFF59E0B),
        TripStatus.ACTIVE    => AppTheme.accentColor,
        TripStatus.FINISHED  => const Color(0xFF3B82F6),
        TripStatus.CANCELLED => Colors.redAccent,
      };

  IconData get _si => switch (trip.status) {
        TripStatus.SCHEDULED => Icons.schedule_rounded,
        TripStatus.ACTIVE    => Icons.directions_car_rounded,
        TripStatus.FINISHED  => Icons.check_circle_rounded,
        TripStatus.CANCELLED => Icons.cancel_rounded,
      };

  String get _sl => switch (trip.status) {
        TripStatus.SCHEDULED => 'Programado',
        TripStatus.ACTIVE    => 'En curso',
        TripStatus.FINISHED  => 'Finalizado',
        TripStatus.CANCELLED => 'Cancelado',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _sc.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _sc.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: _sc.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _sc.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _sc.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_si, color: _sc, size: 13),
                      const SizedBox(width: 5),
                      Text(_sl,
                          style: TextStyle(
                              color: _sc, fontWeight: FontWeight.w800, fontSize: 12)),
                    ],
                  ),
                ),
                const Spacer(),
                // Price badge — always visible (solid gradient)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppTheme.driverGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.driverColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '\$${trip.farePerSeat.toStringAsFixed(2)}/persona',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              children: [
                _infoRow(Icons.radio_button_checked, 'Origen', trip.originZone,
                    AppTheme.driverColorLight),
                const SizedBox(height: 8),
                _infoRow(Icons.location_on_rounded, 'Destino', trip.destinationZone,
                    const Color(0xFFF59E0B)),
                const SizedBox(height: 8),
                _infoRow(Icons.access_time_rounded, 'Salida',
                    _formatDateTime(trip.departureTime), Colors.white54),
                const SizedBox(height: 8),
                _infoRow(
                  Icons.people_rounded,
                  'Cupos',
                  trip.isFinished || trip.isCancelled
                      ? '${trip.totalSeats - trip.availableSeats}/${trip.totalSeats} ocupados'
                      : '${trip.availableSeats}/${trip.totalSeats} disponibles',
                  AppTheme.accentColor,
                ),
                if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoRow(Icons.note_rounded, 'Notas', trip.notes!, Colors.white38),
                ],
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: _buildActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (trip.isScheduled) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _btn('Ver Reservas', Icons.people_rounded,
                  const Color(0xFF3B82F6), onViewReservations)),
              const SizedBox(width: 8),
              Expanded(child: _btn('Iniciar', Icons.play_circle_rounded,
                  AppTheme.accentColor, onStart)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _btn('Editar', Icons.edit_rounded,
                  const Color(0xFFF59E0B), onEdit)),
              const SizedBox(width: 8),
              Expanded(child: _btn('Cancelar', Icons.cancel_rounded,
                  Colors.redAccent, onCancel)),
            ],
          ),
        ],
      );
    } else if (trip.isActive) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _btn('Pasajeros', Icons.people_rounded,
                  const Color(0xFF3B82F6), onViewReservations)),
              const SizedBox(width: 8),
              Expanded(child: _btn('Finalizar', Icons.check_circle_rounded,
                  AppTheme.accentColor, onFinish)),
            ],
          ),
          if (onViewRoute != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _btn('Ver Ruta en Mapa', Icons.map_rounded,
                  const Color(0xFF8B5CF6), onViewRoute!),
            ),
          ],
        ],
      );
    }
    if (trip.isFinished) {
      return Row(
        children: [
          Expanded(child: _btn('Pasajeros', Icons.people_outline,
              Colors.white38, onViewReservations, subtle: true)),
          if (onViewRoute != null) ...[
            const SizedBox(width: 8),
            Expanded(child: _btn('Ver Ruta', Icons.map_rounded,
                const Color(0xFF8B5CF6), onViewRoute!)),
          ],
        ],
      );
    }
    // CANCELLED
    return Row(
      children: [
        Expanded(child: _btn('Pasajeros', Icons.people_outline,
            Colors.white38, onViewReservations, subtle: true)),
        const SizedBox(width: 8),
        Expanded(child: _btn('Eliminar', Icons.delete_rounded,
            Colors.redAccent, onDelete)),
      ],
    );
  }

  Widget _btn(String label, IconData icon, Color color, VoidCallback onTap,
      {bool subtle = false}) {
    final gradient = subtle
        ? null
        : LinearGradient(
            colors: [
              HSLColor.fromColor(color)
                  .withLightness(
                    (HSLColor.fromColor(color).lightness + 0.1).clamp(0.0, 1.0),
                  )
                  .toColor(),
              color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          color: subtle ? Colors.white.withValues(alpha: 0.06) : null,
          borderRadius: BorderRadius.circular(12),
          border: subtle
              ? Border.all(color: AppTheme.dividerColor, width: 1)
              : null,
          boxShadow: subtle
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: subtle ? Colors.white38 : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: subtle ? Colors.white38 : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
