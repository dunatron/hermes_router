library hermes_router;

// /// A Calculator.
// class Calculator {
//   /// Returns [value] plus 1.
//   int addOne(int value) => value + 1;
// }

export 'src/configuration.dart'
    show GoRoute, GoRouterState, RouteBase, ShellRoute;
export 'src/misc/extensions.dart';
export 'src/misc/inherited_router.dart';
export 'src/pages/custom_transition_page.dart';
export 'src/route_data.dart'
    show
        RouteData,
        GoRouteData,
        ShellRouteData,
        TypedRoute,
        TypedGoRoute,
        TypedShellRoute;
export 'src/router.dart';
export 'src/typedefs.dart'
    show GoRouterPageBuilder, GoRouterRedirect, GoRouterWidgetBuilder;
