package com.example.cookly.ui.components

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Kitchen
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

/**
 * Barra inferior de la sección principal. Solo Nevera está activa;
 * Recordatorios queda visible pero deshabilitado.
 */
@Composable
fun AppBottomBar(
    neveraSelected: Boolean,
    onNeveraClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = MaterialTheme.colorScheme
    val itemColors = NavigationBarItemDefaults.colors(
        selectedIconColor = colors.tertiary,
        selectedTextColor = colors.onBackground,
        indicatorColor = colors.tertiary.copy(alpha = 0.18f),
        unselectedIconColor = colors.onSurfaceVariant,
        unselectedTextColor = colors.onSurfaceVariant,
        disabledIconColor = colors.onSurfaceVariant.copy(alpha = 0.38f),
        disabledTextColor = colors.onSurfaceVariant.copy(alpha = 0.38f)
    )

    NavigationBar(
        modifier = modifier,
        containerColor = colors.surface,
        contentColor = colors.onSurface
    ) {
        NavigationBarItem(
            selected = neveraSelected,
            onClick = onNeveraClick,
            icon = { Icon(Icons.Default.Kitchen, contentDescription = "Nevera") },
            label = { Text("Nevera") },
            colors = itemColors
        )
        NavigationBarItem(
            selected = false,
            enabled = false,
            onClick = {},
            icon = { Icon(Icons.Default.Notifications, contentDescription = "Recordatorios") },
            label = { Text("Recordatorios") },
            colors = itemColors
        )
    }
}
