package Utils

import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import java.nio.file.Path

@Composable
fun AsyncImageSvgOrElse(fileName: String, fileItem: Path) {
    if (fileName.endsWith(".svg")) {
        val density = LocalDensity.current
        AsyncImage(
            load = { loadSvgPainter(fileItem.toFile(), density) },
            painterFor = { it },
            modifier = Modifier.height(30.dp),
            contentScale = ContentScale.FillWidth
        )
    } else {
        AsyncImage(
            load = { imageFromFile(fileItem.toFile()) },
            painterFor = { remember { BitmapPainter(it) } },
            modifier = Modifier.height(30.dp),
            contentScale = ContentScale.FillWidth
        )
    }
}