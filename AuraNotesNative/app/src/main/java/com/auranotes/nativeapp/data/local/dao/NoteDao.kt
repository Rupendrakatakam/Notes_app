package com.auranotes.nativeapp.data.local.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import com.auranotes.nativeapp.data.local.entity.BlockEntity
import com.auranotes.nativeapp.data.local.entity.NoteEntity
import com.auranotes.nativeapp.data.local.entity.NoteLinkEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface NoteDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertNote(note: NoteEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBlocks(blocks: List<BlockEntity>)

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertLinks(links: List<NoteLinkEntity>)

    @Delete
    suspend fun deleteNote(note: NoteEntity)

    @Query("SELECT * FROM notes WHERE id = :noteId")
    suspend fun getNoteById(noteId: String): NoteEntity?

    @Query("SELECT * FROM blocks WHERE noteId = :noteId ORDER BY position ASC")
    suspend fun getBlocksForNote(noteId: String): List<BlockEntity>

    @Transaction
    @Query("SELECT * FROM notes ORDER BY updatedAt DESC")
    fun getAllNotesFlow(): Flow<List<NoteEntity>>

    @Query("SELECT * FROM notes WHERE title LIKE '%' || :query || '%'")
    suspend fun searchNotes(query: String): List<NoteEntity>

    @Query("SELECT * FROM note_links WHERE toNoteId = :noteId")
    suspend fun getBacklinks(noteId: String): List<NoteLinkEntity>
}
