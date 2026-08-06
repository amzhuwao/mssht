package zw.ac.mssht.app

import android.app.Application
import androidx.work.Configuration
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import zw.ac.mssht.feature.sync.SyncWorker
import zw.ac.mssht.feature.sync.SyncWorkerFactory

class MsshtApp : Application(), Configuration.Provider {
    lateinit var container: AppContainer
        private set

    private val appScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onCreate() {
        super.onCreate()
        container = AppContainer(this)
        appScope.launch { container.sessionStore.lockForBiometricGate() }
        SyncWorker.enqueue(this)
    }

    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder()
            .setWorkerFactory(SyncWorkerFactory { container.syncRepository() })
            .build()
}
