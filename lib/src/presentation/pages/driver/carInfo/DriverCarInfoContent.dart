import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/carInfo/bloc/DriverCarInfoBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/carInfo/bloc/DriverCarInfoEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/carInfo/bloc/DriverCarInfoState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class DriverCarInfoContent extends StatelessWidget {
  final DriverCarInfoState state;

  const DriverCarInfoContent(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: state.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.driverGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.directions_car_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Datos del vehículo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  context,
                  label: 'Marca del vehículo',
                  icon: Icons.branding_watermark_outlined,
                  initialValue: state.brand.value,
                  onChanged: (text) => context
                      .read<DriverCarInfoBloc>()
                      .add(BrandChanged(brand: BlocFormItem(value: text))),
                  validator: (value) => state.brand.error,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  label: 'Placa del vehículo',
                  icon: Icons.confirmation_number_outlined,
                  keyboardType: TextInputType.text,
                  initialValue: state.plate.value,
                  onChanged: (text) => context
                      .read<DriverCarInfoBloc>()
                      .add(PlateChanged(plate: BlocFormItem(value: text))),
                  validator: (value) => state.plate.error,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  label: 'Color',
                  icon: Icons.palette_outlined,
                  initialValue: state.color.value,
                  onChanged: (text) => context
                      .read<DriverCarInfoBloc>()
                      .add(ColorChanged(color: BlocFormItem(value: text))),
                  validator: (value) => state.color.error,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.driverColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      if (state.formKey?.currentState != null) {
                        if (state.formKey!.currentState!.validate()) {
                          context.read<DriverCarInfoBloc>().add(FormSubmit());
                        }
                      } else {
                        context.read<DriverCarInfoBloc>().add(FormSubmit());
                      }
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('ACTUALIZAR DATOS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required Function(String) onChanged,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted),
        prefixIcon: Icon(icon, color: AppTheme.driverColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.driverColor, width: 2),
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
        fillColor: AppTheme.backgroundDarkCard,
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
