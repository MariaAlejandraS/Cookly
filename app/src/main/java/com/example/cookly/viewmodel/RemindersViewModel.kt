package com.example.cookly.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.cookly.data.AppDatabase
import com.example.cookly.data.Reminder
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

/** Días en el orden de la semana, con X = miércoles para no repetir la M. */
val WEEK_DAY_LABELS = listOf("L", "M", "X", "J", "V", "S", "D")

private val DEFAULT_DAYS = setOf("L", "M", "X", "J", "V")

/** Formulario de un recordatorio nuevo, separado de la lista persistida. */
data class ReminderFormState(
    val name: String = "",
    val hour: Int = 8,
    val minute: Int = 0,
    val leadMinutes: Int = 15,
    val isCustomLead: Boolean = false,
    val days: Set<String> = DEFAULT_DAYS
) {
    val isValid: Boolean
        get() = name.isNotBlank() && days.isNotEmpty() && leadMinutes > 0
}

class RemindersViewModel(application: Application) : AndroidViewModel(application) {

    private val reminderDao = AppDatabase.getInstance(application).reminderDao()
    private val userId: String = FirebaseAuth.getInstance().currentUser?.uid.orEmpty()

    val reminders: StateFlow<List<Reminder>> = reminderDao.getAllReminders(userId)
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = emptyList()
        )

    private val _form = MutableStateFlow(ReminderFormState())
    val form: StateFlow<ReminderFormState> = _form.asStateFlow()

    fun onNameChange(value: String) {
        _form.update { it.copy(name = value) }
    }

    fun onTimeChange(hour: Int, minute: Int) {
        _form.update { it.copy(hour = hour, minute = minute) }
    }

    fun onLeadPresetSelected(minutes: Int) {
        _form.update { it.copy(leadMinutes = minutes, isCustomLead = false) }
    }

    fun onCustomLeadSelected() {
        _form.update { it.copy(isCustomLead = true) }
    }

    fun onCustomLeadMinutesChange(raw: String) {
        val minutes = raw.filter { it.isDigit() }.toIntOrNull() ?: 0
        _form.update { it.copy(leadMinutes = minutes, isCustomLead = true) }
    }

    fun toggleFormDay(day: String) {
        _form.update { current ->
            val next = current.days.toMutableSet()
            if (!next.add(day)) next.remove(day)
            current.copy(days = next)
        }
    }

    fun addReminder() {
        val state = _form.value
        if (!state.isValid) return
        viewModelScope.launch {
            reminderDao.insertReminder(
                Reminder(
                    name = state.name.trim(),
                    hour = state.hour,
                    minute = state.minute,
                    leadMinutes = state.leadMinutes,
                    isEnabled = true,
                    daysOfWeek = encodeDays(state.days),
                    userId = userId
                )
            )
            resetForm()
        }
    }

    fun toggleReminder(reminder: Reminder) {
        viewModelScope.launch {
            reminderDao.updateReminder(reminder.copy(isEnabled = !reminder.isEnabled))
        }
    }

    fun deleteReminder(reminder: Reminder) {
        viewModelScope.launch {
            reminderDao.deleteReminder(reminder)
        }
    }

    fun resetForm() {
        _form.value = ReminderFormState(days = _form.value.days)
    }

    private fun encodeDays(days: Set<String>): String {
        return WEEK_DAY_LABELS.filter { it in days }.joinToString(",")
    }
}
