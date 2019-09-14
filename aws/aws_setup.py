#!/usr/bin/env python

import argparse
import csv
import os


def load_settings(filename="aws-settings.csv", skip_rows=1):
    with open(filename) as f:
        table = csv.reader(f, delimiter=',')
        table = list(table)
    d = {}
    for i, row in enumerate(table):
        if i < skip_rows:
            continue
        d[row[0]] = row[1]
    return d


def main():
    settings = load_settings()
    print(settings)


if __name__ == "__main__":
    main()
