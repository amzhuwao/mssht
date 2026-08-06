package zw.ac.mssht.feature.auth

import android.os.Build
import zw.ac.mssht.core.common.Result
import zw.ac.mssht.core.datastore.SessionStore
import zw.ac.mssht.core.model.LoginRequest
import zw.ac.mssht.core.model.MobileUser
import zw.ac.mssht.core.network.MobileApi

class AuthRepository(
    private val api: MobileApi,
    private val session: SessionStore,
) {
    suspend fun login(identifier: String, password: String, portal: String = "auto"): Result<MobileUser> = try {
        val res = api.login(
            LoginRequest(
                identifier = identifier.trim(),
                password = password,
                deviceName = "${Build.MANUFACTURER} ${Build.MODEL}",
                portal = portal,
            ),
        )
        val token = res.token
        val user = res.user
        if (!res.ok || token.isNullOrBlank() || user == null) {
            Result.Error(res.error ?: "Login failed")
        } else {
            session.saveSession(token, user)
            session.setBiometricEnabled(true)
            Result.Success(user)
        }
    } catch (t: Throwable) {
        Result.Error(t.message ?: "Unable to reach MSSHT server", t)
    }

    suspend fun logout() {
        runCatching { api.logout() }
        session.clear()
    }
}
