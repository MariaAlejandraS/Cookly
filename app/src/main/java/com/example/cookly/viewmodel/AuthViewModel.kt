package com.example.cookly.viewmodel

import android.app.Application
import android.util.Patterns
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.cookly.data.AppDatabase
import com.example.cookly.data.User
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class AuthForm { LOGIN, REGISTER }

/** Eventos de un solo uso para navegar tras autenticarse. */
sealed interface AuthEvent {
    data object Authenticated : AuthEvent
}

/**
 * Estado de autenticación. La UI no guarda el texto en variables sueltas.
 */
data class AuthUiState(
    val email: String = "",
    val name: String = "",
    val password: String = "",
    val isPasswordVisible: Boolean = false,
    val emailError: String? = null,
    val nameError: String? = null,
    val passwordError: String? = null,
    val form: AuthForm = AuthForm.LOGIN,
    /** 1 = correo; 2 = nombre + contraseña (solo registro). */
    val registerStep: Int = 1,
    val isValid: Boolean = false,
    val isLoading: Boolean = false
)

class AuthViewModel(application: Application) : AndroidViewModel(application) {

    private val userDao = AppDatabase.getInstance(application).userDao()

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    private val _events = Channel<AuthEvent>(Channel.BUFFERED)
    val events = _events.receiveAsFlow()

    fun setForm(form: AuthForm) {
        _uiState.update { current ->
            current.copy(form = form, registerStep = 1).withValidation()
        }
    }

    fun onEmailChange(value: String) {
        _uiState.update { current ->
            current.copy(
                email = value,
                emailError = null,
                passwordError = null
            ).withValidation()
        }
    }

    fun onNameChange(value: String) {
        _uiState.update { current ->
            current.copy(name = value).withValidation()
        }
    }

    fun onPasswordChange(value: String) {
        _uiState.update { current ->
            current.copy(password = value, passwordError = null).withValidation()
        }
    }

    fun togglePasswordVisibility() {
        _uiState.update { it.copy(isPasswordVisible = !it.isPasswordVisible) }
    }

    fun goBackToEmailStep() {
        _uiState.update { current ->
            current.copy(registerStep = 1, passwordError = null, nameError = null)
                .withValidation()
        }
    }

    /** Paso 1 de registro: valida formato y que el correo no exista en Room. */
    fun continueRegister() {
        val state = _uiState.value
        if (!state.isValid || state.isLoading) return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val existing = userDao.getUserByEmail(state.email.trim())
            if (existing != null) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        emailError = "Este correo ya está registrado",
                        isValid = false
                    )
                }
            } else {
                _uiState.update {
                    it.copy(isLoading = false, registerStep = 2).withValidation()
                }
            }
        }
    }

    /** Paso 2: persiste el usuario y avisa a la UI para ir a Nevera. */
    fun createAccount() {
        val state = _uiState.value
        if (!state.isValid || state.isLoading) return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val existing = userDao.getUserByEmail(state.email.trim())
            if (existing != null) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        registerStep = 1,
                        emailError = "Este correo ya está registrado"
                    ).withValidation()
                }
                return@launch
            }
            userDao.insertUser(
                User(
                    name = state.name.trim(),
                    email = state.email.trim().lowercase(),
                    password = state.password
                )
            )
            _uiState.update { it.copy(isLoading = false) }
            _events.send(AuthEvent.Authenticated)
        }
    }

    /** Login: busca por correo y compara la contraseña en claro (solo local). */
    fun login() {
        val state = _uiState.value
        if (!state.isValid || state.isLoading) return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val user = userDao.getUserByEmail(state.email.trim())
            if (user != null && user.password == state.password) {
                _uiState.update { it.copy(isLoading = false) }
                _events.send(AuthEvent.Authenticated)
            } else {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        passwordError = "Correo o contraseña incorrectos"
                    )
                }
            }
        }
    }

    private fun AuthUiState.withValidation(): AuthUiState {
        val emailValid = isValidEmail(email)
        val emailFormatError = when {
            email.isBlank() -> null
            !emailValid -> "Ingresa un correo válido"
            else -> emailError
        }

        val nameValid = name.isNotBlank()
        val passwordOkForLogin = password.isNotBlank()
        val passwordOkForRegister = password.length >= 6

        val isFormValid = when (form) {
            AuthForm.LOGIN -> emailValid && passwordOkForLogin
            AuthForm.REGISTER -> if (registerStep == 1) {
                emailValid && emailFormatError == null
            } else {
                nameValid && passwordOkForRegister
            }
        }

        val resolvedPasswordError = when {
            passwordError == "Correo o contraseña incorrectos" -> passwordError
            form == AuthForm.REGISTER && registerStep == 2 && password.isNotEmpty() && !passwordOkForRegister ->
                "Mínimo 6 caracteres"
            else -> null
        }

        val resolvedNameError =
            if (form == AuthForm.REGISTER && registerStep == 2 && name.isNotEmpty() && !nameValid) {
                "Ingresa tu nombre"
            } else {
                null
            }

        return copy(
            emailError = emailFormatError,
            nameError = resolvedNameError,
            passwordError = resolvedPasswordError,
            isValid = isFormValid
        )
    }

    private fun isValidEmail(email: String): Boolean {
        return email.isNotBlank() && Patterns.EMAIL_ADDRESS.matcher(email.trim()).matches()
    }
}
