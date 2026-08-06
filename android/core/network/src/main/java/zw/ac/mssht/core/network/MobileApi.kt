package zw.ac.mssht.core.network

import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query
import zw.ac.mssht.core.model.DeviceRequest
import zw.ac.mssht.core.model.LoginRequest
import zw.ac.mssht.core.model.LoginResponse
import zw.ac.mssht.core.model.NotificationsResponse
import zw.ac.mssht.core.model.OkResponse
import zw.ac.mssht.core.model.SyncResponse

interface MobileApi {
    @POST("login.php")
    suspend fun login(@Body body: LoginRequest): LoginResponse

    @GET("me.php")
    suspend fun me(): LoginResponse

    @POST("logout.php")
    suspend fun logout(): OkResponse

    @POST("device.php")
    suspend fun registerDevice(@Body body: DeviceRequest): OkResponse

    @GET("sync.php")
    suspend fun sync(@Query("since") since: String? = null): SyncResponse

    @GET("notifications.php")
    suspend fun notifications(): NotificationsResponse
}
