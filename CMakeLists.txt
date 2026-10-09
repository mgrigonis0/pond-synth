cmake_minimum_required(VERSION 3.19)
project(pond-synth)

# Path to a checkout of https://github.com/Cycling74/max-sdk-base
set(MAX_SDK_BASE "${CMAKE_SOURCE_DIR}/max-sdk-base" CACHE PATH "max-sdk-base checkout")

add_subdirectory(source/projects/pond_tilde)
