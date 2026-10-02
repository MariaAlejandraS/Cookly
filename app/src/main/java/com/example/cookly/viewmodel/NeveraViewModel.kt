package com.example.cookly.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.cookly.data.AppDatabase
import com.example.cookly.data.Product
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

private const val MILLIS_PER_DAY = 86_400_000L

/**
 * Modelo de UI de un producto.
 * La fecha epoch no se expone: [daysRemaining] se recalcula al leerse
 * (cada recomposición de la lista).
 */
data class ProductUi(
    val id: Long,
    val name: String,
    private val expirationDate: Long
) {
    val daysRemaining: Int
        get() = ((expirationDate - System.currentTimeMillis()) / MILLIS_PER_DAY).toInt()

    fun toEntity(): Product = Product(
        id = id,
        name = name,
        expirationDate = expirationDate
    )
}

class NeveraViewModel(application: Application) : AndroidViewModel(application) {

    private val productDao = AppDatabase.getInstance(application).productDao()

    val products: StateFlow<List<ProductUi>> = productDao.getAllProducts()
        .map { list ->
            list.map { entity ->
                ProductUi(
                    id = entity.id,
                    name = entity.name,
                    expirationDate = entity.expirationDate
                )
            }
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = emptyList()
        )

    fun deleteProduct(product: ProductUi) {
        viewModelScope.launch {
            productDao.deleteProduct(product.toEntity())
        }
    }
}
