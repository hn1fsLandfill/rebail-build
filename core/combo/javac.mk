# Selects a Java compiler.
#
# Inputs:
#	CUSTOM_JAVA_COMPILER -- "eclipse", "openjdk". or nothing for the system
#                           default
#	ALTERNATE_JAVAC -- the alternate java compiler to use
#
# Outputs:
#   COMMON_JAVAC -- Java compiler command with common arguments
#

# We're in a barebones scenario, jack isn't available.
ANDROID_COMPILE_WITH_JACK := false

common_jdk_flags := -source 1.8 -target 1.8 -Xmaxerrs 9999999

# Use the indexer wrapper to index the codebase instead of the javac compiler
ifeq ($(ALTERNATE_JAVAC),)
JAVACC := javac
else
JAVACC := $(ALTERNATE_JAVAC)
endif

ifeq ($(ALTERNATE_KOTLINC),)
KOTLINCC := kotlinc
else
KOTLINCC := $(ALTERNATE_KOTLINC)
endif

# The actual compiler can be wrapped by setting the JAVAC_WRAPPER var.
ifdef JAVAC_WRAPPER
    ifneq ($(JAVAC_WRAPPER),$(firstword $(JAVACC)))
        JAVACC := $(JAVAC_WRAPPER) $(JAVACC)
    endif
endif

# Whatever compiler is on this system.
ifeq ($(BUILD_OS), windows)
    COMMON_JAVAC := development/host/windows/prebuilt/javawrap.exe -J-Xmx256m \
        $(common_jdk_flags)
else
    COMMON_JAVAC := $(JAVACC) -J-Xmx1024M $(common_jdk_flags)
    COMMON_KOTLINC := $(KOTLINCC) -J-Xmx1024M $(common_jdk_flags)
endif

# Eclipse.
ifeq ($(CUSTOM_JAVA_COMPILER), eclipse)
    COMMON_JAVAC := java -Xmx256m -jar prebuilt/common/ecj/ecj.jar -5 \
        -maxProblems 9999999 -nowarn
    $(info CUSTOM_JAVA_COMPILER=eclipse)
endif

HOST_JAVAC ?= $(COMMON_JAVAC)
TARGET_JAVAC ?= $(COMMON_JAVAC)
TARGET_KOTLINC ?= $(COMMON_KOTLINC)

#$(info HOST_JAVAC=$(HOST_JAVAC))
#$(info TARGET_JAVAC=$(TARGET_JAVAC))
