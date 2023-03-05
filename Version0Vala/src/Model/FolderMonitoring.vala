public class FolderMonitoring{

	public signal void something_changed(FileMonitorEvent event, File file);
	FileMonitor monitor; 
	public void monitor_dir(string path_for_monitor)
	{
		try {
			File file = File.new_for_path (path_for_monitor);
			
			monitor = file.monitor (FileMonitorFlags.NONE, null);
			message ("Monitoring: %s\n", file.get_path () ?? "Error get_path");

			monitor.changed.connect ((src, new_name, event) => {
				if (new_name != null) {
					something_changed(event, src);
					message (@"$event: %s, %s\n", src.get_path () ?? "Error get_path", ((!)new_name).get_path () ?? "Error get_path");
					
				} else {
					something_changed(event, src);
					message ("%s: %s\n", event.to_string (), src.get_path () ?? "Error get_path");
				}
			});
		} catch (Error e) {
			warning(e.message);
		}
	}
	
}