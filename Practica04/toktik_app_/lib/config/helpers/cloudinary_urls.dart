class CloudinaryUrls {
  static const cloudName = 'ryzcssnd';

  static Uri video(String publicId) {
    return Uri.parse(
      'https://res.cloudinary.com/$cloudName/video/upload/$publicId.mp4',
    );
  }
}