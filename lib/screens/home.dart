import 'package:flutter/material.dart';
import 'package:frontend/api/peticiones_solicitud.dart';
import 'package:frontend/functions/provider_auth_service.dart';
import 'package:frontend/functions/solicitudes_state.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/solicitud_form.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:frontend/services/usuarios_service.dart';
import 'package:frontend/widgets/solicitud_card.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final UsuariosService serviceUsuario;
  final AuthService authService;
  final BuildContext context;
  final SolicitudesState solicitudesState;

  const Home({
    super.key,
    required this.authService,
    required this.serviceUsuario,
    required this.context,
    required this.solicitudesState,
  });

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  final serviceSolicitud = SolicitudesService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    ProviderAuthService.checkTokenExpiration(context: widget.context);
    PeticionesSolicitud.fetchSolicitudes(
      rol: widget.authService.rol!,
      id: widget.authService.id!,
      context: widget.context,
      serviceSolicitud: serviceSolicitud,
      solicitudesState: widget.solicitudesState,
    );
    
    _tabController = TabController(vsync: this, length: 2);

    _tabController.addListener(
      () {
        if (_tabController.indexIsChanging) {
          if (_tabController.index == 0) {
            PeticionesSolicitud.fetchSolicitudes(
              rol: widget.authService.rol!,
              id: widget.authService.id!,
              context: widget.context,
              serviceSolicitud: serviceSolicitud,
              solicitudesState: widget.solicitudesState,
            );
          } else if (_tabController.index == 1) {
            PeticionesSolicitud.fetchSolicitudesAll(
              context: widget.context,
              serviceSolicitud: serviceSolicitud,
              solicitudesState: widget.solicitudesState,
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SolicitudesState>(
      builder: (context, solicitudesState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Solicitudes de ${widget.authService.rol}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  if (_tabController.index == 0) {
                    PeticionesSolicitud.fetchSolicitudes(
                      rol: widget.authService.rol!,
                      id: widget.authService.id!,
                      context: context,
                      solicitudesState: solicitudesState,
                      serviceSolicitud: serviceSolicitud,
                    );
                  } else if (_tabController.index == 1) {
                    PeticionesSolicitud.fetchSolicitudesAll(
                      context: context,
                      serviceSolicitud: serviceSolicitud,
                      solicitudesState: solicitudesState,
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
            ],
            bottom: widget.authService.rol == 'residente'
                ? TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        text: 'Mis Solicitudes',
                      ),
                      Tab(
                        text: 'Todas las Solicitudes',
                      ),
                    ],
                  )
                : null,
          ),
          body: solicitudesState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : widget.authService.rol == 'residente'
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        solicitudesState.solicitudes.isNotEmpty
                            ? ListView.builder(
                                itemCount: solicitudesState.solicitudes.length,
                                itemBuilder: (context, index) {
                                  return SolicitudCard(
                                    serviceSolicitud: serviceSolicitud,
                                    serviceUsuario: widget.serviceUsuario,
                                    validatedToken: () => ProviderAuthService
                                        .checkTokenExpiration(context: context),
                                    solicitud:
                                        solicitudesState.solicitudes[index],
                                    id: widget.authService.id!,
                                    byRol: widget.authService.rol!,
                                    reloadSolicitud: () =>
                                        PeticionesSolicitud.fetchSolicitudes(
                                      context: context,
                                      rol: widget.authService.rol!,
                                      id: widget.authService.id!,
                                      serviceSolicitud: serviceSolicitud,
                                      solicitudesState: solicitudesState,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text('No hay solicitudes'),
                              ),
                        solicitudesState.solicitudesAll.isNotEmpty
                            ? ListView.builder(
                                itemCount:
                                    solicitudesState.solicitudesAll.length,
                                itemBuilder: (context, index) {
                                  return SolicitudCard(
                                    serviceSolicitud: serviceSolicitud,
                                    serviceUsuario: widget.serviceUsuario,
                                    validatedToken: () => ProviderAuthService
                                        .checkTokenExpiration(context: context),
                                    solicitud:
                                        solicitudesState.solicitudesAll[index],
                                    id: widget.authService.id!,
                                    byRol: widget.authService.rol!,
                                    reloadSolicitud: () =>
                                        PeticionesSolicitud.fetchSolicitudesAll(
                                      context: context,
                                      serviceSolicitud: serviceSolicitud,
                                      solicitudesState: solicitudesState,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text('No hay solicitudes'),
                              ),
                      ],
                    )
                  : solicitudesState.solicitudes.isNotEmpty
                      ? ListView.builder(
                          itemCount: solicitudesState.solicitudes.length,
                          itemBuilder: (context, index) {
                            return SolicitudCard(
                              serviceSolicitud: serviceSolicitud,
                              serviceUsuario: widget.serviceUsuario,
                              validatedToken: () =>
                                  ProviderAuthService.checkTokenExpiration(
                                      context: context),
                              solicitud: solicitudesState.solicitudes[index],
                              id: widget.authService.id!,
                              byRol: widget.authService.rol!,
                              reloadSolicitud: () =>
                                  PeticionesSolicitud.fetchSolicitudes(
                                context: context,
                                rol: widget.authService.rol!,
                                id: widget.authService.id!,
                                serviceSolicitud: serviceSolicitud,
                                solicitudesState: solicitudesState,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text('No hay solicitudes'),
                        ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SolicitudForm(
                          serviceSolicitud: serviceSolicitud,
                          serviceUsuario: widget.serviceUsuario,
                          validatedToken: () =>
                              ProviderAuthService.checkTokenExpiration(
                                  context: context),
                          reloadSolicitud: widget.authService.rol! ==
                                      'residente' &&
                                  _tabController.index == 1
                              ? () => PeticionesSolicitud.fetchSolicitudesAll(
                                    context: context,
                                    serviceSolicitud: serviceSolicitud,
                                    solicitudesState: solicitudesState,
                                  )
                              : () => PeticionesSolicitud.fetchSolicitudes(
                                    context: context,
                                    rol: widget.authService.rol!,
                                    id: widget.authService.id!,
                                    serviceSolicitud: serviceSolicitud,
                                    solicitudesState: solicitudesState,
                                  ),
                          id: widget.authService.id!,
                          byRol: widget.authService.rol!,
                        )),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
