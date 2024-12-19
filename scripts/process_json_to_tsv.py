'''
File: process_json_to_tsv.py
Author: Amber Converse
Purpose: This script converts the exported JSON from Label Studio to tsvs for
    downstream tasks. The following types of files are created:
        * Multi-Label - tsv containing the text field and a binary vector with a field for
            each coded category. For mult-label classification only
        * Multi-Class - tsv containing the text field and a field with a number for each
            coded category (0 = irrelvant, 1 = VerConf, 2 = MatConf, 3 = VerCoop, 4 = MatCoop)
        * Multi-Class One-Hot Binary Version - tsv containing the text field and a binary vector
            with a field for each coded category. This file is distinct from the multi-label version
            because the vector is a one hot binary vector, so texts with multiple labels have been
            excluded. For multi-class classification if one-hot binary vector format is preferred
        * Binary - tsv containing the text field and a field for relevancy (0 = irrelevant,
            1 = relevant). For binary classification
    Requires 1 argument: the directory of the json files to process
    Optional arguments: -r or --recover then the directory with the batch files to recover from
                        -f or --filter then a specific label for filter for ["irrelevant", "verconf", "irr_or_verconf"]
'''

import csv
import json
import pandas as pd
from pathlib import Path
import glob
from sklearn.preprocessing import MultiLabelBinarizer
import argparse

def standardize_labels(labels):
    new_labels = []
    for label in labels:
        new_individual_labels = []
        for individual_label in label:
            if individual_label in ["Verbal Conflict", "Material Conflict", \
                                    "Verbal Cooperation", "Material Cooperation"]:
                new_individual_labels.append(individual_label)
            elif individual_label == "MatConf":
                new_individual_labels.append("Material Conflict")
            elif individual_label == "MatCoop":
                new_individual_labels.append("Material Cooperation")
            elif individual_label == "VerConf":
                new_individual_labels.append("Verbal Conflict")
            elif individual_label == "VerCoop":
                new_individual_labels.append("Verbal Cooperation")
            else:
                print(f"Could not fix label: \"{individual_label}\"")
                assert False
        new_labels.append(new_individual_labels)
    return new_labels

def recover_language_data(id, recovery_df):
    filtered_df = recovery_df.loc[recovery_df["id"] == id]
    if not filtered_df.empty:
        return filtered_df.iloc[0]["ar"], filtered_df.iloc[0]["es"]
    assert False

def verbal_conflict(label):
    return label == ["Verbal Conflict"]

def irrelevant(label):
    return not label

def irrelevant_or_verbal_conflict(label):
    return verbal_conflict(label) or irrelevant(label)

def filter(texts, labels, criteria):
    filtered_texts = []
    filtered_labels = []
    for i, label in enumerate(labels):
        if criteria(label):
            filtered_texts.append(texts[i])
            filtered_labels.append(labels[i])
    return filtered_texts, filtered_labels

def read_json(json_file, recover=False, recovery_df=None):
    
    text_labels = []
    invalid_annotations = 0
    
    with open(json_file, 'r') as json_file:

        tasks = json.load(json_file)

        total_tasks = len(tasks)
        for task in tasks:
            
            task_annotations = []
            
            ground_truth = False
            for annotator in task["annotations"]:
                if annotator["ground_truth"]:
                    ground_truth = True
                    for annotation in annotator["result"]:
                        if annotation["type"] == "taxonomy":
                            for label in annotation["value"]["taxonomy"]:
                                task_annotations.append(label[0])
            
            task_annotations = list(set(task_annotations)) # Remove duplicates

            if recover:
                ar, es = recover_language_data(task["data"]["id"], recovery_df)
                task["data"]["ar"] = ar
                task["data"]["es"] = es
            
            if ground_truth:
                text_labels.append([[task["data"]["en"], task["data"]["es"], task["data"]["ar"], task["data"]["id"]], task_annotations])
            elif task["agreement"] == 100:
                    for annotation in task["annotations"][0]["result"]:
                        if annotation["type"] == "taxonomy":
                            for label in annotation["value"]["taxonomy"]:
                                task_annotations.append(label[0])
                    task_annotations = list(set(task_annotations)) # Remove duplicates
                    text_labels.append([[task["data"]["en"], task["data"]["es"], task["data"]["ar"], task["data"]["id"]], task_annotations])
            else:
                invalid_annotations += 1

    print(f"Discarded {invalid_annotations} invalid labels.")
    print(f"Loss of {invalid_annotations / total_tasks * 100}% of annotations.")
    return text_labels

def write_multilabel(texts, labels, dir):

    with open(Path(dir) / "quadclass/all_annotations_quad_multilabel_WITH_IDS.tsv", "w") as f:
        csv_writer = csv.writer(f, delimiter="\t", quotechar='"')
        csv_writer.writerow(["id","en","es","ar","MatConf","MatCoop","VerConf","VerCoop"])
        for i in range(len(texts)):
            csv_writer.writerow([texts[i][3], texts[i][0],texts[i][1],texts[i][2], \
                                labels[i][0],labels[i][1], \
                                labels[i][2],labels[i][3]])
    
    for j, lang in enumerate(["en","es","ar"]):
        with open(Path(dir) / f"quadclass/{lang}/{lang}_annotations_quad_multilabel_WITH_IDS.tsv", "w") as f:
            csv_writer = csv.writer(f, delimiter="\t", quotechar='"')
            csv_writer.writerow(["id",lang,"MatConf","MatCoop","VerConf","VerCoop"])
            for i in range(len(texts)):
                csv_writer.writerow([texts[i][3], texts[i][j], \
                                    labels[i][0],labels[i][1], \
                                    labels[i][2],labels[i][3]])
            
def write_multiclass(texts, labels, dir):

    with open(Path(dir) / "quadclass/all_annotations_quad_multiclass_WITH_IDS.tsv", "w") as f:
        csv_writer = csv.writer(f, delimiter="\t", quotechar='"')
        csv_writer.writerow(["id","en","es","ar","QuadClass"])
        for i in range(len(texts)):
            if sum(labels[i]) < 2:
                csv_writer.writerow([texts[i][3],texts[i][0],texts[i][1],texts[i][2], \
                                    0 if sum(labels[i]) == 0 else (labels[i] == 1).nonzero()[0][0] + 1])

    # Write One Hot Binary Version     
    with open(Path(dir) / "quadclass/all_annotations_quad_multiclass_ONE_HOT_WITH_IDS.tsv", "w") as f:
        csv_writer = csv.writer(f, delimiter="\t", quotechar='"')
        csv_writer.writerow(["id","en","es","ar","MatConf","MatCoop","VerConf","VerCoop"])
        for i in range(len(texts)):
            if sum(labels[i]) < 2:
                csv_writer.writerow([texts[i][3],texts[i][0],texts[i][1],texts[i][2], \
                                    labels[i][0],labels[i][1], \
                                    labels[i][2],labels[i][3]])
    
    for j, lang in enumerate(["en","es","ar"]):
        with open(Path(dir) / f"quadclass/{lang}/{lang}_annotations_quad_multiclass_WITH_IDS.tsv", "w") as f:
            csv_writer = csv.writer(f, delimiter="\t", quotechar='"')
            csv_writer.writerow(["id",lang,"QuadClass"])
            for i in range(len(texts)):
                if sum(labels[i]) < 2:
                    csv_writer.writerow([texts[i][3],texts[i][j], \
                                        0 if sum(labels[i]) == 0 else (labels[i] == 1).nonzero()[0][0] + 1])
        
        # Write One Hot Binary Version
        with open(Path(dir) / f"quadclass/{lang}/{lang}_annotations_quad_multiclass_ONE_HOT_WITH_IDS.tsv", "w") as f:
            csv_writer = csv.writer(f, delimiter="\t", quotechar='"')
            csv_writer.writerow(["id",lang,"MatConf","MatCoop","VerConf","VerCoop"])
            for i in range(len(texts)):
                if sum(labels[i]) < 2:
                    csv_writer.writerow([texts[i][3],texts[i][j], \
                                        labels[i][0],labels[i][1], \
                                        labels[i][2],labels[i][3]])  

def write_binary(texts, labels, dir):

    with open(Path(dir) / "binary/all_annotations_binary_WITH_IDS.tsv", "w") as f:
        csv_writer = csv.writer(f, delimiter="\t", quotechar='"')
        csv_writer.writerow(["id","en","es","ar","Relevant"])
        for i in range(len(texts)):
            relevant_irrelevant = 0 if sum(labels[i]) == 0 else 1
            csv_writer.writerow([texts[i][3],texts[i][0],texts[i][1],texts[i][2], relevant_irrelevant])

    for j, lang in enumerate(["en","es","ar"]):
        with open(Path(dir) / f"binary/{lang}/{lang}_annotations_binary_WITH_IDS.tsv", "w") as f:
            csv_writer = csv.writer(f, delimiter="\t", quotechar='"')
            csv_writer.writerow(["id",lang,"Relevant"])
            for i in range(len(texts)):
                relevant_irrelevant = 0 if sum(labels[i]) == 0 else 1
                csv_writer.writerow([texts[i][3], texts[i][j], relevant_irrelevant])

def main():

    parser = argparse.ArgumentParser(
                    prog="Process JSON to TSV",
                    description="This script converts the exported JSON from Label Studio to tsvs for downstream tasks.",)
    parser.add_argument("json_dir")
    parser.add_argument('-r', "--recover")
    parser.add_argument('-f', "--filter")

    args = parser.parse_args()
    json_dir = args.json_dir

    recovery_dir = args.recover
    if recovery_dir:
        recovery_df = pd.DataFrame()
        for data_file in Path(recovery_dir).glob("*.csv"):
            df = pd.read_csv(data_file)
            recovery_df = pd.concat([recovery_df, df])
    else:
        recovery_df = None

    filter_type = args.filter
    if filter_type:
        if filter_type == "irrelevant":
            criteria = irrelevant
        elif filter_type == "verconf":
            criteria = verbal_conflict
        elif filter_type == "irr_or_verconf":
            criteria = irrelevant_or_verbal_conflict

    texts = []
    labels = []
    for json_file in glob.glob(f"{json_dir}/*.json"):
        cur_texts, cur_labels = zip(*read_json(json_file, recovery_dir != None, recovery_df))
        texts += cur_texts
        labels += cur_labels
        print(len(texts))

    labels = standardize_labels(labels)

    if filter_type:
        texts, labels = filter(texts, labels, criteria)

    valid_labels = ["Verbal Conflict", "Material Conflict", \
                    "Verbal Cooperation", "Material Cooperation"]
    
    mlb = MultiLabelBinarizer()
    mlb.fit([valid_labels])

    binarized_labels = mlb.transform(labels)
    
    dir = Path(json_dir).parents[0]

    write_multilabel(texts, binarized_labels, dir)

    write_multiclass(texts, binarized_labels, dir)

    write_binary(texts, binarized_labels, dir)

if __name__ == "__main__":
    main()