cmake_minimum_required(VERSION 3.5)
# Set location of base MicroPython directory, and this port's directory.
get_filename_component(MICROPY_DIR .. ABSOLUTE)
#message(WARNING "MICROPY_DIR=${MICROPY_DIR}")
#message(WARNING "CMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}")

project(mpy-cross)

add_executable(mpy-cross)

set_target_properties(mpy-cross PROPERTIES
                      RUNTIME_OUTPUT_DIRECTORY_DEBUG ${MICROPY_DIR}/mpy-cross
                      RUNTIME_OUTPUT_DIRECTORY_RELEASE ${MICROPY_DIR}/mpy-cross)

target_include_directories(mpy-cross PUBLIC . ${CMAKE_BINARY_DIR} ${MICROPY_DIR})

if(WIN32)
set(MICROPY_SOURCE_QSTR ${MICROPY_DIR}/ports/windows/fmode.c)
endif()


set(MICROPY_TARGET mpy-cross)
include(${MICROPY_DIR}/py/py.cmake)

set(MICROPY_SOURCE_QSTR
    ${MICROPY_SOURCE_QSTR}
    ${MICROPY_DIR}/mpy-cross/main.c 
    ${MICROPY_DIR}/mpy-cross/gccollect.c 
    ${MICROPY_DIR}/lib/utils/gchelper_generic.c
    ${MICROPY_SOURCE_PY}
    #${MICROPY_SOURCE_EXTMOD}
    #${MICROPY_SOURCE_EXTMOD_EXTRA}
    #${MICROPY_SOURCE_LIB}
    #${MICROPY_SOURCE_PORT}
)

target_sources(mpy-cross PUBLIC ${MICROPY_SOURCE_QSTR})

include(${MICROPY_DIR}/py/mkrules.cmake)

target_sources(mpy-cross PRIVATE
    ${MICROPY_MPVERSION}
    ${MICROPY_QSTR_DEFS_GENERATED}
)

#add_dependencies(mpy-cross MICROPY_FORCE_BUILD)
