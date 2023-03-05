using Gee;
public class PathHelper 
{
    public PathHelper()
    {
        path.add(Environment.get_home_dir());
    }
    
    ArrayList<string> path = new ArrayList<string>();
    public void append(string s){ path.add(Path.DIR_SEPARATOR_S + s); }
    public void remove()        { path.remove_at(path.size - 1); }
    public string on_index(int index) requires (index > -1) {return path[index];}
    public int size { get{ return path.size; } }

    public inline string get_full()
    {
        var builder = new StringBuilder();
        foreach(var a in path)
            builder.append(a);
        
        return builder.str;
    }
    public string to_string()
    {
        return get_full();
    }
}

[Compact]
public class FolderHelper
{
    public void create_folder(owned string path, owned string folder_name)
    {
        prin(Path.build_path(Path.DIR_SEPARATOR_S, path, folder_name));
        var builded_path = Path.build_path(Path.DIR_SEPARATOR_S, path, folder_name);
        var result = DirUtils.create_with_parents(builded_path, 0755);
        prin(result == 0? "folder created":"failed to create folder");
    }
} 

[Compact]
public class FileHelper {
    public void delete_file(string path, string file_name){
        message(@"removing $(Path.build_path(path,file_name))");
        FileUtils.remove(Path.build_path(path, file_name));
    }

    public File open_file(string path){
        return File.new_for_path (path);
    }

    public File create_file(string path, string file_name){
        message(@"creating file: $(Path.build_path(Path.DIR_SEPARATOR_S, path, file_name))");
        string builded_path = Path.build_path(Path.DIR_SEPARATOR_S, path, file_name);
        var file = File.new_for_path (builded_path);
        try {
            file.create(FileCreateFlags.NONE);
        } catch (Error e) {message(e.message);}
        return file;

    }
}