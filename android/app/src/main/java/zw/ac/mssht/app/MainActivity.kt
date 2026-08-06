package zw.ac.mssht.app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import zw.ac.mssht.core.designsystem.MsshtTheme
import zw.ac.mssht.core.model.DeviceRequest
import zw.ac.mssht.core.model.MobileUser
import zw.ac.mssht.feature.auth.BiometricUnlock
import zw.ac.mssht.feature.auth.LockScreen
import zw.ac.mssht.feature.auth.LoginScreen
import zw.ac.mssht.feature.home.HomeScreen
import zw.ac.mssht.feature.notifications.NotificationsScreen

class MainActivity : FragmentActivity() {
    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { /* no-op */ }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        maybeRequestNotificationsPermission()
        val app = application as MsshtApp
        setContent {
            MsshtTheme {
                MsshtRoot(app.container, activity = this)
            }
        }
    }

    private fun maybeRequestNotificationsPermission() {
        if (Build.VERSION.SDK_INT >= 33) {
            val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
            if (!granted) permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
        }
    }
}

@Composable
private fun MsshtRoot(container: AppContainer, activity: FragmentActivity) {
    val nav = rememberNavController()
    val scope = rememberCoroutineScope()
    val user by container.sessionStore.userFlow.collectAsState(initial = null)
    val unlocked by container.sessionStore.unlockedFlow.collectAsState(initial = false)
    val biometricEnabled by container.sessionStore.biometricEnabledFlow.collectAsState(initial = false)
    var routeUser by remember { mutableStateOf<MobileUser?>(null) }

    DisposableEffect(activity) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_STOP) {
                scope.launch { container.sessionStore.lockForBiometricGate() }
            }
        }
        activity.lifecycle.addObserver(observer)
        onDispose { activity.lifecycle.removeObserver(observer) }
    }

    LaunchedEffect(user, unlocked) {
        routeUser = if (unlocked) user else null
    }

    LaunchedEffect(user, unlocked) {
        if (user != null && unlocked) {
            registerPushToken(activity.applicationContext, container)
            container.syncRepository().sync()
        }
    }

    when {
        user == null -> {
            LoginScreen(
                authRepository = container.authRepository(),
                onLoggedIn = { loggedIn ->
                    routeUser = loggedIn
                    scope.launch { container.syncRepository().sync() }
                    nav.navigate("home") { popUpTo(0) }
                },
            )
        }
        biometricEnabled && !unlocked -> {
            LockScreen(
                onUnlockClick = {
                    if (BiometricUnlock.canAuthenticate(activity)) {
                        BiometricUnlock.prompt(
                            activity,
                            onSuccess = {
                                scope.launch { container.sessionStore.setUnlocked(true) }
                            },
                        )
                    } else {
                        scope.launch { container.sessionStore.setUnlocked(true) }
                    }
                },
                onUsePassword = {
                    scope.launch { container.authRepository().logout() }
                },
            )
        }
        else -> {
            NavHost(navController = nav, startDestination = "home") {
                composable("home") {
                    HomeScreen(
                        user = routeUser ?: user!!,
                        db = container.database,
                        syncRepository = container.syncRepository(),
                        onOpenNotifications = { nav.navigate("notifications") },
                        onLogout = {
                            scope.launch { container.authRepository().logout() }
                        },
                    )
                }
                composable("notifications") {
                    NotificationsScreen(db = container.database, onBack = { nav.popBackStack() })
                }
            }
        }
    }
}

/**
 * Registers an FCM token when Firebase is configured. Uses the token cached by
 * [zw.ac.mssht.feature.notifications.MsshtFirebaseMessagingService], with an optional
 * live fetch via reflection so the app still builds/runs before google-services.json is added.
 */
private suspend fun registerPushToken(context: Context, container: AppContainer) {
    withContext(Dispatchers.IO) {
        val cached = context.getSharedPreferences("mssht_push", Context.MODE_PRIVATE)
            .getString("fcm_token", null)
        val live = runCatching {
            val messaging = Class.forName("com.google.firebase.messaging.FirebaseMessaging")
            val instance = messaging.getMethod("getInstance").invoke(null)
            val task = messaging.getMethod("getToken").invoke(instance)
            // Block on Tasks.await when available
            val tasks = Class.forName("com.google.android.gms.tasks.Tasks")
            tasks.getMethod("await", Class.forName("com.google.android.gms.tasks.Task"))
                .invoke(null, task) as? String
        }.getOrNull()
        val token = live ?: cached ?: return@withContext
        runCatching {
            container.api().registerDevice(
                DeviceRequest(
                    pushToken = token,
                    deviceName = "${Build.MANUFACTURER} ${Build.MODEL}",
                ),
            )
        }
    }
}
