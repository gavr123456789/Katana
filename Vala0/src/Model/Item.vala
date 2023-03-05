public class Content {
    public GLib.File file;
    public void delete_sync(){
        try {
            file.delete ();
        } catch (Error e) {
            print ("Deleting file error: %s\n", e.message);
        }
    }

    public void copy_async_to(string path, int number_of_copyfile){
        File path_file = File.new_for_path (path);
        file.copy_async.begin (path_file, 0, Priority.DEFAULT, null, (current_num_bytes, total_num_bytes) => {
            // Report copy-status:
            print (@"$number_of_copyfile %" + int64.FORMAT + " bytes of %" + int64.FORMAT + " bytes copied.\n",
                current_num_bytes, total_num_bytes);
        }, (obj, res) => {
            try {
                bool tmp = file.copy_async.end (res);
                print ("Result: %s\n", tmp.to_string ());
            } catch (Error e) {
                print ("Error: %s\n", e.message);
            }
        });
    }

    public void move_to(string path){
        
    }
}