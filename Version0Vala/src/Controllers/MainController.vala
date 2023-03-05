using Katana;
using Gee;
//управляется из MainWindow, посылает запросы в DirNavigator
	public class MainController{

    public MainController(Hdy.Carousel carousel, Gtk.Revealer infobar, Gtk.Statusbar statusbar)
    {
		this.carousel = carousel;
		this.infobar = infobar;
		this.statusbar = statusbar;
		//opening files in associated programm
		dir_nav.open_file.connect(open_file);
    }

	weak Hdy.Carousel carousel;
	weak Gtk.Revealer infobar;
	weak Gtk.Statusbar statusbar;
	DirectoryNavigator dir_nav = new DirectoryNavigator();
	SelectedFiles selected_files = new SelectedFiles();

	public string cur_path{
		owned get{
			return dir_nav.path;
		}
	}
	
	//region [ Files ]
	public void create_folder (string folder_name) 
	{
		dir_nav.folder_helper.create_folder(dir_nav.path, folder_name);
		dir_nav.update();
	}

	public void create_file (string file_name) 
	{
		dir_nav.file_helper.create_file(dir_nav.path, file_name);
		dir_nav.update();
	}

	public void delete_selected_files(){
		selected_files.delete_all();

		clear_status_bar();
	}

	public void copy_selected_files(string path){
		selected_files.copy_async_all(path);

		clear_status_bar();
	}

	private void open_file (File file){
		var window = carousel.get_toplevel();
		if(!(window is Window)) error("toplevel of carousel is now window!");

		try {
			Gtk.show_uri_on_window(
				(Window)window,
				file.get_uri(),
				Gdk.CURRENT_TIME
			);
		} catch (Error e) {error(e.message);}
	}
	//endregion

	//region [ Pages ]
	public async void create_page()
	{
		var page = new Page (dir_nav.path, carousel.n_pages + 1);// + 1 тк кк на текущий момент она еще не создана

		page.toggled.connect(page_toggled);
		page.selected.connect(page_selected);

		carousel.add(page);
		carousel.scroll_to(page);
    }

	public async void remove_page()
	{
		var removing_page = (!)(carousel.get_children().last().data as Page);
		removing_page.toggled.disconnect(page_toggled);
		carousel.remove (removing_page);
		dir_nav.go_back();
	}
    
	void page_toggled(File file, bool is_active, uint num_in_carousel)
	{
		if(is_active)
		{
           	delete_last_rows_if_needed(num_in_carousel);
				
			if (dir_nav.goto(file) == true)
				create_page.begin();
		} 
		else 
			delete_last_rows_if_needed(num_in_carousel);
	}

	void page_selected(RowWidget row_widget, bool is_active, uint num_in_carousel)
	{
		if(is_active){
			prin(row_widget.label);
			selected_files.selected_rows.add(row_widget);
		} else {
			selected_files.selected_rows.remove(row_widget);
		}

		//Если выделенных больше нуля, и панель не открыта, то открыть панель, если выделенных стало ноль а панель открыта
		//то закрыть панель
		if(selected_files.selected_rows.size > 0 && infobar.child_revealed == false)
			infobar.reveal_child = true;
		else if (selected_files.selected_rows.size == 0 && infobar.child_revealed == true)
			infobar.reveal_child = false;
		
		statusbar.pop(1);
		statusbar.push(1, @"$(selected_files.selected_rows.size)");

		prin("selected: ", selected_files.selected_rows.size);
		foreach (var row in selected_files.selected_rows)
			prin(row.label);
		
	}
	//endregion

	//region [ Navigation ]
	public inline void go_left(){
		dir_nav.go_left_selected();
	}
	public inline void go_rigth(){
		dir_nav.go_rigth_selected();
	}
	public inline string selected_path(){
		return dir_nav.selected_path;
	}

	//Нужна при открытии папки из одной из предыдущих папок, для удаления всех последующих для открытия новой
	inline void delete_last_rows_if_needed(uint num_in_carousel)
	{
		uint diff_max_and_now = carousel.n_pages - num_in_carousel;
		prin("num in carousele = ", num_in_carousel, " all = ", carousel.n_pages, " diff = ", diff_max_and_now);
		if (diff_max_and_now != 0)
			for (var i = 0; i < diff_max_and_now; i++)
				remove_page.begin();
	}
	//endregion

		
	inline void clear_status_bar()
	{
		statusbar.remove_all(1);
		statusbar.push(1, @"$(selected_files.selected_rows.size)");
		infobar.reveal_child = false;
	}

	
}