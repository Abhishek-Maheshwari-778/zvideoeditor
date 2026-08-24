cmake_minimum_required(VERSION 3.14)
project(z_movie_maker LANGUAGES CXX)

set(BINARY_NAME "z_movie_maker")

cmake_policy(SET CMP0079 NEW)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(APPLICATION_ID "com.example.z_movie_maker")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
  endif()
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of adding them here.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_link_options(${TARGET} PRIVATE /WX)
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake OPTIONAL)

# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done as a post-build step so that changes to any of
# these files are picked up without re-running cmake (this is especially
# important with Flutter, since the Flutter assets can change during a normal
# development workflow).

# The Flutter tool generates a set of outputs that the embedding layer must
# handle as part of the build. This includes the Flutter engine DLL (and the
# corresponding import library), and the Flutter asset bundle.
set(FLUTTER_TOOL_ENVIRONMENT
  "FLUTTER_ROOT=${FLUTTER_ROOT}"
  "FLUTTER_EPHEMERAL_DIR=${CMAKE_CURRENT_SOURCE_DIR}/flutter/ephemeral"
  "PROJECT_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
  "FLUTTER_TARGET=lib/main.dart"
  "FLUTTER_BUILD_DIR=${CMAKE_BINARY_DIR}"
  "FLUTTER_BUILD_NAME=1.0.0"
  "FLUTTER_BUILD_NUMBER=1"
)

# Copy the Flutter library and data assets to the output folder.
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)

foreach(bundled_library ${PLUGIN_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}"
    DESTINATION "${CMAKE_INSTALL_PREFIX}"
    COMPONENT Runtime)
endforeach(bundled_library)

# Copy the flutter_assets directory into the output directory.
install(DIRECTORY "${PROJECT_BUILD_DIR}/flutter_assets"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Bundle install directory
set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")
