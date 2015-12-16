#
SRC=Common/Source
DEV=Common/Source/Devices
DLG=Common/Source/Dialogs
LIB=Common/Source/Library
DRW=Common/Source/Draw
MAP=Common/Source/MapDraw
TOP=Common/Source/Topology
SHP=Common/Source/Topology/shapelib
TER=Common/Source/Terrain
NTR=Common/Source/LKInterface
CLC=Common/Source/Calc
TSK=Common/Source/Calc/Task
CMM=Common/Source/Comm
WPT=Common/Source/Waypoints
RSC=Common/Source/Resources
HDR=Common/Header
SRC_SCREEN=$(SRC)/Screen
SRC_WINDOW=$(SRC)/Window


BIN=Bin/$(TARGET)

# enable/disable heap checking (dmalloc.h libdmalloc.a must be in ../dmalloc)
DMALLOC=n

OPTIMIZE    := -O2
PROFILE	    :=
REMOVE_NS   := y

ifeq ($(DEBUG),y)
 OPTIMIZE  := -O0
 OPTIMIZE  += -g3 -ggdb
 REMOVE_NS :=
 BIN       :=Bin/$(TARGET)_debug
endif

ifeq ($(GPROF),y)
 PROFILE   := -pg
 REMOVE_NS :=
endif

# CONFIG_WIN32 = y for all windows target
CONFIG_WIN32    :=n
CONFIG_PPC2002	:=n
CONFIG_PPC2003	:=n
CONFIG_PC	:=n
CONFIG_WINE	:=n
CONFIG_PNA	:=n
CONFIG_LINUX	:=n
CONFIG_ANDROID	:=n
MINIMAL		:=n
XSCALE		:=n
GTARGET		:=$(TARGET)
	
ifeq ($(TARGET),PPC2002)
  CONFIG_PPC2002 :=y
  CONFIG_WIN32   :=y
endif

ifeq ($(TARGET),PPC2003)
  CONFIG_PPC2003 :=y
  CONFIG_WIN32   :=y
endif

ifeq ($(TARGET),PPC2003X)
  CONFIG_PPC2003 :=y
  XSCALE         :=y
  GTARGET        :=PPC2003
  CONFIG_WIN32   :=y
endif

ifeq ($(TARGET),PC)
  CONFIG_PC      :=y
  CONFIG_WIN32   :=y
endif

ifeq ($(TARGET),PCX64)
  CONFIG_PC    :=y
  CONFIG_WIN32 :=y
endif

ifeq ($(TARGET),WINE)
  CONFIG_WINE  :=y
  CONFIG_WIN32 :=y
endif

ifeq ($(TARGET),PNA)
  CONFIG_PNA     :=y
  CONFIG_PPC2003 :=y
  CONFIG_WIN32   :=y
endif

ifeq ($(TARGET),LINUX)
  CONFIG_LINUX   :=y
  CONFIG_ANDROID :=n
  MINIMAL        :=n
endif

ifeq ($(TARGET),KOBO)
  KOBO ?= /opt/kobo/arm-unknown-linux-gnueabi
  TARGET_IS_KOBO :=y
  CONFIG_LINUX   :=y
  CONFIG_ANDROID :=n
  MINIMAL        :=n
endif

include build/pkgconfig.mk
############# build and CPU info

ifeq ($(CONFIG_PC)$(TARGET),yPCX64)
 TCPATH :=x86_64-w64-mingw32-
 CPU    :=
 MCPU   :=
else ifeq ($(CONFIG_PC),y)
 TCPATH :=i686-w64-mingw32-
 CPU    :=i586
 MCPU   := -mcpu=$(CPU)
else ifeq ($(CONFIG_WINE),y)
 TCPATH	:=wine
 CPU    :=i586
 MCPU   := -mcpu=$(CPU)
else ifeq ($(TARGET_IS_KOBO),y)
 TCPATH := arm-unknown-linux-gnueabi-
 MCPU   := -march=armv7-a -mfpu=neon -mfloat-abi=hard -ftree-vectorize
else ifeq ($(CONFIG_LINUX),y)
 TCPATH :=
else
 TCPATH	:=arm-mingw32ce-
endif

ifeq ($(XSCALE),y)
 CPU    :=xscale
 MCPU   := -mcpu=$(CPU)
endif

ifeq ($(TARGET),PNA)
 CPU    :=arm1136j-s
 MCPU	:=
endif

ifeq ($(CONFIG_PPC2002),y)
 CPU    :=strongarm1110
 MCPU   := -mcpu=$(CPU)
endif

-include local.mk

############# platform info

ifeq ($(CONFIG_PPC2002),y)
 CE_MAJOR	:=3
 CE_MINOR	:=00
 CE_PLATFORM	:=310
 TARGET		:=PPC2002
 PCPU		:=ARM
endif

ifeq ($(CONFIG_PPC2003),y)
 CE_MAJOR	:=4
 CE_MINOR	:=00
 CE_PLATFORM	:=400
 PCPU		:=ARMV4
endif

ifeq ($(CONFIG_PNA),y)
# armv4i
 CE_MAJOR	:=5
 CE_MINOR	:=00
 CE_PLATFORM	:=500
endif

ifeq ($(CONFIG_PC),y)
 CE_MAJOR	:=5
 CE_MINOR	:=00
 CE_PLATFORM	:=500
 TARGET		:=PC
endif

ifeq ($(CONFIG_WINE),y)
 CE_MAJOR	:=5
 CE_MINOR	:=00
 CE_PLATFORM	:=500
 TARGET		:=WINE
 CONFIG_PC	:=y
endif

######## tools

EXE		:=$(findstring .exe,$(MAKE))
AR		:=$(TCPATH)ar$(EXE)
AS		:=$(TCPATH)as$(EXE)
CXX		:=$(TCPATH)g++$(EXE)
CC		:=$(TCPATH)gcc$(EXE)
SIZE		:=$(TCPATH)size$(EXE)
STRIP		:=$(TCPATH)strip$(EXE)
WINDRES		:=$(TCPATH)windres$(EXE)
LD		:=$(TCPATH)ld$(EXE)
OBJCOPY		:=$(TCPATH)objcopy$(EXE)
SYNCE_PCP	:=synce-pcp
SYNCE_PRM	:=synce-prm
CE_VERSION	:=0x0$(CE_MAJOR)$(CE_MINOR)
ARFLAGS		:=r
MKDIR           :=mkdir -p
FIND            :=find
ETAGS           :=etags
EBROWSE         :=ebrowse

GCCVERSION = $(shell $(CXX) --version | grep ^$(TCPATH) | sed 's/^.* //g')

$(info GCC VERSION : $(GCCVERSION))

######## output files
ifeq ($(CONFIG_LINUX),y)
 SUFFIX :=
else
 SUFFIX :=.exe
endif

ifeq ($(DEBUG),y)
 OUTPUTS 	:= LK8000-$(TARGET)_debug$(SUFFIX)
 OUTPUTS_NS	:= LK8000-$(TARGET)_debug-ns$(SUFFIX)
else
 OUTPUTS 	:= LK8000-$(TARGET)$(SUFFIX)
 OUTPUTS_NS	:= LK8000-$(TARGET)-ns$(SUFFIX)
endif

CE_DEFS :=

######## target depends definitions
ifeq ($(TARGET_IS_KOBO),y)
 USE_SDL   :=n
 GLES2     :=n
 GREYSCALE :=y
 DITHER    :=y
 OPENGL    :=n
 USE_SOUND_EXTDEV := y
 CE_DEFS += -DKOBO
 CE_DEFS += -DUSE_MEMORY_CANVAS
endif

ifeq ($(CONFIG_LINUX),y)
 CE_DEFS += -D__linux__
 CE_DEFS += -DHAVE_POSIX
 CE_DEFS += -D__STDC_FORMAT_MACROS

 GREYSCALE ?= n
 USE_SOUND_EXTDEV ?= n

# by default use OpenGL if available
 OPENGL  ?=$(shell $(PKG_CONFIG) --exists gl && echo y)

 ifneq ($(OPENGL),y)
 #no OpenGL or explicitly disabled,
  GLES2   ?=n
  GLES    ?=n
  USE_X11 ?=n
 endif

 ifeq ($(GLES2),y)
  GLES    :=n
  $(eval $(call pkg-config-library,GLES2,glesv2))
 endif

 ifeq ($(GLES),y)
  $(eval $(call pkg-config-library,GLES,glesv1_cm))
 endif

 GLES2 ?=n
 GLES ?=n

 ifeq ($(OPENGL)$(GLES2)$(GLES), ynn)
  $(eval $(call pkg-config-library,GL,gl))
 endif

 ifneq ($(USE_SDL),y)
  ifeq ($(OPENGL),y)
   USE_EGL ?= $(shell $(PKG_CONFIG) --exists egl && echo y)
  endif
 endif

 ifeq ($(OPENGL)$(USE_EGL),yy)
  $(eval $(call pkg-config-library,EGL,egl))
  USE_X11 ?= $(shell $(PKG_CONFIG) --exists x11 && echo y)
  USE_SDL ?=n
 endif

 ifeq ($(USE_WAYLAND),y)
  $(eval $(call pkg-config-library,WAYLAND,wayland-client))
  CE_DEFS += $(WAYLAND_CPPFLAGS) -DUSE_WAYLAND
  WAYLAND_LDLIBS += -lwayland-egl
  # no X11 if wayland enabled
  USE_X11 :=n
  USE_SDL :=n
 endif

 ifeq ($(USE_X11), y)
  $(eval $(call pkg-config-library,X11,x11))
  CE_DEFS += $(X11_CPPFLAGS) -DUSE_X11
 endif

# Use SDL if not explicitly disabled or disabled by another FLAG ... 
 USE_SDL ?=y

 ifeq ($(USE_SDL),y)
  CE_DEFS += -DENABLE_SDL
    
  # check if libSDL2 exist
  USE_SDL2 ?= $(shell $(PKG_CONFIG) --exists sdl2 && echo y)
  ifeq ($(USE_SDL2),y)
   # if libSDL2 exist check for libSDL2_mixer
   USE_SDL2 = $(shell $(PKG_CONFIG) --exists SDL2_mixer && echo y)
  endif

  ifeq ($(USE_SDL2),y)
   # use libSDL2 & libSDL2_mixer if exist

   $(eval $(call pkg-config-library,SDL,sdl2))
   $(eval $(call pkg-config-library,SDL_MIXER,SDL2_mixer))
  else
   # otherwise use libSDL1.2 & libSDL1.2_mixer

   $(eval $(call pkg-config-library,SDL,sdl))
   $(eval $(call pkg-config-library,SDL_MIXER,SDL_mixer))
  endif

  CE_DEFS += $(patsubst -I%,-isystem %,$(SDL_CPPFLAGS))
  CE_DEFS += $(patsubst -I%,-isystem %,$(SDL_MIXER_CPPFLAGS))

 else
  CE_DEFS += -DUSE_POLL_EVENT

  ifeq ($(USE_EGL),y)
   CE_DEFS += -DUSE_EGL
  else
   CE_DEFS += -DUSE_FB
   CE_DEFS += -DUSE_LINUX_INPUT
  endif

  SNDFILE := $(shell $(PKG_CONFIG) --exists sndfile && echo y)
  ALSA := $(shell $(PKG_CONFIG) --exists alsa && echo y)
 endif

 ifeq ($(OPENGL),y)
  CE_DEFS += -DENABLE_OPENGL
  CE_DEFS += -DGL_GLEXT_PROTOTYPES

  ifeq ($(GLES),y)
   CE_DEFS += -DHAVE_GLES
   CE_DEFS += $(patsubst -I%,-isystem %,$(GLES_CPPFLAGS))
  endif

  ifeq ($(GLES2),y)
   CE_DEFS += -DHAVE_GLES -DHAVE_GLES2 -DUSE_GLSL
   CE_DEFS += $(patsubst -I%,-isystem %,$(GLES2_CPPFLAGS))
  endif
 else
  CE_DEFS += -DUSE_MEMORY_CANVAS
 endif

 ifeq ($(GREYSCALE),y)
  CE_DEFS += -DGREYSCALE
 endif

 ifeq ($(DITHER),y)
  CE_DEFS += -DDITHER
 endif

 ifeq ($(SNDFILE)$(ALSA),yy)
  CE_DEFS += -DUSE_ALSA

  $(eval $(call pkg-config-library,SNDFILE,sndfile))
  CE_DEFS += $(patsubst -I%,-isystem %,$(SNDFILE_CPPFLAGS))
  
  $(eval $(call pkg-config-library,ALSA,alsa))
  CE_DEFS += $(patsubst -I%,-isystem %,$(ALSA_CPPFLAGS))

 endif

 $(eval $(call pkg-config-library,ZZIP,zziplib))
 CE_DEFS += $(patsubst -I%,-isystem %,$(ZZIP_CPPFLAGS))

 $(eval $(call pkg-config-library,ZLIB,zlib))
 CE_DEFS += $(patsubst -I%,-isystem %,$(ZLIB_CPPFLAGS))

 $(eval $(call pkg-config-library,FREETYPE,freetype2))
 CE_DEFS += $(patsubst -I%,-isystem %,$(FREETYPE_CPPFLAGS))
 CE_DEFS += -DUSE_FREETYPE

 $(eval $(call pkg-config-library,PNG,libpng))
 CE_DEFS += $(patsubst -I%,-isystem %,$(PNG_CPPFLAGS))
endif

ifeq ($(CONFIG_WIN32),y)
 CE_DEFS += -DUSE_GDI
 #all win32 Targe are unicode
 CE_DEFS += -DUNICODE -D_UNICODE

 ifeq ($(CONFIG_PC),y)
  CE_DEFS +=-D_WIN32_WINDOWS=$(CE_VERSION) -DWINVER=$(CE_VERSION)
  CE_DEFS +=-D_WIN32_IE=$(CE_VERSION) -DWINDOWSPC=1 -DMSOFT
 else
  CE_DEFS +=-D_WIN32_WCE=$(CE_VERSION) -D_WIN32_IE=$(CE_VERSION)
  CE_DEFS +=-DWIN32_PLATFORM_PSPC=$(CE_PLATFORM) -DMSOFT
  # UNIX like ressource don't work on CE5.
  WIN32_RESOURCE := y
 endif

 ifeq ($(WIN32_RESOURCE), y)
  CE_DEFS +=-DWIN32_RESOURCE
 endif
endif

ifeq ($(CONFIG_PPC2002),y)
 CE_DEFS +=-DPPC2002=1
endif
ifeq ($(CONFIG_PPC2003),y)
 CE_DEFS +=-DPPC2003=1
endif

CE_DEFS	 += -DPOCO_NO_UNWINDOWS

ifeq ($(FULLSCREEN),y)
CE_DEFS		+= -DUSE_FULLSCREEN
endif

######## paths
ifeq ($(CONFIG_LINUX),y)
 INCLUDES	:= -I$(HDR)/linuxcompat -I$(HDR) -I$(SRC)
else
 INCLUDES	:= -I$(HDR)/mingw32compat -I$(HDR) -I$(SRC)
endif

INCLUDES	+=  -I$(SRC)/xcs

######## compiler flags

CPPFLAGS	:= $(INCLUDES) $(CE_DEFS)
ifneq ($(DEBUG),y)
 CPPFLAGS	+= -DNDEBUG
endif
#
# LX MINIMAP CUSTOM VERSION
#
#CPPFLAGS	+= -DLXMINIMAP
#
#

#CPPFLAGS	+= -Wchar-subscripts -Wformat -Winit-self -Wimplicit -Wmissing-braces -Wparentheses -Wreturn-type
CPPFLAGS	+= -Wunused-label -Wunused-variable -Wunused-value -Wuninitialized

CPPFLAGS	+= -Wall -Wno-char-subscripts
#CPPFLAGS	+= -Wall -Wno-char-subscripts -Wignored-qualifiers -Wunsafe-loop-optimizations 
#CPPFLAGS	+= -Winit-self -Wswitch -Wcast-qual -Wcast-align
#CPPFLAGS	+= -Wall -Wno-non-virtual-dtor
#CPPFLAGS	+= -Wno-char-subscripts -Wno-switch

#CPPFLAGS	+= -Wshadow
#CPPFLAGS	+= -Wsign-compare -Wsign-conversion

ifeq ($(CONFIG_PNA),y)
 CPPFLAGS	+= -DCECORE -DPNA
endif

ifeq ($(CONFIG_PC),y)
 CPPFLAGS	+= -D_WINDOWS -DWIN32 -DCECORE $(UNICODE)

GCC_GTEQ_480 := $(shell expr `gcc -dumpversion | sed -e 's/\.\([0-9][0-9]\)/\1/g' -e 's/\.\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$$/&00/'` \>= 40800)
ifeq ($(GCC_GTEQ_480),1)
    CPPFLAGS	+= -D_CRT_NON_CONFORMING_SWPRINTFS
 endif
endif

ifeq ($(DMALLOC),y)
 CPPFLAGS += -DHC_DMALLOC
endif

CPPFLAGS += -DPOCO_STATIC

ifeq ($(INT_OVERFLOW), y)
 CPPFLAGS += -ftrapv -DINT_OVERFLOW
endif

CXXFLAGS	:= -std=gnu++0x $(OPTIMIZE) $(PROFILE)
CFLAGS		:= $(OPTIMIZE) $(PROFILE)

####### linker configuration
LDLIBS :=
LDFLAGS :=

ifeq ($(TARGET_IS_KOBO),y)
 # use our glibc version and its ld.so on the Kobo, not the one from
 # the stock Kobo firmware, as it may be incompatible
 LDFLAGS += -Wl,--dynamic-linker=/opt/LK8000/lib/ld-linux-armhf.so.3
 LDFLAGS += -Wl,--rpath=/opt/LK8000/lib
endif

ifeq ($(CONFIG_WIN32),y)
 LDFLAGS		+=-Wl,--major-subsystem-version=$(CE_MAJOR)
 LDFLAGS		+=-Wl,--minor-subsystem-version=$(CE_MINOR)
endif

ifeq ($(CONFIG_PC),y)
 LDFLAGS		+=-Wl,-subsystem,windows
endif

LDFLAGS		+=$(PROFILE)

ifeq ($(CONFIG_LINUX),y)
 LDLIBS += -lstdc++ -pthread -march=native -lrt -lm
 LDLIBS += $(PNG_LDLIBS)
 LDLIBS += $(FREETYPE_LDLIBS)
 LDLIBS += $(ZZIP_LDLIBS)
 LDLIBS += $(GLES_LDLIBS)
 LDLIBS += $(GLES2_LDLIBS)
 LDLIBS += $(GL_LDLIBS)
 LDLIBS += $(EGL_LDLIBS)
 LDLIBS += $(X11_LDLIBS)
 LDLIBS += $(WAYLAND_LDLIBS)
 LDLIBS += $(SDL_LDLIBS)
 LDLIBS += $(SDL_MIXER_LDLIBS)
 LDLIBS += $(ALSA_LDLIBS)
 LDLIBS += $(SNDFILE_LDLIBS)

 ifeq ($(GLES),y)
  LDLIBS += -ldl
 endif
 ifeq ($(GLES2),y)
  LDLIBS += -ldl
 endif
endif


ifeq ($(CONFIG_WIN32),y)
 ifeq ($(CONFIG_PC),y)
  LDLIBS := -Wl,-Bstatic -lstdc++  -lmingw32 -lcomctl32 -lkernel32 -luser32 -lgdi32 -ladvapi32 -lwinmm -lmsimg32 -lwsock32 -lole32 -loleaut32 -luuid
 else
  LDLIBS := -Wl,-Bstatic -lstdc++  -Wl,-Bdynamic -lcommctrl -lole32 -loleaut32 -luuid
  ifeq ($(CONFIG_PPC2002), y)
   LDLIBS		+= -lwinsock
  else
   LDLIBS		+= -lws2
  endif
  ifeq ($(MINIMAL),n)
   LDLIBS		+= -laygshell
   ifneq ($(TARGET),PNA)
    LDLIBS		+= -limgdecmp
   endif
  endif
 endif
endif



ifeq ($(DMALLOC),y)
  LDLIBS += -L../dmalloc -ldmalloc
endif

####### compiler target

ifeq ($(CONFIG_PC),y)
ifeq ($(TARGET),PCX64)
    TARGET_ARCH := -m64
else
    TARGET_ARCH	:=-mwindows -march=i586 -mms-bitfields
endif
else
TARGET_ARCH	:=-mwin32 $(MCPU)
ifeq ($(TARGET),PNA)
TARGET_ARCH	:=-mwin32
endif
ifeq ($(CONFIG_LINUX),y)
TARGET_ARCH	:= $(MCPU)
endif

endif
WINDRESFLAGS	:=-I$(HDR) -I$(SRC) $(CE_DEFS) -D_MINGW32_
MAKEFLAGS	+=-r

####### build verbosity

# Internal - Control verbosity
#  make V=0 - quiet
#  make V=1 - terse (default)
#  make V=2 - show commands
ifeq ($(V),2)
Q		:=
NQ		:=\#
else
Q		:=@
ifeq ($(V),0)
NQ		:=\#
else
NQ		:=
endif
endif

ifeq ($(CONFIG_PC),n)
#CPPFLAGS_Common_Source_ :=-Werror
endif

include build/xcs_screen.mk
include build/xcs_event.mk
include build/lk_os.mk

ifeq ($(CONFIG_LINUX),y)
include build/bitmap2png.mk
endif

####### sources
WINDOW := \
	$(SRC_WINDOW)/WndMain.cpp \
	$(XCS_EVENT) \
	$(XCS_SCREEN) \
	$(LK_OS) \
	$(SRC)/UIGlobals.cpp \


ifeq ($(CONFIG_WIN32),y)
WINDOW += \
	$(SRC_WINDOW)/Win32/Window.cpp \
	$(SRC_WINDOW)/Win32/WndMainBase.cpp \
	$(SRC_WINDOW)/Win32/WndProc.cpp \
	$(SRC_WINDOW)/Win32/WndPaint.cpp \
	$(SRC_WINDOW)/Win32/WndText.cpp \
	$(SRC_WINDOW)/Win32/WndTextEdit.cpp \
	$(SRC_WINDOW)/Win32/WndTextLabel.cpp \
	$(SRC_WINDOW)/Win32/WndCtrlBase.cpp \

endif
	

ifeq ($(USE_SOUND_EXTDEV), y)	
SOUND := \
	$(SRC)/Sound/ExtDev/Sound.cpp \
	$(SRC)/Sound/ExtDev/sound_table.cpp \

else ifeq ($(USE_SDL), y)	
SOUND := \
	$(SRC)/Sound/SDL/Sound.cpp \
	
else ifeq ($(SNDFILE)$(ALSA),yy)
SOUND := \
	$(SRC)/Sound/alsa/Sound.cpp \
	
endif

ifeq ($(CONFIG_WIN32),y)
SOUND := \
	$(SRC)/Sound/Win32/Sound.cpp \

endif
	
SCREEN := \
	$(SRC_SCREEN)/LKColor.cpp \
	$(SRC_SCREEN)/LKPen.cpp \
	$(SRC_SCREEN)/LKBitmap.cpp \
	$(SRC_SCREEN)/LKBrush.cpp \
	$(SRC_SCREEN)/LKSurface.cpp \
	$(SRC_SCREEN)/LKWindowSurface.cpp \
	$(SRC_SCREEN)/LKBitmapSurface.cpp \
	$(SRC_SCREEN)/LKIcon.cpp \

ifeq ($(CONFIG_WIN32),y)
SCREEN += \
	$(SRC_SCREEN)/GDI/AlphaBlend.cpp \
	
endif
	
LIBRARY	:=\
	$(LIB)/bsearch.cpp \
	$(LIB)/Crc.cpp\
	$(LIB)/DirectoryFunctions.cpp \
	$(LIB)/DrawFunctions.cpp \
	$(LIB)/leastsqs.cpp \
	$(LIB)/magfield.cpp \
	$(LIB)/MathFunctions.cpp	\
	$(LIB)/NavFunctions.cpp	\
	$(LIB)/PressureFunctions.cpp\
	$(LIB)/rscalc.cpp \
	$(LIB)/StringFunctions.cpp\
	$(LIB)/TimeFunctions.cpp\
	$(LIB)/Utm.cpp \
	$(LIB)/xmlParser.cpp \


WAYPT	:=\
	$(WPT)/AllocateWaypointList.cpp\
	$(WPT)/AltitudeFromTerrain.cpp\
	$(WPT)/CUPToLatLon.cpp\
	$(WPT)/Close.cpp\
	$(WPT)/FindMatchingWaypoint.cpp\
	$(WPT)/FindNearestFarVisible.cpp\
	$(WPT)/FindNearestWayPoint.cpp\
	$(WPT)/InTerrainRange.cpp\
	$(WPT)/InitWayPointCalc.cpp\
	$(WPT)/ParseCOMPE.cpp\
	$(WPT)/ParseCUP.cpp\
	$(WPT)/ParseDAT.cpp\
	$(WPT)/ParseOZI.cpp\
	$(WPT)/Read.cpp\
	$(WPT)/ReadAltitude.cpp\
	$(WPT)/ReadFile.cpp\
	$(WPT)/SetHome.cpp\
	$(WPT)/ToString.cpp\
	$(WPT)/Virtuals.cpp\
	$(WPT)/Write.cpp\


LKINTER	:=\
	$(NTR)/LKCustomKeyHandler.cpp\
	$(NTR)/LKInit.cpp\
	$(NTR)/LKInitScreen.cpp\
	$(NTR)/LKInterface.cpp \
	$(NTR)/OverTargets.cpp\
	$(NTR)/VirtualKeys.cpp\
	$(NTR)/CScreenOrientation.cpp\
	

DRAW	:=\
	$(DRW)/CalculateScreen.cpp \
	$(DRW)/CalculateWaypointReachable.cpp \
	$(DRW)/DoAirspaces.cpp \
	$(DRW)/DoTarget.cpp \
	$(DRW)/DoTraffic.cpp \
	$(DRW)/DrawAircraft.cpp \
	$(DRW)/DrawAirSpaces.cpp \
	$(DRW)/DrawAirSpacesBorders.cpp \
	$(DRW)/DrawAirspaceLabels.cpp \
	$(DRW)/DrawBearing.cpp \
	$(DRW)/DrawBestCruiseTrack.cpp \
	$(DRW)/DrawCompass.cpp \
	$(DRW)/DrawCross.cpp \
	$(DRW)/DrawFAIOpti.cpp \
	$(DRW)/DrawFinalGlideBar.cpp \
	$(DRW)/DrawFlarmRadar.cpp \
	$(DRW)/DrawFlightMode.cpp \
	$(DRW)/DrawFuturePos.cpp \
	$(DRW)/DrawGlideThroughTerrain.cpp \
	$(DRW)/DrawGPSStatus.cpp \
	$(DRW)/DrawGreatCircle.cpp \
	$(DRW)/DrawHeading.cpp \
	$(DRW)/DrawHSI.cpp \
	$(DRW)/DrawLKAlarms.cpp \
	$(DRW)/DrawMapScale.cpp \
	$(DRW)/DrawRunway.cpp \
	$(DRW)/DrawStartSector.cpp \
	$(DRW)/DrawTRI.cpp \
	$(DRW)/DrawTask.cpp \
	$(DRW)/DrawTaskAAT.cpp \
	$(DRW)/DrawTeamMate.cpp \
	$(DRW)/DrawTerrainAbove.cpp \
	$(DRW)/DrawThermalBand.cpp \
	$(DRW)/DrawThermalEstimate.cpp \
	$(DRW)/DrawWind.cpp \
	$(DRW)/Draw_Primitives.cpp \
	$(DRW)/LKDrawBottomBar.cpp \
	$(DRW)/LKDrawCpuStatsDebug.cpp \
	$(DRW)/LKDrawFLARMTraffic.cpp \
	$(DRW)/LKDrawInfoPage.cpp \
	$(DRW)/LKDrawLook8000.cpp \
	$(DRW)/LKDrawMapSpace.cpp \
	$(DRW)/LKDrawNearest.cpp \
	$(DRW)/LKDrawTargetTraffic.cpp \
	$(DRW)/LKDrawTrail.cpp \
	$(DRW)/LKDrawVario.cpp \
	$(DRW)/LKDrawWaypoints.cpp \
	$(DRW)/LKDrawWelcome.cpp \
	$(DRW)/LKGeneralAviation.cpp \
	$(DRW)/LKMessages.cpp \
	$(DRW)/LKProcess.cpp \
	$(DRW)/LKWriteText.cpp \
	$(DRW)/LoadSplash.cpp\
	$(DRW)/MapScale.cpp \
	$(DRW)/MapWindowA.cpp \
	$(DRW)/MapWindowMode.cpp \
	$(DRW)/MapWindowZoom.cpp \
	$(DRW)/MapWindow_Events.cpp \
	$(DRW)/MapWindow_Utils.cpp \
	$(DRW)/MapWndProc.cpp \
	$(DRW)/Multimaps/DrawMultimap.cpp \
	$(DRW)/Multimaps/DrawMultimap_Asp.cpp \
	$(DRW)/Multimaps/DrawMultimap_Radar.cpp \
	$(DRW)/Multimaps/DrawMultimap_Test.cpp \
	$(DRW)/Multimaps/GetVisualGlidePoints.cpp \
	$(DRW)/Multimaps/RenderAirspace.cpp\
	$(DRW)/Multimaps/RenderAirspaceTerrain.cpp\
	$(DRW)/Multimaps/RenderNearAirspace.cpp\
	$(DRW)/Multimaps/RenderPlane.cpp\
	$(DRW)/Multimaps/Sideview.cpp \
	$(DRW)/Multimaps/Sky.cpp \
	$(DRW)/Multimaps/TopView.cpp \
	$(DRW)/Multimaps/DrawVisualGlide.cpp \
	$(DRW)/OrigAndOrient.cpp \
	$(DRW)/RenderMapWindow.cpp \
	$(DRW)/RenderMapWindowBg.cpp \
	$(DRW)/ScreenLatLon.cpp \
	$(DRW)/Sonar.cpp \
	$(DRW)/TextInBox.cpp \
	$(DRW)/UpdateAndRefresh.cpp \

CALC	:=\
	$(CLC)/AddSnailPoint.cpp 		\
	$(CLC)/AltitudeRequired.cpp \
	$(CLC)/Atmosphere.cpp 		\
	$(CLC)/AutoMC.cpp \
	$(CLC)/AutoQNH.cpp \
	$(CLC)/AverageClimbRate.cpp \
	$(CLC)/Azimuth.cpp \
	$(CLC)/BallastDump.cpp \
	$(CLC)/BestAlternate.cpp	\
	$(CLC)/Calculations2.cpp \
	$(CLC)/Calculations_Utils.cpp \
	$(CLC)/ClimbAverageCalculator.cpp\
	$(CLC)/ClimbStats.cpp\
	$(CLC)/ContestMgr.cpp\
	$(CLC)/DistanceToHome.cpp\
	$(CLC)/DistanceToNext.cpp\
	$(CLC)/DoAlternates.cpp \
	$(CLC)/DoCalculations.cpp \
	$(CLC)/DoCalculationsSlow.cpp \
	$(CLC)/DoCalculationsVario.cpp \
	$(CLC)/DoCommon.cpp \
	$(CLC)/DoLogging.cpp \
	$(CLC)/DoNearest.cpp \
	$(CLC)/DoRangeWaypointList.cpp \
	$(CLC)/DoRecent.cpp \
	$(CLC)/FarFinalGlideThroughTerrain.cpp\
	$(CLC)/FinalGlideThroughTerrain.cpp\
	$(CLC)/Flaps.cpp \
	$(CLC)/FlarmCalculations.cpp \
	$(CLC)/FlightTime.cpp\
	$(CLC)/FreeFlight.cpp \
	$(CLC)/GlideThroughTerrain.cpp \
	$(CLC)/Heading.cpp \
	$(CLC)/HeadWind.cpp \
	$(CLC)/InitCloseCalculations.cpp \
	$(CLC)/LastThermalStats.cpp\
	$(CLC)/LD.cpp\
	$(CLC)/LDRotaryBuffer.cpp\
	$(CLC)/MagneticVariation.cpp \
	$(CLC)/McReady.cpp\
	$(CLC)/NettoVario.cpp\
	$(CLC)/Orbiter.cpp \
	$(CLC)/Pirker.cpp \
	$(CLC)/PredictNextPosition.cpp \
	$(CLC)/ResetFlightStats.cpp\
	$(CLC)/SetWindEstimate.cpp \
	$(CLC)/SpeedToFly.cpp \
	$(CLC)/TakeoffLanding.cpp\
	$(CLC)/TeamCodeCalculation.cpp \
	$(CLC)/TerrainFootprint.cpp \
	$(CLC)/TerrainHeight.cpp \
	$(CLC)/ThermalBand.cpp \
	$(CLC)/ThermalHistory.cpp \
	$(CLC)/ThermalLocator.cpp \
	$(CLC)/TotalEnergy.cpp\
	$(CLC)/Trace.cpp \
	$(CLC)/Turning.cpp \
	$(CLC)/Valid.cpp\
	$(CLC)/Vario.cpp\
	$(CLC)/WaypointApproxDistance.cpp \
	$(CLC)/WaypointArrivalAltitude.cpp \
	$(CLC)/windanalyser.cpp\
	$(CLC)/windmeasurementlist.cpp \
	$(CLC)/windstore.cpp 	\
	$(CLC)/WindEKF.cpp 	\
	$(CLC)/WindKalman.cpp 	\


TASK	:=\
	$(TSK)/AATCalculateIsoLines.cpp \
	$(TSK)/AATDistance.cpp \
	$(TSK)/AATInTurnSector.cpp	\
	$(TSK)/AATStats.cpp 		\
	$(TSK)/AATtools.cpp 		\
	$(TSK)/AnnounceWPSwitch.cpp 	\
	$(TSK)/CheckFinalGlide.cpp \
	$(TSK)/CheckInSector.cpp \
	$(TSK)/CheckStartRestartFinish.cpp \
	$(TSK)/FAIFinishHeight.cpp \
	$(TSK)/FlyDirectTo.cpp \
	$(TSK)/InFinishSector.cpp \
	$(TSK)/InSector.cpp \
	$(TSK)/InStartSector.cpp \
	$(TSK)/InTurnSector.cpp \
	$(TSK)/InsideStartHeight.cpp\
	$(TSK)/OptimizedTargetPos.cpp \
	$(TSK)/ReadyToStartAdvance.cpp \
	$(TSK)/RefreshTaskStatistics.cpp \
	$(TSK)/SpeedHeight.cpp\
	$(TSK)/StartTask.cpp \
	$(TSK)/TaskAltitudeRequired.cpp\
	$(TSK)/TaskSpeed.cpp\
	$(TSK)/TaskStatistic.cpp\
	$(TSK)/TaskUtils.cpp\
	$(TSK)/TimeGates.cpp\
	$(TSK)/RefreshTask/CalculateAATTaskSectors.cpp\
	$(TSK)/RefreshTask/CalculateTaskSectors.cpp\
	$(TSK)/RefreshTask/RefreshTask.cpp\
	$(TSK)/PGTask/PGTaskPt.cpp\
	$(TSK)/PGTask/PGCicrcleTaskPt.cpp\
	$(TSK)/PGTask/PGLineTaskPt.cpp\
	$(TSK)/PGTask/PGTaskMgr.cpp\
	$(TSK)/PGTask/PGSectorTaskPt.cpp\
	$(TSK)/PGTask/PGConeTaskPt.cpp\

TERRAIN	:=\
	$(TER)/OpenCreateClose.cpp	\
	$(TER)/RasterTerrain.cpp	\
	$(TER)/RAW.cpp	\
	$(TER)/STScreenBuffer.cpp \

TOPOL	:=\
	$(TOP)/Topology.cpp		\
	
ifeq ($(OPENGL),y)
TOPOL	+=\
	$(TOP)/OpenGL/GLShapeRenderer.cpp  \
	
endif

MAPDRAW	:=\
	$(MAP)/DrawTerrain.cpp		\
	$(MAP)/DrawTopology.cpp		\
	$(MAP)/MarkLocation.cpp		\
	$(MAP)/OpenCloseTopology.cpp		\
	$(MAP)/SetTopologyBounds.cpp		\
	$(MAP)/TopoMarks.cpp		\
	$(MAP)/ZoomTopology.cpp		\

UTILS	:=\
	$(SRC)/utils/fileext.cpp \
	$(SRC)/utils/stringext.cpp \
	$(SRC)/utils/md5internal.cpp \
	$(SRC)/utils/md5.cpp \
	$(SRC)/utils/filesystem.cpp \
	$(SRC)/utils/openzip.cpp \
	$(SRC)/utils/TextWrapArray.cpp \

COMMS	:=\
	$(CMM)/LKFlarm.cpp\
	$(CMM)/Parser.cpp\
	$(CMM)/ComCheck.cpp\
	$(CMM)/ComPort.cpp\
	$(CMM)/GpsIdPort.cpp\
	$(CMM)/lkgpsapi.cpp\
	$(CMM)/SerialPort.cpp\
	$(CMM)/TTYPort.cpp\
	$(CMM)/UpdateBaroSource.cpp \
	$(CMM)/UpdateMonitor.cpp \
	$(CMM)/UpdateQNH.cpp \
	$(CMM)/UtilsParser.cpp \
	$(CMM)/device.cpp \
	$(CMM)/Bluetooth/BtHandler.cpp \
	$(CMM)/Bluetooth/BtHandlerWince.cpp \
	$(CMM)/Bluetooth/BthPort.cpp \
	$(CMM)/Obex/CObexPush.cpp \


DEVS	:=\
	$(DEV)/devBase.cpp \
	$(DEV)/devBorgeltB50.cpp \
	$(DEV)/devCAI302.cpp \
	$(DEV)/devCaiGpsNav.cpp \
	$(DEV)/devCompeo.cpp \
	$(DEV)/devCondor.cpp \
	$(DEV)/devDigifly.cpp \
	$(DEV)/devDisabled.cpp \
	$(DEV)/devDSX.cpp \
	$(DEV)/devEye.cpp \
	$(DEV)/devEW.cpp \
	$(DEV)/devEWMicroRecorder.cpp \
	$(DEV)/devFlymasterF1.cpp \
	$(DEV)/devFlytec.cpp \
	$(DEV)/devGeneric.cpp \
	$(DEV)/devIlec.cpp \
	$(DEV)/devIMI.cpp \
	$(DEV)/devNmeaOut.cpp \
	$(DEV)/devLKext1.cpp \
	$(DEV)/devLX.cpp \
	$(DEV)/devLX16xx.cpp \
	$(DEV)/devLXMiniMap.cpp \
	$(DEV)/devLXNano.cpp \
	$(DEV)/devLXV7.cpp \
	$(DEV)/devLXV7easy.cpp \
	$(DEV)/devLXV7_EXP.cpp \
	$(DEV)/devPosiGraph.cpp \
	$(DEV)/devVolkslogger.cpp \
	$(DEV)/devXCOM760.cpp \
	$(DEV)/devZander.cpp \
	$(DEV)/devWesterboer.cpp \
	$(DEV)/LKHolux.cpp \
	$(DEV)/LKRoyaltek3200.cpp	\
	$(DEV)/devFlyNet.cpp \
	$(DEV)/devCProbe.cpp \
	$(DEV)/devBlueFlyVario.cpp\
	$(DEV)/devPVCOM.cpp \
	$(DEV)/devKRT2.cpp \
	$(DEV)/devLXNano3.cpp \

VOLKS	:=\
	$(DEV)/Volkslogger/dbbconv.cpp \
	$(DEV)/Volkslogger/grecord.cpp \
	$(DEV)/Volkslogger/vlapi2.cpp \
	$(DEV)/Volkslogger/vlapihlp.cpp \
	$(DEV)/Volkslogger/vlapisys_win.cpp \
	$(DEV)/Volkslogger/vlconv.cpp \
	$(DEV)/Volkslogger/vlutils.cpp


DLGS	:=\
	$(DLG)/AddCustomKeyList.cpp \
	$(DLG)/dlgAirspace.cpp \
	$(DLG)/dlgAirspaceWarningParams.cpp \
	$(DLG)/dlgAirspaceColours.cpp \
	$(DLG)/dlgMultiSelectList.cpp \
	$(DLG)/dlgAirspaceDetails.cpp \
	$(DLG)/dlgAirspacePatterns.cpp \
	$(DLG)/dlgAirspaceSelect.cpp \
	$(DLG)/dlgBasicSettings.cpp \
	$(DLG)/dlgBottomBar.cpp \
	$(DLG)/dlgChecklist.cpp \
	$(DLG)/dlgComboPicker.cpp \
	$(DLG)/dlgConfiguration.cpp \
	$(DLG)/dlgConfiguration2.cpp \
	$(DLG)/dlgCustomKeys.cpp \
	$(DLG)/dlgCustomMenu.cpp \
	$(DLG)/dlgHelp.cpp \
	$(DLG)/dlgInfoPages.cpp \
	$(DLG)/dlgLKAirspaceWarning.cpp \
	$(DLG)/dlgLKTraffic.cpp \
	$(DLG)/dlgLoggerReplay.cpp \
	$(DLG)/dlgMultimaps.cpp\
	$(DLG)/dlgOracle.cpp \
	$(DLG)/dlgOverlays.cpp \
	$(DLG)/dlgProfiles.cpp \
	$(DLG)/dlgRadioSettings.cpp \
	$(DLG)/dlgStartPoint.cpp \
	$(DLG)/dlgStartTask.cpp \
	$(DLG)/dlgStartup.cpp \
	$(DLG)/dlgStatus.cpp \
	$(DLG)/dlgTarget.cpp \
	$(DLG)/dlgTaskCalculator.cpp \
	$(DLG)/dlgTaskOverview.cpp \
	$(DLG)/dlgTaskRules.cpp \
	$(DLG)/dlgTimeGates.cpp \
	$(DLG)/dlgTopology.cpp \
	$(DLG)/dlgTaskWaypoint.cpp \
	$(DLG)/dlgTeamCode.cpp \
	$(DLG)/dlgTerminal.cpp \
	$(DLG)/dlgTextEntry_Keyboard.cpp \
	$(DLG)/dlgThermalDetails.cpp \
	$(DLG)/dlgTools.cpp \
	$(DLG)/dlgWayPointDetails.cpp \
	$(DLG)/dlgWayQuick.cpp \
	$(DLG)/dlgWaypointEdit.cpp \
	$(DLG)/dlgWayPointSelect.cpp \
	$(DLG)/dlgWaypointOutOfTerrain.cpp \
	$(DLG)/dlgWindSettings.cpp \
	$(DLG)/Analysis/DrawOtherFunctions.cpp \
	$(DLG)/Analysis/DrawXYGrid.cpp \
	$(DLG)/Analysis/RenderBarograph.cpp \
	$(DLG)/Analysis/RenderClimb.cpp \
	$(DLG)/Analysis/RenderContest.cpp \
	$(DLG)/Analysis/RenderFAISector.cpp \
	$(DLG)/Analysis/RenderGlidePolar.cpp \
	$(DLG)/Analysis/RenderSpeed.cpp\
	$(DLG)/Analysis/RenderTask.cpp \
	$(DLG)/Analysis/RenderTemperature.cpp \
	$(DLG)/Analysis/RenderWind.cpp \
	$(DLG)/Analysis/ScaleFunctions.cpp \
	$(DLG)/Analysis/StyleLine.cpp \
	$(DLG)/Analysis/Update.cpp \
	$(DLG)/Analysis/dlgStatistics.cpp \
	$(DLG)/Task/AdjustAATTargets.cpp\
	$(DLG)/Task/InsertWaypoint.cpp\
	$(DLG)/Task/LoadTaskWaypoints.cpp\
	$(DLG)/Task/RemoveTaskPoint.cpp\
	$(DLG)/Task/RemoveWaypoint.cpp\
	$(DLG)/Task/ReplaceWaypoint.cpp\
	$(DLG)/Task/RotateStartPoints.cpp\
	$(DLG)/Task/SwapWaypoint.cpp\
	$(DLG)/dlgBluetooth.cpp\
	$(DLG)/dlgIgcFile.cpp\
	$(DLG)/dlgProgress.cpp \
	
SRC_FILES :=\
	$(WINDOW) \
	$(SCREEN) \
	$(SOUND) \
	$(SRC)/AirfieldDetails.cpp \
	$(SRC)/Alarms.cpp\
	$(SRC)/Backlight.cpp 		\
	$(SRC)/Battery.cpp \
	$(SRC)/Bitmaps.cpp \
	$(SRC)/Buttons.cpp \
	$(SRC)/ChangeScreen.cpp\
	$(SRC)/CommandLine.cpp \
	$(SRC)/ConditionMonitor.cpp \
	$(SRC)/DataOptions.cpp \
	$(SRC)/Dialogs.cpp\
	$(SRC)/DLL.cpp \
	$(SRC)/DoInits.cpp\
	$(SRC)/ExpandMacros.cpp	\
	$(SRC)/FlarmIdFile.cpp 		\
	$(SRC)/FlarmTools.cpp		\
	$(SRC)/Fonts1.cpp \
	$(SRC)/Fonts2.cpp		\
	$(SRC)/Geoid.cpp \
	$(SRC)/Globals.cpp	\
	$(SRC)/InitFunctions.cpp\
	$(SRC)/InputEvents.cpp 		\
	$(SRC)/lk8000.cpp\
	$(SRC)/LiveTracker.cpp \
	$(SRC)/LKAirspace.cpp	\
	$(SRC)/LKInstall.cpp 		\
	$(SRC)/LKLanguage.cpp		\
	$(SRC)/LKObjects.cpp \
	$(SRC)/LKProfileInitRuntime.cpp\
	$(SRC)/LKProfileLoad.cpp\
	$(SRC)/LKProfileResetDefault.cpp\
	$(SRC)/LKProfileSave.cpp\
	$(SRC)/LKSimulator.cpp\
	$(SRC)/LKSimTraffic.cpp\
	$(SRC)/LKUtils.cpp \
	$(SRC)/LocalPath.cpp\
	$(SRC)/Locking.cpp\
	$(SRC)/Logger/DoSignature.cpp 	\
	$(SRC)/Logger/FlightDataRec.cpp 	\
	$(SRC)/Logger/LogBook.cpp\
	$(SRC)/Logger/Logger.cpp \
	$(SRC)/Logger/NMEAlogger.cpp\
	$(SRC)/Logger/ReplayLogger.cpp \
	$(SRC)/Logger/StartStopLogger.cpp \
	$(SHP)/mapbits.cpp \
	$(SHP)/maperror.cpp 	\
	$(SHP)/mapprimitive.cpp \
	$(SHP)/mapsearch.cpp\
	$(SHP)/mapshape.cpp \
	$(SHP)/maptree.cpp\
	$(SHP)/mapxbase.cpp \
	$(SRC)/Message.cpp \
	$(SRC)/MessageLog.cpp	\
	$(SRC)/Models.cpp\
	$(SRC)/Multimap.cpp\
	$(SRC)/Oracle.cpp\
	$(SRC)/Polar.cpp		\
	$(SRC)/ProcessTimer.cpp \
	$(SRC)/SaveLoadTask/ClearTask.cpp\
	$(SRC)/SaveLoadTask/DefaultTask.cpp\
	$(SRC)/SaveLoadTask/LoadNewTask.cpp\
	$(SRC)/SaveLoadTask/CTaskFileHelper.cpp\
	$(SRC)/SaveLoadTask/SaveDefaultTask.cpp\
	$(SRC)/SaveLoadTask/SaveTask.cpp\
	$(SRC)/SaveLoadTask/LoadCupTask.cpp\
	$(SRC)/SaveLoadTask/LoadGpxTask.cpp\
	$(SRC)/Settings.cpp\
	$(SRC)/StatusFile.cpp \
	$(SRC)/Thread_Calculation.cpp\
	$(SRC)/Thread_Draw.cpp	\
	$(SRC)/TrueWind.cpp		\
	$(SRC)/TunedParameter.cpp		\
	$(SRC)/units.cpp \
	$(SRC)/Utils.cpp		\
	$(SRC)/WindowControls.cpp \
	\
	$(LKINTER) \
	$(LIBRARY) \
	$(WAYPT) \
	$(DRAW) \
	$(CALC) \
	$(TASK) \
	$(TERRAIN) \
	$(TOPOL) \
	$(MAPDRAW) \
	$(UTILS) \
	$(COMMS) \
	$(DEVS) \
	$(DLGS) \
	$(VOLKS)


####### libraries
RSCSRC  := $(SRC)/Resource

ZZIPSRC	:=$(LIB)/zzip
ZZIP	:=\
	$(ZZIPSRC)/adler32.c	 	\
	$(ZZIPSRC)/crc32.c 		\
	$(ZZIPSRC)/err.c 		$(ZZIPSRC)/fetch.c \
	$(ZZIPSRC)/file.c 		\
	$(ZZIPSRC)/infback.c 		$(ZZIPSRC)/inffast.c \
	$(ZZIPSRC)/inflate.c 		$(ZZIPSRC)/info.c \
	$(ZZIPSRC)/inftrees.c 		$(ZZIPSRC)/plugin.c \
	$(ZZIPSRC)/uncompr.c \
	$(ZZIPSRC)/zip.c 		$(ZZIPSRC)/zstat.c \
	$(ZZIPSRC)/zutil.c

JASSRC	:=$(SRC)/jasper
JASPER	:=\
	$(JASSRC)/base/jas_cm.c 	$(JASSRC)/base/jas_debug.c \
	$(JASSRC)/base/jas_getopt.c	$(JASSRC)/base/jas_icc.c \
	$(JASSRC)/base/jas_iccdata.c 	$(JASSRC)/base/jas_image.c \
	$(JASSRC)/base/jas_init.c 	$(JASSRC)/base/jas_malloc.c \
	$(JASSRC)/base/jas_seq.c 	$(JASSRC)/base/jas_stream.c \
	$(JASSRC)/base/jas_string.c 	$(JASSRC)/base/jas_tvp.c \
	$(JASSRC)/base/jas_version.c	$(JASSRC)/jp2/jp2_cod.c \
	$(JASSRC)/jp2/jp2_dec.c 	$(JASSRC)/jpc/jpc_bs.c \
	$(JASSRC)/jpc/jpc_cs.c 		$(JASSRC)/jpc/jpc_dec.c \
	$(JASSRC)/jpc/jpc_math.c 	$(JASSRC)/jpc/jpc_mct.c \
	$(JASSRC)/jpc/jpc_mqdec.c       $(JASSRC)/jpc/jpc_mqcod.c \
	$(JASSRC)/jpc/jpc_qmfb.c 	$(JASSRC)/jpc/jpc_rtc.cpp \
	$(JASSRC)/jpc/jpc_t1dec.c 	$(JASSRC)/jpc/jpc_t1enc.c \
	$(JASSRC)/jpc/jpc_t1cod.c \
	$(JASSRC)/jpc/jpc_t2dec.c 	$(JASSRC)/jpc/jpc_t2cod.c \
	$(JASSRC)/jpc/jpc_tagtree.c	$(JASSRC)/jpc/jpc_tsfb.c \
	$(JASSRC)/jpc/jpc_util.c 	$(JASSRC)/jpc/RasterTile.cpp

COMPATSRC:=$(SRC)/wcecompat
COMPAT	:=\
	$(COMPATSRC)/errno.cpp 		$(COMPATSRC)/string_extras.cpp

POCOSRC:=$(LIB)/poco
POCO :=\
     $(POCOSRC)/Debugger.cpp \
     $(POCOSRC)/Bugcheck.cpp \
     $(POCOSRC)/ErrorHandler.cpp \
     $(POCOSRC)/Event.cpp \
     $(POCOSRC)/NamedEvent.cpp \
     $(POCOSRC)/Exception.cpp \
     $(POCOSRC)/Mutex.cpp \
     $(POCOSRC)/NamedMutex.cpp \
     $(POCOSRC)/Runnable.cpp \
     $(POCOSRC)/RWLock.cpp \
     $(POCOSRC)/Thread.cpp \
     $(POCOSRC)/ThreadLocal.cpp \
     $(POCOSRC)/ThreadTarget.cpp \
     $(POCOSRC)/Timestamp.cpp \
     $(POCOSRC)/Timespan.cpp \
     $(POCOSRC)/UnicodeConverter.cpp \
     $(POCOSRC)/UTF8Encoding.cpp \
     $(POCOSRC)/UTF16Encoding.cpp \
     $(POCOSRC)/TextEncoding.cpp \
     $(POCOSRC)/ASCIIEncoding.cpp \
     $(POCOSRC)/Latin1Encoding.cpp \
     $(POCOSRC)/Latin9Encoding.cpp \
     $(POCOSRC)/Windows1252Encoding.cpp \
     $(POCOSRC)/TextIterator.cpp \
     $(POCOSRC)/TextConverter.cpp \
     $(POCOSRC)/Ascii.cpp \
     $(POCOSRC)/AtomicCounter.cpp \
     $(POCOSRC)/RefCountedObject.cpp \

GLUSRC:=$(LIB)/glutess
GLU :=\
    $(GLUSRC)/dict.c \
    $(GLUSRC)/geom.c \
    $(GLUSRC)/memalloc.c \
    $(GLUSRC)/mesh.c \
    $(GLUSRC)/normal.c \
    $(GLUSRC)/priorityq.c \
    $(GLUSRC)/priorityq-heap.c \
    $(GLUSRC)/render.c \
    $(GLUSRC)/sweep.c \
    $(GLUSRC)/tess.c \
    $(GLUSRC)/tessellate.c \
    $(GLUSRC)/tessmono.c 

#ifneq ($(CONFIG_PC),y)
#COMPAT	:=$(COMPAT) \
#   $(COMPATSRC)/redir.cpp
#endif

DIALOG_XML = $(wildcard Common/Data/Dialogs/*.xml)
BITMAP_RES = $(wildcard Common/Data/Bitmaps/*.bmp)
ifeq ($(CONFIG_LINUX),y)
BITMAP_RES_O := $(BIN)/Resource/resource_bmp.o
endif
####### compilation outputs

ifeq ($(TARGET_IS_KOBO), y)
DISTRIB_OUTPUT := KoboRoot.tgz

# temporary still we don't have kobo menu.	
SRC_FILES += \
	$(SRC)/xcs/Kobo/System.cpp \
	$(SRC)/xcs/Kobo/Kernel.cpp \
	$(SRC)/xcs/Kobo/Model.cpp
	

endif
# Add JP2 library for JP2000 unsupported raster maps
# (BIN)/jasper.a \

OBJS 	:=\
	$(patsubst $(SRC)%.cpp,$(BIN)%.o,$(SRC_FILES)) \
	$(BIN)/poco.a 
	
ifneq ($(WIN32_RESOURCE), y)	
OBJS	+= $(BIN)/resource.a
endif

ifneq ($(CONFIG_LINUX),y)
OBJS	+= $(BIN)/zzip.a 
OBJS	+= $(BIN)/compat.a
OBJS	+= $(BIN)/lk8000.rsc
endif

ifeq ($(OPENGL),y)
OBJS	+= $(BIN)/glutess.a 
endif

IGNORE	:= \( -name .git \) -prune -o

include build/distrib.mk
include build/kobo.mk

####### dependency handling

DEPFILE		=$(dir $@).$(notdir $@).d
DEPFLAGS	=-Wp,-MD,$(DEPFILE)
dirtarget	=$(subst \\,_,$(subst /,_,$(dir $@)))
cc-flags	=$(DEPFLAGS) $(CFLAGS) $(CPPFLAGS) $(CPPFLAGS_$(dirtarget)) $(TARGET_ARCH)
cxx-flags	=$(DEPFLAGS) $(CXXFLAGS) $(CPPFLAGS) $(CPPFLAGS_$(dirtarget)) $(TARGET_ARCH)



####### targets
.PHONY: FORCE all clean cleani tags rebuild cppcheck install

all:	$(DISTRIB_OUTPUT) $(PNG) $(MASKED_PNG) $(OUTPUTS)
	
rebuild:
	@$(MAKE) clean
	@$(MAKE) all

clean: cleani
	@$(NQ)echo "  CLEAN   $(BIN)"
	$(Q)$(FIND) $(BIN) $(IGNORE) \( -name '*.[oa]' -o -name '*.rsc' -o -name '.*.d' -o -name '*.min.*'  -o -name '*.png' \) -type f -print | xargs -r $(RM)
	$(Q)$(RM) $(OUTPUTS_NS)
	$(Q)$(RM) $(OUTPUTS)
	$(Q)$(RM) $(PNG)
	$(Q)$(RM) $(MASKED_PNG)

cleani:
	@$(NQ)echo "  CLEANI"
	$(Q)$(FIND) . $(IGNORE) \( -name '*.i' \) -type f -print | xargs -r $(RM)

tags:
	@$(NQ)echo "  TAGS"
	$(Q)$(ETAGS) --declarations --output=TAGS `find . -name *\\\.[ch] -or -name *\\\.cpp`
	$(Q)$(EBROWSE) -s `find . -name *\\\.[ch] -or -name *\\\.cpp`

cppcheck : 
	$(Q)cppcheck --force --enable=all -q -j4 $(SRC_FILES)
#	$(Q)cppcheck --force --enable=warning -q -j4 $(ZZIPSRC)
#	$(Q)cppcheck --force --enable=warning -q -j4 $(COMPAT)
	
ifeq ($(TARGET),LINUX)
install : all
	$(Q)install -p -m 0755 -d ~/LK8000/_System/_Bitmaps 
	$(Q)install -p -m 0755 -d ~/LK8000/_System/_Sounds
	$(Q)install -p -m 0755 -d ~/LK8000/_Airspaces 
	$(Q)install -p -m 0755 -d ~/LK8000/_Configuration 
	$(Q)install -p -m 0755 -d ~/LK8000/_Language 
	$(Q)install -p -m 0755 -d ~/LK8000/_Logger 
	$(Q)install -p -m 0755 -d ~/LK8000/_Maps
	$(Q)install -p -m 0755 -d ~/LK8000/_Polars 
	$(Q)install -p -m 0755 -d ~/LK8000/_Tasks
	$(Q)install -p -m 0755 -d ~/LK8000/_Waypoints
	@$(NQ)echo "  install $(OUTPUTS)"
	$(Q)install -p -m 0755 $(OUTPUTS) ~/LK8000
	@$(NQ)echo "  install _System"
	$(Q)install -p -m 0644 $(SYSTEM_FILES) ~/LK8000/_System
	@$(NQ)echo "  install _System/_Bitmaps"
	$(Q)install -p -m 0644 $(BITMAP_FILES) ~/LK8000/_System/_Bitmaps
	@$(NQ)echo "  install _System/_Sounds"
	$(Q)install -p -m 0644 $(SOUND_FILES) ~/LK8000/_System/_Sounds
	@$(NQ)echo "  install _Polars"
	$(Q)install -p -m 0644 $(POLAR_FILES) ~/LK8000/_Polars
	@$(NQ)echo "  install _Language"
	$(Q)install -p -m 0644 $(LANGUAGE_FILES) ~/LK8000/_Language
	@$(NQ)echo "  install _Configuration"
	$(Q)install -p -m 0644 $(CONFIG_FILES) ~/LK8000/_Configuration
	@$(NQ)echo "  install _Waypoints"
	$(Q)install -p -m 0644 $(WAYPOINT_FILES) ~/LK8000/_Waypoints

endif	

#
# Useful debugging targets - make preprocessed versions of the source
#
%.i: %.cpp FORCE
	$(CXX) $(cxx-flags) -E $(OUTPUT_OPTION) $<

%.i: %.c FORCE
	$(CC) $(cc-flags) -E $(OUTPUT_OPTION) $<

%.s: %.cpp FORCE
	$(CXX) $(cxx-flags) -S $(OUTPUT_OPTION) $<



####### rules

$(OUTPUTS) : $(OUTPUTS_NS) 
	@$(NQ)echo "  STRIP   $@"
	$(Q)$(STRIP) $< -o $@
	$(Q)$(SIZE) $@

ifeq ($(REMOVE_NS),y)
	$(RM) $(OUTPUTS_NS)
endif

$(OUTPUTS_NS): $(OBJS)
	@$(NQ)echo "  LINK    $@"
	$(Q)$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LOADLIBES) $(LDLIBS) -o $@

$(BIN)/glutess.a: $(patsubst $(SRC)%.cpp,$(BIN)%.o,$(GLU)) $(patsubst $(SRC)%.c,$(BIN)%.o,$(GLU))
	@$(NQ)echo "  AR      $@"
	$(Q)$(AR) $(ARFLAGS) $@ $^

$(BIN)/zzip.a: $(patsubst $(SRC)%.cpp,$(BIN)%.o,$(ZZIP)) $(patsubst $(SRC)%.c,$(BIN)%.o,$(ZZIP))
	@$(NQ)echo "  AR      $@"
	$(Q)$(AR) $(ARFLAGS) $@ $^

$(BIN)/jasper.a: $(patsubst $(SRC)%.cpp,$(BIN)%.o,$(JASPER)) $(patsubst $(SRC)%.c,$(BIN)%.o,$(JASPER))
	@$(NQ)echo "  AR      $@"
	$(Q)$(AR) $(ARFLAGS) $@ $^

$(BIN)/compat.a: $(patsubst $(SRC)%.cpp,$(BIN)%.o,$(COMPAT)) $(patsubst $(SRC)%.c,$(BIN)%.o,$(COMPAT))
	@$(NQ)echo "  AR      $@"
	$(Q)$(AR) $(ARFLAGS) $@ $^

$(BIN)/poco.a: $(patsubst $(SRC)%.cpp,$(BIN)%.o,$(POCO)) $(patsubst $(SRC)%.c,$(BIN)%.o,$(POCO))
	@$(NQ)echo "  AR      $@"
	$(Q)$(AR) $(ARFLAGS) $@ $^

$(BIN)/%.o: $(SRC)/%.c
	@$(NQ)echo "  CC      $@"
	$(Q)$(MKDIR) $(dir $@)
	$(Q)$(CC) $(cc-flags) -c $(OUTPUT_OPTION) $<
	@sed -i '1s,^[^ :]*,$@,' $(DEPFILE)

$(BIN)/%.o: $(SRC)/%.cpp
	@$(NQ)echo "  CXX     $@"
	$(Q)$(MKDIR) $(dir $@)
	$(Q)$(CXX) $(cxx-flags) -c $(OUTPUT_OPTION) $<
	@sed -i '1s,^[^ :]*,$@,' $(DEPFILE)

$(BIN)/resource.a: $(BIN)/Resource/resource_data.o $(BIN)/Resource/resource_xml.o $(BITMAP_RES_O) 
	@$(NQ)echo "  AR      $@"
	$(Q)$(AR) $(ARFLAGS) $@ $^

$(BIN)/Resource/resource_xml.o:  $(BIN)/Resource/resource_xml.min.S
	@$(NQ)echo "  AS     $@"
	$(Q)$(MKDIR) $(dir $@)
	$(Q)$(AS) -I'$(dir $<)' $(OUTPUT_OPTION) $<

$(BIN)/Resource/resource_data.o:  $(RSCSRC)/resource_data.S
	@$(NQ)echo "  AS     $@"
	$(Q)$(MKDIR) $(dir $@)
	$(Q)$(AS) -I'$(dir $<)' $(OUTPUT_OPTION) $<

$(BIN)/Resource/resource_bmp.o:  $(BIN)/Resource/resource_bmp.png.S
	@$(NQ)echo "  AS     $@"
	$(Q)$(MKDIR) $(dir $@)
	$(Q)$(AS) -I'$(dir $<)' $(OUTPUT_OPTION) $<

$(BIN)/Resource/resource_bmp.png.S : $(RSCSRC)/resource_bmp.S $(patsubst Common/Data/Bitmaps/%.bmp,$(BIN)/Data/Bitmaps/%.png,$(BITMAP_RES))
	@$(NQ)echo "  update $@"
	@sed -r 's|(^.*")\.\./\.\./(Data/Bitmaps[^"]+)(.bmp)".*$$|\1\.\./\.\./\.\./$(BIN)/\2.png"|g' $< > $@

$(BIN)/Resource/resource_xml.min.S :  $(RSCSRC)/resource_xml.S $(patsubst Common/Data/Dialogs/%.xml,$(BIN)/Data/Dialogs/%.min.xml,$(DIALOG_XML))
	@$(NQ)echo "  update $@"
	@sed -r 's|(^.*")\.\./\.\./(Data/Dialogs[^"]+)(.xml".*)$$|\1\.\./\.\./\.\./$(BIN)/\2.min\3|g' $< > $@

$(BIN)/%.rsc: $(BIN)/%.min.rc 
	@$(NQ)echo "  WINDRES $@"
	$(Q)$(WINDRES) $(WINDRESFLAGS) $< $@

$(BIN)/%.min.rc: $(SRC)/%.rc $(patsubst Common/Data/Dialogs/%.xml,$(BIN)/Data/Dialogs/%.min.xml,$(DIALOG_XML))
	@echo "$@: $< " `sed -nr 's|^.*"\.\./(Data[^"]+)".*$$|Common/\1|gp' $<` > $(DEPFILE)
	@$(NQ)echo "  build $@"
	@sed -r 's|(^.*")\.\./(Data/Dialogs[^"]+)(.xml".*)$$|\1$(BIN)/\2.min\3|g' $< > $@

$(BIN)/Data/Dialogs/%.min.xml: Common/Data/Dialogs/%.xml
	@$(NQ)echo "  minimize $@"
	$(Q)xsltproc --output $@ build/dialogtemplate.xsl $<

$(MASKED_PNG) : $(patsubst $(PNG_TARGET)/%.PNG, $(BITMAP_DIR)/%.BMP, $@)
	@$(NQ)echo "  Convert Image	  $@"
	$(Q)$(MKDIR) $(dir $@)
ifeq ($(OPENGL),y)	
	$(Q)convert -crop 50%x100% +repage $(patsubst $(PNG_TARGET)/%.PNG, $(BITMAP_DIR)/%.BMP, $@) +swap -alpha Off -compose CopyOpacity -composite PNG32:$@	
else
	$(Q)convert $(patsubst $(PNG_TARGET)/%.PNG, $(BITMAP_DIR)/%.BMP, $@) PNG24:$@	
endif

$(PNG) : $(patsubst $(PNG_TARGET)/%.PNG, $(BITMAP_DIR)/%.BMP, $@)
	@$(NQ)echo "  Convert Image	  $@"
	$(Q)$(MKDIR) $(dir $@)
	$(Q)convert $(patsubst $(PNG_TARGET)/%.PNG, $(BITMAP_DIR)/%.BMP, $@) PNG24:$@	

$(BIN)/Data/Bitmaps/%.png: Common/Data/Bitmaps/%.bmp
	@$(NQ)echo "  Convert Image	  $@"
	$(Q)$(MKDIR) $(dir $@)
ifeq ($(OPENGL),y)	
	$(Q)convert -crop 50%x100% +repage $^ +swap -alpha Off -compose CopyOpacity -composite PNG32:$@	
else
	$(Q)convert $^ PNG24:$@	
endif

.PRECIOUS: $(BIN)/Data/Dialogs/%.min.xml \
	$(BIN)/lk8000.min.rc

####### include depends files

ifneq ($(wildcard $(BIN)/.*.d),)
include $(wildcard $(BIN)/.*.d)
endif
ifneq ($(wildcard $(BIN)/*/.*.d),)
include $(wildcard $(BIN)/*/.*.d)
endif
ifneq ($(wildcard $(BIN)/*/*/.*.d),)
include $(wildcard $(BIN)/*/*/.*.d)
endif
ifneq ($(wildcard $(BIN)/*/*/*/.*.d),)
include $(wildcard $(BIN)/*/*/*/.*.d)
endif
