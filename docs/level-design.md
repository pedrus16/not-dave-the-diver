# Level Design

Les niveaux sont générés procéduralement, en assemblant de manière aléatoire des "modules".

## Registre des modules

Pour qu'un module soit pris en compte par l'algorithme de génération, il faut l'ajouter dans le fichier de config :

```
res://config/modules_registry.tres
```

Cette ressource contient aussi Horizontal et Vertical `Closed Connector`, qui sont utilisés pour "fermer" un module avec un mur.

À noter que dans la scène de test `res://dev_scenes/level_generation/level_generation.tscn`, les modules sont directement
rentrés dans le Node `LevelGenerator`.

## Créer un module

Pour créer un module :

- Créer une nouvelle scène de type `LevelModule`
- Ajouter des visuels et rochers qui sont dans scenes/environment (préférer les .tscn quand ils existent)
- Ajouter des connecteurs aux entrées / sorties (attention pour l'instant elles font toutes la même taille).
  Pour cela il faut utiliser la scène `res://scenes/modules/module_connector.tscn`
- Ajouter des spots pour les entities (noeud de type `EntitySpot`)

### Spots

Pour configurer les spots, il faut rentrer la liste des entities qui peuvent apparaître à cet endroit.

La liste des entities peut être directement renseignée dans l'inspecteur du Spot, ou sauvegardée dans un fichier
Resource (de type `EntityList`), pour être réutilisé plusieurs fois.

Pour chaque entrée de la liste, il faut glisser le `EntityDescriptor` souhaité (ex: sea_urchin.tres), ainsi que le
poids.

Plus le poids est élevé, plus il y a de chance de faire apparaître cet objet plus qu'un autre.
