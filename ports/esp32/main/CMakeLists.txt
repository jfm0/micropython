# Set location of base MicroPython directory, and this port's directory.
get_filename_component(MICROPY_DIR ${PROJECT_DIR}/../.. ABSOLUTE)
set(MICROPY_PORT_DIR ${PROJECT_DIR})
set(MICROPY_BOARD_DIR ${PROJECT_DIR}/boards/GENERIC)

#=========================================================================
# Include core source components.
#=========================================================================
include(${MICROPY_DIR}/py/py.cmake)
include(${MICROPY_DIR}/extmod/extmod.cmake)

#=========================================================================
set(MICROPY_DEFINITIONS_MP_REGISTER_MODULE 
    MICROPY_PY_BTLITE=1
    MICROPY_PY_BLUETOOTH=1
    MICROPY_BLUETOOTH_ESP32=1
    MICROPY_PY_BLUETOOTH_ENABLE_CENTRAL_MODE=1 # gatts
    MICROPY_PY_BLUETOOTH_CLASSIC=1 # br/edr avrcp, a2dp sink, hfp client profiles
)

set(MICROPY_INCLUDES_MP_REGISTER_MODULE 
    ${MICROPY_DIR}/../custom_source/btlite
)

set(MICROPY_SOURCE_MP_REGISTER_MODULE ${MICROPY_SOURCE_MP_REGISTER_MODULE} 
    # bluetooth 'lite'
    ${MICROPY_DIR}/../custom_source/btlite/modbtlite.c
    ${MICROPY_DIR}/../custom_source/btlite/hal_btlite.h
    ${MICROPY_DIR}/../custom_source/btlite/esp32/ble_ancs.h
    ${MICROPY_DIR}/../custom_source/btlite/esp32/ble_ancs.c
    ${MICROPY_DIR}/../custom_source/btlite/esp32/hal_btlite.c
    ${MICROPY_DIR}/../custom_source/btlite/esp32/bt_a2dp.h
    ${MICROPY_DIR}/../custom_source/btlite/esp32/bt_a2dp.c
    #${MICROPY_DIR}/../custom_source/btlite/esp32/ble.hpp
    #${MICROPY_DIR}/../custom_source/btlite/esp32/ble.cpp
    
    #bluetooth
    ${MICROPY_DIR}/extmod/modbluetooth.c
    ${MICROPY_DIR}/extmod/modbluetooth.h
    ${MICROPY_DIR}/../custom_source/bluetooth_esp32/modbluetooth_esp32.h
    ${MICROPY_DIR}/../custom_source/bluetooth_esp32/modbluetooth_esp32.c
    )

set(MICROPY_SOURCE_EXTMOD_EXTRA
    ${MICROPY_DIR}/extmod/modonewire.c
    ${MICROPY_SOURCE_MP_REGISTER_MODULE}
)

set(MICROPY_SOURCE_LIB
    ${MICROPY_DIR}/lib/littlefs/lfs1.c
    ${MICROPY_DIR}/lib/littlefs/lfs1_util.c
    ${MICROPY_DIR}/lib/littlefs/lfs2.c
    ${MICROPY_DIR}/lib/littlefs/lfs2_util.c
    ${MICROPY_DIR}/lib/mbedtls_errors/mp_mbedtls_errors.c
    ${MICROPY_DIR}/lib/mp-readline/readline.c
    ${MICROPY_DIR}/lib/netutils/netutils.c
    ${MICROPY_DIR}/lib/oofatfs/ff.c
    ${MICROPY_DIR}/lib/oofatfs/ffunicode.c
    ${MICROPY_DIR}/lib/timeutils/timeutils.c
    ${MICROPY_DIR}/lib/utils/interrupt_char.c
    ${MICROPY_DIR}/lib/utils/stdout_helpers.c
    ${MICROPY_DIR}/lib/utils/sys_stdio_mphal.c
    ${MICROPY_DIR}/lib/utils/pyexec.c
)

set(MICROPY_SOURCE_DRIVERS
    ${MICROPY_DIR}/drivers/bus/softspi.c
    ${MICROPY_DIR}/drivers/dht/dht.c
)

set(MICROPY_SOURCE_PORT
    ${PROJECT_DIR}/main.c
    ${PROJECT_DIR}/uart.c
    ${PROJECT_DIR}/gccollect.c
    ${PROJECT_DIR}/mphalport.c
    ${PROJECT_DIR}/fatfs_port.c
    ${PROJECT_DIR}/help.c
    ${PROJECT_DIR}/modutime.c
    ${PROJECT_DIR}/moduos.c
    ${PROJECT_DIR}/machine_timer.c
    ${PROJECT_DIR}/machine_pin.c
    ${PROJECT_DIR}/machine_touchpad.c
    ${PROJECT_DIR}/machine_adc.c
    ${PROJECT_DIR}/machine_dac.c
    ${PROJECT_DIR}/machine_i2c.c
    ${PROJECT_DIR}/machine_pwm.c
    ${PROJECT_DIR}/machine_uart.c
    ${PROJECT_DIR}/modmachine.c
    #${PROJECT_DIR}/modnetwork.c
    #${PROJECT_DIR}/network_lan.c
    #${PROJECT_DIR}/network_ppp.c
    ${PROJECT_DIR}/mpnimbleport.c
    ${PROJECT_DIR}/modsocket.c
    ${PROJECT_DIR}/modesp.c
    ${PROJECT_DIR}/esp32_partition.c
    ${PROJECT_DIR}/esp32_rmt.c
    ${PROJECT_DIR}/esp32_ulp.c
    ${PROJECT_DIR}/modesp32.c
    ${PROJECT_DIR}/espneopixel.c
    ${PROJECT_DIR}/machine_hw_spi.c
    ${PROJECT_DIR}/machine_wdt.c
    ${PROJECT_DIR}/mpthreadport.c
    ${PROJECT_DIR}/machine_rtc.c
    ${PROJECT_DIR}/machine_sdcard.c
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

# create dummy file if does not exist
if(NOT EXISTS ${LV_MPY_C_FILE})
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/lvgl)
    file(TOUCH ${LV_MPY_C_FILE})
endif()

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

# These are sources that can contain QSTR
set(LVGL_SOURCES_QSTR
    ${LV_MPY_C_FILE_MODIFIED}
#============== esp32 ========================
    #${LVGL_BINDINGS_DIR}/driver/esp32/espidf.c
    ${LVGL_BINDINGS_DIR}/driver/esp32/modILI9341.c
    ${LVGL_BINDINGS_DIR}/driver/esp32/modlvesp32.c
    ${LVGL_BINDINGS_DIR}/driver/esp32/modrtch.c
    #${LVGL_BINDINGS_DIR}/driver/esp32/modxpt2046.c
#============== sdl ========================
    #${LVGL_BINDINGS_DIR}/driver/SDL/modSDL.c
    #${LVGL_BINDINGS_DIR}/driver/SDL/SDL_monitor.c
    #${LVGL_BINDINGS_DIR}/driver/SDL/SDL_mouse.c
#============== other ========================
    #${LVGL_BINDINGS_DIR}/driver/linux/modfb.c
    #${LVGL_BINDINGS_DIR}/driver/generic/modlvindev.c
#============== lodepng ========================
    # ${LODEPNG_MPY_C_FILE}
    # ${LVGL_BINDINGS_DIR}/driver/png/mp_lodepng.c
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng_benchmark.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng_fuzzer.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng_unittest.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/lodepng_util.cpp
    # ${LVGL_BINDINGS_DIR}/driver/png/lodepng/pngdetail.cpp
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

set(IDF_COMPONENTS
    app_update
    bootloader_support
    driver
    esp32
    esp_common
    esp_eth
    esp_event
    esp_ipc
    esp_netif
    esp_ringbuf
    esp_rom
    esp_timer
    esp_wifi
    esp_system
    freertos
    heap
    log
    lwip
    mbedtls
    mdns
    newlib
    nvs_flash
    sdmmc
    soc
    spi_flash
    tcpip_adapter
    ulp
    vfs
    xtensa
    bt
)

# Register the main IDF component.
idf_component_register(
    SRCS
        ${MICROPY_SOURCE_PY}
        ${MICROPY_SOURCE_EXTMOD}
        ${MICROPY_SOURCE_EXTMOD_EXTRA}
        ${MICROPY_SOURCE_LIB}
        ${MICROPY_SOURCE_DRIVERS}
        ${MICROPY_SOURCE_PORT}
        ${LVGL_SOURCES}
    INCLUDE_DIRS
        ${MICROPY_DIR}
        ${MICROPY_PORT_DIR}
        ${MICROPY_BOARD_DIR}
        ${CMAKE_BINARY_DIR}
        ${LVGL_INCLUDES}
        ${MICROPY_INCLUDES_MP_REGISTER_MODULE}
    REQUIRES
        ${IDF_COMPONENTS}
)

# Set the MicroPython target as the current (main) IDF component target.
set(MICROPY_TARGET ${COMPONENT_TARGET})

#target_sources(${MICROPY_TARGET} PRIVATE ${LV_MPY_C_FILE})

# Define mpy-cross flags and frozen manifest
set(MICROPY_CROSS_FLAGS -march=xtensawin)
set(MICROPY_FROZEN_MANIFEST ${PROJECT_DIR}/boards/manifest.py)

# Set compile options for this port.
target_compile_definitions(${MICROPY_TARGET} PUBLIC
    MICROPY_ESP_IDF_4=1
    MICROPY_VFS_FAT=1
    MICROPY_VFS_LFS2=1
    FFCONF_H=\"${MICROPY_OOFATFS_DIR}/ffconf.h\"
    LFS1_NO_MALLOC LFS1_NO_DEBUG LFS1_NO_WARN LFS1_NO_ERROR LFS1_NO_ASSERT
    LFS2_NO_MALLOC LFS2_NO_DEBUG LFS2_NO_WARN LFS2_NO_ERROR LFS2_NO_ASSERT
    ${MICROPY_DEFINITIONS_MP_REGISTER_MODULE}
)

target_compile_definitions(${MICROPY_TARGET} PUBLIC
    LV_COLOR_DEPTH=16
    LV_COLOR_16_SWAP=1
)

# Disable some warnings to keep the build output clean.
target_compile_options(${MICROPY_TARGET} PUBLIC
    -Wno-clobbered
    -Wno-deprecated-declarations
    -Wno-missing-field-initializers
)
if(${LVGL_BINDING_GEN_NEW})
add_dependencies(${MICROPY_TARGET} GenLvglBinding) #GenLodepngBinding
endif()

# Collect all of the include directories and compile definitions for the IDF components.
foreach(comp ${IDF_COMPONENTS})
    get_target_property(type __idf_${comp} TYPE)
    set(_inc OFF)
    set(_def OFF)
    if(${type} STREQUAL STATIC_LIBRARY)
        get_target_property(_inc __idf_${comp} INCLUDE_DIRECTORIES)
        get_target_property(_def __idf_${comp} COMPILE_DEFINITIONS)
    elseif(${type} STREQUAL INTERFACE_LIBRARY)
        get_target_property(_inc __idf_${comp} INTERFACE_INCLUDE_DIRECTORIES)
        get_target_property(_def __idf_${comp} INTERFACE_COMPILE_DEFINITIONS)
    endif()
    if(_inc)
        list(APPEND MICROPY_CPP_INC_EXTRA ${_inc})
    endif()
    if(_def)
        list(APPEND MICROPY_CPP_DEF_EXTRA ${_def})
    endif()
endforeach()

#=========================================================================
# Include the main MicroPython cmake rules.
#=========================================================================
include(${MICROPY_DIR}/py/mkrules.cmake)
