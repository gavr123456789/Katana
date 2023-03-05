import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyItemScope
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Card
import androidx.compose.material.Icon
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.TextSnippet
import androidx.compose.material.icons.rounded.ArrowForward
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.unit.dp
import experiments.AsyncImage
import experiments.loadImageBitmap
import java.nio.file.Files
import java.nio.file.Path
import kotlin.io.path.isDirectory

private enum class Sas {
    Directory,
    File,
    Image
}

private fun getFileInfo(fileItem: Path): Sas {
    val isDirectory = fileItem.isDirectory()
    val mimeType: String? = Files.probeContentType(fileItem)
    val isImage = mimeType != null && mimeType.startsWith("image")
    return when {
        isImage -> Sas.Image
        isDirectory -> Sas.Directory
        else -> Sas.File
    }
}

@ExperimentalFoundationApi
@Composable
fun LazyItemScope.FileRow3(
    fileName: String,
    onPathChanged: (Path) -> Unit,
    fileItem: Path,
    itemNumber: Int,
    lastItemNumber: Int
) {

    Card(
        elevation = 10.dp,
        modifier = Modifier
            .fillMaxWidth()
            .height(30.dp)
    ) {
        val currentPath = fileItem.toRealPath().toString()
        val fileType = getFileInfo(fileItem)
        val stateVerticalScroll = rememberScrollState(0)

        Row(modifier = Modifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {

            Card(
                shape = RoundedCornerShape(7, 0, 0, 7),
                modifier = Modifier
                    .weight(1.5f)
                    .fillMaxSize()
            ) {
                when (fileType) {
                    Sas.Directory -> Icon(Icons.Outlined.Folder, "")
                    Sas.File -> Icon(Icons.Outlined.TextSnippet, "")
                    Sas.Image ->
                        AsyncImage(
                            load = { loadImageBitmap(fileItem.toFile()) },
                            painterFor = { remember { BitmapPainter(it) } },
                            contentDescription = "Sample",
                            modifier = Modifier.height(30.dp)
                        )
                }
            }

            Surface(modifier = Modifier
                .fillMaxSize()
                .align(Alignment.CenterVertically)
                .weight(8f)
                .horizontalScroll(stateVerticalScroll)
                .clickable {
                    GBState.onFileSelect(fileItem)
                }) {
                Text(
                    fileName, modifier = Modifier.padding(5.dp)
                )
            }


            Card(shape = RoundedCornerShape(0, 7, 7, 0),
                modifier = Modifier
                    .fillMaxSize()
                    .weight(2f)
                    .clickable {
                        if (fileType == Sas.Directory) {
                            println(currentPath)
                            onPathChanged(fileItem)
                        }
                    }
            )
            {
                Icon(Icons.Rounded.ArrowForward, "", modifier = Modifier.fillMaxSize())
            }
//
//            Column(modifier = Modifier) {
//                Card(shape = RoundedCornerShape(7, 0, 0, 7)) {
//                    when (fileType) {
//                        Sas.Directory -> Icon(Icons.Outlined.Folder, "", modifier = Modifier.size(30.dp))
//                        Sas.File -> Icon(Icons.Outlined.TextSnippet, "", modifier = Modifier.size(30.dp))
//                        Sas.Image ->
//                            AsyncImage(
//                                load = { loadImageBitmap(fileItem.toFile()) },
//                                painterFor = { remember { BitmapPainter(it) } },
//                                contentDescription = "Sample",
//                                modifier = Modifier.width(30.dp)
//                            )
//                    }
//                }
//            }
//            Column(modifier = Modifier
//                .fillMaxWidth()
//                .weight(7f)
//                .verticalScroll(stateVerticalScroll)
//                .clickable {
//                    GBState.onFileSelect(fileItem)
//                }) {
//                Text(fileName, modifier = Modifier.padding(5.dp), style = TextStyle())
//            }
//
//            Column(modifier = Modifier
//                .fillMaxSize()
//                .weight(2f)
//                .clickable
//                {
//                    if (fileType == Sas.Directory) {
//                        println(currentPath)
//                        onPathChanged(fileItem)
//                    }
//                }
//            ) {
//                Card(shape = RoundedCornerShape(0, 7, 7, 0), modifier = Modifier.fillMaxSize()) {
//                    Icon(Icons.Rounded.ArrowForward, "", modifier = Modifier.fillMaxSize())
//                }
//            }

        }
    }
}

