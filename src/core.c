void *malloc(size_t);
char* strcat(char*,const char*);
FILE* fopen(const char*,const char*);

#define YONA_FILE ".yona"

void get_config_file() {
    char* config_path = malloc(50);
    *config_path = '\0';
    strcat(config_path,getenv("HOME"));
    strcat(config_path,"/.config/yona/yona.toml");
    const FILE* CONFIG = fopen(config_path,"r");
}

void create_yona_file() {}

void list_project_commands() {}

void project_command(char** cmd,int use_shell) {}

void run_file(char* filepath) {}

void compile_file(char* filepath) {}

