import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/components/feedback/app_dialog.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/supervisor_request_controller.dart';
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

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  final _controller = Get.find<SupervisorRequestController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _controller.fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, int requestId) {
    AppDialog.confirm(
      title: 'Batalkan Pengajuan',
      message: 'Apakah Anda yakin ingin membatalkan pengajuan atasan ini?',
      confirmLabel: 'Ya, Batal',
      cancelLabel: 'Kembali',
      isDestructive: true,
      onConfirm: () => _controller.deleteRequest(requestId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return RefreshIndicator(
      onRefresh: () => _controller.fetchHistory(refresh: true),
      child: Obx(() {
        if (_controller.isLoadingHistory.value && _controller.historyList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.historyList.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 64),
              Center(child: Text('Belum ada riwayat pengajuan atasan')),
            ],
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _controller.historyList.length + (_controller.isLoadingHistory.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _controller.historyList.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final item = _controller.historyList[index];
            final supervisor = item.requestedSupervisor;
            final statusText = item.status == 'approved'
                ? 'Disetujui'
                : item.status == 'rejected'
                    ? 'Ditolak'
                    : 'Menunggu';
            final statusColor = item.status == 'approved'
                ? Colors.green
                : item.status == 'rejected'
                    ? Colors.red
                    : Colors.orange;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(supervisor?.name ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.reason != null) Text('Alasan: ${item.reason}'),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                isThreeLine: item.reason != null,
                trailing: item.status == 'pending'
                    ? IconButton(
                        icon: Icon(Icons.delete_outline, color: colors.error),
                        onPressed: () => _confirmDelete(context, item.id),
                      )
                    : null,
              ),
            );
          },
        );
      }),
    );
  }
}
