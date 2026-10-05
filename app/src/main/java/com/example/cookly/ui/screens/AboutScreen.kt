package com.example.cookly.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutScreen(onBack: () -> Unit) {
    val colors = MaterialTheme.colorScheme
    Scaffold(
        containerColor = colors.background,
        topBar = {
            TopAppBar(
                title = { Text("Acerca de") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Volver"
                        )
                    }
                }
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp, vertical = 8.dp)
        ) {
            Text(
                text = "Cookly",
                style = MaterialTheme.typography.headlineLarge,
                fontWeight = FontWeight.Bold,
                color = colors.onBackground
            )
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = "Una app para controlar el vencimiento de los productos en tu nevera " +
                    "y recibir recordatorios de las comidas del día. El objetivo es reducir " +
                    "el desperdicio de alimentos y organizar mejor tu cocina.",
                style = MaterialTheme.typography.bodyLarge,
                color = colors.onSurface
            )
            Spacer(modifier = Modifier.height(24.dp))
            Text(
                text = "Universidad y curso",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
                color = colors.onBackground
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Universidad del Cauca\nIngeniería de Sistemas — Desarrollo de aplicaciones móviles",
                style = MaterialTheme.typography.bodyLarge,
                color = colors.onSurface
            )
            Spacer(modifier = Modifier.height(24.dp))
            Text(
                text = "Integrantes",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
                color = colors.onBackground
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Ronal Santiago Valdez Jurado\n Maria Alejandra Solarte\nProyecto académico de la Universidad del Cauca.",
                style = MaterialTheme.typography.bodyLarge,
                color = colors.onSurface,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
