package com.example.cookly.data

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

/** Usuario persistido de forma local (correo único). */
@Entity(
    tableName = "users",
    indices = [Index(value = ["email"], unique = true)]
)
data class User(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val email: String,
    val password: String
)
