using Gee;

//Provides a list of folders and files in Path
public class DirectoryRepository
{
    public DirectoryRepository(string path) 
    {
        this.path = path;
        update();
    }

    public FolderHelper folder_helper = new FolderHelper();
    public FileHelper file_helper = new FileHelper();
    
    public string path { owned get; private set; }

    public HashSet<string> dirs_search = new HashSet<string>(); 
    ArrayList<string> dirs = new ArrayList<string>();
    ArrayList<string> files = new ArrayList<string>();

    //Updates dirs and files with dirs and files in current dir
    public void update() 
    {
        try 
        {
            Dir dir = Dir.open (path, 0);
            string? name = null;
            dirs_search.clear();
            dirs.clear();
            files.clear();
    
            while ((name = dir.read_name ()) != null) 
            {
                if (((!)name).has_prefix(".")) continue;

                string path = Path.build_filename (path, name);
                if (FileUtils.test (path, FileTest.IS_REGULAR)) 
                    files.add(Filename.display_basename(path));
                
    
                if (FileUtils.test (path, FileTest.IS_SYMLINK)) 
                {}
    
                if (FileUtils.test (path, FileTest.IS_DIR)) {
                    dirs.add(Filename.display_basename(path));
                    dirs_search.add(Filename.display_basename(path));
                }
                if (FileUtils.test (path, FileTest.IS_EXECUTABLE)) {
                }
            }
        } catch (FileError err) {
            stderr.printf (err.message);
        }

    }

    public string[] get_names()
    {
        string[] names = {};
        int i;

        for (i = 0; i < dirs.size; i++)
            names += dirs[i];
        for (int j = 0; j < files.size; j++)
            names += files[j];
        return names;
    }

    public string to_string()
    {
        var builder = new StringBuilder();
        foreach (var file in dirs_search)
            builder.append(file + "\n");
        var s = builder.str;
        return s;
    }
}
