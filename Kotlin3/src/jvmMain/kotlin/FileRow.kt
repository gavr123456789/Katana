import androidx.compose.animation.*
import androidx.compose.animation.core.keyframes
import androidx.compose.animation.core.tween
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
import androidx.compose.material.icons.rounded.ArrowForwardIos
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.*
import experiments.AsyncImage
import experiments.loadImageBitmap
import java.nio.file.Files
import java.nio.file.Path
import kotlin.io.path.isDirectory

private enum class FileType {
    Directory,
    Unknown,
    Image
}

private fun getFileInfo(fileItem: Path): FileType {
    val isDirectory = fileItem.isDirectory()
    val mimeType: String? = Files.probeContentType(fileItem)
    val isImage = mimeType != null && mimeType.startsWith("image")
    return when {
        isImage -> FileType.Image
        isDirectory -> FileType.Directory
        else -> FileType.Unknown
    }
}

@OptIn(ExperimentalAnimationApi::class, ExperimentalUnitApi::class)
@ExperimentalFoundationApi
@Composable
fun LazyItemScope.FileRow3(
    fileName: String,
    onPathChanged: (Path) -> Unit,
    fileItem: Path,
    itemNumber: Int,
    lastItemNumber: Int,
    expandedAll: Boolean
) {

    var expanded by remember { mutableStateOf(false) }
    expanded = expandedAll


    Card(
        elevation = 10.dp,
        modifier = Modifier
            .fillMaxWidth()
//            .height(30.dp)
    ) {
        val currentPath = fileItem.toRealPath().toString()
        val fileType = getFileInfo(fileItem)
        val stateVerticalScroll = rememberScrollState(0)


        Row(modifier = Modifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {

            Card(
                shape = RoundedCornerShape(7, 0, 0, 7),
                modifier = Modifier
//                    .weight(1.5f)
                    .size(30.dp)
            ) {
                when (fileType) {
                    FileType.Directory -> Icon(Icons.Outlined.Folder, "")
                    FileType.Unknown -> Icon(Icons.Outlined.TextSnippet, "")
                    FileType.Image ->
                        AsyncImage(
                            load = { loadImageBitmap(fileItem.toFile()) },
                            painterFor = { remember { BitmapPainter(it) } },
                            contentDescription = "Sample",
                            modifier = Modifier.height(30.dp)
                        )
                }
            }


            @OptIn(ExperimentalFoundationApi::class)
            Surface(
                modifier = Modifier
                    .fillMaxSize()
                    .align(Alignment.CenterVertically)
                    .weight(8f)
//                    .horizontalScroll(stateVerticalScroll)
                    .combinedClickable(
                        onClick = {
                            GBState.onFileSelect(fileItem)
                        },
                        onDoubleClick = {
                            expanded = !expanded
                            println("double clicked")
                        },

                        )

            ) {
                AnimatedContent(
                    targetState = expanded,
                    transitionSpec = {
                        fadeIn(animationSpec = tween(150, 150)) with
                                fadeOut(animationSpec = tween(150)) using
                                SizeTransform { initialSize, targetSize ->
                                    println("$initialSize $targetSize")
                                    if (targetState) {
                                        keyframes {
                                            // Expand horizontally first.
                                            IntSize(targetSize.width, initialSize.height) at 150
                                            durationMillis = 300
                                        }
                                    } else {
                                        keyframes {
                                            // Shrink vertically first.
                                            IntSize(initialSize.width, targetSize.height) at 150
                                            durationMillis = 300
                                        }
                                    }
                                }
                    }
                ) { targetExpanded ->
                    if (targetExpanded) {
                        Text(
                            fileName, modifier = Modifier
                                .padding(7.dp),
                            fontSize = TextUnit(14f, TextUnitType.Sp)
                        )
                    } else {
                        Text(
                            fileName, modifier = Modifier
                                .height(30.dp)
                                .padding(7.dp),
                            maxLines = 1,
                            overflow = TextOverflow.Visible,
                            fontSize = TextUnit(14f, TextUnitType.Sp)
                        )
                    }
                }
            }


            Card(shape = RoundedCornerShape(0, 7, 7, 0),
                modifier = Modifier
                    .fillMaxHeight()
                    .weight(2f)
                    .clickable {
                        if (fileType == FileType.Directory) {
                            println(currentPath)
                            onPathChanged(fileItem)
                        }
                    }
            ) {
                Icon(Icons.Rounded.ArrowForwardIos, null, modifier = Modifier.size(30.dp))
            }
        }
    }
}

