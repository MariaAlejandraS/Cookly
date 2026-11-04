package com.example.cookly.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.example.cookly.data.AppDatabase
import com.example.cookly.data.FoodCategories
import com.example.cookly.data.FoodCategory
import com.example.cookly.data.Product
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

private const val MILLIS_PER_DAY = 86_400_000L

data class AddProductUiState(
    val name: String = "",
    val expirationDate: Long? = null,
    val selectedCategory: FoodCategory? = null,
    val isValid: Boolean = false
)

class AddProductViewModel(
    application: Application,
    savedStateHandle: SavedStateHandle
) : AndroidViewModel(application) {

    private val productDao = AppDatabase.getInstance(application).productDao()
    private val productId: Int = savedStateHandle.get<Int>("productId") ?: -1
    val isEditMode: Boolean = productId != -1

    private var editingProduct: Product? = null

    private val _uiState = MutableStateFlow(AddProductUiState())
    val uiState: StateFlow<AddProductUiState> = _uiState.asStateFlow()

    private val _saved = Channel<Unit>(Channel.BUFFERED)
    val saved = _saved.receiveAsFlow()

    init {
        if (isEditMode) {
            viewModelScope.launch {
                val product = productDao.getProductById(productId) ?: return@launch
                editingProduct = product
                _uiState.update {
                    it.copy(
                        name = product.name,
                        expirationDate = product.expirationDate,
                        selectedCategory = FoodCategories.findByName(product.category)
                    ).withValidation()
                }
            }
        }
    }

    fun onNameChange(value: String) {
        _uiState.update { current ->
            current.copy(name = value).withValidation()
        }
    }

    fun onDateSelected(millis: Long?) {
        _uiState.update { current ->
            current.copy(expirationDate = millis).withValidation()
        }
    }

    /**
     * Al elegir categoría se sugiere hoy + minDays (nunca el máximo):
     * el mínimo del rango FDA/USDA es la opción más segura en refrigeración.
     * La fecha se puede ajustar a mano después.
     */
    fun onCategorySelected(category: FoodCategory?) {
        _uiState.update { current ->
            val suggested = category?.let { cat ->
                System.currentTimeMillis() + cat.minDays * MILLIS_PER_DAY
            }
            current.copy(
                selectedCategory = category,
                expirationDate = suggested ?: current.expirationDate
            ).withValidation()
        }
    }

    fun saveProduct() {
        val state = _uiState.value
        val date = state.expirationDate ?: return
        if (!state.isValid) return
        val uid = FirebaseAuth.getInstance().currentUser?.uid.orEmpty()
        viewModelScope.launch {
            if (isEditMode) {
                val existing = editingProduct ?: return@launch
                productDao.updateProduct(
                    existing.copy(
                        name = state.name.trim(),
                        expirationDate = date,
                        category = state.selectedCategory?.name
                    )
                )
            } else {
                productDao.insertProduct(
                    Product(
                        name = state.name.trim(),
                        expirationDate = date,
                        userId = uid,
                        category = state.selectedCategory?.name
                    )
                )
            }
            _saved.send(Unit)
        }
    }

    fun deleteProduct() {
        val existing = editingProduct ?: return
        viewModelScope.launch {
            productDao.deleteProduct(existing)
            _saved.send(Unit)
        }
    }

    private fun AddProductUiState.withValidation(): AddProductUiState {
        return copy(isValid = name.isNotBlank() && expirationDate != null)
    }
}
