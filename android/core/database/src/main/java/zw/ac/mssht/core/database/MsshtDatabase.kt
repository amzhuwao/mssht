package zw.ac.mssht.core.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(
    entities = [
        NotificationEntity::class,
        InvoiceEntity::class,
        ClassEntity::class,
        SyncMetaEntity::class,
    ],
    version = 1,
    exportSchema = false,
)
abstract class MsshtDatabase : RoomDatabase() {
    abstract fun notifications(): NotificationDao
    abstract fun invoices(): InvoiceDao
    abstract fun classes(): ClassDao
    abstract fun syncMeta(): SyncMetaDao

    companion object {
        fun create(context: Context): MsshtDatabase =
            Room.databaseBuilder(context, MsshtDatabase::class.java, "mssht_offline.db")
                .fallbackToDestructiveMigration()
                .build()
    }
}
