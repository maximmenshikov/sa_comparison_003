#!/bin/sh
# Script to perform comparison of few static analysis utilities on
# Toyota ITC benchmarks.
# (C) Maxim Menshchikov 2017

root=$(pwd)
bench=${root}/itc-benchmarks
parsers=${root}/sa_parsers

echo Results > result_final.txt
echo Clang >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.scored/clang_scored.txt ${bench} >> result_final.txt
echo Cppcheck >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.scored/cppcheck_scored.txt ${bench} >> result_final.txt
echo Frama-C >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.scored/framac_scored.txt ${bench} >> result_final.txt
echo PVS Studio >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.scored/pvs_scored.txt ${bench} >> result_final.txt
echo Resharper >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.scored/resharper_scored.txt ${bench} >> result_final.txt