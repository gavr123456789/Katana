
import androidx.compose.animation.*
import androidx.compose.animation.core.keyframes
import androidx.compose.animation.core.tween
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.TextSnippet
import androidx.compose.material.icons.rounded.ArrowForwardIos
import androidx.compose.runtime.*
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
import java.io.File
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import kotlin.io.path.isDirectory
import kotlin.io.path.pathString

private enum class FileType {
    Directory,
    Unknown,
    Image
}

// TODO show error toast if file already exists
@Throws(NoSuchFileException::class, FileAlreadyExistsException::class)
fun Path.renameTo(newName: String) {
    try {
        val src = this.toFile()

        val dest = File(this.parent.pathString, newName)
        println("!!! ${dest.path}")
        if (dest.exists()) {
            throw java.nio.file.FileAlreadyExistsException("Destination file already exist")
        }
        val success = src.renameTo(dest)
        if (success) {
            println("Renaming succeeded")
        } else {
            println("ALL BAD")
        }
    } catch (e: IOException) {
        e.printStackTrace()
    }
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
    fileItem: Path,
    addSelectedFile: (Path) -> Boolean,
    isSelected: Boolean,
    setSelected: (Boolean) -> Unit,
    isExtended: Boolean,
    setExtended: (Boolean) -> Unit,
    openInNewPage: (String) -> Unit,
    refreshCurrentDir: () -> Unit
) {
    val surfaceColor = MaterialTheme.colors.surface
    val green = Color(68, 180, 58)
    val selectedColor = if (isSelected) green else surfaceColor

    val textColor =
        if (isSelected) Color.White else Color.Unspecified //by remember { mutableStateOf(textDefaultColor) }

    var isRenaming by remember { mutableStateOf(false) }
    var fileName2 by remember(key1 = fileItem) { mutableStateOf(fileName) }


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
        val fileType = getFileInfo(fileItem)

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
                        AsyncImageSvgOrElse(fileName, fileItem)
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
                            val wasSelected = addSelectedFile(fileItem)
                            if (!isRenaming)
                                setSelected(wasSelected)
                        },
                        onDoubleClick = {
                            setExtended(!isExtended)
                        },
                        onLongClick = {
                            setExtended(!isExtended)
                            isRenaming = !isRenaming
                        }
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
                        if (isRenaming) {
                            BasicTextField(
                                modifier = Modifier.padding(7.dp).onKeyEvent {
                                    if (
                                        it.type == KeyEventType.KeyUp &&
                                        it.key == Key.Enter
//                                        && it.type == KeyEventType.KeyDown
                                    ) {
                                        fileItem.renameTo(fileName2)
//                                        refreshCurrentDir()
                                        println("renaming to $fileName2")
                                        isRenaming = false
                                        setExtended(false)
                                        true
                                    } else {
                                        false
                                    }
                                },
                                value = fileName2,
                                onValueChange = { newText ->
                                    println(newText.contains("\n"))
                                    if (!newText.contains("\n"))
                                        fileName2 = newText
                                }
                            )
                        } else {
                            Text(
                                fileName2, modifier = Modifier
                                    .background(selectedColor)
                                    .padding(7.dp),
                                fontSize = TextUnit(14f, TextUnitType.Sp),
                                color = textColor
                            )
                        }


                    } else {
                        Text(
                            fileName2, modifier = Modifier
                                .background(selectedColor)
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
                        openInNewPage(fileItem.pathString)
                    }
                    .clickable {
                        when (fileType) {
                            FileType.Directory -> {
                                goToPath(fileItem)
                            }
                            else -> {
                                Desktop.getDesktop().open(fileItem.toFile())
                            }
                        }
                    }
            ) {
                Icon(Icons.Rounded.ArrowForwardIos, null, modifier = Modifier.size(30.dp))
            }
        }
    }
}

@Composable
private fun AsyncImageSvgOrElse(fileName: String, fileItem: Path) {
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

