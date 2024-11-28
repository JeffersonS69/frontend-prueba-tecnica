import 'package:flutter/material.dart';
import 'package:frontend/api/peticiones_solicitud.dart';
import 'package:frontend/functions/image_state.dart';
import 'package:frontend/functions/provider_auth_service.dart';
import 'package:frontend/functions/solicitudes_state.dart';
import 'package:frontend/functions/usuarios_state.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/solicitud_form.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:frontend/services/usuarios_service.dart';
import 'package:frontend/widgets/list_view_solicitudes.dart';
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
    _tabController = TabController(vsync: this, length: 2);

    _fetchDataForTab(0);
  }

  void _fetchDataForTab(int index) {
    final request = index == 0 ? 'solicitudByRol' : 'solicitudes';
    PeticionesSolicitud.fetchSolicitudes(
      context: context,
      solicitudesState: widget.solicitudesState,
      serviceSolicitud: serviceSolicitud,
      id: widget.authService.id,
      rol: widget.authService.rol,
      request: request,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = Provider.of<ImageState>(context);
    final usuariosState = Provider.of<UsuariosState>(context);

    return Consumer<SolicitudesState>(
      builder: (context, solicitudesState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Solicitudes de ${widget.authService.rol}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _fetchDataForTab(_tabController.index),
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
                    onTap: _fetchDataForTab,
                  )
                : null,
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ListViewSolicitudes(
                solicitudesState: solicitudesState,
                imageState: imageState,
                serviceUsuario: widget.serviceUsuario,
                id: widget.authService.id!,
                rol: widget.authService.rol!,
                request: 'solicitudByRol',
                serviceSolicitud: serviceSolicitud,
              ),
              ListViewSolicitudes(
                solicitudesState: solicitudesState,
                imageState: imageState,
                serviceUsuario: widget.serviceUsuario,
                id: widget.authService.id!,
                rol: widget.authService.rol!,
                request: 'solicitudes',
                serviceSolicitud: serviceSolicitud,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SolicitudForm(
                          usuariosState: usuariosState,
                          imageState: imageState,
                          serviceSolicitud: serviceSolicitud,
                          serviceUsuario: widget.serviceUsuario,
                          validatedToken: () =>
                              ProviderAuthService.checkTokenExpiration(
                                  context: context),
                          reloadSolicitud:
                              widget.authService.rol! == 'residente' &&
                                      _tabController.index == 1
                                  ? () => PeticionesSolicitud.fetchSolicitudes(
                                        request: 'solicitudes',
                                        context: context,
                                        serviceSolicitud: serviceSolicitud,
                                        solicitudesState: solicitudesState,
                                      )
                                  : () => PeticionesSolicitud.fetchSolicitudes(
                                        request: 'solicitudByRol',
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
