import 'package:dartz/dartz.dart';
import 'package:tv/domain/entities/tv.dart';
import 'package:tv/domain/usecases/search_tv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';

void main() {
  late SearchTv usecase;
  late MockTvRepository mockTvRepository;

  setUp(() {
    mockTvRepository = MockTvRepository();
    usecase = SearchTv(mockTvRepository);
  });

  final tQuery = 'Game of Thrones';
  final tTvList = <Tv>[];

  test('should get list of tv from the repository', () async {
    when(() => mockTvRepository.searchTv(tQuery))
        .thenAnswer((_) async => Right(tTvList));
    final result = await usecase.execute(tQuery);
    expect(result, Right(tTvList));
  });
}
