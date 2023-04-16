import java.nio.file.Path
import kotlin.io.path.exists
import kotlin.io.path.isDirectory
import kotlin.io.path.listDirectoryEntries

sealed class RealContent(val name: String) {

}

class File(name: String, val path: Path): RealContent(name)
class JsonObj(name: String, val json: String): RealContent(name)


fun getItems(path: Path): List<Path> {

    if (!path.exists()) {
        return listOf()
    }
    return path.listDirectoryEntries().sortedBy { !it.isDirectory() }
}

fun getFiles(path: Path) {

}