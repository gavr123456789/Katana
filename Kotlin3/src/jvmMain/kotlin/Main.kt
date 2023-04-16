

import androidx.compose.desktop.ui.tooling.preview.Preview
import androidx.compose.foundation.LocalScrollbarStyle
import androidx.compose.foundation.ScrollbarStyle
import androidx.compose.material.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.input.key.*
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.WindowState
import androidx.compose.ui.window.application
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.*

val json = Json { ignoreUnknownKeys = true }

@Composable
@Preview
fun App() {
    MaterialTheme {
        CompositionLocalProvider(
            LocalScrollbarStyle provides ScrollbarStyle(
                minimalHeight = 16.dp,
                thickness = 8.dp,
                shape = MaterialTheme.shapes.small,
                hoverDurationMillis = 300,
                unhoverColor = MaterialTheme.colors.onSurface.copy(alpha = 0.12f),
                hoverColor = MaterialTheme.colors.onSurface.copy(alpha = 0.50f),
            )
        ) {
            MainLayout()
//            Body()
//            TransitionedCard()
//            PictureView()
        }
    }
}

@Serializable
data class Project(val name: String, val language: String)

@OptIn(ExperimentalComposeUiApi::class)
fun main() = application {

//    val data = Project("kotlinx.serialization", "Kotlin")
//    val string = json.encodeToString(data)
//    println(string) // {"name":"kotlinx.serialization","language":"Kotlin"}
//    // Deserializing back into objects
//    val obj = json.decodeFromString<Project>(string)
//
//    println(obj) // Project(name=kotlinx.serialization, language=Kotlin)

//    val element = Json.parseToJsonElement("""
//        {"name":"kotlinx.serialization","language":"Kotlin"}
//    """)


//    when (element) {
//        is JsonArray -> TODO()
//        is JsonObject -> TODO()
//        JsonNull -> TODO()
//        else -> {
//
//        }
//    }
//    element.jsonObject.entries.forEach {
//        println("${it.key} to ${it.value}")
//    }

    ////////////////////
    Window(
        onCloseRequest = ::exitApplication, state = WindowState(
            height = 400.dp, width = 310.dp,
        ),
        onKeyEvent = {
            if (
                it.isCtrlPressed &&
                it.key == Key.DirectionRight &&
                it.type == KeyEventType.KeyUp
            ) {
                println("pressed")
                true
            } else {
                false
            }
        }
    ) {
        App()
    }
}
