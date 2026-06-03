import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'bloc/ClientSearchTripsBloc.dart';
import 'bloc/ClientSearchTripsEvent.dart';
import 'bloc/ClientSearchTripsState.dart';

class ClientSearchTripsPage extends StatefulWidget {
  const ClientSearchTripsPage({super.key});

  @override
  State<ClientSearchTripsPage> createState() => _ClientSearchTripsPageState();
}

class _ClientSearchTripsPageState extends State<ClientSearchTripsPage> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientSearchTripsBloc>().add(const SearchTrips());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Column(
        children: [
          _header(),
          _filterBar(),
          Expanded(
            child: BlocBuilder<ClientSearchTripsBloc, ClientSearchTripsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.passengerColor),
                  );
                }
                if (state.response is ErrorData) {
                  return _errorState((state.response as ErrorData).message);
                }
                if (state.trips.isEmpty) {
                  return _emptyState();
                }
                return RefreshIndicator(
                  color: AppTheme.passengerColor,
                  backgroundColor: AppTheme.backgroundDarkSecondary,
                  onRefresh: () async =>
                      context.read<ClientSearchTripsBloc>().add(const SearchTrips()),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: state.trips.length,
                    itemBuilder: (context, i) => _TripSearchCard(
                      trip: state.trips[i],
                      onTap: () => Navigator.pushNamed(
                        context,
                        'client/shared-trips/detail',
                        arguments: {'trip': state.trips[i]},
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
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
          bottom: BorderSide(color: AppTheme.passengerColor.withValues(alpha: 0.2), width: 1),
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
            child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buscar Viajes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                'Encuentra tu próximo trayecto',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.backgroundDarkSecondary,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppTheme.passengerColor.withValues(alpha: 0.6)
                        : AppTheme.dividerColor,
                    width: _selectedDate != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: _selectedDate != null
                          ? AppTheme.passengerColorLight
                          : Colors.white38,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Cualquier fecha',
                      style: TextStyle(
                        color: _selectedDate != null ? Colors.white : Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Buscar — solid gradient button
          Container(
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
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              ),
              onPressed: () =>
                  context.read<ClientSearchTripsBloc>().add(const SearchTrips()),
              icon: const Icon(Icons.search_rounded, size: 17, color: Colors.white),
              label: const Text(
                'Buscar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Limpiar — subtle but visible
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: IconButton(
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() => _selectedDate = null);
                context.read<ClientSearchTripsBloc>().add(const ClearFilters());
                context.read<ClientSearchTripsBloc>().add(const SearchTrips());
              },
              icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.passengerColor,
            surface: AppTheme.backgroundDarkSecondary,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = date);
      context.read<ClientSearchTripsBloc>().add(
        FilterDateChanged(date.toIso8601String().split('T')[0]),
      );
    }
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
              color: AppTheme.passengerColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 46,
              color: AppTheme.passengerColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No se encontraron viajes',
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otra fecha o elimina los filtros',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.passengerGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () =>
                  context.read<ClientSearchTripsBloc>().add(const SearchTrips()),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Reintentar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trip card ────────────────────────────────────────────────────────────────

class _TripSearchCard extends StatelessWidget {
  final SharedTrip trip;
  final VoidCallback onTap;

  const _TripSearchCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.backgroundDarkSecondary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.passengerColor.withValues(alpha: 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.passengerColor.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Route strip
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: AppTheme.passengerColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked, color: AppTheme.passengerColorLight, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.originZone,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_right_alt_rounded,
                        color: Colors.white.withValues(alpha: 0.35), size: 20),
                  ),
                  const Icon(Icons.location_on_rounded, color: AppTheme.textMuted, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.destinationZone,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  _chip(Icons.access_time_rounded, _formatDateTime(trip.departureTime),
                      AppTheme.passengerColorLight),
                  const SizedBox(width: 8),
                  _chip(Icons.people_rounded, '${trip.availableSeats} cupos',
                      AppTheme.accentColor),
                  const Spacer(),
                  // Price badge — solid so always legible
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: AppTheme.passengerGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.passengerColor.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '\$${trip.farePerSeat.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            if (trip.driver != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.person_rounded, size: 13, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(width: 5),
                    Text(
                      'Conductor: ${trip.driver!.name} ${trip.driver!.lastname}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.passengerColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.passengerColor.withValues(alpha: 0.4), width: 1),
                      ),
                      child: const Text(
                        'VER DETALLE →',
                        style: TextStyle(
                          color: AppTheme.passengerColorLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dt.day} ${months[dt.month]} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
