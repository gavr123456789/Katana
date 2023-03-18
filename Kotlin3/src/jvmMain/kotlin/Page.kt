
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.material.Card
import androidx.compose.material.Icon
import androidx.compose.material.Text
import androidx.compose.material.TextField
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
import java.nio.file.Path
import kotlin.io.path.*


@Composable
fun Sass() {
    val text = remember { mutableStateOf("Hello!") }
    Column {
        ContextMenuDataProvider(
            items = {
                listOf(
                    ContextMenuItem("User-defined Action") {/*do something here*/ },
                    ContextMenuItem("Another user-defined action") {/*do something else*/ }
                )
            }
        ) {
            TextField(
                value = text.value,
                onValueChange = { text.value = it },
                label = { Text(text = "Input") }
            )

            Spacer(Modifier.height(16.dp))

            SelectionContainer {
                Text("Hello World!")
            }
        }
    }
}

@OptIn(ExperimentalComposeUiApi::class)
@ExperimentalFoundationApi
@Composable
fun Page(
    addSelectedFile: (Path) -> Boolean,
    setMainPath: (Path) -> Unit,
    checkSelected: (Path) -> Boolean,
    globalShit: GlobalShit,
    path2: Path
) {
    var path: Path by remember { mutableStateOf(Path(DEFAULT_PATH).toRealPath()) }
    var files: List<Path> by remember {mutableStateOf(getFiles(Path(DEFAULT_PATH).toRealPath()))}


    fun setPath(newPath: Path) {
        path = newPath
        files = getFiles(path)
        setMainPath(newPath)
    }

    fun refresh() {
        setPath(Path(path.toString()).toRealPath())
        files = getFiles(path)
        println("refresh page after some action, files size = ${files.size}")
    }

    globalShit.refreshDir = {
        refresh()
    }

    fun createFolderHere() {
        (path / "newDir").createDirectory()
        refresh()
    }
    fun createFileHere() {
        (path / "newFile.txt").createFile()
        refresh()
    }

    var expandedAll by remember { mutableStateOf(false) }


    Column(modifier = Modifier.width(280.dp).fillMaxHeight()) {

        Card(elevation = 10.dp,
            modifier = Modifier
                .fillMaxWidth()
                .padding(10.dp)
                .height(30.dp)
                .padding(end = 12.dp))
        {

            Row(modifier = Modifier.fillMaxSize()) {
                Card(
                    shape = RoundedCornerShape(7, 0, 0, 7),
                    modifier = Modifier.weight(1f).fillMaxSize()
                        .clickable {
                            setPath(path.parent ?: path)
                        })
                {
                    Icon(Icons.Default.ArrowBackIosNew, "back")
                }
                Card(
                    shape = RoundedCornerShape(0),
                    modifier = Modifier.weight(1f).fillMaxSize()
                        .clickable {
                            expandedAll = !expandedAll
                        })
                {
                    if (expandedAll){
                        Icon(Icons.Default.Expand, "back")
                    } else {
                        Icon(Icons.Default.UnfoldLess, "back")
                    }
                }

                Card(
                    shape = RoundedCornerShape(0, 7, 7, 0),
                    modifier = Modifier.weight(1f).fillMaxSize()
                        .clickable {
                            expandedAll = !expandedAll
                        })
                {
                    Icon(Icons.Default.Close, "back")
                }
            }
        }

        ContextMenuArea(
            items = {
                listOf(
                    ContextMenuItem("File") { createFileHere() },
                    ContextMenuItem("Folder") { createFolderHere() },

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

                val extendedItems: MutableSet<Path> by remember { mutableStateOf(mutableSetOf<Path>()) }
                val scope = rememberCoroutineScope()

//                val contextMenuRepresentation = if (isSystemInDarkTheme()) {
//                    DarkDefaultContextMenuRepresentation
//                } else {
//                    LightDefaultContextMenuRepresentation
//                }

                LazyColumn(Modifier.fillMaxSize().padding(end = 12.dp).onPointerEvent(PointerEventType.Scroll) {
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
                }, state = stateVertical) {


                    items(files.size) { x ->

                        val file = files[x]

                        var isSelected by remember(key1 = files[x].pathString) { mutableStateOf(checkSelected(files[x])) }
                        val setSelected: (Boolean) -> Unit = {
                            isSelected = it
                        }
                        var isExtended: Boolean by remember(key1 = files[x].pathString) {
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
                            onPathChanged = ::setPath,
                            fileItem = file,
                            addSelectedFile = addSelectedFile,
                            isSelected = isSelected,
                            setSelected = setSelected,
                            isExtended = expandedAll || isExtended,
                            setExtended = setExtended
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
