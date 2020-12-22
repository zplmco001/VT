#! /bin/bash

#handles the commands of creating a database or colleciton by given arguments
#USAGE:
#./vt.sh create db <dbname>
#./vt.sh create col <collectionname> || <dbname.collectionname>

if [ $1 == 'create' ]                                   #if first given argument is create
then
    if [ $2 == 'db' ]                                   #if second given argument is db
    then
        mkdir $3                                        #create the database folder
        echo 'Database created'                         #inform the user
    fi
    if [ $2 == 'col' ]                                  #if second given argument is col
    then
        IFS='.' read -ra ADDR <<< "$3"                  #Assign Internal Field Seperator to '.' and
                                                        #separate the third argument to find out whether
                                                        #just <collectionname> or <dbname.collectionname>
                                                        #is given and assign the seperated values as array to ADDR
        if [ ${#ADDR[@]} -eq 2 ]                        #If <dbname.collectionname>
        then
            cd ${ADDR[0]}                               #Go to database directory
            mkdir ${ADDR[1]}                            #Create the collection folder.
            echo 'Collection created'
        elif [ ${#ADDR[@]} -eq 1 ]                      #If just collection name is given
        then
            dirs=$(ls)                                  #List the database folders
            for dir in $dirs
            do
                echo $dir
            done
            echo 'Please select database name:'
            read;                                       #Read the written database name
            cd ${REPLY}                                 #Go to read database folder
            mkdir ${ADDR[0]}                            #Create the Collection folder
            echo 'Collection created'
        else
            echo 'Incorrect Collection Name or Command'
        fi
    fi
fi

#inserts obj to given collection
#USAGE:
#./vt.sh insert <obj> <database.collection>
#obj could be json with no whitespace and id field should the first written field
if [ $1 == 'insert' ]                                       #if first given argument is create
then
    IFS='.' read -ra ADDR <<< "${@:(($#))}"                 #Assign Internal Field Seperator to '.' and
                                                            #separate the last argument to take database name and collection name
                                                            #assign the seperated values as array to ADDR
    if [ ${#ADDR[@]} -eq 2 ]                                #If size of array is 2 means database and collection name is given
    then
        cd ${ADDR[0]}                                       #Go to database directory
        cd ${ADDR[1]}                                       #Go to collection directory
        fields=${@:3:(($#-3))}                              #Read the fields in object and assign as array to fields
        IFS=':' read -ra id <<< "${@:2:1}"                  #Assign Internal Field Seperator to ':' and read the id field of object
        for field in $fields                                #For each field in fields
        do
            IFS=':' read -ra add <<< "$field"               #Seperate field name and value
            echo "<${id[1]}>:<${add[1]}>" >> ${add[0]}.txt  #Append the field value with object id to corresponding field text field 
        done
    else
        echo 'Given Collection Not Found'
    fi 
fi

#Finds the first record with given value of one field
#USAGE:
#./vt.sh findBy <fieldname>=<value> <database.collection>
if [ $1 == 'findBy' ]                                   #if first given argument is findBy
then
    IFS='.' read -ra ADDR <<< "${@:(($#))}"             #Assign Internal Field Seperator to '.' and
                                                        #separate the last argument to take database name and collection name
                                                        #assign the seperated values as array to ADDR
    id=""                                               #Variable that wiil keep the id of found record
    if [ ${#ADDR[@]} -eq 2 ]                            #If size of array is 2 means database and collection name is given
    then
        cd ${ADDR[0]}                                   #Go to database directory
        cd ${ADDR[1]}                                   #Go to collection directory
        res=" "                                         #Variable that keep the result
        id+=$(grep "<${2#*"="}>" "${2%%"="*}.txt")      #Find the line includes given value in file of given field name
                                                        #and gets the correspending id of the value
        if [ ${#id} -ne 0 ]                             #If id exists
        then
            res="<id>:${id%%":"*}\n"                    #Add object id to result variable
            for fil in $(ls *.txt)                      #In all fields in collection 
            do
                val=$(grep "${id%%":"*}" "$fil")        #Search fields with given id
                res+="<${fil%%"."*}>":"${val#*":"}"     #Add found value by id to result
                res+='\n'
            done
            printf $res                                 #Print result
        else
            echo 'Record not found'
        fi
    else
        echo 'Given Collection Not Found'
    fi    
fi

#Prints the all objects in given collection
#USAGE:
#./vt.sh findAll <database.collection>
if [ $1 == 'findAll' ]
then
    IFS='.' read -ra ADDR <<< "${@:(($#))}"             #Assign Internal Field Seperator to '.' and
                                                        #separate the last argument to take database name and collection name
                                                        #assign the seperated values as array to ADDR
    if [ ${#ADDR[@]} -eq 2 ]                            #If size of array is 2 means database and collection name is given
    then
        res=""                                          #Variable that keep the result
        cd ${ADDR[0]}                                   #Go to database directory
        cd ${ADDR[1]}                                   #Go to collection directory
        files=($(ls -d *.txt))                          #Gets the files in collection directory as array
        fil=${files[0]}                                 #Get the first file 
        while read -r line                              #Read the file line by line for all objects exist
        do
            id=${line%%":"*}                            #Get id of read line
            res+="<id>:${id}\n"                         #Add object id to result variable
            for cols in $(ls *.txt)                     #In all fields in collection 
            do
                val=$(grep "${id}" "$cols")             #Search fields with id
                res+="<${cols%%"."*}>":"${val#*":"}"    #Add found value by id to result
                res+='\n'
            done
            res+='-------------------------------\n'
            
        done < "$fil"
        printf $res    
    else
        echo '$fil'
    fi
fi

#Deletes given database, collection or record by provided value
#USAGE:
#./vt.sh delete db <dbname>
#./vt.sh delete col <db.colname>
#./vt.sh delete rec in <db.colname> where <field>=<value> 
if [ $1 == 'delete' ]
then
    if [ $2 == 'db' ]
    then
        rm -rf $3                                       #Delete given database folder
        echo "Database deleted"
    elif [ $2 == 'col' ]
    then
        str=$3
        cd ${str%%"."*}                                 #Go to database folder
        rm -rf ${str#*"."}                              #Delete the collection folder
        echo "Collection deleted"
    elif [[ $2 == 'rec' && $3 == 'in' && $5 == 'where' ]]
    then
        ADDR=(${4//./ })                                #Get database and collection name
        cd ${ADDR[0]}                                   #Go to database directory
        cd ${ADDR[1]}                                   #Go to collection directory

        str=$(grep "<${6#*"="}>" "${6%%"="*}.txt")      #Find the line includes given value in field file
        fieldID=${str%%":"*}                            #Get the id of record

        if [ ${#str} -ne 0 ]                            #If id exists
        then
            for file in $(ls *.txt)                     #In all fields in collection 
            do
                sed -i "" "/$fieldID/d" $file           #Deletes the line includes id in all field files
            done
            echo "Delete succesfully"
        else
            echo "No record found"
        fi
    else
        echo "Invalid command"
    fi 
fi

#./vt.sh update <db.col.field> set <newValue> where <oldValue>
if [ $1 == 'update' ]
then
    ADDR=(${2//./ })                                            #Gets the field name in given collection database
    if [ ${#ADDR[@]} -eq 3 ]                                    #If full collection name is given
    then
        cd ${ADDR[0]}                                           #Go to database directory
        cd ${ADDR[1]}                                           #Go to collection directory
        targetField=${ADDR[2]}.txt                              #Get field name and assign field 
        
        if [[ ($3 == 'set' && $5 == 'where') ]]                 #If the command given properly
        then

            oldValue=$(grep ":<$6>" "$targetField")             #Gets line includes old value
            if [ ${#oldValue} -eq 0 ]                           #If record not exists
            then
                echo "Record not found"
            else                                                #If record exists
                id=${oldValue%%":"*}                            #Get record id
                newValue="$id:<$4>"                             #set new value with same id
                echo $newValue
                sed -i -e "s/$oldValue/$newValue/" $targetField #replace new value with old value
                echo "Updated"
            fi
        else
            echo "Command is not correct"
        fi
    else
        echo 'Given Collection Not Found'
    fi  
 fi