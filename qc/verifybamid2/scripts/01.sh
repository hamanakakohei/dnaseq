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
  -v /your_root_dir1:/your_root_dir1 \
  -v /your_root_dir2:/your_root_dir2 \
  -v `pwd`:`pwd` \
  griffan/verifybamid2:latest \
  VerifyBamID \
    --Reference $REF \
    --BamFile   $BAM \
    --SVDPrefix $SVD \
    --NumThread $THREADS \
    --Verbose \
    > results/01/$SAMPLE/out.txt
    #--NumPC
