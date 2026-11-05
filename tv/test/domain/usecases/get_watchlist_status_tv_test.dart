import 'package:tv/domain/usecases/get_watchlist_status_tv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';

void main() {
  late GetWatchlistStatusTv usecase;
  late MockTvRepository mockTvRepository;

  setUp(() {
    mockTvRepository = MockTvRepository();
    usecase = GetWatchlistStatusTv(mockTvRepository);
  });

  test('should get watchlist status from repository', () async {
    when(() => mockTvRepository.isAddedToWatchlistTv(1))
        .thenAnswer((_) async => true);
    final result = await usecase.execute(1);
    expect(result, true);
  });
}
