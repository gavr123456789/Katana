public class DirectoryMenu {
    DirectoryNavigator dir_navigator = new DirectoryNavigator();
    public void run(){
        string answer = "";
        dir_navigator.print();
        prin(0, ". exit");
        prin(-1, ". back");
        
        while (answer != "0"){
            answer = (!)stdin.read_line();
            switch (answer) {
                //  case "-1": dir_navigator.go_back(); break;
                case "1":{
                    prin("enter dir name");
                    string dir_name_answer = (!)stdin.read_line();
                    dir_navigator.folder_helper.create_folder(dir_navigator.path, dir_name_answer);
                    dir_navigator.update();
                } break;
                
                case "0": break;

                //  default: dir_navigator.goto(answer); break;
            }
         
            dir_navigator.print();
            prin(1, ". create dir");
            prin(2, ". create file");
            prin(0, ". exit");
            prin(-1, ". back");
        }
    }


 
}