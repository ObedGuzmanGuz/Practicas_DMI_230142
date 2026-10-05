class DriveUrls {
  static const folderId = '1DND81M6h7MuEiA3W5dDScsmXjzyr9f-6';
  static final folder = Uri.https(
    'drive.google.com',
    '/drive/folders/$folderId',
  );
  // Contenido binario: no confundir con la página /view ni con la carpeta.
  static Uri download(String fileId) => Uri.https(
    'drive.usercontent.google.com',
    '/download',
    {'id': fileId, 'export': 'download'},
  );
  static Uri preview(String fileId) =>
      Uri.https('drive.google.com', '/file/d/$fileId/view');
}
