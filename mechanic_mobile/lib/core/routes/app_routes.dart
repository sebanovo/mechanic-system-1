import 'package:go_router/go_router.dart';
import 'package:mechanic_mobile/presentation/pages/technicians_page.dart';
import '../../domain/entities/service_request.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/request_detail_page.dart';
import '../../presentation/pages/vehicles_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/vehicles',
      builder: (context, state) => const VehiclesPage(),
    ),
    GoRoute(
      path: '/technicians',
      builder: (context, state) => const TechniciansPage(),
    ),
    GoRoute(
      path: '/request/:id',
      builder: (context, state) {
        // We pass the ServiceRequest as an extra object to avoid fetching it again just for the detail view
        // in this simple static data approach.
        final request = state.extra as ServiceRequest;
        return RequestDetailPage(request: request);
      },
    ),
  ],
);
