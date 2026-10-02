package com.example.cookly.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.cookly.data.AppDatabase
import com.example.cookly.data.Product
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class AddProductUiState(
    val name: String = "",
    val expirationDate: Long? = null,
    val isValid: Boolean = false
)

class AddProductViewModel(application: Application) : AndroidViewModel(application) {

    private val productDao = AppDatabase.getInstance(application).productDao()

    private val _uiState = MutableStateFlow(AddProductUiState())
    val uiState: StateFlow<AddProductUiState> = _uiState.asStateFlow()

    private val _saved = Channel<Unit>(Channel.BUFFERED)
    val saved = _saved.receiveAsFlow()

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

    fun saveProduct() {
        val state = _uiState.value
        val date = state.expirationDate ?: return
        if (!state.isValid) return
        viewModelScope.launch {
            productDao.insertProduct(
                Product(
                    name = state.name.trim(),
                    expirationDate = date
                )
            )
            _saved.send(Unit)
        }
    }

    private fun AddProductUiState.withValidation(): AddProductUiState {
        return copy(isValid = name.isNotBlank() && expirationDate != null)
    }
}
