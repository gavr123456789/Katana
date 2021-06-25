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
      of ".png": "folder-picture-symbolic"
      of ".mp3", ".wav": "deepin-music-player-symbolic"
      of ".mp4": "camera-symbolic"
      of ".gif": "avidemux_icon-symbolic"
      
      else: "folder-documents-symbolic"


func getFolderIconFromName*(folderName: string): string = 
  result = case folderName:
      of "Games": "gamepad-symbolic"
      of "Apps": "applications-java-symbolic"
      of "Projects": "applications-python-symbolic"
      of "Programs": "nvim-symbolic"
      of "Plugins": "puzzle-piece-symbolic"
      of ".git": "git-cola-symbolic"
      of "Telegram": "mail-send-symbolic"
      of "node_modules": "folder-nodejs-symbolic"
      
      else: "sidebar-places-symbolic" # sidebar-places-symbolic "inode-directory-symbolic"