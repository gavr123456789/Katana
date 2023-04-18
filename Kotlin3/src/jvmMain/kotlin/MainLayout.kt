
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CutCornerShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.CopyAll
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.MoveDown
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.nio.file.Path
import kotlin.io.path.*
import kotlin.reflect.KFunction0

@Composable
fun Drawer() {
    Column(
        Modifier
            .background(Color.White)
            .fillMaxSize()
    ) {
        repeat(5) { item ->
            Text(text = "Item number $item", modifier = Modifier.padding(8.dp), color = Color.Black)
        }
    }
}


enum class ViewType {
    Files,
    Pictures
}


@OptIn(ExperimentalFoundationApi::class)
@Composable
fun Body(
    addSelectedFile: (String) -> Boolean,
    setMainPath: (Path) -> Unit,
    checkSelected: (RealContent) -> Boolean,
    globalShit: GlobalShit,
) {
    val stateHorizontal = rememberScrollState(0)
    val pages: MutableList<String> by remember { mutableStateOf(mutableStateListOf(Path(DEFAULT_PATH).toRealPath().pathString)) }
    val scope = rememberCoroutineScope()

    fun openNewPage(newPagePath: String) {
        pages.add(newPagePath)

        scope.launch() {
            delay(100)
            stateHorizontal.animateScrollTo(stateHorizontal.maxValue - 5)
        }
    }

    fun removePage(pageIndex: Int) {
        if (pages.size > 1) {
            pages.removeAt(pageIndex)
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {

        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(end = 12.dp)
                .horizontalScroll(stateHorizontal)
        ) {

            pages.forEachIndexed { i, it ->
                Column(
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.background(Color.White)
                ) {
                    Page(
                        id = i,
                        openedPath = it,
                        addSelectedFile = addSelectedFile,
                        setMainPath = setMainPath,
                        checkSelected = checkSelected,
                        openInNewPage = ::openNewPage,
                        removePage = ::removePage,
                        globalShit = globalShit
                    )
                }
            }
        }
        HorizontalScrollbar(
            modifier = Modifier.align(Alignment.BottomStart)
                .fillMaxWidth()
                .padding(end = 12.dp),
            adapter = rememberScrollbarAdapter(stateHorizontal)
        )
    }


}

class GlobalShit {
    // refresh all dirs after moving/coping/deleting files
//    var refreshDirs: List<() -> Unit> = listOf()
    var refreshDir: () -> Unit = {}

    fun refreshDirAndSelectedFiles(selectedFiles: MutableSet<String>, setBottomBarState: (Boolean) -> Unit) {
        selectedFiles.clear()
//        refreshDirs.forEach{it()}
        refreshDir()
        setBottomBarState(false)
    }
}

@OptIn(ExperimentalPathApi::class)
@Composable
fun MainLayout() {
    val globalShit = GlobalShit()

    // If there are many pages, only one of them can be selected
    var mainPath: Path by rememberSaveable { mutableStateOf(Path(DEFAULT_PATH)) }
    val pages: MutableList<Path> by rememberSaveable { mutableStateOf(mutableListOf(mainPath)) }
    fun setMainPath(newMainPath: Path) {
        mainPath = newMainPath
    }

    val scaffoldState = rememberScaffoldState(rememberDrawerState(DrawerValue.Closed))
    val (expandedBar, setExpandedBar) = remember { mutableStateOf(false) }

    val selectedFiles: MutableSet<String> by rememberSaveable { mutableStateOf(mutableSetOf()) }
    var selectedFilesNames: String by rememberSaveable { mutableStateOf("") }

    fun addSelectedFile(file: String): Boolean {
        val result = if (selectedFiles.contains(file)) {
            selectedFiles.remove(file)
            println("removed ${file}")
            false
        } else {
            println("added ${file}")
            selectedFiles.add(file)
            true
        }
        selectedFilesNames = selectedFiles.joinToString(", ") { it }
        setExpandedBar(selectedFiles.size > 0)
        return result
    }

    fun checkSelected(file: RealContent): Boolean = when (file) {
        is FileObj -> selectedFiles.contains(file.getUniq())
        is JsonObj -> TODO()
    }

    fun deleteSelectedFiles() {
        selectedFiles.forEach {
            Path(it).deleteRecursively()
            println("Deleting ${it} from ${mainPath.pathString}")
        }
        globalShit.refreshDirAndSelectedFiles(selectedFiles, setExpandedBar)
    }

    fun moveSelectedFiles() {
        selectedFiles.forEach {
            val path = Path(it)
            val newPath = Path(mainPath.pathString, path.name)
            path.moveTo(newPath, true)
            println("Moving ${path.fileName} to ${newPath.pathString}")
        }
        globalShit.refreshDirAndSelectedFiles(selectedFiles, setExpandedBar)
    }

    fun copySelectedFiles() {
        selectedFiles.forEach {
            val path = Path(it)
            val newPath = Path(mainPath.pathString, it)
            path.copyTo(newPath, true)
            println("Moving ${path.fileName} to ${newPath.pathString}")
        }
        globalShit.refreshDirAndSelectedFiles(selectedFiles, setExpandedBar)
    }


    Scaffold(
        scaffoldState = scaffoldState,

        // нужен BackdropScaffold
        bottomBar = {
            val density = LocalDensity.current
            AnimatedVisibility(
                expandedBar,
                enter = slideInVertically {
                    with(density) { 30.dp.roundToPx() }
                },
                exit = slideOutVertically {
                    with(density) { 30.dp.roundToPx() }
                }
            ) {
                BottomAppBar(Modifier.height(30.dp), contentPadding = PaddingValues(0.dp)) {
                    BottomBar(selectedFilesNames, ::deleteSelectedFiles, ::moveSelectedFiles, ::copySelectedFiles)
                }
            }
        },

        content = {
            Column {
                pages.forEach {
                    Body(::addSelectedFile, ::setMainPath, ::checkSelected, globalShit)
                }
            }
        },

        drawerContent = {
            Drawer()
        },
    )
}

@Composable
private fun BottomBar(
    @Suppress("UNUSED_PARAMETER")
    selectedFilesNames: String,
    deleteSelectedFiles: KFunction0<Unit>,
    moveSelectedFiles: KFunction0<Unit>,
    copySelectedFiles: KFunction0<Unit>
) {

    Card(
        elevation = 0.dp,
        modifier = Modifier,
        shape = CutCornerShape(0.dp)
    )
    {

        Row(modifier = Modifier.fillMaxSize()) {

            Card(
                shape = RoundedCornerShape(0),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        deleteSelectedFiles()
                    })
            {
                Icon(Icons.Outlined.Delete, "delete")
            }


            Card(
                shape = RoundedCornerShape(0),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        moveSelectedFiles()
                    })
            {
                Icon(Icons.Outlined.MoveDown, "move")
            }


            Card(
                shape = RoundedCornerShape(0),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        copySelectedFiles()
                    })
            {
                Icon(Icons.Outlined.CopyAll, "copy")
            }
        }
    }
}

