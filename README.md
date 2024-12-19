# un_data_pipeline
This repository contains instructions and scripts for the data pipeline for the annotation of the UN Parallel corpus.

### Table of Content
1. [UN Parallel Corpus to CSV](#from-un-parallel-corpus-to-csv)
2. [From CSV to Filtered Batches for Label Studio](#from-csv-to-filtered-batches-for-label-studio-simple-filter)
3. [From CSV to Filtered Batches using an Existing Model](#from-csv-to-filtered-batches-using-an-existing-model)
4. [Starting a Label Studio Project](#starting-a-label-studio-project)
5. [From JSON exported from Label Studio to TSV](#from-json-exported-from-label-studio-to-tsv)

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

Note: These files may need to be edited for your file system.

1. Run `3_select_ALL.R` to generate 5 batches of 100,000 sentences from the UN corpus.
2. Run `run_filter.sh` to generate binary predictions using binary_predict.sh for each QuadClass category.
3. Run the Jupyter Notebook file `process_UN_filtered_data.ipynb` to combine these predictions into a balanced csv and create batches of 180 sentences for them.

## Starting a Label Studio Project

1. Click "Create Project" and select the desired workspace (likely UN_data).
2. In the data import tab, select the desired batch.
3. In the labeling setup tab, add the labeling interface by selecting "Custom template" and copying the XML markup for your project into the input box.
4. Once created, add the desired members in the members tab of the project.
5. Assign annotations by selecting all annotations in the data manager tab and selecting "assign annotators".

## From JSON exported from Label Studio to TSV

1. Export the annotations from Label Studio by creating a snapshot in the data manager tab and downloading the full JSON version.
2. Run `process_json_to_tsv.py` with the directory containing the JSON files you wish to process as the only argument.
3. Now the exported TSVs for input into a model should be in the parent directory of JSON directory.