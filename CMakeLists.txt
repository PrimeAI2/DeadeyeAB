cmake_minimum_required(VERSION 3.24)
project(DeadeyeBot LANGUAGES OBJCXX CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(OpenCV REQUIRED COMPONENTS core imgproc highgui)
include_directories(${OpenCV_INCLUDE_DIRS})

set(ASSET_DIR "${CMAKE_SOURCE_DIR}/assets")
set(GEN_DIR "${CMAKE_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${GEN_DIR}")

add_custom_command(OUTPUT "${GEN_DIR}/overlay_png.h"
  COMMAND sh -c "cd ${ASSET_DIR} && xxd -i overlay.png > ${GEN_DIR}/overlay_png.h"
  DEPENDS "${ASSET_DIR}/overlay.png" VERBATIM)
add_custom_command(OUTPUT "${GEN_DIR}/splash_png.h"
  COMMAND sh -c "cd ${ASSET_DIR} && xxd -i splash.png > ${GEN_DIR}/splash_png.h"
  DEPENDS "${ASSET_DIR}/splash.png" VERBATIM)
add_custom_command(OUTPUT "${GEN_DIR}/bodies_wav.h"
  COMMAND sh -c "cd ${ASSET_DIR} && xxd -i bodies.wav > ${GEN_DIR}/bodies_wav.h"
  DEPENDS "${ASSET_DIR}/bodies.wav" VERBATIM)

add_custom_target(embed_assets DEPENDS "${GEN_DIR}/overlay_png.h" "${GEN_DIR}/splash_png.h" "${GEN_DIR}/bodies_wav.h")
include_directories("${GEN_DIR}")

add_executable(DeadeyeBot main_complete.mm)
add_dependencies(DeadeyeBot embed_assets)
target_compile_options(DeadeyeBot PRIVATE -fobjc-arc)
target_link_libraries(DeadeyeBot PRIVATE ${OpenCV_LIBS})

find_library(APPKIT AppKit)
find_library(FOUNDATION Foundation)
find_library(COREGRAPHICS CoreGraphics)
find_library(APPLICATIONSERVICES ApplicationServices)
find_library(SCREENCAPTUREKIT ScreenCaptureKit)
find_library(COREMEDIA CoreMedia)
find_library(COREVIDEO CoreVideo)
find_library(AVFOUNDATION AVFoundation)
find_library(METAL Metal)

target_link_libraries(DeadeyeBot PRIVATE ${APPKIT} ${FOUNDATION} ${COREGRAPHICS} ${APPLICATIONSERVICES} ${SCREENCAPTUREKIT} ${COREMEDIA} ${COREVIDEO} ${AVFOUNDATION} ${METAL})
