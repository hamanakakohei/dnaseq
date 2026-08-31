#!/bin/bash
set -euo pipefail


while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)        REF="$2"; shift ;;
    --bam)        BAM="$2"; shift ;;
    --sample)     SAMPLE="$2"; shift ;;
    --svd_prefix) SVD="$2"; shift ;;
    --threads)    THREADS="$2"; shift ;;
    *) echo "Unknown argument: $1" >&2 ; exit 1 ;;
  esac
  shift
done


mkdir -p results/01/$SAMPLE


docker run \
  -u $(id -u):$(id -g) \
  --rm \
  -v /antares01:/antares01 \
  -v /betelgeuse10:/betelgeuse10 \
  -v `pwd`:`pwd` \
  -w `pwd`/results/01/$SAMPLE \
  griffan/verifybamid2:latest \
  VerifyBamID \
    --Reference $REF \
    --BamFile   $BAM \
    --SVDPrefix $SVD \
    --NumThread $THREADS \
    --Verbose \
    > results/01/$SAMPLE/out.txt
    #--NumPC
