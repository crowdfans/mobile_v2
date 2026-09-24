import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tendência tem rótulo semântico além da cor', () {
    expect(searchRankTrendLabel(SearchRankTrend.up), 'subiu');
    expect(searchRankTrendLabel(SearchRankTrend.down), 'desceu');
    expect(searchRankTrendLabel(SearchRankTrend.flat), 'estável');
  });

  test('delta positivo sobe, negativo desce, nulo/zero estável', () {
    expect(searchRankTrendFromDelta(3), SearchRankTrend.up);
    expect(searchRankTrendFromDelta(-2), SearchRankTrend.down);
    expect(searchRankTrendFromDelta(0), SearchRankTrend.flat);
    expect(searchRankTrendFromDelta(null), SearchRankTrend.flat);
  });
}
