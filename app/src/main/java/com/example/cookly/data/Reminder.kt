package com.example.cookly.data

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

/**
 * Recordatorio de comida (aún sin notificaciones reales).
 * [userId] es el UID de FirebaseAuth.
 * [daysOfWeek] usa etiquetas "L,M,X,J,V,S,D" separadas por comas.
 */
@Entity(
    tableName = "reminders",
    indices = [Index(value = ["userId"])]
)
data class Reminder(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val hour: Int,
    val minute: Int,
    val leadMinutes: Int,
    val isEnabled: Boolean = true,
    val daysOfWeek: String,
    val userId: String
)
