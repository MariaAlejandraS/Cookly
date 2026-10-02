package com.example.cookly.ui.screens

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
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextLinkStyles
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
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
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit,
    onForgotPassword: () -> Unit = {},
    onGoogleClick: () -> Unit = {},
    onAppleClick: () -> Unit = {},
    onTermsClick: () -> Unit = {},
    onPrivacyClick: () -> Unit = {},
    viewModel: AuthViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val colors = MaterialTheme.colorScheme

    LaunchedEffect(Unit) {
        viewModel.setForm(AuthForm.LOGIN)
        viewModel.events.collect { event ->
            if (event is AuthEvent.Authenticated) onLoginSuccess()
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

                Text(
                    text = "COOKLY",
                    style = MaterialTheme.typography.headlineLarge,
                    color = colors.onBackground,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(28.dp))

                Text(
                    text = "Inicia sesión",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.onBackground,
                    textAlign = TextAlign.Center
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Ingresa tu correo y contraseña para continuar",
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.onSurfaceVariant,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(24.dp))

                AuthTextField(
                    value = uiState.email,
                    onValueChange = viewModel::onEmailChange,
                    placeholder = "correoelectrónico@dominio.com",
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Email,
                        imeAction = ImeAction.Next
                    ),
                    isError = uiState.emailError != null,
                    supportingText = uiState.emailError
                )

                Spacer(modifier = Modifier.height(12.dp))

                AuthTextField(
                    value = uiState.password,
                    onValueChange = viewModel::onPasswordChange,
                    placeholder = "Contraseña",
                    isPassword = true,
                    isPasswordVisible = uiState.isPasswordVisible,
                    onTogglePasswordVisibility = viewModel::togglePasswordVisibility,
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Password,
                        imeAction = ImeAction.Done
                    ),
                    isError = uiState.passwordError != null,
                    supportingText = uiState.passwordError
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = "¿Olvidaste tu contraseña?",
                    style = MaterialTheme.typography.bodySmall,
                    color = colors.onSurface,
                    modifier = Modifier
                        .align(Alignment.End)
                        .clickable(onClick = onForgotPassword)
                        .padding(vertical = 4.dp)
                )

                Spacer(modifier = Modifier.height(16.dp))

                AuthPrimaryButton(
                    text = "Iniciar sesión",
                    enabled = uiState.isValid && !uiState.isLoading,
                    onClick = viewModel::login
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

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 24.dp, top = 12.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                RegisterPrompt(onNavigateToRegister = onNavigateToRegister)
                LegalDisclaimer(
                    onTermsClick = onTermsClick,
                    onPrivacyClick = onPrivacyClick
                )
            }
        }
    }
}

@Composable
fun RegisterPrompt(onNavigateToRegister: () -> Unit) {
    val colors = MaterialTheme.colorScheme
    val annotated = buildAnnotatedString {
        withStyle(SpanStyle(color = colors.onSurfaceVariant)) {
            append("¿No tienes cuenta? ")
        }
        withStyle(
            SpanStyle(
                color = colors.onBackground,
                fontWeight = FontWeight.Bold
            )
        ) {
            append("Regístrate")
        }
    }
    Text(
        text = annotated,
        style = MaterialTheme.typography.bodyMedium,
        textAlign = TextAlign.Center,
        modifier = Modifier.clickable(onClick = onNavigateToRegister)
    )
}

@Composable
fun LegalDisclaimer(
    onTermsClick: () -> Unit,
    onPrivacyClick: () -> Unit
) {
    val colors = MaterialTheme.colorScheme
    val linkStyle = TextLinkStyles(
        style = SpanStyle(
            color = colors.onBackground,
            fontWeight = FontWeight.Medium,
            textDecoration = TextDecoration.Underline
        )
    )
    val annotated = buildAnnotatedString {
        withStyle(SpanStyle(color = colors.onSurfaceVariant)) {
            append("Al hacer clic en continuar, aceptas nuestros ")
        }
        pushLink(
            LinkAnnotation.Clickable(
                tag = "terms",
                styles = linkStyle,
                linkInteractionListener = { onTermsClick() }
            )
        )
        append("Términos de servicio")
        pop()
        withStyle(SpanStyle(color = colors.onSurfaceVariant)) {
            append(" y ")
        }
        pushLink(
            LinkAnnotation.Clickable(
                tag = "privacy",
                styles = linkStyle,
                linkInteractionListener = { onPrivacyClick() }
            )
        )
        append("Política de privacidad")
        pop()
    }
    Text(
        text = annotated,
        style = MaterialTheme.typography.bodySmall,
        textAlign = TextAlign.Center
    )
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun LoginScreenPreview() {
    CooklyTheme {
        LoginScreen(
            onLoginSuccess = {},
            onNavigateToRegister = {}
        )
    }
}
