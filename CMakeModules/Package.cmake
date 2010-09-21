# Enable printf format macros from <inttypes.h> in C++ code.
ADD_DEFINITIONS (-D__STDC_FORMAT_MACROS)

# Enable 64-bit off_t type to work with big files.
ADD_DEFINITIONS (-D_FILE_OFFSET_BITS=64)

# Enable ignore errors mode in Judy macros.
#ADD_DEFINITIONS (-DJUDYERROR_NOTEST)

SET (LIBDIR lib)
IF (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
  SET (LIBDIR lib64)
ENDIF (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")

# Don't know if this is needed with one monolith CMakeLists.txt file.
#SET (CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
#SET (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
#SET (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Make FIND_LIBRARY search for static libs only and make it search inside lib64
# directory in addition to the usual lib one.

#SET (CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})
SET (CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_STATIC_LIBRARY_PREFIX})
SET (FIND_LIBRARY_USE_LIB64_PATHS TRUE)
SET (LINK_SEARCH_END_STATIC TRUE)

# Include source tree root, include directory inside it and build tree root,
# which is for files, generated by cmake from templates (e.g. autogenerated
# C/C++ includes).

INCLUDE_DIRECTORIES (${PROJECT_BINARY_DIR})
INCLUDE_DIRECTORIES (${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES (${PROJECT_SOURCE_DIR}/include)

# USE_LIBRARY (var lib)
# -----------------------------------------------------------------------------
# Find library [lib] using standard FIND_LIBRARY command and save its path into
# variable named [var].

MACRO (USE_LIBRARY var lib)
  FIND_LIBRARY (${var} ${lib})
  IF (${var})
    MESSAGE (STATUS "FOUND ${${var}}")  # SHOULD BE BOLD GREEN
  ELSE (${var})
    MESSAGE (STATUS "ERROR ${${var}}")  # SHOULD BE BOLD RED
  ENDIF (${var})
ENDMACRO (USE_LIBRARY)

# USE_INCLUDE (var inc [FIND_PATH_ARGS ...])
# -----------------------------------------------------------------------------
# Find include [inc] using standard FIND_PATH command and save its dirname into
# variable named [var]. Also include its dirname into project.

MACRO (USE_INCLUDE var inc)
  FIND_PATH (${var} ${inc} ${ARGN})
  IF (${var})
    MESSAGE (STATUS "FOUND ${${var}}/${inc}")  # SHOULD BE BOLD GREEN
    INCLUDE_DIRECTORIES (${${var}})
  ELSE (${var})
    MESSAGE (STATUS "ERROR ${${var}}/${inc}")  # SHOULD BE BOLD RED
  ENDIF (${var})
ENDMACRO (USE_INCLUDE)

# USE_SUBPATH (var sub)
# -----------------------------------------------------------------------------
# Find subpath [sub] using standard FIND_PATH command and save its dirname into
# variable named [var].

MACRO (USE_SUBPATH var sub)
  FIND_PATH (${var}_PREFIX ${sub} ONLY_CMAKE_FIND_ROOT_PATH)
  IF (${var}_PREFIX)
    GET_FILENAME_COMPONENT (${var} "${${var}_PREFIX}/${sub}" PATH)
    MESSAGE (STATUS "FOUND ${var}=${${var}}")
  ELSE (${var}_PREFIX)
    MESSAGE (STATUS "ERROR ${var}")
  ENDIF (${var}_PREFIX)
ENDMACRO (USE_SUBPATH)

# USE_PACKAGE (var lib inc [FIND_PATH_ARGS ...])
# -----------------------------------------------------------------------------
# Find package using USE_LIBRARY and USE_INCLUDE macros.

MACRO (USE_PACKAGE var lib inc)
  IF (NOT ${lib} STREQUAL "NO_LIB")
    USE_LIBRARY (LIB_${var} ${lib})
  ENDIF (NOT ${lib} STREQUAL "NO_LIB")
  IF (NOT ${inc} STREQUAL "NO_INC")
    USE_INCLUDE (INC_${var} ${inc} ${ARGN})
  ENDIF (NOT ${inc} STREQUAL "NO_INC")
ENDMACRO (USE_PACKAGE)

# USE_PKG (pkg)
# -----------------------------------------------------------------------------
# Find package using USE_PACKAGE and some heuristic on naming traditions.

MACRO (USE_PKG pkg)
  STRING (TOUPPER ${pkg} var)
  USE_PACKAGE (${var} ${pkg} ${pkg}.h)
ENDMACRO (USE_PKG)

# GET_LOCALTIME (var [format [tmzone]])
# -----------------------------------------------------------------------------
# Print system date and time regarding to specified [format] and [tmzone]. If
# either [format] or [tmzone] is omitted, the default settings for the current
# locale will take the place.

#MACRO (GET_LOCALTIME var format tmzone) # XXX make variadic
#  SET_IF_NOT_SET (o_format "${format}")
#  SET_IF_NOT_SET (o_format "%c")
#  SET_IF_NOT_SET (o_tmzone "${tmzone}")
#  SET_IF_NOT_NIL (o_tmzone "-d'now GMT${o_tmzone}'")
#  ADD_CUSTOM_COMMAND (OUTPUT var COMMAND "date +'${o_format}' ${o_tmzone}")
#ENDMACRO (GET_LOCALTIME)

