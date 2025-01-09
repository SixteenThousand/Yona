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

yona.1.gz: README.md
	# make light edits of the readme to make it a manual,
	# then convert to roff format for man,
	# and finally gzip the man page as that's just the done thing
	sed 's/\(^# Yona$\)/\1(1)/;/^<!-- exclude everything after this point/,//d' README.md \
		| pandoc --to=man -s --shift-heading-level-by=-1 \
		| gzip -c - > yona.1.gz
build: yona.1.gz
