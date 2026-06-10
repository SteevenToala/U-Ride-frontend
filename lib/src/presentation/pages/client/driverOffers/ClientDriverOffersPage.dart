import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/DriverTripRequest.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/driverOffers/ClientDriverOffersItem.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'package:lottie/lottie.dart';

class ClientDriverOffersPage extends StatefulWidget {
  const ClientDriverOffersPage({super.key});

  @override
  State<ClientDriverOffersPage> createState() => _ClientDriverOffersPageState();
}

class _ClientDriverOffersPageState extends State<ClientDriverOffersPage> {

  int? idClientRequest;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (idClientRequest != null) {
        context.read<ClientDriverOffersBloc>().add(ListenNewDriverOfferSocketIO(idClientRequest: idClientRequest!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    idClientRequest = ModalRoute.of(context)?.settings.arguments as int;
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocListener<ClientDriverOffersBloc, ClientDriverOffersState>(
        listener: (context, state) {
          final response = state.responseDriverOffers;
          final responseAssignDriver = state.responseAssignDriver;
          if (response is ErrorData) {
            Fluttertoast.showToast(msg: response.message, toastLength: Toast.LENGTH_LONG);
          }
          if (responseAssignDriver is Success) {
            Navigator.pushNamed(context, 'client/map/trip', arguments: idClientRequest);
          }
        },
        child: BlocBuilder<ClientDriverOffersBloc, ClientDriverOffersState>(
            builder: (context, state) {
          final response = state.responseDriverOffers;

          if (response is Loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.passengerColor),
            );
          }
          else if (response is Success) {
            final driverTripRequest = response.data as List<DriverTripRequest>;
            if (driverTripRequest.isEmpty) {
              return _waitingState();
            }
            return _buildContent(context, driverTripRequest);
          }
          return _waitingState();
        }),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<DriverTripRequest> offers) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final cols = w >= 960 ? 3 : w >= 580 ? 2 : 1;
          final hPad = w >= 580 ? 20.0 : 16.0;
          final spacing = 14.0;
          final cardW = cols == 1
              ? double.infinity
              : (w - hPad * 2 - spacing * (cols - 1)) / cols;

          if (cols == 1) {
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
              itemCount: offers.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ClientDriverOffersItem(offers[i]),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: offers
                  .map((o) => SizedBox(width: cardW, child: ClientDriverOffersItem(o)))
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _waitingState() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Esperando conductores...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Lottie.asset(
            'assets/lottie/waiting_car.json',
            width: 280,
            height: 200,
          ),
        ],
      ),
    );
  }
}
