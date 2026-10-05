package com.example.cookly.data

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

/** Acceso a recordatorios filtrados por el usuario autenticado. */
@Dao
interface ReminderDao {
    @Insert
    suspend fun insertReminder(reminder: Reminder): Long

    @Delete
    suspend fun deleteReminder(reminder: Reminder)

    @Update
    suspend fun updateReminder(reminder: Reminder)

    @Query("SELECT * FROM reminders WHERE userId = :userId ORDER BY hour ASC, minute ASC")
    fun getAllReminders(userId: String): Flow<List<Reminder>>
}
