import { Routes } from "@angular/router";
import { AdminAuthLayout } from "./core/layout/layouts/admin-auth-layout/admin-auth-layout";
import { AppLayout } from "./core/layout/layouts/app-layout/app-layout";
import { AuthLayout } from "./core/layout/layouts/auth-layout/auth-layout";
import { PublicLayout } from "./core/layout/layouts/public-layout/public-layout";
import { authGuard } from "./core/session/guards/auth.guard";

export const routes: Routes = [
	// Public
	{
		path: "",
		component: PublicLayout,
		children: [
			{
				path: "",
				loadChildren: () =>
					import("./features/public/public.routes").then(m => m.PUBLIC_ROUTES),
			},
		],
	},

	// Authentication
	{
		path: "auth",
		component: AuthLayout,
		children: [
			// public login
			{
				path: "",
				loadChildren: () =>
					import("./features/auth/auth.routes").then(m => m.AUTH_ROUTES),
			},
		],
	},

	{
		path: "",
		component: AdminAuthLayout,
		// canActivateChild: [adminGuestGuard],
		children: [
			// hidden login
			{
				path: "platform/auth",
				loadChildren: () =>
					import("./features/auth/auth.routes").then(m => m.ADMIN_ROUTES),
			},
		],
	},

	// Private
	{
		path: "app",
		canActivate: [authGuard],
		component: AppLayout,
		children: [
			// {
			//   path: "", //default route
			//   redirectTo: "dashboard",
			//   pathMatch: "full",
			// },

			// {
			//   path: "dashboard",
			//   loadChildren: () =>
			//     import("./features/dashboard/dashboard.routes").then(
			//       m => m.DASHBOARD_ROUTES
			//     ),
			// },

			// //EXAMPLE
			// {
			//   path: "tenants",
			//   canActivate: [roleGuard],
			// 	data: {
			// 		roles: ["PROVIDER_ADMIN", "CLIENT", "PLATFORM_ADMIN"],
			// 	},
			//   loadChildren: () =>
			//     import("./features/tanants/tenants.routes").then(
			//       m => m.TENANTS_ROUTES
			//     ),
			// },
			// {
			//   path: "subscriptions",
			//   loadChildren: () =>
			//     import("./features/subscriptions/subscriptions.routes").then(
			//       m => m.SUBSCRIPTIONS_ROUTES
			//     ),
			// },
			{
				path: "providers",
				loadChildren: () =>
					import("./features/providers/provider.routes").then(
						m => m.PROVIDERS_ROUTES
					),
			},

			{
				path: "provider-me",
				loadChildren: () =>
					import("./features/provider-me/provider-me.routes").then(
						m => m.PROVIDER_ME_ROUTES
					),
			},
			{
				path: "users",
				loadChildren: () =>
					import("./features/users/users.routes").then(m => m.USERS_ROUTES),
			},
			// {
			//   path: "plans",
			//   canMatch: [adminGuard],
			//   loadChildren: () =>
			//     import("./features/plans/plans.routes").then(m => m.PLANS_ROUTES),
			// },
			// {
			//   path: "access",
			//   loadChildren: () =>
			//     import("./features/access/access.routes").then(m => m.ACCESS_ROUTES),
			// },
			// {
			//   path: "roles",
			//   loadChildren: () =>
			//     import("./features/roles/roles.routes").then(m => m.ROLES_ROUTES),
			// },
			// {
			//   path: "permissions",
			//   loadChildren: () =>
			//     import("./features/permissions/permission.routes").then(
			//       m => m.PERMISSIONS_ROUTES
			//     ),
			// },
			// {
			//   path: "audit",
			//   loadChildren: () =>
			//     import("./features/audit/audit.routes").then(m => m.AUDIT_ROUTES),
			// },

			// {
			//   path: "reports",
			//   loadChildren: () =>
			//     import("./features/reports/reports.routes").then(
			//       m => m.REPORTS_ROUTES
			//     ),
			// },
			// {
			//   path: "settings",
			//   loadChildren: () =>
			//     import("./features/settings/settings.routes").then(
			//       m => m.SETTINGS_ROUTES
			//     ),
			// },
			{
				path: "**",
				loadComponent: () =>
					import("./features/not-found/pages/private-not-found-page/private-not-found-page").then(
						m => m.PrivateNotFoundPage
					),
			},
		],
	},

	//unknown routes
	{
		path: "**",
		loadComponent: () =>
			import("./features/not-found/pages/public-not-found-page/public-not-found-page").then(
				m => m.PublicNotFoundPage
			),
	},
];

// EXAMPLE
// {
// 	path: "tenants",
// 	canActivate: [roleGuard],
// 	data: {
// 		roles: ["PROVIDER_ADMIN", "CLIENT", "PLATFORM_ADMIN"],
// 	},
// 	loadChildren: () =>
// 		import("./features/tanants/tenants.routes").then(
// 			m => m.TENANTS_ROUTES),
// },
