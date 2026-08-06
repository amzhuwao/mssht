package zw.ac.mssht.core.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "notifications")
data class NotificationEntity(
    @PrimaryKey val id: Int,
    val title: String,
    val body: String,
    val isRead: Boolean,
    val createdAt: String?,
)

@Entity(tableName = "invoices")
data class InvoiceEntity(
    @PrimaryKey val id: Int,
    val invoiceNumber: String,
    val status: String,
    val totalAmount: Double,
    val balanceDue: Double,
    val dueDate: String?,
    val updatedAt: String?,
)

@Entity(tableName = "classes")
data class ClassEntity(
    @PrimaryKey val id: Int,
    val name: String,
    val joinCode: String?,
    val status: String,
)

@Entity(tableName = "sync_meta")
data class SyncMetaEntity(
    @PrimaryKey val id: Int = 1,
    val lastServerTime: String?,
    val notificationsUnread: Int = 0,
    val openInvoices: Int = 0,
    val activeClasses: Int = 0,
)
