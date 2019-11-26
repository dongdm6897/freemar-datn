import 'dart:async';

import 'package:collection/collection.dart' show ListEquality;
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class ObjectListState {
  final List<dynamic> objects;
  final bool isLoading;
  final Object error;
  final int currentPage;

  const ObjectListState({
    @required this.objects,
    @required this.isLoading,
    @required this.error,
    @required this.currentPage,
  });

  factory ObjectListState.initial() => ObjectListState(
      isLoading: false, objects: (<Object>[]), error: null, currentPage: 1);

  ObjectListState copyWith(
          {List<Object> objects,
          bool isLoading,
          Object error,
          int currentPage}) =>
      ObjectListState(
          error: error,
          objects: objects != null ? objects : this.objects,
          isLoading: isLoading ?? this.isLoading,
          currentPage: currentPage ?? this.currentPage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectListState &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(objects, other.objects) &&
          isLoading == other.isLoading;

  @override
  int get hashCode => objects.hashCode ^ isLoading.hashCode;

  @override
  String toString() =>
      'ObjectListState(objects.length=${objects.length}, isLoading=$isLoading, error=$error)';
}

class ObjectsBloc {
  ///
  /// PublishSubject emit object when max items
  ///
  final loadAllController = PublishSubject<Object>();

  ///
  /// BehaviorSubject of errors, emit null when have no error
  ///
  final errorController = BehaviorSubject<Object>.seeded(null, sync: true);
  ValueObservable<Object> errorNullable$;
  Stream<Object> errorNotNull$; // stream of errors exposed to UI

  ///
  /// PublishSubject handle load first page intent
  ///
  final loadFirstPageController = PublishSubject<Object>();

  ///
  /// PublishSubject handle load more intent
  ///
  final loadMoreController = PublishSubject<Object>();

  ///
  /// Stream of states
  ///
  ValueConnectableObservable<ObjectListState> objectsList$;
  StreamSubscription<ObjectListState> streamSubscription;

  ///
  /// Sinks
  ///
  Sink<Object> get loadMore => loadMoreController.sink;

  Sink<Object> get loadFirstPage => loadFirstPageController.sink;

  ///
  /// Streams
  ///
  Stream<ObjectListState> get objectsList => objectsList$;

  Stream<Object> get loadedAllObjects => loadAllController.stream;

  Stream<Object> get error => errorNotNull$;

  ObjectsBloc() {
    errorNullable$ = errorController;
    errorNotNull$ = errorController.where((error) => error != null);

    final Observable<ObjectListState> loadMore = loadMoreController
        .where((_) {
          final error = errorNullable$.value;
          return error == null;
        })
        .map((action) => action)
        .exhaustMap(loadMoreData);

    final Observable<ObjectListState> loadFirstPage =
        loadFirstPageController.map((action) => action).flatMap(loadMoreData);

    final Observable<Observable<ObjectListState>> streams = Observable.merge([
      loadFirstPage,
      loadMore,
    ]).map((state) => Observable.just(state));
    // merger to one stream, and map each state to Observable

    objectsList$ = Observable.switchLatest(streams).distinct().publishValueSeeded(ObjectListState.initial());

    streamSubscription = objectsList$.connect();
  }

  Stream<ObjectListState> loadMoreData(dynamic action) async* {}

  dispose() async {
    await streamSubscription.cancel();
    await Future.wait([
      loadAllController.close(),
      loadMoreController.close(),
      loadFirstPageController.close(),
      errorController.close(),
    ]);
  }
}
