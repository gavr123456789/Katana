func getFileIconFromExt*(ext: string): string = 
  result = case ext:
      of ".vala": "valacompiler-symbolic"
      of ".java", ".jar": "applications-java-symbolic"
      of ".py": "applications-python-symbolic"
      of ".nim", ".nimble": "nvim-symbolic"
      of ".gitignore": "appimagekit-github-desktop-symbolic"
      of ".exe", ".dll", ".bat": "windows-symbolic"
      of ".kt": "folder-kotlin-symbolic"
      of ".js": "folder-js-symbolic"
      of ".node": "folder-nodejs-symbolic"
      of ".go": "folder-go-symbolic"
      of ".cpp": "khangman-symbolic"
      

      of ".jpg", ".jpeg", ".JPEG", ".JPG": "image-x-generic-symbolic"
      of ".png": "folder-picture-symbolic"

      of ".mp3", ".wav": "deepin-music-player-symbolic"
      of ".mp4", ".mkv": "camera-symbolic"
      of ".webm": "acestreamplayer-symbolic"
      of ".gif": "avidemux_icon-symbolic"

      of ".7z", ".gz", ".zip": "7zip-symbolic"

      of ".pdf": "document-viewer-symbolic"
      of ".svg": "swappy-symbolic"
      of ".css", ".scss": "large-brush-symbolic"
      of ".html": "org.gnome.Eolie-symbolic"
      of ".txt": "accessories-text-editor-symbolic"
      of ".sh": "gnome-eterm-symbolic"
      of ".ui": "object-packing-symbolic"
      of ".qbs": "QtIcon-symbolic"
      # of ".mds": ""
      of ".sql": "libreoffice-base-symbolic"
      # of ".md"
      # of ".yml"
      # of ".json"
      # office
      of ".xls": "x-office-calendar-symbolic"
      of ".doc", ".docx": "x-office-document-symbolic"
      of "": "application-x-executable-symbolic" 
      # VM
      of ".vbox": "application-x-appliance-symbolic"
      of ".vdi": "folder-vm-symbolic"
      # font
      of ".tff": "font-x-generic-symbolic"
      # apps
      # of "inkscape": "inkscape-symbolic"
      # binary data
      of ".bin", ".db": "hex-symbolic"


      else: "folder-documents-symbolic"


func getFolderIconFromName*(folderName: string): string = 
  result = case folderName:
      of "Games": "games-app-symbolic"
      of "JetBrains": "intellij-symbolic"
      of "Apps": "applications-java-symbolic"
      of "Projects": "document-open-symbolic"
      of "Programs": "folder-app-symbolic"
      of "Plugins": "puzzle-piece-symbolic"
      of ".git": "git-cola-symbolic"
      of "Telegram", "Telegram Desktop": "mail-send-symbolic"
      of "node_modules": "folder-nodejs-symbolic"
      of "Books": "folder-library-symbolic" # file-catalog-symbolic
      of "VirtualBox VMs": "folder-vm-symbolic"
      else: "sidebar-places-symbolic" # sidebar-places-symbolic "inode-directory-symbolic"