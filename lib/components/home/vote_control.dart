import 'package:crowdfans/components/home/vote_control_bar.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';

/// Setas de upvote/downvote com persistência via [VoteService] no post.
class VoteControl extends StatelessWidget {
  const VoteControl({super.key, required this.post, this.onVoteApplied});

  final FeedPost post;
  final ValueChanged<VoteResult>? onVoteApplied;

  @override
  Widget build(BuildContext context) {
    return VoteControlBar(
      votes: post.votes,
      myVote: post.myVote,
      onVote: (direction) => VoteService.votePost(post.id, direction),
      onVoteApplied: onVoteApplied,
    );
  }
}
