package zw.ac.mssht.feature.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import zw.ac.mssht.core.common.Result
import zw.ac.mssht.core.designsystem.BrandMark
import zw.ac.mssht.core.designsystem.MsshtColors
import zw.ac.mssht.core.designsystem.MsshtDisplay
import zw.ac.mssht.core.designsystem.PrimaryButton
import zw.ac.mssht.core.model.MobileUser

@Composable
fun LoginScreen(
    authRepository: AuthRepository,
    onLoggedIn: (MobileUser) -> Unit,
) {
    var identifier by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var error by remember { mutableStateOf<String?>(null) }
    var loading by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.linearGradient(
                    listOf(MsshtColors.PrimaryDark, MsshtColors.Primary, MsshtColors.PrimaryLight),
                ),
            )
            .padding(24.dp),
        contentAlignment = Alignment.Center,
    ) {
        Card(
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = MsshtColors.Surface),
            elevation = CardDefaults.cardElevation(8.dp),
            modifier = Modifier.fillMaxWidth(),
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                BrandMark(large = true)
                Text("Student Portal", fontFamily = MsshtDisplay, fontSize = 24.sp, fontWeight = FontWeight.SemiBold, color = MsshtColors.Primary)
                Text("Manica Skyview SHT", color = MsshtColors.TextMuted, fontSize = 14.sp)
                Spacer(Modifier.height(8.dp))
                OutlinedTextField(
                    value = identifier,
                    onValueChange = { identifier = it },
                    label = { Text("Student ID or Email") },
                    placeholder = { Text("e.g. M20260065") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                )
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Password") },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    modifier = Modifier.fillMaxWidth(),
                )
                if (error != null) {
                    Text(error!!, color = MsshtColors.Danger, fontSize = 13.sp)
                }
                if (loading) {
                    CircularProgressIndicator(color = MsshtColors.Primary)
                } else {
                    PrimaryButton("Sign In to Portal", onClick = {
                        scope.launch {
                            loading = true
                            error = null
                            when (val r = authRepository.login(identifier, password)) {
                                is Result.Success -> onLoggedIn(r.data)
                                is Result.Error -> error = r.message
                                Result.Loading -> Unit
                            }
                            loading = false
                        }
                    })
                }
                Text(
                    "Staff may sign in with work email. Biometric unlock is enabled after the first successful login.",
                    color = MsshtColors.TextMuted,
                    fontSize = 12.sp,
                )
            }
        }
    }
}
