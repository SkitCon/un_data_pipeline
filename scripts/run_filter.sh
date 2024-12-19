#!/bin/bash

python3 binary_predict.py --dataset data/most_relevant.csv --model salsarra/en_binary --output output/relevant_irrelevant.csv

python3 binary_predict.py --dataset data/most_relevant.csv --model salsarra/BinQuad_EN_matconf --output output/mat_conf.csv

python3 binary_predict.py --dataset data/most_relevant.csv --model salsarra/BinQuad_EN_matcoop --output output/mat_coop.csv

python3 binary_predict.py --dataset data/most_relevant.csv --model salsarra/BinQuad_EN_verconf --output output/ver_conf.csv

python3 binary_predict.py --dataset data/most_relevant.csv --model salsarra/BinQuad_EN_vercoop --output output/ver_coop.csv
