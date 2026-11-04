package com.example.cookly.data

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Park
import androidx.compose.material.icons.filled.DinnerDining
import androidx.compose.material.icons.filled.Eco
import androidx.compose.material.icons.filled.Egg
import androidx.compose.material.icons.filled.Inventory2
import androidx.compose.material.icons.filled.LocalDrink
import androidx.compose.material.icons.filled.LunchDining
import androidx.compose.material.icons.filled.RiceBowl
import androidx.compose.material.icons.filled.SetMeal
import androidx.compose.material.icons.filled.Spa
import androidx.compose.material.icons.filled.Tapas
import androidx.compose.ui.graphics.vector.ImageVector

/**
 * Categorías basadas en plazos de refrigeración doméstica
 * (FDA FoodSafety.gov / USDA FoodKeeper).
 */
data class FoodCategory(
    val name: String,
    val minDays: Int,
    val maxDays: Int,
    val icon: ImageVector
)

object FoodCategories {
    val all: List<FoodCategory> = listOf(
        FoodCategory("Carne molida", 1, 2, Icons.Default.LunchDining),
        FoodCategory("Cortes enteros de carne", 3, 5, Icons.Default.DinnerDining),
        FoodCategory("Pollo o pavo crudo", 1, 2, Icons.Default.Egg),
        FoodCategory("Pescado y mariscos crudos", 1, 2, Icons.Default.SetMeal),
        FoodCategory("Comida cocida / sobras", 3, 4, Icons.Default.RiceBowl),
        FoodCategory("Embutidos o fiambres abiertos", 3, 5, Icons.Default.Tapas),
        FoodCategory("Lácteos abiertos", 5, 7, Icons.Default.LocalDrink),
        FoodCategory("Verduras de hoja", 3, 7, Icons.Default.Eco),
        FoodCategory("Frutas blandas", 1, 2, Icons.Default.Spa),
        FoodCategory("Frutas firmes", 5, 7, Icons.Default.Park),
        FoodCategory("Otros / enlatados abiertos", 3, 5, Icons.Default.Inventory2)
    )

    fun findByName(name: String?): FoodCategory? {
        if (name.isNullOrBlank()) return null
        return all.find { it.name == name }
    }
}
