package com.example.cookly.navigation

/**
 * Rutas de navegación de Cookly.
 * Usar [route] en el NavHost; no pasar NavController a las pantallas.
 */
sealed class Screen(val route: String) {
    data object Login : Screen("login")
    data object Register : Screen("register")
    data object Nevera : Screen("nevera")
    data object AddProduct : Screen("add_product?productId={productId}") {
        fun create(productId: Int = -1): String = "add_product?productId=$productId"
    }
    data object Reminders : Screen("reminders")
    data object About : Screen("about")
}
