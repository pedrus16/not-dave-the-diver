# Level Design

Les niveaux sont générés procéduralement, en assemblant de manière aléatoire des "modules".

## Registre des modules

Pour qu'un module soit pris en compte par l'algorithme de génération, il faut l'ajouter dans le fichier de config :

```
res://config/modules_registry.tres
```

Cette ressource contient aussi `Closed Connector`, qui est utilisé pour "fermer" un module avec un mur.

A noter que dans la scène de test `res://dev_scenes/level_generation/level_generation.tscn`, les modules sont directement
rentrés dans le Node `LevelGenerator`.

## Créer un module

Pour créer un module :

- Créer une nouvelle scène de type `LevelModule`
- Ajouter des visuels, des colliders 2D
- Ajouter des connecteurs aux entrées / sorties (attention pour l'instant elles font toutes la même taille).
  Pour cela il faut utiliser la scène `res://dev_scenes/level-generation/module_connector.tscn` (bientôt mis dans res://scenes)
- Ajouter des spots pour les interactables (noeud de type `InteractableSpot`)

### Spots

Pour configurer les spots, il faut rentrer la liste des interactables qui peuvent apparaître à cet endroit.

La liste des interactables peut être directement renseignée dans l'inspecteur du Spot, ou sauvegardée dans un fichier
Resource (de type `InteractableList`), pour être réutilisé plusieurs fois.

Pour chaque entrée de la liste, il faut glisser le `InteractableDescriptor` souhaité (ex: sea_urchin.tres), ainsi que le
poids.

Plus le poids est élevé, plus il y a de chance de faire apparaître cet objet plus qu'un autre.
