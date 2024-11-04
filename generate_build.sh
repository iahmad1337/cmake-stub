#!/usr/bin/env sh
set -x

if [ ! -f ./CMakeLists.txt ]
then
    echo "This script should be launched from the project root"
    exit 1
fi

################################################################################
#                            Determining build type                            #
################################################################################

if [ "$#" -lt 1 ]
then
    echo "Please pass the build type (debug or release)"
    exit 1
fi
preset="$1"

################################################################################
#               Determining mechanism for fetching dependencies                #
################################################################################

additional_opts=""
if [ "$#" -lt 2 ]
then
    while true
    do
        read -p "Are you sure you want to continue without providing vcpkg root? (y/n)" answer
        case $answer in
            [Yy]* )
                echo "Proceeding with installation from urls"
                break;;
            [Nn]* )
                echo "Please relaunch the script and pass vcpkg root as the second argument. Aborting"
                exit 0
                break;;
            * ) echo "Please answer with 'y' or 'n'.";;
        esac
    done
else
    VCPKG_ROOT="$2"
    additional_opts="$additional_opts -DUSE_VCPKG=ON -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
    additional_opts="$additional_opts -DVCPKG_TARGET_TRIPLET=x64-linux-clang"
    additional_opts="$additional_opts -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$VCPKG_ROOT/triplets/clang-toolchain.cmake"
fi

# NOTE: the second variable is not quoted because I want it to be split
cmake -S . --preset=$preset $additional_opts

cp --force "$preset/compile_commands.json" .
