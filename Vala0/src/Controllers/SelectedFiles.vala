using Gee;
class SelectedFiles {
    public HashSet<RowWidget> selected_rows = new HashSet<RowWidget>();
    public void delete_all(){
        foreach (var row in selected_rows){
            row.delete_file();
        }
        selected_rows.clear();
    }

    public void copy_async_all(owned string path){
        int copy_num = 0;
        foreach (var row in selected_rows){
            row.copy_async_file(path, ++copy_num);
        }
        selected_rows.clear();
    }
}