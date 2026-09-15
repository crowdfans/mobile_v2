import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';

/// Setas de upvote/downvote reutilizáveis (post ou comentário).
///
/// CF-131: pill compacta — neutro cinza, upvote verde, downvote vermelho.
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

  Color _accentFor(int voteState) {
    if (voteState == 1) {
      return AppPalette.green500;
    }
    if (voteState == -1) {
      return AppPalette.red500;
    }
    return AppPalette.platinum300;
  }

  Color _labelFor(int voteState) {
    if (voteState == 1) {
      return AppPalette.green500;
    }
    if (voteState == -1) {
      return AppPalette.red500;
    }
    return AppPalette.platinum500;
  }

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
    final accent = _accentFor(_voteState);
    final label = _labelFor(_voteState);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: accent, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 28,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VoteChevron(
              key: const Key('vote-up'),
              icon: Icons.keyboard_arrow_up,
              color: label,
              onTap: () => handleVote(1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                key: const Key('vote-count'),
                '$_voteCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: label,
                ),
              ),
            ),
            _VoteChevron(
              key: const Key('vote-down'),
              icon: Icons.keyboard_arrow_down,
              color: label,
              onTap: () => handleVote(-1),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteChevron extends StatelessWidget {
  const _VoteChevron({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
