package com.auranotes.nativeapp.ui.editor

import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.OffsetMapping
import androidx.compose.ui.text.input.TransformedText
import androidx.compose.ui.text.input.VisualTransformation

@Composable
fun MarkdownEditor(modifier: Modifier = Modifier) {
    var text by remember { mutableStateOf("") }

    BasicTextField(
        value = text,
        onValueChange = { text = it },
        modifier = modifier,
        textStyle = MaterialTheme.typography.bodyLarge.copy(color = MaterialTheme.colorScheme.onSurface),
        cursorBrush = SolidColor(MaterialTheme.colorScheme.primary),
        visualTransformation = MarkdownVisualTransformation()
    )
}

class MarkdownVisualTransformation : VisualTransformation {
    override fun filter(text: androidx.compose.ui.text.AnnotatedString): TransformedText {
        val annotatedString = buildAnnotatedString {
            append(text.text)
            
            // Basic Markdown highlight rules
            
            // Bold **text**
            var matcher = Regex("\\*\\*(.*?)\\*\\*").findAll(text.text)
            for (match in matcher) {
                addStyle(
                    style = SpanStyle(fontWeight = FontWeight.Bold),
                    start = match.range.first,
                    end = match.range.last + 1
                )
            }
            
            // Headings # Heading
            matcher = Regex("^(#{1,6}) (.*)\$", RegexOption.MULTILINE).findAll(text.text)
            for (match in matcher) {
                addStyle(
                    style = SpanStyle(
                        fontWeight = FontWeight.Bold,
                        color = androidx.compose.ui.graphics.Color(0xFF81D4FA) // Header accent color
                    ),
                    start = match.range.first,
                    end = match.range.last + 1
                )
            }
            
            // Code block `code`
            matcher = Regex("`(.*?)`").findAll(text.text)
            for (match in matcher) {
                addStyle(
                    style = SpanStyle(
                        fontFamily = FontFamily.Monospace,
                        background = androidx.compose.ui.graphics.Color.DarkGray.copy(alpha = 0.5f)
                    ),
                    start = match.range.first,
                    end = match.range.last + 1
                )
            }
        }
        return TransformedText(annotatedString, OffsetMapping.Identity)
    }
}
