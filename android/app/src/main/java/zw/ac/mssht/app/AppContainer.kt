package zw.ac.mssht.app

import android.content.Context
import zw.ac.mssht.core.database.MsshtDatabase
import zw.ac.mssht.core.datastore.SessionStore
import zw.ac.mssht.core.network.MobileApi
import zw.ac.mssht.core.network.createMobileApi
import zw.ac.mssht.feature.auth.AuthRepository
import zw.ac.mssht.feature.sync.SyncRepository

class AppContainer(context: Context) {
    val sessionStore = SessionStore(context)
    val database = MsshtDatabase.create(context)

    @Volatile private var cachedApi: MobileApi? = null

    fun api(baseUrl: String = BuildConfig.API_BASE_URL): MobileApi {
        val existing = cachedApi
        if (existing != null) return existing
        return createMobileApi(baseUrl) { sessionStore.token() }.also { cachedApi = it }
    }

    fun authRepository(baseUrl: String = BuildConfig.API_BASE_URL) =
        AuthRepository(api(baseUrl), sessionStore)

    fun syncRepository(baseUrl: String = BuildConfig.API_BASE_URL) =
        SyncRepository(api(baseUrl), database, sessionStore)
}
