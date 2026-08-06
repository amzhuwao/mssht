package zw.ac.mssht.feature.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import zw.ac.mssht.core.designsystem.BrandMark
import zw.ac.mssht.core.designsystem.MsshtColors
import zw.ac.mssht.core.designsystem.MsshtDisplay
import zw.ac.mssht.core.designsystem.PrimaryButton

@Composable
fun LockScreen(onUnlockClick: () -> Unit, onUsePassword: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.linearGradient(listOf(MsshtColors.PrimaryDark, MsshtColors.Primary)))
            .padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        BrandMark(large = true)
        Text("MSSHT Locked", fontFamily = MsshtDisplay, color = MsshtColors.OnPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 16.dp))
        Text("Use biometrics to continue", color = MsshtColors.AccentLight, modifier = Modifier.padding(bottom = 24.dp))
        PrimaryButton("Unlock with biometrics", onClick = onUnlockClick)
        PrimaryButton("Sign in again", onClick = onUsePassword, modifier = Modifier.padding(top = 12.dp))
    }
}
