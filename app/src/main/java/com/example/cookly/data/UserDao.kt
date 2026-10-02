package com.example.cookly.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query

/** Acceso a la tabla de usuarios (login y registro). */
@Dao
interface UserDao {
    @Insert
    suspend fun insertUser(user: User): Long

    /** Comparación sin distinguir mayúsculas para no duplicar cuentas. */
    @Query("SELECT * FROM users WHERE LOWER(email) = LOWER(:email) LIMIT 1")
    suspend fun getUserByEmail(email: String): User?
}
