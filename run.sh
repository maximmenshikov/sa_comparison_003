#!/bin/sh
# Script to perform comparison of few static analysis utilities on
# Toyota ITC benchmarks.
# (C) Maxim Menshchikov 2017

git clone https://github.com/mmenshchikov/itc-benchmarks.git

root=$(pwd)
bench=${root}/itc-benchmarks

git clone https://github.com/mmenshchikov/sa_parsers.git
parsers=${root}/sa_parsers
xbuild ${parsers}/sa_parsers.sln

# Run cppcheck
rm "${root}/result_cppcheck.txt"
cd ${bench}/01.w_Defects
echo "######## 01.w_Defects" >> "${root}/result_cppcheck.txt"
cppcheck . 2>> "${root}/result_cppcheck.txt"
echo "######## 02.wo_Defects" >> "${root}/result_cppcheck.txt"
cd ${bench}/02.wo_Defects
cppcheck . 2>> "${root}/result_cppcheck.txt"

# Run Clang
rm -rf "${root}/result_clang"
cd $bench
./bootstrap
./configure
make clean
mkdir "${root}/result_clang"
scan-build-3.9 -v -o "${root}/result_clang" make

# Run Frama-C
rm "${root}/result_frama-c.txt"
cd ${bench}/01.w_Defects
echo "######## 01.w_Defects" >> "${root}/result_frama-c.txt"
frama-c -cpp-extra-args="-I../include -isystem $(frama-c -print-share-path)/libc -isystem /usr/include -include ${root}/gnuc_prereq.h -D__FC_DEFINE_PID_T" \
        -val $(ls *.c | grep -v "extern_1" | grep -v "invalid_memory_access.c" | grep -v "st_overflow.c" | grep -v "st_underrun.c" | xargs) \
        >> ${root}/result_frama-c.txt
echo "######## 02.wo_Defects" >> "${root}/result_frama-c.txt"
cd ${bench}/02.wo_Defects
frama-c -cpp-extra-args="-I../include -isystem $(frama-c -print-share-path)/libc -isystem /usr/include -include ${root}/gnuc_prereq.h -D__FC_DEFINE_PID_T" \
        -val $(ls *.c | grep -v "extern_1" | grep -v "invalid_memory_access.c" | grep -v "st_overflow.c" | grep -v "st_underrun.c" | xargs) \
        >> ${root}/result_frama-c.txt

# Build PVS-Studio comment inserting utility
cd ${root}
git clone https://github.com/viva64/how-to-use-pvs-studio-free.git
cd how-to-use-pvs-studio-free
mkdir build
cd build
pvs_root=$(pwd)
cmake -DCMAKE_BUILD_TYPE=Release ..
make
cd ${root}
cp -R itc-benchmarks ./pvs_code
cd pvs_code
make clean

# Insert comments
${pvs_root}/how-to-use-pvs-studio-free -c 1 .

# Analyze
mkdir -p "${root}/result_pvs"
pvs-studio-analyzer trace -o "${root}/result_pvs/strace_out" -- make
pvs-studio-analyzer analyze -f "${root}/result_pvs/strace_out" -o "${root}/result_pvs/project.log"
plog-converter -a GA:1,2 -t tasklist -o "${root}/result_pvs/project.tasks" "${root}/result_pvs/project.log"

cd ${root}
# Run parsers
${parsers}/framac_parser/bin/Debug/framac_parser.exe result_frama-c.txt result_frama-c2.txt > parsed_framac.txt
${parsers}/clang_parser/bin/Debug/clang_parser.exe result_clang > parsed_clang.txt
${parsers}/cppcheck_parser/bin/Debug/cppcheck_parser.exe result_cppcheck.txt > parsed_cppcheck.txt
${parsers}/pvs_parser/bin/Debug/pvs_parser.exe result_pvs/project.tasks > parsed_pvs.txt
