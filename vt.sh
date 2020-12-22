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
#obj json türünde ama boşluk içermeyecek ve id field ilk sırada olacak
if [ $1 == 'insert' ]
then
    IFS='.' read -ra ADDR <<< "${@:(($#))}"
    if [ ${#ADDR[@]} -eq 2 ]
    then
        cd ${ADDR[0]}
        cd ${ADDR[1]}
        fields=${@:3:(($#-3))}
        IFS=':' read -ra id <<< "${@:2:1}"
        for field in $fields
        do
            IFS=':' read -ra add <<< "$field"
            echo "<${id[1]}>:<${add[1]}>" >> ${add[0]}.txt
        done
    else
        echo 'Given Collection Not Found'
    fi 
fi

#vt findBy <fieldname1>=<value1> <database.collection>
if [ $1 == 'findBy' ]
then
    IFS='.' read -ra ADDR <<< "${@:(($#))}"
    str=""
    header=" "
    if [ ${#ADDR[@]} -eq 2 ]
    then
        cd ${ADDR[0]}
        cd ${ADDR[1]}
        fields=${@:2:(($#-2))}
        res=" "
        #for field in $fields
        #do
            str+=$(grep "<${2#*"="}>" "${2%%"="*}.txt")
         #   break
        #done
        if [ ${#str} -ne 0 ]
        then
            echo $str
            res="<id>:${str%%":"*}\n"
            for fil in $(ls)
            do
                val=$(grep "${str%%":"*}" "$fil")
                res+="<${fil%%"."*}>":"${val#*":"}"
                res+='\n'
            done
            printf $res
        else
            echo 'Record not found'
        fi
        
        
    else
        echo 'Given Collection Not Found'
    fi    
fi

#vt findAll <database.collection>
if [ $1 == 'findAll' ]
then
    IFS='.' read -ra ADDR <<< "${@:(($#))}"
    str=" "
    if [ ${#ADDR[@]} -eq 2 ]
    then
        cd ${ADDR[0]}
        cd ${ADDR[1]}
        str=" "
        for file in $(ls)
        do
            echo ${file%%"."*}
            echo $(cat $file)
        done
    
    else
        echo 'Given Collection Not Found'
    fi
fi

#vt delete db <dbname>
#vt delete col <db.colname>
if [ $1 == 'delete' ]
then
    if [ $2 == 'db' ]
    then
        rm -rf $3
        echo "Database deleted"
    else
        echo "Database not found"
    fi

    if [ $2 == 'col' ]
    then
        str=$3
        cd ${str%%"."*}
        rm -rf ${str#*"."}
        echo "Collection deleted"
    else
        echo "Collection not found"
    fi
fi

#vt update <db.col.field> set <newValue> where <oldValue>
if [ $1 == 'update' ]
then
    ADDR=(${2//./ })
    if [ ${#ADDR[@]} -eq 3 ]
    then
        cd ${ADDR[0]}
        cd ${ADDR[1]}
        targetField=${ADDR[2]}.txt
        
        if [[ ($3 == 'set' && $5 == 'where') ]]
        then

            oldValue=$(grep ":<$6>" "$targetField")
            if [ ${#oldValue} -eq 0 ]
            then
                echo "Record not found"
            else
                id=${oldValue%%":"*}
                newValue="$id:<$4>"
                echo $newValue
                sed -i -e "s/$oldValue/$newValue/" $targetField
                echo "Updated"
            fi
        else
            echo "Command is not correct"
        fi
    else
        echo 'Given Collection Not Found'
    fi  
 fi