package com.example.cookly.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TimePicker
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.cookly.data.Reminder
import com.example.cookly.navigation.Screen
import com.example.cookly.ui.components.AppBottomBar
import com.example.cookly.ui.components.AuthPrimaryButton
import com.example.cookly.ui.components.AuthTextField
import com.example.cookly.viewmodel.ReminderFormState
import com.example.cookly.viewmodel.RemindersViewModel
import com.example.cookly.viewmodel.WEEK_DAY_LABELS
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

private val LeadPresets = listOf(5, 10, 15, 30, 60)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RemindersScreen(
    onBack: () -> Unit,
    onNavigateToNevera: () -> Unit,
    viewModel: RemindersViewModel = viewModel()
) {
    val reminders by viewModel.reminders.collectAsState()
    val form by viewModel.form.collectAsState()
    val colors = MaterialTheme.colorScheme
    var showSheet by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    Scaffold(
        containerColor = colors.background,
        bottomBar = {
            AppBottomBar(
                currentRoute = Screen.Reminders.route,
                onNeveraClick = onNavigateToNevera,
                onRemindersClick = {}
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 20.dp)
        ) {
            Spacer(modifier = Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Volver",
                        tint = colors.onBackground
                    )
                }
                Text(
                    text = "Recordatorios",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.onBackground,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            TodayInfoCard()

            Spacer(modifier = Modifier.height(16.dp))

            LazyColumn(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                contentPadding = PaddingValues(bottom = 12.dp)
            ) {
                if (reminders.isEmpty()) {
                    item {
                        Text(
                            text = "Aún no tienes recordatorios. Agrega uno para tus comidas.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = colors.onSurfaceVariant,
                            textAlign = TextAlign.Center,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 24.dp)
                        )
                    }
                } else {
                    items(reminders, key = { it.id }) { reminder ->
                        ReminderCard(
                            reminder = reminder,
                            onToggle = { viewModel.toggleReminder(reminder) },
                            onDelete = { viewModel.deleteReminder(reminder) }
                        )
                    }
                }

                item {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "Días del nuevo recordatorio",
                        style = MaterialTheme.typography.bodyMedium,
                        color = colors.onSurface,
                        fontWeight = FontWeight.Medium
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    WeekDayChips(
                        selected = form.days,
                        onToggle = viewModel::toggleFormDay
                    )
                }
            }

            AuthPrimaryButton(
                text = "Agregar recordatorio",
                enabled = true,
                onClick = { showSheet = true },
                modifier = Modifier.padding(bottom = 12.dp)
            )
        }
    }

    if (showSheet) {
        ModalBottomSheet(
            onDismissRequest = { showSheet = false },
            sheetState = sheetState
        ) {
            NewReminderSheet(
                form = form,
                onNameChange = viewModel::onNameChange,
                onTimeChange = viewModel::onTimeChange,
                onLeadPresetSelected = viewModel::onLeadPresetSelected,
                onCustomLeadSelected = viewModel::onCustomLeadSelected,
                onCustomLeadMinutesChange = viewModel::onCustomLeadMinutesChange,
                onToggleDay = viewModel::toggleFormDay,
                onSave = {
                    viewModel.addReminder()
                    showSheet = false
                }
            )
        }
    }
}

@Composable
private fun TodayInfoCard() {
    val colors = MaterialTheme.colorScheme
    val today = remember {
        val locale = Locale("es", "ES")
        val formatted = SimpleDateFormat("d 'de' MMMM", locale).format(Date())
        "Hoy, $formatted"
    }
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = colors.surfaceVariant)
    ) {
        Text(
            text = today.replaceFirstChar { it.uppercase() },
            modifier = Modifier.padding(16.dp),
            style = MaterialTheme.typography.bodyLarge,
            color = colors.onSurface,
            fontWeight = FontWeight.Medium
        )
    }
}

@Composable
private fun ReminderCard(
    reminder: Reminder,
    onToggle: () -> Unit,
    onDelete: () -> Unit
) {
    val colors = MaterialTheme.colorScheme
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = colors.surfaceVariant)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Surface(
                shape = CircleShape,
                color = colors.tertiary.copy(alpha = 0.16f),
                modifier = Modifier.size(44.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Restaurant,
                    contentDescription = null,
                    tint = colors.tertiary,
                    modifier = Modifier.padding(10.dp)
                )
            }
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 12.dp)
            ) {
                Text(
                    text = reminder.name,
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontSize = MaterialTheme.typography.bodyLarge.fontSize
                    ),
                    color = colors.onSurface,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = formatHour12(reminder.hour, reminder.minute),
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.onSurfaceVariant
                )
                Text(
                    text = "Avisa ${formatLead(reminder.leadMinutes)} · ${reminder.daysOfWeek}",
                    style = MaterialTheme.typography.bodySmall,
                    color = colors.onSurfaceVariant
                )
            }
            Switch(
                checked = reminder.isEnabled,
                onCheckedChange = { onToggle() },
                colors = SwitchDefaults.colors(
                    checkedThumbColor = colors.onTertiary,
                    checkedTrackColor = colors.tertiary
                )
            )
            IconButton(onClick = onDelete) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = "Eliminar ${reminder.name}",
                    tint = colors.error
                )
            }
        }
    }
}

@Composable
private fun WeekDayChips(
    selected: Set<String>,
    onToggle: (String) -> Unit
) {
    val colors = MaterialTheme.colorScheme
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        WEEK_DAY_LABELS.forEach { day ->
            val isOn = day in selected
            Surface(
                onClick = { onToggle(day) },
                shape = CircleShape,
                color = if (isOn) colors.primary else colors.background,
                contentColor = if (isOn) colors.onPrimary else colors.onSurface,
                border = BorderStroke(
                    1.dp,
                    if (isOn) colors.primary else colors.outline
                ),
                modifier = Modifier.size(40.dp)
            ) {
                Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                    Text(
                        text = day,
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.labelLarge,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NewReminderSheet(
    form: ReminderFormState,
    onNameChange: (String) -> Unit,
    onTimeChange: (Int, Int) -> Unit,
    onLeadPresetSelected: (Int) -> Unit,
    onCustomLeadSelected: () -> Unit,
    onCustomLeadMinutesChange: (String) -> Unit,
    onToggleDay: (String) -> Unit,
    onSave: () -> Unit
) {
    var showTimePicker by remember { mutableStateOf(false) }
    val colors = MaterialTheme.colorScheme

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp)
            .padding(bottom = 24.dp)
    ) {
        Text(
            text = "+ Nuevo recordatorio",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = colors.onSurface
        )
        Spacer(modifier = Modifier.height(16.dp))

        AuthTextField(
            value = form.name,
            onValueChange = onNameChange,
            placeholder = "Nombre (ej. Cena)"
        )

        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Hora",
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium
        )
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedButton(
            onClick = { showTimePicker = true },
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(Icons.Default.Schedule, contentDescription = null)
            Spacer(modifier = Modifier.size(8.dp))
            Text(formatHour12(form.hour, form.minute))
        }

        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Avisar con anticipación de",
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium
        )
        Spacer(modifier = Modifier.height(8.dp))
        LeadMinutesSelector(
            leadMinutes = form.leadMinutes,
            isCustom = form.isCustomLead,
            onPreset = onLeadPresetSelected,
            onCustom = onCustomLeadSelected,
            onCustomValue = onCustomLeadMinutesChange
        )

        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Días de la semana",
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium
        )
        Spacer(modifier = Modifier.height(8.dp))
        WeekDayChips(selected = form.days, onToggle = onToggleDay)

        Spacer(modifier = Modifier.height(24.dp))
        AuthPrimaryButton(
            text = "Guardar",
            enabled = form.isValid,
            onClick = onSave
        )
    }

    if (showTimePicker) {
        val timeState = rememberTimePickerState(
            initialHour = form.hour,
            initialMinute = form.minute,
            is24Hour = false
        )
        AlertDialog(
            onDismissRequest = { showTimePicker = false },
            confirmButton = {
                TextButton(
                    onClick = {
                        onTimeChange(timeState.hour, timeState.minute)
                        showTimePicker = false
                    }
                ) { Text("Aceptar") }
            },
            dismissButton = {
                TextButton(onClick = { showTimePicker = false }) { Text("Cancelar") }
            },
            text = { TimePicker(state = timeState) }
        )
    }
}

@Composable
private fun LeadMinutesSelector(
    leadMinutes: Int,
    isCustom: Boolean,
    onPreset: (Int) -> Unit,
    onCustom: () -> Unit,
    onCustomValue: (String) -> Unit
) {
    val colors = MaterialTheme.colorScheme
    val chipColors = FilterChipDefaults.filterChipColors(
        selectedContainerColor = colors.primary,
        selectedLabelColor = colors.onPrimary
    )
    Column {
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            LeadPresets.take(3).forEach { minutes ->
                FilterChip(
                    selected = !isCustom && leadMinutes == minutes,
                    onClick = { onPreset(minutes) },
                    label = { Text("${minutes} min") },
                    colors = chipColors
                )
            }
        }
        Spacer(modifier = Modifier.height(4.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            FilterChip(
                selected = !isCustom && leadMinutes == 30,
                onClick = { onPreset(30) },
                label = { Text("30 min") },
                colors = chipColors
            )
            FilterChip(
                selected = !isCustom && leadMinutes == 60,
                onClick = { onPreset(60) },
                label = { Text("1 hora") },
                colors = chipColors
            )
            FilterChip(
                selected = isCustom,
                onClick = onCustom,
                label = { Text("Personalizado") },
                colors = chipColors
            )
        }
        if (isCustom) {
            Spacer(modifier = Modifier.height(8.dp))
            AuthTextField(
                value = if (leadMinutes > 0) leadMinutes.toString() else "",
                onValueChange = onCustomValue,
                placeholder = "Minutos",
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
            )
        }
    }
}

private fun formatHour12(hour24: Int, minute: Int): String {
    val calendar = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, hour24)
        set(Calendar.MINUTE, minute)
    }
    return SimpleDateFormat("h:mm a", Locale.US).format(calendar.time)
}

private fun formatLead(minutes: Int): String {
    return if (minutes % 60 == 0 && minutes >= 60) {
        val hours = minutes / 60
        if (hours == 1) "1 hora antes" else "$hours horas antes"
    } else {
        "$minutes min antes"
    }
}
