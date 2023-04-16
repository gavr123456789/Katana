import kotlinx.serialization.json.JsonElement
import java.nio.file.Path
import kotlin.io.path.*


enum class ItemType {
    File, JSON
}

sealed class RealContent(val name: String)
class File(name: String, val path: Path) : RealContent(name)
class JsonObj(name: String, val json: JsonElement) : RealContent(name)

fun RealContent.getUniq(): String =
    when (this) {
        is File -> this.path.pathString
        is JsonObj -> this.name
    }


fun ItemType.getItems(path: Path): List<RealContent> =
    when (this) {
        ItemType.File -> getFiles(path)
        ItemType.JSON -> TODO()
    }


fun getFiles(path: Path): List<File> {
    if (!path.exists()) {
        return listOf()
    }
    return path.listDirectoryEntries()
        .sortedBy { !it.isDirectory() }
        .map { File(name = it.name, path = it) }
}