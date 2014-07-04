#
# Makefile to compile my thesis. 
#     Recursive Makefile
#
# The primary target are :
#
# <default>		Generate ps
# swoh_ps\		Generate and show ps
# show_pdf		Generate and show pdf
# pdf			Generate pdf
# clean			Clean up generated files by latex
#
# Author := dmike
# Email  := cipmiky@gmail.com
#

# Do not:
#* use make's built-in rules and variables;
#* print "Entering directory"
MAKEFLAGS += -rR --no-print-directory

# That's the default target
PHONY := _all
_all:

#Delete implicit rules on top Makefile
$(CURDIR)/Makefile Makefile: ;

PHONY += all
_all: all

OUTPUT_DIR         := realese
SOURCE_CHAPTER_DIR := capitoli
SOURCE_INTRO_DIR   := introduzione 
SOURCE_BIB_DIR     := bibliography
SOURCE_CONCLUSIONS := conclusione
SETTING_LATEX      := setting-my-thesis.sty

quiet = quiet_
Q     = @

#Look for make include files relative to root of the project
MAKEFLAGS += --include-dir=$(CURDIR)

# Include some basic definition.
Kbuild.include: ;
include Kbuild.include

shell		:= bash
CP		:= cp
MKDIR		:= mkdir -p
MV		:= mv
RM		:= rm -rf
LATEX		:= pdflatex
BIB		:= biber
DVIPS		:= dvips
PSPDF		:= ps2pdf
SETTINGS	:= -o

#Use as default ps viwer *gv*, you can change it setting by CMD line
#-----------------------------
ifeq "$(PS_VIEWER)" ""
ifeq "$(call file-exists, /usr/bin/gv)" ""
PS_VIEWER	:= evince
else
PS_VIEWER 	:= gv
endif
endif

#Use as default pdf viwer *evince*, you can change it setting by CMD line
#-----------------------------
ifeq "$(PDF_VIEWER)" ""
ifneq "$(call file-exists, /usr/bin/evince)" ""
PDF_VIEWER      := evince
else ifneq "$(call file-exists, /usr/bin/acroread)" ""
PDF_VIEWER	:= acroread
else
PDF_VIEWER	:= ghostscipt
endif
endif

THESIS_BIB_OUT := thesis_degree.bcf
THESIS_PS_OUT  := $(OUTPUT_DIR)/thesis_degree.ps
THESIS_PDF_OUT := $(subst ps,pdf,$(THESIS_PS_OUT))
THESIS_DVI_OUT := $(subst ps,dvi,$(THESIS_PS_OUT))
ALL_SOURCE     := $(wildcard $(SOURCE_CHAPTER_DIR)/*.tex)  \
                  $(wildcard *.tex)                        \
		  $(wildcard $(SOURCE_INTRO_DIR)/*.tex)    \
                  $(wildcard $(SOURCE_CONCLUSIONS)/*.tex)  \
		  $(wildcard $(SOURCE_BIB_DIR)/*.bib)
BIB_SOURCE     := $(wildcard $(SOURCE_BIB_DIR)/*.bib)
MAIN_SOURCE    := thesis_degree.tex

# Using the latex compiler
ifeq "$(LATEX)" "latex"

# Primary target dependecies
all : $(THESIS_PS_OUT)

#PDF-OUTPUT
PHONY += pdf
pdf : $(THESIS_PDF_OUT)

#Build and show ps output
PHONY += show_ps
show_ps : $(THESIS_PS_OUT)
	$(PS_VIEWER) $<

ifeq "$(MAKECMDGOALS)" "pdf"
.INTERMEDIATE: $(THESIS_PS_OUT)
endif

# Generate the pdf file
#
$(THESIS_PDF_OUT): $(THESIS_PS_OUT)


# Generate ps format file
#

$(THESIS_PS_OUT): $(THESIS_DVI_OUT)

# Generate the dvi format file
#

.INTERMEDIATE: $(THESIS_DVI_OUT) 
$(THESIS_DVI_OUT): $(THESIS_BIB_OUT) $(ALL_SOURCE) $(SETTING_LATEX)
	$(call latex-compile,$(MAIN_SOURCE))
	$(MV) $(notdir $@) $(OUTPUT_DIR)
endif

#Using the pdflatex compiler
ifeq "$(LATEX)" "pdflatex"
# Primary target dependecies
all : $(THESIS_PDF_OUT)

$(THESIS_PDF_OUT):  $(THESIS_BIB_OUT) $(ALL_SOURCE) $(SETTING_LATEX)
	$(call latex-compile,$(MAIN_SOURCE))
	$(MV) $(notdir $@) $(OUTPUT_DIR)
endif

$(THESIS_BIB_OUT): $(BIB_SOURCE)
	$(call latex-biber-compile,$(MAIN_SOURCE),$@)
$(SETTING_LATEX):
#Build and show pdf output
PHONY += show_pdf
show_pdf : $(THESIS_PDF_OUT)
	$(PDF_VIEWER) $<


# %.pdf- Pattern rule to produce pdf output from ps input
%.pdf: %.ps
	$(PSPDF) $< $@

#%.ps- Pattern rule to produce ps output from dvi input
%.ps: %.dvi
	$(DVIPS) $(SETTINGS) $@ $<


# Rule to clean the main dir and all the subdirs.
#
#

Makefile.clean: ;
include Makefile.clean

PHONY += clean

clean: 
	$(call cmd,rmfiles)
	$(call cmd,rmdirs)


#
# Create output dir if it doesn't exist.
#
ifneq "$(MAKECMDGOALS)" "clean"
_create-out-dir :=    \
	$(if $(call file-exists,  \
	$(OUTPUT_DIR)),, \
	$(shell $(MKDIR) $(OUTPUT_DIR)))
endif

#Brief documentation of the typical target used
#---------------------------------------------------------------

PHONY += help
help:
	@echo ' Cleaning targets:'
	@echo ' clean		-Remove all the files in the current dir and in the subdirs except the source files and remove the outputfile too'
	@echo ''
	@echo ' Other generics targets:'
	@echo ' all		-build the document in pdf format using pdflatex'
	@echo ' show_ps        -build the document in ps format and show it with *evince*'
	@echo ' pdf		-build the document in pdf format'
	@echo ' show_pdf	-build the document in pdf format and show it with *acroread* (the linux program for AdobeReader)'
	@echo ' help		-print this Help Message'
	@echo ''

#--------------------------------------------------------------------
quiet_cmd_rmdirs = $(if $(wildcard $(rm-dirs)),CLEAN   $(wildcard $(rm-dirs)))
      cmd_rmdirs = $(RM) $(rm-dirs)

quiet_cmd_rmfiles = $(if $(wildcard $(rm-files)),CLEAN   $(wildcard $(rm-files)))
      cmd_rmfiles = $(RM) $(rm-files)

.PHONY: $(PHONY)
