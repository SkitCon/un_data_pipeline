'''
File: binary_predict.py
Author: Amber Converse
Purpose: Run binary predictions on the new sentences using existing ConfliBERT models.

    Args:
        --dataset: the dataset to run predictions on (CSV)
        --model: path to the model to use, should be binary (export 0 or 1)
        --output: the output path for the predictions
        --column: the name of the column with the text of the sentences in it in the input
            dataset
'''

import time
import argparse
import pandas as pd
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification, pipeline

def chunk_text(text, tokenizer, max_length):
    # Tokenize the text and get token IDs
    tokens = tokenizer(text, truncation=False, return_tensors="pt")["input_ids"][0]
    # Split the tokens into chunks of max_length
    chunks = [tokens[i:i+max_length] for i in range(0, len(tokens), max_length)]
    # Decode each chunk back into text
    return [tokenizer.decode(chunk, skip_special_tokens=True) for chunk in chunks]

def main(df, model_dir, output_dir, column):

    tokenizer = AutoTokenizer.from_pretrained(model_dir)
    model = AutoModelForSequenceClassification.from_pretrained(model_dir).to("cuda")
    
    classification_pipeline = pipeline(
        "text-classification",
        model=model,
        tokenizer=tokenizer,
        truncation=True,  # Ensure the tokens are truncated if too long
        max_length=512,  # Truncate to the model's maximum token limit
        return_all_scores=False,  # Only returns the label with the highest score
        device=0 if torch.cuda.is_available() else -1
    )
    
    # Classify each sentence (with chunking if needed)
    labels = []
    scores = []
    
    num_sentences = len(df[column])
    report_at = list(range(1,110, 5))
    
    start_time = time.time()
    for i, sentence in enumerate(df[column]):
        
        # Report progress
        if int((i / num_sentences) * 100) == report_at[0]:
            report_at = report_at[1:]
            cur_time = time.time()
            print(f"Progress report on {model_dir}:\n\t{int((i / num_sentences) * 100)}% completed.\n\tEstimated time to complete: {round(((cur_time - start_time) / i) * (num_sentences - i) / 60, 1)} minutes.")
    
        # Split sentence into chunks if it's too long
        sentence_chunks = chunk_text(sentence, tokenizer, max_length=512)
        chunk_results = []
        for chunk in sentence_chunks:
            # Pass the chunk as a string to the classification pipeline
            result = classification_pipeline(chunk)[0]
            binary_label = 0 if result['label'] == 'LABEL_0' else 1
            chunk_results.append((binary_label, result['score']))

        # Aggregate chunk results by averaging probabilities or labels
        avg_score = sum([score for _, score in chunk_results]) / len(chunk_results)
        avg_label = round(sum([label for label, _ in chunk_results]) / len(chunk_results))  # Majority voting for label

        labels.append(avg_label)
        scores.append(avg_score)

    df["label"] = labels
    df["score"] = scores

    df.to_csv(output_dir, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset",
                        default = "predict.csv",
                        type=str,
                        help="The input dataset.")
    parser.add_argument("--model",
                        default = "google-bert/bert-base-uncased",
                        type=str,
                        help="The model path")
    parser.add_argument("--output",
                        default = "output.csv",
                        type=str,
                        help="The output file path")
    parser.add_argument("--column",
                        default = "en",
                        type=str,
                        help="The name of the column for classification features")
    
    args = parser.parse_args()

    df = pd.read_csv(args.dataset)

    main(df, args.model, args.output, args.column)
