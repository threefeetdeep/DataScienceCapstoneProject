Capstone Project of the Coursera JHU Data Science Specialization
Next word prediction using an N-gram Model

Oliver Bailey (threefeetdeep
Aug-Sept 2020.

The main goal of the project is to design a Shiny application that takes as input a partial (incomplete) English sentence and predicts the next word in the sentence. You may want to start by taking a look at the app. In that case, please remember to read the instructions in the Documentation tab of the app before using it. The app can be found at:
http://threefeetdeep.shinyapps.io/?

A slide deck presentation that overviews the project has been published to Rpubs here: https://rpubs.com/ojaybee/663258


Project top level folder structure and information about data files:<br>
|<br>
|  
|--- Data - output data from the creation of ngram tables, to be used by the prediction app<br>
|  
|--- App - the UI/Server code for Shiny Text Prediction App<br>
|  
|--- Code - the R code used to develop the prediction function used by the Shiny App<br>
|  
|--- SlidePresentation - a slide deck to introduce and promote the Shiny App<br>
|  
|---  MileStone Report - early study of the input text data used as the basis of the prediction model
  
IMPORTANT:  The course organizers provided a zip file with training data for our models, with size over 570Mb. This is not included here in this repository but can be downloaded from  http://www.corpora.heliohost.org/  This zip file consists of three sources of text data, mined from blogs, twitter and news sources online. Each source is about 200MB.

 Ngram models were created from these corpora using strings of 1-4 words. 

