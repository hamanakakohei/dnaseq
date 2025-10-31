#!/usr/bin/env python3

import argparse
import os
from glob import glob
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def parse_args():
    parser = argparse.ArgumentParser(description="Summarize and plot norm counts for motif and locus files.")
    parser.add_argument("--input_dir", default='results/01/', help="Input directory containing .tsv files")
    parser.add_argument("--out_dir", default='results/02/', help="Directory to save plots and tables")
    parser.add_argument("--out_hist_prefix", default='hist', help="Prefix for output histogram files")
    parser.add_argument("--out_table_prefix", default='table', help="Prefix for output summary table files")
    return parser.parse_args()


def process_files(file_paths, thresholds, value_column, suffix_to_strip):
    summary = []

    for file_path in file_paths:
        df = pd.read_csv(file_path, sep="\t")
        sample = os.path.basename(file_path).replace(suffix_to_strip, "")
        row = {"Sample": sample}
        for t in thresholds:
            row[f"more_than_{t}"] = (df[value_column] > t).sum()
        summary.append(row)

    summary_df = pd.DataFrame(summary)
    summary_df.set_index("Sample", inplace=True)
    return summary_df


def plot_histograms_summary(summary_df, thresholds, bin_width, out_path, title_prefix):
    n = len(thresholds)
    fig, axes = plt.subplots(n, 1, figsize=(10, 5 * n), constrained_layout=True)

    for i, t in enumerate(thresholds):
        col = f"more_than_{t}"
        data = summary_df[col].dropna()

        min_edge = (data.min() // bin_width) * bin_width
        max_edge = ((data.max() // bin_width) + 1) * bin_width
        bins = np.arange(min_edge, max_edge + bin_width, bin_width)

        ax = axes[i] if n > 1 else axes
        ax.hist(data, bins=bins, edgecolor='black', alpha=0.7)
        ax.set_title(f"{title_prefix}: {col} (bin width = {bin_width})")
        ax.set_xlabel(f"Number of locus or motif with {col} norm count")
        ax.set_ylabel("Frequency")

    plt.savefig(out_path)
    plt.close()


def main():
    args = parse_args()

    thresholds = [1, 2, 5, 10]
    os.makedirs(args.out_dir, exist_ok=True)

    # motifファイル一覧取得
    motif_files = glob(os.path.join(args.input_dir, "**", "*.ehdn.profile.motif.tsv"), recursive=True)
    motif_summary_df = process_files(motif_files, thresholds, "norm_num_paired_irrs", ".ehdn.profile.motif.tsv")
    motif_table_path = os.path.join(args.out_dir, f"{args.out_table_prefix}_motif.tsv")
    motif_summary_df.to_csv(motif_table_path, sep="\t")

    # locusファイル一覧取得
    locus_files = glob(os.path.join(args.input_dir, "**", "*.ehdn.profile.locus.tsv"), recursive=True)
    locus_summary_df = process_files(locus_files, thresholds, "norm_num_anc_irrs", ".ehdn.profile.locus.tsv")
    locus_table_path = os.path.join(args.out_dir, f"{args.out_table_prefix}_locus.tsv")
    locus_summary_df.to_csv(locus_table_path, sep="\t")

    # motifヒストグラムまとめて1枚の画像に
    bin_width = 1
    motif_hist_path = os.path.join(args.out_dir, f"{args.out_hist_prefix}_motif_summary.png")
    plot_histograms_summary(motif_summary_df, thresholds, bin_width, motif_hist_path, "Motif")

    # locusヒストグラムまとめて1枚の画像に
    bin_width = 5
    locus_hist_path = os.path.join(args.out_dir, f"{args.out_hist_prefix}_locus_summary.png")
    plot_histograms_summary(locus_summary_df, thresholds, bin_width, locus_hist_path, "Locus")


if __name__ == "__main__":
    main()
