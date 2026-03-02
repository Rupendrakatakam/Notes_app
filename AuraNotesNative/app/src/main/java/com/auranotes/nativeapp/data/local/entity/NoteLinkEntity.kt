package com.auranotes.nativeapp.data.local.entity

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "note_links",
    foreignKeys = [
        ForeignKey(
            entity = NoteEntity::class,
            parentColumns = ["id"],
            childColumns = ["fromNoteId"],
            onDelete = ForeignKey.CASCADE
        ),
        ForeignKey(
            entity = NoteEntity::class,
            parentColumns = ["id"],
            childColumns = ["toNoteId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["fromNoteId"]), Index(value = ["toNoteId"])]
)
data class NoteLinkEntity(
    @PrimaryKey val id: String,
    val fromNoteId: String,
    val toNoteId: String,
    val contextBlockId: String? = null
)
