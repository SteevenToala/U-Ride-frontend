import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/trip-reservations/TripReservationsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';

class ClientTripDetailPage extends StatefulWidget {
  final SharedTrip trip;

  const ClientTripDetailPage({super.key, required this.trip});

  @override
  State<ClientTripDetailPage> createState() => _ClientTripDetailPageState();
}

class _ClientTripDetailPageState extends State<ClientTripDetailPage> {
  bool _isReserving = false;
  int? _passengerId;
  final _messageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPassenger();
  }

  Future<void> _loadPassenger() async {
    final pref = SharefPref();
    final session = await pref.read('user');
    if (session != null) {
      final auth = AuthResponse.fromJson(session);
      setState(() => _passengerId = auth.user.id);
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _showReserveDialog(TripReservationsUseCases useCases) async {
    int seats = 1;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: const Color(0xFF1A2E44),
          title: const Text('Reservar lugar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: seats > 1 ? () => setS(() => seats--) : null,
                    icon: const Icon(Icons.remove_circle, color: Color(0xFF00C896)),
                  ),
                  Text('$seats cupo${seats > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: seats < widget.trip.availableSeats
                        ? () => setS(() => seats++)
                        : null,
                    icon: const Icon(Icons.add_circle, color: Color(0xFF00C896)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${(seats * widget.trip.farePerSeat).toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF00C896), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Mensaje al conductor (opcional)',
                  hintStyle: const TextStyle(color: Color(0xFF4A6278)),
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
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8BA3BC))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C896),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await _doReserve(useCases, seats);
              },
              child: const Text('Confirmar Reserva'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doReserve(TripReservationsUseCases useCases, int seats) async {
    if (_passengerId == null) {
      Fluttertoast.showToast(msg: 'Error: usuario no identificado');
      return;
    }
    setState(() => _isReserving = true);
    final reservation = TripReservation(
      idTrip: widget.trip.id!,
      idPassenger: _passengerId!,
      seatsRequested: seats,
      message: _messageCtrl.text.isNotEmpty ? _messageCtrl.text : null,
    );
    final response = await useCases.create.run(reservation);
    setState(() => _isReserving = false);
    if (response is Success) {
      Fluttertoast.showToast(
        msg: '¡Reserva enviada! Espera la confirmación del conductor.',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
      );
      if (mounted) Navigator.pop(context, true);
    } else if (response is ErrorData) {
      Fluttertoast.showToast(msg: (response as ErrorData<TripReservation>).message, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    // Use GetIt to get TripReservationsUseCases
    final useCases = GetIt.instance<TripReservationsUseCases>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2E44),
        title: const Text('Detalle del Viaje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _routeCard(trip),
            const SizedBox(height: 16),
            _detailsCard(trip),
            if (trip.driver != null) ...[
              const SizedBox(height: 16),
              _driverCard(trip.driver!),
            ],
            if (trip.notes != null && trip.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _notesCard(trip.notes!),
            ],
            const SizedBox(height: 16),
            _rulesCard(),
            const SizedBox(height: 30),
            if (trip.hasAvailableSeats)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C896),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  onPressed: _isReserving ? null : () => _showReserveDialog(useCases),
                  icon: _isReserving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.bookmark_add),
                  label: Text(
                    _isReserving ? 'Reservando...' : 'RESERVAR LUGAR',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_meeting_room, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Sin cupos disponibles', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(SharedTrip trip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2E44), Color(0xFF0D2137)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00C896).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF00C896), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Origen', style: TextStyle(color: Color(0xFF8BA3BC), fontSize: 11)),
                    Text(trip.originZone, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Column(
              children: List.generate(3, (i) => Container(
                width: 2, height: 6,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: const Color(0xFF1E3A5F),
              )),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.flag, color: Color(0xFFF59E0B), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Destino', style: TextStyle(color: Color(0xFF8BA3BC), fontSize: 11)),
                    Text(trip.destinationZone, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          if (trip.originLat != 0.0 && trip.originLng != 0.0) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00C896),
                  side: const BorderSide(color: Color(0xFF00C896)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, 'client/shared-trips/route-map', arguments: {'trip': trip});
                },
                icon: const Icon(Icons.map, size: 18),
                label: const Text('Ver ruta en mapa'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailsCard(SharedTrip trip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        children: [
          _detailRow(Icons.calendar_today, 'Salida', _formatDateTime(trip.departureTime), const Color(0xFF3B82F6)),
          const Divider(color: Color(0xFF1E3A5F), height: 20),
          _detailRow(Icons.people, 'Cupos disponibles', '${trip.availableSeats} de ${trip.totalSeats}', const Color(0xFF00C896)),
          const Divider(color: Color(0xFF1E3A5F), height: 20),
          _detailRow(Icons.attach_money, 'Tarifa por persona', '\$${trip.farePerSeat.toStringAsFixed(2)}', const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _driverCard(driver) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF0D1B2A),
            backgroundImage: driver.image != null ? NetworkImage(driver.image) : null,
            child: driver.image == null ? const Icon(Icons.person, color: Color(0xFF00C896), size: 28) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Conductor', style: TextStyle(color: Color(0xFF8BA3BC), fontSize: 11)),
                Text('${driver.name} ${driver.lastname}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                if (driver.career != null)
                  Text(driver.career, style: const TextStyle(color: Color(0xFF4A6278), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Color(0xFF00C896), size: 22),
        ],
      ),
    );
  }

  Widget _notesCard(String notes) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.note, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(notes, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 13))),
        ],
      ),
    );
  }

  Widget _rulesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Color(0xFF00C896), size: 18),
              SizedBox(width: 8),
              Text('Normas de Convivencia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ...[
            'Llega puntual al punto de encuentro',
            'Trato respetuoso con todos los viajeros',
            'No compartas datos personales del grupo',
            'Respeta las normas del conductor/a',
          ].map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF00C896), size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 12))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${dt.day} ${months[dt.month]} ${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
