
<!-- README.md is generated from README.Rmd. Please edit that file -->

# apinsee

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/RLesur/apinsee.svg?branch=master)](https://travis-ci.org/RLesur/apinsee)
[![Codecov test
coverage](https://codecov.io/gh/RLesur/apinsee/branch/master/graph/badge.svg)](https://codecov.io/gh/RLesur/apinsee?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/apinsee)](https://cran.r-project.org/package=apinsee)
<!-- badges: end -->

**apinsee** est un package pour le langage R destiné à faciliter
l’authentification aux API de l’Insee accessibles à l’adresse
[api.insee.fr](https://api.insee.fr/).

## Avertissement

**Ce package est en cours de développement. Ses fonctionnalités vont
évoluer.**

## Installation

Vous pouvez installer la version de développement depuis
[GitHub](https://github.com/) en exécutant :

``` r
remotes::install_github("rlesur/apinsee")
```

## Exemple

### Créer une application

Créez une application ayant accès à l’API Sirene sur le site
[api.insee.fr](https://api.insee.fr/) : voir
[l’aide](https://api.insee.fr/catalogue/site/themes/wso2/subthemes/insee/pages/help.jag).

Sauvegardez la clef du consommateur dans la variable d’environnement
`INSEE_API_KEY` et le secret du consommateur dans la variable
d’environnement `INSEE_API_SECRET` : la méthode la plus sûre est
d’enregistrer ces deux variables d’environnement dans votre fichier
`.Renviron`.

Pour accéder facilement au fichier `.Renviron`, vous pouvez utiliser la
commande `usethis::edit_r_environ("user")`.

Ajoutez ces deux lignes dans votre fichier `.Renviron` :

``` bash
INSEE_API_KEY="xxxxxxxxxxxxxxxxxx"    # clef du consommateur
INSEE_API_SECRET="yyyyyyyyyyyyyyyyyy" # secret du consommateur
```

Sauvegardez ce fichier et **redémarrez votre session R**.

### Créer un jeton d’accès

Le package **apinsee** ne comprend qu’une fonction utile :
`insee_auth()`. Cette fonction permet de récupérer un jeton d’accès à
votre application. Ce jeton d’accès peut être affecté à un objet et est
sauvegardé de façon interne dans votre session R. Vous pouvez donc
simplement exécuter la fonction :

``` r
token <- apinsee::insee_auth()
```

Les jetons d’accès ayant une durée de validité limitée, cette fonction
permet de récupérer automatiquement un jeton valide.

### Intégrer **apinsee**

Imaginons que vous souhaitiez développer un package qui accède à l’API
Sirene. Vous pouvez créer la fonction suivante :

``` r
requete_siren_unitaire <- function(
  siren, date = NULL, token = apinsee::insee_auth()
) {
  
  url <- httr::modify_url(
    "https://api.insee.fr/", 
    path = c("entreprises", "sirene", "V3", "siren", siren), 
    query = list(date = date)
  )
  
  res <- httr::GET(url, httr::config(token = token))
  httr::stop_for_status(res)
  httr::content(res)[["uniteLegale"]]
}
```

Dès lors, votre utilisateur (s’il renseigne les variables
d’environnement précédentes) aura à simplement exécuter la fonction
`requete_sirene_unitaire()` de votre package :

``` r
requete_siren_unitaire(siren = "005520135", date = Sys.Date())
#> $siren
#> [1] "005520135"
#> 
#> $statutDiffusionUniteLegale
#> [1] "O"
#> 
#> $dateCreationUniteLegale
#> [1] "1955-01-01"
#> 
#> $sigleUniteLegale
#> NULL
#> 
#> $sexeUniteLegale
#> NULL
#> 
#> $prenom1UniteLegale
#> NULL
#> 
#> $prenom2UniteLegale
#> NULL
#> 
#> $prenom3UniteLegale
#> NULL
#> 
#> $prenom4UniteLegale
#> NULL
#> 
#> $prenomUsuelUniteLegale
#> NULL
#> 
#> $pseudonymeUniteLegale
#> NULL
#> 
#> $identifiantAssociationUniteLegale
#> NULL
#> 
#> $trancheEffectifsUniteLegale
#> [1] "NN"
#> 
#> $anneeEffectifsUniteLegale
#> NULL
#> 
#> $dateDernierTraitementUniteLegale
#> [1] "2009-09-26T08:36:53"
#> 
#> $nombrePeriodesUniteLegale
#> [1] 8
#> 
#> $categorieEntreprise
#> NULL
#> 
#> $anneeCategorieEntreprise
#> NULL
#> 
#> $periodesUniteLegale
#> $periodesUniteLegale[[1]]
#> $periodesUniteLegale[[1]]$dateFin
#> NULL
#> 
#> $periodesUniteLegale[[1]]$dateDebut
#> [1] "2007-11-19"
#> 
#> $periodesUniteLegale[[1]]$etatAdministratifUniteLegale
#> [1] "C"
#> 
#> $periodesUniteLegale[[1]]$changementEtatAdministratifUniteLegale
#> [1] TRUE
#> 
#> $periodesUniteLegale[[1]]$nomUniteLegale
#> NULL
#> 
#> $periodesUniteLegale[[1]]$changementNomUniteLegale
#> [1] FALSE
#> 
#> $periodesUniteLegale[[1]]$nomUsageUniteLegale
#> NULL
#> 
#> $periodesUniteLegale[[1]]$changementNomUsageUniteLegale
#> [1] FALSE
#> 
#> $periodesUniteLegale[[1]]$denominationUniteLegale
#> [1] "CHANVI GESTION"
#> 
#> $periodesUniteLegale[[1]]$changementDenominationUniteLegale
#> [1] FALSE
#> 
#> $periodesUniteLegale[[1]]$denominationUsuelle1UniteLegale
#> NULL
#> 
#> $periodesUniteLegale[[1]]$denominationUsuelle2UniteLegale
#> NULL
#> 
#> $periodesUniteLegale[[1]]$denominationUsuelle3UniteLegale
#> NULL
#> 
#> $periodesUniteLegale[[1]]$changementDenominationUsuelleUniteLegale
#> [1] FALSE
#> 
#> $periodesUniteLegale[[1]]$categorieJuridiqueUniteLegale
#> [1] "5710"
#> 
#> $periodesUniteLegale[[1]]$changementCategorieJuridiqueUniteLegale
#> [1] FALSE
#> 
#> $periodesUniteLegale[[1]]$activitePrincipaleUniteLegale
#> [1] "74.1J"
#> 
#> $periodesUniteLegale[[1]]$nomenclatureActivitePrincipaleUniteLegale
#> [1] "NAFRev1"
#> 
#> $periodesUniteLegale[[1]]$changementActivitePrincipaleUniteLegale
#> [1] FALSE
#> 
#> $periodesUniteLegale[[1]]$nicSiegeUniteLegale
#> [1] "00038"
#> 
#> $periodesUniteLegale[[1]]$changementNicSiegeUniteLegale
#> [1] FALSE
#> 
#> $periodesUniteLegale[[1]]$economieSocialeSolidaireUniteLegale
#> NULL
#> 
#> $periodesUniteLegale[[1]]$changementEconomieSocialeSolidaireUniteLegale
#> [1] FALSE
#> 
#> $periodesUniteLegale[[1]]$caractereEmployeurUniteLegale
#> [1] "O"
#> 
#> $periodesUniteLegale[[1]]$changementCaractereEmployeurUniteLegale
#> [1] FALSE
```

Dans le cas où votre utilisateur ne souhaiterait pas renseigner les
variables d’environnement, il devra préalablement s’authentifier en
exécutant :

``` r
apinsee::insee_auth(
  key = "xxxxxxxxxxxxxxxxxxxx", # clef du consommateur
  secret = "yyyyyyyyyyyyyyyyyy" # secret du consommateur
)
```

## TODO

  - Offrir des fonctions qui gèrent les jetons d’accès expirés.

  - Vérifier s’il existe un point d’accès de validation des jetons
    d’accès.
