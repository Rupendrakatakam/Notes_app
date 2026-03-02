package com.auranotes.nativeapp.service

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.withContext
import java.util.concurrent.atomic.AtomicBoolean

class VoiceTranscriptionService(private val context: Context) {
    
    private val _isRecording = MutableStateFlow(false)
    val isRecording: StateFlow<Boolean> = _isRecording

    private val _transcribedText = MutableStateFlow("")
    val transcribedText: StateFlow<String> = _transcribedText

    private var audioRecord: AudioRecord? = null
    private val recordingThread = AtomicBoolean(false)
    
    // Whisper.cpp parameters usually require 16kHz, mono, 16-bit PCM
    private val sampleRate = 16000
    private val channelConfig = AudioFormat.CHANNEL_IN_MONO
    private val audioFormat = AudioFormat.ENCODING_PCM_16BIT
    private val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)

    suspend fun startRecording() {
        if (_isRecording.value) return
        
        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize
            )

            audioRecord?.startRecording()
            _isRecording.value = true
            recordingThread.set(true)
            
            withContext(Dispatchers.IO) {
                readAudioLoop()
            }
        } catch (e: SecurityException) {
            e.printStackTrace()
            // Handle permission denied
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun stopRecording() {
        recordingThread.set(false)
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        _isRecording.value = false
        
        // Mocking Whisper transcription delay
        simulateTranscription()
    }

    private fun readAudioLoop() {
        val buffer = ShortArray(bufferSize)
        while (recordingThread.get()) {
            val readSize = audioRecord?.read(buffer, 0, bufferSize) ?: 0
            if (readSize > 0) {
                // Here we would feed the raw audio buffer into whisper.cpp via JNI
                // e.g., WhisperJNI.processAudio(buffer)
            }
        }
    }

    private fun simulateTranscription() {
        // Placeholder for actual C++ Whisper JNI call
        // E.g., val text = whisperJni.getFullTranscription()
        _transcribedText.value = "This is a placeholder transcription from the local Whisper instance. Audio was captured successfully and passed to the JNI bridge."
    }
}
