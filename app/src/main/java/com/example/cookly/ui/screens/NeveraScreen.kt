package com.example.cookly.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Logout
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Kitchen
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.cookly.data.FoodCategories
import com.example.cookly.navigation.Screen
import com.example.cookly.ui.components.AppBottomBar
import com.example.cookly.ui.theme.CooklyWarning
import com.example.cookly.viewmodel.AuthViewModel
import com.example.cookly.viewmodel.NeveraViewModel
import com.example.cookly.viewmodel.ProductUi

@Composable
fun NeveraScreen(
    onNavigateToAddProduct: () -> Unit,
    onNavigateToEditProduct: (Int) -> Unit,
    onNavigateToReminders: () -> Unit,
    onNavigateToAbout: () -> Unit,
    onLogout: () -> Unit,
    viewModel: NeveraViewModel = viewModel(),
    authViewModel: AuthViewModel = viewModel()
) {
    val products by viewModel.products.collectAsState()
    val colors = MaterialTheme.colorScheme
    var showLogoutDialog by remember { mutableStateOf(false) }

    Scaffold(
        containerColor = colors.background,
        bottomBar = {
            AppBottomBar(
                currentRoute = Screen.Nevera.route,
                onNeveraClick = {},
                onRemindersClick = onNavigateToReminders
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 20.dp)
        ) {
            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Mi nevera",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.onBackground,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.weight(1f)
                )

                IconButton(onClick = onNavigateToAbout) {
                    Icon(
                        imageVector = Icons.Default.Info,
                        contentDescription = "Acerca de",
                        tint = colors.onSurfaceVariant,
                        modifier = Modifier.size(22.dp)
                    )
                }

                // Logout discreto: no usa el estilo relleno de cámara/+.
                IconButton(onClick = { showLogoutDialog = true }) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.Logout,
                        contentDescription = "Cerrar sesión",
                        tint = colors.onSurfaceVariant,
                        modifier = Modifier.size(22.dp)
                    )
                }

                Spacer(modifier = Modifier.width(4.dp))

                // Cámara no implementada: se muestra deshabilitada a propósito.
                FilledIconButton(
                    onClick = {},
                    enabled = false,
                    shape = CircleShape,
                    colors = IconButtonDefaults.filledIconButtonColors(
                        containerColor = colors.tertiary,
                        contentColor = colors.onTertiary,
                        disabledContainerColor = colors.outline.copy(alpha = 0.45f),
                        disabledContentColor = colors.onSurfaceVariant.copy(alpha = 0.55f)
                    )
                ) {
                    Icon(
                        Icons.Default.PhotoCamera,
                        contentDescription = "Cámara (no disponible aún)"
                    )
                }

                Spacer(modifier = Modifier.width(8.dp))

                FilledIconButton(
                    onClick = onNavigateToAddProduct,
                    shape = CircleShape,
                    colors = IconButtonDefaults.filledIconButtonColors(
                        containerColor = colors.primary,
                        contentColor = colors.onPrimary
                    )
                ) {
                    Icon(Icons.Default.Add, contentDescription = "Agregar producto")
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Lista reactiva: si Room queda vacía, se muestra el estado vacío (nunca en blanco).
            if (products.isEmpty()) {
                EmptyNeveraState(modifier = Modifier.fillMaxSize())
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(bottom = 16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(products, key = { it.id }) { product ->
                        ProductCard(
                            product = product,
                            onClick = { onNavigateToEditProduct(product.id) },
                            onDelete = { viewModel.deleteProduct(product) }
                        )
                    }
                }
            }
        }
    }

    if (showLogoutDialog) {
        AlertDialog(
            onDismissRequest = { showLogoutDialog = false },
            title = { Text("¿Cerrar sesión?") },
            text = {
                Text("Podrás volver a entrar con tu correo. Tus productos y recordatorios se conservan.")
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showLogoutDialog = false
                        // Firebase + Credential Manager; luego el NavHost va a login.
                        authViewModel.signOut(onLogout)
                    }
                ) {
                    Text("Cerrar sesión", color = colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showLogoutDialog = false }) {
                    Text("Cancelar")
                }
            }
        )
    }
}

@Composable
private fun EmptyNeveraState(modifier: Modifier = Modifier) {
    val colors = MaterialTheme.colorScheme
    Box(modifier = modifier, contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(
                imageVector = Icons.Default.Kitchen,
                contentDescription = null,
                modifier = Modifier.size(72.dp),
                tint = colors.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = "Tu nevera está vacía. Agrega tu primer producto.",
                style = MaterialTheme.typography.bodyLarge,
                color = colors.onSurfaceVariant,
                textAlign = TextAlign.Center
            )
        }
    }
}

@Composable
private fun ProductCard(
    product: ProductUi,
    onClick: () -> Unit,
    onDelete: () -> Unit
) {
    val colors = MaterialTheme.colorScheme
    // Recalcula en cada recomposición para que el badge cambie con el paso de los días.
    val daysRemaining = product.daysRemaining
    val categoryIcon = FoodCategories.findByName(product.category)?.icon
        ?: Icons.Default.Kitchen

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = colors.surfaceVariant),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Surface(
                shape = CircleShape,
                color = colors.tertiary.copy(alpha = 0.16f),
                modifier = Modifier.size(44.dp)
            ) {
                Icon(
                    imageVector = categoryIcon,
                    contentDescription = product.category,
                    tint = colors.tertiary,
                    modifier = Modifier.padding(10.dp)
                )
            }
            Spacer(modifier = Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = product.name,
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontSize = MaterialTheme.typography.titleLarge.fontSize
                    ),
                    color = colors.onSurface,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(8.dp))
                ExpirationBadge(daysRemaining = daysRemaining)
            }
            // IconButton consume el clic y no abre la edición de la tarjeta.
            IconButton(onClick = onDelete) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = "Eliminar ${product.name}",
                    tint = colors.error
                )
            }
        }
    }
}

@Composable
private fun ExpirationBadge(daysRemaining: Int) {
    val colors = MaterialTheme.colorScheme
    val (label, badgeColor) = when {
        daysRemaining <= 0 -> "Vence hoy" to colors.error
        daysRemaining == 1 -> "Vence mañana" to CooklyWarning
        else -> "$daysRemaining días" to colors.tertiary
    }

    Surface(
        shape = RoundedCornerShape(50),
        color = badgeColor.copy(alpha = 0.16f)
    ) {
        Text(
            text = label,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
            style = MaterialTheme.typography.bodySmall,
            color = badgeColor,
            fontWeight = FontWeight.SemiBold
        )
    }
}
