package com.example.cookly

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.cookly.navigation.Screen
import com.example.cookly.ui.screens.AddProductScreen
import com.example.cookly.ui.screens.LoginScreen
import com.example.cookly.ui.screens.NeveraScreen
import com.example.cookly.ui.screens.RegisterScreen
import com.example.cookly.ui.theme.CooklyTheme

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

    // Tras autenticarse, Nevera es el home: se saca login/registro del back stack.
    fun goToNeveraClearingAuth() {
        navController.navigate(Screen.Nevera.route) {
            popUpTo(Screen.Login.route) { inclusive = true }
            launchSingleTop = true
        }
    }

    NavHost(
        navController = navController,
        startDestination = Screen.Login.route
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
                onOpenCamera = { /* TODO: cámara, pendiente */ },
                onNavigateToAddProduct = {
                    navController.navigate(Screen.AddProduct.route)
                }
            )
        }
        composable(Screen.AddProduct.route) {
            AddProductScreen(
                onProductSaved = { navController.popBackStack() },
                onNavigateToNevera = { navController.popBackStack() }
            )
        }
    }
}
