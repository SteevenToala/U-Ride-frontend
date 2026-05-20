import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/PlacemarkData.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'bloc/DriverPublishTripBloc.dart';
import 'bloc/DriverPublishTripEvent.dart';
import 'bloc/DriverPublishTripState.dart';

class DriverPublishTripPage extends StatefulWidget {
  final SharedTrip? tripToEdit;
  final int idDriver;

  const DriverPublishTripPage({
    super.key,
    required this.idDriver,
    this.tripToEdit,
  });

  @override
  State<DriverPublishTripPage> createState() => _DriverPublishTripPageState();
}

class _DriverPublishTripPageState extends State<DriverPublishTripPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.tripToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DriverPublishTripBloc>().add(LoadTripForEdit(widget.tripToEdit!));
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
    if (mounted) {
      context.read<DriverPublishTripBloc>().add(DepartureTimeChanged(_selectedDateTime!.toIso8601String()));
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tripToEdit != null;
    return BlocListener<DriverPublishTripBloc, DriverPublishTripState>(
      listener: (context, state) {
        if (state.response is Success) {
          Fluttertoast.showToast(
            msg: isEditing ? 'Viaje actualizado correctamente' : 'Viaje publicado correctamente',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.green,
          );
          context.read<DriverPublishTripBloc>().add(const ResetForm());
          Navigator.pop(context, true);
        } else if (state.response is ErrorData) {
          Fluttertoast.showToast(
            msg: (state.response as ErrorData).message,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A2E44),
          title: Text(
            isEditing ? 'Editar Viaje' : 'Publicar Viaje',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: BlocBuilder<DriverPublishTripBloc, DriverPublishTripState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('📍 Ruta del Viaje'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A2E44),
                          foregroundColor: const Color(0xFF00C896),
                          side: const BorderSide(color: Color(0xFF00C896)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final result = await Navigator.pushNamed(context, 'driver/shared-trips/map-picker', arguments: {'title': 'Trazar Ruta'});
                          if (result != null && result is Map<String, dynamic>) {
                            final origin = result['origin'] as PlacemarkData;
                            final dest = result['destination'] as PlacemarkData;
                            if (mounted) {
                              context.read<DriverPublishTripBloc>().add(OriginZoneChanged(origin.address, origin.lat, origin.lng));
                              context.read<DriverPublishTripBloc>().add(DestinationZoneChanged(dest.address, dest.lat, dest.lng));
                            }
                          }
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('DEFINIR RUTA EN MAPA', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.originZone.isNotEmpty)
                      _infoRow(Icons.location_on, 'Origen:', state.originZone, const Color(0xFF00C896)),
                    if (state.destinationZone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.flag, 'Destino:', state.destinationZone, Colors.orangeAccent),
                    ],
                    const SizedBox(height: 24),
                    _sectionTitle('🕐 Fecha y Hora de Salida'),
                    const SizedBox(height: 12),
                    _dateTimePicker(state),
                    const SizedBox(height: 24),
                    _sectionTitle('🚗 Detalles del Viaje'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Cupos disponibles',
                            hint: '1 - 8',
                            icon: Icons.people,
                            keyboardType: TextInputType.number,
                            initialValue: state.totalSeats,
                            onChanged: (v) => context.read<DriverPublishTripBloc>().add(TotalSeatsChanged(v)),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              final n = int.tryParse(v);
                              if (n == null || n < 1 || n > 8) return '1 a 8 cupos';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'Tarifa por persona (\$)',
                            hint: 'Ej: 1.50',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            initialValue: state.farePerSeat,
                            onChanged: (v) => context.read<DriverPublishTripBloc>().add(FarePerSeatChanged(v)),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              if (double.tryParse(v) == null) return 'Valor inválido';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Notas o reglas del viaje (opcional)',
                      hint: 'Ej: Puntualidad, no fumar, respetar normas...',
                      icon: Icons.note,
                      maxLines: 3,
                      initialValue: state.notes,
                      onChanged: (v) => context.read<DriverPublishTripBloc>().add(NotesChanged(v)),
                    ),
                    const SizedBox(height: 30),
                    _rulesCard(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate() && state.departureTime.isNotEmpty) {
                                  if (isEditing) {
                                    context.read<DriverPublishTripBloc>().add(SubmitUpdateTrip(idDriver: widget.idDriver));
                                  } else {
                                    context.read<DriverPublishTripBloc>().add(SubmitPublishTrip(idDriver: widget.idDriver));
                                  }
                                } else if (state.departureTime.isEmpty) {
                                  Fluttertoast.showToast(msg: 'Selecciona la fecha y hora de salida');
                                }
                              },
                        child: state.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEditing ? 'GUARDAR CAMBIOS' : 'PUBLICAR VIAJE',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    String? initialValue,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF8BA3BC)),
        hintStyle: const TextStyle(color: Color(0xFF4A6278)),
        prefixIcon: Icon(icon, color: const Color(0xFF00C896)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00C896), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF1A2E44),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _dateTimePicker(DriverPublishTripState state) {
    return GestureDetector(
      onTap: _pickDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E44),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDateTime != null ? const Color(0xFF00C896) : const Color(0xFF1E3A5F),
            width: _selectedDateTime != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF00C896)),
            const SizedBox(width: 12),
            Text(
              _selectedDateTime != null
                  ? _formatDateTime(_selectedDateTime!)
                  : 'Seleccionar fecha y hora',
              style: TextStyle(
                color: _selectedDateTime != null ? Colors.white : const Color(0xFF4A6278),
                fontSize: 15,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF8BA3BC)),
          ],
        ),
      ),
    );
  }

  Widget _rulesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E44),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.shield, color: Color(0xFF00C896), size: 20),
              SizedBox(width: 8),
              Text('Reglas de Seguridad U-Ride', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          _RuleItem(text: 'Solo estudiantes con correo institucional verificado'),
          _RuleItem(text: 'Respetar la puntualidad acordada'),
          _RuleItem(text: 'No compartir datos personales del grupo'),
          _RuleItem(text: 'Trato respetuoso entre todos los viajeros'),
          _RuleItem(text: 'El pago se coordina según los términos acordados'),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String text;
  const _RuleItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF00C896), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF8BA3BC), fontSize: 13))),
        ],
      ),
    );
  }
}
