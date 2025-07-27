// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $mainLayoutShellRoute,
  $authRoute,
  $profileRoute,
];

RouteBase get $mainLayoutShellRoute => ShellRouteData.$route(
  navigatorKey: MainLayoutShellRoute.$navigatorKey,
  factory: $MainLayoutShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(path: '/', factory: _$HomeRoute._fromState),
    GoRouteData.$route(path: '/calendar', factory: _$CalendarRoute._fromState),
    GoRouteData.$route(
      path: '/essentials',

      factory: _$EssentialsRoute._fromState,
    ),
    GoRouteData.$route(path: '/meteor', factory: _$MeteorRoute._fromState),
    GoRouteData.$route(
      path: '/profile',

      factory: _$ProfileRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'additional-info',

          factory: _$CompleteProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $MainLayoutShellRouteExtension on MainLayoutShellRoute {
  static MainLayoutShellRoute _fromState(GoRouterState state) =>
      const MainLayoutShellRoute();
}

mixin _$HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => HomeRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$CalendarRoute on GoRouteData {
  static CalendarRoute _fromState(GoRouterState state) => CalendarRoute();

  @override
  String get location => GoRouteData.$location('/calendar');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$EssentialsRoute on GoRouteData {
  static EssentialsRoute _fromState(GoRouterState state) => EssentialsRoute();

  @override
  String get location => GoRouteData.$location('/essentials');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$MeteorRoute on GoRouteData {
  static MeteorRoute _fromState(GoRouterState state) => MeteorRoute();

  @override
  String get location => GoRouteData.$location('/meteor');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$CompleteProfileRoute on GoRouteData {
  static CompleteProfileRoute _fromState(GoRouterState state) =>
      CompleteProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile/additional-info');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $authRoute =>
    GoRouteData.$route(path: '/auth', factory: _$AuthRoute._fromState);

mixin _$AuthRoute on GoRouteData {
  static AuthRoute _fromState(GoRouterState state) => AuthRoute();

  @override
  String get location => GoRouteData.$location('/auth');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $profileRoute =>
    GoRouteData.$route(path: '/profile', factory: _$ProfileRoute._fromState);
