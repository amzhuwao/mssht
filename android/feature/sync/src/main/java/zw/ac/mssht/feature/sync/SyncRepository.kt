package zw.ac.mssht.feature.sync

import zw.ac.mssht.core.common.Result
import zw.ac.mssht.core.database.ClassEntity
import zw.ac.mssht.core.database.InvoiceEntity
import zw.ac.mssht.core.database.MsshtDatabase
import zw.ac.mssht.core.database.NotificationEntity
import zw.ac.mssht.core.database.SyncMetaEntity
import zw.ac.mssht.core.datastore.SessionStore
import zw.ac.mssht.core.network.MobileApi

class SyncRepository(
    private val api: MobileApi,
    private val db: MsshtDatabase,
    private val session: SessionStore,
) {
    suspend fun sync(since: String? = null): Result<Unit> = try {
        val response = api.sync(since)
        if (!response.ok) {
            Result.Error(response.error ?: "Sync failed")
        } else {
            db.notifications().clear()
            db.notifications().upsertAll(
                response.notifications.map {
                    NotificationEntity(it.id, it.title, it.body, it.isRead, it.createdAt)
                },
            )
            db.invoices().clear()
            db.invoices().upsertAll(
                response.invoices.map {
                    InvoiceEntity(
                        it.id, it.invoiceNumber, it.status,
                        it.totalAmount, it.balanceDue, it.dueDate, it.updatedAt,
                    )
                },
            )
            db.classes().clear()
            db.classes().upsertAll(
                response.classes.map { ClassEntity(it.id, it.name, it.joinCode, it.status) },
            )
            db.syncMeta().upsert(
                SyncMetaEntity(
                    lastServerTime = response.serverTime,
                    notificationsUnread = response.stats.notificationsUnread,
                    openInvoices = response.stats.openInvoices,
                    activeClasses = response.stats.activeClasses,
                ),
            )
            response.serverTime?.let { session.setLastSync(it) }
            Result.Success(Unit)
        }
    } catch (t: Throwable) {
        Result.Error(t.message ?: "Network error", t)
    }
}
