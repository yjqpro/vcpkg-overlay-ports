vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(CAF_TOOL_PATH )
if (VCPKG_TARGET_IS_WINDOWS AND (TRIPLET_SYSTEM_ARCH STREQUAL arm OR TRIPLET_SYSTEM_ARCH STREQUAL arm64))
    if (EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/caf-generate-enum-strings.exe)
        set(CAF_TOOL_PATH ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/)
    elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows-static/tools/caf-generate-enum-strings.exe)
        set(CAF_TOOL_PATH ${CURRENT_INSTALLED_DIR}/../x86-windows-static/tools/)
    elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x64-windows/tools/caf-generate-enum-strings.exe AND CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
        set(CAF_TOOL_PATH ${CURRENT_INSTALLED_DIR}/../x64-windows/tools/)
    elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x64-windows-static/tools/caf-generate-enum-strings.exe AND CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
        set(CAF_TOOL_PATH ${CURRENT_INSTALLED_DIR}/../x64-windows-static/tools/)
    else()
        message(FATAL_ERROR "Since caf needs to run the built-in executable, please install caf:x86-windows or caf:x64-windows first.")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO actor-framework/actor-framework
    REF 1c12c214399432960609f257a550a6ab8b22a754
    SHA512 280f5707f1ff75db7d47be9f3db85dea6722fef641c6041d9a3bed6d363399132865d7f0d24c788c9abc5a73d46662eb98dd6dd14ff411f9554acc7a0889209b
    HEAD_REF master
    PATCHES
        # openssl-version-override.patch
        fix-arm.patch
        fix-build-config-hpp.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCAF_BUILD_STATIC=ON
        -DCAF_BUILD_STATIC_ONLY=ON
        -DCAF_ENABLE_EXAMPLES=OFF
        -DCAF_ENABLE_IO_MODULE=OFF
        -DCAF_TOOL_PATH=${CAF_TOOL_PATH}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/caf)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/caf RENAME copyright)

vcpkg_copy_pdbs()
