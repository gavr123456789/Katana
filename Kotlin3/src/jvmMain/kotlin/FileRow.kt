
import androidx.compose.animation.*
import androidx.compose.animation.core.keyframes
import androidx.compose.animation.core.tween
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.TextSnippet
import androidx.compose.material.icons.rounded.ArrowForwardIos
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.*
import experiments.AsyncImage
import experiments.loadImageBitmap
import java.awt.Desktop
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
fun FileRow3(
    fileName: String,
    onPathChanged: (Path) -> Unit,
    fileItem: Path,
    addSelectedFile: (Path) -> Boolean,
    isSelected: Boolean,
    setSelected: (Boolean) -> Unit,
    isExtended: Boolean,
    setExtended: (Boolean) -> Unit

) {
    val surfaceColor = MaterialTheme.colors.surface
    val selectedColor = Color(68, 180, 58)
    val middleColor = if (isSelected) selectedColor else surfaceColor

    val textColor =
        if (isSelected) Color.White else Color.Unspecified //by remember { mutableStateOf(textDefaultColor) }


    Card(
        elevation = 10.dp,
        modifier = Modifier.fillMaxWidth()
    ) {
        val currentPath = fileItem.toRealPath().toString()
        val fileType = getFileInfo(fileItem)


        Row(modifier = Modifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {

            Card(
                shape = RoundedCornerShape(7, 0, 0, 7),
                modifier = Modifier
                    .size(30.dp),
                backgroundColor = MaterialTheme.colors.surface
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
                    .combinedClickable(
                        onClick = {
                            val wasSelected = addSelectedFile(fileItem)
                            setSelected(wasSelected)
                        },
                        onDoubleClick = {
                            setExtended(!isExtended)
                            println("double clicked")
                        },
                    )
            ) {
                AnimatedContent(
                    targetState = isExtended,
                    transitionSpec = {
                        fadeIn(animationSpec = tween(150, 150)) with
                                fadeOut(animationSpec = tween(150)) using
                                SizeTransform { initialSize, targetSize ->
                                    if (targetState) {
                                        keyframes {
                                            IntSize(targetSize.width, initialSize.height) at 150
                                            durationMillis = 300
                                        }
                                    } else {
                                        keyframes {
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
                                .background(middleColor)
                                .padding(7.dp),
                            fontSize = TextUnit(14f, TextUnitType.Sp),
                            color = textColor
                        )
                    } else {
                        Text(
                            fileName, modifier = Modifier
                                .background(middleColor)
                                .height(30.dp)
                                .padding(7.dp),
                            maxLines = 1,
                            overflow = TextOverflow.Visible,
                            fontSize = TextUnit(14f, TextUnitType.Sp),
                            color = textColor
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

                        } else {
                            Desktop.getDesktop().open(fileItem.toFile())

                        }
                    }
            ) {
                Icon(Icons.Rounded.ArrowForwardIos, null, modifier = Modifier.size(30.dp))
            }
        }
    }
}

