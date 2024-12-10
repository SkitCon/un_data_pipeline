'''
File: get_sec_docs.py
Author: Amber Converse
Purpose: Script to grab all of docs related to the security
    council from the UN Parallel Corpus. "Related to the
    security council" is defined as all docs with an s
    in the second column of their doc symbol.

    Run in the dir containing the UNv1.0-TEI dir. Run with
    -rmxml option to remove the XML metadata and extract the
    plain text. Sorted docs will be in a dir called
    UNv1.0-TEI-S in files dedicated to each language. With
    the -rmxml option active, all text is dumped into one
    txt file with each document seperated by 2 newlines.
'''

import argparse
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET

def remove_xml(fname):
    '''
    Extracts the plain text from an XML file.
    
    :param fname: a string giving the name of the XML file
    :return: a string containing the text of the XML file
    '''
    doc = ET.parse(fname).getroot()
    return '\n'.join(['\n'.join([' '.join([s.strip() for s in p.itertext()]) \
           for p in body]) \
           for body in doc.find("text")])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-rmxml", "--rmxml",
                    help="Remove XML metadata",
                    action="store_true")
    args = parser.parse_args()

    root = Path("UNv1.0-TEI")
    new_root = Path("UNv1.0-TEI-S")
    for lang in root.iterdir():
        if not lang.stem.startswith("."):
            for year in lang.iterdir():
                if year.is_dir():
                    src_dir = year / "s"
                    if src_dir.exists():
                        dst_dir = list(src_dir.parts)
                        dst_dir[0] = new_root
                        dst_dir = Path(*dst_dir)
                        shutil.copytree(src_dir, dst_dir, dirs_exist_ok=True)
    
    if not args.rmxml:
        exit(0)
    for lang in new_root.iterdir():
        if lang.is_dir() and not lang.stem.startswith("."):
            dump_file = new_root / f"UNv1.0-DUMP-{lang.stem}.txt"
            with dump_file.open('w', encoding="utf-8") as f:
                for xml_file in lang.rglob("*.xml"):
                    plain_text = remove_xml(str(xml_file))
                    f.write(plain_text + "\n\n")

if __name__ == "__main__":
    main()
