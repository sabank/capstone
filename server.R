
####### load library ###########################################################
library(shiny)
library(stringi)
library(data.table)

####### load data ##############################################################
unigrams = readRDS("./data/unigrams_final.rds")
bigrams = readRDS("./data/bigrams_final.rds")
trigrams = readRDS("./data/trigrams_final.rds")
fourgrams = readRDS("./data/fourgrams_final.rds")
fivegrams = readRDS("./data/fivegrams_final.rds")
codes = readRDS("./data/codes_final.rds")

####### helpers ################################################################
word2code = function(w){
    l = list(w)
    codes[l]$code
}

code2word = function(a){
    where = sapply(a, function(x)which(codes$code == x))
    codes[where]$x
}

####### handlers ###############################################################
codes = rbindlist(list(codes, list(x="PROFANITY", cX=1, code=1000001)),
                  use.names = TRUE, fill = TRUE)
setkey(codes, x)
shinyServer(function(input, output) {
    # clean input sentence
    preProcess = function(sentence){
        sentence = tolower(sentence)
        sentence = paste(" BS ", sentence)
        sentenceWords = unlist(stri_extract_all_words(sentence))
        regexYEAR = "^[12]{1}[0-9]{3}$"
        sentenceWords = stri_replace_all(sentenceWords, replacement = "YEAR",
                                         regex = regexYEAR)
        regexNUM = "^[[:digit:]]+(,[[:digit:]]*)*\\.*[[:digit:]]*$"
        sentenceWords = stri_replace_all(sentenceWords, replacement = "NUM",
                                         regex = regexNUM)
        punctuationRegex = "[\\[\\]\\$\\*\\+\\.\\?\\^\\{\\}\\|\\(\\)\\#%&~_/<=>✬!,:;❵@]"
        sentenceWords = stri_replace_all(sentenceWords, replacement = "",
                                         regex = punctuationRegex)
        sentenceWords = stri_replace_all(sentenceWords, replacement = "'",
                                         fixed = "’")
        nonEnglishChars = "[^A-Za-z'-[:space:]]"
        sentenceWords = stri_replace_all(sentenceWords, replacement = "",
                                         regex = nonEnglishChars)
        emptyWords = (sentenceWords == "")|(sentenceWords=="'")
        sentenceWords = sentenceWords[!emptyWords]
        return(sentenceWords)
    } 
    # unigram predictor
    predictWith1grams = function(prevWords=numeric(0), k=3){
        newWords = numeric(0)
        newProbs=numeric(0)
        selected = unigrams[!(x %in% prevWords)][order(pX, decreasing = TRUE)]
        k2 = min(k, nrow(selected))
        newWords = selected$x[1:k2]
        newProbs = selected$pX[1:k2]
        prediction = list(words = newWords, probs = newProbs)
        return(prediction)
    }
    # bigram predictor
    predictWith2grams = function(x0=numeric(0), prevWords=numeric(0), k=3){
        newWords = numeric(0)
        newProbs=numeric(0)
        (bigramsExist = any(!is.na(bigrams[.(x0)][!(y %in% prevWords)]$pXY)) )
        if(bigramsExist){
            selected = bigrams[.(x0)][!(y %in% prevWords)][order(pXY, decreasing = T)]
            k2 = min(k, nrow(selected))
            newWords = selected$y[1:k2]
            newProbs = selected$pXY[1:k2]
            # Second case of Katz backoff formula
            alpha = selected$alpha[1]
            fromUnigrams = predictWith1grams(c(prevWords, newWords), k)
            newWords = c(newWords, fromUnigrams$words)
            newProbs = c(newProbs, alpha * fromUnigrams$probs)
        } else {
            # third case of Katz backoff formula.
            # applies when x0 is an unseen word.
            fromUnigrams = predictWith1grams(prevWords, k)
            newWords = fromUnigrams$words
            newProbs = fromUnigrams$probs
        }
        prediction = list(words = newWords, probs = newProbs)
        return(prediction)
    }
    # trigram predictor
    predictWith3grams = function(xy=numeric(0), prevWords=numeric(0), k=3){
        x0 = xy[1]
        y0 = xy[2]
        newWords = numeric(0)
        newProbs=numeric(0)
        (trigramsExist = any(!is.na(trigrams[.(x0, y0)][!(z %in% prevWords)]$pXYZ)) )
        if(trigramsExist){
            selected = trigrams[.(x0, y0)][!(z %in% prevWords)][order(pXYZ, decreasing = T)]
            k2 = min(k, nrow(selected))
            newWords = selected$z[1:k2]
            newProbs = selected$pXYZ[1:k2]
            # second case of Katz backoff formula
            alpha = selected$alpha[1]
            fromBigrams = predictWith2grams(x0 = y0, c(prevWords, newWords), k)
            newWords = c(newWords, fromBigrams$words)
            newProbs = c(newProbs, alpha * fromBigrams$probs)
        } else {
            # third case of Katz backoff formula.
            # applies when (x0, y0) is an unseen 2-gram.
            fromBigrams = predictWith2grams(x0 = y0, prevWords, k)
            newWords = fromBigrams$words
            newProbs = fromBigrams$probs
        }
        prediction = list(words = newWords, probs = newProbs)
        return(prediction)  
    }
    # fourgram predictor
    predictWith4grams = function(xyz=numeric(0), prevWords=numeric(0), k=3){
        x0 = xyz[1]
        y0 = xyz[2]
        z0 = xyz[3]
        newWords = numeric(0)
        newProbs=numeric(0)
        (fourgramsExist = any(!is.na(fourgrams[.(x0, y0, z0)][!(t %in% prevWords)]$pXYZT)) )
        if(fourgramsExist){
            selected = fourgrams[.(x0, y0, z0)][!(t %in% prevWords)][order(pXYZT, decreasing = T)]
            k2 = min(k, nrow(selected))
            newWords = selected$t[1:k2]
            newProbs = selected$pXYZT[1:k2]
            # second case of Katz backoff formula
            alpha = selected$alpha[1]
            fromTrigrams = predictWith3grams(xy= c(y0,z0), c(prevWords, newWords), k)
            newWords = c(newWords, fromTrigrams$words)
            newProbs = c(newProbs, alpha * fromTrigrams$probs)
        } else {
            # third case of Katz backoff formula.
            # applies when (x0, y0, z0) is an unseen 3-gram.
            fromTrigrams = predictWith3grams(xy= c(y0,z0), prevWords, k)
            newWords = fromTrigrams$words
            newProbs = fromTrigrams$probs
        }
        prediction = list(words = newWords, probs = newProbs)
        return(prediction)
    }
    # fivegram predictor
    predictWith5grams = function(xyzt=numeric(0), prevWords=numeric(0), k=3){
        x0 = xyzt[1]
        y0 = xyzt[2]
        z0 = xyzt[3]
        t0 = xyzt[4]
        newWords = numeric(0)
        newProbs=numeric(0)
        (fivegramsExist = any(!is.na(fivegrams[.(x0, y0, z0, t0)][!(u %in% prevWords)]$pXYZTU)))
        if(fivegramsExist){
            selected = fivegrams[.(x0, y0, z0, t0)][!(u %in% prevWords)][order(pXYZTU, decreasing = T)]
            k2 = min(k, nrow(selected))
            newWords = selected$u[1:k2]
            newProbs = selected$pXYZTU[1:k2]
            # second case of Katz backoff formula
            alpha = selected$alpha[1]
            fromFourgrams = predictWith4grams(xyz= c(y0, z0, t0), c(prevWords, newWords), k)
            newWords = c(newWords, fromFourgrams$words)
            newProbs = c(newProbs, alpha * fromFourgrams$probs)
        } else {
            # third case of Katz backoff formula.
            # applies when (x0, y0, z0, t0) is an unseen 4-gram.
            fromFourgrams = predictWith4grams(xyz= c(y0, z0, t0), prevWords, k)
            newWords = fromFourgrams$words
            newProbs = fromFourgrams$probs
        }
        prediction = list(words = newWords, probs = newProbs)
        return(prediction)
    }
    ####### event ##############################################################
    predictedWord = function(inputSentence=character(0), k=10){
        # preprocess the words
        inputWords = preProcess(inputSentence)
        # convert them to numeric codes
        inputWords = word2code(inputWords)
        # check the number of input words
        n  = length(inputWords)
        prevWords = numeric(0)
        prevProbs = numeric(0)
        prediction = list()
        # prediction depends on the value of n
        if(n >= 3){
            xyz = inputWords[(n-2):n]
            prediction = predictWith4grams(xyz, prevWords, k)
        } else if(n == 2){
            xy = inputWords
            xy = inputWords[(n-1):n]
            prediction = predictWith3grams(xy, prevWords, k)
        }  else if(n == 1){
            x = inputWords
            prediction = predictWith2grams(x0=x, prevWords, k)
        }  else if(n == 0){
            prediction = predictWith1grams(prevWords, k)
        } 
        # create list of predicted word codes and probabilities
        predictedWords = list(words = code2word(prediction$words), 
                              probs = prediction$probs)
        return(predictedWords)
    }
    # display the word with highest probability
    output$highestprediction <- renderText({
        predictedWord(input$in_sentence, k = input$num2predict)$words[1]
    })
    # update list and display uppon user input
    prediction = reactive({
        k = input$num2predict
        predList = predictedWord(input$in_sentence, k)
        data.table(words = predList$words[1:k], probs = predList$probs[1:k])
    })
    # display table of predcited words and their probabilities
    output$predictionTable = renderDataTable(
        options = list(searching = FALSE, paging=FALSE, bInfo=FALSE), 
        prediction()
    )
    # update title of probability table
    output$listprob = renderText(
        paste0( "The ", 
                input$num2predict, 
                " prediction:", 
                collapse = "")
    )
})