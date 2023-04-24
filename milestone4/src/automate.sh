#! /bin/bash

count=1

for FILE in ../tests/*; 
    do ./myCompiler $FILE ../outputs/test$count.3ac ../outputs/test$count.s; count=$((count+1));
done