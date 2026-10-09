cmake_minimum_required(VERSION 3.19)

# Legacy Max SDK scripts: the folder name "pond_tilde" becomes the external "pond~".
include(${MAX_SDK_BASE}/script/max-pretarget.cmake)

include_directories("${C74_INCLUDES}")

add_library(${PROJECT_NAME} MODULE pond_tilde.cpp ../../engine/pond_engine.h)
target_compile_options(${PROJECT_NAME} PRIVATE -O3)

include(${MAX_SDK_BASE}/script/max-posttarget.cmake)
