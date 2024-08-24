#include "core.c"

int strcmp(const char*,const char*);

int main(int argc, char** argv) {
    if(strcmp(*argv,"init") == 0) {
        create_yona_file();
    } else if(strcmp(*argv,"list") == 0) {
        list_project_commands();
    } else if(strcmp(*argv,"-h") == 0 || strcmp(*argv,"--shell") == 0) {
        project_command(argv+1,1);
    } else if(strcmp(*argv,"-s") == 0 || 
            strcmp(*argv,"--single-file") == 0) {
        if(strcmp(*(argv+1),"run") == 0) {
            run_file(*(argv+2));
        } else if(strcmp(*(argv+1),"compile") == 0) {
            compile_file(*(argv+2));
        }
    } else {
        project_command(argv+1,0);
    }
}
