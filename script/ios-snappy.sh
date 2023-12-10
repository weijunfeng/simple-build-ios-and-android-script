# MIT License

# Copyright (c) 2020 asteriskzuo

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#!/bin/sh

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  AsteriskZuo                                        #" >/dev/null
echo "# Update Date:             2020.05.28                                         #" >/dev/null
echo "# Script version:          1.0.0                                              #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/simple-build-ios-and-android-script     #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# Build ios snappy shell script.                                            #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/openssl_for_ios_and_android             #" >/dev/null
echo "###############################################################################" >/dev/null

# set -x

snappy_zip_file=""
snappy_zip_file_no_suffix=""
snappy_zip_file_path=""
snappy_zip_file_no_suffix_path=""
snappy_input_dir=""
snappy_output_dir=""
snappy_command=protoc

function ios_snappy_printf_variable() {
    log_var_print "snappy_input_dir =                $snappy_input_dir"
    log_var_print "snappy_output_dir =               $snappy_output_dir"
    log_var_print "snappy_zip_file =                 $snappy_zip_file"
    log_var_print "snappy_zip_file_no_suffix =       $snappy_zip_file_no_suffix"
    log_var_print "snappy_zip_file_path =            $snappy_zip_file_path"
    log_var_print "snappy_zip_file_no_suffix_path =  $snappy_zip_file_no_suffix_path"
}

function ios_snappy_pre_tool_check() {

    # snappy-3.11.4 need mac version > 10.3
    local mac_version=$(util_get_mac_version)
    local mac_version_list=($(echo ${mac_version} | sed "s/\./ /g"))
#    if test ${#mac_version_list[@]} -lt 3; then
#        common_die "get mac version error!"
#    fi
    export MACOSX_DEPLOYMENT_TARGET="10.8"

#    local snappy_version=$(protoc --version)
#    util_is_in "$COMMON_LIBRARY_VERSION" "$snappy_version" || common_die "snappy is not installed on the system, see the snappy installation instructions. (ref: https://github.com/protocolbuffers/snappy/blob/master/src/README.md)"

    snappy_input_dir="${COMMON_INPUT_DIR}/${COMMON_LIBRARY_NAME}"
    snappy_output_dir="${COMMON_OUTPUT_DIR}/${COMMON_PLATFORM_TYPE}/${COMMON_LIBRARY_NAME}"

    snappy_zip_file="${COMMON_DOWNLOAD_ADRESS##*/}"
    snappy_zip_file_no_suffix=$(util_remove_substr "cpp-" ${snappy_zip_file%.tar.gz})
    snappy_zip_file_path="${snappy_input_dir}/${snappy_zip_file}"
    snappy_zip_file_no_suffix_path="${snappy_input_dir}/${snappy_zip_file_no_suffix}"

    util_create_dir "${snappy_input_dir}"
    util_create_dir "${snappy_output_dir}"

    ios_snappy_printf_variable

}

function ios_snappy_pre_download_zip() {
    local library_id=$1
    util_download_file "$COMMON_DOWNLOAD_ADRESS" "$snappy_zip_file_path"
}

function ios_snappy_build_unzip() {
    local library_id=$1
    util_unzip2 "$snappy_zip_file_path" "${snappy_input_dir}" "$snappy_zip_file_no_suffix"
}

function ios_snappy_build_config_make() {
    local library_id=$1
    local library_arch=$2

    local library_arch_path="${snappy_output_dir}/${library_arch}"
    util_remove_dir "$library_arch_path"
    util_create_dir "${library_arch_path}/log"

    ios_printf_arch_variable

    pushd .
    cd "$snappy_zip_file_no_suffix_path"
    mkdir -p build
    cd build
    pwd

    if [[ "${library_arch}" == "x86-64" ]]; then
        cmake -DSNAPPY_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX="$library_arch_path" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/Users/weijunfeng/Desktop/gcc/ssl/simple-build-ios-and-android-script/script/toolchain/iOS_64.cmake -DCMAKE_SYSTEM_NAME="${COMMON_PLATFORM_TYPE}"  -DCMAKE_SYSTEM_VERSION="${IOS_API}" .. >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"
#        cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain/iOS_64.cmake  -DCMAKE_IOS_DEVELOPER_ROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/  -GXcode .. >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"
    elif [[ "${library_arch}" == "armv7" ]]; then
        cmake -DSNAPPY_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX="$library_arch_path" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/Users/weijunfeng/Desktop/gcc/ssl/simple-build-ios-and-android-script/script/toolchain/iOS_32.cmake -DCMAKE_SYSTEM_NAME="${COMMON_PLATFORM_TYPE}"  -DCMAKE_SYSTEM_VERSION="${IOS_API}" .. >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"
#        cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain/iOS_32.cmake  -DCMAKE_IOS_DEVELOPER_ROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/  -GXcode .. >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"
    elif [[ "${library_arch}" == "arm64" ]]; then
        cmake -DSNAPPY_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX="$library_arch_path" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/Users/weijunfeng/Desktop/gcc/ssl/simple-build-ios-and-android-script/script/toolchain/iOS_64.cmake -DCMAKE_SYSTEM_NAME="${COMMON_PLATFORM_TYPE}"  -DCMAKE_SYSTEM_VERSION="${IOS_API}" .. >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"
#        cmake -DCMAKE_TOOLCHAIN_FILE=/Users/weijunfeng/Desktop/gcc/ssl/simple-build-ios-and-android-script/script/toolchain/iOS_64.cmake  -DCMAKE_IOS_DEVELOPER_ROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/  -GXcode .. >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"
    elif [[ "${library_arch}" == "arm64e" ]]; then
        cmake -DSNAPPY_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX="$library_arch_path" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/Users/weijunfeng/Desktop/gcc/ssl/simple-build-ios-and-android-script/script/toolchain/iOS_64.cmake -DCMAKE_SYSTEM_NAME="${COMMON_PLATFORM_TYPE}"  -DCMAKE_SYSTEM_VERSION="${IOS_API}" .. >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"
#        cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain/iOS_64.cmake  -DCMAKE_IOS_DEVELOPER_ROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/  -GXcode .. >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"
#        ./configure --host=$(ios_get_build_host "${library_arch}") --prefix="${library_arch_path}" --disable-shared >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    else
        common_die "not support $library_arch"
    fi
#        common_build_make "${library_arch_path}" "clean" "-j$(util_get_cpu_count)" "install"
        xcodebuild -project "$snappy_zip_file_no_suffix_path"/Project.xcodeproj -alltargets -sdk iphoneos"${IOS_SDK_VERSION}" -configuration Release
    popd
}

function ios_snappy_archive() {
    local library_id=$1
    local static_library_list=()
    for ((i = 0; i < ${#IOS_ARCHS[@]}; i++)); do
        local static_library_file_path="${snappy_output_dir}/${IOS_ARCHS[i]}/lib/lib${COMMON_LIBRARY_NAME}.a"
        if [ -f "$static_library_file_path" ]; then
            static_library_list[${#static_library_list[@]}]="$static_library_file_path"
        fi
    done
    if [ 0 -lt ${#static_library_list[@]} ]; then
        util_remove_dir "${snappy_output_dir}/lipo"
        util_create_dir "${snappy_output_dir}/lipo"
        lipo ${static_library_list[@]} -create -output "${snappy_output_dir}/lipo/lib${COMMON_LIBRARY_NAME}-universal.a"
    fi
}
