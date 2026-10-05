package com.example.cookly.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuAnchorType
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.cookly.data.FoodCategories
import com.example.cookly.data.FoodCategory
import com.example.cookly.navigation.Screen
import com.example.cookly.ui.components.AppBottomBar
import com.example.cookly.ui.components.AuthPrimaryButton
import com.example.cookly.ui.components.AuthTextField
import com.example.cookly.viewmodel.AddProductViewModel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddProductScreen(
    onProductSaved: () -> Unit,
    onNavigateToNevera: () -> Unit,
    onNavigateToReminders: () -> Unit,
    viewModel: AddProductViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val colors = MaterialTheme.colorScheme
    val isEditMode = viewModel.isEditMode
    var showDatePicker by remember { mutableStateOf(false) }
    var showDeleteDialog by remember { mutableStateOf(false) }
    var categoryMenuExpanded by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        viewModel.saved.collect { onProductSaved() }
    }

    Scaffold(
        containerColor = colors.background,
        bottomBar = {
            AppBottomBar(
                currentRoute = Screen.AddProduct.route,
                onNeveraClick = onNavigateToNevera,
                onRemindersClick = onNavigateToReminders
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
        ) {
            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = if (isEditMode) "Editar producto" else "Agregar producto",
                style = MaterialTheme.typography.titleLarge,
                color = colors.onBackground,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(24.dp))

            AuthTextField(
                value = uiState.name,
                onValueChange = viewModel::onNameChange,
                placeholder = "Nombre del producto",
                keyboardOptions = KeyboardOptions(
                    capitalization = KeyboardCapitalization.Sentences,
                    imeAction = ImeAction.Next
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "Categoría del producto",
                style = MaterialTheme.typography.bodyMedium,
                color = colors.onSurface,
                fontWeight = FontWeight.Medium
            )
            Spacer(modifier = Modifier.height(8.dp))

            ExposedDropdownMenuBox(
                expanded = categoryMenuExpanded,
                onExpandedChange = { categoryMenuExpanded = it }
            ) {
                OutlinedTextField(
                    value = uiState.selectedCategory?.name ?: "",
                    onValueChange = {},
                    readOnly = true,
                    modifier = Modifier
                        .fillMaxWidth()
                        .menuAnchor(
                            type = ExposedDropdownMenuAnchorType.PrimaryNotEditable,
                            enabled = true
                        ),
                    placeholder = { Text("Opcional") },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = categoryMenuExpanded) },
                    leadingIcon = uiState.selectedCategory?.let { cat ->
                        { Icon(cat.icon, contentDescription = null) }
                    }
                )
                ExposedDropdownMenu(
                    expanded = categoryMenuExpanded,
                    onDismissRequest = { categoryMenuExpanded = false }
                ) {
                    DropdownMenuItem(
                        text = { Text("Sin categoría") },
                        onClick = {
                            viewModel.onCategorySelected(null)
                            categoryMenuExpanded = false
                        }
                    )
                    FoodCategories.all.forEach { category: FoodCategory ->
                        DropdownMenuItem(
                            text = { Text(category.name) },
                            leadingIcon = { Icon(category.icon, contentDescription = null) },
                            onClick = {
                                viewModel.onCategorySelected(category)
                                categoryMenuExpanded = false
                            }
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "Fecha de vencimiento",
                style = MaterialTheme.typography.bodyMedium,
                color = colors.onSurface,
                fontWeight = FontWeight.Medium
            )
            Spacer(modifier = Modifier.height(8.dp))

            OutlinedButton(
                onClick = { showDatePicker = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = uiState.expirationDate?.let { formatExpiration(it) }
                        ?: "Seleccionar fecha"
                )
            }

            uiState.selectedCategory?.let { category ->
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Recomendado: ${category.minDays} a ${category.maxDays} días en refrigeración",
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.onSurface
                )
                Text(
                    text = "La fecha sugerida usa el mínimo del rango por seguridad. Ajústala según el empaque si lo necesitas.",
                    style = MaterialTheme.typography.bodySmall,
                    color = colors.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(28.dp))

            AuthPrimaryButton(
                text = if (isEditMode) "Guardar cambios" else "Guardar producto",
                enabled = uiState.isValid,
                onClick = viewModel::saveProduct
            )

            if (isEditMode) {
                Spacer(modifier = Modifier.height(8.dp))
                TextButton(
                    onClick = { showDeleteDialog = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Eliminar producto", color = colors.error)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }

    if (showDatePicker) {
        val datePickerState = rememberDatePickerState(
            initialSelectedDateMillis = uiState.expirationDate ?: System.currentTimeMillis()
        )
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(
                    onClick = {
                        datePickerState.selectedDateMillis?.let(viewModel::onDateSelected)
                        showDatePicker = false
                    }
                ) {
                    Text("Aceptar")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) {
                    Text("Cancelar")
                }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }

    if (showDeleteDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteDialog = false },
            title = { Text("¿Eliminar producto?") },
            text = { Text("Esta acción no se puede deshacer.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        showDeleteDialog = false
                        viewModel.deleteProduct()
                    }
                ) {
                    Text("Eliminar", color = colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteDialog = false }) {
                    Text("Cancelar")
                }
            }
        )
    }
}

private fun formatExpiration(millis: Long): String {
    return SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date(millis))
}
