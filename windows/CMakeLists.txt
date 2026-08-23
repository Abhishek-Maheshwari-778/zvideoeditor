# Project-level CMakeLists.txt for Flutter Windows app
cmake_minimum_required(VERSION 3.14)
project(z_movie_maker LANGUAGES CXX)

set(BINARY_NAME "z_movie_maker")

cmake_policy(SET CMP0079 NEW)

# Explicitly opt in to modern CMake target configuration.
set(EXTRA_PLUGINS_LIBRARIES)
set(PLUGIN_BUNDLED_LIBRARIES)

# Bundle install directory
set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

add_subdirectory(flutter)
add_subdirectory(runner)

# Generated plugin build rules
include(flutter/generated_plugins.cmake OPTIONAL)
