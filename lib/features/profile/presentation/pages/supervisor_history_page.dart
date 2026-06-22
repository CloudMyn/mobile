import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_typography.dart';
import 'supervisor_approvals_tab.dart';
import 'request_supervisor_page.dart';

class SupervisorHistoryPage extends StatelessWidget {
  const SupervisorHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppTopAppBar(
          title: 'Menu Atasan',
          bottom: TabBar(
            tabAlignment: TabAlignment.fill,
            labelColor: colors.primary,
            unselectedLabelColor: colors.outline,
            indicatorColor: colors.primary,
            tabs: const [
              Tab(text: 'Riwayat Atasan'),
              Tab(text: 'Persetujuan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _HistoryTab(),
            SupervisorApprovalsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const RequestSupervisorPage()),
          label: const Text('Ajukan Atasan'),
          icon: const Icon(Icons.add),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Daftar riwayat atasan (Tahap Pengembangan)'),
    );
  }
}
