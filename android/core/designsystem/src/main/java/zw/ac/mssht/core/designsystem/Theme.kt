package zw.ac.mssht.core.designsystem

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp

private val LightColors = lightColorScheme(
    primary = MsshtColors.Primary,
    onPrimary = MsshtColors.OnPrimary,
    primaryContainer = MsshtColors.PrimaryLight,
    onPrimaryContainer = MsshtColors.OnPrimary,
    secondary = MsshtColors.Accent,
    onSecondary = MsshtColors.OnAccent,
    secondaryContainer = MsshtColors.AccentLight,
    onSecondaryContainer = MsshtColors.PrimaryDark,
    background = MsshtColors.Background,
    onBackground = MsshtColors.Text,
    surface = MsshtColors.Surface,
    onSurface = MsshtColors.Text,
    surfaceVariant = MsshtColors.Background,
    onSurfaceVariant = MsshtColors.TextMuted,
    outline = MsshtColors.Border,
    error = MsshtColors.Danger,
)

private val MsshtShapes = Shapes(
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(10.dp),
    large = RoundedCornerShape(16.dp),
)

@Composable
fun MsshtTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColors,
        typography = MsshtTypography,
        shapes = MsshtShapes,
        content = content,
    )
}
