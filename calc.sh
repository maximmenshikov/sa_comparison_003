#!/bin/sh
# Script to perform comparison of few static analysis utilities on
# Toyota ITC benchmarks.
# (C) Maxim Menshchikov 2017

root=$(pwd)
bench=${root}/itc-benchmarks
parsers=${root}/sa_parsers

echo Results > result_final.txt
echo Clang >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.evaluated/clang_evaluated.txt ${bench} >> result_final.txt
echo Cppcheck >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.evaluated/cppcheck_evaluated.txt ${bench} >> result_final.txt
echo Frama-C >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.evaluated/framac_evaluated.txt ${bench} >> result_final.txt
echo PVS Studio >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.evaluated/pvs_evaluated.txt ${bench} >> result_final.txt
echo Resharper >> result_final.txt
${parsers}/report_calc/bin/Debug/report_calc.exe 03.evaluated/resharper_evaluated.txt ${bench} >> result_final.txt