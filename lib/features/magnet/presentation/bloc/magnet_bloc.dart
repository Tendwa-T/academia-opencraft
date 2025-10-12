import 'package:academia/features/features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magnet/magnet.dart';
import 'package:magnet_daystar_university/magnet_daystar_university.dart';

part 'magnet_state.dart';
part 'magnet_event.dart';

class MagnetBloc extends Bloc<MagnetEvent, MagnetState> {
  final MagnetLoginUsecase magnetLoginUsecase;
  final GetCachedMagnetCredentialUsecase getCachedMagnetCredentialUsecase;
  final GetMagnetAuthenticationStatusUsecase
  getMagnetAuthenticationStatusUsecase;
  final FetchMagnetStudentProfileUsecase fetchMagnetStudentProfileUsecase;
  final GetCachedMagnetStudentProfileUsecase
  getCachedMagnetStudentProfileUsecase;
  final DeleteMagentCourseByCourseCodeUsecase
  deleteMagentCourseByCourseCodeUsecase;
  final GetCachedMagnetStudentTimetableUsecase
  getCachedMagnetStudentTimetableUsecase;
  final FetchMagnetStudentTimetableUsecase fetchMagnetStudentTimetableUsecase;
  final FetchMagnetFinancialFeesStatementsUsecase
  fetchMagnetFinancialFeesStatementsUsecase;

  final Map<int, MagnetPortalRepository> _magnetInstances = {};
  MagnetBloc({
    required this.magnetLoginUsecase,
    required this.getCachedMagnetCredentialUsecase,
    required this.getMagnetAuthenticationStatusUsecase,
    required this.getCachedMagnetStudentProfileUsecase,
    required this.fetchMagnetStudentProfileUsecase,
    required this.fetchMagnetStudentTimetableUsecase,
    required this.getCachedMagnetStudentTimetableUsecase,
    required this.deleteMagentCourseByCourseCodeUsecase,
    required this.fetchMagnetFinancialFeesStatementsUsecase,
  }) : super(MagnetInitialState()) {
    /// Initialize application with the appropriate magnet instance
    /// per institution linked by the institution id
    on<InitializeMagnetInstancesEvent>((event, emit) async {
      try {
        _magnetInstances.addAll({
          5426: await DaystarPortalRepository.create(debugMode: true),
        });
        emit(MagnetInstancesLoadedState());
      } catch (e) {
        emit(MagnetErrorState(error: "Failed to initialize magnet instances"));
      }
    });
    on<GetCachedMagnetCredentialEvent>((event, emit) async {
      emit(MagnetLoadingState());
      final result = await getCachedMagnetCredentialUsecase(
        GetCachedMagnetCredentialUsecaseParams(
          institutionID: event.institutionID,
          userID: event.userID,
        ),
      );
      result.fold(
        (error) {
          emit(MagnetCredentialNotFetched(error: error.message));
        },
        (cred) {
          emit(MagnetCredentialFetched(magnetCredential: cred));
        },
      );
    });
    on<GetCachedMagnetProfileEvent>((event, emit) async {
      emit(MagnetLoadingState());
      final result = await getCachedMagnetStudentProfileUsecase(
        GetCachedMagnetStudentProfileUsecaseParams(
          institutionID: event.institutionID,
          userID: event.userID,
        ),
      );
      result.fold(
        (error) {
          emit(MagnetErrorState(error: error.message));
        },
        (profile) {
          emit(MagnetProfileLoadedState(magnetStudentProfile: profile));
        },
      );
    });
    on<FetchMagnetProfileEvent>((event, emit) async {
      emit(MagnetLoadingState());

      if (!_magnetInstances.containsKey(event.institutionID)) {
        return emit(MagnetNotSupportedState());
      }
      final magnetInstance = _magnetInstances[event.institutionID]!;
      final result = await fetchMagnetStudentProfileUsecase(
        FetchMagnetStudentProfileUsecaseParams(
          magnetInstance: magnetInstance,
          institutionID: event.institutionID,
          userID: event.userID,
        ),
      );
      result.fold(
        (error) {
          emit(MagnetErrorState(error: error.message));
        },
        (profile) {
          emit(MagnetProfileLoadedState(magnetStudentProfile: profile));
        },
      );
    });
    on<FetchMagnetStudentTimeTableEvent>((event, emit) async {
      emit(MagnetLoadingState());

      if (!_magnetInstances.containsKey(event.institutionID)) {
        return emit(MagnetNotSupportedState());
      }
      final magnetInstance = _magnetInstances[event.institutionID]!;
      final result = await fetchMagnetStudentTimetableUsecase(
        FetchMagnetStudentTimetableUsecaseParams(
          magnetInstance: magnetInstance,
          institutionID: event.institutionID,
          userID: event.userID,
        ),
      );
      result.fold(
        (error) {
          emit(MagnetErrorState(error: error.message));
        },
        (courses) {
          emit(MagnetTimeTableLoadedState(timetable: courses));
        },
      );
    });
    on<GetCachedMagnetStudentTimetableEvent>((event, emit) async {
      emit(MagnetLoadingState());

      if (!_magnetInstances.containsKey(event.institutionID)) {
        return emit(MagnetNotSupportedState());
      }
      final result = await getCachedMagnetStudentTimetableUsecase(
        GetCachedMagnetStudentTimetableUsecaseParams(
          institutionID: event.institutionID,
          userID: event.userID,
        ),
      );
      result.fold(
        (error) {
          emit(MagnetErrorState(error: error.message));
        },
        (courses) {
          emit(MagnetTimeTableLoadedState(timetable: courses));
        },
      );
    });
    on<DeleteCachedMagnetStudentTimetableEvent>((event, emit) async {
      emit(MagnetLoadingState());

      final result = await deleteMagentCourseByCourseCodeUsecase(
        DeleteMagentCourseByCourseCodeUsecaseParams(
          institutionID: event.institutionID,
          userID: event.userID,
          courseCode: event.courseCode,
        ),
      );
      result.fold(
        (error) {
          emit(MagnetErrorState(error: error.message));
        },
        (deleted) {
          add(
            GetCachedMagnetStudentTimetableEvent(
              institutionID: event.institutionID,
              userID: event.userID,
            ),
          );
        },
      );
    });

    on<FetchMagnetFeeStatementTransactionsEvent>((event, emit) async {
      emit(MagnetLoadingState());

      if (!_magnetInstances.containsKey(event.institutionID)) {
        return emit(MagnetNotSupportedState());
      }

      final magnetInstance = _magnetInstances[event.institutionID]!;
      final result = await fetchMagnetFinancialFeesStatementsUsecase(
        FetchMagnetFinancialFeesStatementsUsecaseParams(
          userID: event.userID,
          institutionID: event.institutionID,
          magnetPortalRepository: magnetInstance,
        ),
      );
      result.fold(
        (error) {
          emit(MagnetErrorState(error: error.message));
        },
        (transactions) {
          emit(MagnetFeesTransactionsLoadedState(transactions: transactions));
        },
      );
    });

    on<LinkMagnetAccountEvent>((event, emit) async {
      emit(MagnetLoadingState());

      if (!_magnetInstances.containsKey(event.institutionID)) {
        return emit(MagnetNotSupportedState());
      }

      final magnetInstance = _magnetInstances[event.institutionID]!;
      final result = await magnetLoginUsecase(
        MagnetLoginUsecaseParams(
          userID: event.userID,
          institutionID: event.institutionID,
          credentials: event.credentials,
          magnetInstance: magnetInstance,
        ),
      );
      result.fold(
        (error) {
          emit(MagnetErrorState(error: error.message));
        },
        (ok) {
          if (!ok) {
            emit(
              MagnetErrorState(error: "We failed to authenticate your account"),
            );
          }
          emit(MagnetAuthenticatedState());
        },
      );
    });

    on<RefreshMagnetAuthenticationEvent>((event, emit) async {
      emit(MagnetLoadingState());

      if (!_magnetInstances.containsKey(event.institutionID)) {
        return emit(MagnetNotSupportedState());
      }

      final magnetInstance = _magnetInstances[event.institutionID]!;
      final authStatus = await getMagnetAuthenticationStatusUsecase(
        GetMagnetAuthenticationStatusUsecaseParams(
          userID: event.userID,
          institutionID: event.institutionID,
          magnetPortalRepository: magnetInstance,
        ),
      );

      await authStatus.fold(
        (error) async => emit(
          MagnetErrorState(
            error: "Failed to fetch magnet authentication state",
          ),
        ),
        (isLoggedIn) async {
          if (isLoggedIn) return emit(MagnetAuthenticatedState());
          final result = await magnetLoginUsecase(
            MagnetLoginUsecaseParams(
              userID: event.userID,
              institutionID: event.institutionID,
              credentials: event.credentials,
              magnetInstance: magnetInstance,
            ),
          );
          await result.fold(
            (error) async {
              emit(MagnetErrorState(error: error.message));
            },
            (ok) async {
              if (!ok) {
                emit(
                  MagnetErrorState(
                    error: "We failed to authenticate your account",
                  ),
                );
              }
              emit(MagnetAuthenticatedState());
            },
          );
        },
      );
    });
  }

  bool isInstitutionSupported(int institutionID) {
    final magnetInstance = _magnetInstances[institutionID];
    return magnetInstance != null;
  }
}
