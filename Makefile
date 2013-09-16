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

OUTPUT_DIR         := realese
SOURCE_CHAPTER_DIR := capitoli
SOURCE_INTRO_DIR   := introduzione 
SETTING_LATEX      := setting-my-thesis.sty

QUIET = @
Q     = $(QUIET)

shell		:= bash
CP		:= cp
PDF_VIEWER      := acroread
MKDIR		:= mkdir -p
MV		:= mv
RM		:= rm -rf
LATEX		:= latex
DVIPS		:= dvips
PSPDF		:= ps2pdf
SETTINGS	:= -o

export RM

#Use as default ps viwer *gv*, you can change it setting by CMD line
#-----------------------------
ifeq "$(PS_VIEWER)"""
PS_VIEWER 	:= gv
endif

# $(call file-existes, file-name)
# Return non-null if a file exists
file-exists = $(wildcard $1)

# $(call latex-compile,source_code)
# Compile the main source code with latex
define latex-compile
 $(LATEX) $1 
 $(LATEX) $1
 $(LATEX) $1
endef

THESIS_PS_OUT  := $(OUTPUT_DIR)/thesis_degree.ps
THESIS_PDF_OUT := $(subst ps,pdf,$(THESIS_PS_OUT))
THESIS_DVI_OUT := $(subst ps,dvi,$(THESIS_PS_OUT))
ALL_SOURCE     := $(wildcard $(SOURCE_CHAPTER_DIR)/*.tex)  \
                  $(wildcard *.tex)                        \
		  $(wildcard $(SOURCE_INTRO_DIR)/*.tex)
MAIN_SOURCE    := thesis_degree.tex

PHONY = all
all : $(THESIS_PS_OUT)

PHONY += pdf
pdf : $(THESIS_PDF_OUT)

PHONY += show_ps
show_ps : $(THESIS_PS_OUT)
	$(PS_VIEWER) $<

PHONY += show_pdf
show_pdf : $(THESIS_PDF_OUT)
	$(PDF_VIEWER) $<

# Generate the pdf file
#
$(THESIS_PDF_OUT): $(THESIS_PS_OUT)

ifeq "$(MAKECMDGOALS)" "pdf"
.INTERMEDIATE: $(THESIS_PS_OUT)
endif

# Generate ps format file
#

$(THESIS_PS_OUT): $(THESIS_DVI_OUT)

# Generate the dvi format file
#

.INTERMEDIATE: $(THESIS_DVI_OUT) 
$(THESIS_DVI_OUT): $(ALL_SOURCE) $(SETTING_LATEX)
	$(call latex-compile,$(MAIN_SOURCE))
	$(MV) $(notdir $@) $(OUTPUT_DIR)
$(SETTING_LATEX):

# %.pdf- Pattern rule to produce pdf output from ps input
%.pdf: %.ps
	$(PSPDF) $< $@

#%.ps- Pattern rule to produce ps output from dvi input
%.ps: %.dvi
	$(DVIPS) $(SETTINGS) $@ $<


# Rule to clean the main dir and all the subdirs.
# We use a recursive make.
#

ifeq "$(MAKECMDGOALS)" "clean"
TARGET		:= clean
clean-dir 	:= $(SOURCE_INTRO_DIR) $(SOURCE_CHAPTER_DIR)
endif


PHONY += $(clean-dir) clean 

clean: $(clean-dir)
	$(RM) $(OUTPUT_DIR) *.aux *.log *~ *.toc
$(clean-dir):
	$(Q)$(MAKE) -C $@ $(TARGET)
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
	@echo ' all		-build the document in postscript format'
	@echo ' show_ps        -build the document in ps format and show it with *evince*'
	@echo ' pdf		-build the document in pdf format'
	@echo ' show_pdf	-build the document in pdf format and show it with *acroread* (the linux program for AdobeReader)'
	@echo ' help		-print this Help Message'
	@echo ''

.PHONY: $(PHONY)