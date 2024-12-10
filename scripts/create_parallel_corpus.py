'''
File: create_parallel_corpus.py
Author: Amber Converse
Purpose: Script that uses the file UNv1.0.6way.ids to
    create a multilingual corpus between all UN official
    languages aligned at the sentence level.
    
    Two options for file format, -csv (default) for each
    sentence to be written as a row in a csv with 3 columns
    for each language or -json which formats the sentences
    as a list of tasks for Label Studio with a field for
    each language.
    
    This script should be located in the same
    directory as the UNv1.0-TEI-S created by the script
    get_sec_docs.py. The UNv1.0.6way.ids file should
    be located immediately inside the UNv1.0-TEI-S
    directory. Files for each year will be located in
    a new directory called UNv1.0-linked
'''

import argparse
import os
import xml.etree.ElementTree as ET
import json
import csv

def write_tasks_file_json(year, tasks):
    '''
    This function writes the tasks object as a json.

    :param year: a string representing the year of all tasks in
        the tasks object
    :param tasks: a list of dictionaries containing an id field
        and a data field, containing a dictionary with the 
        text_ar, text_en, and text_es fields, each containing
        the text of the sentence for each respective language.
    '''
    try:
        os.mkdir("UNv1.0-linked")
    except OSError:
        pass
    
    with open(f"UNv1.0-linked/{year}.json", 'w', encoding="utf-8") as f:
        f.write(json.dumps(tasks, ensure_ascii=False))

def write_tasks_file_csv(year, tasks):
    '''
    This function writes the tasks object to a file as a csv.
    Each row is a set of 3 sentences in Arabic, English, and
    Spanish.
    
    :param year: a string representing the year of all tasks in
        the tasks object
    :param tasks: a list of dictionaries containing an id field
        and a data field, containing a dictionary with the
        text_ar, text_en, and text_es fields, each containing
        the text of the sentence for each respective language.
    '''
    try:
        os.mkdir("UNv1.0-linked")
    except OSError:
        pass

    with open(f"UNv1.0-linked/{year}.csv", 'w', encoding="utf-8") as csv_file:
        csv_writer = csv.writer(csv_file, quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(["id","ar","en","es","ru","fr","zh"])
        for task in tasks:
            csv_writer.writerow([task["id"],task["data"]["text_ar"], \
                    task["data"]["text_en"],task["data"]["text_es"], \
                    task["data"]["text_ru"],task["data"]["text_fr"],
                    task["data"]["text_zh"]])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-csv", "--csv",
                    help="Export in CSV",
                    action="store_true")
    parser.add_argument("-json", "--json",
                    help="Export in JSON",
                    action="store_true")
    args = parser.parse_args()
    
    if args.json:
        write_tasks_file = write_tasks_file_json
    else:
        write_tasks_file = write_tasks_file_csv

    with open("UNv1.0-TEI-S/UNv1.0.6way.ids", 'r') as id_file:
        cur_year = None
        task_dict = dict()
        tasks = []
        for line in id_file:
            elems = line.strip().split()
            year = elems[0][:4]
            doc_path = f"{elems[0]}.xml"
            if doc_path.split("/")[1] != "s":
                continue

            task_dict["id"] = f"{elems[0]}/{elems[1][3:]}"
            task_dict["data"] = dict()
            
            if not cur_year:
                cur_year = year
            elif cur_year != year:
                write_tasks_file(cur_year, tasks)
                cur_year = year
                tasks = []

            sent_ids = {"ar":[elem[3:] 
                            for elem in elems if elem[:2] == "ar"],
                        "en":[elem[3:]
                            for elem in elems if elem[:2] == "en"],
                        "es":[elem[3:]
                            for elem in elems if elem[:2] == "es"],
                        "ru":[elem[3:]
                            for elem in elems if elem[:2] == "ru"],
                        "fr":[elem[3:]
                            for elem in elems if elem[:2] == "fr"],
                        "zh":[elem[3:]
                            for elem in elems if elem[:2] == "zh"],}
            
            valid = True 
            for lang in sent_ids:
                sentences = []
                try:
                    doc_tree = ET.parse(f"UNv1.0-TEI-S/{lang}/{doc_path}")
                except:
                    print(f"CORRUPTED/MISSING: {lang}/{doc_path}")
                    valid = False
                    break
                doc_tree = doc_tree.getroot()
                for s_id in sent_ids[lang]:
                    sentences.append(doc_tree.find( \
                        f"text/body/p/s[@id='{s_id}']").text.strip())
                task_dict["data"][f"text_{lang}"] = ' '.join(sentences)
            if valid:
                tasks.append(task_dict)
            task_dict = dict()
        write_tasks_file(cur_year, tasks)
            
if __name__ == "__main__":
    main()
