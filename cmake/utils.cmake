macro(set_if_undefined variable)
    if(NOT DEFINED "${variable}")
        set("${variable}" ${ARGN})
    endif()
endmacro()

function(win_copy_deps_to_target_dir target)
    if(NOT WIN32)
        return()
    endif()

    set(has_runtime_dll_genex NO)

    if(CMAKE_MAJOR_VERSION GREATER 3 OR CMAKE_MINOR_VERSION GREATER_EQUAL 21)
        set(has_runtime_dll_genex YES)

        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -P "${libfoxochat_SOURCE_DIR}/cmake/silent_copy.cmake"
                "$<TARGET_RUNTIME_DLLS:${target}>" "$<TARGET_FILE_DIR:${target}>"
            COMMAND_EXPAND_LISTS)
    endif()

    foreach(dep ${ARGN})
        get_target_property(dep_type ${dep} TYPE)

        if(dep_type STREQUAL "SHARED_LIBRARY")
            if(NOT has_runtime_dll_genex)
                add_custom_command(TARGET ${target} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -P "${libfoxochat_SOURCE_DIR}/cmake/silent_copy.cmake"
                        "$<TARGET_FILE:${dep}>" "$<TARGET_PDB_FILE:${dep}>" "$<TARGET_FILE_DIR:${target}>"
                    COMMAND_EXPAND_LISTS)
            else()
                add_custom_command(TARGET ${target} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -P "${libfoxochat_SOURCE_DIR}/cmake/silent_copy.cmake"
                        "$<TARGET_PDB_FILE:${dep}>" "$<TARGET_FILE_DIR:${target}>"
                    COMMAND_EXPAND_LISTS)
            endif()
        endif()
    endforeach()
endfunction()
