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
  # check if no chars, or last char is a fullstop i.e. new sentence
  if (s == "" | str_sub(s,-1,-1)==".") return (NULL)
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
load("../Data/ngrams.rdat")

# ungroup the tables
unigrams <- ungroup(unigrams); bigrams <- ungroup(bigrams); trigrams <- ungroup(trigrams)
unigrams_head <- head(unigrams, 3)
top_start_words <- c("I","The","You","We","I'm")


# **************************************
#         PREDICTION FUNCTION
# **************************************
prob_penalty_model <- function(s, as_table=F, num_preds=3, penalty = 0.2, quad = F) {
  # check num_preds is in range 1 to 6
  if (num_preds < 1 | num_preds > 6) num_preds = 3

  # clean the input text
  s <- clean_string(s)
  num_words <- length(s)
  
  # is this the sentence start?
  if (num_words == 0) {
    return (top_start_words[1:num_preds])
  }
  
  # if one word get top matching bigrams and unigrams
  if (num_words == 1) {
    # 0-6 top matching bigrams
    bi <- bigrams %>%  filter(ng_head==s) 
    # top6 matching unigrams
    uni <- unigrams_head
    uni$prob <- as.integer(uni$prob * (1+penalty))
    # combine
    pred <- rbind(bi, uni)
  } else if (quad == F){
    # num_words must be 2 or more at this point, so find matching tri/bi/unigrams
    last_two_words <- paste(s[length(s)-1:0], collapse = " ")
    last_word <- get_last_n_words(last_two_words,1)
    
    # 0-6 top matching trigrams
    tri <- trigrams %>% filter(ng_head==last_two_words)
    # 0-6 top matching bigrams
    bi <- bigrams %>% filter(ng_head==last_word) 
    bi$prob <- as.integer(bi$prob * (1+penalty))
    # top6 matching unigrams
    uni <- unigrams_head 
    uni$prob <- as.integer(uni$prob * (1+penalty)^2)
    # combine
    pred <- rbind(tri,bi,uni)
  } else {
    # "QuadPower Mode(TM)", erm, using quadgrams.
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
    bi$prob <- as.integer(bi$prob * (1+penalty))
    # top6 matching unigrams
    uni <- unigrams_head 
    uni$prob <- as.integer(uni$prob * (1+penalty)^2)
    # combine
    pred <- rbind(quad,tri,bi,uni)
  }
  
  # pick most common duplicate, sort most probable first
  pred %<>% group_by(ng_next) %>% arrange(prob) %>% slice(1:1) %>% arrange(prob)
  
  if (as_table == FALSE) {return(head(pred$ng_next,num_preds))}
  return(head(pred,num_preds))
}