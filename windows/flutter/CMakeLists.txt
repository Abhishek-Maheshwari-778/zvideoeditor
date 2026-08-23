# Flutter wrapper CMakeLists.txt
cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake OPTIONAL)

# TODO: Move the rest of this into files in ephemeral. See
# https://github.com/flutter/flutter/issues/57146.
set(WRAPPER_ROOT "${EPHEMERAL_DIR}/cpp_client_wrapper")

# === Flutter Library ===
set(FLUTTER_LIB "${EPHEMERAL_DIR}/flutter_windows.dll")

# === Wrapper ===
list(APPEND CPP_WRAPPER_SOURCES_CORE
  "${WRAPPER_ROOT}/core_implementations.cc"
  "${WRAPPER_ROOT}/standard_codec.cc"
)
list(APPEND CPP_WRAPPER_SOURCES_PLUGIN
  "${WRAPPER_ROOT}/plugin_registrar.cc"
)
list(APPEND CPP_WRAPPER_SOURCES_APP
  "${WRAPPER_ROOT}/flutter_engine.cc"
  "${WRAPPER_ROOT}/flutter_view_controller.cc"
)

# Target for wrapper libraries
add_library(flutter_wrapper_core STATIC
  ${CPP_WRAPPER_SOURCES_CORE}
)
apply_standard_settings(flutter_wrapper_core)
set_target_properties(flutter_wrapper_core PROPERTIES
  POSITION_INDEPENDENT_CODE ON)
target_include_directories(flutter_wrapper_core PUBLIC
  "${WRAPPER_ROOT}/include"
)

add_library(flutter_wrapper_plugin STATIC
  ${CPP_WRAPPER_SOURCES_PLUGIN}
)
apply_standard_settings(flutter_wrapper_plugin)
set_target_properties(flutter_wrapper_plugin PROPERTIES
  POSITION_INDEPENDENT_CODE ON)
target_include_directories(flutter_wrapper_plugin PUBLIC
  "${WRAPPER_ROOT}/include"
)
target_link_libraries(flutter_wrapper_plugin PUBLIC flutter_wrapper_core)

add_library(flutter_wrapper_app STATIC
  ${CPP_WRAPPER_SOURCES_APP}
)
apply_standard_settings(flutter_wrapper_app)
set_target_properties(flutter_wrapper_app PROPERTIES
  POSITION_INDEPENDENT_CODE ON)
target_include_directories(flutter_wrapper_app PUBLIC
  "${WRAPPER_ROOT}/include"
)
target_link_libraries(flutter_wrapper_app PUBLIC flutter_wrapper_core)

# === Assembly ===
add_library(flutter_assemble INTERFACE)
target_link_libraries(flutter_assemble INTERFACE flutter_wrapper_app)
