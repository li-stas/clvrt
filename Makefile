
ifdef CLIPROOT
include $(CLIPROOT)/include/Makefile.inc
endif
CLIP	= $(CLIPROOT)/bin/clip
CLIPFLAGS = -a -O -l 
CLIPLIBS  = -lclip-xml
OBJS  = main.o clvrt.o bindx.o cdocopt.o crdocopt.o csdoc.o\
	first.o libfcn.o pere.o slctn.o tost.o slct.o rso.o s_soper.o\
	dokkkta.o crbsdokk.o crdkkln.o s_dkkln.o fpodg.o \
	mkotchn.o mkotch.o mkotchd.o slavut.o rszga.o\
	ppc.o kpkload.o rszg.o sdrc.o sklprv.o nost.o protv.o\
	smtp_obj.o ftoken.o\
	libdbf.o rslib.o scen.o libfcne.o sbarost.o\
	rmsdrc.o rmsd0.o rmsd1.o rmrc0.o rmrc1.o maska.o\
	obol.o \
	jaffa.o jaffarpt.o zdocall.o mcrdbc.o vid.o edin.o\
	\
	maine.o pfakt.o pprh.o paotv.o praotv.o pro.o\
	\
	corauto.o autodoc.o corvt.o deb.o debn.o debn03.o rsdogzen.o rs2zen.o


#rddsys.o lpos.o lposd.o\

.SUFFIXES: .prg .o

all:    $(OBJS) 
	$(CLIP) -e -s $(OBJS) $(CLIPLIBS)
#	$(CLIP) -e --static $(OBJS) $(CLIPLIBS)
	cp main app_clvrt
	rm main

clean:
	rm -fr *.o *.c *.a *.so *.b *.BAK *.bak *~ core* *.ex *.nm

copy:
	./cp_clvrt

install:
	rm -f /usr/local/sbin/app_clvrt
	cp ./app_clvrt /usr/local/sbin/app_clvrt

.prg.o:
	$(CLIP) $(CLIPFLAGS) $<

.prg.po:
	$(CLIP) $(CLIPFLAGS) -p $<

