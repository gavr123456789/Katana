

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Card
import androidx.compose.material.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBackIosNew
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Expand
import androidx.compose.material.icons.filled.UnfoldLess
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.input.pointer.onPointerEvent
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.util.zip.ZipFile
import kotlin.io.path.*




// Future

fun unzip(zipFileName: String) {
    ZipFile(zipFileName).use { zip ->
        zip.entries().asSequence().forEach { entry ->
            zip.getInputStream(entry).use { input ->
                File(entry.name).outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }
    }
}

fun filterByName() {
    Files.newDirectoryStream(Paths.get("."), "*.zip").forEach { path ->
        val zipFileName = path.toString()
        // any of the above approaches
    }
}


@OptIn(ExperimentalComposeUiApi::class)
@ExperimentalFoundationApi
@Composable
fun Page(
    openedPath: String,
    addSelectedFile: (Path) -> Boolean,
    setMainPath: (Path) -> Unit,
    checkSelected: (Path) -> Boolean,
    openInNewPage: (String) -> Unit,
    removePage: (Int) -> Unit,
    id: Int,
    globalShit: GlobalShit
) {

    val (path, setPath) = remember(key1 = openedPath) { mutableStateOf(Path(openedPath)) }
    var items: List<Path> by remember(key1 = openedPath) { mutableStateOf(getItems(Path(openedPath))) }

    fun goBack(newPath: Path) {
        setPath(newPath)
        items = getItems(newPath)
        setMainPath(newPath)
    }
    fun goToPath(path: Path) {
        setPath(path)
        items = getItems(path)
        setMainPath(path)
    }
    fun refreshPage() {
        items = getItems(path)
    }
    globalShit.refreshDir = ::refreshPage


    fun createFolderHere() {
        (path / "newDir").createDirectory()
        refreshPage()
    }

    fun createFileHere() {
        (path / "newFile.txt").createFile()
        refreshPage()
    }

    var expandedAll by remember { mutableStateOf(false) }


    Column(modifier = Modifier.width(280.dp).fillMaxHeight()) {
        expandedAll = TopMenu(path, expandedAll, ::goBack, {removePage(id)})
        ContextMenuArea(
            items = {
                listOf(
                    ContextMenuItem("+Folder") { createFolderHere() },
                    ContextMenuItem("+File") { createFileHere() },
                )
            },
        ) {
            Box(
                modifier = Modifier
                    .width(300.dp)
                    .padding(10.dp, 0.dp, 10.dp, 10.dp),
                contentAlignment = Alignment.BottomCenter
            ) {
                val stateVertical = rememberLazyListState(0)
                val extendedItems: MutableSet<Path> by remember { mutableStateOf(mutableSetOf()) }
                val scope = rememberCoroutineScope()


                LazyColumn(
                    Modifier
                        .fillMaxSize()
                        .padding(end = 12.dp)
                        .onPointerEvent(PointerEventType.Scroll) {
                            var currentItem = stateVertical.layoutInfo.visibleItemsInfo[0].index
                            val itemsToScrolling =
                                stateVertical.layoutInfo.visibleItemsInfo.size / 2 // how many items we're scrolling
                            if (it.changes.first().scrollDelta.y == 1.0f) { // scroll down
                                scope.launch { stateVertical.animateScrollToItem(currentItem + itemsToScrolling) }
                            } else { // scroll up
                                if (currentItem < itemsToScrolling) {
                                    currentItem = itemsToScrolling
                                } // because we cannot animate to negative number
                                scope.launch { stateVertical.animateScrollToItem(currentItem - itemsToScrolling) }
                            }
                        },
                    state = stateVertical
                ) {


                    items(items.size) { x ->

                        val file = items[x]

                        var isSelected by remember(key1 = items[x].pathString) { mutableStateOf(checkSelected(items[x])) }
                        val setSelected: (Boolean) -> Unit = {
                            isSelected = it
                        }


                        var previousSelectedFile: Path? = remember { null }
                        var lastSelectedFile: Path? = remember { null }
                        fun setSelectedMany(selected: Path) {
                            if (previousSelectedFile == null) {
                                previousSelectedFile = selected
                            } else {
                                lastSelectedFile = selected
//                                selectMany(from = previousSelectedFile, to = lastSelectedFile)
                            }
                        }

                        
                        var isExtended: Boolean by remember(key1 = items[x].pathString) {
                            mutableStateOf(
                                extendedItems.contains(
                                    file
                                )
                            )
                        }
                        val setExtended: (Boolean) -> Unit = {
                            isExtended = it
                            if (it) {
                                extendedItems.add(file)
                            } else {
                                extendedItems.remove(file)
                            }
                        }


                        FileRow3(
                            fileName = "${file.fileName}",
                            goToPath = ::goToPath,
                            fileItem = file,
                            addSelectedFile = addSelectedFile,
                            isSelected = isSelected,
                            setSelected = setSelected,
                            isExtended = expandedAll || isExtended,
                            setExtended = setExtended,
                            openInNewPage = openInNewPage,
                        )
                        Spacer(modifier = Modifier.height(5.dp))
                    }
                }

                VerticalScrollbar(
                    modifier = Modifier.align(Alignment.CenterEnd).fillMaxHeight(),
                    adapter = rememberScrollbarAdapter(
                        scrollState = stateVertical
                    )
                )
            }
        }
    }


}

@Composable
private fun TopMenu(path: Path, expandedAll: Boolean, goBack: (Path) -> Unit, removePage: () -> Unit): Boolean {
    var expandedAll1 = expandedAll
    Card(
        elevation = 10.dp,
        modifier = Modifier
            .fillMaxWidth()
            .padding(10.dp)
            .height(30.dp)
            .padding(end = 12.dp)
    )
    {

        Row(modifier = Modifier.fillMaxSize()) {
            Card(
                shape = RoundedCornerShape(7, 0, 0, 7),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        goBack(path.parent ?: path)
//                        setPath(path.parent ?: path)
                    })
            {
                Icon(Icons.Default.ArrowBackIosNew, "back")
            }
            Card(
                shape = RoundedCornerShape(0),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        expandedAll1 = !expandedAll1
                    })
            {
                if (expandedAll1) {
                    Icon(Icons.Default.Expand, "back")
                } else {
                    Icon(Icons.Default.UnfoldLess, "back")
                }
            }

            Card(
                shape = RoundedCornerShape(0, 7, 7, 0),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        removePage()
                    })
            {
                Icon(Icons.Default.Close, "back")
            }
        }
    }
    return expandedAll1
}
