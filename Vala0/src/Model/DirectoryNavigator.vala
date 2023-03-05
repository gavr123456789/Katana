using Gee;


//Contains the latest(from rigth) oped directory
public class DirectoryNavigator
{

    public DirectoryNavigator() 
    {
        update();
    }

    public PathHelper path_helper = new PathHelper();

    public int selected_path_index;
    public FolderHelper folder_helper = new FolderHelper();
    public FileHelper file_helper = new FileHelper();
    HashSet<string> dirs_search = new HashSet<string>(); 
    
    public string path { owned get { return path_helper.get_full(); }}

    public signal void open_file(File file);

    /**
    * @file open dir or file
    * @return true if it was a folder, false if it was a file
    */
    public bool goto(File file){

        var filename = (!)file.get_basename();
        if(filename in dirs_search)
        {
            path_helper.append(filename);
            message(@"goto $filename");
            prin(Log.METHOD," ", filename);
            update();
            return true;
        } else {
            open_file(file);
            return false;
        }
    }


    public void go_left_selected()
    {
        --selected_path_index;
        prin("index--");
        prin(selected_path_index);

    }
    public void go_rigth_selected()
    {
        ++selected_path_index;
        prin("index++");
        prin(selected_path_index);
    }
    public string selected_path{
        owned get{
            return path_helper.on_index(selected_path_index);
        }
    }


    public void go_back()
    {
        path_helper.remove();
        update();
    }

    /**
    * Updates dirs and files with dirs and files in current dir
    */
    public void update() 
    {
        try 
        {
            Dir dir = Dir.open (path, 0);
            string? name = null;
            dirs_search.clear();
    
            while ((name = dir.read_name ()) != null) 
            {
                if (((!)name).has_prefix(".")) 
                    continue;
                string path = Path.build_filename (path, name);
            
                if (FileUtils.test (path, FileTest.IS_DIR)) 
                    dirs_search.add(Filename.display_basename(path));
                
               
            }
        } catch (FileError err) {
            stderr.printf (err.message);
        }
        //  prin(Log.METHOD, " ",timer.elapsed());
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

[Print] public void prin(string s){stdout.printf(s + "\n");}