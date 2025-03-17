part of image_crop;

class ImageOptions {
  final int width;
  final int height;

  ImageOptions({
    required this.width,
    required this.height,
  });

  @override
  int get hashCode => Object.hash(width, height);

  @override
  bool operator ==(other) =>
      other is ImageOptions && other.width == width && other.height == height;

  @override
  String toString() => '$runtimeType(width: $width, height: $height)';
}

class ImageCrop {
  static const _channel =
      const MethodChannel('plugins.lykhonis.com/image_crop');

  static Future<bool> requestPermissions() => _channel
      .invokeMethod<bool>('requestPermissions')
      .then<bool>((result) => result ?? false);

  static Future<ImageOptions?> getImageOptions({
    required File file,
  }) async {
    final result =
        await _channel.invokeMethod('getImageOptions', {'path': file.path});

    final width = result['width'] as int?;
    final height = result['height'] as int?;

    if (width == null || height == null) return null;
    

    return ImageOptions(
      width: width,
      height: height,
    );
  }

  static Future<File?> cropImage({
    required File file,
    required Rect area,
    double? scale,
  }) =>
      _channel.invokeMethod<String>('cropImage', {
        'path': file.path,
        'left': area.left,
        'top': area.top,
        'right': area.right,
        'bottom': area.bottom,
        'scale': scale ?? 1.0,
      }).then((result) => result != null ? File(result) : null);

  static Future<File?> sampleImage({
    required File file,
    int? preferredSize,
    int? preferredWidth,
    int? preferredHeight,
  }) async {
    assert(() {
      if (preferredSize == null &&
          (preferredWidth == null || preferredHeight == null)) {
        throw ArgumentError(
            'Preferred size or both width and height of a resampled image must be specified.');
      }
      return true;
    }());

    final String? path = await _channel.invokeMethod<String>('sampleImage', {
      'path': file.path,
      'maximumWidth': preferredSize ?? preferredWidth,
      'maximumHeight': preferredSize ?? preferredHeight,
    });

    return path != null ? File(path) : null;
  }
}
