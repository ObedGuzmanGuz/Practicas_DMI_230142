class VideoPost {
  final int number;
  final String caption;
  final String description;
  final String videoUrl;
  final String driveFileId;
  final String source;
  final int initialLikes;
  final int initialViews;
  final int likes;
  final int views;
  final bool isLiked;
  final bool usesEmbeddedPlayer;

  const VideoPost({
    required this.number,
    required this.caption,
    this.description = '',
    required this.videoUrl,
    required this.driveFileId,
    this.source = 'Cloudinary',
    this.likes = 0,
    this.views = 0,
    int? initialLikes,
    int? initialViews,
    this.isLiked = false,
    this.usesEmbeddedPlayer = false,
  })  : initialLikes = initialLikes ?? likes,
        initialViews = initialViews ?? views;

  VideoPost copyWith({int? likes, int? views, bool? isLiked, String? description}) {
    return VideoPost(
      number: number,
      caption: caption,
      description: description ?? this.description,
      videoUrl: videoUrl,
      driveFileId: driveFileId,
      source: source,
      initialLikes: initialLikes,
      initialViews: initialViews,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      usesEmbeddedPlayer: usesEmbeddedPlayer,
    );
  }
}
