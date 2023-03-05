using Gtk;
public class RowWidget : ListBoxRow {
    public RowWidget(GLib.File file){
        content.file = file;

        this.add(main_box);
        main_box.add(select_btn);
        main_box.add(direction_btn);
        
        main_box.get_style_context().add_class(STYLE_CLASS_LINKED);
        direction_btn.toggled.connect(direction_toggled_handler);
        select_btn.toggled.connect(selected_toggled_handler);
    }

    ~RowWidget(){
        direction_btn.toggled.disconnect(direction_toggled_handler);
        select_btn.toggled.disconnect(selected_toggled_handler);
    }

    Content content = new Content();

    ToggleButton select_btn    = new ToggleButton();
    ToggleButton direction_btn = new ToggleButton(){
        always_show_image = true,
        label = "",
        image = new Image.from_icon_name("pan-end-symbolic", IconSize.BUTTON)
    };

    Box main_box = new Box(Orientation.HORIZONTAL, 0);
    
    public signal void direction_btn_toggled(File file, bool is_active);
    public signal void select_btn_toggled(RowWidget row_widget, bool is_active);
  
    public bool active { 
        get { return direction_btn.active; } 
        set { direction_btn.set_active(value); } 
    }

    public bool selected { 
        get { return select_btn.active; } 
        set { direction_btn.set_active(value); } 
    }

    public string label { 
        get { return select_btn.label ?? "Null Error"; } 
        set { select_btn.label = value; } 
    }

    public FileType file_type {
        get { return content.file.query_file_type(FileQueryInfoFlags.NONE); } 
    }

    public inline void delete_file(){
        content.delete_sync();
    }

    public inline void copy_async_file(owned string path, int copy_num){
        content.copy_async_to(path, copy_num);
    }

    inline void direction_toggled_handler (ToggleButton src){
        if(src.active)
        {
            prin("Toggled file type: ", file_type);
            if(file_type == FileType.REGULAR) {
                TimeoutSource time = new TimeoutSource.seconds(1);

                time.set_callback (() => {
                    src.active = false;
                    return false;
                });
                time.attach();
            }
        }
        direction_btn_toggled(content.file, direction_btn.active);
    }

    inline void selected_toggled_handler (ToggleButton src){
        select_btn_toggled(this, src.active);

    }

    
}