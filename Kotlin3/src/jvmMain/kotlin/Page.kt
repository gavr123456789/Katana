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
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import java.nio.file.Path
import kotlin.io.path.Path

// files: List<Path>, onFilesChange: (List<Path>) -> Unit
//@OptIn(ExperimentalFoundationApi::class)
@ExperimentalFoundationApi
@Composable
fun Page() {


    var path: Path by rememberSaveable { mutableStateOf(Path(".").toRealPath()) }
    val maybeFiles = getFiles(path)
    val files: List<Path> = maybeFiles

    fun setPath(newPath: Path) {
        path = newPath
    }

    Column(modifier = Modifier.width(250.dp)) {

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
                            println("back to: $path")
                        })
                {
                    Icon(Icons.Default.ArrowBack, "back")
                }
                Card(
                    shape = RoundedCornerShape(0, 7, 7, 0),
                    modifier = Modifier.weight(1f).fillMaxSize()
                        .clickable {
                            setPath(path.parent ?: path)
                            println("back to: $path")
                        })
                {
                    Icon(Icons.Default.ArrowForward, "back")
                }
            }
        }


        Box(
            modifier = Modifier
                .width(250.dp)
                .padding(10.dp, 0.dp, 10.dp, 10.dp),
            contentAlignment = Alignment.BottomCenter
        ) {
            val state = rememberLazyListState()

            LazyColumn(Modifier.fillMaxSize().padding(end = 12.dp), state) {
                items(files.size) { x ->
                    FileRow3(
                        fileItem = files[x],
                        fileName = "${files[x].fileName}",
                        onPathChanged = { path = it },
                        itemNumber = x,
                        lastItemNumber = files.size - 1
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
