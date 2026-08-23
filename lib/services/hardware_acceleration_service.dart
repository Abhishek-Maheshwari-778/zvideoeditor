import 'dart:io';
import 'package:flutter/foundation.dart';

enum GpuVendor {
  nvidia,
  intel,
  amd,
  none,
}

enum HardwareAccelMode {
  autoDetect,
  nvidiaNvenc,
  intelQsv,
  amdAmf,
  cpuMultiThreaded,
  hybridCpuGpu,
}

class HardwareProfile {
  final GpuVendor gpuVendor;
  final String gpuName;
  final int cpuCores;
  final int totalRamMb;
  final bool hasHardwareEncoder;
  final HardwareAccelMode activeMode;
  final int memoryCacheLimitMb;
  final bool enableD3D11Decoding;

  const HardwareProfile({
    this.gpuVendor = GpuVendor.none,
    this.gpuName = 'Integrated Graphics / CPU Software Renderer',
    this.cpuCores = 2,
    this.totalRamMb = 4096, // 4 GB RAM Base Spec
    this.hasHardwareEncoder = false,
    this.activeMode = HardwareAccelMode.hybridCpuGpu,
    this.memoryCacheLimitMb = 512, // Optimized for 4GB RAM
    this.enableD3D11Decoding = true,
  });

  HardwareProfile copyWith({
    GpuVendor? gpuVendor,
    String? gpuName,
    int? cpuCores,
    int? totalRamMb,
    bool? hasHardwareEncoder,
    HardwareAccelMode? activeMode,
    int? memoryCacheLimitMb,
    bool? enableD3D11Decoding,
  }) {
    return HardwareProfile(
      gpuVendor: gpuVendor ?? this.gpuVendor,
      gpuName: gpuName ?? this.gpuName,
      cpuCores: cpuCores ?? this.cpuCores,
      totalRamMb: totalRamMb ?? this.totalRamMb,
      hasHardwareEncoder: hasHardwareEncoder ?? this.hasHardwareEncoder,
      activeMode: activeMode ?? this.activeMode,
      memoryCacheLimitMb: memoryCacheLimitMb ?? this.memoryCacheLimitMb,
      enableD3D11Decoding: enableD3D11Decoding ?? this.enableD3D11Decoding,
    );
  }
}

class HardwareAccelerationService {
  static final HardwareAccelerationService _instance = HardwareAccelerationService._internal();
  factory HardwareAccelerationService() => _instance;
  HardwareAccelerationService._internal();

  HardwareProfile _currentProfile = const HardwareProfile();
  HardwareProfile get profile => _currentProfile;

  /// Detects system hardware capabilities (CPU, RAM, NVIDIA/Intel/AMD GPU)
  Future<HardwareProfile> detectHardware() async {
    int cores = Platform.numberOfProcessors;
    if (cores < 2) cores = 2;

    GpuVendor vendor = GpuVendor.none;
    String gpuName = 'Intel HD Graphics / Standard CPU Renderer';
    bool hasHwEnc = false;

    if (Platform.isWindows) {
      try {
        final result = await Process.run('powershell', [
          '-Command',
          'Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name',
        ]);
        if (result.exitCode == 0) {
          final output = result.stdout.toString().toLowerCase();
          if (output.contains('nvidia') || output.contains('geforce') || output.contains('quadro')) {
            vendor = GpuVendor.nvidia;
            gpuName = result.stdout.toString().trim().split('\n').first;
            hasHwEnc = true;
          } else if (output.contains('intel') || output.contains('iris') || output.contains('uhd')) {
            vendor = GpuVendor.intel;
            gpuName = result.stdout.toString().trim().split('\n').first;
            hasHwEnc = true;
          } else if (output.contains('amd') || output.contains('radeon')) {
            vendor = GpuVendor.amd;
            gpuName = result.stdout.toString().trim().split('\n').first;
            hasHwEnc = true;
          }
        }
      } catch (e) {
        debugPrint('[HardwareDetection] GPU check error: $e');
      }
    }

    _currentProfile = HardwareProfile(
      gpuVendor: vendor,
      gpuName: gpuName,
      cpuCores: cores,
      totalRamMb: 4096, // 4GB Baseline Spec
      hasHardwareEncoder: hasHwEnc,
      activeMode: hasHwEnc ? HardwareAccelMode.hybridCpuGpu : HardwareAccelMode.cpuMultiThreaded,
      memoryCacheLimitMb: 512, // 512MB RAM cache safe for 4GB machines
      enableD3D11Decoding: true,
    );

    return _currentProfile;
  }

  void updateProfile(HardwareProfile newProfile) {
    _currentProfile = newProfile;
  }

  /// Returns optimal FFmpeg flags for hardware decoding and encoding
  List<String> getFFmpegHardwareFlags() {
    final List<String> flags = [];

    // Hardware Decoding (DirectX 11 D3D11VA)
    if (_currentProfile.enableD3D11Decoding && Platform.isWindows) {
      flags.addAll(['-hwaccel', 'd3d11va']);
    }

    // CPU Multithreading Optimization (2 Cores or 4 Cores target)
    flags.addAll(['-threads', _currentProfile.cpuCores.toString()]);

    return flags;
  }

  /// Returns the video encoder codec string (NVENC, QSV, AMF, or CPU libx264)
  String getVideoEncoderCodec() {
    switch (_currentProfile.activeMode) {
      case HardwareAccelMode.nvidiaNvenc:
        return 'h264_nvenc';
      case HardwareAccelMode.intelQsv:
        return 'h264_qsv';
      case HardwareAccelMode.amdAmf:
        return 'h264_amf';
      case HardwareAccelMode.hybridCpuGpu:
        if (_currentProfile.gpuVendor == GpuVendor.nvidia) return 'h264_nvenc';
        if (_currentProfile.gpuVendor == GpuVendor.intel) return 'h264_qsv';
        if (_currentProfile.gpuVendor == GpuVendor.amd) return 'h264_amf';
        return 'libx264';
      case HardwareAccelMode.cpuMultiThreaded:
      case HardwareAccelMode.autoDetect:
      default:
        return 'libx264';
    }
  }
}
