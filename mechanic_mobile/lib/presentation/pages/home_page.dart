import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../core/di/injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<HomeViewModel>();
    _viewModel.loadRequests();
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
    // TODO: Call auth.logout()
    _showInfoSnackBar('Sesión cerrada correctamente');
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
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
      drawer: Drawer(
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
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: Colors.blue),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Usuario Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'cliente@ejemplo.com',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.home,
                title: 'Inicio',
                onTap: () {
                  context.pop();
                },
              ),
              _buildDrawerItem(
                icon: Icons.directions_car,
                title: 'Mis vehículos',
                onTap: () {
                  context.pop();
                  context.push('/vehicles');
                },
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title: 'Historial',
                onTap: () {
                  _showInfoSnackBar('Historial (próximamente)');
                },
              ),
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Mi perfil',
                onTap: () {
                  _showInfoSnackBar('Perfil (próximamente)');
                },
              ),
              _buildDrawerItem(
                icon: Icons.support_agent,
                title: 'Soporte',
                onTap: () {
                  _showInfoSnackBar('Soporte (próximamente)');
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
                      _viewModel.loadRequests();
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
                    'No hay solicitudes activas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca el botón + para solicitar auxilio',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _viewModel.loadRequests(),
            color: Colors.blue,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _viewModel.requests.length,
              itemBuilder: (context, index) {
                final request = _viewModel.requests[index];
                return _buildRequestCard(request);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showInfoSnackBar('Reportar nueva emergencia');
          // TODO: Navigate to create request page
          // context.push('/new-request');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva solicitud'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
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

  Widget _buildRequestCard(dynamic request) {
    // Mapeo de estados a colores e íconos
    final statusConfig = _getStatusConfig(request.status);

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
          context.push('/request/${request.id}', extra: request);
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
                          request.description,
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
                            request.status,
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
                  Text(
                    request.mechanicName.isNotEmpty
                        ? request.mechanicName
                        : 'Buscando mecánico...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                ],
              ),
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
      case 'ASSIGNED':
        return {'color': Colors.blue, 'icon': Icons.person_pin_circle};
      case 'EN_ROUTE':
        return {'color': Colors.cyan, 'icon': Icons.directions_car};
      case 'ON_SITE':
        return {'color': Colors.purple, 'icon': Icons.location_on};
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}
