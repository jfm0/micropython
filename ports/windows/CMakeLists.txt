cmake_minimum_required(VERSION 3.5)
project(micropython)

set(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
# Set location of base MicroPython directory, and this port's directory.
get_filename_component(MICROPY_DIR ${PROJECT_DIR}/../.. ABSOLUTE)
set(MICROPY_PORT_DIR ${PROJECT_DIR})
#set(MICROPY_BOARD_DIR ${MICROPY_DIR}/ports/unix/variants/dev)
set(MICROPY_FROZEN_MANIFEST ${MICROPY_DIR}/ports/unix/variants/dev/manifest.py)

#=========================================================================
# Include core source components.
#=========================================================================
include(${MICROPY_DIR}/py/py.cmake)
include(${MICROPY_DIR}/extmod/extmod.cmake)

add_executable(micropython)
set(MICROPY_TARGET micropython)

#=========================================================================
# Enable/disable modules and 3rd-party libs to be included in interpreter
# Build 32-bit binaries on a 64-bit host
set(MICROPY_FORCE_32BIT 0)

# This variable can take the following values:
#  0 - no readline, just simple stdin input
#  1 - use MicroPython version of readline
set(MICROPY_USE_READLINE, 1)

# btree module using Berkeley DB 1.xx
set(MICROPY_PY_BTREE, 1)

# _thread module using pthreads
set(MICROPY_PY_THREAD, 1)

# Subset of CPython termios module
set(MICROPY_PY_TERMIOS, 0)

# Subset of CPython socket module
set(MICROPY_PY_SOCKET, 0)

# ffi module requires libffi (libffi-dev Debian package)
set(MICROPY_PY_FFI, 1)

# ussl module requires one of the TLS libraries below
set(MICROPY_PY_USSL, 1)
# axTLS has minimal size but implements only a subset of modern TLS
# functionality, so may have problems with some servers.
set(MICROPY_SSL_AXTLS, 1)
# mbedTLS is more up to date and complete implementation, but also
# more bloated.
set(MICROPY_SSL_MBEDTLS, 0)

# jni module requires JVM/JNI
set(MICROPY_PY_JNI, 0)

# Avoid using system libraries, use copies bundled with MicroPython
# as submodules (currently affects only libffi).
set(MICROPY_STANDALONE, 0)
#=========================================================================
target_compile_definitions(${MICROPY_TARGET} PUBLIC
        MICROPY_USE_READLINE=1
        MICROPY_PY_TERMIOS=0
        MICROPY_PY_SOCKET=0
        MICROPY_PY_THREAD=1
        MICROPY_PY_THREAD_GIL=0
        MPZ_DIG_SIZE=16
)

set(MICROPY_SOURCE_EXTMOD_EXTRA
#    ${MICROPY_DIR}/extmod/modonewire.c
    ${MICROPY_DIR}/extmod/machine_pinbase.c
)

set(MICROPY_SOURCE_LIB
    ${MICROPY_DIR}/lib/littlefs/lfs1.c
    ${MICROPY_DIR}/lib/littlefs/lfs1_util.c
    ${MICROPY_DIR}/lib/littlefs/lfs2.c
    ${MICROPY_DIR}/lib/littlefs/lfs2_util.c
    #${MICROPY_DIR}/lib/mbedtls_errors/mp_mbedtls_errors.c
    ${MICROPY_DIR}/lib/mp-readline/readline.c
    ${MICROPY_DIR}/lib/netutils/netutils.c
    ${MICROPY_DIR}/lib/oofatfs/ff.c
    ${MICROPY_DIR}/lib/oofatfs/ffunicode.c
    ${MICROPY_DIR}/lib/timeutils/timeutils.c
    #${MICROPY_DIR}/lib/utils/interrupt_char.c
    #${MICROPY_DIR}/lib/utils/stdout_helpers.c
    #${MICROPY_DIR}/lib/utils/sys_stdio_mphal.c
    #${MICROPY_DIR}/lib/utils/pyexec.c
    ${MICROPY_DIR}/lib/utils/gchelper_generic.c
    ${MICROPY_DIR}/lib/utils/printf.c
)

set(MICROPY_SOURCE_DRIVERS
    #${MICROPY_DIR}/drivers/bus/softspi.c
    #${MICROPY_DIR}/drivers/dht/dht.c
)

set(MICROPY_SOURCE_PORT
    # ==================== windows specific
    ${MICROPY_DIR}/ports/windows/mpconfigport.h
    ${MICROPY_DIR}/ports/windows/windows_mphal.c
    ${MICROPY_DIR}/ports/windows/realpath.c
    ${MICROPY_DIR}/ports/windows/init.c
    ${MICROPY_DIR}/ports/windows/sleep.c
    ${MICROPY_DIR}/ports/windows/fmode.c
    ${MICROPY_DIR}/ports/windows/msvc/dirent.c
    ${MICROPY_DIR}/ports/windows/msvc/gettimeofday.c
    ${MICROPY_DIR}/ports/windows/msvc/gettimeofday.c
    ${MICROPY_DIR}/ports/windows/msvc/pthread.c
    ${MICROPY_DIR}/ports/windows/msvc/pthread.h
    # ==================== unix
    ${MICROPY_DIR}/ports/unix/main.c
    ${MICROPY_DIR}/ports/unix/gccollect.c
    ${MICROPY_DIR}/ports/unix/input.c
    ${MICROPY_DIR}/ports/unix/modmachine.c
    ${MICROPY_DIR}/ports/unix/modos.c
    ${MICROPY_DIR}/ports/unix/modtime.c

    ${MICROPY_DIR}/ports/unix/mpthreadport.c
    ${MICROPY_DIR}/ports/unix/moduos_vfs.c
    ${MICROPY_DIR}/ports/unix/moduselect.c
    #${MICROPY_DIR}/ports/unix/alloc.c
    ${MICROPY_DIR}/ports/unix/fatfs_port.c
    # ${MICROPY_DIR}/ports/unix/mpbthciport.c
    # ${MICROPY_DIR}/ports/unix/mpbtstackport_common.c
    # ${MICROPY_DIR}/ports/unix/mpbtstackport_h4.c
    # ${MICROPY_DIR}/ports/unix/mpbtstackport_usb.c
    # ${MICROPY_DIR}/ports/unix/mpnimbleport.c
    # ${MICROPY_DIR}/ports/unix/modusocket.c
    # ${MICROPY_DIR}/ports/unix/modtermios.c
)

set(MICROPY_SOURCE_QSTR
    ${MICROPY_SOURCE_PY}
    ${MICROPY_SOURCE_EXTMOD}
    ${MICROPY_SOURCE_EXTMOD_EXTRA}
    ${MICROPY_SOURCE_LIB}
    ${MICROPY_SOURCE_PORT}
)

#### Custom C modules
set(LVGL_BINDING On CACHE BOOL "Enable lvgl")
if(${LVGL_BINDING})
set(LVGL_BINDINGS_DIR "${MICROPY_DIR}/lib/lv_bindings")

set(LVGL_HEADERS
    ${LVGL_BINDINGS_DIR}/lv_conf.h
    ${LVGL_BINDINGS_DIR}/lvgl/lvgl.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_api_map.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_conf_internal.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_conf_kconfig.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lvgl.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_disp.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_group.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_indev.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_obj.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_obj_style_dec.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_refr.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_style.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_arc.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_blend.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_img.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_label.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_line.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_mask.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_rect.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_triangle.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_img_buf.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_img_cache.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_img_decoder.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_fmt_txt.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_loader.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_symbol_def.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_gpu/lv_gpu_nxp_pxp.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_gpu/lv_gpu_nxp_pxp_osa.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_gpu/lv_gpu_nxp_vglite.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_gpu/lv_gpu_stm32_dma2d.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_hal/lv_hal.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_hal/lv_hal_disp.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_hal/lv_hal_indev.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_hal/lv_hal_tick.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_anim.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_area.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_async.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_bidi.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_color.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_debug.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_fs.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_gc.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_ll.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_log.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_math.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_mem.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_printf.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_task.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_templ.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_txt.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_txt_ap.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_types.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_utils.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme_empty.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme_material.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme_mono.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme_template.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_arc.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_bar.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_btn.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_btnmatrix.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_calendar.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_canvas.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_chart.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_checkbox.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_cont.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_cpicker.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_dropdown.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_gauge.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_img.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_imgbtn.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_keyboard.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_label.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_led.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_line.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_linemeter.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_list.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_msgbox.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_objmask.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_objx_templ.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_page.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_roller.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_slider.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_spinbox.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_spinner.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_switch.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_table.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_tabview.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_textarea.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_tileview.h
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_win.h)

find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(LV_MPY_C_FILE "${CMAKE_BINARY_DIR}/lvgl/lv_mpy.c")
set(LV_MPY_C_FILE_MODIFIED "${LVGL_BINDINGS_DIR}/lv_mpy.c")
#set(LODEPNG_MPY_C_FILE "${CMAKE_BINARY_DIR}/lvgl/lodepng_mpy.c")

# create dummy file if does not exist
if(NOT EXISTS ${LV_MPY_C_FILE})
    #message(WARNING "LV_MPY_C_FILE=${LV_MPY_C_FILE} not exists?")
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/lvgl)
    file(TOUCH ${LV_MPY_C_FILE})
endif()
# if(NOT EXISTS ${LODEPNG_MPY_C_FILE})
    # file(TOUCH ${LODEPNG_MPY_C_FILE})
# endif()

set(LVGL_BINDING_GEN_NEW Off CACHE BOOL "Generate a new lvgl binding (actual lvgl.c file is located in ${LV_MPY_C_FILE_MODIFIED}")
if(${LVGL_BINDING_GEN_NEW})
add_custom_target(GenLvglBinding
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/lvgl
    COMMAND ${CMAKE_C_COMPILER} -E -DLV_COLOR_DEPTH=16 -DLV_COLOR_16_SWAP=1 -I ${LVGL_BINDINGS_DIR}/pycparser/utils/fake_libc_include -I ${LVGL_BINDINGS_DIR} ${LVGL_BINDINGS_DIR}/lvgl/lvgl.h > ${CMAKE_BINARY_DIR}/lvgl/lvgl.pp.c
    COMMAND ${Python3_EXECUTABLE} ${MICROPY_DIR}/lib/lv_bindings/gen/gen_mpy.py -M lvgl -MP lv -MD ${CMAKE_BINARY_DIR}/lvgl/lv_mpy.json -E ${CMAKE_BINARY_DIR}/lvgl/lvgl.pp.c ${LVGL_BINDINGS_DIR}/lvgl/lvgl.h > ${LV_MPY_C_FILE}
    BYPRODUCTS "${CMAKE_BINARY_DIR}/lvgl/lvgl.pp.c" ${LV_MPY_C_FILE}
    COMMENT "Preprocessing Lvgl for generating bindings"
    DEPENDS ${LVGL_BINDINGS_DIR}/lvgl/lvgl.h #${LVGL_HEADERS}
    VERBATIM
)
endif()

# add_custom_target(GenLodepngBinding
    # COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/lvgl
    # COMMAND ${CMAKE_C_COMPILER} -E -I ${LVGL_BINDINGS_DIR}/pycparser/utils/fake_libc_include -I ${LVGL_BINDINGS_DIR} ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng.h > ${CMAKE_BINARY_DIR}/lvgl/lodepng.pp.c
    # COMMAND ${Python3_EXECUTABLE} ${MICROPY_DIR}/lib/lv_bindings/gen/gen_mpy.py -M lodepng -E ${CMAKE_BINARY_DIR}/lvgl/lodepng.pp.c ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng.h > ${CMAKE_BINARY_DIR}/lvgl/lodepng_mpy.c
    # BYPRODUCTS "${CMAKE_BINARY_DIR}/lvgl/lodepng.pp.c" #${LV_MPY_C_FILE}
    # COMMENT "Preprocessing Lodepng for generating bindings"
    # DEPENDS ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng.h #${LVGL_HEADERS} 
    # VERBATIM
# )

# These are sources that can contain QSTR
set(LVGL_SOURCES_QSTR
    ${LV_MPY_C_FILE_MODIFIED}
#${LVGL_BINDINGS_DIR}/driver/esp32/espidf.c
    # ${LVGL_BINDINGS_DIR}/driver/esp32/modILI9341.c
    # ${LVGL_BINDINGS_DIR}/driver/esp32/modlvesp32.c
    # ${LVGL_BINDINGS_DIR}/driver/esp32/modrtch.c
    #${LVGL_BINDINGS_DIR}/driver/esp32/modxpt2046.c
#============== sdl ========================
    ${LVGL_BINDINGS_DIR}/driver/SDL/modSDL.c
    ${LVGL_BINDINGS_DIR}/driver/SDL/SDL_monitor.c
    ${LVGL_BINDINGS_DIR}/driver/SDL/SDL_mouse.c
    #${LVGL_BINDINGS_DIR}/driver/linux/modfb.c
    ${LVGL_BINDINGS_DIR}/driver/generic/modlvindev.c
#============== lodepng ========================
    # ${LODEPNG_MPY_C_FILE}
    # ${LVGL_BINDINGS_DIR}/driver/png/mp_lodepng.c
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng_fuzzer.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng_util.cpp
#============== lodepng ========================
    #${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng_benchmark.cpp
    #${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng_unittest.cpp
    #${LVGL_BINDINGS_DIR}/driver/png/lodepng/pngdetail.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_4bit_palette.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_bmp2png.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_decode.c
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_decode.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_encode.c
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_encode.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_encode_type.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_gzip.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_opengl.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_optimize_png.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_png2bmp.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_png_info.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_reencode.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_sdl.c
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/examples/example_sdl.cpp
    # ${LVGL_BINDINGS_DIR}/driver/stm32/string1.c
    # ${LVGL_BINDINGS_DIR}/driver/stm32/STM32F7DISC/ft5336.c
    # ${LVGL_BINDINGS_DIR}/driver/stm32/STM32F7DISC/modrk043fn48h.c
    # ${LVGL_BINDINGS_DIR}/driver/stm32/STM32F7DISC/stm32746g_discovery_ts.c
)

set(LVGL_SOURCES
    ${LVGL_SOURCES_QSTR}
    # ${LVGL_BINDINGS_DIR}/lvgl/examples/porting/lv_port_disp_template.c
    # ${LVGL_BINDINGS_DIR}/lvgl/examples/porting/lv_port_fs_template.c
    # ${LVGL_BINDINGS_DIR}/lvgl/examples/porting/lv_port_indev_template.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_disp.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_group.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_indev.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_obj.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_refr.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_core/lv_style.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_arc.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_blend.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_img.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_label.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_line.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_mask.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_rect.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_draw_triangle.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_img_buf.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_img_cache.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_draw/lv_img_decoder.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_dejavu_16_persian_hebrew.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_fmt_txt.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_loader.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_10.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_12.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_12_subpx.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_14.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_16.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_18.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_20.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_22.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_24.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_26.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_28.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_28_compressed.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_30.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_32.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_34.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_36.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_38.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_40.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_42.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_44.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_46.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_48.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_montserrat_8.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_simsun_16_cjk.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_font/lv_font_unscii_8.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_gpu/lv_gpu_nxp_pxp.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_gpu/lv_gpu_nxp_pxp_osa.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_gpu/lv_gpu_nxp_vglite.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_gpu/lv_gpu_stm32_dma2d.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_hal/lv_hal_disp.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_hal/lv_hal_indev.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_hal/lv_hal_tick.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_anim.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_area.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_async.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_bidi.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_color.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_debug.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_fs.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_gc.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_ll.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_log.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_math.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_mem.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_printf.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_task.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_templ.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_txt.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_txt_ap.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_misc/lv_utils.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme_empty.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme_material.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme_mono.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_themes/lv_theme_template.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_arc.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_bar.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_btn.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_btnmatrix.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_calendar.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_canvas.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_chart.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_checkbox.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_cont.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_cpicker.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_dropdown.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_gauge.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_img.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_imgbtn.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_keyboard.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_label.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_led.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_line.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_linemeter.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_list.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_msgbox.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_objmask.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_objx_templ.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_page.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_roller.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_slider.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_spinbox.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_spinner.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_switch.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_table.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_tabview.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_textarea.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_tileview.c
    ${LVGL_BINDINGS_DIR}/lvgl/src/lv_widgets/lv_win.c
    )

set(LVGL_INCLUDES
    ${LVGL_BINDINGS_DIR}/
    ${LVGL_BINDINGS_DIR}/lvgl/src)

list(APPEND MICROPY_SOURCE_QSTR ${LVGL_SOURCES_QSTR})
#message(WARNING "MICROPY_SOURCE_QSTR=${MICROPY_SOURCE_QSTR}")

endif()

# Register the main IDF component.
target_sources(${MICROPY_TARGET} 
    PRIVATE 
        ${MICROPY_SOURCE_PY}
        ${MICROPY_SOURCE_EXTMOD}
        ${MICROPY_SOURCE_EXTMOD_EXTRA}
        ${MICROPY_SOURCE_LIB}
        ${MICROPY_SOURCE_DRIVERS}
        ${MICROPY_SOURCE_PORT}
        ${LVGL_SOURCES}
)
target_include_directories(${MICROPY_TARGET} 
    PRIVATE 
        ${MICROPY_DIR}
        ${MICROPY_PORT_DIR}
        #${MICROPY_BOARD_DIR}
        ${CMAKE_BINARY_DIR}
        ${LVGL_INCLUDES}
        ${MICROPY_DIR}/ports/unix
        ${MICROPY_DIR}/ports/windows/msvc
)

# Set the MicroPython target as the current (main) IDF component target.

#target_sources(${MICROPY_TARGET} PRIVATE ${LV_MPY_C_FILE})

# Define mpy-cross flags and frozen manifest
set(MICROPY_CROSS_FLAGS -mcache-lookup-bc)

# Set compile options for this port.
target_compile_definitions(${MICROPY_TARGET} PUBLIC
    #MICROPY_ESP_IDF_4=1
    MICROPY_VFS=1
    MICROPY_VFS_FAT=1
    MICROPY_VFS_LFS2=1
    FFCONF_H=\"${MICROPY_OOFATFS_DIR}/ffconf.h\"
    LFS1_NO_MALLOC LFS1_NO_DEBUG LFS1_NO_WARN LFS1_NO_ERROR LFS1_NO_ASSERT
    LFS2_NO_MALLOC LFS2_NO_DEBUG LFS2_NO_WARN LFS2_NO_ERROR LFS2_NO_ASSERT
    # use vfs's functions for import stat and builtin open
    mp_import_stat=mp_vfs_import_stat
    mp_builtin_open=mp_vfs_open
    mp_builtin_open_obj=mp_vfs_open_obj

)

target_compile_definitions(${MICROPY_TARGET} PUBLIC
    LV_COLOR_DEPTH=16
    LV_COLOR_16_SWAP=1
)

# Disable some warnings to keep the build output clean.
target_compile_options(${MICROPY_TARGET} PUBLIC
    #-Wno-clobbered
    #-Wno-deprecated-declarations
    #-Wno-missing-field-initializers
)
if(${LVGL_BINDING_GEN_NEW})
add_dependencies(${MICROPY_TARGET} GenLvglBinding) #GenLodepngBinding
endif()

#=========================================================================
# Libraries
#=========================================================================

find_package(SDL2 REQUIRED)
#message(WARNING "SDL2_INCLUDE_DIRS=${SDL2_INCLUDE_DIRS}")
#message(WARNING "SDL2_LIBRARIES=${SDL2_LIBRARIES}")
include_directories(${SDL2_INCLUDE_DIRS})
target_link_libraries(${MICROPY_TARGET} SDL2::SDL2)#${SDL2_LIBRARIES})

# add_custom_command(TARGET ${MICROPY_TARGET} POST_BUILD        # Adds a post-build event to MyTest
    # COMMAND ${CMAKE_COMMAND} -E copy_if_different  # which executes "cmake - E copy_if_different..."
        # "${SDL2_DIR}/../bin/SDL2.dll"      # <--this is in-file
        # $<TARGET_FILE_DIR:${MICROPY_TARGET}>)  

# add_custom_command(TARGET ${MICROPY_TARGET} POST_BUILD        # Adds a post-build event to MyTest
    # COMMAND ${CMAKE_COMMAND} -E copy_if_different  # which executes "cmake - E copy_if_different..."
        # "${SDL2_DIR}/../bin/SDL2d.dll"      # <--this is in-file
        # $<TARGET_FILE_DIR:${MICROPY_TARGET}>)  

# set(THREADS_PREFER_PTHREAD_FLAG ON)
# find_package(Threads REQUIRED)
# target_link_libraries(${MICROPY_TARGET} Threads::Threads)
#find_package(pthreads REQUIRED)
#message(WARNING "PTHREAD_INCLUDE_DIRS=${PTHREAD_INCLUDE_DIRS}")
#message(WARNING "PTHREAD_LIBRARIES=${PTHREAD_LIBRARIES}")
#message(WARNING "PTHREAD_DEFINITIONS=${PTHREAD_DEFINITIONS}")
#message(WARNING "CMAKE_CL_64=${CMAKE_CL_64}")

#include_directories(${PTHREAD_INCLUDE_DIRS})
#target_link_libraries(${MICROPY_TARGET} ${PTHREAD_LIBRARIES})
# target_compile_definitions(${MICROPY_TARGET} PUBLIC
    # ${PTHREAD_DEFINITIONS}
# )

include(CheckLibraryExists)
check_library_exists(m pow "" LIBM) # math library
if(LIBM)
    target_link_libraries(${MICROPY_TARGET} m)
endif()

#=========================================================================
# Include the main MicroPython cmake rules.
#=========================================================================
include(${MICROPY_DIR}/py/mkrules.cmake)
