include Makefile.inc
PREFIX = .
export TOPDIR=$(CURDIR)

all: includes bison libs server client relay tags

includes:
	cd $(INCDIR); $(MAKE) links

bison:
	@echo "[CONFIG ] /bison++/"
	cd $(PREFIX)/bison++; ./configure &>configure.log
	@echo "[MAKE   ] /bison++/bison++"
	cd $(PREFIX)/bison++; $(MAKE)

parser: 
	cd ClntCfgMgr; $(MAKE) parser
	cd SrvCfgMgr; $(MAKE) parser
	cd RelCfgMgr; $(MAKE) parser

client: $(CLIENTBIN)

$(CLIENTBIN): includes commonlibs clntlibs $(MISC)/DHCPClient.o $(CLIENT)
	@echo "[LINK   ] $(SUBDIR)/$@"
	$(CPP) $(OPTS) $(CLNTLINKOPTS) -o $@ $(MISC)/DHCPClient.o $(CLIENT) \
	-L$(MISC)	  -lMisc \
	-L$(ADDRMGR)      -lAddrMgr \
	-L$(CLNTADDRMGR)  -lClntAddrMgr \
	-L$(LOWLEVEL)    \
	-L$(CLNTOPTIONS)  -lClntOptions \
	-L$(OPTIONS)      -lOptions \
	-L$(CLNTTRANSMGR) -lClntTransMgr \
	-L$(CLNTCFGMGR)   -lClntCfgMgr \
	-L$(CFGMGR)       -lCfgMgr \
	-L$(CLNTIFACEMGR) -lClntIfaceMgr \
	-L$(IFACEMGR)     -lIfaceMgr \
	-L$(CLNTMESSAGES) -lClntMsg \
	                  -lClntAddrMgr \
	                  -lAddrMgr \
	-L$(MISC)         -lMisc \
	-L$(MESSAGES)     -lMsg \
	-lClntOptions -lOptions -lLowLevel $(XMLLIBS) $(EFENCE) 

server: $(SERVERBIN)

$(SERVERBIN): includes commonlibs srvlibs $(MISC)/DHCPServer.o $(SERVER)
	@echo "[LINK   ] $(SUBDIR)/$@"
	$(CPP) $(OPTS) -I $(INCDIR) $(SRVLINKOPTS) -o $@ $(MISC)/DHCPServer.o $(SERVER)  \
	-L$(SRVADDRMGR)   -lSrvAddrMgr \
	-L$(ADDRMGR)      -lAddrMgr \
	-L$(LOWLEVEL)    \
	-L$(SRVOPTIONS)  -lSrvOptions \
	-L$(SRVTRANSMGR) -lSrvTransMgr \
	-L$(SRVCFGMGR)   -lSrvCfgMgr \
	-L$(CFGMGR)      -lCfgMgr\
	-L$(SRVIFACEMGR) -lSrvIfaceMgr \
	-L$(IFACEMGR)     -lIfaceMgr \
	-L$(MISC)        -lMisc\
	-lSrvIfaceMgr -lSrvMsg -lSrvCfgMgr \
	-L$(SRVADDRMGR)  -lSrvAddrMgr \
	                 -lAddrMgr \
	-L$(SRVOPTIONS)  -lSrvOptions \
	-L$(SRVTRANSMGR) -lSrvTransMgr \
	-L$(SRVCFGMGR)   -lSrvCfgMgr \
	-L$(SRVIFACEMGR) -lSrvIfaceMgr \
	-L$(SRVMESSAGES) -lSrvMsg \
	-L$(MESSAGES)    -lMsg \
	-L$(MISC)        -lMisc \
	-L$(OPTIONS)     -lOptions $(XMLLIBS) \
	-L$(LOWLEVEL)    -lLowLevel $(EFENCE) 

relay: $(RELAYBIN)

$(RELAYBIN): includes commonlibs relaylibs $(MISC)/DHCPRelay.o $(RELAY)
	@echo "[LINK   ] $(SUBDIR)/$@"
	$(CPP) $(OPTS) -I $(INCDIR) $(SRVLINKOPTS) -o $@ $(MISC)/DHCPRelay.o $(RELAY)  \
	-L$(RELTRANSMGR) -lRelTransMgr \
	-L$(RELCFGMGR)   -lRelCfgMgr \
	-L$(RELIFACEMGR) -lRelIfaceMgr \
	-L$(RELOPTIONS)  -lRelOptions \
	-L$(RELMESSAGES) -lRelMsg \
	-L$(LOWLEVEL)    -lLowLevel\
	-L$(CFGMGR)      -lCfgMgr\
	-L$(IFACEMGR)     -lIfaceMgr \
	-L$(MISC)        -lMisc\
	-L$(MESSAGES)    -lMsg \
	-L$(MISC)        -lMisc \
	-L$(OPTIONS)     -lOptions \
	-lMisc -lIfaceMgr -lLowLevel -lRelTransMgr -lRelCfgMgr -lRelMsg -lRelOptions -lOptions\
	 $(XMLLIBS) $(EFENCE) 

objs:	includes
	@for dir in $(COMMONSUBDIRS); do \
		( cd $$dir; $(MAKE) objs ) || exit 1; \
	done
	@for dir in $(CLNTSUBDIRS); do \
		( cd $$dir; $(MAKE) objs ) || exit 1; \
	done
	@for dir in $(SRVSUBDIRS); do \
		( cd $$dir; $(MAKE) objs ) || exit 1; \
	done


# === libs ===

libs:	commonlibs clntlibs srvlibs

commonlibs:	includes
	@for dir in $(COMMONSUBDIRS); do \
		( cd $$dir; $(MAKE) libs ) || exit 1; \
	done

clntlibs:	includes
	@for dir in $(CLNTSUBDIRS); do \
		( cd $$dir; $(MAKE) libs ) || exit 1; \
	done

srvlibs:	includes
	@for dir in $(SRVSUBDIRS); do \
		( cd $$dir; $(MAKE) libs ) || exit 1; \
	done

relaylibs:	includes
	@for dir in $(RELSUBDIRS); do \
		( cd $$dir; $(MAKE) libs ) || exit 1; \
	done

doc: 
	cd doc; $(MAKE)

oxygen:
	@echo "[DOXYGEN]"
	doxygen oxygen.cfg >oxygen.log 2>oxygen.err

VERSION-linux:
	echo " Operating system " >  VERSION
	echo "------------------" >> VERSION
	uname -o >> VERSION
	echo >> VERSION

	echo " Version " >> VERSION
	echo "---------" >> VERSION
	echo "$(VERSION)" >> VERSION
	echo >> VERSION

	echo " C++ compiler used " >> VERSION
	echo "-------------------" >> VERSION
	$(CPP) --version >> VERSION
	echo >> VERSION

	echo " C compiler used " >> VERSION
	echo "-----------------" >> VERSION
	$(CC) --version  >>VERSION
	echo >> VERSION

	echo " Date " >> VERSION
	echo "------" >> VERSION
	date +%Y-%m-%d >> VERSION
	echo >> VERSION
#	if [ "$XMLCFLAGS" != "" ]; then
#	    echo "libxml2       : YES" >> VERSION
#	else
#	    echo "libxml2       : NO" >> VERSION
#	fi

VERSION-win:
	echo " Operating system " >  VERSION
	echo "------------------" >> VERSION
	echo " Windows XP/2003"   >> VERSION
	echo >> VERSION

	echo " Version " >> VERSION
	echo "---------" >> VERSION
	echo "$(VERSION)" >> VERSION
	echo >> VERSION

	echo " C++ compiler used " >> VERSION
	echo "-------------------" >> VERSION
	echo "MS Visual C++ 2003 edition" >> VERSION
	echo >> VERSION

	echo " C compiler used " >> VERSION
	echo "-----------------" >> VERSION
	echo "MS Visual C++ 2003 edition" >> VERSION
	echo >> VERSION

	echo " Date " >> VERSION
	echo "------" >> VERSION
	date +%Y-%m-%d >> VERSION
	echo >> VERSION

VERSION-src:
	echo " Version " > VERSION
	echo "---------" >> VERSION
	echo "$(VERSION)" >> VERSION
	echo >> VERSION

	echo " Date " >> VERSION
	echo "------" >> VERSION
	date +%Y-%m-%d >> VERSION
	echo >> VERSION

release:
	echo "Following release targets are available:"
	echo "release-linux - Linux binaries"
	echo "release-win32 - Windows binaries"
	echo "release-src   - Sources"
	echo "release-doc   - Documentation"
	echo "release-deb   - DEB package"
	echo "release-rpm   - RPM package"
	echo "release-all   - all of the above"
	echo
	echo "To make release-win32 work, place dibbler-server.exe and"
	echo "dibbler-client.exe in this directory."

release-linux: VERSION-linux client server doc
	@echo "[TAR/GZ ] dibbler-$(VERSION)-linux.tar.gz"
	tar czvf dibbler-$(VERSION)-linux.tar.gz                        \
		 $(SERVERBIN) $(CLIENTBIN) client*.conf server*.conf    \
		 CHANGELOG RELNOTES LICENSE VERSION doc/dibbler-user.pdf > filelist-linux

release-win32: VERSION-win doc
	@echo "[TAR/GZ ] dibbler-$(VERSION)-win32.tar.gz"
	tar czvf dibbler-$(VERSION)-win32.tar.gz                   \
		 dibbler-server.exe dibbler-client.exe             \
                 client*.conf server*.conf                         \
		 CHANGELOG RELNOTES LICENSE VERSION doc/dibbler-user.pdf > filelist-win32

release-src: VERSION-src 
	@echo "[RM     ] dibbler-$(VERSION)-src.tar.gz"
	rm -f dibbler-$(VERSION)-src.tar.gz
	cd doc; $(MAKE) clean
	if [ -e bison++/Makefile ]; then echo "[CLEAN  ] /bison++"; cd bison++; $(MAKE) clean; fi
	@echo "[TAR/GZ ] ../dibbler-tmp.tar.gz"
	cd ..; tar czvf dibbler-tmp.tar.gz --exclude CVS --exclude '*.exe' --exclude '*.o' \
        --exclude '*.a' --exclude '*.deb' --exclude '*.tar.gz' dibbler > filelist-src
	@echo "[RENAME ] dibbler-$(VERSION)-src.tar.gz"
	mv ../dibbler-tmp.tar.gz dibbler-$(VERSION)-src.tar.gz

release-doc: VERSION-src doc oxygen
	@echo "[TAR/GZ ] dibbler-$(VERSION)-doc.tar.gz"
	tar czvf dibbler-$(VERSION)-doc.tar.gz VERSION RELNOTES LICENSE CHANGELOG \
                 doc/*.pdf doc/html doc/rfc doc/rfc-drafts > filelist-doc

release-gentoo: VERSION-linux
	@echo "[TAR/GZ ] dibbler-tmp.tar.gz"
	cd $(PORTDIR)/gentoo; tar czvf ../../dibbler-tmp.tar.gz --exclude CVS net-misc
	@echo "[RENAME ] dibbler-$(VERSION)-gentoo.tar.gz"
	mv dibbler-tmp.tar.gz dibbler-$(VERSION)-gentoo.tar.gz

release-all: release-src release-linux release-doc release-deb release-rpm release-win32

release-deb: VERSION-linux server client doc
	@echo "[RM     ] dibbler_$(VERSION)_i386.deb"
	rm -f dibbler_$(VERSION)_i386.deb
	@echo "[RM     ] $(PORTDIR)/debian/root"
	rm -rf $(PORTDIR)/debian/root
	@echo "[MKDIR  ] $(PORTDIR)/debian/root"
	$(MKDIR) $(PORTDIR)/debian/root/usr/sbin
	$(MKDIR) $(PORTDIR)/debian/root/usr/share/doc/dibbler
	$(MKDIR) $(PORTDIR)/debian/root/usr/share/man/man8
	$(MKDIR) $(PORTDIR)/debian/root/var/lib/dibbler
	$(MKDIR) $(PORTDIR)/debian/root/DEBIAN
	@echo "[CP     ] $(PORTDIR)/debian/root"
	$(CP) $(PORTDIR)/debian/dibbler-$(VERSION).control $(PORTDIR)/debian/root/DEBIAN/control
	$(CP) $(SERVERBIN) $(PORTDIR)/debian/root/usr/sbin
	$(CP) $(CLIENTBIN) $(PORTDIR)/debian/root/usr/sbin
	$(CP) CHANGELOG $(PORTDIR)/debian/root/usr/share/doc/dibbler/changelog
	$(CP) RELNOTES $(PORTDIR)/debian/root/usr/share/doc/dibbler
	$(CP) VERSION $(PORTDIR)/debian/root/usr/share/doc/dibbler
	$(CP) $(PORTDIR)/debian//copyright $(PORTDIR)/debian/root/usr/share/doc/dibbler
	$(CP) doc/dibbler-user.pdf $(PORTDIR)/debian/root/usr/share/doc/dibbler
	$(CP) doc/man/dibbler-server.8 $(PORTDIR)/debian/root/usr/share/man/man8
	$(CP) doc/man/dibbler-client.8 $(PORTDIR)/debian/root/usr/share/man/man8
	$(CP) *.conf $(PORTDIR)/debian/root/var/lib/dibbler
	@echo "[GZIP   ] $(PORTDIR)/debian/root"
	gzip -9 $(PORTDIR)/debian/root/usr/share/doc/dibbler/changelog
	gzip -9 $(PORTDIR)/debian/root/usr/share/man/man8/dibbler-server.8
	gzip -9 $(PORTDIR)/debian/root/usr/share/man/man8/dibbler-client.8
	@echo "[STRIP  ] $(PORTDIR)/debian/root"
	strip --remove-section=.comment $(PORTDIR)/debian/root/usr/sbin/dibbler-server
	strip --remove-section=.comment $(PORTDIR)/debian/root/usr/sbin/dibbler-client
	@echo "[CHOWN  ] $(PORTDIR)/debian/root"
	chown -R root:root $(PORTDIR)/debian/root/usr
	chown -R root:root $(PORTDIR)/debian/root/var
	@echo "[CHMOD  ] $(PORTDIR)/debian/root"
	find $(PORTDIR)/debian/root/ -type d -exec chmod 755 {} \;
	find $(PORTDIR)/debian/root/ -type f -exec chmod 644 {} \;
	chmod 755 $(PORTDIR)/debian/root/usr/sbin/*
	@echo "[DPKG   ] dibbler_$(VERSION)_i386.deb"
	cd $(PORTDIR)/debian; dpkg-deb --build root 1>dpkg-deb.log
	mv $(PORTDIR)/debian/root.deb dibbler_$(VERSION)_i386.deb
	@echo "[LINTIAN] dibbler_$(VERSION)_i386.deb"
	lintian -i dibbler_$(VERSION)_i386.deb &> $(PORTDIR)/debian/dibbler_$(VERSION)_i386.log

release-rpm: VERSION-linux release-src
	$(MKDIR) $(PORTDIR)/redhat/BUILD
	$(MKDIR) $(PORTDIR)/redhat/RPMS/athlon
	$(MKDIR) $(PORTDIR)/redhat/RPMS/i386
	$(MKDIR) $(PORTDIR)/redhat/RPMS/i486
	$(MKDIR) $(PORTDIR)/redhat/RPMS/i586
	$(MKDIR) $(PORTDIR)/redhat/RPMS/i686
	$(MKDIR) $(PORTDIR)/redhat/RPMS/noarch
	$(MKDIR) $(PORTDIR)/redhat/SOURCES
	$(MKDIR) $(PORTDIR)/redhat/SPECS
	$(MKDIR) $(PORTDIR)/redhat/SRPMS
	@echo "[CP     ] $(PORTDIR)/redhat/SOURCES/dibbler-$(VERSION)-src.tar.gz"
	$(CP) dibbler-$(VERSION)-src.tar.gz $(PORTDIR)/redhat/SOURCES
	@echo "[RPM    ] $(PORTDIR)/redhat/SPEC/dibbler-$(VERSION).spec"
	rpmbuild --define "_topdir `pwd`/$(PORTDIR)/redhat" -bb $(PORTDIR)/redhat/SPECS/dibbler-$(VERSION).spec
	cd $(PORTDIR)/redhat/RPMS/i386; for file in *; do \
	echo "[CP     ] $$file"; \
	$(CP) $$file ../../../.. ; \
	done

install: server client doc
	$(MKDIR) $(INST_WORKDIR)
	@echo "[INSTALL] $(SERVERBIN)"
	$(INSTALL) -m 755 $(SERVERBIN) $(INST_WORKDIR)/
	@echo "[INSTALL] $(CLIENTBIN)"
	$(INSTALL) -m 755 $(CLIENTBIN) $(INST_WORKDIR)/
	@for dir in *.conf; do \
		(echo "[INSTALL] $$dir" && $(INSTALL) -m 644 $$dir $(INST_WORKDIR)) \
	done
	$(MKDIR) $(INST_MANDIR)/man8
	@for dir in doc/man/*.8; do \
		(echo "[INSTALL] $$dir" && $(INSTALL) -m 644 $$dir $(INST_MANDIR)/man8) \
	done
	$(MKDIR) $(INST_DOCDIR)/dibbler
	@echo "[INSTALL] /doc/dibbler-user.pdf"
	$(INSTALL) -m 755 doc/dibbler-user.pdf $(INST_DOCDIR)/dibbler/dibbler-user.pdf
	@echo "[INSTALL] /doc/dibbler-devel.pdf"
	$(INSTALL) -m 755 doc/dibbler-devel.pdf $(INST_DOCDIR)/dibbler/dibbler-devel.pdf
	echo "[LINKS  ] $(SERVERBIN) "
	ln -sf $(INST_WORKDIR)/$(SERVERBIN) $(INST_BINDIR)
	echo "[LINKS  ] $(CLIENTBIN) "
	ln -sf $(INST_WORKDIR)/$(CLIENTBIN) $(INST_BINDIR)


fixme:
	rm -rf FIXME
	find . -name \*.cpp -exec grep -H "FIXME" {} \; | tee FIXME

tags:
	@echo "[TAGS   ]"
	rm -f TAGS
	find . -name '*.cpp' -or -name '*.h' | xargs etags

clean-libs:
	find . -name *.a -exec rm {} \;

links: includes
clobber: clean

.PHONY: release-winxp release-src release-linux release-deb relase-rpm release-all VERSION VERSION-win doc parser
