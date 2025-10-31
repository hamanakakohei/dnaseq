#!/bin/bash
set -euo pipefail


# 引数
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


# 変数
REF_DIR=$(dirname "$REF")
REF_BASE=$(basename "$REF")
BAM_DIR=$(dirname "$BAM")
BAM_BASE=$(basename "$BAM")
SVD_DIR=$(dirname "$SVD")
SVD_PREFIX=$(basename "$SVD")


# 実行
mkdir -p results/01/$SAMPLE

docker run \
  -u $(id -u):$(id -g) \
  --rm \
  -v $REF_DIR:/ref \
  -v $BAM_DIR:/bam \
  -v $SVD_DIR:/svd \
  -v `pwd`/results/01/$SAMPLE:/out \
  -w /out \
  griffan/verifybamid2:latest \
  VerifyBamID \
    --Reference /ref/$REF_BASE \
    --BamFile /bam/$BAM_BASE \
    --SVDPrefix /svd/$SVD_PREFIX \
    --NumThread $THREADS \
    --Verbose \
    > results/01/$SAMPLE/out.txt 
    #--NumPC
