import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/supervisor_request_controller.dart';
import '../../../../design_system/tokens/app_colors.dart';

class SupervisorApprovalsTab extends StatefulWidget {
  const SupervisorApprovalsTab({super.key});

  @override
  State<SupervisorApprovalsTab> createState() => _SupervisorApprovalsTabState();
}

class _SupervisorApprovalsTabState extends State<SupervisorApprovalsTab> {
  final _controller = Get.find<SupervisorRequestController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _controller.fetchApprovals();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showRejectDialog(int requestId) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Tolak Pengajuan'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Alasan penolakan (opsional)',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Get.back();
              _controller.rejectRequest(requestId, reasonController.text.isEmpty ? null : reasonController.text);
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(int requestId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Setujui Pengajuan'),
        content: const Text('Apakah Anda yakin ingin menyetujui pengajuan atasan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Get.back();
              _controller.approveRequest(requestId);
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return RefreshIndicator(
      onRefresh: () => _controller.fetchApprovals(refresh: true),
      child: Obx(() {
        if (_controller.isLoadingApprovals.value && _controller.approvalList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final sortedList = _controller.approvalList.toList()
          ..sort((a, b) {
            if (a.status == 'pending' && b.status != 'pending') return -1;
            if (a.status != 'pending' && b.status == 'pending') return 1;
            return b.createdAt.compareTo(a.createdAt);
          });

        if (sortedList.isEmpty) {
          return ListView(
            children: [
              const SizedBox(height: 100),
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: colors.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Tidak Ada Persetujuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Saat ini tidak ada pengajuan yang perlu diproses.',
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
          itemCount: sortedList.length + (_controller.isLoadingApprovals.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == sortedList.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final item = sortedList[index];
            final requester = item.user;

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
                                requester?.name ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (requester?.nip != null) ...[
                                const SizedBox(height: 2),
                                Text('NIP: ${requester!.nip}', style: TextStyle(fontSize: 12, color: colors.outline)),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Diajukan: ${DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt)}',
                                style: TextStyle(fontSize: 12, color: colors.outline),
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
                        'Diproses pada: ${DateFormat('dd MMM yyyy, HH:mm').format(item.status == 'approved' ? (item.approvedAt ?? item.updatedAt) : (item.rejectedAt ?? item.updatedAt))}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                    if (item.status == 'pending') ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => _showRejectDialog(item.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.error,
                              side: BorderSide(color: colors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Tolak'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showApproveDialog(item.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Setujui'),
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
