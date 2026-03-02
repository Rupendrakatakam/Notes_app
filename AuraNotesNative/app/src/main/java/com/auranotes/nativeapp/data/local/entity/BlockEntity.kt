package com.auranotes.nativeapp.data.local.entity

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "blocks",
    foreignKeys = [
        ForeignKey(
            entity = NoteEntity::class,
            parentColumns = ["id"],
            childColumns = ["noteId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["noteId"])]
)
data class BlockEntity(
    @PrimaryKey val id: String,
    val noteId: String,
    val type: String, // paragraph, heading, code, task, audio
    val content: String,
    val language: String? = null,
    val checked: Boolean? = null,
    val position: Int,
    val indent: Int = 0,
    val embedding: ByteArray? = null // For vector search later
)
