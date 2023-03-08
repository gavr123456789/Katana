
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.VerticalScrollbar
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.rememberScrollbarAdapter
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Card
import androidx.compose.material.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBackIosNew
import androidx.compose.material.icons.filled.Expand
import androidx.compose.material.icons.filled.UnfoldLess
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import java.nio.file.Path
import kotlin.io.path.Path
import kotlin.io.path.pathString

@ExperimentalFoundationApi
@Composable
fun Page(
    addSelectedFile: (Path) -> Boolean,
    setMainPath: (Path) -> Unit,
    checkSelected: (Path) -> Boolean,
    globalShit: GlobalShit
) {
    var path: Path by remember { mutableStateOf(Path(DEFAULT_PATH).toRealPath()) }
//    val files: List<Path> = getFiles(path)
    var files: List<Path> by remember {mutableStateOf(getFiles(Path(DEFAULT_PATH).toRealPath()))}

    fun setPath(newPath: Path) {
        println("path changed to $newPath")
        path = newPath
        files = getFiles(path)
        setMainPath(newPath)
    }
    globalShit.refreshDir = {
        setPath(Path(path.toString()).toRealPath())
        files = getFiles(path)
        println("refresh page after some action, files size = ${files.size}")
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
                    shape = RoundedCornerShape(0, 7, 7, 0),
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
            }
        }


        Box(
            modifier = Modifier
                .width(300.dp)
                .padding(10.dp, 0.dp, 10.dp, 10.dp)
            ,
            contentAlignment = Alignment.BottomCenter
        ) {
            val state = rememberLazyListState()


            LazyColumn(Modifier.fillMaxSize().padding(end = 12.dp), state) {
                items(files.size) { x ->
                    var isSelected by remember(key1 = files[x].pathString) { mutableStateOf(checkSelected(files[x])) }
                    val setSelected: (Boolean) -> Unit = {
                        isSelected = it
                    }

                    FileRow3(
                        fileItem = files[x],
                        fileName = "${files[x].fileName}",
                        onPathChanged = ::setPath,
                        itemNumber = x,
                        lastItemNumber = files.size - 1,
                        expandedAll = expandedAll,
                        addSelectedFile = addSelectedFile,
                        isSelected = isSelected,
                        setSelected = setSelected
                    )
                    Spacer(modifier = Modifier.height(5.dp))
                }
            }

            VerticalScrollbar(
                modifier = Modifier.align(Alignment.CenterEnd).fillMaxHeight(),
                adapter = rememberScrollbarAdapter(
                    scrollState = state
                )
            )
        }
    }


}
