import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/components/feedback/app_dialog.dart';
import '../../../../design_system/tokens/app_colors.dart';
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
          variant: AppTopAppBarVariant.withBack,
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
            children: [
              const SizedBox(height: 100),
              Icon(
                Icons.history_edu,
                size: 80,
                color: colors.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Belum Ada Riwayat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Anda belum pernah mengajukan permohonan atasan.',
                  style: TextStyle(color: colors.outline),
                  textAlign: TextAlign.center,
                ),
              ),
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.outline.withOpacity(0.2)),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supervisor?.name ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Diajukan: ${DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.reason != null && item.reason!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Alasan:',
                        style: TextStyle(fontSize: 12, color: colors.outline),
                      ),
                      Text(
                        item.reason!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    if (item.status != 'pending') ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: colors.outline.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text(
                        '${item.status == 'approved' ? 'Disetujui' : 'Ditolak'} oleh ${supervisor?.name ?? 'Atasan'}',
                        style: TextStyle(fontSize: 12, color: colors.outline),
                      ),
                      Text(
                        'Pada: ${DateFormat('dd MMM yyyy, HH:mm').format(item.status == 'approved' ? (item.approvedAt ?? item.updatedAt) : (item.rejectedAt ?? item.updatedAt))}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                    if (item.status == 'pending') ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                            label: Text('Batalkan', style: TextStyle(color: colors.error)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _confirmDelete(context, item.id),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
