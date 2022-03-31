#define ELEMENT_TYPE	byte    // Type des éléments du tableau
#define BITS_POS	    3	    // Nombre de bits sur lesquels sont codés les indices du tableau
#define N               7	    // Nombre d'éléments du tableau (2 ^ BITS_POS - 1)

ELEMENT_TYPE tab[N];	// Tableau à trier (global pour simplifier l'accès)

// ------- Fonctions de tri ----------------------------------------------------

#ifndef VERIFY_PARTITION
// Effectue le tri rapide du tableau tab
// Entrée :
//      chan c : un canal pour prévenir de la fin de l'exécution
//      short lo : indice du début de la portion de tableau à trier
//      short hi : indice de fin de la portion de tableau à trier
// Sortie :
//      Le tableau tab est trié entre les indices lo et hi.
//
proctype quicksort(chan r; short lo, hi) {
    // Variable permettant de récupérer le pivot
    ELEMENT_TYPE p;
    // Canal auxiliaire pour récuperer la valeur de retour de partion et
    // détecter la fin d'exécution des appels à quicksort
    chan c = [0] of {ELEMENT_TYPE};
    if
    :: (lo >= 0 && hi >= 0 && lo < hi) ->
	    run partition(c, lo, hi);	// Appel à partition
	    c?p;   // Récupération du pivot
	    // Appels récursifs à quicksort
   	    run quicksort(c, lo, p - 1);
	    c?_;   // La valeur de retour est ignorée car pas importante
	    run quicksort(c, p + 1, hi);
	    c?_;
    :: else
    fi
    // Fin, envoi du message dans le canal
    r!1;
}
#endif

// Effectue les partitions du tableau selon le "schéma de partition de Lomuto"
// Entrée :
//      chan c : canal permettant de renvoyer l'indice du pivot
//      unsigned lo : indice du début de la portion du tableau à partitionner
//      unsigned lo : indice de fin de la portion du tableau à partitionner
// Sortie :
//	Renvoie p, l'indice du pivot, tel que :
//	    - pour tout x dans [lo, p - 1] : tab[x] <= tab[p]
//	    - pour tout x dans [p + 1, hi] : tab[x] >= tab[p]
//
proctype partition(chan c; unsigned lo : BITS_POS; unsigned hi : BITS_POS) {
    // Le pivot est le dernier élément
    ELEMENT_TYPE pivot = tab[hi];
    short i = lo - 1;
    unsigned j : BITS_POS = lo;
    // Parcours du tableau entre lo et hi
    for (j : lo .. hi) {
        if
        :: (tab[j] <= pivot) ->
                i++;
                // swap
                ELEMENT_TYPE tmp = tab[j];
                tab[j] = tab[i];
                tab[i] = tmp;
        :: else
        fi
    }
    c!i;
}

// ------- Fonctions de vérifications ------------------------------------------

#ifdef VERIFY_SORT
// Vérifie à l'aide des assertions si le tableau est effectivement trié
proctype check_sort() {
    byte i = 0;
    ELEMENT_TYPE e = 0;
    // Pour chaque élément du tableau, on vérifie s'il est supérieur à celui qui
    // le précède, si oui, le tableau est correctement trié
    for (i : 0 .. N - 1) {
	    assert(e <= tab[i]);
	    e = tab[i];
    }
}
#endif

#ifdef VERIFY_PARTITION
// Vérifie à l'aide des assertions si le partitionnement est correct
proctype check_partition(unsigned p : BITS_POS; unsigned lo : BITS_POS;	unsigned hi : BITS_POS) {
    unsigned i : BITS_POS = lo;
    ELEMENT_TYPE pivot = tab[p];
    // Soit i l'indice d'un élément du tableau et p l'indice du pivot, vérifie pour chaque
    // valeur de i entre lo et hi :
    //      - si i < p alors l'élément à l'indice i est inférieur ou égale au pivot
    //      - sinon, l'élément à l'indice i est supérieur ou égale au pivot
    // Si oui, le tableau est correctement partitionné autour du pivot p
    for (i : lo .. hi) {
        if
        :: i < p -> assert(tab[i] <= pivot);
        :: else -> assert(tab[i] >= pivot);
        fi
    }
}
#endif

// ------- Fonctions auxiliaires -----------------------------------------------

#ifdef SHOW_SORT
// Affiche le contenu d'un tableau
proctype print_array(chan r) {
    byte i = 0;
    printf("[");
    for (i : 0 .. N - 1) {
        printf("%d ", tab[i]);
    }
    printf("]\n");
    r!1;
}
#endif

// Génère un tableau aléatoire de N éléments
// Utilise la méthode select du langage SPIN pour générer des nombres aléatoires
proctype random_array(chan r) {
    byte i = 0;
    // Rempli le tableau global de taille N
    for (i : 0 .. N - 1) {
	    ELEMENT_TYPE e;
	    select(e : 1 .. N);	// Renvoie un nombre aléatoire entre 0 et N
	    tab[i] = e;
    }
    r!1;
}

// ------- Fonction principale -------------------------------------------------

init {
    // Canal de communication
    chan end = [0] of {ELEMENT_TYPE};
    // Rempli le tableau tab de manière aléatoire
    run random_array(end);
    end?_;

#ifdef SHOW_SORT
    printf("Tableau de départ :\n");
    run print_array(end);
    end?_;
#endif


#ifdef VERIFY_SORT
    // Appelle quicksort pour effectuer le tri
    run quicksort(end, 0, N - 1);
    end?_;
    // Teste si le tri est correct
    run check_sort();
#endif

#ifdef VERIFY_PARTITION
    // Lance la fonction partition pour effectuer le test
    unsigned p : BITS_POS;
    run partition(end, 0, N - 1);
    end?p;
    // Test la validité de la fonction partition
    run check_partition(p, 0, N - 1);
#endif

#ifdef SHOW_SORT
    run quicksort(end, 0, N - 1);
    end?_;
    printf("Tableau après tri :\n");
    run print_array(end);
    end?_;
#endif
}
