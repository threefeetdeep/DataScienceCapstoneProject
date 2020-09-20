library(dplyr)      # for wrangling
library(magrittr)   # for piping
library(stringr)    # for word to corpus str_c() function
library(tidytext)   # for unnest_tokens()

# **************************************
#         UTITLITY FUNCTIONS
# **************************************

# input is a string, output is vector of last n words
get_last_n_words <- function(s,n) {
  str_to_lower(word(s, -n, -1))
}

# convert words not in our unigram vocab to "unkwn" token
convert_oov <- function(words_to_check) {
  ifelse(words_to_check %in% unigrams$ng_next, words_to_check,"unkwn")
}
  
# function to clean a string, removing punctuation, replacing out-of-vocab words
clean_string <- function(s) {
  # check if no chars, or last char is a fullstop, exclamation or question mark
  # i.e.  a new sentence
  if (s == "" | str_detect(s,"(\\!|\\?|\\.) *$")) return (NULL)
  
  # return most recent sentence only i.e words after most recent ./!/?
  s <- str_extract(s, "[\\w\\s']+$")
  # convert to single row data frame
  s <- data.frame(text=s)
  # use tidytext unnest_tokens to clean and split to words
  s <- unnest_tokens(s, text, text) 
  # replace OOV words with "unkwn"
  s <- convert_oov(s$text)
  
  return(s)
}


# **************************************
#         INITIALIZATION
# **************************************

# load n-gram tables
load("ngrams.rdat")

# ungroup the tables
unigrams <- ungroup(unigrams); bigrams <- ungroup(bigrams); trigrams <- ungroup(trigrams)
unigrams_head <- head(unigrams, 6)

# capitalize sentence start words
sentence_starts$ng_next <- str_to_title(sentence_starts$ng_next)
sentence_starts <- data.frame(sentence_starts)


# **************************************
#         PREDICTION FUNCTION
# **************************************
prob_penalty_model <- function(s, num_preds=3, penalty = 0.2, quad = F) {
  # check num_preds is in range 1 to 6
  if (num_preds < 1 | num_preds > 6) num_preds = 3

  # clean the input text
  s <- clean_string(s)
  num_words <- length(s)
  
  # is this the sentence start?
  if (num_words == 0) {
    return (sentence_starts[1:num_preds,])
  } else if (num_words == 1) {
    # if one word get top matching bigrams and unigrams
    bi <- bigrams %>%  filter(ng_head==s) 
    uni <- unigrams_head
    uni$prob <- as.integer(uni$prob * (1+penalty))
    
    pred <- rbind(bi, uni)
    
  } else if (quad == F | (quad == T & num_words < 3)) {
    # num_words must be 2 or more at this point, so find matching tri/bi/unigrams
    last_two_words <- paste(s[length(s)-1:0], collapse = " ")
    last_word <- get_last_n_words(last_two_words,1)
    
    tri <- trigrams %>% filter(ng_head==last_two_words)
    bi <- bigrams %>% filter(ng_head==last_word) 
    bi$prob <- as.integer(bi$prob * (1+penalty))
    
    uni <- unigrams_head 
    uni$prob <- as.integer(uni$prob * (1+penalty)^2)
    
    pred <- rbind(tri,bi,uni)
    
  } else if (quad == T & num_words >= 3) {
    # "QuadPower Mode(TM)" using quadgrams. (quad = T)
    last_three_words <- paste(s[length(s)-2:0], collapse = " ")
    last_two_words <- paste(s[length(s)-1:0], collapse = " ")
    last_word <- get_last_n_words(last_two_words,1)
    
    # 0-6 top matching quadgrams
    quad <- quadgrams %>% filter(ng_head==last_three_words)
    # 0-6 top matching trigrams
    tri <- trigrams %>% filter(ng_head==last_two_words)
    tri$prob <- as.integer(tri$prob * (1+penalty))
    # 0-6 top matching bigrams
    bi <- bigrams %>% filter(ng_head==last_word) 
    bi$prob <- as.integer(bi$prob * (1+penalty)^2)
    # top6 matching unigrams
    uni <- unigrams_head 
    uni$prob <- as.integer(uni$prob * (1+penalty)^3)
    # combine
    pred <- rbind(quad,tri,bi,uni)
  }
  
  # pick most common duplicate, sort most probable first
  pred %<>% group_by(ng_next) %>% arrange(prob) %>% slice(1:1) %>% arrange(prob)
  
  return(head(pred,num_preds))
}
