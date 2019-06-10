#
# xbs-compatible Makefile for bzip2.
#

Project             = bzip2
GnuNoConfigure      = YES
Extra_CC_Flags      = -no-cpp-precomp -D_FILE_OFFSET_BITS=64
Extra_Install_Flags = PREFIX=$(RC_Install_Prefix)
GnuAfterInstall     = strip-binaries fix-manpages install-plist

install:: shadow_source

include $(MAKEFILEPATH)/CoreOS/ReleaseControl/GNUSource.make

Install_Target      = install

strip-binaries:
	$(STRIP) -x $(DSTROOT)/usr/bin/bunzip2
	$(STRIP) -x $(DSTROOT)/usr/bin/bzcat
	$(STRIP) -x $(DSTROOT)/usr/bin/bzip2recover
	$(STRIP) -x $(DSTROOT)/usr/bin/bzip2
	$(STRIP) -x $(DSTROOT)/usr/local/lib/libbz2.a
	$(STRIP) -x $(DSTROOT)/usr/lib/libbz2.1.0.dylib

fix-manpages:
	$(MKDIR) $(DSTROOT)/usr/share
	$(MV) $(DSTROOT)/usr/man $(DSTROOT)/usr/share
	$(LN) $(DSTROOT)/usr/share/man/man1/bzip2.1 $(DSTROOT)/usr/share/man/man1/bunzip2.1
	$(LN) $(DSTROOT)/usr/share/man/man1/bzip2.1 $(DSTROOT)/usr/share/man/man1/bzcat.1
	$(LN) $(DSTROOT)/usr/share/man/man1/bzip2.1 $(DSTROOT)/usr/share/man/man1/bzip2recover.1

OSV	= $(DSTROOT)/usr/local/OpenSourceVersions
OSL	= $(DSTROOT)/usr/local/OpenSourceLicenses

install-plist:
	$(MKDIR) $(OSV)
	$(INSTALL_FILE) $(SRCROOT)/$(Project).plist $(OSV)/$(Project).plist
	$(MKDIR) $(OSL)
	$(INSTALL_FILE) $(Sources)/LICENSE $(OSL)/$(Project).txt

# Automatic Extract & Patch
AEP            = YES
AEP_Project    = $(Project)
AEP_Version    = 1.0.2
AEP_ProjVers   = $(AEP_Project)-$(AEP_Version)
AEP_Filename   = $(AEP_ProjVers).tar.gz
AEP_ExtractDir = $(AEP_ProjVers)
AEP_Patches    = bzdiff.diff EA.diff dylib.diff

ifeq ($(suffix $(AEP_Filename)),.bz2)
AEP_ExtractOption = j
else
AEP_ExtractOption = z
endif

# Extract the source.
install_source::
ifeq ($(AEP),YES)
	$(TAR) -C $(SRCROOT) -$(AEP_ExtractOption)xf $(SRCROOT)/$(AEP_Filename)
	$(RMDIR) $(SRCROOT)/$(AEP_Project)
	$(MV) $(SRCROOT)/$(AEP_ExtractDir) $(SRCROOT)/$(AEP_Project)
	for patchfile in $(AEP_Patches); do \
		cd $(SRCROOT)/$(Project) && patch -p0 < $(SRCROOT)/patches/$$patchfile; \
	done
endif
