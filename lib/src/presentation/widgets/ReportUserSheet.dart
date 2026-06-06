import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/Report.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/reports/ReportsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

/// Shows a bottom sheet for filing a misconduct report against another user.
/// Call via: `ReportUserSheet.show(context, reportedUserId: x, reportedUserName: 'Name')`
class ReportUserSheet extends StatefulWidget {
  final int reportedUserId;
  final String reportedUserName;

  const ReportUserSheet({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  static Future<void> show(
    BuildContext context, {
    required int reportedUserId,
    required String reportedUserName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportUserSheet(
        reportedUserId: reportedUserId,
        reportedUserName: reportedUserName,
      ),
    );
  }

  @override
  State<ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends State<ReportUserSheet> {
  final _reasonCtrl = TextEditingController();
  final _evidenceCtrl = TextEditingController();
  bool _isLoading = false;
  String? _selectedCategory;

  static const _categories = [
    'Comportamiento irrespetuoso',
    'No se presentó al viaje',
    'Condujo de forma peligrosa',
    'Acoso o intimidación',
    'Incumplió las reglas del viaje',
    'Otro',
  ];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _evidenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reasonCtrl.text.trim();
    if (_selectedCategory == null) {
      Fluttertoast.showToast(msg: 'Selecciona una categoría', backgroundColor: Colors.orange);
      return;
    }
    if (reason.isEmpty) {
      Fluttertoast.showToast(msg: 'Describe el motivo del reporte', backgroundColor: Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final session = await SharefPref().read('user');
    if (session == null) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'No se pudo obtener tu sesión', backgroundColor: Colors.red);
      return;
    }
    final auth = AuthResponse.fromJson(session);
    final reporterId = auth.user.id!;

    if (reporterId == widget.reportedUserId) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'No puedes reportarte a ti mismo', backgroundColor: Colors.red);
      return;
    }

    final fullReason = '$_selectedCategory: $reason';
    final evidenceUrl = _evidenceCtrl.text.trim().isEmpty ? null : _evidenceCtrl.text.trim();

    final report = Report(
      reporterUserId: reporterId,
      reportedUserId: widget.reportedUserId,
      reason: fullReason,
      evidenceUrl: evidenceUrl,
    );

    final result = await GetIt.instance<ReportsUseCases>().createReport.run(report);
    setState(() => _isLoading = false);

    if (result is Success<Report>) {
      Fluttertoast.showToast(msg: '✓ Reporte enviado al equipo de administración', backgroundColor: Colors.green);
      if (mounted) Navigator.pop(context);
    } else if (result is ErrorData) {
      Fluttertoast.showToast(msg: (result as ErrorData).message, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDarkSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reportar usuario',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    Text(
                      widget.reportedUserName,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 8),
          // Category selector
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Categoría *', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? Colors.redAccent.withOpacity(0.15) : AppTheme.inputFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? Colors.redAccent : AppTheme.borderSubtle,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: selected ? Colors.redAccent : AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Reason text field
          TextField(
            controller: _reasonCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Descripción *',
              labelStyle: const TextStyle(color: AppTheme.textMuted),
              hintText: 'Describe con detalle lo que ocurrió...',
              hintStyle: const TextStyle(color: AppTheme.textFaint, fontSize: 13),
              filled: true,
              fillColor: AppTheme.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Evidence URL (optional)
          TextField(
            controller: _evidenceCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Enlace de evidencia (opcional)',
              labelStyle: const TextStyle(color: AppTheme.textMuted),
              hintText: 'URL de imagen, video o captura...',
              hintStyle: const TextStyle(color: AppTheme.textFaint, fontSize: 13),
              prefixIcon: const Icon(Icons.link, color: AppTheme.textMuted, size: 18),
              filled: true,
              fillColor: AppTheme.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Privacy note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: AppTheme.textMuted, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu reporte es anónimo. El administrador lo revisará y aplicará las acciones necesarias.',
                    style: TextStyle(color: AppTheme.textFaint, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar Reporte', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
