install:
	sudo cp ./yona /usr/bin
	sudo cp ./ysh /usr/bin
	# the '|| :' prevents make from saying there was an error
	cp -n ./config/* -t $${XDG_CONFIG_DIR:-$(HOME)/.config}/yona || :
uninstall:
	sudo rm /usr/bin/yona /usr/bin/ysh