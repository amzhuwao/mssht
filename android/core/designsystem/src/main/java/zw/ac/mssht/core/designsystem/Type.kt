package zw.ac.mssht.core.designsystem

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

/**
 * Typography aligned with web guidelines:
 * - Body / UI: DM Sans (sans) — use default sans closely matching until fonts are bundled
 * - Display / titles: Playfair Display (serif)
 *
 * Bundle DM Sans + Playfair Display under res/font for production parity.
 */
val MsshtSans = FontFamily.SansSerif
val MsshtDisplay = FontFamily.Serif

val MsshtTypography = Typography(
    displayLarge = TextStyle(fontFamily = MsshtDisplay, fontWeight = FontWeight.Bold, fontSize = 32.sp, color = MsshtColors.PrimaryDark),
    headlineMedium = TextStyle(fontFamily = MsshtDisplay, fontWeight = FontWeight.SemiBold, fontSize = 24.sp, color = MsshtColors.PrimaryDark),
    titleLarge = TextStyle(fontFamily = MsshtSans, fontWeight = FontWeight.SemiBold, fontSize = 20.sp, color = MsshtColors.Text),
    titleMedium = TextStyle(fontFamily = MsshtSans, fontWeight = FontWeight.SemiBold, fontSize = 16.sp, color = MsshtColors.Text),
    bodyLarge = TextStyle(fontFamily = MsshtSans, fontWeight = FontWeight.Normal, fontSize = 16.sp, color = MsshtColors.Text),
    bodyMedium = TextStyle(fontFamily = MsshtSans, fontWeight = FontWeight.Normal, fontSize = 14.sp, color = MsshtColors.Text),
    labelLarge = TextStyle(fontFamily = MsshtSans, fontWeight = FontWeight.SemiBold, fontSize = 14.sp),
    labelMedium = TextStyle(fontFamily = MsshtSans, fontWeight = FontWeight.Medium, fontSize = 12.sp, color = MsshtColors.TextMuted),
)
