import sets
import ../main_widgets/row_widget
var selectedStoreGb*: HashSet[FileRow] # if page with selected closed, may be leak?
