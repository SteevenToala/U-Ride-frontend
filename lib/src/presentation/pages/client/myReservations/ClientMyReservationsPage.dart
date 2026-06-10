import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/ReservationStatus.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/trip-reservations/TripReservationsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/ReportUserSheet.dart';

class ClientMyReservationsPage extends StatefulWidget {
  const ClientMyReservationsPage({super.key});

  @override
  State<ClientMyReservationsPage> createState() => _ClientMyReservationsPageState();
}

class _ClientMyReservationsPageState extends State<ClientMyReservationsPage>
    with SingleTickerProviderStateMixin {
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
    setState(() {
      _passengerId = auth.user.id;
      _isLoading = true;
    });

    final useCases = GetIt.instance<TripReservationsUseCases>();
    final response = await useCases.getByPassenger.run(auth.user.id!);
    setState(() => _isLoading = false);
    if (response is Success<List<TripReservation>>) {
      setState(() => _reservations = response.data);
    } else if (response is ErrorData) {
      Fluttertoast.showToast(
          msg: (response as ErrorData).message, backgroundColor: Colors.red);
    }
  }

  Future<void> _cancelReservation(
      TripReservation reservation, TripReservationsUseCases useCases) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cancelar reserva?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          'No podrás deshacer esta acción.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
      Fluttertoast.showToast(
          msg: (response as ErrorData<TripReservation>).message,
          backgroundColor: Colors.red);
    }
  }

  Future<void> _editReservation(
      TripReservation reservation, TripReservationsUseCases useCases) async {
    final meetingPointCtrl = TextEditingController(text: reservation.meetingPoint);
    final messageCtrl = TextEditingController(text: reservation.message);
    String metodoPago = reservation.paymentMethod;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.backgroundDarkCard,
          title: const Text('Editar Solicitud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: meetingPointCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Punto de encuentro',
                  hintStyle: const TextStyle(color: AppTheme.textFaint),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.accentColor),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundDark,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Observaciones / Mensaje',
                  hintStyle: const TextStyle(color: AppTheme.textFaint),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.accentColor),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundDark,
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MÉTODO DE PAGO',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentMethodOption(
                    type: 'EFECTIVO',
                    icon: Icons.money_rounded,
                    label: 'Efectivo',
                    selected: metodoPago == 'EFECTIVO',
                    onTap: () => setS(() => metodoPago = 'EFECTIVO'),
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentMethodOption(
                    type: 'PAYPAL',
                    icon: Icons.paypal_rounded,
                    label: 'PayPal',
                    selected: metodoPago == 'PAYPAL',
                    onTap: () => setS(() => metodoPago = 'PAYPAL'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final updatedRes = TripReservation(
                  idTrip: reservation.idTrip,
                  idPassenger: reservation.idPassenger,
                  meetingPoint: meetingPointCtrl.text.isNotEmpty ? meetingPointCtrl.text : null,
                  message: messageCtrl.text.isNotEmpty ? messageCtrl.text : null,
                  paymentMethod: metodoPago,
                );
                final response = await useCases.update.run(reservation.id!, updatedRes);
                if (response is Success) {
                  Fluttertoast.showToast(msg: 'Solicitud actualizada con éxito', backgroundColor: Colors.green);
                  _loadReservations();
                } else if (response is ErrorData) {
                  Fluttertoast.showToast(msg: (response as ErrorData).message, backgroundColor: Colors.red);
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String type,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.accentColor.withOpacity(0.15) : AppTheme.backgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppTheme.accentColor : AppTheme.borderSubtle),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppTheme.accentColor : Colors.white54, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.accentColor : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _payWithPaypal(TripReservation reservation, TripReservationsUseCases useCases) {
    final total = reservation.seatsRequested * (reservation.trip?.farePerSeat ?? 0.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PaypalCheckoutDialog(
        total: total,
        onCreateReservation: (orderId) async {
          final response = await useCases.payPaypal.run(reservation.id!, orderId);
          if (response is Success) {
            return true;
          } else if (response is ErrorData) {
            Fluttertoast.showToast(msg: (response as ErrorData).message, backgroundColor: Colors.red);
            return false;
          }
          return false;
        },
        onSuccess: () {
          Fluttertoast.showToast(
            msg: '¡Pago con PayPal verificado con éxito! Tu cupo está confirmado.',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.green,
          );
          _loadReservations();
        },
      ),
    );
  }

  List<TripReservation> _filtered(ReservationStatus status) =>
      _reservations.where((r) => r.status == status).toList();

  @override
  Widget build(BuildContext context) {
    final useCases = GetIt.instance<TripReservationsUseCases>();
    final pending = _filtered(ReservationStatus.PENDING);
    final accepted = _filtered(ReservationStatus.ACCEPTED);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Column(
        children: [
          _pageHeader(),
          // Tab bar with passenger color
          Container(
            color: AppTheme.backgroundDarkSecondary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.passengerColorLight,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: [
                Tab(text: 'Pendientes (${pending.length})'),
                Tab(text: 'Aceptadas (${accepted.length})'),
                const Tab(text: 'Historial'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.passengerColor))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _reservationsList(pending, useCases,
                          canCancelFn: (r) => r.trip?.isScheduled ?? false),
                      _reservationsList(accepted, useCases,
                          canCancelFn: (r) => r.trip?.isScheduled ?? false,
                          showReport: true),
                      _historyList(),
                    ],
                  ),
          ),
        ],
      ),
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
            AppTheme.passengerColor.withValues(alpha: 0.25),
            AppTheme.backgroundDarkSecondary,
          ],
        ),
        border: Border(
          bottom: BorderSide(
              color: AppTheme.passengerColor.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppTheme.passengerGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.passengerColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis Reservas',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              Text(
                '${_reservations.length} reserva${_reservations.length != 1 ? 's' : ''} en total',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          // Refresh
          GestureDetector(
            onTap: _loadReservations,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reservationsList(
    List<TripReservation> items,
    TripReservationsUseCases? useCases, {
    bool Function(TripReservation)? canCancelFn,
    bool showReport = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.passengerColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 40,
                color: AppTheme.passengerColor.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 16),
            const Text('No hay reservas aquí',
                style: TextStyle(color: Colors.white54, fontSize: 15)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppTheme.passengerColor,
      backgroundColor: AppTheme.backgroundDarkSecondary,
      onRefresh: _loadReservations,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final r = items[i];
          final allowCancel = useCases != null &&
              (canCancelFn != null ? canCancelFn(r) : false);
          final allowEdit = useCases != null && r.status == ReservationStatus.PENDING;
          final allowPay = useCases != null &&
              r.status == ReservationStatus.ACCEPTED &&
              r.paymentMethod == 'PAYPAL' &&
              r.paymentStatus == 'PENDIENTE';
          final driverUser = r.trip?.driver;
          final driverId = driverUser?.id ?? r.trip?.idDriver;
          final driverName = driverUser != null
              ? '${driverUser.name} ${driverUser.lastname}'
              : 'el conductor';
          return _MyReservationCard(
            reservation: r,
            onCancel: allowCancel ? () => _cancelReservation(r, useCases!) : null,
            onEdit: allowEdit ? () => _editReservation(r, useCases!) : null,
            onPay: allowPay ? () => _payWithPaypal(r, useCases!) : null,
            onViewRoute: r.trip != null
                ? () => Navigator.pushNamed(
                      context,
                      'client/shared-trips/route-map',
                      arguments: {'trip': r.trip},
                    )
                : null,
            onReport: showReport && driverId != null
                ? () => ReportUserSheet.show(context, reportedUserId: driverId, reportedUserName: driverName)
                : null,
          );
        },
      ),
    );
  }

  Widget _historyList() {
    final history = _reservations
        .where((r) =>
            r.status == ReservationStatus.REJECTED ||
            r.status == ReservationStatus.CANCELLED)
        .toList();
    return _reservationsList(history, null);
  }
}

// ── Reservation card ─────────────────────────────────────────────────────────

class _MyReservationCard extends StatelessWidget {
  final TripReservation reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onViewRoute;
  final VoidCallback? onReport;
  final VoidCallback? onEdit;
  final VoidCallback? onPay;

  const _MyReservationCard({
    required this.reservation,
    this.onCancel,
    this.onViewRoute,
    this.onReport,
    this.onEdit,
    this.onPay,
  });

  Color get _statusColor {
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

  @override
  Widget build(BuildContext context) {
    final trip = reservation.trip;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status header stripe
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                _StatusChip(status: reservation.status),
                const Spacer(),
                if (trip != null)
                  Text(
                    _formatDateTime(trip.departureTime),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trip != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.radio_button_checked,
                          color: AppTheme.passengerColorLight, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(trip.originZone,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.more_vert, color: Colors.white24, size: 14),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppTheme.textMuted, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(trip.destinationZone,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  if (reservation.meetingPoint != null && reservation.meetingPoint!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_rounded,
                            color: AppTheme.accentColor, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('Punto de encuentro: ${reservation.meetingPoint}',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ] else
                  const Text('Viaje',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(Icons.people_rounded,
                        '${reservation.seatsRequested} cupo${reservation.seatsRequested > 1 ? 's' : ''}'),
                    if (trip != null)
                      _infoChip(Icons.attach_money_rounded,
                          '\$${(reservation.seatsRequested * trip.farePerSeat).toStringAsFixed(2)} total'),
                    if (reservation.isPaidWithPaypal)
                      _paypalChip()
                    else
                      _infoChip(Icons.money_rounded, 'Efectivo'),
                  ],
                ),
                const SizedBox(height: 14),
                _actionRow(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(BuildContext context) {
    final hasRoute = onViewRoute != null;
    final hasCancel = onCancel != null;
    final hasReport = onReport != null;
    final hasEdit = onEdit != null;
    final hasPay = onPay != null;

    if (!hasRoute && !hasCancel && !hasReport && !hasEdit && !hasPay) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            if (hasRoute)
              Expanded(
                child: _solidBtn(
                  label: 'Ruta',
                  icon: Icons.map_rounded,
                  color: AppTheme.passengerColor,
                  gradient: AppTheme.passengerGradient,
                  onTap: onViewRoute!,
                ),
              ),
            if (hasRoute && (hasCancel || hasEdit || hasPay)) const SizedBox(width: 8),
            if (hasEdit)
              Expanded(
                child: _solidBtn(
                  label: 'Editar',
                  icon: Icons.edit_rounded,
                  color: AppTheme.accentColor,
                  gradient: AppTheme.primaryGradient,
                  onTap: onEdit!,
                ),
              ),
            if (hasEdit && (hasCancel || hasPay)) const SizedBox(width: 8),
            if (hasPay)
              Expanded(
                child: _solidBtn(
                  label: 'Pagar',
                  icon: Icons.paypal_rounded,
                  color: const Color(0xFF0079C1),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0079C1), Color(0xFF00457C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: onPay!,
                ),
              ),
            if (hasPay && hasCancel) const SizedBox(width: 8),
            if (hasCancel)
              Expanded(
                child: _solidBtn(
                  label: 'Cancelar',
                  icon: Icons.cancel_rounded,
                  color: Colors.redAccent,
                  gradient: LinearGradient(
                    colors: [Colors.redAccent.withOpacity(0.8), Colors.redAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: onCancel!,
                ),
              ),
          ],
        ),
        if (hasReport) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onReport,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.flag_outlined, size: 14, color: Colors.orange),
                  SizedBox(width: 6),
                  Text(
                    'Reportar conductor',
                    style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _solidBtn({
    required String label,
    required IconData icon,
    required Color color,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white38),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _paypalChip() {
    const paypalBlue = Color(0xFF0079C1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: paypalBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: paypalBlue.withOpacity(0.5), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.paypal_rounded, size: 12, color: paypalBlue),
          SizedBox(width: 5),
          Text('Pagado con PayPal',
              style: TextStyle(color: paypalBlue, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
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

// ── Status chip ───────────────────────────────────────────────────────────────

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
        color = AppTheme.statusScheduledColor;
        label = 'Pendiente';
        icon = Icons.hourglass_top_rounded;
        break;
      case ReservationStatus.ACCEPTED:
        color = AppTheme.accentColor;
        label = '¡Confirmado!';
        icon = Icons.check_circle_rounded;
        break;
      case ReservationStatus.REJECTED:
        color = Colors.redAccent;
        label = 'Rechazado';
        icon = Icons.cancel_rounded;
        break;
      case ReservationStatus.CANCELLED:
        color = Colors.grey;
        label = 'Cancelado';
        icon = Icons.do_not_disturb_rounded;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
