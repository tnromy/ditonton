import 'package:dartz/dartz.dart';
import 'package:tv/domain/usecases/get_tv_season_detail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late GetTvSeasonDetail usecase;
  late MockTvRepository mockTvRepository;

  setUp(() {
    mockTvRepository = MockTvRepository();
    usecase = GetTvSeasonDetail(mockTvRepository);
  });

  const tTvId = 1;
  const tSeasonNumber = 1;

  test('should get season detail from the repository', () async {
    when(() => mockTvRepository.getTvSeasonDetail(tTvId, tSeasonNumber))
        .thenAnswer((_) async => const Right(testSeasonDetail));
    final result = await usecase.execute(tTvId, tSeasonNumber);
    expect(result, const Right(testSeasonDetail));
  });
}
