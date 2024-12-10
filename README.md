# un_data_pipeline
This repository contains instructions and scripts for the data pipeline for the annotation of the UN Parallel corpus.

### Table of Content
1. [UN Paralle Corpus to CSV](#from-un-parallel-corpus-to-csv)
2. [From CSV to Filtered Batches for Label Studio](#from-csv-to-filtered-batches-for-label-studio-simple-filter)
3. [From CSV to Filtered Batches using an Existing Model](#from-csv-to-filtered-batches-from-an-existing-model)

## From UN Parallel Corpus to CSV

Note: This corpus has already been compiled into CSVs of years. This file is available on Box in NSF_UNdata/data/UNv1.0-linked. However, if you need to regenerate these files, these are the instructions:
1. Download all XML and link files from the [UN Parallel Corpus](https://www.un.org/dgacm/en/content/uncorpus/Download)
2. Decompress the files and place them all into the same UNv1.0-TEI directory (i.e. UNv1.0-TEI/en, UNv1.0-TEI/ar, ...)
3. Organize the scripts and data into this file tree:
```
.
├── UNv1.0-TEI/
│   ├── ar
│   ├── en
│   ├── es
│   ├── fr
│   ├── ru
│   └── zh
└── get_sec_docs.py  
```
4. Run `python3 get_sec_docs.py`, no arguments are required for this purpose. This filters the UN Corpus to only contain documents related to the Security Council
  Now the file tree should look like this:
```
.
├── UNv1.0-TEI-S/
│   ├── UNv1.0.6way.ids
│   ├── ar
│   ├── en
│   ├── es
│   ├── fr
│   ├── ru
│   └── zh
├── get_sec_docs.py
└── create_parallel_corpus.py
```
6. Run `python3 create_parallel_corpus --csv` to create the linked year files in UNv1.0-linked

## From CSV to Filtered Batches for Label Studio (Simple Filter)
1. Run the R script `1_select_annotation_data_v7.R` with your working directory set to the directory which contains data/UNv1.0-linked (the year files)
2. This will result in 30 batches of 400 sentences formatted for Label Studio in annotations/data/batch_X.csv

## From CSV to Filtered Batches using an Existing Model
