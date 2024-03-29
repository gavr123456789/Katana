import Utils.mso
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Card
import androidx.compose.material.Icon
import androidx.compose.material.MaterialTheme
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBackIosNew
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Expand
import androidx.compose.material.icons.filled.UnfoldLess
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.DefaultShadowColor
import androidx.compose.ui.input.pointer.PointerButton
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.input.pointer.onPointerEvent
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.util.zip.ZipFile
import kotlin.io.path.Path
import kotlin.io.path.createDirectory
import kotlin.io.path.createFile
import kotlin.io.path.div


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
    addSelectedFile: (String) -> Boolean,
    setSelectedPageId: (Int) -> Unit,
    checkSelected: (RealContent) -> Boolean,
    openInNewPage: (String) -> Unit,
    removePage: (Int) -> Unit,
    id: Int,
    globalShit: GlobalShit,
    isThisPageSelected: Boolean
) {

    val (path, setPath) = remember(key1 = openedPath) { mso(Path(openedPath)) }
    var items: List<RealContent> by remember(key1 = openedPath) { mso(ItemType.File.getItems(path)) }

//    fun goBack(path: Path) {
//        setPath(path)
//        items = ItemType.File.getItems(path)
//        setSelectedPageId(id)
//    }

    fun goToPath(path: Path) {
        setPath(path)
        items = ItemType.File.getItems(path)
        setSelectedPageId(id)
    }

    fun refreshPage() {
        items = ItemType.File.getItems(path)
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

    var expandedAll by remember { mso(false) }


    Column(modifier = Modifier.width(280.dp).fillMaxHeight()) {
        expandedAll = TopMenu(path, expandedAll, ::goToPath, { removePage(id) }, isThisPageSelected, setSelectedPageId, id)
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
                contentAlignment = Alignment.BottomCenter,

                ) {
                val stateVertical = rememberLazyListState(0)
                val extendedItems: MutableSet<RealContent> by remember { mso(mutableSetOf()) }
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

                        val file: RealContent = items[x]

                        var isSelected by remember(key1 = items[x].getUniq()) { mutableStateOf(checkSelected(items[x])) }
                        val setSelected: (Boolean) -> Unit = {
                            isSelected = it
                        }

                        // TODO select many
//                        var previousSelectedFile: RealContent? = remember { null }
//                        var lastSelectedFile: RealContent? = remember { null }
//                        fun setSelectedMany(selected: RealContent) {
//                            if (previousSelectedFile == null) {
//                                previousSelectedFile = selected
//                            } else {
//                                lastSelectedFile = selected
////                                selectMany(from = previousSelectedFile, to = lastSelectedFile)
//                            }
//                        }

//                                lastSelectedFile = selected
//                                selectMany(from = previousSelectedFile, to = lastSelectedFile)
//                            }
//                        }


                        var isExtended: Boolean by remember(key1 = items[x].getUniq()) {
                            mutableStateOf(
                                extendedItems.contains(file)
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

                        Spacer(modifier = Modifier.height(3.dp))

                        FileRow3(
                            fileName = file.name,
                            goToPath = ::goToPath,
                            item = file,
                            addSelectedFile = addSelectedFile,
                            isSelected = isSelected,
                            setSelected = setSelected,
                            isExtended = expandedAll || isExtended,
                            setExtended = setExtended,
                            openInNewPage = openInNewPage,
                            refreshCurrentDir = ::refreshPage
                        )
                        Spacer(modifier = Modifier.height(2.dp))
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

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun TopMenu(
    path: Path,
    expandedAll: Boolean,
    goBack: (Path) -> Unit,
    removePage: () -> Unit,
    isThisPageSelected: Boolean,
    setSelectedPageId: (Int) -> Unit,
    pageId: Int
): Boolean {
    var expandedAll1 = expandedAll
    Card(
        elevation = 10.dp,
        modifier = Modifier
            .fillMaxWidth()
            .padding(10.dp)
            .height(30.dp)
            .padding(end = 12.dp)
            .shadow(
//                ambientColor = if (isThisPageSelected) Color.Blue else DefaultShadowColor,
                spotColor = if (isThisPageSelected) Color.Blue else DefaultShadowColor,
                elevation = if (isThisPageSelected) 18.dp else 10.dp,
                shape = MaterialTheme.shapes.medium
            )
            .onClick(matcher = PointerMatcher.mouse(PointerButton.Secondary)) {
                setSelectedPageId(pageId)
            }
    )
    {

        Row(modifier = Modifier.fillMaxSize()) {
            Card(
                shape = RoundedCornerShape(7, 0, 0, 7),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        goBack(path.parent ?: path)
                    })
            {
                Icon(Icons.Default.ArrowBackIosNew, "back")
            }
            Card(
                shape = RoundedCornerShape(0),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable(role = Role.Checkbox) {
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
