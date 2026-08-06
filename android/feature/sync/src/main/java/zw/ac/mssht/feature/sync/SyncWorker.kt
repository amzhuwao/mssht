package zw.ac.mssht.feature.sync

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import zw.ac.mssht.core.common.Result
import java.util.concurrent.TimeUnit

class SyncWorker(
    appContext: Context,
    params: WorkerParameters,
    private val repository: SyncRepository,
) : CoroutineWorker(appContext, params) {
    override suspend fun doWork(): Result {
        return when (val r = repository.sync()) {
            is zw.ac.mssht.core.common.Result.Success -> Result.success()
            else -> Result.retry()
        }
    }

    companion object {
        const val UNIQUE = "mssht_periodic_sync"

        fun enqueue(context: Context) {
            val req = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES).build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                UNIQUE,
                ExistingPeriodicWorkPolicy.KEEP,
                req,
            )
        }
    }
}
