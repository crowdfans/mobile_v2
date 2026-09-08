import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';

/// Setas de upvote/downvote reutilizáveis (post ou comentário).
class VoteControlBar extends StatefulWidget {
  const VoteControlBar({
    super.key,
    required this.votes,
    required this.myVote,
    required this.onVote,
    this.onVoteApplied,
  });

  final int votes;
  final int myVote;
  final Future<VoteResult> Function(VoteDirection direction) onVote;
  final ValueChanged<VoteResult>? onVoteApplied;

  @override
  State<VoteControlBar> createState() => _VoteControlBarState();
}

class _VoteControlBarState extends State<VoteControlBar> {
  int? _optimisticVotes;
  int? _optimisticMyVote;
  var _submitting = false;

  int get _voteState =>
      _optimisticMyVote ?? VoteService.normalizeVoteState(widget.myVote);
  int get _voteCount => _optimisticVotes ?? widget.votes;

  Future<void> handleVote(VoteDirection direction) async {
    if (_submitting) {
      return;
    }
    final next = VoteService.getNextVoteState(
      currentState: _voteState,
      direction: direction,
    );
    setState(() {
      _optimisticMyVote = next.nextVoteState;
      _optimisticVotes = _voteCount + next.voteCountDelta;
      _submitting = true;
    });
    try {
      final result = await widget.onVote(direction);
      if (!mounted) {
        return;
      }
      setState(() {
        _optimisticMyVote = null;
        _optimisticVotes = null;
      });
      widget.onVoteApplied?.call(result);
    } catch (_) {
      if (mounted) {
        setState(() {
          _optimisticMyVote = null;
          _optimisticVotes = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final up = _voteState == 1;
    final down = _voteState == -1;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => handleVote(1),
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: up ? colors.primary : colors.icon,
            ),
          ),
          Text(
            '$_voteCount',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => handleVote(-1),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: down ? colors.danger : colors.icon,
            ),
          ),
        ],
      ),
    );
  }
}
