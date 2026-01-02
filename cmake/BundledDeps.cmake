include(FetchContent)

set(FETCHCONTENT_QUIET OFF)


function(smw_declare_gitrepo name url tag)
    FetchContent_Declare(
        ${name}
        GIT_REPOSITORY ${url}
        GIT_TAG ${tag}
        GIT_SHALLOW TRUE
        GIT_PROGRESS TRUE
        OVERRIDE_FIND_PACKAGE
    )
endfunction()


if (USE_BUNDLED_SDL)
    message("Using bundled SDL")

    # iOS builds are significantly more reliable when using static libraries
    # (avoids dylib code signing / embedding complexity).
    if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
        set(SDL_SHARED OFF CACHE BOOL "" FORCE)
        set(SDL_STATIC ON CACHE BOOL "" FORCE)
    endif()

    # SDL2
    # Default to SDL's upstream defaults on non-iOS platforms.
    if (NOT (CMAKE_SYSTEM_NAME STREQUAL "iOS"))
        set(SDL_STATIC OFF CACHE BOOL "")
    endif()
    smw_declare_gitrepo(
        SDL2
        https://github.com/libsdl-org/SDL.git
        release-2.30.11
    )

    # SDL2 image
    set(SDL2IMAGE_VENDORED ON CACHE BOOL "")
    set(SDL2IMAGE_DEPS_SHARED OFF CACHE BOOL "")
    smw_declare_gitrepo(
        SDL2_image
        https://github.com/libsdl-org/SDL_image
        release-2.8.4
    )

    # SDL2 mixer
    set(SDL2MIXER_VENDORED ON CACHE BOOL "")
    set(SDL2MIXER_DEPS_SHARED OFF CACHE BOOL "")
    smw_declare_gitrepo(
        SDL2_mixer
        https://github.com/libsdl-org/SDL_mixer
        release-2.8.0
    )
endif()
