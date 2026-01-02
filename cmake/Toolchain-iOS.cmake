# iOS toolchain for Super Mario War (CMake)
#
# Usage example (Simulator build, no signing required):
#   cmake -S . -B build-ios -G Xcode \
#     -DCMAKE_TOOLCHAIN_FILE=cmake/Toolchain-iOS.cmake \
#     -DSMW_IOS_PLATFORM=SIMULATOR \
#     -DUSE_SDL2_LIBS=ON -DUSE_BUNDLED_SDL=ON -DBUILD_TESTS=OFF
#
# Notes:
# - This toolchain intentionally targets the Simulator by default to avoid
#   code-signing requirements in CI and developer machines.
# - For device builds, set SMW_IOS_PLATFORM=OS (you'll still need signing).

set(CMAKE_SYSTEM_NAME iOS)

# SMW_IOS_PLATFORM:
# - SIMULATOR: iphonesimulator SDK (default)
# - OS:        iphoneos SDK (device)
if(NOT DEFINED SMW_IOS_PLATFORM)
  set(SMW_IOS_PLATFORM "SIMULATOR" CACHE STRING "iOS SDK platform: SIMULATOR or OS")
endif()

string(TOUPPER "${SMW_IOS_PLATFORM}" _SMW_IOS_PLATFORM_UPPER)
if(_SMW_IOS_PLATFORM_UPPER STREQUAL "OS")
  set(CMAKE_OSX_SYSROOT "iphoneos" CACHE STRING "" FORCE)
  set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "" FORCE)
elseif(_SMW_IOS_PLATFORM_UPPER STREQUAL "SIMULATOR")
  set(CMAKE_OSX_SYSROOT "iphonesimulator" CACHE STRING "" FORCE)
  # Modern simulator supports arm64 on Apple Silicon and x86_64 on Intel.
  # Default to arm64 to keep builds consistent in CI.
  set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "" FORCE)
else()
  message(FATAL_ERROR "Unknown SMW_IOS_PLATFORM='${SMW_IOS_PLATFORM}'. Use SIMULATOR or OS.")
endif()

# Common iOS settings
set(CMAKE_OSX_DEPLOYMENT_TARGET "12.0" CACHE STRING "Minimum supported iOS version" FORCE)

# Cross-compiling find behavior
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

