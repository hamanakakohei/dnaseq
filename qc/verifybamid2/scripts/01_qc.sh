#!/bin/bash
# 1: ログの行数
# 2: ログのファイルサイズ
# 3: ログにERROR, Error, errorが含まれていないか
# 4: 出力結果のサンプルディレクトリ数
# 5: サンプル毎の出力結果ファイル数
# 6: out.txtが何個あるか
# 7: result.Ancestryが何個あるか
# 8: result.selfSMが何個あるか
# 9: out.txtのファイルサイズ
# 10: result.Ancestryのファイルサイズ
# 11: result.selfSMのファイルサイズ
set -euo pipefail

OUT_DIR=results/01_qc/
mkdir -p $OUT_DIR

ls logs/01/*.log | wc -l > ${OUT_DIR}1.log
ls -l logs/01/   | awk '{print $5,$9}' | sort -n > ${OUT_DIR}2.log
ls logs/01/      | xargs -I{} bash -c 'echo -n {}" "; grep -e RROR -e rror -e found logs/01/{} || true; echo -e ""' > ${OUT_DIR}3.log
ls results/01/   | wc -l > ${OUT_DIR}4.log
ls results/01/   | xargs -I{} bash -c 'echo -n {}" "; ls results/01/{} | wc -l' | sort -k2,2n > ${OUT_DIR}5.log
ls results/01/*/out.txt          | wc -l > ${OUT_DIR}6.log
ls results/01/*/result.Ancestry | wc -l > ${OUT_DIR}7.log
ls results/01/*/result.selfSM   | wc -l > ${OUT_DIR}8.log
ls -l results/01/*/out.txt          | awk '{print $5,$9}' | sort -n > ${OUT_DIR}9.log
ls -l results/01/*/result.Ancestry | awk '{print $5,$9}' | sort -n > ${OUT_DIR}10.log
ls -l results/01/*/result.selfSM   | awk '{print $5,$9}' | sort -n > ${OUT_DIR}11.log
