import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/overlay_layer_model.dart';
import '../../services/asset_library_service.dart';

class AssetStoreDialog extends StatefulWidget {
  final void Function(AudioTrackModel) onAddAudio;
  final void Function(OverlayLayerModel) onAddOverlay;

  const AssetStoreDialog({
    super.key,
    required this.onAddAudio,
    required this.onAddOverlay,
  });

  @override
  State<AssetStoreDialog> createState() => _AssetStoreDialogState();
}

class _AssetStoreDialogState extends State<AssetStoreDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AssetLibraryService _assetService = AssetLibraryService();
  String? downloadingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 680,
        height: 540,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Color(0xFF0078D7), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Free Media & Effects Asset Store',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF0078D7),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.music_note, size: 16), text: 'Music'),
                Tab(icon: Icon(Icons.volume_up, size: 16), text: 'Sound FX'),
                Tab(icon: Icon(Icons.emoji_emotions, size: 16), text: 'Stickers & Emojis'),
                Tab(icon: Icon(Icons.movie, size: 16), text: 'Stock Videos'),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAudioList(AssetLibraryService.musicTracks, isMusic: true),
                  _buildAudioList(AssetLibraryService.soundEffects, isMusic: false),
                  _buildStickersGrid(AssetLibraryService.stickers),
                  _buildStockVideosPlaceholder(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioList(List<MediaAssetItem> list, {required bool isMusic}) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
      itemBuilder: (context, index) {
        final item = list[index];
        final isDownloading = downloadingId == item.id;

        return ListTile(
          dense: true,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMusic ? const Color(0xFF3B82F6).withOpacity(0.2) : const Color(0xFFFF9800).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isMusic ? Icons.library_music_rounded : Icons.graphic_eq_rounded,
              color: isMusic ? const Color(0xFF3B82F6) : const Color(0xFFFF9800),
              size: 20,
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Duration: ${item.duration}  •  Size: ${item.fileSize}',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          trailing: isDownloading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D7),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 14, color: Colors.white),
                  label: const Text('Add to Project', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    setState(() => downloadingId = item.id);
                    final local = await _assetService.downloadAssetLocally(item);
                    setState(() => downloadingId = null);

                    final track = AudioTrackModel(
                      id: 'asset-${const Uuid().v4().substring(0, 8)}',
                      name: item.title,
                      filePath: local ?? item.downloadUrl,
                      startTime: 0.0,
                      duration: isMusic ? 30.0 : 2.0,
                      volume: isMusic ? 0.7 : 1.0,
                      autoDucking: isMusic,
                    );
                    widget.onAddAudio(track);
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
        );
      },
    );
  }

  Widget _buildStickersGrid(List<MediaAssetItem> list) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final isDownloading = downloadingId == item.id;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: item.previewUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white38),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 26,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: isDownloading
                      ? null
                      : () async {
                          setState(() => downloadingId = item.id);
                          final local = await _assetService.downloadAssetLocally(item);
                          setState(() => downloadingId = null);

                          final overlay = OverlayLayerModel(
                            id: 'stk-${const Uuid().v4().substring(0, 8)}',
                            name: item.title,
                            type: OverlayType.sticker,
                            content: local ?? item.downloadUrl,
                            startTime: 0.0,
                            duration: 4.0,
                            scale: 0.8,
                          );
                          widget.onAddOverlay(overlay);
                          if (mounted) Navigator.of(context).pop();
                        },
                  child: Text(
                    isDownloading ? 'Saving...' : 'Add Sticker',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockVideosPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_rounded, color: Color(0xFF0078D7), size: 48),
          SizedBox(height: 12),
          Text(
            'Pexels & Pixabay 4K Stock Video Library',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Free royalty-free video loops are ready for 1-click import.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
