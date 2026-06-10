import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/Report.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/AdminReportItem.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReportsBloc>().add(LoadReports());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      child: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocBuilder<AdminReportsBloc, AdminReportsState>(
              builder: (context, state) {
                final response = state.response;

                if (response is Loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentColor),
                  );
                }

                if (response is ErrorData) {
                  return _errorState((response as ErrorData).message, context);
                }

                if (response is Success<List<Report>>) {
                  final all = (response as Success<List<Report>>).data;
                  final filtered = _filter == 'ALL'
                      ? all
                      : all.where((r) => r.status.name == _filter).toList();

                  // Summary counts
                  final openCount = all.where((r) => r.status == ReportStatus.OPEN).length;
                  final warnedCount = all.where((r) => r.status == ReportStatus.WARNED).length;
                  final suspendedCount = all.where((r) => r.status == ReportStatus.ACTION_APPLIED).length;

                  return Column(
                    children: [
                      _buildSummaryBar(openCount, warnedCount, suspendedCount),
                      Expanded(
                        child: filtered.isEmpty
                            ? _emptyState()
                            : RefreshIndicator(
                                color: AppTheme.accentColor,
                                backgroundColor: AppTheme.backgroundDarkCard,
                                onRefresh: () async => context.read<AdminReportsBloc>().add(LoadReports()),
                                child: _buildContent(context, filtered),
                              ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Report> reports) {
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
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
              itemCount: reports.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AdminReportItem(reports[i]),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: reports
                  .map((r) => SizedBox(width: cardW, child: AdminReportItem(r)))
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppTheme.backgroundDarkSecondary,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('Todos', 'ALL', AppTheme.accentColor),
            const SizedBox(width: 8),
            _chip('Abiertos', 'OPEN', Colors.orange),
            const SizedBox(width: 8),
            _chip('Revisados', 'REVIEWED', Colors.blue),
            const SizedBox(width: 8),
            _chip('Advertidos', 'WARNED', Colors.amber),
            const SizedBox(width: 8),
            _chip('Suspendidos', 'ACTION_APPLIED', Colors.redAccent),
            const SizedBox(width: 8),
            _chip('Desestimados', 'DISMISSED', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, Color color) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppTheme.inputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppTheme.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppTheme.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(int open, int warned, int suspended) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDarkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Pendientes', open, Colors.orange, Icons.inbox_rounded),
              _vDivider(),
              _statItem('Advertidos', warned, Colors.amber, Icons.warning_amber_rounded),
              _vDivider(),
              _statItem('Suspendidos', suspended, Colors.redAccent, Icons.block_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36, color: AppTheme.borderSubtle);

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 14),
          Text(
            _filter == 'ALL' ? 'No hay reportes registrados' : 'Sin reportes con este estado',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text('El sistema está limpio 👍', style: TextStyle(color: AppTheme.textFaint, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _errorState(String message, BuildContext ctx) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 52, color: Colors.red.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => ctx.read<AdminReportsBloc>().add(LoadReports()),
          ),
        ],
      ),
    );
  }
}
