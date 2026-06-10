// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart'
    as _i216;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/AuthService.dart'
    as _i805;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/ClientRequestsService.dart'
    as _i267;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/DriverCarInfoService.dart'
    as _i279;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/DriversPositionService.dart'
    as _i665;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/DriverTripRequestsService.dart'
    as _i1000;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/ReportsService.dart'
    as _i610;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/SharedTripsService.dart'
    as _i949;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/TripReservationsService.dart'
    as _i516;
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/UsersService.dart'
    as _i32;
import 'package:indriver_clone_flutter/src/di/AppModule.dart' as _i534;
import 'package:indriver_clone_flutter/src/domain/repository/AuthRepository.dart'
    as _i554;
import 'package:indriver_clone_flutter/src/domain/repository/ClientRequestsRepository.dart'
    as _i228;
import 'package:indriver_clone_flutter/src/domain/repository/DriverCarInfoRepository.dart'
    as _i796;
import 'package:indriver_clone_flutter/src/domain/repository/DriversPositionRepository.dart'
    as _i456;
import 'package:indriver_clone_flutter/src/domain/repository/DriverTripRequestsRepository.dart'
    as _i759;
import 'package:indriver_clone_flutter/src/domain/repository/GeolocatorRepository.dart'
    as _i323;
import 'package:indriver_clone_flutter/src/domain/repository/ReportsRepository.dart'
    as _i604;
import 'package:indriver_clone_flutter/src/domain/repository/SharedTripsRepository.dart'
    as _i502;
import 'package:indriver_clone_flutter/src/domain/repository/SocketRepository.dart'
    as _i416;
import 'package:indriver_clone_flutter/src/domain/repository/TripReservationsRepository.dart'
    as _i637;
import 'package:indriver_clone_flutter/src/domain/repository/UsersRepository.dart'
    as _i377;
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart'
    as _i231;
import 'package:indriver_clone_flutter/src/domain/useCases/client-requests/ClientRequestsUseCases.dart'
    as _i477;
import 'package:indriver_clone_flutter/src/domain/useCases/driver-car-info/DriverCarInfoUseCases.dart'
    as _i875;
import 'package:indriver_clone_flutter/src/domain/useCases/driver-trip-request/DriverTripRequestUseCases.dart'
    as _i940;
import 'package:indriver_clone_flutter/src/domain/useCases/drivers-position/DriversPositionUseCases.dart'
    as _i205;
import 'package:indriver_clone_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart'
    as _i234;
import 'package:indriver_clone_flutter/src/domain/useCases/reports/ReportsUseCases.dart'
    as _i448;
import 'package:indriver_clone_flutter/src/domain/useCases/shared-trips/SharedTripsUseCases.dart'
    as _i316;
import 'package:indriver_clone_flutter/src/domain/useCases/socket/SocketUseCases.dart'
    as _i337;
import 'package:indriver_clone_flutter/src/domain/useCases/trip-reservations/TripReservationsUseCases.dart'
    as _i1033;
import 'package:indriver_clone_flutter/src/domain/useCases/users/UsersUseCases.dart'
    as _i602;
import 'package:injectable/injectable.dart' as _i526;
import 'package:socket_io_client/socket_io_client.dart' as _i414;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    gh.factory<_i216.SharefPref>(() => appModule.sharefPref);
    gh.factory<_i414.Socket>(() => appModule.socket);
    gh.factoryAsync<String>(() => appModule.token);
    gh.factory<_i805.AuthService>(() => appModule.authService);
    gh.factory<_i32.UsersService>(() => appModule.usersService);
    gh.factory<_i665.DriversPositionService>(
        () => appModule.driversPositionService);
    gh.factory<_i267.ClientRequestsService>(
        () => appModule.clientRequestsService);
    gh.factory<_i1000.DriverTripRequestsService>(
        () => appModule.driverTripRequestsService);
    gh.factory<_i279.DriverCarInfoService>(
        () => appModule.driverCarInfoService);
    gh.factory<_i554.AuthRepository>(() => appModule.authRepository);
    gh.factory<_i377.UsersRepository>(() => appModule.usersRepository);
    gh.factory<_i416.SocketRepository>(() => appModule.socketRepository);
    gh.factory<_i228.ClientRequestsRepository>(
        () => appModule.clientRequestsRepository);
    gh.factory<_i323.GeolocatorRepository>(
        () => appModule.geolocatorRepository);
    gh.factory<_i456.DriverPositionRepository>(
        () => appModule.driversPositionRepository);
    gh.factory<_i759.DriverTripRequestsRepository>(
        () => appModule.driverTripRequestsRepository);
    gh.factory<_i796.DriverCarInfoRepository>(
        () => appModule.driverCarInfoRepository);
    gh.factory<_i231.AuthUseCases>(() => appModule.authUseCases);
    gh.factory<_i602.UsersUseCases>(() => appModule.usersUseCases);
    gh.factory<_i234.GeolocatorUseCases>(() => appModule.geolocatorUseCases);
    gh.factory<_i337.SocketUseCases>(() => appModule.socketUseCases);
    gh.factory<_i205.DriversPositionUseCases>(
        () => appModule.driversPositionUseCases);
    gh.factory<_i477.ClientRequestsUseCases>(
        () => appModule.clientRequestsUseCases);
    gh.factory<_i940.DriverTripRequestUseCases>(
        () => appModule.driverTripRequestUseCases);
    gh.factory<_i875.DriverCarInfoUseCases>(
        () => appModule.driverCarInfoUseCases);
    gh.factory<_i610.ReportsService>(() => appModule.reportsService);
    gh.factory<_i604.ReportsRepository>(() => appModule.reportsRepository);
    gh.factory<_i448.ReportsUseCases>(() => appModule.reportsUseCases);
    gh.factory<_i949.SharedTripsService>(() => appModule.sharedTripsService);
    gh.factory<_i516.TripReservationsService>(
        () => appModule.tripReservationsService);
    gh.factory<_i502.SharedTripsRepository>(
        () => appModule.sharedTripsRepository);
    gh.factory<_i637.TripReservationsRepository>(
        () => appModule.tripReservationsRepository);
    gh.factory<_i316.SharedTripsUseCases>(() => appModule.sharedTripsUseCases);
    gh.factory<_i1033.TripReservationsUseCases>(
        () => appModule.tripReservationsUseCases);
    return this;
  }
}

class _$AppModule extends _i534.AppModule {}
