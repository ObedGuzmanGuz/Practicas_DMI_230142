import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();
    return Scaffold(
      body: provider.initialLoading
          ? const Center(child: CircularProgressIndicator())
          : VideoScrollableView(videos: provider.videos),
    );
  }
}
