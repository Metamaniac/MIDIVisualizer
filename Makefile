#Compiler: g++
CXX = g++

#Include directories (for headers): standard include dirs in /usr and /usr/local, and our helper directory.
INCLUDEDIR = -I/usr/include/ -I/usr/local/include/ -Isrc/helpers/ -Isrc/libs/ -Isrc/libs/glfw/include/

#Libraries needed: OpenGL, GLEW and glfw3. glfw3 requires Cocoa, IOKit and CoreVideo.
LIBDIR = -Lsrc/libs/glfw/lib-mac/ -Lsrc/libs/nfd/lib-mac/
LIBS = $(LIBDIR) -lglfw3 -lnfd -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo -framework AppKit

#Compiler flags: C++11 standard, and display 'all' warnings.
CXXFLAGS = -std=c++11 -Wall -O3

#Build directory
BUILDDIR = build
#Source directory
SRCDIR = src

#Paths to the source files
#Collect sources from subdirectories (up to depth 3) 
# /!\ at depth 4, src/libs/glm/detail contains dummy cpp files that we want to ignore.
SRC_DEPTH_2 = $(wildcard $(SRCDIR)/*/*.cpp)
SRC_DEPTH_3 = $(wildcard $(SRCDIR)/*/*/*.cpp)
SOURCES = $(SRC_DEPTH_3) $(SRC_DEPTH_2) $(SRCDIR)/main.cpp
TOOLSOURCES = $(SRC_DEPTH_3) $(SRC_DEPTH_2) $(SRCDIR)/packager.cpp

#Paths to the object files
OBJECTS = $(SOURCES:$(SRCDIR)/%.cpp=$(BUILDDIR)/%.o)
TOOLOBJECTS = $(TOOLSOURCES:$(SRCDIR)/%.cpp=$(BUILDDIR)/%.o)

#Paths to the subdirectories
SUBDIRS_LIST = $(shell find src -type d)
SUBDIRS = $(SUBDIRS_LIST:$(SRCDIR)%=$(BUILDDIR)%)

#Executable name
EXECNAME = midiviz
TOOLNAME = midiviz-packager

#Re-create the build dir if needed, compile and link.
all: dirs $(EXECNAME)

#Linking phase: combine all objects files to generate the executable
$(EXECNAME): dirs $(OBJECTS)
	@echo "Linking $(EXECNAME)..."
	@$(CXX) $(OBJECTS) $(LIBS) -o $(BUILDDIR)/$(EXECNAME)
	@echo "Done!"

$(TOOLNAME): dirs $(TOOLOBJECTS)
	@echo "Linking $(TOOLNAME)..."
	@$(CXX) $(TOOLOBJECTS) $(LIBS) -o $(BUILDDIR)/$(TOOLNAME)
	@echo "Done!"

#Compiling phase: generate the object files from the source files
$(BUILDDIR)/%.o : $(SRCDIR)/%.cpp
	@echo "Compiling $<"
	@$(CXX) -c $(CXXFLAGS) $(INCLUDEDIR)  $< -o $@

#Run the executable
run:
	@./$(BUILDDIR)/$(EXECNAME)

# Package the images as raw arrays and write them in the source directory.
package: dirs $(TOOLNAME)
	@./$(BUILDDIR)/$(TOOLNAME)
	@echo "You can now compile $(EXECNAME) with the updated data."

#Create the build directory and its subdirectories
dirs:
	@mkdir -p $(SUBDIRS)

#Remove the whole build directory
.PHONY: clean
clean :
	rm -r $(BUILDDIR)

