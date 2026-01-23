#!/usr/bin/env python3 -B
import json

# Q1 The model and presentation layer were combined. This made it hard to alter just the model or just the presentation.
# Q2 Yes there is one function doing everything. Word_counts should be split up.
# Q3 Yes stopwords and punctuation were hard coded and part of the combined function.
# Q4 Yes, just one large function. Needed to be split up into lots of smaller functions.

# Q3 --> Seperating out Polcy (From this point until the function definitions)
CONFIG = {
    "output" : "print", # Set output format as either "print" or "JSON"
    "lang" : "eng", # Language for stopwords: "eng", "spa", "ger" 
    "stopwords": [], 
    "english_stopwords": "eng_stopwords.txt", # Path to English stopwords file. Used file as is so output is different.
    "spanish_stopwords": "spa_stopwords.txt", # Path to Spanish stopwords file
    "german_stopwords": "ger_stopwords.txt", # Path to German stopwords file
    "punctuation": '.,!?;:"()[]', # Punctuation to remove
    "top_n": 10, # Number of top frequent words to display
    "print_format": [2, 15, 3], # Formatting for print output: [rank_width, word_width, count_width]
    "JSON_format": ["json_output.txt", 2] # [output_file, indent]
}

# Q3 --> Seperating out Mechanism (From this point until the function call)
# Q1, Q2 --> Single function responsible for loading text
def load_text(file):
  with open(file) as f:
    text = f.read()
  return text

# Q1, Q2  --> seperates out presentation from model, single responsibility (showing header)
def show_header(file):
  print(f"\n{'='*50}")
  print(f"WORD FREQUENCY ANALYSIS - {file}")
  print(f"{'='*50}\n")

# Q1, Q2  --> seperates out presentation from model, single responsibility (show word stats)
def show_count(num_words, num_unique):
  print(f"Total words (after removing stopwords): {num_words}")
  print(f"Unique words: {num_unique}\n")

# Q1, Q2  --> seperates out presentation from model, single responsibility (show top n word frequencies)
def show_word_freq(sorted_words):
  print(f"Top {CONFIG['top_n']} most frequent words:\n")
  for i, (word, count) in enumerate(sorted_words[:CONFIG['top_n']], 1):
    bar = "*" * count
    print(f"{i:{CONFIG['print_format'][0]}}. {word:{CONFIG['print_format'][1]}} {count:{CONFIG['print_format'][2]}} {bar}")
  
  print()

# BQ1 --> Function to convert results to JSON format
def toJSON(file, counts, sorted_words):
  output = {
      "file": file,
      "total_words": sum(counts.values()),
      "unique_words": len(counts),
      "top_words": [
          {"rank": i + 1, "word": word, "count": count}
          for i, (word, count) in enumerate(sorted_words[:CONFIG['top_n']])
      ]
  }
  return output

# BQ1 --> Function to output JSON to file
def output_JSON(output):
  with open(CONFIG["JSON_format"][0], "w") as f:
    json.dump(output, f, indent=CONFIG["JSON_format"][1])


# BQ2, BQ4 --> Function to load stopwords from file based on language
def loadStopwords(lang):
  if lang == "spa": 
    CONFIG['stopwords'] = open(CONFIG["spanish_stopwords"]).read().lower().split()
  elif lang == "ger":
    CONFIG['stopwords'] = open(CONFIG["german_stopwords"]).read().lower().split()
  else: 
    CONFIG['stopwords'] = open(CONFIG["english_stopwords"]).read().lower().split()

# Q1, Q2  --> seperates out calculations from presentation, single responsibility (sort words on count)
def sort_words(counts):
  return sorted(counts.items(), key=lambda x: x[1], reverse=True)

# Q1, Q2  --> seperates out calculations from presentation, single responsibility (clean text)
def clean_text(text):
  return text.lower().split()

# Q1, Q2  --> seperates out calculations from presentation, single responsibility (get word counts)
def get_word_count(words):
  counts = {}
  for word in words:
    # Hardcoded punctuation removal
    word = word.strip(CONFIG["punctuation"])
    if word and word not in CONFIG["stopwords"]:  # Hardcoded stopwords
      counts[word] = counts.get(word, 0) + 1
  return counts

# Q4 --> Small main function coordinating the workflow
def word_counter(file):
  loadStopwords(CONFIG["lang"])
  counts = get_word_count(clean_text(load_text(file)))
  if CONFIG["output"] == "JSON":
    output_JSON(toJSON(file, counts, sort_words(counts)))
  elif CONFIG["output"] == "print":
    show_header(file)
    show_count(sum(counts.values()), len(counts))
    show_word_freq(sort_words(counts))

# Function call to execute the word counter
word_counter("essay.txt")

# BQ3 --> Unit tests for the functions
def test_load_text():
  assert len(load_text("essay.txt")) > 0

def test_loadStopwords():
  loadStopwords("eng")
  assert "the" in CONFIG['stopwords']

def test_toJSON():
  counts = {'word': 5, 'test': 3}
  sorted_words = sort_words(counts)
  output = toJSON("essay.txt", counts, sorted_words)
  assert output['total_words'] == 8
  assert output['unique_words'] == 2
  assert output['top_words'][0]['word'] == 'word'

def test_sort_words():
  counts = {'word': 5, 'test': 3}
  sorted_words = sort_words(counts)
  assert sorted_words[0][0] == 'word'
  assert sorted_words[1][0] == 'test'

def test_clean_text():
  text = "Hello, World!"
  words = clean_text(text)
  assert words == ["hello,", "world!"]

def test_get_word_count():
  words = ["hello", "world", "hello"]
  counts = get_word_count(words)
  assert counts['hello'] == 2
  assert counts['world'] == 1

test_load_text()
test_loadStopwords()
test_toJSON()
test_sort_words()
test_clean_text()
test_get_word_count()
