package com.example.cookly.data

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

/** Producto de la nevera, asociado al UID de Firebase del usuario. */
@Entity(
    tableName = "products",
    indices = [Index(value = ["userId"])]
)
data class Product(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val name: String,
    val expirationDate: Long,
    val userId: String,
    val category: String? = null
)
