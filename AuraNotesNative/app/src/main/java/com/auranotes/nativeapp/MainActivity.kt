package com.auranotes.nativeapp

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Divider
import androidx.compose.material3.ListItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.auranotes.nativeapp.ui.capture.FastCaptureBottomSheet
import com.auranotes.nativeapp.ui.editor.MarkdownEditor
import com.auranotes.nativeapp.ui.theme.AuraNotesNativeTheme
import com.auranotes.nativeapp.ui.viewmodel.MainViewModel
import com.auranotes.nativeapp.ui.viewmodel.MainViewModelFactory

class MainActivity : ComponentActivity() {
    private val viewModel: MainViewModel by viewModels {
        MainViewModelFactory((application as AuraNotesApplication).repository)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        handleIntent(intent)
        
        setContent {
            AuraNotesNativeTheme {
                var showFastCapture by remember { mutableStateOf(intent.getBooleanExtra("OPEN_FAST_CAPTURE", false)) }
                val notes by viewModel.allNotes.collectAsState()
                
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    Column(modifier = Modifier.padding(innerPadding).fillMaxSize()) {
                        // Main App Content (Note List & Editor)
                        LazyColumn(modifier = Modifier.weight(1f)) {
                            items(notes) { note ->
                                ListItem(
                                    headlineContent = { Text(note.title) },
                                    supportingContent = { Text(note.id.substring(0, 8)) }
                                )
                                Divider()
                            }
                        }
                        MarkdownEditor(modifier = Modifier.weight(1f).padding(16.dp))
                    }
                    
                    if (showFastCapture) {
                        FastCaptureBottomSheet(
                            onDismiss = { showFastCapture = false },
                            onSave = { content ->
                                viewModel.saveQuickNote(content)
                                showFastCapture = false
                            }
                        )
                    }
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
        // Note: For a real app with singleTask launch mode, you'd trigger recomposition here, 
        // but since we read from intent extra on recreation in onCreate, it works for standard launches.
    }

    private fun handleIntent(intent: Intent) {
        // Additional intent handling if needed in the future
    }
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    AuraNotesNativeTheme {
        Greeting("Android")
    }
}
