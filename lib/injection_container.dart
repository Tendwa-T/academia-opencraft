import 'package:academia/config/flavor.dart';
import 'package:academia/core/network/network.dart';
import 'package:academia/database/database.dart';
import 'package:academia/features/auth/data/data.dart';
import 'package:academia/features/chirp/memberships/data/repository/chirp_community_membership_repository_impl.dart';
import 'package:academia/features/features.dart';
import 'package:academia/features/institution/institution.dart';
import 'package:academia/features/permissions/permissions.dart';
import 'package:academia/features/sherehe/data/data.dart';
import 'package:academia/features/sherehe/domain/domain.dart';
import 'package:dio_request_inspector/dio_request_inspector.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;
Future<void> init(FlavorConfig flavor) async {
  final DioRequestInspector inspector = DioRequestInspector(
    isInspectorEnabled: true,
    password: '123456', // remove this line if you don't need password
    showSummary: false,
  );

  sl.registerSingleton<DioRequestInspector>(inspector);

  // Register the flavor
  sl.registerSingleton<FlavorConfig>(flavor);

  final cacheDB = sl.registerSingleton<AppDataBase>(AppDataBase());

  sl.registerFactory<AuthLocalDatasource>(
    () => AuthLocalDatasource(localDB: cacheDB),
  );

  sl.registerFactory<DioClient>(
    () => DioClient(
      flavor,
      authLocalDatasource: sl.get<AuthLocalDatasource>(),
      requestInspector: sl<DioRequestInspector>(),
    ),
  );

  sl.registerFactory(
    () => AuthRemoteDatasource(flavor: flavor, dioClient: sl()),
  );
  sl.registerFactory<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      authRemoteDatasource: sl.get<AuthRemoteDatasource>(),
      authLocalDatasource: sl.get<AuthLocalDatasource>(),
    ),
  );

  sl.registerFactory<SignInWithGoogleUsecase>(
    () => SignInWithGoogleUsecase(sl.get<AuthRepositoryImpl>()),
  );

  sl.registerFactory<SignInWithSpotifyUsecase>(
    () => SignInWithSpotifyUsecase(sl.get<AuthRepositoryImpl>()),
  );

  sl.registerFactory<GetPreviousAuthState>(
    () => GetPreviousAuthState(sl.get<AuthRepositoryImpl>()),
  );
  sl.registerFactory<RefreshVerisafeTokenUsecase>(
    () => RefreshVerisafeTokenUsecase(authRepository: sl<AuthRepositoryImpl>()),
  );

  //sherehe
  sl.registerLazySingleton<ShereheRemoteDataSource>(
    () => ShereheRemoteDataSource(dioClient: sl.get<DioClient>(), flavor: sl()),
  );
  sl.registerLazySingleton(
    () => CreateEventUseCase(sl.get<ShereheRepository>()),
  );
  sl.registerLazySingleton<ShereheLocalDataSource>(
    () => ShereheLocalDataSource(localDB: cacheDB),
  );
  sl.registerLazySingleton(() => CreateAttendeeUseCase(sl()));

  sl.registerSingleton<ShereheRepository>(
    ShereheRepositoryImpl(
      remoteDataSource: sl.get<ShereheRemoteDataSource>(),
      localDataSource: sl.get<ShereheLocalDataSource>(),
    ),
  );

  sl.registerSingleton<GetEvent>(GetEvent(sl()));
  sl.registerLazySingleton(() => GetSpecificEvent(sl()));
  sl.registerLazySingleton(() => GetAttendee(sl()));
  sl.registerLazySingleton(() => CacheEventsUseCase(sl()));

  sl.registerFactory(
    () => ShereheHomeBloc(
      getEvent: sl(),
      getAttendee: sl(),
      cacheEventsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ShereheDetailsBloc(
      getSpecificEventUseCase: sl(),
      getAttendeesUseCase: sl(),
      createAttendeeUseCase: sl(),
      getCachedUserProfileUseCase: sl(),
    ),
  );
  // Chirp
  sl.registerFactory<ChirpRemoteDataSource>(
    () => ChirpRemoteDataSource(dioClient: sl.get<DioClient>(), flavor: flavor),
  );
  sl.registerFactory<ChirpLocalDataSource>(
    () => ChirpLocalDataSource(db: cacheDB),
  );
  sl.registerFactory<ChirpRepository>(
    () => ChirpRepositoryImpl(
      remoteDataSource: sl.get<ChirpRemoteDataSource>(),
      localDataSource: sl.get<ChirpLocalDataSource>(),
    ),
  );
  sl.registerFactory(() => GetFeedPosts(sl()));
  sl.registerFactory(
    () => CachePostsUsecase(chirpRepository: sl.get<ChirpRepository>()),
  );
  sl.registerFactory(
    () => GetPostRepliesUsecase(chirpRepository: sl.get<ChirpRepository>()),
  );
  sl.registerFactory(
    () => CachePostRepliesUsecase(chirpRepository: sl.get<ChirpRepository>()),
  );
  sl.registerFactory(
    () => CommentUsecase(chirpRepository: sl.get<ChirpRepository>()),
  );
  sl.registerFactory(
    () => CreatePostUsecase(chirpRepository: sl.get<ChirpRepository>()),
  );
  sl.registerFactory(
    () => LikePostUsecase(chirpRepository: sl.get<ChirpRepository>()),
  );
  sl.registerFactory(
    () => FeedBloc(
      getFeedPosts: sl.get<GetFeedPosts>(),
      cachePosts: sl.get<CachePostsUsecase>(),
      likePost: sl.get<LikePostUsecase>(),
      createPost: sl.get<CreatePostUsecase>(),
      addComment: sl.get<CommentUsecase>(),
      cachePostReplies: sl.get<CachePostRepliesUsecase>(),
      getPostReplies: sl.get<GetPostRepliesUsecase>(),
    ),
  );
  sl.registerFactory<ProfileRemoteDatasource>(
    () =>
        ProfileRemoteDatasource(dioClient: sl.get<DioClient>(), flavor: flavor),
  );
  sl.registerFactory<ProfileLocalDatasource>(
    () => ProfileLocalDatasource(localDB: cacheDB),
  );

  sl.registerFactory<ProfileRepositoryImpl>(
    () => ProfileRepositoryImpl(
      profileLocalDatasource: sl.get<ProfileLocalDatasource>(),
      profileRemoteDatasource: sl.get<ProfileRemoteDatasource>(),
    ),
  );

  sl.registerFactory<RefreshCurrentUserProfileUsecase>(
    () => RefreshCurrentUserProfileUsecase(
      profileRepository: sl.get<ProfileRepositoryImpl>(),
    ),
  );

  sl.registerFactory<UpdateUserProfile>(
    () => UpdateUserProfile(profileRepository: sl.get<ProfileRepositoryImpl>()),
  );

  sl.registerFactory<UpdateUserPhone>(
    () => UpdateUserPhone(profileRepository: sl.get<ProfileRepositoryImpl>()),
  );

  sl.registerFactory<GetCachedProfileUsecase>(
    () => GetCachedProfileUsecase(
      profileRepository: sl.get<ProfileRepositoryImpl>(),
    ),
  );

  // Todos
  sl.registerFactory<TodoLocalDatasource>(
    () => TodoLocalDatasource(localDB: cacheDB),
  );
  sl.registerFactory<TodoRemoteDatasource>(
    () => TodoRemoteDatasource(dioClient: sl.get<DioClient>(), flavor: flavor),
  );

  sl.registerFactory<TodoRepository>(
    () => TodoRepositoryImpl(
      todoRemoteDatasource: sl.get<TodoRemoteDatasource>(),
      todoLocalDatasource: sl.get<TodoLocalDatasource>(),
    ),
  );

  sl.registerFactory<GetCachedTodosUsecase>(
    () => GetCachedTodosUsecase(todoRepository: sl.get<TodoRepository>()),
  );

  sl.registerFactory<RefreshTodosUsecase>(
    () => RefreshTodosUsecase(todoRepository: sl.get<TodoRepository>()),
  );
  sl.registerFactory<CreateTodoUsecase>(
    () => CreateTodoUsecase(todoRepository: sl.get<TodoRepository>()),
  );
  sl.registerFactory<UpdateTodoUsecase>(
    () => UpdateTodoUsecase(todoRepository: sl.get<TodoRepository>()),
  );
  sl.registerFactory<CompleteTodoUsecase>(
    () => CompleteTodoUsecase(todoRepository: sl.get<TodoRepository>()),
  );

  sl.registerFactory<DeleteTodoUsecase>(
    () => DeleteTodoUsecase(todoRepository: sl.get<TodoRepository>()),
  );

  // Agenda
  sl.registerFactory<AgendaEventLocalDataSource>(
    () => AgendaEventLocalDataSource(localDB: cacheDB),
  );
  sl.registerFactory<AgendaEventRemoteDatasource>(
    () => AgendaEventRemoteDatasource(
      dioClient: sl.get<DioClient>(),
      flavor: flavor,
    ),
  );

  sl.registerFactory<AgendaEventRepository>(
    () => AgendaEventRepositoryImpl(
      agendaEventRemoteDatasource: sl.get<AgendaEventRemoteDatasource>(),
      agendaEventLocalDataSource: sl.get<AgendaEventLocalDataSource>(),
    ),
  );

  sl.registerFactory<GetCachedAgendaEventsUsecase>(
    () => GetCachedAgendaEventsUsecase(
      agendaEventRepository: sl.get<AgendaEventRepository>(),
    ),
  );

  sl.registerFactory<RefreshAgendaEventsUsecase>(
    () => RefreshAgendaEventsUsecase(
      agendaEventRepository: sl.get<AgendaEventRepository>(),
    ),
  );

  sl.registerFactory<CreateAgendaEventUsecase>(
    () => CreateAgendaEventUsecase(
      agendaEventRepository: sl.get<AgendaEventRepository>(),
    ),
  );

  sl.registerFactory<UpdateAgendaEventUsecase>(
    () => UpdateAgendaEventUsecase(
      agendaEventRepository: sl.get<AgendaEventRepository>(),
    ),
  );

  sl.registerFactory<DeleteAgendaEventUsecase>(
    () => DeleteAgendaEventUsecase(
      agendaEventRepository: sl.get<AgendaEventRepository>(),
    ),
  );

  sl.registerFactory<AgendaEventBloc>(
    () => AgendaEventBloc(
      getCachedAgendaEventsUsecase: sl.get<GetCachedAgendaEventsUsecase>(),
      refreshAgendaEventsUsecase: sl.get<RefreshAgendaEventsUsecase>(),
      createAgendaEventUsecase: sl.get<CreateAgendaEventUsecase>(),
      updateAgendaEventUsecase: sl.get<UpdateAgendaEventUsecase>(),
      deleteAgendaEventUsecase: sl.get<DeleteAgendaEventUsecase>(),
    ),
  );

  // Communities
  sl.registerFactory<CommunityRemoteDatasource>(
    () => CommunityRemoteDatasource(
      dioClient: sl.get<DioClient>(),
      flavor: flavor,
    ),
  );

  sl.registerFactory<CommunityLocalDatasource>(
    () => CommunityLocalDatasource(localDB: sl()),
  );

  sl.registerFactory<CommunityRepositoryImpl>(
    () => CommunityRepositoryImpl(
      remoteDatasource: sl.get(),
      communityLocalDatasource: sl.get(),
    ),
  );

  sl.registerFactory<CreateCommunityUseCase>(
    () => CreateCommunityUseCase(repository: sl.get<CommunityRepositoryImpl>()),
  );

  sl.registerFactory<GetCommunityByIdUseCase>(
    () =>
        GetCommunityByIdUseCase(repository: sl.get<CommunityRepositoryImpl>()),
  );

  sl.registerFactory<ModerateMembersUseCase>(
    () => ModerateMembersUseCase(repository: sl.get<CommunityRepositoryImpl>()),
  );

  sl.registerFactory<JoinCommunityUseCase>(
    () => JoinCommunityUseCase(repository: sl.get<CommunityRepositoryImpl>()),
  );

  sl.registerFactory<LeaveCommunityUseCase>(
    () => LeaveCommunityUseCase(repository: sl.get<CommunityRepositoryImpl>()),
  );

  sl.registerFactory<DeleteCommunityUseCase>(
    () => DeleteCommunityUseCase(repository: sl.get<CommunityRepositoryImpl>()),
  );

  sl.registerFactory<GetCommunityMembersUsecase>(
    () => GetCommunityMembersUsecase(
      repository: sl.get<CommunityRepositoryImpl>(),
    ),
  );

  sl.registerFactory<AddCommunityGuidelinesUsecase>(
    () => AddCommunityGuidelinesUsecase(
      repository: sl.get<CommunityRepositoryImpl>(),
    ),
  );

  sl.registerFactory<GetPostableCommunitiesUsecase>(
    () => GetPostableCommunitiesUsecase(
      communityRepository: sl.get<CommunityRepositoryImpl>(),
    ),
  );

  sl.registerFactory(
    () => SearchForCommunityUsecase(
      communityRepository: sl.get<CommunityRepositoryImpl>(),
    ),
  );

  sl.registerFactory(
    () => CommunityListingCubit(
      getPostableCommunitiesUsecase: sl(),
      searchForCommunityUsecase: sl(),
    ),
  );

  sl.registerFactory<CommunityHomeBloc>(
    () => CommunityHomeBloc(
      getCommunityByIdUseCase: sl.get<GetCommunityByIdUseCase>(),
      moderateMembers: sl.get<ModerateMembersUseCase>(),
      joinCommunityUseCase: sl.get<JoinCommunityUseCase>(),
      leaveCommunityUseCase: sl.get<LeaveCommunityUseCase>(),
      deleteCommunityUseCase: sl.get<DeleteCommunityUseCase>(),
      addCommunityGuidelinesUsecase: sl.get<AddCommunityGuidelinesUsecase>(),
    ),
  );

  sl.registerFactory<CreateCommunityBloc>(
    () => CreateCommunityBloc(
      createCommunityUseCase: sl.get<CreateCommunityUseCase>(),
    ),
  );

  sl.registerFactory<CommunityUsersBloc>(
    () => CommunityUsersBloc(
      getCommunityMembersUsecase: sl.get<GetCommunityMembersUsecase>(),
    ),
  );

  /*************************************************************************
                                    CHIRP
  *************************************************************************/
  // -- Memberships
  sl.registerFactory<ChirpCommunityMembershipLocalDatasource>(
    () => ChirpCommunityMembershipLocalDatasource(localDB: sl()),
  );
  sl.registerFactory<ChirpCommunityMembershipRemoteDatasource>(
    () => ChirpCommunityMembershipRemoteDatasource(
      dioClient: sl(),
      flavor: flavor,
    ),
  );
  sl.registerFactory<ChirpCommunityMembershipRepository>(
    () => ChirpCommunityMembershipRepositoryImpl(
      profileLocalDatasource: sl(),
      chirpCommunityMembershipLocalDatasource: sl(),
      chirpCommunityMembershipRemoteDatasource: sl(),
    ),
  );

  sl.registerFactory<GetCachedPersonalChirpCommunityMemberships>(
    () => GetCachedPersonalChirpCommunityMemberships(repository: sl()),
  );

  sl.registerFactory<GetRemotePersonalChirpMembershipsUsecase>(
    () => GetRemotePersonalChirpMembershipsUsecase(repository: sl()),
  );

  sl.registerFactory<ChirpCommunityMembershipBloc>(
    () => ChirpCommunityMembershipBloc(
      getCachedPersonalChirpCommunityMemberships: sl(),
      getRemotePersonalChirpMembershipsUsecase: sl(),
    ),
  );
  /*************************************************************************
                              // NOTIFICATIONS
  *************************************************************************/
  sl.registerFactory<NotificationRemoteDatasource>(
    () => NotificationRemoteDatasource(),
  );
  sl.registerFactory<NotificationLocalDatasource>(
    () => NotificationLocalDatasource(localDB: cacheDB),
  );

  sl.registerFactory<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDatasource: sl.get<NotificationRemoteDatasource>(),
      localDatasource: sl.get<NotificationLocalDatasource>(),
    ),
  );

  sl.registerFactory<InitializeOneSignalUsecase>(
    () => InitializeOneSignalUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<GetNotificationsUsecase>(
    () => GetNotificationsUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<MarkNotificationAsReadUsecase>(
    () => MarkNotificationAsReadUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<MarkAllNotificationsAsReadUsecase>(
    () => MarkAllNotificationsAsReadUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<DeleteNotificationUsecase>(
    () => DeleteNotificationUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<ClearAllNotificationsUsecase>(
    () => ClearAllNotificationsUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<GetNotificationCountUsecase>(
    () => GetNotificationCountUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<GetUnreadCountUsecase>(
    () => GetUnreadCountUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<SetNotificationPermissionUsecase>(
    () => SetNotificationPermissionUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<GetNotificationPermissionUsecase>(
    () => GetNotificationPermissionUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<SendLocalNotificationUsecase>(
    () => SendLocalNotificationUsecase(sl.get<NotificationRepository>()),
  );
  sl.registerFactory<SetUserDataUsecase>(
    () => SetUserDataUsecase(repository: sl.get<NotificationRepository>()),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      initializeOneSignalUsecase: sl.get<InitializeOneSignalUsecase>(),
      getNotificationsUsecase: sl.get<GetNotificationsUsecase>(),
      markNotificationAsReadUsecase: sl.get<MarkNotificationAsReadUsecase>(),
      markAllNotificationsAsReadUsecase: sl
          .get<MarkAllNotificationsAsReadUsecase>(),
      deleteNotificationUsecase: sl.get<DeleteNotificationUsecase>(),
      clearAllNotificationsUsecase: sl.get<ClearAllNotificationsUsecase>(),
      getNotificationCountUsecase: sl.get<GetNotificationCountUsecase>(),
      getUnreadCountUsecase: sl.get<GetUnreadCountUsecase>(),
      setNotificationPermissionUsecase: sl
          .get<SetNotificationPermissionUsecase>(),
      getNotificationPermissionUsecase: sl
          .get<GetNotificationPermissionUsecase>(),
      sendLocalNotificationUsecase: sl.get<SendLocalNotificationUsecase>(),
      setUserDataUsecase: sl.get<SetUserDataUsecase>(),
    ),
  );

  // Firebase Remote Config
  sl.registerSingleton<FirebaseRemoteConfig>(FirebaseRemoteConfig.instance);
  sl.registerFactory<RemoteConfigRemoteDatasource>(
    () => RemoteConfigRemoteDatasource(remoteConfig: sl()),
  );
  sl.registerFactory<RemoteConfigRepository>(
    () => RemoteConfigRepositoryImpl(
      remoteDatasource: sl.get<RemoteConfigRemoteDatasource>(),
    ),
  );

  sl.registerFactory<InitializeRemoteConfigUsecase>(
    () => InitializeRemoteConfigUsecase(sl.get<RemoteConfigRepository>()),
  );
  sl.registerFactory<FetchAndActivateUsecase>(
    () => FetchAndActivateUsecase(sl.get<RemoteConfigRepository>()),
  );
  sl.registerFactory<GetStringUsecase>(
    () => GetStringUsecase(sl.get<RemoteConfigRepository>()),
  );
  sl.registerFactory<GetBoolUsecase>(
    () => GetBoolUsecase(sl.get<RemoteConfigRepository>()),
  );
  sl.registerFactory<GetIntUsecase>(
    () => GetIntUsecase(sl.get<RemoteConfigRepository>()),
  );
  sl.registerFactory<GetDoubleUsecase>(
    () => GetDoubleUsecase(sl.get<RemoteConfigRepository>()),
  );
  sl.registerFactory<GetJsonUsecase>(
    () => GetJsonUsecase(sl.get<RemoteConfigRepository>()),
  );
  sl.registerFactory<GetAllParametersUsecase>(
    () => GetAllParametersUsecase(sl.get<RemoteConfigRepository>()),
  );
  sl.registerFactory<RemoteConfigBloc>(
    () => RemoteConfigBloc(
      initializeUsecase: sl.get<InitializeRemoteConfigUsecase>(),
      fetchAndActivateUsecase: sl.get<FetchAndActivateUsecase>(),
      getStringUsecase: sl.get<GetStringUsecase>(),
      getBoolUsecase: sl.get<GetBoolUsecase>(),
      getIntUsecase: sl.get<GetIntUsecase>(),
      getDoubleUsecase: sl.get<GetDoubleUsecase>(),
      getJsonUsecase: sl.get<GetJsonUsecase>(),
      getAllParametersUsecase: sl.get<GetAllParametersUsecase>(),
    ),
  );

  // --- Institutions ---
  sl.registerFactory<InstitutionLocalDatasource>(
    () => InstitutionLocalDatasource(localDB: sl<AppDataBase>()),
  );
  sl.registerFactory<InstitutionRemoteDatasource>(
    () => InstitutionRemoteDatasource(dioClient: sl(), flavor: flavor),
  );

  sl.registerFactory<InstitutionRepositoryImpl>(
    () => InstitutionRepositoryImpl(
      institutionLocalDatasource: sl(),
      institutionRemoteDatasource: sl(),
    ),
  );

  sl.registerFactory<GetAllUserAccountInstitutionsUsecase>(
    () => GetAllUserAccountInstitutionsUsecase(
      institutionRepository: sl<InstitutionRepositoryImpl>(),
    ),
  );

  sl.registerFactory<GetAllCachedInstitutionsUsecase>(
    () => GetAllCachedInstitutionsUsecase(
      institutionRepository: sl<InstitutionRepositoryImpl>(),
    ),
  );

  sl.registerFactory<AddAccountToInstitution>(
    () => AddAccountToInstitution(
      institutionRepository: sl<InstitutionRepositoryImpl>(),
    ),
  );

  sl.registerFactory<SearchForInstitutionByNameUsecase>(
    () => SearchForInstitutionByNameUsecase(
      institutionRepository: sl<InstitutionRepositoryImpl>(),
    ),
  );

  sl.registerFactory<InstitutionBloc>(
    () => InstitutionBloc(
      addAccountToInstitution: sl(),
      getAllCachedInstitutionsUsecase: sl(),
      searchForInstitutionByNameUsecase: sl(),
      getAllUserAccountInstitutionsUsecase: sl(),
    ),
  );

  // Magnet
  sl.registerFactory<MagnetCredentialsLocalDatasource>(
    () => MagnetCredentialsLocalDatasource(localDB: sl()),
  );
  sl.registerFactory<MagnetStudentProfileLocalDatasource>(
    () => MagnetStudentProfileLocalDatasource(localDB: sl()),
  );
  sl.registerFactory<MagnetCourseLocalDataSource>(
    () => MagnetCourseLocalDataSource(localDB: sl()),
  );

  sl.registerFactory<MagnetRepositoryImpl>(
    () => MagnetRepositoryImpl(
      magnetCredentialsLocalDatasource: sl(),
      magnetStudentProfileLocalDatasource: sl(),
      magnetCourseLocalDataSource: sl(),
    ),
  );

  // -- Usecases
  sl.registerFactory<MagnetLoginUsecase>(
    () => MagnetLoginUsecase(magnetRepository: sl<MagnetRepositoryImpl>()),
  );
  sl.registerFactory<GetCachedMagnetCredentialUsecase>(
    () => GetCachedMagnetCredentialUsecase(
      magnetRepository: sl<MagnetRepositoryImpl>(),
    ),
  );
  sl.registerFactory<GetMagnetAuthenticationStatusUsecase>(
    () => GetMagnetAuthenticationStatusUsecase(
      magnetRepository: sl<MagnetRepositoryImpl>(),
    ),
  );
  sl.registerFactory<GetCachedMagnetStudentProfileUsecase>(
    () => GetCachedMagnetStudentProfileUsecase(
      magnetRepository: sl<MagnetRepositoryImpl>(),
    ),
  );
  sl.registerFactory<FetchMagnetStudentProfileUsecase>(
    () => FetchMagnetStudentProfileUsecase(
      magnetRepository: sl<MagnetRepositoryImpl>(),
    ),
  );
  sl.registerFactory<FetchMagnetStudentTimetableUsecase>(
    () => FetchMagnetStudentTimetableUsecase(
      magnetRepository: sl<MagnetRepositoryImpl>(),
    ),
  );
  sl.registerFactory<GetCachedMagnetStudentTimetableUsecase>(
    () => GetCachedMagnetStudentTimetableUsecase(
      magnetRepository: sl<MagnetRepositoryImpl>(),
    ),
  );

  sl.registerFactory<DeleteMagentCourseByCourseCodeUsecase>(
    () => DeleteMagentCourseByCourseCodeUsecase(
      magnetRepository: sl<MagnetRepositoryImpl>(),
    ),
  );
  sl.registerFactory<FetchMagnetFinancialFeesStatementsUsecase>(
    () => FetchMagnetFinancialFeesStatementsUsecase(
      magnetRepository: sl<MagnetRepositoryImpl>(),
    ),
  );

  // -- Bloc
  sl.registerFactory<MagnetBloc>(
    () => MagnetBloc(
      magnetLoginUsecase: sl(),
      getCachedMagnetCredentialUsecase: sl(),
      getMagnetAuthenticationStatusUsecase: sl(),
      fetchMagnetStudentProfileUsecase: sl(),
      getCachedMagnetStudentProfileUsecase: sl(),
      fetchMagnetStudentTimetableUsecase: sl(),
      deleteMagentCourseByCourseCodeUsecase: sl(),
      getCachedMagnetStudentTimetableUsecase: sl(),
      fetchMagnetFinancialFeesStatementsUsecase: sl(),
    ),
  );

  // AdMob
  sl.registerFactory<AdRemoteDataSource>(() => AdRemoteDataSourceImpl());

  sl.registerFactory<AdRepository>(
    () => AdRepositoryImpl(sl.get<AdRemoteDataSource>()),
  );

  sl.registerFactory<InitializeAdMobUsecase>(
    () => InitializeAdMobUsecase(sl.get<AdRepository>()),
  );
  sl.registerFactory<LoadBannerAdUsecase>(
    () => LoadBannerAdUsecase(sl.get<AdRepository>()),
  );
  sl.registerFactory<LoadInterstitialAdUsecase>(
    () => LoadInterstitialAdUsecase(sl.get<AdRepository>()),
  );
  sl.registerFactory<LoadRewardedAdUsecase>(
    () => LoadRewardedAdUsecase(sl.get<AdRepository>()),
  );
  sl.registerFactory<ShowInterstitialAdUsecase>(
    () => ShowInterstitialAdUsecase(sl.get<AdRepository>()),
  );
  sl.registerFactory<ShowRewardedAdUsecase>(
    () => ShowRewardedAdUsecase(sl.get<AdRepository>()),
  );
  sl.registerFactory<GetLoadedAdsUsecase>(
    () => GetLoadedAdsUsecase(sl.get<AdRepository>()),
  );
  sl.registerFactory<SetTestModeUsecase>(
    () => SetTestModeUsecase(sl.get<AdRepository>()),
  );

  sl.registerFactory<AdBloc>(
    () => AdBloc(
      initializeAdMobUsecase: sl.get<InitializeAdMobUsecase>(),
      loadBannerAdUsecase: sl.get<LoadBannerAdUsecase>(),
      loadInterstitialAdUsecase: sl.get<LoadInterstitialAdUsecase>(),
      loadRewardedAdUsecase: sl.get<LoadRewardedAdUsecase>(),
      showInterstitialAdUsecase: sl.get<ShowInterstitialAdUsecase>(),
      showRewardedAdUsecase: sl.get<ShowRewardedAdUsecase>(),
      getLoadedAdsUsecase: sl.get<GetLoadedAdsUsecase>(),
      setTestModeUsecase: sl.get<SetTestModeUsecase>(),
    ),
  );

  // Permissions
  sl.registerFactory<PermissionDatasource>(() => PermissionDatasourceImpl());
  sl.registerFactory<PermissionRepository>(
    () => PermissionRepositoryImpl(permissionDatasource: sl()),
  );
  sl.registerFactory<RequestPermissionUsecase>(
    () => RequestPermissionUsecase(permissionRepository: sl()),
  );
  sl.registerFactory<CheckPermissionUsecase>(
    () => CheckPermissionUsecase(permissionRepository: sl()),
  );
  sl.registerFactory<PermissionCubit>(
    () => PermissionCubit(
      checkPermissionUsecase: sl(),
      requestPermissionUsecase: sl(),
    ),
  );
}
