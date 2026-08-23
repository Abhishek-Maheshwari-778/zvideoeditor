import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/hardware_acceleration_service.dart';

class HardwareSettingsDialog extends StatefulWidget {
  const HardwareSettingsDialog({super.key});

  @override
  State<HardwareSettingsDialog> createState() => _HardwareSettingsDialogState();
}

class _HardwareSettingsDialogState extends State<HardwareSettingsDialog> {
  final HardwareAccelerationService _hwService = HardwareAccelerationService();
  late HardwareProfile profile;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    profile = _hwService.profile;
    _runHardwareScan();
  }

  Future<void> _runHardwareScan() async {
    setState(() => isScanning = true);
    final detected = await _hwService.detectHardware();
    if (mounted) {
      setState(() {
        profile = detected;
        isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory_rounded, color: Color(0xFF0078D7), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Hardware Acceleration & Low-RAM Settings',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // Live Hardware Specs Card (Targeting 4GB RAM / 2-Core CPUs)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detected System Hardware',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (isScanning)
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        const Text('Target Spec: 4GB RAM • 2 Cores', style: TextStyle(color: Color(0xFF00C853), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.developer_board, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Text('CPU Cores: ${profile.cpuCores} Active Execution Threads', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.videogame_asset_rounded, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('GPU / iGPU: ${profile.gpuName}', style: const TextStyle(color: Colors.white70, fontSize: 11), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Acceleration Mode Selection
            const Text('Hardware Acceleration Mode', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<HardwareAccelMode>(
              value: profile.activeMode,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(
                  value: HardwareAccelMode.hybridCpuGpu,
                  child: Text('Hybrid CPU + GPU Simultaneous (Best Performance)'),
                ),
                DropdownMenuItem(
                  value: HardwareAccelMode.nvidiaNvenc,
                  child: Text('NVIDIA NVENC Hardware Acceleration'),
                ),
                DropdownMenuItem(
                  value: HardwareAccelMode.intelQsv,
                  child: Text('Intel QuickSync (QSV) Hardware Acceleration'),
                ),
                DropdownMenuItem(
                  value: HardwareAccelMode.amdAmf,
                  child: Text('AMD AMF Hardware Acceleration'),
                ),
                DropdownMenuItem(
                  value: HardwareAccelMode.cpuMultiThreaded,
                  child: Text('CPU Multi-Threaded (4GB RAM Low-Spec Safe Mode)'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  setState(() => profile = profile.copyWith(activeMode: mode));
                }
              },
            ),
            const SizedBox(height: 16),

            // RAM Memory Cache Limit (Optimized for 4GB RAM)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Memory Cache Limit', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                Text('${profile.memoryCacheLimitMb} MB (Optimized for 4GB)', style: const TextStyle(color: Color(0xFF0078D7), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: profile.memoryCacheLimitMb.toDouble(),
              min: 256,
              max: 2048,
              divisions: 7,
              activeColor: const Color(0xFF0078D7),
              onChanged: (val) => setState(() => profile = profile.copyWith(memoryCacheLimitMb: val.toInt())),
            ),
            const SizedBox(height: 8),

            // DirectX 11 D3D11VA Hardware Decoding Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('DirectX 11 (D3D11VA) Video Decoding', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              subtitle: const Text('Uses GPU hardware decoding to keep CPU usage low during playback', style: TextStyle(color: Colors.grey, fontSize: 10)),
              value: profile.enableD3D11Decoding,
              activeColor: const Color(0xFF0078D7),
              onChanged: (val) => setState(() => profile = profile.copyWith(enableD3D11Decoding: val)),
            ),
            const SizedBox(height: 20),

            // Save Settings Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D7)),
                onPressed: () {
                  _hwService.updateProfile(profile);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hardware acceleration profile applied!'), backgroundColor: Colors.green),
                  );
                },
                child: const Text('Save & Apply Hardware Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
