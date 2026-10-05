package com.example.cookly.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val LightColorScheme = lightColorScheme(
    primary = CooklyBlack,
    onPrimary = CooklyWhite,
    secondary = CooklyBlack,
    onSecondary = CooklyWhite,
    background = CooklyWhite,
    onBackground = CooklyBlack,
    surface = CooklyWhite,
    onSurface = CooklyBlack,
    surfaceVariant = CooklySocialFill,
    onSurfaceVariant = CooklyMuted,
    outline = CooklyOutline,
    error = CooklyError,
    onError = CooklyWhite,
    tertiary = CooklyGreen,
    onTertiary = CooklyWhite
)

private val DarkColorScheme = darkColorScheme(
    primary = CooklyWhite,
    onPrimary = CooklyBlack,
    secondary = CooklyWhite,
    onSecondary = CooklyBlack,
    background = CooklyBlack,
    onBackground = CooklyWhite,
    surface = CooklyBlack,
    onSurface = CooklyWhite,
    surfaceVariant = CooklyMuted,
    onSurfaceVariant = CooklyOutline,
    outline = CooklyMuted,
    error = CooklyError,
    onError = CooklyWhite,
    tertiary = CooklyGreen,
    onTertiary = CooklyBlack
)

@Composable
fun CooklyTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    // Desactivado por defecto para respetar el prototipo (blanco/negro) y no el wallpaper.
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }

        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
