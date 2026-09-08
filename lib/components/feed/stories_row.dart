import 'package:crowdfans/components/feed/story_row_item.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:flutter/material.dart';

/// Linha de stories no topo do feed.
class StoriesRow extends StatelessWidget {
  const StoriesRow({super.key, required this.stories});

  final List<StoryItem> stories;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        itemCount: stories.length,
        itemBuilder: (context, index) => StoryRowItem(story: stories[index]),
      ),
    );
  }
}
