BINARY_DIR=$(HOME)/.local/bin
ifeq ($(XDG_CONFIG_DIR),)
	XDG_CONFIG_DIR=$(HOME)/.config
endif
install:
	mkdir -p $(BINARY_DIR)
	cp ./yona $(BINARY_DIR)
	mkdir -p $(XDG_CONFIG_DIR)/yona
	cp -n ./config/* -t $(XDG_CONFIG_DIR)/yona
uninstall:
	rm $(BINARY_DIR)/yona
