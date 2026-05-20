import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/ReservationStatus.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'bloc/DriverReservationsBloc.dart';
import 'bloc/DriverReservationsEvent.dart';
import 'bloc/DriverReservationsState.dart';

class DriverReservationsPage extends StatefulWidget {
  final SharedTrip trip;

  const DriverReservationsPage({super.key, required this.trip});

  @override
  State<DriverReservationsPage> createState() => _DriverReservationsPageState();
}

class _DriverReservationsPageState extends State<DriverReservationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverReservationsBloc>().add(LoadReservationsByTrip(idTrip: widget.trip.id!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2E44),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reservas del Viaje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              '${widget.trip.originZone} → ${widget.trip.destinationZone}',
              style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocListener<DriverReservationsBloc, DriverReservationsState>(
        listener: (context, state) {
          if (state.response is Success<TripReservation>) {
            Fluttertoast.showToast(msg: 'Reserva actualizada', backgroundColor: Colors.green);
          } else if (state.response is ErrorData) {
            Fluttertoast.showToast(
              msg: (state.response as ErrorData).message,
              backgroundColor: Colors.red,
            );
          }
        },
        child: BlocBuilder<DriverReservationsBloc, DriverReservationsState>(
          builder: (context, state) {
            if (state.isLoading && state.reservations.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
            }
            if (state.reservations.isEmpty) {
              return _emptyState();
            }

            // Summary bar
            final pending = state.reservations.where((r) => r.isPending).length;
            final accepted = state.reservations.where((r) => r.isAccepted).length;

            return Column(
              children: [
                _summaryBar(pending, accepted, widget.trip.availableSeats),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.reservations.length,
                    itemBuilder: (context, i) {
                      final r = state.reservations[i];
                      return _ReservationCard(
                        reservation: r,
                        onAccept: r.isPending
                            ? () => _confirm(context,
                                title: '¿Aceptar reserva?',
                                message: 'El pasajero quedará confirmado en el viaje.',
                                onConfirm: () => context
                                    .read<DriverReservationsBloc>()
                                    .add(AcceptReservation(idReservation: r.id!)))
                            : null,
                        onReject: r.isPending
                            ? () => _confirm(context,
                                title: '¿Rechazar reserva?',
                                message: 'El pasajero será notificado del rechazo.',
                                onConfirm: () => context
                                    .read<DriverReservationsBloc>()
                                    .add(RejectReservation(idReservation: r.id!)),
                                isDestructive: true)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryBar(int pending, int accepted, int available) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Pendientes', pending.toString(), const Color(0xFFF59E0B)),
          _statItem('Aceptados', accepted.toString(), const Color(0xFF00C896)),
          _statItem('Cupos libres', available.toString(), const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 12)),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Sin reservas aún', style: TextStyle(color: Colors.white70, fontSize: 16)),
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
            child: const Text('No', style: TextStyle(color: Color(0xFF8BA3BC))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.redAccent : const Color(0xFF00C896),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }
}

class _ReservationCard extends StatelessWidget {
  final TripReservation reservation;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _ReservationCard({
    required this.reservation,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final passenger = reservation.passenger;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor().withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF0D1B2A),
                  backgroundImage: passenger?.image != null ? NetworkImage(passenger!.image!) : null,
                  child: passenger?.image == null
                      ? const Icon(Icons.person, color: Color(0xFF00C896))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger != null ? '${passenger.name} ${passenger.lastname}' : 'Pasajero',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (passenger?.career != null)
                        Text(passenger!.career!, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 12)),
                      if (passenger?.referenceZone != null)
                        Text('📍 ${passenger!.referenceZone}', style: const TextStyle(color: Color(0xFF4A6278), fontSize: 12)),
                    ],
                  ),
                ),
                _StatusBadge(status: reservation.status),
              ],
            ),
            if (reservation.message != null && reservation.message!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.message_outlined, color: Color(0xFF8BA3BC), size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: Text(reservation.message!, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 13))),
                  ],
                ),
              ),
            ],
            if (onAccept != null || onReject != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: onReject,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rechazar'),
                      ),
                    ),
                  if (onAccept != null && onReject != null) const SizedBox(width: 8),
                  if (onAccept != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: onAccept,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Aceptar'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor() {
    switch (reservation.status) {
      case ReservationStatus.PENDING:
        return const Color(0xFFF59E0B);
      case ReservationStatus.ACCEPTED:
        return const Color(0xFF00C896);
      case ReservationStatus.REJECTED:
        return Colors.redAccent;
      case ReservationStatus.CANCELLED:
        return Colors.grey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case ReservationStatus.PENDING:
        color = const Color(0xFFF59E0B);
        label = 'Pendiente';
        break;
      case ReservationStatus.ACCEPTED:
        color = const Color(0xFF00C896);
        label = 'Aceptado';
        break;
      case ReservationStatus.REJECTED:
        color = Colors.redAccent;
        label = 'Rechazado';
        break;
      case ReservationStatus.CANCELLED:
        color = Colors.grey;
        label = 'Cancelado';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
