class VideoPost {
  final int number;
  final String caption;
  final String videoUrl;
  final String driveFileId;
  final int likes;
  final int views;
  final bool isLiked;
  const VideoPost({
    required this.number,
    required this.caption,
    required this.videoUrl,
    required this.driveFileId,
    this.likes = 0,
    this.views = 0,
    this.isLiked = false,
  });
  VideoPost copyWith({int? likes, int? views, bool? isLiked}) => VideoPost(
    number: number,
    caption: caption,
    videoUrl: videoUrl,
    driveFileId: driveFileId,
    likes: likes ?? this.likes,
    views: views ?? this.views,
    isLiked: isLiked ?? this.isLiked,
  );
}
