PREFIX ?= /usr

all:
	@echo RUN \'make install\' to install pfetch

install: 
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p pfetch $(DESTDIR)$(PREFIX)/bin
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/pfetch

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/pfetch
