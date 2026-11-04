package com.example.cookly.viewmodel

import android.app.Activity
import android.app.Application
import android.util.Patterns
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.NoCredentialException
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.cookly.R
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthException
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.auth.userProfileChangeRequest
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlin.coroutines.cancellation.CancellationException

enum class AuthForm { LOGIN, REGISTER }

sealed interface AuthEvent {
    data object Authenticated : AuthEvent
}

data class AuthUiState(
    val email: String = "",
    val name: String = "",
    val password: String = "",
    val isPasswordVisible: Boolean = false,
    val emailError: String? = null,
    val nameError: String? = null,
    val passwordError: String? = null,
    val form: AuthForm = AuthForm.LOGIN,
    val registerStep: Int = 1,
    val isValid: Boolean = false,
    val isLoading: Boolean = false,
    val snackbarMessage: String? = null
)

class AuthViewModel(application: Application) : AndroidViewModel(application) {

    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
    private val credentialManager = CredentialManager.create(application)
    private val webClientId: String =
        application.getString(R.string.google_web_client_id)

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

    fun clearSnackbar() {
        _uiState.update { it.copy(snackbarMessage = null) }
    }

    /** Paso 1: solo valida el formato; Firebase confirma duplicados al crear la cuenta. */
    fun continueRegister() {
        val state = _uiState.value
        if (!state.isValid || state.isLoading) return
        _uiState.update { it.copy(registerStep = 2).withValidation() }
    }

    /** Registro con correo/contraseña y displayName del paso 2. */
    fun createAccount() {
        val state = _uiState.value
        if (!state.isValid || state.isLoading) return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                auth.createUserWithEmailAndPassword(
                    state.email.trim(),
                    state.password
                ).await()
                val profile = userProfileChangeRequest {
                    displayName = state.name.trim()
                }
                auth.currentUser?.updateProfile(profile)?.await()
                _uiState.update { it.copy(isLoading = false) }
                _events.send(AuthEvent.Authenticated)
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                applyFirebaseError(e)
            }
        }
    }

    fun login() {
        val state = _uiState.value
        if (!state.isValid || state.isLoading) return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                auth.signInWithEmailAndPassword(
                    state.email.trim(),
                    state.password
                ).await()
                _uiState.update { it.copy(isLoading = false) }
                _events.send(AuthEvent.Authenticated)
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                applyFirebaseError(e)
            }
        }
    }

    /**
     * Google Sign-In moderno: Credential Manager pide el idToken
     * y Firebase lo canjea por una sesión.
     */
    fun signInWithGoogle(activity: Activity) {
        if (_uiState.value.isLoading) return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                val idToken = requestGoogleIdToken(activity)
                    ?: throw IllegalStateException("No se recibió el token de Google")
                val credential = GoogleAuthProvider.getCredential(idToken, null)
                auth.signInWithCredential(credential).await()
                _uiState.update { it.copy(isLoading = false) }
                _events.send(AuthEvent.Authenticated)
            } catch (_: GetCredentialCancellationException) {
                _uiState.update { it.copy(isLoading = false) }
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        snackbarMessage = e.message?.takeIf { msg -> msg.isNotBlank() }
                            ?: "No se pudo iniciar sesión con Google"
                    )
                }
            }
        }
    }

    fun sendPasswordReset(email: String) {
        val trimmed = email.trim()
        if (!isValidEmail(trimmed)) {
            _uiState.update { it.copy(emailError = "Ingresa un correo válido") }
            return
        }
        viewModelScope.launch {
            try {
                auth.sendPasswordResetEmail(trimmed).await()
            } catch (_: Exception) {
                // Mismo mensaje genérico para no revelar si el correo existe.
            }
            _uiState.update {
                it.copy(
                    snackbarMessage = "Si el correo existe, te enviamos un enlace para restablecer tu contraseña."
                )
            }
        }
    }

    /** Cierra Firebase y limpia el estado de Credential Manager (Google). */
    fun signOut(onDone: () -> Unit) {
        viewModelScope.launch {
            auth.signOut()
            try {
                credentialManager.clearCredentialState(ClearCredentialStateRequest())
            } catch (_: Exception) {
                // Si no hubo sesión de Google, esto puede fallar sin impacto.
            }
            onDone()
        }
    }

    private suspend fun requestGoogleIdToken(activity: Activity): String? {
        val silentOption = GetGoogleIdOption.Builder()
            .setFilterByAuthorizedAccounts(false)
            .setServerClientId(webClientId)
            .setAutoSelectEnabled(false)
            .build()
        val silentRequest = GetCredentialRequest.Builder()
            .addCredentialOption(silentOption)
            .build()
        val result = try {
            credentialManager.getCredential(activity, silentRequest)
        } catch (_: NoCredentialException) {
            // Abre el selector explícito "Sign in with Google".
            val explicitOption = GetSignInWithGoogleOption.Builder(webClientId).build()
            val explicitRequest = GetCredentialRequest.Builder()
                .addCredentialOption(explicitOption)
                .build()
            credentialManager.getCredential(activity, explicitRequest)
        }
        val credential = result.credential
        if (credential is CustomCredential &&
            credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
        ) {
            return GoogleIdTokenCredential.createFrom(credential.data).idToken
        }
        return null
    }

    private fun applyFirebaseError(error: Exception) {
        val code = (error as? FirebaseAuthException)?.errorCode.orEmpty()
        val (emailError, passwordError, step) = when (code) {
            "ERROR_EMAIL_ALREADY_IN_USE" ->
                Triple("Este correo ya está registrado", null, 1)
            "ERROR_INVALID_EMAIL" ->
                Triple("Ingresa un correo válido", null, _uiState.value.registerStep)
            "ERROR_WEAK_PASSWORD" ->
                Triple(null, "La contraseña es demasiado débil", 2)
            "ERROR_WRONG_PASSWORD",
            "ERROR_USER_NOT_FOUND",
            "ERROR_INVALID_CREDENTIAL",
            "ERROR_INVALID_LOGIN_CREDENTIALS" ->
                Triple(null, "Correo o contraseña incorrectos", _uiState.value.registerStep)
            "ERROR_USER_DISABLED" ->
                Triple(null, "Esta cuenta está deshabilitada", _uiState.value.registerStep)
            "ERROR_NETWORK_REQUEST_FAILED" ->
                Triple(null, "Sin conexión. Intenta de nuevo", _uiState.value.registerStep)
            else -> Triple(
                null,
                error.localizedMessage ?: "No se pudo completar la autenticación",
                _uiState.value.registerStep
            )
        }
        _uiState.update {
            it.copy(
                isLoading = false,
                emailError = emailError,
                passwordError = passwordError,
                registerStep = step,
                isValid = false
            )
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
            passwordError != null && form == AuthForm.LOGIN -> passwordError
            form == AuthForm.REGISTER && registerStep == 2 && password.isNotEmpty() && !passwordOkForRegister ->
                "Mínimo 6 caracteres"
            form == AuthForm.REGISTER -> passwordError
            else -> null
        }

        val resolvedNameError =
            if (form == AuthForm.REGISTER && registerStep == 2 && name.isNotEmpty() && !nameValid) {
                "Ingresa tu nombre"
            } else {
                nameError
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
