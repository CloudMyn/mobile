import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return RefreshIndicator(
      onRefresh: () => _controller.fetchApprovals(refresh: true),
      child: Obx(() {
        if (_controller.isLoadingApprovals.value && _controller.approvalList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.approvalList.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 64),
              Center(child: Text('Tidak ada daftar persetujuan yang menunggu')),
            ],
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _controller.approvalList.length + (_controller.isLoadingApprovals.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _controller.approvalList.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final item = _controller.approvalList[index];
            final requester = item.user;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requester?.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (requester?.nip != null) ...[
                      const SizedBox(height: 4),
                      Text('NIP: ${requester!.nip}'),
                    ],
                    if (item.reason != null) ...[
                      const SizedBox(height: 8),
                      Text('Alasan: ${item.reason}'),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showRejectDialog(item.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Tolak'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showApproveDialog(item.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Setujui'),
                        ),
                      ],
                    ),
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
