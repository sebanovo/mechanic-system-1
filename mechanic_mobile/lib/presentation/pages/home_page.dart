import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../core/di/injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel _viewModel;
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<HomeViewModel>();
    _authViewModel = sl<AuthViewModel>();

    // Cargar datos del usuario si no existen
    if (_authViewModel.user == null) {
      _authViewModel.loadMe();
    }

    _loadIncidentsByRole();
  }

  Future<void> _loadIncidentsByRole() async {
    final userRole = _getUserRole(_authViewModel.user?.roleCodes);

    if (userRole == 'PLATFORM_ADMIN') {
      await _viewModel.loadAllIncidents();
    } else if (userRole == 'CLIENT') {
      await _viewModel.loadRequests();
    }
  }

  void _showInfoSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _logout() {
    _authViewModel.logout();
    _showInfoSnackBar('Sesión cerrada correctamente');
    context.go('/login');
  }

  // ✅ Obtener el primer rol de la lista de roleCodes
  String? _getUserRole(List<String>? roleCodes) {
    if (roleCodes == null || roleCodes.isEmpty) return null;
    return roleCodes.first;
  }

  String _getRoleDisplayName(List<String>? roleCodes) {
    final role = _getUserRole(roleCodes);
    switch (role) {
      case 'PROVIDER_ADMIN':
        return 'Taller / Proveedor';
      case 'CLIENT':
        return 'Cliente';
      case 'PLATFORM_ADMIN':
        return 'Administrador';
      case 'TECHNICIAN':
        return 'Técnico';
      default:
        return 'Usuario';
    }
  }

  // ✅ Verificar si el usuario tiene un rol específico
  bool _hasRole(List<String>? roleCodes, String role) {
    return roleCodes?.contains(role) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // final userRole = _getUserRole(_authViewModel.user?.roleCodes);
    final isClient = _hasRole(_authViewModel.user?.roleCodes, 'CLIENT');
    final isAdmin = _hasRole(_authViewModel.user?.roleCodes, 'PLATFORM_ADMIN');

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Todos los Incidentes' : 'Mis Solicitudes'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Solo mostrar vehículos si es CLIENT
          if (isClient)
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () {
                context.push('/vehicles');
              },
              tooltip: 'Mis vehículos',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      drawer: ListenableBuilder(
        listenable: _authViewModel,
        builder: (context, _) {
          final user = _authViewModel.user;
          final userRole = _getUserRole(user?.roleCodes);
          final isProvider = _hasRole(user?.roleCodes, 'PROVIDER_ADMIN');
          final isClient = _hasRole(user?.roleCodes, 'CLIENT');
          final isAdmin = _hasRole(user?.roleCodes, 'PLATFORM_ADMIN');

          return Drawer(
            child: Container(
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue.shade800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(
                                _getRoleIcon(userRole),
                                size: 35,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          user?.fullName ?? 'Cargando...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: Colors.blue.shade100,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getRoleDisplayName(user?.roleCodes),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Opciones del menú
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Inicio',
                    onTap: () {
                      context.pop();
                      _loadIncidentsByRole();
                    },
                  ),

                  // Solo mostrar vehículos si es CLIENT
                  if (isClient)
                    _buildDrawerItem(
                      icon: Icons.directions_car,
                      title: 'Mis vehículos',
                      onTap: () {
                        context.pop();
                        context.push('/vehicles');
                      },
                    ),

                  // Solo mostrar técnicos si es PROVIDER_ADMIN
                  if (isProvider)
                    _buildDrawerItem(
                      icon: Icons.construction,
                      title: 'Mis Técnicos',
                      onTap: () {
                        context.pop();
                        context.push('/technicians');
                      },
                    ),

                  if (isProvider)
                    _buildDrawerItem(
                      icon: Icons.business,
                      title: 'Mi Taller',
                      onTap: () {
                        context.pop();
                        context.push('/provider-profile');
                      },
                    ),

                  if (userRole == 'PLATFORM_ADMIN')
                    _buildDrawerItem(
                      icon: Icons.business_center,
                      title: 'Proveedores',
                      onTap: () {
                        context.pop();
                        context.push('/admin/providers');
                      },
                    ),

                  if (isProvider)
                    _buildDrawerItem(
                      icon: Icons.miscellaneous_services,
                      title: 'Servicios',
                      onTap: () {
                        context.pop();
                        context.push('/catalog-services');
                      },
                    ),

                  // Admin puede ir a la gestión de incidentes
                  if (isAdmin)
                    _buildDrawerItem(
                      icon: Icons.admin_panel_settings,
                      title: 'Panel de Control',
                      onTap: () {
                        context.pop();
                        context.push('/admin/incidents');
                      },
                    ),

                  // Provider: Solicitudes disponibles
                  if (isProvider)
                    _buildDrawerItem(
                      icon: Icons.list_alt,
                      title: 'Solicitudes Disponibles',
                      onTap: () {
                        context.pop();
                        context.push('/provider/available-requests');
                      },
                    ),

                  // Provider: Operaciones activas
                  if (isProvider)
                    _buildDrawerItem(
                      icon: Icons.engineering,
                      title: 'Operaciones Activas',
                      onTap: () {
                        context.pop();
                        context.push('/provider/active-operations');
                      },
                    ),

                  // Cliente: Mis solicitudes (navegar a lista completa)
                  if (isClient)
                    _buildDrawerItem(
                      icon: Icons.list_alt,
                      title: 'Mis Solicitudes',
                      onTap: () {
                        context.pop();
                        context.push('/incidents');
                      },
                    ),

                  _buildDrawerItem(
                    icon: Icons.notifications,
                    title: 'Mis Dispositivos',
                    onTap: () {
                      context.pop();
                      context.push('/devices');
                    },
                  ),

                  const Divider(),

                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Cerrar sesión',
                    onTap: _logout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _viewModel.errorMessage!,
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _loadIncidentsByRole();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (_viewModel.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.blue.shade200),
                  const SizedBox(height: 16),
                  Text(
                    isAdmin
                        ? 'No hay incidentes registrados'
                        : 'No hay solicitudes activas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isClient)
                    Text(
                      'Toca el botón + para solicitar auxilio',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  if (isAdmin)
                    Text(
                      'Los incidentes aparecerán aquí cuando los clientes los creen',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _loadIncidentsByRole(),
            color: Colors.blue,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _viewModel.requests.length,
              itemBuilder: (context, index) {
                final request = _viewModel.requests[index];
                return _buildRequestCard(request, isAdmin);
              },
            ),
          );
        },
      ),
      floatingActionButton: isClient
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/create-incident');
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva solicitud'),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red.shade700 : Colors.blue.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red.shade700 : Colors.grey.shade800,
          fontWeight: isDestructive ? FontWeight.w500 : null,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.blue.shade50,
      splashColor: Colors.blue.shade100,
    );
  }

  IconData _getRoleIcon(String? roleCode) {
    switch (roleCode) {
      case 'PROVIDER_ADMIN':
        return Icons.build_circle;
      case 'CLIENT':
        return Icons.person;
      case 'PLATFORM_ADMIN':
        return Icons.admin_panel_settings;
      case 'TECHNICIAN':
        return Icons.handyman;
      default:
        return Icons.person;
    }
  }

  Widget _buildRequestCard(dynamic request, bool isAdmin) {
    // ✅ Obtener valores de forma segura (usando try-catch o verificando existencia)
    final String id = request.id ?? '';

    // ✅ Status - casi siempre existe
    final String status = request.status ?? 'PENDING';

    // ✅ Priority - puede llamarse 'priority' o 'servicePriority'
    String priority = 'MEDIUM';
    try {
      priority = request.priority ?? request.servicePriority ?? 'MEDIUM';
    } catch (e) {
      priority = 'MEDIUM';
    }

    // ✅ Título - puede ser 'title' o 'description'
    String title = '';
    try {
      title = request.title ?? request.description ?? 'Sin título';
    } catch (e) {
      title = request.description ?? 'Sin título';
    }

    // ✅ Nombre del taller/técnico
    String assignedTo = 'Buscando taller...';
    try {
      if (request.assignedTechnician?.fullName != null) {
        assignedTo = request.assignedTechnician!.fullName;
      } else if (request.provider?.businessName != null) {
        assignedTo = request.provider!.businessName;
      } else if (request.mechanicName != null &&
          request.mechanicName.isNotEmpty) {
        assignedTo = request.mechanicName;
      }
    } catch (e) {
      assignedTo = 'En proceso...';
    }

    // ✅ Nombre del cliente (para admin)
    String clientName = '';
    try {
      if (request.clientUser?.fullName != null) {
        clientName = request.clientUser!.fullName;
      }
    } catch (e) {
      clientName = '';
    }

    final statusConfig = _getStatusConfig(status);

    // Título para admin
    String displayTitle = title;
    if (isAdmin && clientName.isNotEmpty) {
      displayTitle = '$clientName: $title';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusConfig['color']!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (isAdmin) {
            context.push('/admin/incident/$id');
          } else {
            context.push('/incident-detail/$id', extra: request);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusConfig['color']!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      statusConfig['icon'],
                      color: statusConfig['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusConfig['color']!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusConfig['color'],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      assignedTo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (priority != 'MEDIUM')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: priority == 'HIGH' || priority == 'URGENT'
                            ? Colors.red.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: priority == 'HIGH' || priority == 'URGENT'
                              ? Colors.red.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
              if (isAdmin && request.provider != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        request.provider!.businessName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return {'color': Colors.orange, 'icon': Icons.pending_actions};
      case 'PUBLISHED':
        return {'color': Colors.blue, 'icon': Icons.publish};
      case 'ASSIGNED':
        return {'color': Colors.purple, 'icon': Icons.person_pin_circle};
      case 'EN_ROUTE':
        return {'color': Colors.cyan, 'icon': Icons.directions_car};
      case 'ON_SITE':
        return {'color': Colors.teal, 'icon': Icons.location_on};
      case 'IN_PROGRESS':
        return {'color': Colors.indigo, 'icon': Icons.build};
      case 'COMPLETED':
        return {'color': Colors.green, 'icon': Icons.check_circle};
      case 'CANCELLED':
        return {'color': Colors.red, 'icon': Icons.cancel};
      default:
        return {'color': Colors.grey, 'icon': Icons.help_outline};
    }
  }
}
