import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../controllers/supervisor_request_controller.dart';

class RequestSupervisorPage extends StatefulWidget {
  const RequestSupervisorPage({super.key});

  @override
  State<RequestSupervisorPage> createState() => _RequestSupervisorPageState();
}

class _RequestSupervisorPageState extends State<RequestSupervisorPage> {
  final _controller = Get.find<SupervisorRequestController>();
  final _reasonController = TextEditingController();
  
  Map<String, dynamic>? _selectedSupervisor;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedSupervisor == null) {
      AppFeedback.showSnackbar(
        title: 'Perhatian',
        message: 'Silakan pilih atasan terlebih dahulu',
        type: FeedbackType.warning,
      );
      return;
    }

    final success = await _controller.submitRequest(
      _selectedSupervisor!['id'] as int,
      _reasonController.text.isEmpty ? null : _reasonController.text,
    );

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppTopAppBar(
        title: 'Ajukan Atasan Baru',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih Atasan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.length < 3) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                return await _controller.searchUsers(textEditingValue.text);
              },
              displayStringForOption: (option) => option['name'] as String,
              onSelected: (option) {
                setState(() {
                  _selectedSupervisor = option;
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Ketik nama atasan (min. 3 huruf)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _selectedSupervisor != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              textEditingController.clear();
                              setState(() {
                                _selectedSupervisor = null;
                              });
                            },
                          )
                        : null,
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                        maxWidth: MediaQuery.of(context).size.width - 32,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option['name'] as String),
                            subtitle: option['nip'] != null ? Text(option['nip'] as String) : null,
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Alasan Pengajuan (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tuliskan alasan mengapa Anda mengubah atasan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Obx(() => ElevatedButton(
                  onPressed: _controller.isSubmitting.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _controller.isSubmitting.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Ajukan Atasan', style: TextStyle(fontSize: 16)),
                )),
          ],
        ),
      ),
    );
  }
}

