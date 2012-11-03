#find ./build/ -name '*.h' -exec sed -n -e 's/#define [^ ]*_IMPLEMENTATION "\([^"]*\)"/\1/p' {} \;

file(GLOB abidir build/*/include/*)
foreach(dir ${abidir})
    if(IS_DIRECTORY "${dir}")
        string(REGEX REPLACE "^.*/([^/]*)$" "\\1" abi "${dir}")
    endif()
endforeach()

set(impls)
set(types)

file(GLOB files build/*/include/${abi}/*.h)
foreach(header ${files})
    file(STRINGS ${header} content)
    foreach(line ${content})
        if ("${line}" MATCHES "#define .*_IMPLEMENTATION \"")
            string(REGEX REPLACE "#define .*_IMPLEMENTATION (\".*\")" "\\1" impl "${line}")
            list(APPEND impls "${impl}\n")
        endif()
        if ("${line}" MATCHES "^typedef ")
            list(APPEND types "\"${line}\"\n")
        endif()
    endforeach()
endforeach()

message("implementations: ${impls}")
message("types: ${types}")


set(tmp)
list(APPEND tmp "set(PLAN_IMPLEMENTATIONS\n")
list(APPEND tmp "${impls}")
list(APPEND tmp ")\n")
list(APPEND tmp "set(PLAN_TYPES\n")
list(APPEND tmp "${types}")
list(APPEND tmp ")\n")
string(REPLACE "\n;" "\n" tmpoutStr "${tmp}")

if(NOT OUTPUT_LOCATION)
    set(OUTPUT_LOCATION "cmake/plans/${abi}_plan.cmake")
endif()

message("Created new build plan for [${abi}]")
message("${tempOutStr}")
message("Writing plan to [${OUTPUT_LOCATION}]")

file(WRITE "${OUTPUT_LOCATION}" "${tmpoutStr}")
