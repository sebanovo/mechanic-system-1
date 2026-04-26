import { Routes } from "@angular/router";

export const PROVIDERS_ROUTES: Routes = [
	{
		path: "", //default route
		redirectTo: "list",
		pathMatch: "full",
	},
	{
		path: "list",
		loadComponent: () =>
			import("./pages/provider-list-page/provider-list-page").then(
				m => m.ProviderListPage
			),
	},
];
