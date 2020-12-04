# CMake fragment for MicroPython rules

set(MICROPY_PY_QSTRDEFS "${MICROPY_PY_DIR}/qstrdefs.h")
set(MICROPY_GENHDR_DIR "${CMAKE_BINARY_DIR}/genhdr")
set(MICROPY_MPVERSION "${MICROPY_GENHDR_DIR}/mpversion.h")
set(MICROPY_MODULEDEFS "${MICROPY_GENHDR_DIR}/moduledefs.h")
set(MICROPY_QSTR_DEFS_LAST "${MICROPY_GENHDR_DIR}/qstr.i.last")
set(MICROPY_QSTR_DEFS_SPLIT "${MICROPY_GENHDR_DIR}/qstr.split")
set(MICROPY_QSTR_DEFS_COLLECTED "${MICROPY_GENHDR_DIR}/qstrdefs.collected.h")
set(MICROPY_QSTR_DEFS_PREPROCESSED "${MICROPY_GENHDR_DIR}/qstrdefs.preprocessed.h")
set(MICROPY_QSTR_DEFS_GENERATED "${MICROPY_GENHDR_DIR}/qstrdefs.generated.h")

# Provide defaults for preprocessor flags if not already defined
if(NOT MICROPY_CPP_FLAGS)
    get_target_property(MICROPY_CPP_INC ${MICROPY_TARGET} INCLUDE_DIRECTORIES)
    get_target_property(MICROPY_CPP_DEF ${MICROPY_TARGET} COMPILE_DEFINITIONS)
endif()

# Compute MICROPY_CPP_FLAGS for preprocessor
list(APPEND MICROPY_CPP_INC ${MICROPY_CPP_INC_EXTRA})
list(APPEND MICROPY_CPP_DEF ${MICROPY_CPP_DEF_EXTRA})
set(_prefix "-I")
foreach(_arg ${MICROPY_CPP_INC})
    list(APPEND MICROPY_CPP_FLAGS ${_prefix}${_arg})
endforeach()
set(_prefix "-D")
foreach(_arg ${MICROPY_CPP_DEF})
    list(APPEND MICROPY_CPP_FLAGS ${_prefix}${_arg})
endforeach()
list(APPEND MICROPY_CPP_FLAGS ${MICROPY_CPP_FLAGS_EXTRA})

find_package(Python3 REQUIRED COMPONENTS Interpreter)

target_sources(${MICROPY_TARGET} PRIVATE
    ${MICROPY_MPVERSION}
    ${MICROPY_QSTR_DEFS_GENERATED}
)

# Command to force the build of another command

# add_custom_command(
    # OUTPUT MICROPY_FORCE_BUILD
    # COMMENT ""
    # COMMAND echo -n
# )

# Generate mpversion.h

add_custom_command(
    OUTPUT ${MICROPY_MPVERSION}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${MICROPY_GENHDR_DIR}
    COMMAND ${Python3_EXECUTABLE} ${MICROPY_DIR}/py/makeversionhdr.py ${MICROPY_MPVERSION}
    # DEPENDS MICROPY_FORCE_BUILD
)

# Generate moduledefs.h
set(MICROPY_SOURCE_MP_REGISTER_MODULE ${MICROPY_SOURCE_MP_REGISTER_MODULE} ${MICROPY_PY_DIR}/modarray.c)
message(WARNING "MICROPY_SOURCE_MP_REGISTER_MODULE=${MICROPY_SOURCE_MP_REGISTER_MODULE}")
add_custom_command(
    OUTPUT ${MICROPY_MODULEDEFS}
    COMMAND ${Python3_EXECUTABLE} ${MICROPY_PY_DIR}/makemoduledefs_cmake.py --input "${MICROPY_SOURCE_MP_REGISTER_MODULE}" --output ${MICROPY_MODULEDEFS}.temp
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MICROPY_MODULEDEFS}.temp ${MICROPY_MODULEDEFS}
    BYPRODUCTS ${MICROPY_MODULEDEFS}.temp
    DEPENDS ${MICROPY_MPVERSION}
            ${MICROPY_SOURCE_MP_REGISTER_MODULE}
            ${MICROPY_PY_DIR}/makemoduledefs_cmake.py
)

# Generate qstrs

# If any of the dependencies in this rule change then the C-preprocessor step must be run.
# It only needs to be passed the list of MICROPY_SOURCE_QSTR files that have changed since
# it was last run, but it looks like it's not possible to specify that with cmake.
add_custom_command(
    OUTPUT ${MICROPY_QSTR_DEFS_LAST}
    COMMAND ${Python3_EXECUTABLE} ${MICROPY_PY_DIR}/makeqstrdefs.py pp ${CMAKE_C_COMPILER} -E output ${MICROPY_QSTR_DEFS_LAST}.temp cflags ${MICROPY_CPP_FLAGS} -DNO_QSTR sources ${MICROPY_SOURCE_QSTR}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MICROPY_QSTR_DEFS_LAST}.temp ${MICROPY_QSTR_DEFS_LAST}
    BYPRODUCTS ${MICROPY_QSTR_DEFS_LAST}.temp 
    DEPENDS ${MICROPY_MODULEDEFS}
        ${MICROPY_SOURCE_QSTR}
    VERBATIM
)

add_custom_command(
    OUTPUT ${MICROPY_QSTR_DEFS_SPLIT}
    COMMAND ${Python3_EXECUTABLE} ${MICROPY_PY_DIR}/makeqstrdefs.py split qstr ${MICROPY_GENHDR_DIR}/qstr.i.last ${MICROPY_GENHDR_DIR}/qstr ${MICROPY_QSTR_DEFS_SPLIT}
    #COMMAND ${CMAKE_COMMAND} -E touch ${MICROPY_QSTR_DEFS_SPLIT}
    DEPENDS ${MICROPY_QSTR_DEFS_LAST}
    VERBATIM
)

add_custom_command(
    OUTPUT ${MICROPY_QSTR_DEFS_COLLECTED}
    COMMAND ${Python3_EXECUTABLE} ${MICROPY_PY_DIR}/makeqstrdefs.py cat qstr _ ${MICROPY_GENHDR_DIR}/qstr ${MICROPY_QSTR_DEFS_COLLECTED}.temp
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MICROPY_QSTR_DEFS_COLLECTED}.temp ${MICROPY_QSTR_DEFS_COLLECTED}
    BYPRODUCTS ${MICROPY_QSTR_DEFS_COLLECTED}.temp 
    DEPENDS ${MICROPY_QSTR_DEFS_SPLIT}
    VERBATIM
)

file(WRITE ${MICROPY_GENHDR_DIR}/sed_filter1 "s/^Q(.*)/\"&\"/")
file(WRITE ${MICROPY_GENHDR_DIR}/sed_filter2 "s/^\\\"\\(Q(.*)\\)\\\"/\\1/")
#todo change to use ${CMAKE_COMMAND} -E cat (after cmake 3.18)
add_custom_command(
    OUTPUT ${MICROPY_QSTR_DEFS_PREPROCESSED}
    COMMAND cat ${MICROPY_PY_QSTRDEFS} ${MICROPY_QSTR_DEFS_COLLECTED} | sed -f ${MICROPY_GENHDR_DIR}/sed_filter1 > ${MICROPY_GENHDR_DIR}/cat_qstrdefs_collected.h
    COMMAND ${CMAKE_C_COMPILER} -E ${MICROPY_CPP_FLAGS} ${MICROPY_GENHDR_DIR}/cat_qstrdefs_collected.h | sed -f ${MICROPY_GENHDR_DIR}/sed_filter2 > ${MICROPY_QSTR_DEFS_PREPROCESSED}.temp
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MICROPY_QSTR_DEFS_PREPROCESSED}.temp ${MICROPY_QSTR_DEFS_PREPROCESSED}
    DEPENDS ${MICROPY_QSTR_DEFS_COLLECTED}
    BYPRODUCTS ${MICROPY_QSTR_DEFS_PREPROCESSED}.temp ${MICROPY_GENHDR_DIR}/cat_qstrdefs_collected.h
    VERBATIM
)

add_custom_command(
    OUTPUT ${MICROPY_QSTR_DEFS_GENERATED}
    COMMAND ${Python3_EXECUTABLE} ${MICROPY_PY_DIR}/makeqstrdata.py ${MICROPY_QSTR_DEFS_PREPROCESSED} > ${MICROPY_QSTR_DEFS_GENERATED}.temp
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MICROPY_QSTR_DEFS_GENERATED}.temp ${MICROPY_QSTR_DEFS_GENERATED}
    DEPENDS ${MICROPY_QSTR_DEFS_PREPROCESSED}
    BYPRODUCTS ${MICROPY_QSTR_DEFS_GENERATED}.temp
    VERBATIM
)

# Build frozen code if enabled

if(MICROPY_FROZEN_MANIFEST)
    set(MICROPY_FROZEN_CONTENT "${CMAKE_BINARY_DIR}/frozen_content.c")

    target_sources(${MICROPY_TARGET} PRIVATE
        ${MICROPY_FROZEN_CONTENT}
    )

    target_compile_definitions(${MICROPY_TARGET} PUBLIC
        MICROPY_QSTR_EXTRA_POOL=mp_qstr_frozen_const_pool
        MICROPY_MODULE_FROZEN_MPY=\(1\)
    )

    add_custom_command(
        OUTPUT ${MICROPY_FROZEN_CONTENT}
        COMMAND ${Python3_EXECUTABLE} ${MICROPY_DIR}/tools/makemanifest.py -o ${MICROPY_FROZEN_CONTENT}.temp -v "MPY_DIR=${MICROPY_DIR}" -v "PORT_DIR=${MICROPY_PORT_DIR}" -b "${CMAKE_BINARY_DIR}" -f${MICROPY_CROSS_FLAGS} ${MICROPY_FROZEN_MANIFEST}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MICROPY_FROZEN_CONTENT}.temp ${MICROPY_FROZEN_CONTENT}
        DEPENDS #MICROPY_FORCE_BUILD
            ${MICROPY_QSTR_DEFS_GENERATED}
        VERBATIM
    )
endif()
