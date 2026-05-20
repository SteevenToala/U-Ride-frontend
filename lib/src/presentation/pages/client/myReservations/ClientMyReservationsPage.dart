import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/ReservationStatus.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/trip-reservations/TripReservationsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';

class ClientMyReservationsPage extends StatefulWidget {
  const ClientMyReservationsPage({super.key});

  @override
  State<ClientMyReservationsPage> createState() => _ClientMyReservationsPageState();
}

class _ClientMyReservationsPageState extends State<ClientMyReservationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TripReservation> _reservations = [];
  bool _isLoading = true;
  int? _passengerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    final pref = SharefPref();
    final session = await pref.read('user');
    if (session == null) return;
    final auth = AuthResponse.fromJson(session);
    setState(() { _passengerId = auth.user.id; _isLoading = true; });

    final useCases = GetIt.instance<TripReservationsUseCases>();
    final response = await useCases.getByPassenger.run(auth.user.id!);
    setState(() => _isLoading = false);
    if (response is Success<List<TripReservation>>) {
      setState(() => _reservations = response.data);
    } else if (response is ErrorData) {
      Fluttertoast.showToast(msg: (response as ErrorData).message, backgroundColor: Colors.red);
    }
  }

  Future<void> _cancelReservation(TripReservation reservation, TripReservationsUseCases useCases) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E44),
        title: const Text('¿Cancelar reserva?', style: TextStyle(color: Colors.white)),
        content: const Text('No podrás deshacer esta acción.', style: TextStyle(color: Color(0xFF8BA3BC))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No', style: TextStyle(color: Color(0xFF8BA3BC)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final response = await useCases.cancel.run(reservation.id!);
    if (response is Success<TripReservation>) {
      Fluttertoast.showToast(msg: 'Reserva cancelada', backgroundColor: Colors.orange);
      _loadReservations();
    } else if (response is ErrorData) {
      Fluttertoast.showToast(msg: (response as ErrorData<TripReservation>).message, backgroundColor: Colors.red);
    }
  }

  List<TripReservation> _filtered(ReservationStatus status) =>
      _reservations.where((r) => r.status == status).toList();

  @override
  Widget build(BuildContext context) {
    final useCases = GetIt.instance<TripReservationsUseCases>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF00C896),
            labelColor: const Color(0xFF00C896),
            unselectedLabelColor: const Color(0xFF4A6278),
            tabs: [
              Tab(text: 'Pendientes (${_filtered(ReservationStatus.PENDING).length})'),
              Tab(text: 'Aceptadas (${_filtered(ReservationStatus.ACCEPTED).length})'),
              Tab(text: 'Historial'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Solo se puede cancelar si el viaje aún está PROGRAMADO
                      _reservationsList(_filtered(ReservationStatus.PENDING), useCases,
                          canCancelFn: (r) => r.trip?.isScheduled ?? false),
                      _reservationsList(_filtered(ReservationStatus.ACCEPTED), useCases,
                          canCancelFn: (r) => r.trip?.isScheduled ?? false),
                      _historyList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _reservationsList(
    List<TripReservation> items,
    TripReservationsUseCases? useCases, {
    bool canCancel = false,
    bool Function(TripReservation)? canCancelFn,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 70, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 12),
            const Text('No hay reservas aquí', style: TextStyle(color: Colors.white38, fontSize: 15)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF00C896),
      backgroundColor: const Color(0xFF1A2E44),
      onRefresh: _loadReservations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final r = items[i];
          // Cancelación permitida solo si el viaje sigue PROGRAMADO
          final allowCancel = useCases != null &&
              (canCancelFn != null ? canCancelFn(r) : canCancel);
          return _MyReservationCard(
            reservation: r,
            onCancel: allowCancel ? () => _cancelReservation(r, useCases!) : null,
          );
        },
      ),
    );
  }

  Widget _historyList() {
    final history = _reservations
        .where((r) => r.status == ReservationStatus.REJECTED || r.status == ReservationStatus.CANCELLED)
        .toList();
    return _reservationsList(history, null);
  }
}

// Removed TripReservationsUseCasesProvider (replaced by GetIt.instance usage)

class _MyReservationCard extends StatelessWidget {
  final TripReservation reservation;
  final VoidCallback? onCancel;

  const _MyReservationCard({required this.reservation, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final trip = reservation.trip;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor().withOpacity(0.35)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (trip != null) ...[
                        Text('${trip.originZone} → ${trip.destinationZone}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(_formatDateTime(trip.departureTime),
                            style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 12)),
                      ] else
                        const Text('Viaje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _StatusChip(status: reservation.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoChip(Icons.people, '${reservation.seatsRequested} cupo${reservation.seatsRequested > 1 ? 's' : ''}'),
                const SizedBox(width: 8),
                if (trip != null)
                  _infoChip(Icons.attach_money,
                      '\$${(reservation.seatsRequested * trip.farePerSeat).toStringAsFixed(2)} total'),
              ],
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancelar Reserva'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF8BA3BC)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 12)),
        ],
      ),
    );
  }

  Color _statusColor() {
    switch (reservation.status) {
      case ReservationStatus.PENDING: return const Color(0xFFF59E0B);
      case ReservationStatus.ACCEPTED: return const Color(0xFF00C896);
      case ReservationStatus.REJECTED: return Colors.redAccent;
      case ReservationStatus.CANCELLED: return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final ReservationStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case ReservationStatus.PENDING:
        color = const Color(0xFFF59E0B); label = 'Pendiente'; icon = Icons.hourglass_top;
        break;
      case ReservationStatus.ACCEPTED:
        color = const Color(0xFF00C896); label = '¡Confirmado!'; icon = Icons.check_circle;
        break;
      case ReservationStatus.REJECTED:
        color = Colors.redAccent; label = 'Rechazado'; icon = Icons.cancel;
        break;
      case ReservationStatus.CANCELLED:
        color = Colors.grey; label = 'Cancelado'; icon = Icons.do_not_disturb;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
