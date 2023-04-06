package experiments

import androidx.compose.foundation.Image
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asSkiaBitmap
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.loadSvgPainter
import androidx.compose.ui.unit.Density
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.jetbrains.skia.SamplingMode
import java.io.File
import java.io.IOException


//object GlobalImageCache {
//    val map = mutableMapOf<String, ImageBitmap>()
//}

@Composable
fun <T>AsyncImage(
    load: suspend () -> T,
    painterFor: @Composable (T) -> Painter,
    modifier: Modifier = Modifier,
    contentScale: ContentScale = ContentScale.Crop,
) {
    val image:  T? by produceState<T?>(null) {

        value = withContext(Dispatchers.IO) {
                try {
                    val x = load()
                    x
                } catch (e: IOException) {
                    e.printStackTrace()
                    null
                }
            }
    }


    if (image != null) {
        Image(
            painter = painterFor(image!!),
            contentDescription = null,
            contentScale = contentScale,
            modifier = modifier
        )
    }
}

// Loading from file with java.io API
//fun loadImageBitmap(file: File): ImageBitmap {
//    return file.inputStream().buffered().use(::loadImageBitmap)
//}

fun imageFromFile(file: File): ImageBitmap {
    val image = org.jetbrains.skia.Image.makeFromEncoded(file.readBytes())
    val scaledImage = ImageBitmap(image.width / 4, image.height / 4)
    image.scalePixels(scaledImage.asSkiaBitmap().peekPixels()!!, SamplingMode.DEFAULT, true)
    return scaledImage
}


fun loadSvgPainter(file: File, density: Density): Painter =
    file.inputStream().buffered().use { loadSvgPainter(it, density) }

//fun loadXmlImageVector(file: File, density: Density): ImageVector =
//    file.inputStream().buffered().use { loadXmlImageVector(InputSource(it), density) }

/* Loading from network with java.net API */
//
//fun loadImageBitmap(url: String): ImageBitmap =
//    URL(url).openStream().buffered().use(::loadImageBitmap)
//
//fun loadSvgPainter(url: String, density: Density): Painter =
//    URL(url).openStream().buffered().use { loadSvgPainter(it, density) }
//
//fun loadXmlImageVector(url: String, density: Density): ImageVector =
//    URL(url).openStream().buffered().use { loadXmlImageVector(InputSource(it), density) }

/* Loading from network with Ktor client API (https://ktor.io/docs/client.html). */

/*

suspend fun loadImageBitmap(url: String): ImageBitmap =
    urlStream(url).use(::loadImageBitmap)

suspend fun loadSvgPainter(url: String, density: Density): Painter =
    urlStream(url).use { loadSvgPainter(it, density) }

suspend fun loadXmlImageVector(url: String, density: Density): ImageVector =
    urlStream(url).use { loadXmlImageVector(InputSource(it), density) }

@OptIn(KtorExperimentalAPI::class)
private suspend fun urlStream(url: String) = HttpClient(CIO).use {
    ByteArrayInputStream(it.get(url))
}

 */