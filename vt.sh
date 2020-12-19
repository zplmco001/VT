#! /bin/bash

#vt create db <dbname>
#vt create col <collectionname> || <dbname.collectionname>

if [ $1 == 'create' ]
then
    if [ $2 == 'db' ]
    then
        mkdir $3
        echo 'Database created'
    fi
    if [ $2 == 'col' ]
    then
        IFS='.' read -ra ADDR <<< "$3"
        if [ ${#ADDR[@]} -eq 2 ]
        then
            cd ${ADDR[0]}
            mkdir ${ADDR[1]}
            echo 'Collection created'
        elif [ ${#ADDR[@]} -eq 1 ]
        then
            dirs=$(ls)
            for dir in $dirs
            do
                echo $dir
            done
            echo 'Please select database name:'
            read;
            cd ${REPLY}
            mkdir ${ADDR[0]}
            echo 'Collection created'
        else
            echo 'Incorrect Collection Name or Command'
        fi
        
    fi
fi

#vt insert <obj> <database.collection>
#obj json türünde ama boşluk içermeyecek

if [ $1 == 'insert' ]
then
    for (( i=2;i<=(($#-1));i++ ))
    do
        echo $i
    done
fi
