package zw.ac.mssht.feature.notifications

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import zw.ac.mssht.core.database.MsshtDatabase
import zw.ac.mssht.core.designsystem.MsshtCard
import zw.ac.mssht.core.designsystem.MsshtColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotificationsScreen(db: MsshtDatabase, onBack: () -> Unit) {
    val items by db.notifications().observe().collectAsState(initial = emptyList())
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Notifications") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Outlined.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        containerColor = MsshtColors.Background,
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            if (items.isEmpty()) {
                item { MsshtCard { Text("No notifications cached. Sync when online.", color = MsshtColors.TextMuted) } }
            }
            items(items) { n ->
                MsshtCard {
                    Text(n.title, fontWeight = if (n.isRead) FontWeight.Normal else FontWeight.Bold, color = MsshtColors.PrimaryDark)
                    Text(n.body, color = MsshtColors.TextMuted, fontSize = 13.sp)
                    Text(n.createdAt ?: "", color = MsshtColors.TextMuted, fontSize = 11.sp)
                }
            }
        }
    }
}
