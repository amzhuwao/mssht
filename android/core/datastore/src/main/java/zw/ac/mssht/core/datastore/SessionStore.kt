package zw.ac.mssht.core.datastore

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import zw.ac.mssht.core.model.MobileUser

private val Context.dataStore by preferencesDataStore("mssht_prefs")

class SessionStore(private val context: Context) {
    private val json = Json { ignoreUnknownKeys = true }
    private val masterKey = MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()
    private val secure = EncryptedSharedPreferences.create(
        context,
        "mssht_secure_session",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
    )

    private val biometricEnabled = booleanPreferencesKey("biometric_enabled")
    private val unlocked = booleanPreferencesKey("session_unlocked")
    private val userJson = stringPreferencesKey("user_json")
    private val lastSync = stringPreferencesKey("last_sync_at")
    private val baseUrl = stringPreferencesKey("base_url")

    fun token(): String? = secure.getString(KEY_TOKEN, null)

    suspend fun saveSession(token: String, user: MobileUser) {
        secure.edit().putString(KEY_TOKEN, token).apply()
        context.dataStore.edit {
            it[userJson] = json.encodeToString(user)
            it[unlocked] = true
        }
    }

    /** Call on cold start so biometric gate is required again. */
    suspend fun lockForBiometricGate() {
        context.dataStore.edit { prefs ->
            if (prefs[biometricEnabled] == true && !secure.getString(KEY_TOKEN, null).isNullOrBlank()) {
                prefs[unlocked] = false
            }
        }
    }

    suspend fun clear() {
        secure.edit().clear().apply()
        context.dataStore.edit { it.clear() }
    }

    val userFlow: Flow<MobileUser?> = context.dataStore.data.map { prefs ->
        prefs[userJson]?.let { runCatching { json.decodeFromString<MobileUser>(it) }.getOrNull() }
    }

    val biometricEnabledFlow: Flow<Boolean> = context.dataStore.data.map { it[biometricEnabled] ?: false }
    val unlockedFlow: Flow<Boolean> = context.dataStore.data.map { it[unlocked] ?: false }
    val lastSyncFlow: Flow<String?> = context.dataStore.data.map { it[lastSync] }
    val baseUrlFlow: Flow<String?> = context.dataStore.data.map { it[baseUrl] }

    suspend fun setBiometricEnabled(enabled: Boolean) {
        context.dataStore.edit { it[biometricEnabled] = enabled }
    }

    suspend fun setUnlocked(value: Boolean) {
        context.dataStore.edit { it[unlocked] = value }
    }

    suspend fun setLastSync(iso: String) {
        context.dataStore.edit { it[lastSync] = iso }
    }

    suspend fun setBaseUrl(url: String) {
        context.dataStore.edit { it[baseUrl] = url }
    }

    companion object {
        private const val KEY_TOKEN = "auth_token"
    }
}
