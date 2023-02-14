###############################################################################################
#
# Script for training good word and phrase vector model using public corpora, version 1.0.
# The training time will be from several hours to about a day.
#
# Downloads about 8 billion words, makes phrases using two runs of word2phrase, trains
# a 500-dimensional vector model and evaluates it on word and phrase analogy tasks.
#
###############################################################################################

# This function will convert text to lowercase and remove special characters
normalize_text() {
  awk '{print tolower($0);}' | sed -e "s/’/'/g" -e "s/′/'/g" -e "s/''/ /g" -e "s/'/ ' /g" -e "s/“/\"/g" -e "s/”/\"/g" \
  -e 's/"/ " /g' -e 's/\./ \. /g' -e 's/<br \/>/ /g' -e 's/, / , /g' -e 's/(/ ( /g' -e 's/)/ ) /g' -e 's/\!/ \! /g' \
  -e 's/\?/ \? /g' -e 's/\;/ /g' -e 's/\:/ /g' -e 's/-/ - /g' -e 's/=/ /g' -e 's/=/ /g' -e 's/*/ /g' -e 's/|/ /g' \
  -e 's/«/ /g' | tr 0-9 " "
}


wget http://www.statmt.org/lm-benchmark/1-billion-word-language-modeling-benchmark-r13output.tar.gz - done
# tar -xvf 1-billion-word-language-modeling-benchmark-r13output.tar.zip
# tar -xvf 1-billion-word-language-modeling-benchmark-r13output.tar.gz
# unzip 1-billion-word-language-modeling-benchmark-r13output.tar.gz 
# manual unzip

for i in `ls 1-billion-word-language-modeling-benchmark-r13output/training-monolingual.tokenized.shuffled`; do
  normalize_text < 1-billion-word-language-modeling-benchmark-r13output/training-monolingual.tokenized.shuffled/$i >> data.txt
done

gcc word2vec.c -o word2vec -lm -pthread -O3 -funroll-loops
make word2vec distance
./word2vec -train data.txt -output vectors.bin -cbow 1 -size 500 -window 10 -negative 10 -hs 0 -sample 1e-5 -threads 100 -binary 1 -iter 3 -min-count 10
./distance vectors.bin