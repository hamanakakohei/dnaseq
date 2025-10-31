#!/bin/bash
set -euo pipefail


SAMPLE_CRAM_LIST=inputs/sample_cram.txt

START=1
END=$(wc -l < "$SAMPLE_CRAM_LIST")


# 1
qsub -t ${START}-${END}:1 -tc 1 qsubs/01.qsub


# 1_qc
./scripts/01_qc.sh


# 2
while read SAMPLE CRAM; do
  CONTAMI_LEVEL=$(tail -n1 results/01/$SAMPLE/out.txt | sed 's/FREEMIX(Alpha)://')
  echo $SAMPLE $CONTAMI_LEVEL 
done < $SAMPLE_CRAM_LIST > results/02/summary.txt
