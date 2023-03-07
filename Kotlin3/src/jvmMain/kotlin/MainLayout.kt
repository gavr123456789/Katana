import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CutCornerShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CopyAll
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.MoveDown
import androidx.compose.material.icons.rounded.ArrowBack
import androidx.compose.material.icons.rounded.Edit
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import java.nio.file.Path
import kotlin.io.path.*
import kotlin.reflect.KFunction0

@Composable
fun TopBar(onMenuClicked: () -> Unit, onFirstButtonClick: () -> Unit, onBackClick: () -> Unit) {
    TopAppBar(
        title = {
            Text(text = "home/", color = Color.White)
        },
        navigationIcon = {

            Icon(
                imageVector = Icons.Default.Menu,
                contentDescription = "Menu",
                modifier = Modifier.clickable(onClick = onMenuClicked),
                tint = Color.White
            )
            IconButton(onClick = onFirstButtonClick) {
                Icon(Icons.Rounded.Edit, contentDescription = "Localized description")
            }

            IconButton(onClick = onBackClick) {
                Icon(Icons.Rounded.ArrowBack, contentDescription = "Localized description")
            }
        },
    )
}

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


@OptIn(ExperimentalFoundationApi::class)
@Composable
fun Body(addSelectedFile: (Path) -> Boolean, setMainPath: (Path) -> Unit, checkSelected: (Path) -> Boolean) {
    val stateHorizontal = rememberScrollState(0)

    Row(
        modifier = Modifier
            .fillMaxSize()
            .padding(end = 12.dp)
            .horizontalScroll(stateHorizontal)
    ) {
        Column(
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.background(Color.White)
        ) {
            Page(addSelectedFile, setMainPath, checkSelected)
        }
    }

//    HorizontalScrollbar(
//        modifier = Modifier
//            .align(Alignment.Bottom)
//            .fillMaxWidth()
//            .padding(end = 12.dp),
//        adapter = rememberScrollbarAdapter(stateHorizontal)
//    )
}


@OptIn(ExperimentalPathApi::class)
@Composable
fun MainLayout() {
    var mainPath: Path by rememberSaveable { mutableStateOf(Path(DEFAULT_PATH)) }
    fun setMainPath(newMainPath: Path) {
        mainPath = newMainPath
        println("mainPath changed to ${newMainPath.pathString}")
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
            run {
                it.deleteRecursively()
                println("Deleting ${it.fileName} from ${mainPath.pathString}")
            }
        }
    }

    fun moveSelectedFiles() {
        selectedFiles.forEach {
            run {
                val newPath = Path(mainPath.pathString, it.name)
                it.moveTo(newPath, true)
                println("Moving ${it.fileName} to ${newPath.pathString}")
            }
        }
    }

    fun copySelectedFiles() {
        selectedFiles.forEach {
            run {
                val newPath = Path(mainPath.pathString, it.name)
                it.copyTo(newPath, true)
                println("Moving ${it.fileName} to ${newPath.pathString}")
            }
        }
    }


    Scaffold(
        scaffoldState = scaffoldState,

        topBar = {
//            TopBar(
//
//                onMenuClicked = {
//                    coroutineScope.launch {
//                        scaffoldState.drawerState.open()
//                    }
//                },
//                onFirstButtonClick = {
//                    TODO()
//                },
//                onBackClick = {
//                    setExpandedBar(!expandedBar)
//                }
//            )
        },
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
            Body(::addSelectedFile, ::setMainPath, ::checkSelected)
        },

        drawerContent = {
            Drawer()
        },

//        floatingActionButton = {
//            FloatingActionButton(
//
//                onClick = {
//                    coroutineScope.launch {
//                        when (scaffoldState.snackbarHostState.showSnackbar(
//                            message = "Snack Bar",
//                            actionLabel = "Dismiss"
//                        )) {
//                            SnackbarResult.Dismissed -> {
//                                // do something when
//                                // snack bar is dismissed
//                            }
//
//                            SnackbarResult.ActionPerformed -> {
//                                // when it appears
//                            }
//                        }
//                    }
//                }) {
//                // Simple Text inside FAB
//                Text(text = "X")
//            }
//        }
    )
}

@Composable
private fun BottomBar(
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
                Icon(Icons.Default.Delete, "delete")
            }


            Card(
                shape = RoundedCornerShape(0),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        moveSelectedFiles()
                    })
            {
                Icon(Icons.Default.MoveDown, "delete")
            }


            Card(
                shape = RoundedCornerShape(0),
                modifier = Modifier.weight(1f).fillMaxSize()
                    .clickable {
                        copySelectedFiles()
                    })
            {
                Icon(Icons.Default.CopyAll, "delete")
            }
        }
    }
}

