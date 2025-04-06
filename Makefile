yona: *.bash
	echo -e '#!/bin/env bash\n' > yona
	cat \
		task_runners.bash \
		run.bash \
		compile.bash \
		yona.bash \
		>> yona
	chmod +x yona
build: yona
test: yona
	bash test.bash

BINARY_DIR=$(HOME)/.local/bin
install:
	mkdir -p $(BINARY_DIR)
	cp ./yona $(BINARY_DIR)
uninstall:
	rm $(BINARY_DIR)/yona
