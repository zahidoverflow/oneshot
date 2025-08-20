package com.android.oneshot.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView

// Cyberpunk Hacker Theme
private val HackerColorScheme = darkColorScheme(
    primary = NeonGreen,
    onPrimary = HackerBlack,
    secondary = NeonBlue,
    onSecondary = HackerBlack,
    tertiary = NeonPink,
    onTertiary = HackerBlack,
    background = HackerBlack,
    onBackground = HackerGreen,
    surface = TerminalBlack,
    onSurface = HackerGreen,
    surfaceVariant = CardDark,
    onSurfaceVariant = ConsoleGray,
    error = ErrorRed,
    onError = HackerBlack,
    outline = MatrixGreen,
    outlineVariant = DarkGreen
)

// Legacy schemes for compatibility
private val DarkColorScheme = darkColorScheme(
    primary = Purple80,
    secondary = PurpleGrey80,
    tertiary = Pink80
)

private val LightColorScheme = lightColorScheme(
    primary = Purple40,
    secondary = PurpleGrey40,
    tertiary = Pink40
)

@Composable
fun OneshotTheme(
    darkTheme: Boolean = true, // Force dark theme for hacker aesthetic
    dynamicColor: Boolean = false, // Disable dynamic colors for consistent hacker theme
    content: @Composable () -> Unit
) {
    val colorScheme = HackerColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
}
}