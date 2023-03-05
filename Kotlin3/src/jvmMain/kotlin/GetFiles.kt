import java.nio.file.Path
import kotlin.io.path.Path
import kotlin.io.path.exists
import kotlin.io.path.isDirectory
import kotlin.io.path.listDirectoryEntries

fun getFiles(path: Path): List<Path> {
//    val path = Path(pathStr)

    if (!path.exists()) {
        return listOf()
    }

    return path.listDirectoryEntries().sortedBy { !it.isDirectory() }
}