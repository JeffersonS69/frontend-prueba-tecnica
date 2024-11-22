import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/solicitud_form.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:frontend/widgets/solicitud_card.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final AuthService authService;
  const Home({super.key, required this.authService});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  List<dynamic> solicitudes = [];
  List<dynamic> solicitudesAll = [];
  bool isLoading = true;
  final service = SolicitudesService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchSolicitudes(widget.authService.rol!, widget.authService.id!);
    _tabController = TabController(vsync: this, length: 2);

    _tabController.addListener(
      () {
        if (_tabController.indexIsChanging) {
          if (_tabController.index == 0) {
            fetchSolicitudes(widget.authService.rol!, widget.authService.id!);
          } else if (_tabController.index == 1) {
            fetchSolicitudesAll();
          }
        }
      },
    );
  }

  Future<void> fetchSolicitudes(String rol, int id) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isTokenExpired()) {
      _showSessionExpiredDialog();
      return;
    }

    try {
      setState(() => isLoading = true);
      final data = await service.fetchSolicitudesByRol(rol, id);
      setState(() {
        solicitudes = data;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar las solicitudes'),
        ),
      );
    }
  }

  Future<void> fetchSolicitudesAll() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isTokenExpired()) {
      _showSessionExpiredDialog();
      return;
    }

    try {
      setState(() => isLoading = true);
      final data = await service.fetchSolicitudes();
      setState(() {
        solicitudesAll = data;
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar las solicitudes'),
        ),
      );
    }
  }

  void checkTokenExpiration() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isTokenExpired()) {
      _showSessionExpiredDialog();
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sesión expirada'),
          content: const Text(
              'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes de ${widget.authService.rol}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0) {
                fetchSolicitudes(
                    widget.authService.rol!, widget.authService.id!);
              } else if (_tabController.index == 1) {
                fetchSolicitudesAll();
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : widget.authService.rol == 'residente'
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    solicitudes.isNotEmpty
                        ? ListView.builder(
                            itemCount: solicitudes.length,
                            itemBuilder: (context, index) {
                              return SolicitudCard(
                                  validatedToken: checkTokenExpiration,
                                  solicitud: solicitudes[index],
                                  id: widget.authService.id!,
                                  byRol: widget.authService.rol!,
                                  reloadSolicitud: () => fetchSolicitudes(
                                      widget.authService.rol!,
                                      widget.authService.id!));
                            },
                          )
                        : const Center(
                            child: Text('No hay solicitudes'),
                          ),
                    solicitudesAll.isNotEmpty
                        ? ListView.builder(
                            itemCount: solicitudesAll.length,
                            itemBuilder: (context, index) {
                              return SolicitudCard(
                                  validatedToken: checkTokenExpiration,
                                  solicitud: solicitudesAll[index],
                                  id: widget.authService.id!,
                                  byRol: widget.authService.rol!,
                                  reloadSolicitud: fetchSolicitudesAll);
                            },
                          )
                        : const Center(
                            child: Text('No hay solicitudes'),
                          ),
                  ],
                )
              : solicitudes.isNotEmpty
                  ? ListView.builder(
                      itemCount: solicitudes.length,
                      itemBuilder: (context, index) {
                        return SolicitudCard(
                          validatedToken: checkTokenExpiration,
                          solicitud: solicitudes[index],
                          id: widget.authService.id!,
                          byRol: widget.authService.rol!,
                          reloadSolicitud: () => fetchSolicitudes(
                              widget.authService.rol!, widget.authService.id!),
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
                      validatedToken: checkTokenExpiration,
                      reloadSolicitud: widget.authService.rol! == 'residente' &&
                              _tabController.index == 1
                          ? fetchSolicitudesAll
                          : () => fetchSolicitudes(
                              widget.authService.rol!, widget.authService.id!),
                      id: widget.authService.id!,
                      byRol: widget.authService.rol!,
                    )),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
