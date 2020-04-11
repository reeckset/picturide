import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mockito/mockito.dart';
import 'package:picturide/redux/reducers/app_reducer.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

Widget makeTestableWidgetRedux(
  child,
  {AppState initialState, MockNavigatorObserver navigatorObserver}
){
  if(initialState == null) initialState = AppState.create();

  final store = Store<AppState>(
        appReducer,
        initialState: initialState,
        middleware: [thunkMiddleware]);

  return 
    StoreProvider(store: store, child: 
      makeTestableWidget(child, navigatorObserver: navigatorObserver)
    );
}

Widget makeTestableWidget(child, {MockNavigatorObserver navigatorObserver}){
  return MaterialApp(
    home: child,
    navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
    onGenerateRoute: (RouteSettings routeSettings) => 
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(body: Text('mock-page'));
        }
      ),
  );
}