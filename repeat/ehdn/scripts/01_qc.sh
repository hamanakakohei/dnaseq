#!/bin/bash
set -euo pipefail

OUT_DIR=results/01_qc/
mkdir -p $OUT_DIR

ls logs/01/*.log | wc -l > ${OUT_DIR}1.log
ls -l logs/01/   | awk '{print $5,$9}' | sort -n > ${OUT_DIR}2.log
ls logs/01/      | xargs -I{} bash -c 'echo -n {}" "; grep -e RROR -e rror -e found logs/01/{} || true; echo -e ""' > ${OUT_DIR}3.log
ls results/01/   | wc -l > ${OUT_DIR}4.log
ls results/01/   | xargs -I{} bash -c 'echo -n {}" "; ls results/01/{} | wc -l' | sort -k2,2n > ${OUT_DIR}5.log
ls results/01/*/*.ehdn.profile.locus.tsv        | wc -l > ${OUT_DIR}6.log
ls results/01/*/*.ehdn.profile.motif.tsv        | wc -l > ${OUT_DIR}7.log
ls results/01/*/*.ehdn.profile.reads.tsv        | wc -l > ${OUT_DIR}8.log
ls results/01/*/*.ehdn.profile.str_profile.json | wc -l > ${OUT_DIR}9.log
ls -l results/01/*/*.ehdn.profile.locus.tsv        | awk '{print $5,$9}' | sort -n > ${OUT_DIR}10.log
ls -l results/01/*/*.ehdn.profile.motif.tsv        | awk '{print $5,$9}' | sort -n > ${OUT_DIR}11.log
ls -l results/01/*/*.ehdn.profile.reads.tsv        | awk '{print $5,$9}' | sort -n > ${OUT_DIR}12.log
ls -l results/01/*/*.ehdn.profile.str_profile.json | awk '{print $5,$9}' | sort -n > ${OUT_DIR}13.log
