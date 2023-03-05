using Gtk;
using Gee;
namespace Katana {
	
	const int LAZY_LOAD_ELEMENTS = 40;

	[GtkTemplate (ui = "/org/gnome/Katana/Page.ui")]
	public class Page : ScrolledWindow 
	{
		[GtkChild] ListBox page_content;
		RowWidget? last_toggled_widget;

		string page_path;
		uint number_in_carousel{private set; get;}

		ArrayQueue<string> file_names_list = new ArrayQueue<string>();
		FolderMonitoring folder_monitor = new FolderMonitoring();
		FileHelper file_helper = new FileHelper();
		DirectoryRepository dir_repo;


		public signal void toggled(File str, bool is_active,  uint path_from);
		public signal void selected(RowWidget str, bool is_active,  uint path_from);

		public Page(string path, uint number_in_carousel)
		{
			dir_repo = new DirectoryRepository(path);
			this.number_in_carousel = number_in_carousel;
			//Monitoring
			this.page_path = path;
			folder_monitor.monitor_dir(path);
			folder_monitor.something_changed.connect(something_changed);

			page_content.set_header_func(set_header_func);// add separators

			fill_file_names();
			fill_page();
			// Lazy loading
			this.vadjustment.value_changed.connect (() => {
				double max_value = (this.vadjustment.upper - this.vadjustment.page_size) * 0.85;
				if (this.vadjustment.value >= max_value) {
					fill_page();
				}
			});

			//  this.vadjustment.changed.connect (() => {
			//  	while (need_more()) {
			//  		fill_page();
			//  	}
			//  });
		}

		~Page(){

		}

		void fill_file_names(){
			foreach (var file_name in dir_repo.get_names())
				file_names_list.add(file_name);
		}

		void update(){
			prin("updated");
			dir_repo.update();
			file_names_list.clear();
			fill_file_names();
			remove_all_elements();
			fill_page();
			show_all();
		}
		

		public void add_new_element(owned File file)
		{
			string filename =  (!)file.get_basename();
			var row = new RowWidget(file) { label = filename };
			row.direction_btn_toggled.connect(row_widget_toggled);
			row.select_btn_toggled.connect(row_widget_selected);
			page_content.add(row);
		}

		void remove_all_elements()
		{
			int i = 0;
			prin("remove_all_elements");
			page_content.foreach((widget) => {
				prin(++i, " removed");
				page_content.remove(widget);
			});
		}

		void something_changed(FileMonitorEvent e, File file)
		{
			message(@"$e");
			this.update();
		}


		void row_widget_toggled(RowWidget src, File file, bool active)
		{
			//untoggle_last
			if(last_toggled_widget != src)
			{
				if (last_toggled_widget == null)
					last_toggled_widget = src;
				else {
					((!)last_toggled_widget).active = false;
					last_toggled_widget = src;
				}
			} 
			//
			toggled(file, active, number_in_carousel);
		}
		void row_widget_selected(RowWidget src, bool active)
		{
			selected(src, active, number_in_carousel);
		}

		void set_header_func (Gtk.ListBoxRow row, Gtk.ListBoxRow? row_before) 
		{
			row.set_header (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
		}

		public void fill_page()
		{
			//  var timer = new Timer();
			int max = file_names_list.size >= LAZY_LOAD_ELEMENTS? LAZY_LOAD_ELEMENTS: file_names_list.size;
			
			for (var i = 0; i < max; ++i)
				add_new_element(file_helper.open_file(page_path + "/" + file_names_list.poll()));
			
			//  prin(Log.METHOD, " ",timer.elapsed());
			//  prin("Items left: ", file_names_list.size);

			show_all();
		}

		//For lazy load
		//  bool need_more() 
		//  {
		//  	if(file_names_list.size != 0)
		//  	{
		//  		int natural_height;
		//  		page_content.get_preferred_height (null, out natural_height);

		//  		if (this.vadjustment.page_size > natural_height) 
		//  			return true;
		//  	}
		//  	return false;
		//  }
	}
}
