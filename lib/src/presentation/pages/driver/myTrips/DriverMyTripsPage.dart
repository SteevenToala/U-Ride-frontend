import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripStatus.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';
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
      backgroundColor: const Color(0xFF0D1B2A),
      body: BlocListener<DriverMyTripsBloc, DriverMyTripsState>(
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
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
            }
            if (state.trips.isEmpty) {
              return _emptyState();
            }
            return RefreshIndicator(
              color: const Color(0xFF00C896),
              backgroundColor: const Color(0xFF1A2E44),
              onRefresh: () async {
                if (_driverId != null) {
                  context.read<DriverMyTripsBloc>().add(LoadMyTrips(idDriver: _driverId!));
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.trips.length,
                itemBuilder: (context, i) {
                  final currentTrip = state.trips[i];
                  return _TripCard(
                    trip: currentTrip,
                    onStart: () => _confirm(
                      context,
                      title: '¿Iniciar viaje?',
                      message: 'El viaje comenzará y no podrás editar la información.',
                      onConfirm: () => context.read<DriverMyTripsBloc>().add(StartTrip(idTrip: currentTrip.id!)),
                    ),
                    onCancel: () => _confirm(
                      context,
                      title: '¿Cancelar viaje?',
                      message: 'Los pasajeros confirmados serán notificados.',
                      onConfirm: () => context.read<DriverMyTripsBloc>().add(CancelDriverTrip(idTrip: currentTrip.id!)),
                    ),
                    onFinish: () => _confirm(
                      context,
                      title: '¿Finalizar viaje?',
                      message: 'Marca el viaje como completado.',
                      onConfirm: () => context.read<DriverMyTripsBloc>().add(FinishTrip(idTrip: currentTrip.id!)),
                    ),
                    onDelete: () => _confirm(
                      context,
                      title: '¿Eliminar viaje?',
                      message: 'Esta acción no se puede deshacer.',
                      onConfirm: () => context.read<DriverMyTripsBloc>().add(DeleteTrip(idTrip: currentTrip.id!)),
                      isDestructive: true,
                    ),
                    onEdit: () => Navigator.pushNamed(
                      context,
                      'driver/shared-trips/publish',
                      arguments: {'idDriver': _driverId, 'tripToEdit': currentTrip},
                    ).then((_) {
                      if (_driverId != null) {
                        context.read<DriverMyTripsBloc>().add(LoadMyTrips(idDriver: _driverId!));
                      }
                    }),
                    onViewReservations: () => Navigator.pushNamed(
                      context,
                      'driver/shared-trips/reservations',
                      arguments: {'trip': currentTrip},
                    ).then((_) {
                      if (_driverId != null) {
                        context.read<DriverMyTripsBloc>().add(LoadMyTrips(idDriver: _driverId!));
                      }
                    }),
                    onViewRoute: (currentTrip.originLat != null && currentTrip.originLat != 0.0)
                        ? () => Navigator.pushNamed(
                              context,
                              'driver/shared-trips/route-map',
                              arguments: {'trip': currentTrip},
                            )
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00C896),
        onPressed: () => Navigator.pushNamed(
          context,
          'driver/shared-trips/publish',
          arguments: {'idDriver': _driverId},
        ).then((_) {
          if (_driverId != null) {
            context.read<DriverMyTripsBloc>().add(LoadMyTrips(idDriver: _driverId!));
          }
        }),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Viaje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No tienes viajes publicados', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Toca el botón + para publicar tu primer viaje', style: TextStyle(color: Color(0xFF4A6278), fontSize: 13)),
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
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E44),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Color(0xFF8BA3BC))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8BA3BC))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.redAccent : const Color(0xFF00C896),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor().withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: _statusColor().withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusColor().withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(), color: _statusColor(), size: 20),
                const SizedBox(width: 8),
                Text(_statusLabel(), style: TextStyle(color: _statusColor(), fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${trip.farePerSeat.toStringAsFixed(2)}/persona',
                    style: const TextStyle(color: Color(0xFF00C896), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(Icons.location_on, 'Origen', trip.originZone),
                const SizedBox(height: 8),
                _infoRow(Icons.flag, 'Destino', trip.destinationZone),
                const SizedBox(height: 8),
                _infoRow(Icons.access_time, 'Salida', _formatDateTime(trip.departureTime)),
                const SizedBox(height: 8),
                _infoRow(
                  Icons.people,
                  'Cupos',
                  trip.isFinished || trip.isCancelled
                      ? '${trip.totalSeats - trip.availableSeats}/${trip.totalSeats} ocupados'
                      : '${trip.availableSeats}/${trip.totalSeats} disponibles',
                ),
                if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoRow(Icons.note, 'Notas', trip.notes!),
                ],
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _buildActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (trip.isScheduled) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _actionBtn('Ver Reservas', Icons.people, const Color(0xFF3B82F6), onViewReservations)),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn('Iniciar', Icons.play_arrow, const Color(0xFF00C896), onStart)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _actionBtn('Editar', Icons.edit, const Color(0xFFF59E0B), onEdit)),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn('Cancelar', Icons.cancel, Colors.redAccent, onCancel)),
            ],
          ),
        ],
      );
    } else if (trip.isActive) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _actionBtn('Pasajeros', Icons.people, const Color(0xFF3B82F6), onViewReservations)),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn('Finalizar', Icons.check_circle, const Color(0xFF00C896), onFinish)),
            ],
          ),
          if (onViewRoute != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _actionBtn('Ver Ruta en Mapa', Icons.map, const Color(0xFF8B5CF6), onViewRoute!),
            ),
          ],
        ],
      );
    }
    // FINISHED — solo lectura, no se puede eliminar (registro histórico)
    if (trip.isFinished) {
      return SizedBox(
        width: double.infinity,
        child: _actionBtn('Ver Pasajeros', Icons.people_outline, const Color(0xFF8BA3BC), onViewReservations),
      );
    }
    // CANCELLED — se puede eliminar para limpiar la lista
    return Row(
      children: [
        Expanded(child: _actionBtn('Ver Pasajeros', Icons.people_outline, const Color(0xFF8BA3BC), onViewReservations)),
        const SizedBox(width: 8),
        Expanded(child: _actionBtn('Eliminar', Icons.delete_outline, Colors.redAccent, onDelete)),
      ],
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF00C896)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Color _statusColor() {
    switch (trip.status) {
      case TripStatus.SCHEDULED:
        return const Color(0xFFF59E0B);
      case TripStatus.ACTIVE:
        return const Color(0xFF00C896);
      case TripStatus.FINISHED:
        return const Color(0xFF3B82F6);
      case TripStatus.CANCELLED:
        return Colors.redAccent;
    }
  }

  IconData _statusIcon() {
    switch (trip.status) {
      case TripStatus.SCHEDULED:
        return Icons.schedule;
      case TripStatus.ACTIVE:
        return Icons.directions_car;
      case TripStatus.FINISHED:
        return Icons.check_circle;
      case TripStatus.CANCELLED:
        return Icons.cancel;
    }
  }

  String _statusLabel() {
    switch (trip.status) {
      case TripStatus.SCHEDULED:
        return 'Programado';
      case TripStatus.ACTIVE:
        return 'En curso';
      case TripStatus.FINISHED:
        return 'Finalizado';
      case TripStatus.CANCELLED:
        return 'Cancelado';
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
