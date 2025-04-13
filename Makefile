yona: *.bash
	m4 --prefix-builtins yona.bash > yona
	chmod +x yona
build: yona
test: yona
	bash --noprofile --norc test.bash

BINARY_DIR=$(HOME)/.local/bin
install:
	mkdir -p $(BINARY_DIR)
	cp ./yona $(BINARY_DIR)
uninstall:
	rm $(BINARY_DIR)/yona
