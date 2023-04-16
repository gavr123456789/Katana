
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
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.input.key.*
import androidx.compose.ui.input.pointer.PointerButton
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.*
import experiments.AsyncImage
import experiments.imageFromFile
import experiments.loadSvgPainter
import java.awt.Desktop
import java.nio.file.Files
import java.nio.file.Path
import kotlin.io.path.isDirectory
import kotlin.io.path.pathString

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

@OptIn(ExperimentalAnimationApi::class, ExperimentalUnitApi::class, ExperimentalComposeUiApi::class)
@ExperimentalFoundationApi
@Composable
fun FileRow3(
    fileName: String,
    goToPath: (Path) -> Unit,
    item: RealContent,
    addSelectedFile: (String) -> Boolean,
    isSelected: Boolean,
    setSelected: (Boolean) -> Unit,
    isExtended: Boolean,
    setExtended: (Boolean) -> Unit,
    openInNewPage: (String) -> Unit,
) {
    val surfaceColor = MaterialTheme.colors.surface
    val selectedColor = Color(68, 180, 58)
    val middleColor = if (isSelected) selectedColor else surfaceColor

    val textColor =
        if (isSelected) Color.White else Color.Unspecified //by remember { mutableStateOf(textDefaultColor) }

    if (item !is File) {
        throw Error("TODO")
    }
    val path = item.path

    Card(
        elevation = 10.dp,
        modifier = Modifier.fillMaxWidth().onPreviewKeyEvent {
            when {
                (it.key == Key.A && it.type == KeyEventType.KeyUp) -> {
                    true
                }

                else -> false
            }
        }
    ) {
        val pathString = path.toRealPath().toString()
        val fileType = getFileInfo(path)

        Row(
            modifier = Modifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically)
        {

            Card(
                shape = RoundedCornerShape(7, 0, 0, 7),
                modifier = Modifier.size(30.dp),
                backgroundColor = MaterialTheme.colors.surface
            ) {
                when (fileType) {
                    FileType.Directory -> Icon(Icons.Outlined.Folder, "")
                    FileType.Unknown -> Icon(Icons.Outlined.TextSnippet, "")
                    FileType.Image -> {
                        if (fileName.endsWith(".svg")) {
                            val density = LocalDensity.current
                            AsyncImage(
                                load = { loadSvgPainter(path.toFile(), density) },
                                painterFor = { it },
                                modifier = Modifier.height(30.dp),
                                contentScale = ContentScale.FillWidth
                            )
                        } else {
                            AsyncImage(
                                load = { imageFromFile(path.toFile()) },
                                painterFor = { remember { BitmapPainter(it) } },
                                modifier = Modifier.height(30.dp),
                                contentScale = ContentScale.FillWidth
                            )
                        }
                    }
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
                            val wasSelected = addSelectedFile(path.pathString)
                            setSelected(wasSelected)
                        },
                        onDoubleClick = {
                            setExtended(!isExtended)
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
                    .onClick(matcher = PointerMatcher.mouse(PointerButton.Secondary)) {
                        openInNewPage(path.pathString)
                    }
                    .clickable {
                        if (fileType == FileType.Directory) {
                            goToPath(path)
                        } else {
                            Desktop.getDesktop().open(path.toFile())
                        }
                    }
            ) {
                Icon(Icons.Rounded.ArrowForwardIos, null, modifier = Modifier.size(30.dp))
            }
        }
    }
}

