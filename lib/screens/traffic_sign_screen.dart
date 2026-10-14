import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/traffic_sign_card.dart';

/// Màn hình danh sách Biển báo giao thông đường bộ.
class TrafficSignScreen extends StatefulWidget {
  const TrafficSignScreen({super.key});

  @override
  State<TrafficSignScreen> createState() => _TrafficSignScreenState();
}

class _TrafficSignScreenState extends State<TrafficSignScreen> {
  String _selectedGroup = 'Tất cả';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allSigns = context.watch<QuestionProvider>().signs;

    // Tự động trích xuất các nhóm biển báo có trong dữ liệu JSON
    final groups = <String>{
      'Tất cả',
      ...allSigns.map((s) => s.group),
    }.toList();

    // Lọc biển báo theo nhóm và từ khóa tìm kiếm
    final filteredSigns = allSigns.where((sign) {
      final matchGroup =
          _selectedGroup == 'Tất cả' || sign.group == _selectedGroup;
      final query = _searchQuery.trim().toLowerCase();
      final matchSearch = query.isEmpty ||
          sign.name.toLowerCase().contains(query) ||
          sign.id.toLowerCase().contains(query) ||
          sign.meaning.toLowerCase().contains(query);
      return matchGroup && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biển báo giao thông'),
      ),
      body: Column(
        children: [
          // Ô tìm kiếm biển báo
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm mã biển (VD: P.102) hoặc tên biển báo...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Thanh lọc theo nhóm biển báo
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: groups.map((group) {
                  final selected = _selectedGroup == group;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(group),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color:
                            selected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedGroup = group),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Danh sách biển báo
          Expanded(
            child: filteredSigns.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy biển báo phù hợp.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSigns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return TrafficSignCard(sign: filteredSigns[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}