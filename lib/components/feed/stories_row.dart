import 'package:crowdfans/components/feed/story_live_item.dart';
import 'package:crowdfans/components/feed/story_meet_and_greet_item.dart';
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
      height: 124,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          final type = story.featureType?.toLowerCase();
          // Meet = anel verde; demais (live / sem tipo) = anel vermelho, como no Expo e nos prints.
          if (type == 'meetandgreet') {
            return StoryMeetAndGreetItem(
              name: story.name,
              imageUri: story.imageUri,
            );
          }
          return StoryLiveItem(name: story.name, imageUri: story.imageUri);
        },
      ),
    );
  }
}
