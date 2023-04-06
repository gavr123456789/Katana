
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CutCornerShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.outlined.CopyAll
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.MoveDown
import androidx.compose.material.icons.rounded.ArrowBack
import androidx.compose.material.icons.rounded.Edit
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.DelicateCoroutinesApi
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

@OptIn(ExperimentalFoundationApi::class, DelicateCoroutinesApi::class)
@Composable
fun Body(
    addSelectedFile: (Path) -> Boolean,
    setMainPath: (Path) -> Unit,
    checkSelected: (Path) -> Boolean,
    globalShit: GlobalShit,
) {
    val stateHorizontal = rememberScrollState(0)

//    var viewType: ViewType by remember {mutableStateOf (ViewType.Files)}

    val pages: SnapshotStateList<String> by rememberSaveable {mutableStateOf (mutableStateListOf(Path(DEFAULT_PATH).toRealPath().pathString))}
    val scope = rememberCoroutineScope()

    fun openNewPage(newPagePath: String) {
        pages.add(newPagePath)

        scope.launch() {
            delay(100)
            stateHorizontal.animateScrollTo(stateHorizontal.maxValue)
            println(stateHorizontal.value)
        }
    }

    fun removePage(page: String) {
        if (pages.size > 1) {
            println("to delete ${page}")
            println("list before ${pages.map {it}}")
            val qq = pages.indexOfFirst { it == page }
            println("found on $qq")
            pages.removeAt(qq)
            println("list after ${pages.map {it}}")

        }
    }

    Box(modifier = Modifier.fillMaxSize()) {

        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(end = 12.dp)
                .horizontalScroll(stateHorizontal)
        ) {
            println("rerendering: ${pages.map{it}} ")
            pages.forEach{
                Column(
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.background(Color.White)
                ) {
                    Page(it, addSelectedFile, setMainPath, checkSelected, globalShit, ::openNewPage, ::removePage)
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
    var refreshDir: () -> Unit = {}
    fun refreshDirAndSelectedFiles(selectedFiles: MutableSet<Path>, setBottomBarState: (Boolean) -> Unit) {
        selectedFiles.clear()
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

    val selectedFiles: MutableSet<Path> by rememberSaveable { mutableStateOf(mutableSetOf()) }
    var selectedFilesNames: String by rememberSaveable { mutableStateOf("") }

    fun addSelectedFile(file: Path): Boolean {
        val result = if (selectedFiles.contains(file)) {
            selectedFiles.remove(file)
            println("removed ${file.fileName}")
            false
        } else {
            println("added ${file.fileName}")
            selectedFiles.add(file)
            true
        }
        selectedFilesNames = selectedFiles.joinToString(", ") { it.name }
        setExpandedBar(selectedFiles.size > 0)
        return result
    }

    fun checkSelected(file: Path): Boolean = selectedFiles.contains(file)

    fun deleteSelectedFiles() {
        selectedFiles.forEach {
            it.deleteRecursively()
            println("Deleting ${it.fileName} from ${mainPath.pathString}")
        }
        globalShit.refreshDirAndSelectedFiles(selectedFiles, setExpandedBar)
    }

    fun moveSelectedFiles() {
        selectedFiles.forEach {
            val newPath = Path(mainPath.pathString, it.name)
            it.moveTo(newPath, true)
            println("Moving ${it.fileName} to ${newPath.pathString}")
        }
        globalShit.refreshDirAndSelectedFiles(selectedFiles, setExpandedBar)

    }

    fun copySelectedFiles() {
        selectedFiles.forEach {
            val newPath = Path(mainPath.pathString, it.name)
            it.copyTo(newPath, true)
            println("Moving ${it.fileName} to ${newPath.pathString}")
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
                    Body(::addSelectedFile, ::setMainPath, ::checkSelected, globalShit, path = it)
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

