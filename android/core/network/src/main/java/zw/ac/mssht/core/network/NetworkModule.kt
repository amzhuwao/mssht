package zw.ac.mssht.core.network

import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import zw.ac.mssht.core.common.AppConfig
import java.util.concurrent.TimeUnit

fun createJson(): Json = Json {
    ignoreUnknownKeys = true
    isLenient = true
    explicitNulls = false
}

fun createOkHttp(tokenProvider: () -> String?): OkHttpClient {
    val logging = HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BASIC }
    val auth = Interceptor { chain ->
        val token = tokenProvider()
        val req = if (!token.isNullOrBlank()) {
            chain.request().newBuilder().header("Authorization", "Bearer $token").build()
        } else chain.request()
        chain.proceed(req)
    }
    return OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .addInterceptor(auth)
        .addInterceptor(logging)
        .build()
}

fun createMobileApi(baseUrl: String, tokenProvider: () -> String?): MobileApi {
    val root = if (baseUrl.endsWith("/")) baseUrl else "$baseUrl/"
    val apiBase = root + AppConfig.API_PREFIX
    val json = createJson()
    return Retrofit.Builder()
        .baseUrl(apiBase)
        .client(createOkHttp(tokenProvider))
        .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
        .build()
        .create(MobileApi::class.java)
}
