package com.example.cookly.ui.screens

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.cookly.R
import com.example.cookly.ui.components.AuthOrDivider
import com.example.cookly.ui.components.AuthPrimaryButton
import com.example.cookly.ui.components.AuthTextField
import com.example.cookly.ui.components.SocialLoginButton
import com.example.cookly.ui.theme.CooklyTheme
import com.example.cookly.viewmodel.AuthEvent
import com.example.cookly.viewmodel.AuthForm
import com.example.cookly.viewmodel.AuthViewModel

@Composable
fun RegisterScreen(
    onRegisterSuccess: () -> Unit,
    onNavigateToLogin: () -> Unit,
    onGoogleClick: () -> Unit = {},
    onAppleClick: () -> Unit = {},
    onTermsClick: () -> Unit = {},
    onPrivacyClick: () -> Unit = {},
    viewModel: AuthViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val colors = MaterialTheme.colorScheme

    LaunchedEffect(Unit) {
        viewModel.setForm(AuthForm.REGISTER)
        viewModel.events.collect { event ->
            if (event is AuthEvent.Authenticated) onRegisterSuccess()
        }
    }

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = colors.background
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .systemBarsPadding()
                .imePadding()
                .padding(horizontal = 28.dp)
        ) {
            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Spacer(modifier = Modifier.height(48.dp))

                // Logo visible en ambos pasos.
                Text(
                    text = "COOKLY",
                    style = MaterialTheme.typography.headlineLarge,
                    color = colors.onBackground,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(28.dp))

                AnimatedContent(
                    targetState = uiState.registerStep,
                    transitionSpec = {
                        if (targetState > initialState) {
                            (slideInHorizontally { it } + fadeIn()) togetherWith
                                (slideOutHorizontally { -it } + fadeOut())
                        } else {
                            (slideInHorizontally { -it } + fadeIn()) togetherWith
                                (slideOutHorizontally { it } + fadeOut())
                        }
                    },
                    label = "registerSteps",
                    modifier = Modifier.fillMaxWidth()
                ) { step ->
                    if (step == 1) {
                        RegisterEmailStep(
                            email = uiState.email,
                            emailError = uiState.emailError,
                            isValid = uiState.isValid,
                            isLoading = uiState.isLoading,
                            onEmailChange = viewModel::onEmailChange,
                            onContinue = viewModel::continueRegister,
                            onGoogleClick = onGoogleClick,
                            onAppleClick = onAppleClick
                        )
                    } else {
                        RegisterDetailsStep(
                            name = uiState.name,
                            nameError = uiState.nameError,
                            password = uiState.password,
                            passwordError = uiState.passwordError,
                            isPasswordVisible = uiState.isPasswordVisible,
                            isValid = uiState.isValid,
                            isLoading = uiState.isLoading,
                            onNameChange = viewModel::onNameChange,
                            onPasswordChange = viewModel::onPasswordChange,
                            onTogglePasswordVisibility = viewModel::togglePasswordVisibility,
                            onCreateAccount = viewModel::createAccount,
                            onBack = viewModel::goBackToEmailStep
                        )
                    }
                }
            }

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 24.dp, top = 12.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                LoginPrompt(onNavigateToLogin = onNavigateToLogin)
                LegalDisclaimer(
                    onTermsClick = onTermsClick,
                    onPrivacyClick = onPrivacyClick
                )
            }
        }
    }
}

@Composable
private fun RegisterEmailStep(
    email: String,
    emailError: String?,
    isValid: Boolean,
    isLoading: Boolean,
    onEmailChange: (String) -> Unit,
    onContinue: () -> Unit,
    onGoogleClick: () -> Unit,
    onAppleClick: () -> Unit
) {
    val colors = MaterialTheme.colorScheme
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Crea una cuenta",
            style = MaterialTheme.typography.titleLarge,
            color = colors.onBackground,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "Ingresa tu correo electrónico para registrarte en esta aplicación",
            style = MaterialTheme.typography.bodyMedium,
            color = colors.onSurfaceVariant,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(24.dp))

        AuthTextField(
            value = email,
            onValueChange = onEmailChange,
            placeholder = "correoelectrónico@dominio.com",
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Email,
                imeAction = ImeAction.Done
            ),
            isError = emailError != null,
            supportingText = emailError
        )

        Spacer(modifier = Modifier.height(16.dp))

        AuthPrimaryButton(
            text = "Continuar",
            enabled = isValid && !isLoading,
            onClick = onContinue
        )

        Spacer(modifier = Modifier.height(20.dp))
        AuthOrDivider()
        Spacer(modifier = Modifier.height(20.dp))

        SocialLoginButton(
            text = "Continuar con Google",
            iconRes = R.drawable.ic_google,
            onClick = onGoogleClick
        )
        Spacer(modifier = Modifier.height(12.dp))
        SocialLoginButton(
            text = "Continuar con Apple",
            iconRes = R.drawable.ic_apple,
            onClick = onAppleClick
        )
    }
}

@Composable
private fun RegisterDetailsStep(
    name: String,
    nameError: String?,
    password: String,
    passwordError: String?,
    isPasswordVisible: Boolean,
    isValid: Boolean,
    isLoading: Boolean,
    onNameChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onTogglePasswordVisibility: () -> Unit,
    onCreateAccount: () -> Unit,
    onBack: () -> Unit
) {
    val colors = MaterialTheme.colorScheme
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Crea una cuenta",
            style = MaterialTheme.typography.titleLarge,
            color = colors.onBackground,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "Ingresa tu nombre y una contraseña de al menos 6 caracteres",
            style = MaterialTheme.typography.bodyMedium,
            color = colors.onSurfaceVariant,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(24.dp))

        AuthTextField(
            value = name,
            onValueChange = onNameChange,
            placeholder = "Nombre",
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Text,
                imeAction = ImeAction.Next
            ),
            isError = nameError != null,
            supportingText = nameError
        )

        Spacer(modifier = Modifier.height(12.dp))

        AuthTextField(
            value = password,
            onValueChange = onPasswordChange,
            placeholder = "Contraseña",
            isPassword = true,
            isPasswordVisible = isPasswordVisible,
            onTogglePasswordVisibility = onTogglePasswordVisibility,
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Password,
                imeAction = ImeAction.Done
            ),
            isError = passwordError != null,
            supportingText = passwordError
        )

        Spacer(modifier = Modifier.height(16.dp))

        AuthPrimaryButton(
            text = "Crear cuenta",
            enabled = isValid && !isLoading,
            onClick = onCreateAccount
        )

        TextButton(onClick = onBack) {
            Text(
                text = "Atrás",
                color = colors.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun LoginPrompt(onNavigateToLogin: () -> Unit) {
    val colors = MaterialTheme.colorScheme
    val annotated = buildAnnotatedString {
        withStyle(SpanStyle(color = colors.onSurfaceVariant)) {
            append("¿Ya tienes cuenta? ")
        }
        withStyle(
            SpanStyle(
                color = colors.onBackground,
                fontWeight = FontWeight.Bold
            )
        ) {
            append("Inicia sesión")
        }
    }
    Text(
        text = annotated,
        style = MaterialTheme.typography.bodyMedium,
        textAlign = TextAlign.Center,
        modifier = Modifier.clickable(onClick = onNavigateToLogin)
    )
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun RegisterScreenPreview() {
    CooklyTheme {
        RegisterScreen(
            onRegisterSuccess = {},
            onNavigateToLogin = {}
        )
    }
}
