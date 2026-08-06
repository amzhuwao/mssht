package zw.ac.mssht.core.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class MobileUser(
    val id: Int,
    val email: String,
    val role: String,
    @SerialName("first_name") val firstName: String = "",
    @SerialName("last_name") val lastName: String = "",
    @SerialName("display_name") val displayName: String = "",
    @SerialName("student_id") val studentId: Int? = null,
    @SerialName("student_number") val studentNumber: String? = null,
    @SerialName("must_change_password") val mustChangePassword: Boolean = false,
    val portal: String = "student",
)

@Serializable
data class LoginRequest(
    val identifier: String,
    val password: String,
    @SerialName("device_name") val deviceName: String = "Android",
    val portal: String = "auto",
)

@Serializable
data class LoginResponse(
    val ok: Boolean,
    val token: String? = null,
    @SerialName("expires_at") val expiresAt: String? = null,
    val user: MobileUser? = null,
    val error: String? = null,
    @SerialName("server_time") val serverTime: String? = null,
)

@Serializable
data class SyncStats(
    @SerialName("notifications_unread") val notificationsUnread: Int = 0,
    @SerialName("open_invoices") val openInvoices: Int = 0,
    @SerialName("active_classes") val activeClasses: Int = 0,
)

@Serializable
data class NotificationItem(
    val id: Int,
    val title: String,
    val body: String = "",
    @SerialName("is_read") val isRead: Boolean = false,
    @SerialName("created_at") val createdAt: String? = null,
)

@Serializable
data class InvoiceItem(
    val id: Int,
    @SerialName("invoice_number") val invoiceNumber: String,
    val status: String,
    @SerialName("total_amount") val totalAmount: Double = 0.0,
    @SerialName("balance_due") val balanceDue: Double = 0.0,
    @SerialName("due_date") val dueDate: String? = null,
    @SerialName("updated_at") val updatedAt: String? = null,
)

@Serializable
data class ClassItem(
    val id: Int,
    val name: String,
    @SerialName("join_code") val joinCode: String? = null,
    val status: String = "active",
)

@Serializable
data class SyncResponse(
    val ok: Boolean,
    @SerialName("server_time") val serverTime: String? = null,
    val user: MobileUser? = null,
    val stats: SyncStats = SyncStats(),
    val notifications: List<NotificationItem> = emptyList(),
    val invoices: List<InvoiceItem> = emptyList(),
    val classes: List<ClassItem> = emptyList(),
    val error: String? = null,
)

@Serializable
data class DeviceRequest(
    @SerialName("push_token") val pushToken: String,
    @SerialName("device_name") val deviceName: String = "Android",
)

@Serializable
data class OkResponse(val ok: Boolean, val error: String? = null)

@Serializable
data class NotificationsResponse(
    val ok: Boolean,
    val notifications: List<NotificationItem> = emptyList(),
    val error: String? = null,
)
