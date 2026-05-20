import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'bloc/ClientSearchTripsBloc.dart';
import 'bloc/ClientSearchTripsEvent.dart';
import 'bloc/ClientSearchTripsState.dart';

class ClientSearchTripsPage extends StatefulWidget {
  const ClientSearchTripsPage({super.key});

  @override
  State<ClientSearchTripsPage> createState() => _ClientSearchTripsPageState();
}

class _ClientSearchTripsPageState extends State<ClientSearchTripsPage> {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientSearchTripsBloc>().add(const SearchTrips());
    });
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Column(
        children: [
          _searchPanel(),
          Expanded(
            child: BlocBuilder<ClientSearchTripsBloc, ClientSearchTripsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
                }
                if (state.response is ErrorData) {
                  return _errorState((state.response as ErrorData).message);
                }
                if (state.trips.isEmpty) {
                  return _emptyState();
                }
                return RefreshIndicator(
                  color: const Color(0xFF00C896),
                  backgroundColor: const Color(0xFF1A2E44),
                  onRefresh: () async => context.read<ClientSearchTripsBloc>().add(const SearchTrips()),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
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

  Widget _searchPanel() {
    return Container(
      color: const Color(0xFF1A2E44),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          // Row with origin/destination filters removed as requested

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E3A5F)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF00C896), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Cualquier fecha',
                          style: TextStyle(
                            color: _selectedDate != null ? Colors.white : const Color(0xFF4A6278),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C896),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => context.read<ClientSearchTripsBloc>().add(const SearchTrips()),
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Buscar'),
              ),
              const SizedBox(width: 6),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1B2A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _originCtrl.clear();
                  _destCtrl.clear();
                  setState(() => _selectedDate = null);
                  context.read<ClientSearchTripsBloc>().add(const ClearFilters());
                  context.read<ClientSearchTripsBloc>().add(const SearchTrips());
                },
                icon: const Icon(Icons.clear, color: Color(0xFF8BA3BC), size: 18),
              ),
            ],
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
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      if (mounted) {
        context.read<ClientSearchTripsBloc>().add(FilterDateChanged(date.toIso8601String().split('T')[0]));
      }
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          const Text('No se encontraron viajes', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Intenta cambiar los filtros de búsqueda', style: TextStyle(color: Color(0xFF4A6278), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C896)),
            onPressed: () => context.read<ClientSearchTripsBloc>().add(const SearchTrips()),
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Function(String) onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4A6278), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF00C896), size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00C896)),
        ),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: onChanged,
    );
  }
}

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
          color: const Color(0xFF1A2E44),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E3A5F)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // Route header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF00C896), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(trip.originZone, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  const Icon(Icons.arrow_forward, color: Color(0xFF4A6278), size: 16),
                  const SizedBox(width: 6),
                  const Icon(Icons.flag, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(trip.destinationZone, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E3A5F), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  _chip(Icons.access_time, _formatDateTime(trip.departureTime), const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _chip(Icons.people, '${trip.availableSeats} cupos', const Color(0xFF00C896)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C896).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00C896).withOpacity(0.4)),
                    ),
                    child: Text(
                      '\$${trip.farePerSeat.toStringAsFixed(2)}',
                      style: const TextStyle(color: Color(0xFF00C896), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            if (trip.driver != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Color(0xFF4A6278)),
                    const SizedBox(width: 4),
                    Text(
                      'Conductor: ${trip.driver!.name} ${trip.driver!.lastname}',
                      style: const TextStyle(color: Color(0xFF4A6278), fontSize: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${dt.day} ${months[dt.month]} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
