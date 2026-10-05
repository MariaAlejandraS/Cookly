package com.example.cookly

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.cookly.navigation.Screen
import com.example.cookly.ui.screens.AboutScreen
import com.example.cookly.ui.screens.AddProductScreen
import com.example.cookly.ui.screens.LoginScreen
import com.example.cookly.ui.screens.NeveraScreen
import com.example.cookly.ui.screens.RegisterScreen
import com.example.cookly.ui.screens.RemindersScreen
import com.example.cookly.ui.theme.CooklyTheme
import com.google.firebase.auth.FirebaseAuth

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            CooklyTheme {
                CooklyNavHost()
            }
        }
    }
}

@Composable
fun CooklyNavHost() {
    val navController = rememberNavController()
    val start = if (FirebaseAuth.getInstance().currentUser != null) {
        Screen.Nevera.route
    } else {
        Screen.Login.route
    }

    fun goToNeveraClearingAuth() {
        navController.navigate(Screen.Nevera.route) {
            popUpTo(Screen.Login.route) { inclusive = true }
            launchSingleTop = true
        }
    }

    NavHost(
        navController = navController,
        startDestination = start
    ) {
        composable(Screen.Login.route) {
            LoginScreen(
                onLoginSuccess = { goToNeveraClearingAuth() },
                onNavigateToRegister = {
                    navController.navigate(Screen.Register.route)
                }
            )
        }
        composable(Screen.Register.route) {
            RegisterScreen(
                onRegisterSuccess = { goToNeveraClearingAuth() },
                onNavigateToLogin = {
                    navController.popBackStack()
                }
            )
        }
        composable(Screen.Nevera.route) {
            NeveraScreen(
                onNavigateToAddProduct = {
                    navController.navigate(Screen.AddProduct.create())
                },
                onNavigateToEditProduct = { productId ->
                    navController.navigate(Screen.AddProduct.create(productId))
                },
                onNavigateToReminders = {
                    navController.navigate(Screen.Reminders.route) {
                        launchSingleTop = true
                    }
                },
                onNavigateToAbout = {
                    navController.navigate(Screen.About.route)
                },
                onLogout = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(0) { inclusive = true }
                        launchSingleTop = true
                    }
                }
            )
        }
        composable(
            route = Screen.AddProduct.route,
            arguments = listOf(
                navArgument("productId") {
                    type = NavType.IntType
                    defaultValue = -1
                }
            )
        ) {
            AddProductScreen(
                onProductSaved = { navController.popBackStack() },
                onNavigateToNevera = { navController.popBackStack() },
                onNavigateToReminders = {
                    navController.navigate(Screen.Reminders.route) {
                        popUpTo(Screen.Nevera.route)
                        launchSingleTop = true
                    }
                }
            )
        }
        composable(Screen.Reminders.route) {
            RemindersScreen(
                onBack = { navController.popBackStack() },
                onNavigateToNevera = {
                    navController.navigate(Screen.Nevera.route) {
                        popUpTo(Screen.Nevera.route) { inclusive = false }
                        launchSingleTop = true
                    }
                }
            )
        }
        composable(Screen.About.route) {
            AboutScreen(onBack = { navController.popBackStack() })
        }
    }
}
