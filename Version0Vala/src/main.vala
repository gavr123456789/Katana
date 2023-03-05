
int main (string[] args) {
	var app = new Gtk.Application ("org.gnome.Katana", ApplicationFlags.FLAGS_NONE);

	app.startup.connect (() => {
		Hdy.init ();
	});

	app.activate.connect (() => {
		var win = app.active_window;
		win = new Katana.Window (app);
		win.present ();
	});

	//For catching CRITICALS with GDB
	Log.set_always_fatal(LogLevelFlags.LEVEL_CRITICAL);

	return app.run (args);
}
