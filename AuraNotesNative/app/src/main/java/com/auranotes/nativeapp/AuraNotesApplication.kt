package com.auranotes.nativeapp

import android.app.Application
import com.auranotes.nativeapp.data.local.AppDatabase
import com.auranotes.nativeapp.data.repository.NoteRepository

class AuraNotesApplication : Application() {
    
    val database by lazy { AppDatabase.getDatabase(this) }
    val repository by lazy { NoteRepository(database.noteDao()) }
    
    override fun onCreate() {
        super.onCreate()
    }
}
