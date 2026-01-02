# iOS-specific build configuration
#
# Included automatically from the top-level CMakeLists.txt when
# CMAKE_SYSTEM_NAME is "iOS" (see cmake/Toolchain-iOS.cmake).

message("Building for iOS")

# iOS builds are app-bundle oriented; keep output predictable.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Avoid building unit tests by default on iOS (can be overridden explicitly).
set(BUILD_TESTS OFF CACHE BOOL "Build the unit tests" FORCE)

# iOS generally doesn't support dlopen in the same way as desktop;
# keep things simple and avoid optional runtime behaviors here.
add_definitions(-D__IOS__)

