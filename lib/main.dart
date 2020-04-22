import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:picturide/redux/reducers/app_reducer.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/view/pages/add_audio_page.dart';
import 'package:picturide/view/pages/edit_clip_page.dart';
import 'package:picturide/view/pages/home_page.dart';
import 'package:picturide/view/pages/project_page.dart';
import 'package:picturide/view/pages/export_page.dart';
import 'package:picturide/view/theme.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  final store = Store<AppState>(
    appReducer,
    initialState:  AppState.create(),
    middleware: [thunkMiddleware]);
  return runApp(App(store: store));
}

class App extends StatelessWidget {

  static final Map<String, Function> routeBuilders = {
    '/': (_) => HomePage(),
    '/add_audio_page': (_) => AddAudioPage(),
    '/edit_clip_page': (clip) => EditClipPage(clip),
    '/project_page': (_) => ProjectPage(),
    '/export_page': (_) => ExportPage(),
  };

  final Store<AppState> store;

  App({ Key key, this.store }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: themeData,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => 
              routeBuilders[settings.name](settings.arguments)
          );
        }
      )
    );
  }
}
