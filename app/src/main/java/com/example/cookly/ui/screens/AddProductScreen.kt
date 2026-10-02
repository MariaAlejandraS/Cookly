package com.example.cookly.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
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
    viewModel: AddProductViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val colors = MaterialTheme.colorScheme
    var showDatePicker by remember { mutableStateOf(false) }
    val datePickerState = rememberDatePickerState(
        initialSelectedDateMillis = System.currentTimeMillis()
    )

    LaunchedEffect(Unit) {
        // Al guardar en Room, volvemos a Nevera (popBackStack).
        viewModel.saved.collect { onProductSaved() }
    }

    Scaffold(
        containerColor = colors.background,
        bottomBar = {
            AppBottomBar(
                neveraSelected = true,
                onNeveraClick = onNavigateToNevera
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 20.dp)
        ) {
            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "Agregar producto",
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

            Spacer(modifier = Modifier.height(28.dp))

            AuthPrimaryButton(
                text = "Guardar producto",
                // Nombre no vacío + fecha elegida (epoch millis en el ViewModel).
                enabled = uiState.isValid,
                onClick = viewModel::saveProduct
            )
        }
    }

    if (showDatePicker) {
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
}

private fun formatExpiration(millis: Long): String {
    return SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date(millis))
}
