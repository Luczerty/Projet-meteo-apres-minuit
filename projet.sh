#!/bin/bash


. fonctions.sh  # On inclut un autre fichier .sh qui contient des fonctions


# ----------------------------------------------------------------------------------------------------


# On vérifie le nombre d'argument et le message d'aide

if [ "$#" -eq 0 ] ; then    # On vérifie s'il n'y a aucun argument
    echo "Erreur: vous n'avez pas saisit d'arguments."  # Message d'erreur
    echo -e "Référez-vous au --help si vous avez besoin d'aide.\n"
    exit 1
elif [ "$#" -eq 1 ] && [ "$1" == "--help" ] ; then      # On vérifie si on veut lire l'aide
    Help     # Message d'aide
    exit 0
fi


# ----------------------------------------------------------------------------------------------------


# On vérifie si les exécutables du programme en c sont présent

if [ ! -e triAVL ] ; then   # S'il n'est pas présent
    echo "L'executable pour le tri avec un AVL n'est pas présent: compilation en cours."
    sleep 1
    gcc triAVL.c -o triAVL
    echo "L'executable a été crée."
    sleep 1.5
fi
if [ ! -e triABR ] ; then   # S'il n'est pas présent
    echo "L'executable pour le tri avec un ABR n'est pas présent: compilation en cours."
    sleep 1
    gcc triABR.c -o triABR
    echo "L'executable a été crée."
    sleep 1.5
fi
if [ ! -e triLC ] ; then   # S'il n'est pas présent
    echo "L'executable pour le tri avec une liste chaînée n'est pas présent: compilation en cours."
    sleep 1
    gcc triLC.c -o triLC
    echo "L'executable a été crée."
    sleep 1.5
fi


# ----------------------------------------------------------------------------------------------------


# On initialisation des arguments de donnés clés

t=0     # Argument de la température initialisé à 0
p=0     # Argument de la pression atmosphérique initialisé à 0
w=0     # Argument du vent initialisé à 0
h=0     # Argument de l'altitude initialisé à 0
m=0     # Argument de l'humidité initialisé à 0
f=0     # Argument du fichier initialisé à 0

# On initialisation des arguments de tris

tab=0   # Argument du tri avec tab
abr=0   # Argument du tri avec avl
avl=0   # Argument du tri avec abr

ARGUMENTS="$(getopt -o :LRTd:FGSAOQt:p:whmf: --long  avl,abr,tab -- "$@")"    # On définie tous les arguments possibles

if [ $? -ne 0 ] ; then  # On vérifie si les arguments sont corrects
    echo "Erreur: argument incorrect."  # Message d'erreur
    echo -e "Référez-vous au --help si vous avez besoin d'aide.\n"
    exit 1
fi

eval set -- "$ARGUMENTS"    # On assige chaque $i à un caractère dans l'ordre des arguments
unset ARGUMENTS

while true ; do # On analyse tous les arugments
    case "$1" in
        -T | --tab)
            tab=1
            shift
            ;;
        -R | --abr)
            abr=1
            shift
            ;;
        -L | --avl)
            avl=1
            shift
            ;;
        -d)
            d=$2      # -d est présent
            shift 2
            ;;
        -F)
            F=1             # -F est présent
            shift
            ;;
        -G)
            G=1             # -G est présent
            shift
            ;;
        -S)
            S=1             # -S est présent
            shift
            ;;
        -A)
            A=1             # -A est présent
            shift
            ;;
        -O)
            O=1             # -O est présent
            shift
            ;;
        -Q)
            Q=1             # -Q est présent
            shift
            ;;
        -t)
            t=$2
            if [ "$t" -lt 1 ]  || [ "$t" -gt 3 ] ; then   # On vérifie le mode pour la température
                echo "Erreur: mode incorrect pour la température. Sasir t1, t2 ou t3 selon le mode voulu."  # Message d'erreur
                echo -e "Référez-vous au --help si vous avez besoin d'aide.\n"
                exit 1
            fi
            shift 2
            ;;
        -p)
            p=$2
            if [ "$p" -lt 1 ]  || [ "$p" -gt 3 ] ; then   # On vérifie le mode pour la pression
                echo "Erreur: mode incorrect pour la pression. Sasir p1, p2 ou p3 selon le mode voulu."  # Message d'erreur
                echo -e "Référez-vous au --help si vous avez besoin d'aide.\n"
                exit 1
            fi
            shift 2
            ;;
        -w)
            w=1             # -w est présent
            shift
            ;;
        -h)
            h=1             # -h est présent
            shift
            ;;
        -m)
            m=1             # -m est présent
            shift
            ;;
        -f)
            f=$2
            shift 2
            ;;
        --)
            break
            ;;
        *)
            echo "Erreur: argument incorrect."  # Message d'erreur
            echo -e "Référez-vous au --help si vous avez besoin d'aide.\n"
            exit 1
            ;;
    esac
done

# On test les arguments clés, c'est-à-dire -t, -p, -h ou -m

if [ "$#" -gt 0 ] && ([ "$t" -eq 0 ] && [ "$p" -eq 0 ] && [ "$w" -eq 0 ] && [ "$h" -eq 0 ] && [ "$m" -eq 0 ]) ; then   # On vérifie qu'on ait au moins un argument clé
    echo "Erreur: il manque un argument clé: -t, -p, -w, -h ou -m."     # Message d'erreur
    echo -e "Référez-vous au --help si vous avez besoin d'aide.\n"
    exit 1
elif [ ! -e "$f" ] || [ ! -f "$f" ] ; then
    echo "Erreur: le ficher "$f" n'existe pas, veuillez en saisir un nouveau. N'oubliez pas son extension." # Message d'erreur
    echo -e "Référez-vous au --help si vous avez besoin d'aide.\n"
    exit 2
fi


# ----------------------------------------------------------------------------------------------------


# Premier filtrage: date

if [ -n "$d" ] ; then   # On vérifie si un filtrage selon la date est nécessaire

    DATE1=$(echo "$d" | awk -F "/" '{print $1}')    # On récupère la première date
    DATE2=$(echo "$d" | awk -F "/" '{print $2}')    # On récupère la seconde date

    ANNEE1=$(echo "$DATE1" | awk -F "-" '{print $1}')   # On récupère la première année
    ANNEE2=$(echo "$DATE2" | awk -F "-" '{print $1}')   # On récupère la seconde année

    if [ -z $ANNEE1 ] || [ -z $ANNEE2 ] || ([ $ANNEE1 -lt 2010 ] || [ $ANNEE1 -gt 2022 ]) || ([ $ANNEE2 -lt 2010 ] || [ $ANNEE2 -gt 2022 ]) ; then      # On vérifié si les deux années sont correctes
        echo "Erreur: date incorrecte."     # Message d'erreur
        exit 3
    elif [ $ANNEE1 -gt $ANNEE2 ] ; then     # On vérifié si les deux années sont correctes
        echo "Erreur: la première année doit être inférieure à la seconde."     # Message d'erreur
        exit 3
    else
        MOIS1=$(echo "$DATE1" | awk -F "-" '{print $2}')    # On récupère le premier mois        
        MOIS2=$(echo "$DATE2" | awk -F "-" '{print $2}')    # On récupère le second mois
        if [ -z $MOIS1 ] || [ -z $MOIS2 ] || ([ $MOIS1 -lt 1 ] || [ $MOIS1 -gt 12 ]) || ([ $MOIS2 -lt 01 ] || [ $MOIS2 -gt 12 ]) ; then     # On vérifié si les deux mois sont corrects
            echo "Erreur: mois incorrect."      # Message d'erreur
            exit 3
        else
            JOUR1=$(echo "$DATE1" | awk -F "-" '{print $3}')    # On récupère le premier jour           
            JOUR2=$(echo "$DATE2" | awk -F "-" '{print $3}')    # On récupère le second jour  
            if [ -z $JOUR1 ] || [ -z $JOUR2 ] || ([ $JOUR1 -lt 1 ] || [ $JOUR1 -gt 31 ]) || ([ $JOUR2 -lt 1 ] || [ $JOUR2 -gt 31 ]) ; then      # On vérifié si les deux jours sont corrects
                echo "Erreur: jour incorrect."  # Message d'erreur
                exit 3
            fi
        fi
    fi

    echo "Filtre selon les dates min et max."

    # Trie selon la date min et max

    head -n1 "$f" > filtre.csv
    awk -v A1="$ANNEE1" -v M1="$MOIS1" -v J1="$JOUR1" -v A2="$ANNEE2" -v M2="$MOIS2" -v J2="$JOUR2" -F'[;T-]' '{  
        if($2>A1 && $2<A2)
        {
            print;
        }
        else
        {
            if($2==A1 && $2==A2) 
            {
                if($3==M1 && $3==M2) 
                {
                    if($4==J1 && $4==J2)
                    {
                        print;
                    }
                }
                else
                {   
                    if($3>M1 && $3<M2)
                    {
                        print;
                    }
                    else
                    {
                        if($3==M1)
                        {
                            if($4>=J1)
                            {
                                print;
                            }
                        }
                        if($3==M2)
                        {
                            if($4<=J2)
                            {
                                print;
                            }
                        }
                    }
                }
            }
            else
            {
                if($2==A1)
                {
                    if($3>M1)
                    {
                        print;
                    }
                    else
                    {
                        if($3==M1)
                        {
                            if($4>=J1)
                            {
                                print;
                            }
                        }
                    }
                }
                if($2==A2)
                {
                    if($3<M2)
                    {
                        print;
                    }
                    else
                    {
                        if($3==M2)
                        {
                            if($4<=J2)
                            {
                                print;
                            }
                        }
                    }
                }
            }
        }
    }' "$f" >> filtre.csv
    echo -e "Filtre selon les dates min et max effectué. \n"
    else
        echo -e "Pas de tri selon des dates min et max. \n"
fi

# Deuxième filtrage: lieux

if [ -n "$d" ] ; then
    f="filtre.csv"    # Si on a filtré par la date pour continuer de filtrer si besoin
fi
        
if [ -n "$F" ] ; then       # On vérifie si un filtrage selon le lieux, ici la France, est nécessaire
    echo "Filtre selon les données de France et de Corse."
    echo $(head -n1 "$f") > lieux.csv       # On insert la prémière ligne avec la signification de chaque colonne
    awk -F ";" '$15 ~ /[0-9][0-6][0-9][0-9][0-9]/' "$f" >> lieux.csv    # On prend en compte seulement les donneés provenant de France
    awk -F ";" '$15 ~ /[2][a-z][0-9][0-9][0-9]/' "$f" >> lieux.csv      # Et on ajoute les donneés provenant de Corse
    mv lieux.csv filtre.csv
    f="filtre.csv"
    echo -e "Le filtrage selon les données de France et de Corse a été effectué.\n"   # Message de validation

elif [ -n "$G" ] ; then     # On vérifie si un filtrage selon le lieux, ici la Guyane, est nécessaire
    echo "Filtre selon les données de Guyane."
    echo $(head -n1 "$f") > lieux.csv   # On insert la prémière ligne avec la signification de chaque colonne
    awk -F ";" '$15 ~ /[9][7][3][0-9][0-9]/' "$f" >> lieux.csv   # On prend en compte seulement les donneés provenant de Guyane
    mv lieux.csv filtre.csv
    f="filtre.csv"
    echo -e "Le filtrage selon les données de Guyane a été effectué.\n"   # Message de validation

elif [ -n "$S" ] ; then     # On vérifie si un filtrage selon le lieux, ici Saint-Pierre et Miquelon, est nécessaire
    echo "Filtre selon les données de Saint-Pierre et Miquelon."
    echo $(head -n1 "$f") > lieux.csv   # On insert la prémière ligne avec la signification de chaque colonne
    awk -F ";" '$15 ~ /[9][7][5][0-9][0-9]/' "$f" >> lieux.csv   # On prend en compte seulement les donneés provenant de Saint-Pierre-et-Miquelon
    mv lieux.csv filtre.csv
    f="filtre.csv"
    echo -e "Le filtrage selon les données de Saint-Pierre et Miquelon a été effecuté.\n"   # Message de validation

elif [ -n "$A" ] ; then     # On vérifie si un filtrage selon le lieux, ici les Antilles, est nécessaire
    echo "Filtre selon les données des Antilles."
    echo $(head -n1 "$f") > lieux.csv   # On insert la prémière ligne avec la signification de chaque colonne
    awk -F ";" '$15 ~ /[9][7][1,2,7,8][0-9][0-9]/' "$f" >> lieux.csv    # On prend en compte seulement les donneés provenant des Antilles
    mv lieux.csv filtre.csv
    f="filtre.csv"
    echo -e "Filtrage selon les données des Antilles effectué.\n"    # Message de validation

elif [ -n "$O" ] ; then     # On vérifie si un filtrage selon le lieux, ici l'océan Indien, est nécessaire
    echo "Filtre selon les données des îles de l'océan Indien."
    echo $(head -n1 "$f") > lieux.csv   # On insert la prémière ligne avec la signification de chaque colonne
    LC_NUMERIC="C" awk -F'[;,]' '$10 ~ /-[1-4][1-9]/' meteo_filtered_data_v1.csv >> lieux.csv
    #awk -F ";" '$15 ~ /[9][8][4][1][0-3]/' "$f" >> lieux.csv    # On prend en compte seulement les donneés provenant des îles de l'océan Indien
    mv lieux.csv filtre.csv
    f="filtre.csv"
    echo -e "Le filtrage selon les données des îles de l'océan Indien a été effectué.\n"  # Message de validation

elif [ -n "$Q" ] ; then     # On vérifie si un filtrage selon le lieux, ici l'Antarctique, est nécessaire
    echo "Filtre selon les données d'Antarctique."
    echo $(head -n1 "$f") > lieux.csv   # On insert la prémière ligne avec la signification de chaque colonne
    awk -F ";" '$10 ~ /^[-6][6]/' "$f" >> lieux.csv     # On prend en compte seulement les donneés provenant d'Antarctique
    mv lieux.csv filtre.csv
    f="filtre.csv"
    echo -e "Le filtrage selon les données d'Antarctique a été effectué.\n"   # Message de validation
else
    echo -e "Pas de filtrage selon le lieux.\n"
fi


# ----------------------------------------------------------------------------------------------------


# Troisième filtrage: types de données

# Température

if [ "$t" -eq 1 ] ; then
    echo "Filtre selon la température en mode 1."
    tail -n+2 "$f" | LC_NUMERIC="C" awk -F ";" '
    {
    if($11!="")
    {
        {
            ID=$1; TEMP=$11; som[ID]=som[ID]+TEMP; compt[ID]++
        }
        if(!(ID in min || ID in max))
        {
            min[ID]=TEMP
            max[ID]=TEMP
        }
        {
            if(min[ID]>TEMP)
            {
                min[ID]=TEMP
            }
        }
        {
            if(max[ID]<TEMP)
            {
                max[ID]=TEMP
            }
        }
    }
    }
    END{for(ID in som) print ID, min[ID], max[ID], som[ID]/compt[ID]}' > temperature1.txt    # On récupère l'ID de la station, la température max, la température min et la température moyenne que l'on met dans un fichier.txt
    sed -i 's/,/./g' temperature1.txt  # Transformer les virgules en points
    echo -e "Le fichier sur la température en mode 1 a été crée.\n"  # Message de validation
    if [ "$abr" -eq 1 ] ; then
        ./triABR f temperature1.txt o temperature1_trie.txt t
    elif [ "$tab" -eq 1 ] ; then
        ./triLC f temperature1.txt o temperature1_trie.txt t
    else
        ./triAVL f temperature1.txt o temperature1_trie.txt t
    fi
    rm temperature1.txt
    
    gnuplot -persist <<-EOFMarker
    set title "Température des stations"    # Titre du gnuplot
    set xlabel "ID de station"  # Nom de l'axe des x
    set ylabel "Température"    # Nom de l'axe des y
    set size ratio 1  # Taille du graphique
    set xtics rotate    # Rotation du nom des valeurs de l'axe x
    plot 'temperature1_trie.txt' using log(1):3:2:xtic(1) with filledcurve title "Ecart avec température min et max" lc rgb '#fde725', '' using log(1):4 smooth mcspline lw 2 title "Température moyenne"   # Commande pour produire le graphique
EOFMarker

    rm temperature1_trie.txt
elif [ "$t" -eq 2 ] ; then
    echo "Filtre selon la température en mode 2."
    tail -n+2 "$f" | awk -F";" '
    {
    if($11!="")
    {
        {
        DATE=$2; TEMP=$11; som[DATE]=som[DATE]+TEMP; compt[DATE]++
        }
    }
    }
    END{for(DATE in som) print DATE, som[DATE]/compt[DATE]}' > temperature2.txt
    sed -i 's/,/./g' temperature2.txt   # Transformer les virgules en points
    echo -e "Le fichier sur la température en mode 2 a été crée.\n"   # Message de validation
    if [ "$abr" -eq 1 ] ; then
        ./triABR f temperature2.txt o temperature2_trie.txt t
    elif [ "$tab" -eq 1 ] ; then
        ./triLC f temperature2.txt o temperature2_trie.txt t
    else
        ./triAVL f temperature2.txt o temperature2_trie.txt t
    fi
    rm temperature2.txt
    
    gnuplot -persist <<-EOFMarker
    set title "Moyenne des températures selon la date"  # Titre du gnuplot
    set xlabel "Date"   # Nom de l'axe des x
    set ylabel "Moyenne température"    # Nom de l'axe des y
    set size ratio 1  # Taille du graphique
    set xdata time  # On definit l'axe des x comme une date
    set timefmt "%Y-%m-%dT%H"   # Format de la date
    set xtic rotate # Rotation du nom des valeurs de l'axe x
    plot 'temperature2_trie.txt' using 1:2 with l title "Température"   # Commande pour produire le graphique
EOFMarker

    rm temperature2_trie.txt
elif [ "$t" -eq 3 ] ; then
    echo "Filtre selon la température en mode 3."
    tail -n+2 "$f" | awk -F'[;T:]' '
    {
        if($15!="")
        {
            print $1, $2, $3, $15
        }
    }' > temperature3.txt
    sed -i 's/,/./g' temperature3.txt  # Transformer les virgules en points
    echo -e "Le fichier sur la pression atmosphérique en mode 3 a été crée.\n"   # Message de validation 
    if [ "$abr" -eq 1 ] ; then
        ./triABR f temperature3.txt o temperature3_trie.txt t
    elif [ "$tab" -eq 1 ] ; then
        ./triLC f temperature3.txt o temperature3_trie.txt t
    else
        ./triAVL f temperature3.txt o temperature3_trie.txt t
    fi
    rm temperature3.txt
    gnuplot -persist <<-EOFMarker
    set title "Températures selon la date/heure"
    set xlabel "Jour"
    set ylabel "Température"
    unset key
    set xdata time
    set timefmt "%Y-%m-%d"
    set format x "%Y-%m-%d"
    set xtic rotate
    set datafile separator " "
    set palette model RGB defined (1 "#440154", 4 "#472c7a", 7 "#3b518b" , 10 "#2c718e", 13 "#21908d", 16 "#27ad81", 19 "#5cc863", 22 "#aadc32")
    set cbrange [1:22]
    set cbtics format ""
    set cbtics ("1H" 1, "4H" 4, "7H" 7, "10H" 10, "13H" 13, "16H" 16, "19H" 19, "22H" 22)
    plot 'temperature3_trie.txt' using 2:4:3 with l title "Température" palette
EOFMarker

    rm temperature3_trie.txt
fi

# Pression atmosphérique

if [ "$p" -eq 1 ] ; then
    echo "Filtre selon la pression atmosphérique en mode 1."
    tail -n+2 "$f" | LC_NUMERIC="C" awk -F ";" '
    {
    if($7!="")
    {
        {
            ID=$1; PRES=$7; som[ID]=som[ID]+PRES; compt[ID]++
        }
        if(!(ID in min || ID in max))
        {
            min[ID]=PRES
            max[ID]=PRES
        }
        {
            if(min[ID]>PRES)
            {
                min[ID]=PRES
            }
        }
        {
            if(max[ID]<PRES)
            {
                max[ID]=PRES
            }
        }
    }
    }
    END{for(ID in som) print ID, min[ID], max[ID], som[ID]/compt[ID]}' > pression1.txt    # On récupère l'ID de la station, la pression max, la pression min et la pression moyenne que l'on met dans un fichier.txt
    sed -i 's/,/./g' pression1.txt  # Transformer les virgules en points
    echo -e "Le fichier sur la pression atmosphérique en mode 1 a été crée.\n"   # Message de validation
    if [ "$abr" -eq 1 ] ; then
        ./triABR f pression1.txt o pression1_trie.txt p
    elif [ "$tab" -eq 1 ] ; then
        ./triLC f pression1.txt o pression1_trie.txt p
    else
        ./triAVL f pression1.txt o pression1_trie.txt p
    fi
    rm pression1.txt
    
    gnuplot -persist <<-EOFMarker
    set title "Pression des stations"   # Titre du gnuplot
    set xlabel "ID de station"  # Nom de l'axe des x
    set ylabel "Pression"   # Nom de l'axe des y
    set size ratio 1  # Taille du graphique
    set xtics rotate    # Rotation du nom des valeurs de l'axe x
    plot 'pression1_trie.txt' using log(1):3:2:xtic(1) with filledcurve title "Ecart avec pression min et max" lc rgb '#fde725', '' using log(1):4 smooth mcspline lw 2 title "Pression moyenne" # Commande pour produire le graphique
EOFMarker

    rm pression1_trie.txt
elif [ "$p" -eq 2 ] ; then
    echo "Filtre selon la pression atmosphérique en mode 2."
    tail -n+2 "$f" | awk -F";" '
    {
    if($7!="")
    {
        {
        DATE=$2; PRES=$7; som[DATE]=som[DATE]+PRES; compt[DATE]++
        }
    }
    }
    END{for(DATE in som) print DATE, som[DATE]/compt[DATE]}' > pression2.txt
    sed -i 's/,/./g' pression2.txt  # Transformer les virgules en points
    echo -e "Le fichier sur la pression atmosphérique en mode 2 a été crée.\n"   # Message de validation
    if [ "$abr" -eq 1 ] ; then
        ./triABR f pression2.txt o pression2_trie.txt p
    elif [ "$tab" -eq 1 ] ; then
        ./triLC f pression2.txt o pression2_trie.txt p
    else
        ./triAVL f pression2.txt o pression2_trie.txt p
    fi
    rm pression2.txt
    
    gnuplot -persist <<-EOFMarker
    set title "Moyenne des pression selon la date"  # Titre du gnuplot
    set xlabel "Date"   # Nom de l'axe des x
    set ylabel "Moyenne pression"   # Nom de l'axe des y
    set size ratio 1  # Taille du graphique
    set xdata time  # On definit l'axe des x comme une date
    set timefmt "%Y-%m-%dT%H"   # Format de la date
    set xtic rotate # Rotation du nom des valeurs de l'axe x
    plot 'pression2_trie.txt' using 1:2 with l title "Pression" # Commande pour produire le graphique
EOFMarker

    rm pression2_trie.txt
elif [ "$p" -eq 3 ] ; then
    echo "Filtre selon la pression atmosphérique en mode 3."
    tail -n+2 "$f" | awk -F'[;T:]' '
    {
        if($11!="")
        {
            print $1, $2, $3 ,$11
        }
    }' > pression3.txt
    sed -i 's/,/./g' pression3.txt  # Transformer les virgules en points
    echo -e "Le fichier sur la pression atmosphérique en mode 3 a été crée.\n"   # Message de validation 
    if [ "$abr" -eq 1 ] ; then
        ./triABR f pression3.txt o pression3_trie.txt p
    elif [ "$tab" -eq 1 ] ; then
        ./triLC f pression3.txt o pression3_trie.txt p
    else
        ./triAVL f pression3.txt o pression3_trie.txt p
    fi
    rm pression3.txt
    
    gnuplot -persist <<-EOFMarker
    set title "Pression selon la date/heure"
    set xlabel "Jour"
    set ylabel "Pression"
    unset key
    set xdata time
    set timefmt "%Y-%m-%d %H"
    set xtic rotate
    set datafile separator " "
    set palette model RGB defined (1 "#440154", 4 "#472c7a", 7 "#3b518b" , 10 "#2c718e", 13 "#21908d", 16 "#27ad81", 19 "#5cc863", 22 "#aadc32")
    set cbrange [1:22]
    set cbtics format ""
    set cbtics ("1H" 1, "4H" 4, "7H" 7, "10H" 10, "13H" 13, "16H" 16, "19H" 19, "22H" 22)
    plot 'pression3_trie.txt' using 2:4:3 with l title "Prssion" palette
EOFMarker

    rm pression3_trie.txt
fi

# Vent

if [ "$w" -eq 1 ] ; then
    echo "Filtre selon le vent."
    tail -n+2 "$f" | awk -F'[;,]' '
    {
    if($4!="")
    {
        ID=$1; DIR=$4; somDIRX[ID]=somDIRX[ID]+DIR*sin(DIR); somDIRY[ID]=somDIRY[ID]+DIR*cos(DIR); comptDIR[ID]++
    }
    if($5!="")
    {
        VIT=$5; somVIT[ID]=somVIT[ID]+VIT; comptVIT[ID]++; LAT=$10; LONG=$11
    }
    }
    !(LAT in lat) {
        lat[ID]=LAT
        long[ID]=LONG
    }
    END{for(ID in somDIRX) print ID, somDIRX[ID]/comptDIR[ID], somDIRY[ID]/comptDIR[ID], somVIT[ID]/comptVIT[ID], long[ID], lat[ID]}' > vent.txt  # On récupère l'ID de la station, l'orientation moyenne des vents et la vitesse moyenne des vents que l'on met dans un fichier.tx
    sed -i 's/,/./g' vent.txt   # Transformer les virgules en points
    echo -e "Le fichier sur le vent a été crée.\n"    # Message de validation
    if [ "$abr" -eq 1 ] ; then
        ./triABR f vent.txt o vent_trie.txt v
    elif [ "$tab" -eq 1 ] ; then
        ./triLC f vent.txt o vent_trie.txt v
    else
        ./triAVL f vent.txt o vent_trie.txt v
    fi
    rm vent.txt
    
    gnuplot -persist <<-EOFMarker
    set title "Vitesse moyen du vent selon des vecteurs"  # Titre du gnuplot
    set xlabel "Longitude"  # Nom de l'axe des x
    set ylabel "Latitude"   # Nom de l'axe des y
    set size ratio 1    # Taille du graphique
    set palette rgb 33,13,10    # Mis en place d'une palette pour des couleurs
    plot 'vent_trie.txt' using 5:6:(column(2)*3):(column(3)*3):4 with vectors palette title "vent"  # Commande pour produire le graphique. On a multiplé les composantes x et y des vecteurs pour mieux les voir
EOFMarker

    rm vent_trie.txt
fi

# Altitude

if [ "$h" -eq 1 ] ; then
    echo "Filtre selon l'altitude."
    tail -n+2 "$f" | LC_NUMERIC="C" awk -F'[;,]' '
    {
        ID=$1; H=$15; LAT=$10; LONG=$11
    }
    !(ID in alt) {
        alt[ID]=H
        lat[ID]=LAT
        long[ID]=LONG
    }
    END{for(ID in alt) print alt[ID], long[ID], lat[ID]}' > altitude.txt   # On récupère l'ID de la station, l'altitude et les coordonnées que l'on met dans un fichier.txt
    sed -i 's/,/./g' altitude.txt  # Transformer les virgules en points
    echo -e "Le fichier sur l'altitude a été crée.\n"    # Message de validation
    if [ "$abr" -eq 1 ] ; then
        ./triABR r f altitude.txt o altitude_trie.txt h
    elif [ "$tab" -eq 1 ] ; then
        ./triLC r f altitude.txt o altitude_trie.txt h
    else
        ./triAVL r f altitude.txt o altitude_trie.txt h
    fi
    rm altitude.txt
    
    gnuplot -persist <<-EOFMarker
    set title "Altitude des station"    # Titre du gnuplot
    set xlabel "Longitude"  # Nom de l'axe des x
    set ylabel "Latitude"   # Nom de l'axe des y
    set size ratio 1  # Taille du graphique
    set palette rgb 33,13,10    # Mis en place d'une palette pour des couleurs
    splot 'altitude_trie.txt' using 2:1:3 ls 7 ps 2 palette title "Altitudes des stations"  # Commande pour produire le graphique
EOFMarker

    rm altitude_trie.txt
fi

# Humidité

if [ "$m" -eq 1 ] ; then
    echo "Filtre selon l'humidité."
    tail -n+2 "$f" | awk -F'[;,]' '
    {
        ID=$1; M=$6; LAT=$10; LONG=$11
    }
    !(ID in moist) {
        moist[ID]=M
        lat[ID]=LAT
        long[ID]=LONG
    }
    {
        if(moist[ID]<M)
        {
            moist[ID]=M
        }
    }
    END{for(ID in moist) print moist[ID], long[ID], lat[ID]}' > humidite.txt     # On récupère l'ID de la station, l'humidité et les coordonnées que l'on met dans un fichier.txt
    sed -i 's/,/./g' humidite.txt  # Transformer les virgules en points
    echo -e "Le fichier sur l'humidite a été crée.\n"    # Message de validation
    if [ "$abr" -eq 1 ] ; then
        ./triABR r f humidite.txt o humidite_trie.txt m
    elif [ "$tab" -eq 1 ] ; then
        ./triLC r f humidite.txt o humidite_trie.txt m
    else
        ./triAVL r f humidite.txt o humidite_trie.txt m
    fi
    rm humidite.txt
    
    gnuplot -persist <<-EOFMarker
    set title "Humidité max par station"    # Titre du gnuplot
    set xlabel "Longitude"  # Nom de l'axe des x
    set ylabel "Latitude"   # Nom de l'axe des y
    set size ratio 1  # Taille du graphique
    stats 'humidite_trie.txt' using 1 name 'h' nooutput # On récupère les valeurs de l'humidité
    set cbrange [h_min:h_max]   # Encadrement de la teinte de couleurs
    unset key   # Effacement de la légende 
    set pm3d map
    set dgrid3d 100,100
    set pm3d interpolate 0,0
    splot 'humidite_trie.txt' using 2:3:1   # Commande pour produire le graphique
EOFMarker

    rm humidite_trie.txt
fi

if [ -e "filtre.csv" ] ; then   # On vérifie si on a utilisé un fichier temporaire pour le filtrage
    rm filtre.csv   # On suprrime le fichier temporaire qui a servi à filtrer le fichier principal
fi
