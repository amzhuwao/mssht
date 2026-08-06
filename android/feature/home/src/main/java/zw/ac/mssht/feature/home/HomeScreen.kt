package zw.ac.mssht.feature.home

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Notifications
import androidx.compose.material.icons.outlined.Refresh
import androidx.compose.material.icons.outlined.Logout
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import zw.ac.mssht.core.database.MsshtDatabase
import zw.ac.mssht.core.designsystem.MsshtCard
import zw.ac.mssht.core.designsystem.MsshtColors
import zw.ac.mssht.core.designsystem.MsshtDisplay
import zw.ac.mssht.core.designsystem.SectionTitle
import zw.ac.mssht.core.model.MobileUser
import zw.ac.mssht.feature.sync.SyncRepository

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    user: MobileUser,
    db: MsshtDatabase,
    syncRepository: SyncRepository,
    onOpenNotifications: () -> Unit,
    onLogout: () -> Unit,
) {
    val meta by db.syncMeta().observe().collectAsState(initial = null)
    val invoices by db.invoices().observe().collectAsState(initial = emptyList())
    val classes by db.classes().observe().collectAsState(initial = emptyList())
    val scope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Dashboard") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MsshtColors.Surface,
                    titleContentColor = MsshtColors.PrimaryDark,
                ),
                actions = {
                    IconButton(onClick = {
                        scope.launch { syncRepository.sync() }
                    }) { Icon(Icons.Outlined.Refresh, contentDescription = "Sync") }
                    IconButton(onClick = onOpenNotifications) { Icon(Icons.Outlined.Notifications, contentDescription = "Notifications") }
                    IconButton(onClick = onLogout) { Icon(Icons.Outlined.Logout, contentDescription = "Logout") }
                },
            )
        },
        containerColor = MsshtColors.Background,
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(
                            Brush.linearGradient(listOf(MsshtColors.PrimaryDark, MsshtColors.PrimaryLight)),
                            RoundedCornerShape(10.dp),
                        )
                        .padding(20.dp),
                ) {
                    Text("WELCOME", color = MsshtColors.AccentLight, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    Text(user.displayName.ifBlank { user.email }, fontFamily = MsshtDisplay, color = MsshtColors.OnPrimary, fontSize = 24.sp, fontWeight = FontWeight.SemiBold)
                    Text(user.studentNumber ?: user.role, color = MsshtColors.OnPrimary.copy(alpha = 0.85f))
                }
            }
            item {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                    StatChip("Alerts", meta?.notificationsUnread ?: 0, Modifier.weight(1f))
                    StatChip("Invoices", meta?.openInvoices ?: 0, Modifier.weight(1f))
                    StatChip("Classes", meta?.activeClasses ?: 0, Modifier.weight(1f))
                }
            }
            item { SectionTitle("Your classes") }
            if (classes.isEmpty()) {
                item { MsshtCard { Text("No classes cached yet. Pull to sync when online.", color = MsshtColors.TextMuted) } }
            } else {
                items(classes) { c ->
                    MsshtCard {
                        Text(c.name, fontWeight = FontWeight.SemiBold, color = MsshtColors.Primary)
                        Text(c.joinCode ?: c.status, color = MsshtColors.TextMuted, fontSize = 13.sp)
                    }
                }
            }
            item { SectionTitle("Recent invoices") }
            if (invoices.isEmpty()) {
                item { MsshtCard { Text("No invoices offline yet.", color = MsshtColors.TextMuted) } }
            } else {
                items(invoices.take(8)) { inv ->
                    MsshtCard {
                        Text(inv.invoiceNumber, fontWeight = FontWeight.SemiBold)
                        Text("${inv.status} · due ${inv.dueDate ?: "—"}", color = MsshtColors.TextMuted, fontSize = 13.sp)
                        Text("Balance: ${"%.2f".format(inv.balanceDue)}", color = MsshtColors.Primary)
                    }
                }
            }
            item { Spacer(Modifier = Modifier.height(24.dp)) }
        }
    }
}

@Composable
private fun StatChip(label: String, value: Int, modifier: Modifier = Modifier) {
    MsshtCard(modifier = modifier) {
        Text(value.toString(), fontWeight = FontWeight.Bold, fontSize = 22.sp, color = MsshtColors.Primary)
        Text(label, color = MsshtColors.TextMuted, fontSize = 12.sp)
    }
}
