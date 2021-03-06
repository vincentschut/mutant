# ***************************************************************************
#   mutant - MUlti Temporal ANalysis Tool
# 
#   begin			: 2014/06/16
#   copyright		: (c) 2014- by Werner Macho
#   email			: werner.macho@gmail.com
#   based on valuetool
#   copyright		: (C) 2008-2010 by G. Picard
# ***************************************************************************
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ***************************************************************************

# Makefile for a PyQGIS plugin 

PLUGINNAME = mutant

# for building dist zip
TEMPDIR = /tmp

PY_FILES = __init__.py mutant.py mutantwidget.py mutantmap.py

EXTRAS = metadata.txt img/icon.svg img/icon.png

UI_FILES = ui_mutant.py

RESOURCE_FILES = resources_rc.py

default: compile

compile: $(UI_FILES) $(RESOURCE_FILES)
#compile: $(UI_FILES)

%_rc.py : %.qrc
	pyrcc4 -o $*_rc.py  $<

%.py : %.ui
	pyuic4 -o $@ $<

# The deploy  target only works on unix like operating system where
# the Python plugin directory is located at:
# $HOME/.qgis2/python/plugins
deploy: compile
	mkdir -p $(HOME)/.qgis2/python/plugins/$(PLUGINNAME)
	cp -vf $(PY_FILES) $(HOME)/.qgis2/python/plugins/$(PLUGINNAME)
	cp -vf $(UI_FILES) $(HOME)/.qgis2/python/plugins/$(PLUGINNAME)
	cp -vf $(RESOURCE_FILES) $(HOME)/.qgis2/python/plugins/$(PLUGINNAME)
	cp -vrf $(EXTRAS) $(HOME)/.qgis2/python/plugins/$(PLUGINNAME)
	#mkdir -p $(HOME)/.qgis2/python/plugins/$(PLUGINNAME)/docs

#dist: cleandist
#	mkdir -p $(TEMPDIR)/$(PLUGINNAME)
#	cp -r ./*.* $(TEMPDIR)/$(PLUGINNAME)
#	cd $(TEMPDIR); zip -9rv $(PLUGINNAME).zip $(PLUGINNAME)
#	@echo "You can find the plugin for the qgis repo here: $(TEMPDIR)/$(PLUGINNAME).zip"

#cleandist:
#	rm -rf $(TEMPDIR)/$(PLUGINNAME)
#	rm -rf $(PLUGINNAME).zip

# The dclean target removes compiled python files from plugin directory
# also deletes any .svn entry
dclean:
	find $(HOME)/.qgis2/python/plugins/$(PLUGINNAME) -iname "*.pyc" -delete
	find $(HOME)/.qgis2/python/plugins/$(PLUGINNAME) -iname ".svn" -prune -exec rm -Rf {} \;

# The derase deletes deployed plugin
derase:
	rm -Rf $(HOME)/.qgis2/python/plugins/$(PLUGINNAME)

# The zip target deploys the plugin and creates a zip file with the deployed
# content. You can then upload the zip file on http://plugins.qgis.org
zip: deploy dclean 
	rm -f $(PLUGINNAME).zip
	cd $(HOME)/.qgis2/python/plugins; zip -9r $(CURDIR)/$(PLUGINNAME).zip $(PLUGINNAME)

# Create a zip package of the plugin named $(PLUGINNAME).zip. 
# This requires use of git (your plugin development directory must be a 
# git repository).
# To use, pass a valid commit or tag as follows:
#   make package VERSION=Version_0.3.2
package: compile
		rm -f $(PLUGINNAME).zip
		git archive --prefix=$(PLUGINNAME)/ -o $(PLUGINNAME).zip $(VERSION)
		echo "Created package: $(PLUGINNAME).zip"

upload: zip
	$(PLUGIN_UPLOAD) $(PLUGINNAME).zip

# transup
# update .ts translation files
transup:
	pylupdate4 Makefile

# transcompile
# compile translation files into .qm binary format
transcompile: $(TRANSLATIONS:.ts=.qm)

# transclean
# deletes all .qm files
transclean:
	rm -f i18n/*.qm

clean:
	rm $(UI_FILES) $(RESOURCE_FILES)

# build documentation with sphinx
doc: 
	cd help; make html