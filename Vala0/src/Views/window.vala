using Gee;
namespace Katana{

	

[GtkTemplate (ui = "/org/gnome/Katana/window.ui")]
public class Window : Hdy.ApplicationWindow {
	[GtkChild] Hdy.Carousel carousel;
	
	[GtkChild] Gtk.ToggleButton search_button;
	[GtkChild] Gtk.ToggleButton create_folder;
	[GtkChild] Gtk.ToggleButton create_file;
	
	[GtkChild] Gtk.Entry folder_name_entry;
	[GtkChild] Gtk.Entry file_format_entry;
	[GtkChild] Gtk.Entry file_name_entry;

	[GtkChild] Gtk.SearchBar searchbar;
	[GtkChild] Gtk.Statusbar statusbar;

	[GtkChild] Gtk.Revealer selectedbar;
	//  [GtkChild] Gtk.Image infobar_icon;
 
	MainController main_controller;
	uint current_page = 0;

	public Window (Gtk.Application app) {
		Object (application: app);
	}
	construct {
		main_controller = new MainController(carousel, selectedbar, statusbar);
		main_controller.create_page.begin();
	}

	[GtkCallback]
	void page_changed (Hdy.Carousel carousel, uint index) {
		//We need to check is it changed left or rigth
		if(current_page < index)
			main_controller.go_rigth();
		else if (current_page > index)
			main_controller.go_left();

		current_page = index;
	}

	[GtkCallback]
	void create_folder_clicked (Gtk.Widget btn) {
		main_controller.create_folder(folder_name_entry.text);
		folder_name_entry.text = "";
		create_folder.active = false;
	}

	[GtkCallback]
	void create_file_clicked (Gtk.Widget btn) {
		string format = 
		file_format_entry.text.has_prefix(".")?
		 file_format_entry.text:
		 "." + file_format_entry.text;
		
		main_controller.create_file(file_name_entry.text + format);
		file_name_entry.text   = "";
		file_format_entry.text = "";
		create_file.active = false;
	}

	[GtkCallback]
	void on_search_button_toggled () {
		if (search_button.active) {
			searchbar.search_mode_enabled = true;
		} else {
			searchbar.search_mode_enabled = false;
		}
	}

	[GtkCallback]
	void delete_file_clicked (Gtk.Button src) {
		main_controller.delete_selected_files();
	}

	[GtkCallback]
	void copy_file_clicked (Gtk.Button src) {
		message(@"$(main_controller.cur_path)");
		//main_controller.copy_selected_files(main_controller.cur_path);
	}

	[GtkCallback]
	void test_button_clicked (Gtk.Button src) {
		//  showinfobar (QUESTION, "Question?");
	}
}

}// no usless extra indent
