#!/bin/bash
set -euo pipefail

SAMPLE_CRAM_LIST=inputs/sample_cram.txt
REF=ref/Homo_sapiens_assembly38.fasta

MANIFEST=inputs/manifest2098.txt
PREFIX=manifest2098
ANNOVAR=annovar20250302/annotate_variation.pl
HUMAN_DB=annovar/201612/hg38

PROBANDS=inputs/probands.txt
CONTROLS=inputs/controls.txt
PROBAND_RELATIVE=inputs/proband-relative_pairs.txt # PEDか、その最初の2列のみでもok

N_SAMPLE=$(wc -l < "$SAMPLE_CRAM_LIST")


# 01 全サンプルでEHdn profileする
qsub -t 1-"$N_SAMPLE":1 -tc 10 qsubs/01.qsub \
  "$SAMPLE_CRAM_LIST" \
  "$REF"

bash scripts/01_qc.sh
find . -name str_profile.json
find `pwd`/results/01/ -name "*.str_profile.json" > results/01/str_profile_json.list


# 02 コールが多すぎるサンプルを見つける
# この結果を見てマニフェストファイルを編集して、03から再開する
## パターン1：condaで環境を一時的に立ち上げる場合
#conda run -n ehdn_env \
#  scripts/02_qc.py \
#  > logs/02/log 2>&1
# パターン2：sourceで環境を永続的に立ち上げる場合（下流の解析は問題なし）
(
  set +u
  source /usr/local/genome/python3-venv/env.sh
  scripts/02_qc.py > logs/02/log 2>&1
)


# 03 結果をマージして、outlier解析をして、Annovarをかける
scripts/03_ehdn_merge_and_outlier.sh \
  --manifest "$MANIFEST" \
  --prefix   results/03/"$PREFIX" \
  --ref      "$REF" \
  --annovar  "$ANNOVAR" \
  --human_db "$HUMAN_DB" \
  > logs/03/log 2>&1


# 04：アレル頻度を付けて、outlier motifとoutlier locus結果をマージする
N_SAMPLE=$(wc -l < "$PROBANDS")
qsub -t 1-"$N_SAMPLE":1 -tc 40 qsubs/04.qsub \
  "$PROBANDS" \
  "$CONTROLS" \
  "$PROBAND_RELATIVE" \
  "$PREFIX"
