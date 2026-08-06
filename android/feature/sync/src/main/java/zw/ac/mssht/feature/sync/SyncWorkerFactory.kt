package zw.ac.mssht.feature.sync

import android.content.Context
import androidx.work.ListenableWorker
import androidx.work.WorkerFactory
import androidx.work.WorkerParameters

class SyncWorkerFactory(
    private val repositoryProvider: () -> SyncRepository,
) : WorkerFactory() {
    override fun createWorker(
        appContext: Context,
        workerClassName: String,
        workerParameters: WorkerParameters,
    ): ListenableWorker? {
        if (workerClassName != SyncWorker::class.java.name) return null
        return SyncWorker(appContext, workerParameters, repositoryProvider())
    }
}
