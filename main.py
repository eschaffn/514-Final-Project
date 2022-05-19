import nltk
from nltk import word_tokenize as tokenizer
from nltk.corpus import stopwords

import numpy as np
import json
from tqdm import tqdm

# Uncomment the two lines below if you don't have the installed packages for NLTK

# nltk.download('averaged_perceptron_tagger')
# nltk.download('stopwords')

# Declaring file paths to the texts

EN_path = 'frankenstein.txt'
FR_path = 'three_musketeers_FR.txt'

# Declaring file paths to glove embeddings

en_glove_path = 'multilingual_embeddings/multilingual_embeddings.en'
fr_glove_path = 'multilingual_embeddings/multilingual_embeddings.fr'

def tokenizeAndTag(fpath, lang):
    with open(fpath, 'r') as f:
        f = f.read().lower() # read the entire book into memory
        stop_words = set(stopwords.words(lang)) # declare stopwords
        tokenized = tokenizer(f, language = lang) # tokenize the book
        filtered = [w for w in tokenized if not w in stop_words] # remove stopwords
        tagged = nltk.pos_tag(filtered) # tag the tokenized words with their POS
        
        return list(set(tagged)) # cast to a set then back to a list to remove unique words
    
    
def sort_POS(data):
    noun_list, verb_list, adj_list = [], [], [] # initialize lists for different POS
    
    noun_tags = ('NN', 'NNP', 'NNS') # Declare tags which represent nouns
    verb_tags = ('VB', 'VBD', 'VBG', 'VBN', 'VBP', 'VBZ') # Declare tags which represent verbs
    adj_tags = ('JJ', 'JJR', 'JJS') # Declare tags which represent adjectives
    
    for word in data:
        # Loop through the tokenized and tagged words and sort them into lists depending which POS they are
        noun_list.append(word[0]) if word[1] in noun_tags else None
        verb_list.append(word[0]) if word [1] in verb_tags else None
        adj_list.append(word[0]) if word[1] in adj_tags else None
    
    return [noun_list, verb_list, adj_list] # returns a list of lists 
        
        
def read_glove_vector(glove_vec):
  with open(glove_vec, 'r', encoding='UTF-8') as f:
    words = set() 
    word_to_vec_map = {} # Initialize empty dictionary 
    for line in f:
      w_line = line.split() 
      curr_word = w_line[0]
      word_to_vec_map[curr_word] = np.array(w_line[1:], dtype=np.float32)
  
  return word_to_vec_map # Returns a dictionary where k = word, and v = the embedding associated


def word_to_vec(data, map):
    vec_list = [] # initialize new list for embeddings
    for word in data: # loop through each word in the data
        if word in map.keys(): # check if the word exists in the vocab
            vec = map[word] # assign the embedding vector for the word
            vec_list.append(vec) # append the embedding to a new list
            
    return vec_list # return all the embeddings


def cos(vec1, vec2):
    cos_sim = np.dot(vec1, vec2)/(np.linalg.norm(vec1)*np.linalg.norm(vec2)) # define cosine similarity equation

    return cos_sim # return the  cosine similarity score
        

def pairwise_cos_calc(vectors):
    cos_list = [cos(x,y) for i,x in enumerate(vectors) for j,y in enumerate(vectors) if i != j] # calculates all pairwise scores, does not compare a word to itself

    return cos_list # returns a list of all pairwise cosine scores


def main(pos_list, map):
    all_pos = [word_to_vec(pos, map) for pos in pos_list] # iterates through each list of words and prepares embeddings
    
    # returns the pairwise cosine scores of all word lists
    return pairwise_cos_calc(all_pos[0]), \
           pairwise_cos_calc(all_pos[1]), \
           pairwise_cos_calc(all_pos[2])


if __name__ == '__main__':
    print("Preparing GloVe Vectors...")
    en_word_to_vec_map = read_glove_vector(en_glove_path) # Prepares glove vectors for english
    fr_word_to_vec_map = read_glove_vector(fr_glove_path) # Prepares glove vectors for french
    print("GloVe Vectors Prepared!\n")

    print("Tagging and Tokenizing...")
    EN_tagged = tokenizeAndTag(EN_path, "english") # tags and tokenizes the English book
    FR_tagged = tokenizeAndTag(FR_path, 'french') # Tags and tokenizes the french book
    print("Done!\n")

    print("Seperating by Parts of Speech...")
    EN_noun_verb_adj = sort_POS(EN_tagged) # sorts the tokens into their POS for english
    FR_noun_verb_adj = sort_POS(FR_tagged) # sorts the tokens into their POS for french
    print("Done!\n")
    
    print("Computing Pairwise Cosine Distances, this will take some time...\n")
    en_noun_cos, en_verb_cos, en_adj_cos = main(EN_noun_verb_adj, en_word_to_vec_map) # Calculates English cosine scores
    fr_noun_cos, fr_verb_cos, fr_adj_cos = main(FR_noun_verb_adj, fr_word_to_vec_map) # calculates french cosine scores

    print(f'\nEnglish:\nNouns: {len(en_noun_cos)} | Verbs: {len(en_verb_cos)} | Adjectives: {len(en_adj_cos)}\n')
    print(f'\nFrench:\nNouns: {len(fr_noun_cos)} | Verbs: {len(fr_verb_cos)} | Adjectives: {len(fr_adj_cos)}\n')

    # Formats data into a JSON dictionary 
    
    json_dict = {'en_nouns': [float(x) for x in en_noun_cos], 
                 'en_verbs': [float(x) for x in en_verb_cos],
                 'en_adjs': [float(x) for x in en_adj_cos],
                 'fr_nouns': [float(x) for x in fr_noun_cos],
                 'fr_verbs': [float(x) for x in fr_verb_cos],
                 'fr_adjs': [float(x) for x in fr_adj_cos]}
    
    with open('json_data.json', 'w') as f:
        json.dump(json_dict, f) # Stores the JSON dictionary in JSON format for use in R


    