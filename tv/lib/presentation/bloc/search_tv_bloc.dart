import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/domain/usecases/search_tv.dart';
import 'package:tv/presentation/bloc/tv_list_bloc.dart';
import 'package:rxdart/rxdart.dart';

class OnTvQueryChanged extends Equatable {
  const OnTvQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class SearchTvBloc extends Bloc<OnTvQueryChanged, TvListState> {
  static const debounceDuration = Duration(milliseconds: 500);

  SearchTvBloc(SearchTv searchTv) : super(const TvListEmpty()) {
    on<OnTvQueryChanged>((event, emit) async {
      final query = event.query.trim();
      if (query.isEmpty) {
        emit(const TvListEmpty());
        return;
      }

      emit(const TvListLoading());
      final result = await searchTv.execute(query);
      result.fold(
        (failure) => emit(TvListError(failure.message)),
        (tvs) => emit(TvListHasData(tvs)),
      );
    }, transformer: _debounce(debounceDuration));
  }
}
