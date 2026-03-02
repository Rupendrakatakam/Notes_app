package com.auranotes.nativeapp.data.repository

import com.auranotes.nativeapp.data.local.dao.NoteDao
import com.auranotes.nativeapp.data.local.entity.BlockEntity
import com.auranotes.nativeapp.data.local.entity.NoteEntity
import com.auranotes.nativeapp.data.local.entity.NoteLinkEntity
import kotlinx.coroutines.flow.Flow

class NoteRepository(private val noteDao: NoteDao) {

    val allNotesFlow: Flow<List<NoteEntity>> = noteDao.getAllNotesFlow()

    suspend fun getNoteById(id: String): NoteEntity? {
        return noteDao.getNoteById(id)
    }

    suspend fun getBlocksForNote(noteId: String): List<BlockEntity> {
        return noteDao.getBlocksForNote(noteId)
    }

    suspend fun insertNoteWithBlocks(note: NoteEntity, blocks: List<BlockEntity>, links: List<NoteLinkEntity>) {
        noteDao.insertNote(note)
        noteDao.insertBlocks(blocks)
        noteDao.insertLinks(links)
    }

    suspend fun deleteNote(note: NoteEntity) {
        noteDao.deleteNote(note)
    }

    suspend fun searchNotes(query: String): List<NoteEntity> {
        return noteDao.searchNotes(query)
    }
    
    suspend fun getBacklinks(noteId: String): List<NoteLinkEntity> {
        return noteDao.getBacklinks(noteId)
    }
}
