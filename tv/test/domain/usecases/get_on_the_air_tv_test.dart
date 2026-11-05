import 'package:dartz/dartz.dart';
import 'package:tv/domain/entities/tv.dart';
import 'package:tv/domain/usecases/get_on_the_air_tv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';

void main() {
  late GetOnTheAirTv usecase;
  late MockTvRepository mockTvRepository;

  setUp(() {
    mockTvRepository = MockTvRepository();
    usecase = GetOnTheAirTv(mockTvRepository);
  });

  final tTvList = <Tv>[];

  test('should get list of tv from the repository', () async {
    when(() => mockTvRepository.getOnTheAirTv())
        .thenAnswer((_) async => Right(tTvList));
    final result = await usecase.execute();
    expect(result, Right(tTvList));
  });
}
