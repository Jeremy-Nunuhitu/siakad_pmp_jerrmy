part of '../pimpinan_views.dart';

class _RektorCommandHero extends StatelessWidget {
  const _RektorCommandHero({
    required this.tahun,
    required this.tanggal,
    required this.campusHealth,
    required this.totalMahasiswa,
    required this.totalDosen,
    required this.topFakultas,
    required this.topProdi,
    required this.activeFilters,
  });

  final String tahun;
  final String tanggal;
  final double campusHealth;
  final int totalMahasiswa;
  final int totalDosen;
  final String topFakultas;
  final String topProdi;
  final List<String> activeFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _dashboardScoreColor(campusHealth / 100);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06285B), Color(0xFF0B57D0), Color(0xFFF9B208)],
          stops: [0, 0.68, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B57D0).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final score = _RektorHealthRing(
            value: campusHealth / 100,
            label: campusHealth.toStringAsFixed(0),
            color: scoreColor,
          );
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RektorPill(
                    icon: Icons.lock_outline,
                    label: 'Read Only',
                    foreground: Colors.white,
                  ),
                  _RektorPill(
                    icon: Icons.calendar_month_outlined,
                    label: tahun,
                    foreground: Colors.white,
                  ),
                  _RektorPill(
                    icon: Icons.today_outlined,
                    label: tanggal,
                    foreground: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Command Center Rektor',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Universitas SIAKAD dalam satu layar: performa akademik, KRS, presensi, kapasitas kelas, dan utilisasi ruangan.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _RektorHeroStat(
                    label: 'Mahasiswa',
                    value: '$totalMahasiswa',
                    icon: Icons.school_outlined,
                  ),
                  _RektorHeroStat(
                    label: 'Dosen',
                    value: '$totalDosen',
                    icon: Icons.badge_outlined,
                  ),
                  _RektorHeroStat(
                    label: 'Fakultas unggul',
                    value: topFakultas,
                    icon: Icons.account_balance_outlined,
                  ),
                  _RektorHeroStat(
                    label: 'Prodi terbesar',
                    value: topProdi,
                    icon: Icons.workspace_premium_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: activeFilters
                    .take(6)
                    .map(
                      (item) => _RektorPill(
                        icon: Icons.tune_outlined,
                        label: item,
                        foreground: Colors.white,
                      ),
                    )
                    .toList(),
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 18),
                Center(child: score),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: content),
              const SizedBox(width: 22),
              score,
            ],
          );
        },
      ),
    );
  }
}

class _RektorFilterPanel extends StatelessWidget {
  const _RektorFilterPanel({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Filter Analitik',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: children),
          ],
        ),
      ),
    );
  }
}

class _RektorExecutiveGrid extends StatelessWidget {
  const _RektorExecutiveGrid({required this.items});
  final List<_RektorExecutiveMetric> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 1100
            ? (constraints.maxWidth - 36) / 4
            : constraints.maxWidth >= 640
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _RektorKpiCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _RektorKpiCard extends StatelessWidget {
  const _RektorKpiCard({required this.item});
  final _RektorExecutiveMetric item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const Spacer(),
              Text(
                '${(item.progress.clamp(0.0, 1.0).toDouble() * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: item.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
              children: [
                TextSpan(text: item.value),
                TextSpan(
                  text: item.suffix,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: item.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: item.progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 7,
              color: item.color,
              backgroundColor: item.color.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RektorExecutiveMetric {
  const _RektorExecutiveMetric({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
    required this.progress,
    required this.note,
  });

  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final Color color;
  final double progress;
  final String note;
}

class _RektorSnapshotStrip extends StatelessWidget {
  const _RektorSnapshotStrip({required this.stats});
  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 900
              ? (constraints.maxWidth - 42) / 4
              : constraints.maxWidth >= 560
              ? (constraints.maxWidth - 14) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: stats
                .map(
                  (item) => SizedBox(
                    width: width,
                    child: _RektorMiniStat(stat: item),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _RektorMiniStat extends StatelessWidget {
  const _RektorMiniStat({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stat.value}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(stat.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _RektorActionDock extends StatelessWidget {
  const _RektorActionDock({
    required this.onOpenData,
    required this.onOpenKrs,
    required this.onOpenPresensi,
    required this.onOpenLaporan,
  });

  final VoidCallback onOpenData;
  final VoidCallback onOpenKrs;
  final VoidCallback onOpenPresensi;
  final VoidCallback onOpenLaporan;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onOpenLaporan,
          icon: const Icon(Icons.summarize_outlined),
          label: const Text('Laporan Akademik'),
        ),
        OutlinedButton.icon(
          onPressed: onOpenData,
          icon: const Icon(Icons.hub_outlined),
          label: const Text('Data Universitas'),
        ),
        OutlinedButton.icon(
          onPressed: onOpenKrs,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('KRS'),
        ),
        OutlinedButton.icon(
          onPressed: onOpenPresensi,
          icon: const Icon(Icons.co_present_outlined),
          label: const Text('Presensi'),
        ),
      ],
    );
  }
}

class _RektorInsightPanel extends StatelessWidget {
  const _RektorInsightPanel({
    required this.campusHealth,
    required this.krsApprovalRate,
    required this.presensiMahasiswaRate,
    required this.presensiDosenRate,
    required this.ruangTerpakaiRate,
    required this.waitingKrs,
    required this.unusedRooms,
    required this.fullClasses,
  });

  final double campusHealth;
  final double krsApprovalRate;
  final double presensiMahasiswaRate;
  final double presensiDosenRate;
  final double ruangTerpakaiRate;
  final int waitingKrs;
  final int unusedRooms;
  final int fullClasses;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        final left = _RektorInsightCard(
          title: 'Radar Kinerja',
          children: [
            _RektorSignalBar(label: 'KRS', value: krsApprovalRate),
            _RektorSignalBar(
              label: 'Presensi Mahasiswa',
              value: presensiMahasiswaRate,
            ),
            _RektorSignalBar(label: 'Presensi Dosen', value: presensiDosenRate),
            _RektorSignalBar(
              label: 'Utilisasi Ruangan',
              value: ruangTerpakaiRate,
            ),
          ],
        );
        final right = _RektorInsightCard(
          title: 'Prioritas Hari Ini',
          children: [
            _RektorPriorityTile(
              icon: Icons.pending_actions_outlined,
              label: 'KRS menunggu validasi',
              value: waitingKrs,
            ),
            _RektorPriorityTile(
              icon: Icons.meeting_room_outlined,
              label: 'Ruangan belum terpakai',
              value: unusedRooms,
            ),
            _RektorPriorityTile(
              icon: Icons.groups_outlined,
              label: 'Kelas kapasitas penuh',
              value: fullClasses,
            ),
            _RektorPriorityTile(
              icon: Icons.monitor_heart_outlined,
              label: 'Skor kesehatan kampus',
              value: campusHealth.round(),
              suffix: '%',
            ),
          ],
        );
        if (!wide) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _RektorInsightCard extends StatelessWidget {
  const _RektorInsightCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _RektorSignalBar extends StatelessWidget {
  const _RektorSignalBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = _dashboardScoreColor(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text('${(value * 100).toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              minHeight: 10,
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

class _RektorPriorityTile extends StatelessWidget {
  const _RektorPriorityTile({
    required this.icon,
    required this.label,
    required this.value,
    this.suffix = '',
  });

  final IconData icon;
  final String label;
  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final color = value == 0 ? Colors.green : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '$value$suffix',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RektorHealthRing extends StatelessWidget {
  const _RektorHealthRing({
    required this.value,
    required this.label,
    required this.color,
  });

  final double value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 178,
      height: 178,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 178,
            height: 178,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              strokeWidth: 14,
              color: color,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Health Score',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RektorHeroStat extends StatelessWidget {
  const _RektorHeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.76)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RektorPill extends StatelessWidget {
  const _RektorPill({
    required this.icon,
    required this.label,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
