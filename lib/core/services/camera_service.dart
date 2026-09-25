import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Camera service managing hardware camera lifecycle, lens toggling,
/// torch, frame capture, and zero-crash fallback for simulated environments.
class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();

  CameraService._();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isInitializing = false;
  String? _initError;

  // Granular ValueNotifiers for 120 FPS UI reactivity without full tree rebuilds
  final ValueNotifier<bool> isReadyNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isTorchOnNotifier = ValueNotifier(false);
  final ValueNotifier<CameraLensDirection> lensDirectionNotifier =
      ValueNotifier(CameraLensDirection.front);

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized && _controller != null && _controller!.value.isInitialized;
  bool get isAvailable => _cameras.isNotEmpty && _initError == null;
  String? get initError => _initError;
  List<CameraDescription> get cameras => _cameras;

  /// Initializes camera hardware. If no hardware cameras are detected
  /// or an exception occurs, marks as simulated fallback mode without throwing.
  Future<bool> initialize({CameraLensDirection preferredLens = CameraLensDirection.front}) async {
    if (_isInitializing) return false;
    _isInitializing = true;
    _initError = null;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _isInitialized = false;
        _isInitializing = false;
        _initError = 'No camera hardware detected. Using interactive AR mirror simulation.';
        isReadyNotifier.value = false;
        return false;
      }

      // Find preferred lens direction (default front for mirror try-on)
      int targetIndex = _cameras.indexWhere((c) => c.lensDirection == preferredLens);
      if (targetIndex == -1) targetIndex = 0;
      _selectedCameraIndex = targetIndex;

      await _initControllerForCamera(_cameras[_selectedCameraIndex]);
      _isInitializing = false;
      return true;
    } catch (e) {
      _isInitialized = false;
      _isInitializing = false;
      _initError = 'Camera init: $e. Using interactive AR mirror fallback.';
      isReadyNotifier.value = false;
      return false;
    }
  }

  Future<void> _initControllerForCamera(CameraDescription description) async {
    await _controller?.dispose();

    final newController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await newController.initialize();
      _controller = newController;
      _isInitialized = true;
      lensDirectionNotifier.value = description.lensDirection;
      isReadyNotifier.value = true;
    } catch (e) {
      _isInitialized = false;
      _initError = 'Controller failed: $e';
      isReadyNotifier.value = false;
      await newController.dispose();
      _controller = null;
    }
  }

  /// Toggles between front and back camera
  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    isReadyNotifier.value = false;
    await _initControllerForCamera(_cameras[_selectedCameraIndex]);
  }

  /// Toggles flashlight / torch
  Future<void> toggleTorch() async {
    if (_controller == null || !_isInitialized) return;

    try {
      final current = isTorchOnNotifier.value;
      await _controller!.setFlashMode(current ? FlashMode.off : FlashMode.torch);
      isTorchOnNotifier.value = !current;
    } catch (_) {
      // Some lenses/platforms don't support torch
    }
  }

  /// Captures a live picture frame from camera
  Future<XFile?> capturePicture() async {
    if (_controller == null || !_isInitialized) return null;
    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint('Failed to capture picture: $e');
      return null;
    }
  }

  /// Disposes camera resources cleanly to prevent memory leaks
  Future<void> dispose() async {
    isReadyNotifier.value = false;
    _isInitialized = false;
    await _controller?.dispose();
    _controller = null;
  }
}
