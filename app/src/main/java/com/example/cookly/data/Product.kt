package com.example.cookly.data

import androidx.room.Entity
import androidx.room.PrimaryKey

/** Producto de la nevera. La fecha de vencimiento se guarda como epoch millis. */
@Entity(tableName = "products")
data class Product(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val expirationDate: Long
)
