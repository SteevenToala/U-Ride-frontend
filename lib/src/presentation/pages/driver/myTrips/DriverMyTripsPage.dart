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
  TripStatus? _filter;

  static const _filterDefs = <({String label, TripStatus? status, IconData icon})>[
    (label: 'Todos',       status: null,                 icon: Icons.grid_view_rounded),
    (label: 'Programados', status: TripStatus.SCHEDULED, icon: Icons.schedule_rounded),
    (label: 'En curso',    status: TripStatus.ACTIVE,    icon: Icons.directions_car_rounded),
    (label: 'Finalizados', status: TripStatus.FINISHED,  icon: Icons.check_circle_outline_rounded),
    (label: 'Cancelados',  status: TripStatus.CANCELLED, icon: Icons.cancel_outlined),
  ];

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
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.driverColor),
              );
            }
            final filtered = _filter == null
                ? state.trips
                : state.trips.where((t) => t.status == _filter).toList();

            return Column(
              children: [
                _pageHeader(state.trips),
                if (state.trips.isNotEmpty) _filterBar(state.trips),
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.driverColor,
                    backgroundColor: AppTheme.backgroundDarkSecondary,
                    onRefresh: () async {
                      if (_driverId != null) {
                        context
                            .read<DriverMyTripsBloc>()
                            .add(LoadMyTrips(idDriver: _driverId!));
                      }
                    },
                    child: state.trips.isEmpty
                        ? _emptyState(null)
                        : filtered.isEmpty
                            ? _emptyState(_filter)
                            : _buildContent(context, filtered),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _publishFab(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _pageHeader(List<SharedTrip> trips) {
    final active    = trips.where((t) => t.isActive).length;
    final scheduled = trips.where((t) => t.isScheduled).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.driverColor.withValues(alpha: 0.22),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.driverGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.driverColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mis Viajes',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 17)),
                Text('${trips.length} publicado${trips.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          if (active > 0) ...[
            _pill('$active en curso', AppTheme.accentColor),
            const SizedBox(width: 6),
          ],
          if (scheduled > 0) _pill('$scheduled prog.', AppTheme.statusScheduledColor),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );

  // ── Filter bar ────────────────────────────────────────────────────────────

  Widget _filterBar(List<SharedTrip> trips) {
    return Container(
      color: AppTheme.backgroundDarkSecondary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filterDefs.map((f) {
            final count = f.status == null
                ? trips.length
                : trips.where((t) => t.status == f.status).length;
            if (count == 0 && f.status != null) return const SizedBox.shrink();
            final active = _filter == f.status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filter = f.status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.driverColor.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? AppTheme.driverColor.withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(f.icon,
                          size: 13,
                          color: active
                              ? AppTheme.driverColorLight
                              : Colors.white54),
                      const SizedBox(width: 6),
                      Text(f.label,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                          )),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.driverColor.withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('$count',
                            style: TextStyle(
                              color: active ? Colors.white : Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Responsive content ────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, List<SharedTrip> trips) {
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
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 100),
              itemCount: trips.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCard(context, trips[i]),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 100),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: trips
                  .map((t) => SizedBox(
                        width: cardW,
                        child: _buildCard(context, t),
                      ))
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCard(BuildContext context, SharedTrip t) {
    return _TripCard(
      trip: t,
      onStart: () => _confirm(context,
          title: '¿Iniciar viaje?',
          message: 'El viaje comenzará y no podrás editar la información.',
          onConfirm: () =>
              context.read<DriverMyTripsBloc>().add(StartTrip(idTrip: t.id!)),
          confirmColor: AppTheme.accentColor),
      onCancel: () => _confirm(context,
          title: '¿Cancelar viaje?',
          message: 'Los pasajeros confirmados serán notificados.',
          onConfirm: () => context
              .read<DriverMyTripsBloc>()
              .add(CancelDriverTrip(idTrip: t.id!)),
          isDestructive: true),
      onFinish: () => _confirm(context,
          title: '¿Finalizar viaje?',
          message: 'Marca el viaje como completado.',
          onConfirm: () =>
              context.read<DriverMyTripsBloc>().add(FinishTrip(idTrip: t.id!)),
          confirmColor: AppTheme.accentColor),
      onDelete: () => _confirm(context,
          title: '¿Eliminar viaje?',
          message: 'Esta acción no se puede deshacer.',
          onConfirm: () =>
              context.read<DriverMyTripsBloc>().add(DeleteTrip(idTrip: t.id!)),
          isDestructive: true),
      onEdit: () => Navigator.pushNamed(context, 'driver/shared-trips/publish',
              arguments: {'idDriver': _driverId, 'tripToEdit': t})
          .then((_) {
        if (mounted && _driverId != null) {
          context
              .read<DriverMyTripsBloc>()
              .add(LoadMyTrips(idDriver: _driverId!));
        }
      }),
      onViewReservations: () => Navigator.pushNamed(
              context, 'driver/shared-trips/reservations',
              arguments: {'trip': t})
          .then((_) {
        if (mounted && _driverId != null) {
          context
              .read<DriverMyTripsBloc>()
              .add(LoadMyTrips(idDriver: _driverId!));
        }
      }),
      onViewRoute: (t.originLat != null && t.originLat != 0.0)
          ? () => Navigator.pushNamed(context, 'driver/shared-trips/route-map',
              arguments: {'trip': t})
          : null,
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────

  Widget _publishFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.driverGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppTheme.driverColor.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => Navigator.pushNamed(context, 'driver/shared-trips/publish',
                arguments: {'idDriver': _driverId})
            .then((_) {
          if (mounted && _driverId != null) {
            context
                .read<DriverMyTripsBloc>()
                .add(LoadMyTrips(idDriver: _driverId!));
          }
        }),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nuevo Viaje',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
      ),
    );
  }

  // ── Empty states ───────────────────────────────────────────────────────────

  Widget _emptyState(TripStatus? forFilter) {
    final String title;
    final String subtitle;
    final IconData icon;
    switch (forFilter) {
      case TripStatus.SCHEDULED:
        title = 'Sin viajes programados';
        subtitle = 'Publica un nuevo viaje con el botón +';
        icon = Icons.schedule_rounded;
      case TripStatus.ACTIVE:
        title = 'Sin viajes en curso';
        subtitle = 'Inicia un viaje programado para verlo aquí';
        icon = Icons.directions_car_rounded;
      case TripStatus.FINISHED:
        title = 'Sin viajes finalizados';
        subtitle = 'Tu historial de viajes completados';
        icon = Icons.check_circle_outline_rounded;
      case TripStatus.CANCELLED:
        title = 'Sin viajes cancelados';
        subtitle = '';
        icon = Icons.cancel_outlined;
      default:
        title = 'No tienes viajes publicados';
        subtitle = 'Toca el botón + para publicar tu primer viaje';
        icon = Icons.directions_car_outlined;
    }
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
              child: Icon(icon,
                  size: 38,
                  color: AppTheme.driverColor.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(subtitle,
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

  // ── Confirm dialog ─────────────────────────────────────────────────────────

  Future<void> _confirm(BuildContext context,
      {required String title,
      required String message,
      required VoidCallback onConfirm,
      bool isDestructive = false,
      Color? confirmColor}) async {
    final color =
        isDestructive ? Colors.redAccent : (confirmColor ?? AppTheme.driverColor);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }
}

// ══ Trip Card ════════════════════════════════════════════════════════════════

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
        TripStatus.SCHEDULED => AppTheme.statusScheduledColor,
        TripStatus.ACTIVE    => AppTheme.accentColor,
        TripStatus.FINISHED  => AppTheme.statusFinishedColor,
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
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: status + date ──────────────────────────────────
            Row(
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _sc.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: _sc.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_si, color: _sc, size: 11),
                      const SizedBox(width: 4),
                      Text(_sl,
                          style: TextStyle(
                              color: _sc,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3)),
                    ],
                  ),
                ),
                const Spacer(),
                // Date + time
                Icon(Icons.calendar_today_rounded,
                    size: 11, color: Colors.white38),
                const SizedBox(width: 4),
                Text(_formatDate(trip.departureTime),
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),

            const SizedBox(height: 14),

            // ── Row 2: route with dots ────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dot connector
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentColor,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                              width: 1.5,
                              color: AppTheme.borderSubtle),
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.backgroundDark,
                          border: Border.all(
                              color: AppTheme.textMuted, width: 1.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Route texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ORIGEN',
                                style: TextStyle(
                                    color: AppTheme.textFaint,
                                    fontSize: 9,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 1),
                            Text(trip.originZone,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DESTINO',
                                style: TextStyle(
                                    color: AppTheme.textFaint,
                                    fontSize: 9,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 1),
                            Text(trip.destinationZone,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Row 3: seats + time + price ───────────────────────────
            Row(
              children: [
                _metaChip(
                  icon: Icons.people_rounded,
                  label: trip.isFinished || trip.isCancelled
                      ? '${trip.totalSeats - trip.availableSeats}/${trip.totalSeats} ocupados'
                      : '${trip.availableSeats}/${trip.totalSeats} libres',
                  color: Colors.white54,
                ),
                const SizedBox(width: 10),
                _metaChip(
                  icon: Icons.access_time_rounded,
                  label: _formatTime(trip.departureTime),
                  color: Colors.white54,
                ),
                const Spacer(),
                // Price — prominent badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.statusScheduledColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            AppTheme.statusScheduledColor.withValues(alpha: 0.35),
                        width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money_rounded,
                          size: 13,
                          color: AppTheme.statusScheduledColor),
                      Text(
                        '${trip.farePerSeat.toStringAsFixed(2)}/p',
                        style: TextStyle(
                          color: AppTheme.statusScheduledColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (trip.notes != null && trip.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.notes_rounded, size: 12, color: Colors.white24),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trip.notes!,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            Container(height: 1, color: AppTheme.dividerColor),
            const SizedBox(height: 10),

            // ── Actions ───────────────────────────────────────────────
            _buildActions(),
          ],
        ),
      ),
      // Left accent strip
      Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: Container(width: 4, color: _sc),
      ),
    ],   // Stack
    ),   // ClipRRect
    ),   // Container
    );
  }

  // ── Meta chip ─────────────────────────────────────────────────────────────

  Widget _metaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      );

  // ── Actions ───────────────────────────────────────────────────────────────

  Widget _buildActions() {
    if (trip.isScheduled) {
      return Column(
        children: [
          // Secondary row
          Row(children: [
            Expanded(
                child: _ghostBtn('Ver Reservas', Icons.people_rounded,
                    onViewReservations)),
            const SizedBox(width: 8),
            Expanded(child: _ghostBtn('Editar', Icons.edit_rounded, onEdit)),
            const SizedBox(width: 8),
            _iconGhostBtn(Icons.cancel_rounded, Colors.redAccent, onCancel),
          ]),
          const SizedBox(height: 8),
          // Primary action
          _primaryBtn('Iniciar viaje', Icons.play_arrow_rounded,
              AppTheme.accentColor, onStart),
        ],
      );
    }

    if (trip.isActive) {
      return Column(
        children: [
          if (onViewRoute != null) ...[
            Row(children: [
              Expanded(
                  child: _ghostBtn('Pasajeros', Icons.people_rounded,
                      onViewReservations)),
              const SizedBox(width: 8),
              Expanded(
                  child: _ghostBtn(
                      'Ver Ruta', Icons.map_rounded, onViewRoute!)),
            ]),
            const SizedBox(height: 8),
          ] else ...[
            _ghostBtn('Ver Pasajeros', Icons.people_rounded, onViewReservations),
            const SizedBox(height: 8),
          ],
          _primaryBtn('Finalizar viaje', Icons.check_circle_rounded,
              AppTheme.accentColor, onFinish),
        ],
      );
    }

    if (trip.isFinished) {
      return Row(children: [
        Expanded(
            child: _ghostBtn(
                'Ver Pasajeros', Icons.people_outline, onViewReservations)),
        if (onViewRoute != null) ...[
          const SizedBox(width: 8),
          Expanded(
              child: _ghostBtn('Ver Ruta', Icons.map_rounded, onViewRoute!)),
        ],
      ]);
    }

    // CANCELLED
    return Row(children: [
      Expanded(
          child: _ghostBtn(
              'Ver Pasajeros', Icons.people_outline, onViewReservations)),
      const SizedBox(width: 8),
      Expanded(
          child: _destructiveBtn('Eliminar', Icons.delete_rounded, onDelete)),
    ]);
  }

  // ── Button helpers ─────────────────────────────────────────────────────────

  Widget _primaryBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HSLColor.fromColor(color)
                  .withLightness((HSLColor.fromColor(color).lightness + 0.1)
                      .clamp(0.0, 1.0))
                  .toColor(),
              color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _ghostBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: Colors.white38),
            const SizedBox(width: 5),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _destructiveBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: Colors.redAccent),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _iconGhostBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ── Date helpers ──────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
