import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/ReservationStatus.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/ReportUserSheet.dart';
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
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDarkCard,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reservas del Viaje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              '${widget.trip.originZone} → ${widget.trip.destinationZone}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
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
              return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
            }
            if (state.reservations.isEmpty) {
              return _emptyState();
            }

            final pending = state.reservations.where((r) => r.isPending).length;
            final accepted = state.reservations.where((r) => r.isAccepted).length;

            // Cupos disponibles calculados dinámicamente desde reservas aceptadas
            final acceptedSeats = state.reservations
                .where((r) => r.isAccepted)
                .fold(0, (sum, r) => sum + r.seatsRequested);
            final dynamicAvailableSeats = widget.trip.totalSeats - acceptedSeats;

            return Column(
              children: [
                _summaryBar(pending, accepted, dynamicAvailableSeats, widget.trip.totalSeats, widget.trip.isFinished || widget.trip.isCancelled),
                Expanded(
                  child: _buildContent(context, state.reservations),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TripReservation> reservations) {
    Widget buildCard(TripReservation r) {
      return _ReservationCard(
        reservation: r,
        farePerSeat: widget.trip.farePerSeat,
        onAccept: r.isPending
            ? () => _confirm(context,
                title: '¿Aceptar reserva?',
                message: 'El pasajero quedará confirmado.',
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
        onConfirmPayment: (r.isAccepted && r.paymentMethod == 'EFECTIVO' && r.paymentStatus == 'PENDIENTE')
            ? () => _confirm(context,
                title: '¿Confirmar pago en efectivo?',
                message: 'Se registrará el cobro de \$${(r.seatsRequested * widget.trip.farePerSeat).toStringAsFixed(2)} y se ocuparán los puestos de forma definitiva.',
                onConfirm: () => context
                    .read<DriverReservationsBloc>()
                    .add(ConfirmPayment(idReservation: r.id!)))
            : null,
        onReport: r.isAccepted && r.passenger != null
            ? () => ReportUserSheet.show(
                context,
                reportedUserId: r.passenger!.id!,
                reportedUserName: '${r.passenger!.name} ${r.passenger!.lastname}',
              )
            : null,
      );
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
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
              itemCount: reservations.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: buildCard(reservations[i]),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: reservations
                  .map((r) => SizedBox(width: cardW, child: buildCard(r)))
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _summaryBar(int pending, int accepted, int available, int total, bool isFinished) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Pendientes', pending.toString(), AppTheme.statusScheduledColor),
          _statItem('Aceptados', accepted.toString(), AppTheme.accentColor),
          _statItem(isFinished ? 'Cupos ocupados' : 'Cupos libres', isFinished ? '${total - available} / $total' : '$available / $total', AppTheme.statusFinishedColor),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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
          const SizedBox(height: 8),
          const Text('Las solicitudes de los pasajeros aparecerán aquí', style: TextStyle(color: AppTheme.textFaint, fontSize: 13)),
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
        backgroundColor: AppTheme.backgroundDarkCard,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.redAccent : AppTheme.accentColor,
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

// ─── Tarjeta de reserva enriquecida ─────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  final TripReservation reservation;
  final double farePerSeat;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReport;
  final VoidCallback? onConfirmPayment;

  const _ReservationCard({
    required this.reservation,
    required this.farePerSeat,
    this.onAccept,
    this.onReject,
    this.onReport,
    this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    final passenger = reservation.passenger;
    final totalCost = reservation.seatsRequested * farePerSeat;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor().withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pasajero + badge de estado ─────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.backgroundDark,
                  backgroundImage: passenger?.image != null ? NetworkImage(passenger!.image!) : null,
                  child: passenger?.image == null
                      ? const Icon(Icons.person, color: AppTheme.accentColor, size: 26)
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
                        Text(passenger!.career!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      if (passenger?.referenceZone != null)
                        Text('📍 ${passenger!.referenceZone}', style: const TextStyle(color: AppTheme.textFaint, fontSize: 12)),
                    ],
                  ),
                ),
                _StatusBadge(status: reservation.status),
              ],
            ),

            const SizedBox(height: 12),

            // ── Cupos y costo — información clave para el conductor ─
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cupos solicitados', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                        Row(
                          children: [
                            const Icon(Icons.event_seat, color: AppTheme.accentColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${reservation.seatsRequested} cupo${reservation.seatsRequested > 1 ? "s" : ""}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 38, color: AppTheme.borderSubtle),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total a cobrar', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, color: AppTheme.statusScheduledColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '\$${totalCost.toStringAsFixed(2)}',
                              style: const TextStyle(color: AppTheme.statusScheduledColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Mensaje del pasajero ───────────────────────────────
            if (reservation.message != null && reservation.message!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.message_outlined, color: AppTheme.textMuted, size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: Text(reservation.message!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13))),
                  ],
                ),
              ),
            ],

            // ── Fecha de solicitud y Estado de Pago ─────────────────
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (reservation.createdAt != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppTheme.textFaint),
                      const SizedBox(width: 4),
                      Text(
                        'Solicitado: ${_formatDate(reservation.createdAt!)}',
                        style: const TextStyle(color: AppTheme.textFaint, fontSize: 11),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Icon(
                      reservation.paymentMethod == 'PAYPAL' ? Icons.paypal_rounded : Icons.money_rounded,
                      size: 13,
                      color: reservation.paymentStatus == 'PAGADO' ? Colors.green : Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reservation.paymentMethod == 'PAYPAL'
                          ? 'PayPal: ${reservation.paymentStatus}'
                          : 'Efectivo: ${reservation.paymentStatus}',
                      style: TextStyle(
                        color: reservation.paymentStatus == 'PAGADO' ? Colors.green : Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Botones Aceptar / Rechazar / Reportar / Confirmar Pago ─────────────
            if (onAccept != null || onReject != null || onReport != null || onConfirmPayment != null) ...[
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: onAccept,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Aceptar'),
                      ),
                    ),
                  if (onConfirmPayment != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: onConfirmPayment,
                        icon: const Icon(Icons.payments, size: 16),
                        label: const Text('Confirmar Pago'),
                      ),
                    ),
                  if (onReport != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: onReport,
                        icon: const Icon(Icons.flag_outlined, size: 16),
                        label: const Text('Reportar'),
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor() {
    switch (reservation.status) {
      case ReservationStatus.PENDING:
        return AppTheme.statusScheduledColor;
      case ReservationStatus.ACCEPTED:
        return AppTheme.accentColor;
      case ReservationStatus.REJECTED:
        return Colors.redAccent;
      case ReservationStatus.CANCELLED:
        return Colors.grey;
    }
  }
}

// ─── Badge de estado ─────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case ReservationStatus.PENDING:
        color = AppTheme.statusScheduledColor;
        label = 'Pendiente';
        break;
      case ReservationStatus.ACCEPTED:
        color = AppTheme.accentColor;
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
