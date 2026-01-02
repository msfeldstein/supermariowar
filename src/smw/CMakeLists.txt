add_executable(smw WIN32
	main.cpp

	ai.cpp
	ai.h
	FPSLimiter.cpp
	FPSLimiter.h
	GSGameplay.cpp
	GSGameplay.h
	GSMenu.cpp
	GSMenu.h
	GSSplashScreen.cpp
	GSSplashScreen.h
	net.cpp
	net.h
	network/FileCompressor.cpp
	network/FileCompressor.h
	network/NetConfigManager.cpp
	network/NetConfigManager.h
	ObjectContainer.cpp
	ObjectContainer.h
	objectgame.cpp
	objectgame.h
	objecthazard.cpp
	objecthazard.h
	player.cpp
	player.h
	world.cpp
	world.h

	../common/movingplatform.cpp
	../common/movingplatform.h
)

add_subdirectory(player_components)
add_subdirectory(menu)
add_subdirectory(gamemodes)
add_subdirectory(objects)
add_subdirectory(ui)

target_compile_features(smw PUBLIC cxx_std_14)
target_compile_definitions(smw PRIVATE
	GIT_REVISION="${SMW_GIT_REVISION}"
	GIT_DATE="${SMW_GIT_DATE}"
)

#
# iOS app bundle configuration
#
if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
	set(SMW_IOS_BUNDLE_ID "net.smwstuff.supermariowar" CACHE STRING "iOS bundle identifier")
	set(SMW_IOS_BUNDLE_DATA ON CACHE BOOL "Copy data/ into the iOS app bundle")

	set(_smw_ios_plist_in "${PROJECT_SOURCE_DIR}/resources/ios/Info.plist.in")
	set(_smw_ios_plist "${PROJECT_BINARY_DIR}/Info-iOS.plist")
	set(SMW_VERSION "${PROJECT_VERSION}")
	configure_file("${_smw_ios_plist_in}" "${_smw_ios_plist}" @ONLY)

	set_target_properties(smw PROPERTIES
		MACOSX_BUNDLE TRUE
		MACOSX_BUNDLE_INFO_PLIST "${_smw_ios_plist}"
		XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "${SMW_IOS_BUNDLE_ID}"
		XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
		XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
		XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
	)

	# SDL/iOS commonly needs these system frameworks when linking statically.
	target_link_libraries(smw PRIVATE
		"-framework UIKit"
		"-framework Foundation"
		"-framework CoreGraphics"
		"-framework QuartzCore"
		"-framework AVFoundation"
		"-framework AudioToolbox"
		"-framework CoreMotion"
		"-framework GameController"
	)

	if (SMW_IOS_BUNDLE_DATA)
		add_custom_command(TARGET smw POST_BUILD
			COMMAND "${CMAKE_COMMAND}" -E make_directory "$<TARGET_BUNDLE_CONTENT_DIR:smw>/Resources"
			COMMAND "${CMAKE_COMMAND}" -E copy_directory
				"${PROJECT_SOURCE_DIR}/data"
				"$<TARGET_BUNDLE_CONTENT_DIR:smw>/Resources/data"
			COMMENT "Copying game data into iOS app bundle"
		)
	endif()

	# Convenience build target name for iOS builds.
	add_custom_target(smw-ios DEPENDS smw)
endif()

if(NO_NETWORK)
	target_compile_definitions(smw PRIVATE NETWORK_DISABLED)
else()
	target_sources(smw PRIVATE
		platform/network/enet/NetworkLayerENet.cpp
		platform/network/enet/NetworkLayerENet.h
	)
endif()

if (WIN32)
	# Add EXE icon on Windows
	target_sources(smw PRIVATE "${PROJECT_SOURCE_DIR}/resources/windows/smw.rc")
endif()

#
# Dependencies
#

target_link_libraries(smw CommonFiles)
if(NOT NO_NETWORK)
	target_link_libraries(smw NetplayFiles)
endif()

if(NOT EMSCRIPTEN)
	target_link_libraries(smw ZLIB::ZLIB)
endif()

target_link_libraries(smw yaml-cpp)

#
# Installation
#

install(TARGETS smw DESTINATION "${SMW_BINDIR}")

# install Linux desktop item and icons
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux" AND NOT SMW_INSTALL_PORTABLE)
	configure_file("${PROJECT_SOURCE_DIR}/resources/linux/supermariowar.desktop.in"
		"${PROJECT_BINARY_DIR}/supermariowar.desktop" @ONLY)

	install(FILES "${PROJECT_BINARY_DIR}/supermariowar.desktop" DESTINATION "${SMW_DESKTOPDIR}")
	install(FILES "${PROJECT_SOURCE_DIR}/resources/icons/smw.xpm" DESTINATION "${SMW_PIXMAPDIR}")
	install(FILES "${PROJECT_SOURCE_DIR}/resources/icons/smw.png" DESTINATION "${SMW_ICONDIR}/32x32/apps/")
endif()
