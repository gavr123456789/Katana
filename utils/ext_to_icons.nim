func getFileIconFromExt*(ext: string): string = 
  result = case ext:
      of ".vala": "valacompiler-symbolic"
      of ".java": "applications-java-symbolic"
      of ".py": "applications-python-symbolic"
      of ".nim", ".nimble": "nvim-symbolic"
      of ".gitignore": "appimagekit-github-desktop-symbolic"
      of ".exe": "wine-winecfg-symbolic"
      of ".kt": "folder-kotlin-symbolic"
      of ".js": "folder-js-symbolic"
      of ".node": "folder-nodejs-symbolic"
      of ".png", ".jpg", ".jpeg": "folder-picture-symbolic"
      of ".mp3", ".wav": "deepin-music-player-symbolic"
      of ".mp4", "mkv": "camera-symbolic"
      of ".webm": "acestreamplayer-symbolic"
      of ".gif": "avidemux_icon-symbolic"
      
      else: "folder-documents-symbolic"


func getFolderIconFromName*(folderName: string): string = 
  result = case folderName:
      of "Games": "games-app-symbolic"
      of "Apps": "applications-java-symbolic"
      of "Projects": "document-open-symbolic"
      of "Programs": "gnugo-symbolic"
      of "Plugins": "puzzle-piece-symbolic"
      of ".git": "git-cola-symbolic"
      of "Telegram": "mail-send-symbolic"
      of "node_modules": "folder-nodejs-symbolic"
      of "Books": "folder-library-symbolic" # file-catalog-symbolic
      
      else: "sidebar-places-symbolic" # sidebar-places-symbolic "inode-directory-symbolic"