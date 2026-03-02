package com.auranotes.nativeapp.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.auranotes.nativeapp.data.local.dao.NoteDao
import com.auranotes.nativeapp.data.local.entity.BlockEntity
import com.auranotes.nativeapp.data.local.entity.NoteEntity
import com.auranotes.nativeapp.data.local.entity.NoteLinkEntity

@Database(
    entities = [NoteEntity::class, BlockEntity::class, NoteLinkEntity::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {

    abstract fun noteDao(): NoteDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "auranotes.db"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
