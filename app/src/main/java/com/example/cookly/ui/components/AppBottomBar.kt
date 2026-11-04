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
import com.example.cookly.navigation.Screen

/**
 * Barra inferior de la sección principal: Nevera y Recordatorios.
 */
@Composable
fun AppBottomBar(
    currentRoute: String,
    onNeveraClick: () -> Unit,
    onRemindersClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = MaterialTheme.colorScheme
    val neveraSelected = currentRoute == Screen.Nevera.route ||
        currentRoute.startsWith("add_product")
    val remindersSelected = currentRoute == Screen.Reminders.route

    val itemColors = NavigationBarItemDefaults.colors(
        selectedIconColor = colors.tertiary,
        selectedTextColor = colors.onBackground,
        indicatorColor = colors.tertiary.copy(alpha = 0.18f),
        unselectedIconColor = colors.onSurfaceVariant,
        unselectedTextColor = colors.onSurfaceVariant
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
            selected = remindersSelected,
            enabled = true,
            onClick = onRemindersClick,
            icon = { Icon(Icons.Default.Notifications, contentDescription = "Recordatorios") },
            label = { Text("Recordatorios") },
            colors = itemColors
        )
    }
}
