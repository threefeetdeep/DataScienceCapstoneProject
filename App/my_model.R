library(dplyr)      # for wrangling
library(magrittr)   # for piping
library(stringr)    # for word to corpus str_c() function
library(tidytext)   # for unnest_tokens()

# load "corpus" variable
load("../Data/ngrams_25.rdat")
rm(quadgrams)


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
  if (s == "") return (NULL)
  # convert to single row data frame
  s <- data.frame(text=s)
  # use tidytext unnest_tokens to clean and split to words
  s <- unnest_tokens(s, text, text) 
  # replace OOV words with "unkwn"
  s <- convert_oov(s$text)
  
  return(s)
}


# ungroup the tables
unigrams <- ungroup(unigrams); bigrams <- ungroup(bigrams); trigrams <- ungroup(trigrams)
unigrams_head <- head(unigrams, 3)
top_start_words <- c("I","The","You","We","I'm")

prob_penalty_model <- function(s, as_table=FALSE, num_preds=3, penalty = 0.4) {
  s <- clean_string(s)
  num_words <- length(s)
  
  # is this a sentence start?
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
  } else {
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
  }
  
  # pick most common duplicate, sort most probable first
  pred %<>% group_by(ng_next) %>% arrange(prob) %>% slice(1:1) %>% arrange(prob)
  
  if (as_table == FALSE) {return(head(pred$ng_next,num_preds))}
  return(head(pred,num_preds))
}
