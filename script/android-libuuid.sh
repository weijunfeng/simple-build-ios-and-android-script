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
echo "# Build android libuuid shell script.                                        #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/openssl_for_ios_and_android             #" >/dev/null
echo "###############################################################################" >/dev/null

# set -x

libuuid_zip_file=""
libuuid_zip_file_no_suffix=""
libuuid_zip_file_path=""
libuuid_zip_file_no_suffix_path=""
libuuid_input_dir=""
libuuid_output_dir=""

function android_libuuid_printf_variable() {
    log_var_print "libuuid_input_dir =                $libuuid_input_dir"
    log_var_print "libuuid_output_dir =               $libuuid_output_dir"
    log_var_print "libuuid_zip_file =                 $libuuid_zip_file"
    log_var_print "libuuid_zip_file_no_suffix =       $libuuid_zip_file_no_suffix"
    log_var_print "libuuid_zip_file_path =            $libuuid_zip_file_path"
    log_var_print "libuuid_zip_file_no_suffix_path =  $libuuid_zip_file_no_suffix_path"
}

function android_libuuid_pre_tool_check() {

#    local libuuid_version=$(protoc --version)
#    util_is_in "$COMMON_LIBRARY_VERSION" "$libuuid_version" || common_die "libuuid is not installed on the system, see the libuuid installation instructions. (ref: https://github.com/protocolbuffers/libuuid/blob/master/src/README.md)"

    libuuid_input_dir="${COMMON_INPUT_DIR}/${COMMON_LIBRARY_NAME}"
    libuuid_output_dir="${COMMON_OUTPUT_DIR}/${COMMON_PLATFORM_TYPE}/${COMMON_LIBRARY_NAME}"

    libuuid_zip_file="${COMMON_DOWNLOAD_ADRESS##*/}"
    libuuid_zip_file_no_suffix=$(util_remove_substr "cpp-" ${libuuid_zip_file%.tar.gz})
    libuuid_zip_file_path="${libuuid_input_dir}/${libuuid_zip_file}"
    libuuid_zip_file_no_suffix_path="${libuuid_input_dir}/${libuuid_zip_file_no_suffix}"

    util_create_dir "${libuuid_input_dir}"
    util_create_dir "${libuuid_output_dir}"

    android_libuuid_printf_variable

}

function android_libuuid_pre_download_zip() {
    local library_id=$1
    util_download_file "$COMMON_DOWNLOAD_ADRESS" "$libuuid_zip_file_path"
}

function android_libuuid_build_unzip() {
    local library_id=$1
    util_unzip2 "$libuuid_zip_file_path" "${libuuid_input_dir}" "$libuuid_zip_file_no_suffix"
}

function android_libuuid_build_config_make() {
    local library_id=$1
    local library_arch=$2

    local library_arch_path="${libuuid_output_dir}/${library_arch}"
    util_remove_dir "$library_arch_path"
    util_create_dir "${library_arch_path}/log"

    export LDFLAGS="$LDFLAGS -Wunused-command-line-argument -llog"

    android_printf_arch_variable

    pushd .
    cd "$libuuid_zip_file_no_suffix_path"

    # git submodule update --init --recursive
    if [[ "${library_arch}" == "x86-64" ]]; then

        # scc_info_FileDescriptorProto_google_2flibuuid_2fdescriptor_2eproto , so use --disable-shared
        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --disable-shared  >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "x86" ]]; then

        # scc_info_FileDescriptorProto_google_2flibuuid_2fdescriptor_2eproto , so use --disable-shared
        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --disable-shared  >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "armeabi-v7a" ]]; then

        # scc_info_FileDescriptorProto_google_2flibuuid_2fdescriptor_2eproto , so use --disable-shared
        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --disable-shared  >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "arm64-v8a" ]]; then

        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}"  >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    else
        common_die "not support $library_arch"
    fi

    common_build_make "${library_arch_path}" "clean" "-j$(util_get_cpu_count)" "install"

    popd
}

function android_libuuid_archive() {
    local library_name=$1
}