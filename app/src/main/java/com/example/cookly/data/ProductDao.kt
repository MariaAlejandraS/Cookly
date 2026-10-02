package com.example.cookly.data

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

/** Acceso a productos. [getAllProducts] es Flow para que Nevera se actualice sola. */
@Dao
interface ProductDao {
    @Insert
    suspend fun insertProduct(product: Product): Long

    @Delete
    suspend fun deleteProduct(product: Product)

    @Query("SELECT * FROM products ORDER BY expirationDate ASC")
    fun getAllProducts(): Flow<List<Product>>
}
