import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:picturide/redux/reducers/app_reducer.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

Widget makeTestableWidgetRedux(child, {AppState initialState}){
  if(initialState == null) initialState = AppState.create();

  final store = Store<AppState>(
        appReducer,
        initialState: initialState,
        middleware: [thunkMiddleware]);

  return 
    StoreProvider(store: store, child: 
      MaterialApp(home: 
        makeTestableWidget(child)
      )
    );
}

Widget makeTestableWidget(child){
  return MaterialApp(home: child);
}