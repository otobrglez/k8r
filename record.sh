#!/usr/bin/env bash
set -ex

rm -rf *.mp4 ./screens/*

STEP_FILES="./steps/step-*.dat"
for step in $STEP_FILES; do
    out_path="${step/steps/screens}"
    out_path="${out_path/dat/png}"
    gnuplot -e "load 'config.gp'; plot '$step' using 1:2:3 with points pointtype 109 pointsize 2 palette" > $out_path
done

ffmpeg -y \
    -i ./screens/step-%03d.png \
    -c:v libx264 \
    -vf fps=30 \
    -pix_fmt yuv420p \
    ./out.mp4
