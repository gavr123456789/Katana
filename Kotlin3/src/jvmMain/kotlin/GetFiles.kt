import java.nio.file.Path
import kotlin.io.path.exists
import kotlin.io.path.isDirectory
import kotlin.io.path.listDirectoryEntries

fun getFiles(path: Path): List<Path> {

    if (!path.exists()) {
        return listOf()
    }
    val q = path.listDirectoryEntries().sortedBy { !it.isDirectory() }
    println("in path ${path.fileName} there are ${q.size} files")
    return q
}