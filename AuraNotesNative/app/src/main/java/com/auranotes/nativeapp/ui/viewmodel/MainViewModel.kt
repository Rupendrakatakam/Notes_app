package com.auranotes.nativeapp.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.auranotes.nativeapp.data.local.entity.BlockEntity
import com.auranotes.nativeapp.data.local.entity.NoteEntity
import com.auranotes.nativeapp.data.repository.NoteRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.util.UUID

class MainViewModel(private val repository: NoteRepository) : ViewModel() {

    val allNotes: StateFlow<List<NoteEntity>> = repository.allNotesFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun saveQuickNote(content: String) {
        if (content.isBlank()) return
        viewModelScope.launch {
            val noteId = UUID.randomUUID().toString()
            val now = System.currentTimeMillis()
            
            val note = NoteEntity(
                id = noteId,
                title = extractTitle(content),
                createdAt = now,
                updatedAt = now
            )
            
            val block = BlockEntity(
                id = UUID.randomUUID().toString(),
                noteId = noteId,
                type = "paragraph",
                content = content,
                position = 0
            )

            repository.insertNoteWithBlocks(note, listOf(block), emptyList())
        }
    }

    private fun extractTitle(content: String): String {
        val lines = content.lines()
        val firstLine = lines.firstOrNull { it.isNotBlank() } ?: "Untitled Note"
        // Remove markdown heading characters if present
        return firstLine.replace(Regex("^#+\\s*"), "").take(50)
    }
}

class MainViewModelFactory(private val repository: NoteRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MainViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return MainViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
