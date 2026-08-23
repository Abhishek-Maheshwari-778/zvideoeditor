import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../services/giphy_service.dart';

class GiphyPickerDialog extends StatefulWidget {
  final void Function(GiphyItem) onSelectGiphy;

  const GiphyPickerDialog({super.key, required this.onSelectGiphy});

  @override
  State<GiphyPickerDialog> createState() => _GiphyPickerDialogState();
}

class _GiphyPickerDialogState extends State<GiphyPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  bool isStickers = true;
  bool isLoading = false;
  List<GiphyItem> items = [];

  @override
  void initState() {
    super.initState();
    _fetchTrending();
  }

  Future<void> _fetchTrending() async {
    setState(() => isLoading = true);
    final results = await GiphyService.getTrending(stickersOnly: isStickers);
    if (mounted) {
      setState(() {
        items = results;
        isLoading = false;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _fetchTrending();
      return;
    }
    setState(() => isLoading = true);
    final results = await GiphyService.search(query: query, stickersOnly: isStickers);
    if (mounted) {
      setState(() {
        items = results;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.grid_view_rounded, color: Colors.black, size: 24),
                const SizedBox(width: 8),
                const Text('GIPHY Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search GIFs & Stickers...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: _search,
                  ),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Stickers'),
                  selected: isStickers,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  onSelected: (val) {
                    setState(() => isStickers = true);
                    _search(_searchController.text);
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('GIFs'),
                  selected: !isStickers,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  onSelected: (val) {
                    setState(() => isStickers = false);
                    _search(_searchController.text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : items.isEmpty
                      ? const Center(child: Text('No results found.'))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return InkWell(
                              onTap: () {
                                widget.onSelectGiphy(item);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEEEEE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(
                                    imageUrl: item.previewUrl,
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) => const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
