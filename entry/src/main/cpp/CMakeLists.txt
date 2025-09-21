# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(entry)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

add_library(
        entry
        SHARED
        vuln_jni.cpp)

target_link_libraries(
        entry
        ace_napi.z
        hilog_ndk.z)