
<!-- README.md is generated from README.Rmd. Please edit that file -->

# apinsee

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/InseeFrLab/apinsee.svg?branch=master)](https://travis-ci.org/InseeFrLab/apinsee)
[![Codecov test
coverage](https://codecov.io/gh/InseeFrLab/apinsee/branch/master/graph/badge.svg)](https://codecov.io/gh/InseeFrLab/apinsee?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/apinsee)](https://cran.r-project.org/package=apinsee)
<!-- badges: end -->

**apinsee** est un package pour le langage R destiné à faciliter
l’authentification aux API de l’Insee accessibles à l’adresse
[api.insee.fr](https://api.insee.fr/).

## Avertissement

**Ce package est en cours de développement. Ses fonctionnalités peuvent
évoluer.**

## Motivation

Comme toutes les API modernes, l’utilisation des API de l’Insee requiert
d’utiliser une procédure d’authentification et de récupérer un jeton
d’accès. Le site [api.insee.fr](https://api.insee.fr/) recommande
d’utiliser un nouveau jeton d’accès toutes les 24 heures.

L’objectif du package **apinsee** est de faciliter la gestion et
l’utilisation de ces jetons d’accès conformément à ces
recommandations.

## Installation

Vous pouvez installer la version de développement depuis
[GitHub](https://github.com/) en exécutant :

``` r
remotes::install_github("inseefrlab/apinsee")
```

## Exemple

### Créer une application

Créez une application sur le site [api.insee.fr](https://api.insee.fr/)
: voir
[l’aide](https://api.insee.fr/catalogue/site/themes/wso2/subthemes/insee/pages/help.jag).

Sauvegardez la clef du consommateur dans la variable d’environnement
`INSEE_APP_KEY` et le secret du consommateur dans la variable
d’environnement `INSEE_APP_SECRET` : la méthode la plus sûre est
d’enregistrer ces deux variables d’environnement dans votre fichier
`.Renviron`.

Pour accéder facilement au fichier `.Renviron`, vous pouvez utiliser la
commande `usethis::edit_r_environ("user")`.

Ajoutez ces deux lignes dans votre fichier `.Renviron` :

``` bash
INSEE_APP_KEY=xxxxxxxxxxxxxxxxxx    # clef du consommateur
INSEE_APP_SECRET=yyyyyyyyyyyyyyyyyy # secret du consommateur
```

Sauvegardez ce fichier et **redémarrez votre session R**.

### Créer et utiliser un jeton d’accès

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

Ce token peut ensuite être utilisé comme valeur du paramètre `token` de
la fonction `httr::config()` :

``` r
library(httr)
set_config(config(token = token))
```

Dès lors, vous pouvez accéder aux API de l’Insee auxquelles votre
application a souscrites.

## Utiliser **apinsee** dans votre package

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
  
  # check for rate limit
  if (identical(httr::status_code(res), 429L)) {
    Sys.sleep(60)
    res <- httr::GET(url, httr::config(token = token))
  }
  
  httr::stop_for_status(res)
  httr::content(res)[["uniteLegale"]]
}
```

Dès lors, votre utilisateur (s’il utilise une application ayant souscrit
à l’API Sirene et qu’il a correctement renseigné les variables
d’environnement) aura à simplement exécuter la fonction
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

### Conseil aux développeurs de packages utilisant apinsee

Si vous testez du code utilisant **apinsee**, vous devez mettre le
package **httpuv** dans la rubrique `Suggests` du fichier `DESCRIPTION`
de votre package.

## Utilisation interne à l’Insee

**apinsee** peut également être utilisé au sein de l’Insee pour les
agents qui souhaiteraient accéder aux plateformes de test, recette ou
pré-production. Le plus simple est de modifier l’option `apinsee.url`.
La valeur par défaut de l’option `apinsee.url` est :

``` r
getOption("apinsee.url")
#> [1] "https://api.insee.fr/"
```

Il vous suffit donc de rajouter avant d’exécuter vos scripts :

``` r
options(apinsee.url = "adresse.de.la.plateforme")
```

Enfin, pour accéder à l’environnement de recette, il ne faut pas
utiliser de proxy, vous devez donc également soit modifier les variables
d’environnement `http_proxy` et `https_proxy` dans le fichier
`.Renviron` (recommandé), soit rajouter :

``` r
httr::set_config(httr::use_proxy(""))
```

## Licence

Le code source de ce projet est publié sous licence MIT.
