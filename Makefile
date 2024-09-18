build:
	cp ./yona $(HOME)/path-extras
install:
	cp ./yona /usr/bin/yona
	cp ./config/* -t $${XDG_CONFIG_DIR:-$(HOME)/.config}/yona
