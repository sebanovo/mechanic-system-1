import 'package:go_router/go_router.dart';
import '../../domain/entities/service_request.dart';
import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/home/pages/home_page.dart';
import '../../presentation/service_request/pages/request_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
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
