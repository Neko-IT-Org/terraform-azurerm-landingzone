# Module Terraform Azure Resource Group

Ce module Terraform crée et configure un groupe de ressources Azure en appliquant des bonnes pratiques d'étiquetage, de sécurité et de gouvernance. Il ajoute automatiquement un tag `CreatedOn` horodaté et peut, en option, protéger le groupe de ressources par un verrou ou gérer des attributions de rôles.

## Fonctionnalités principales

- Création d'un groupe de ressources Azure avec fusion des tags fournis et du tag `CreatedOn` généré eautomatiquement.
- Activation facultative d'un verrou (`CanNotDelete` ou `ReadOnly`) pour limiter les suppressions ou modifications accidentelles.
- Déclaration d'attributions de rôles optionnelles au niveau du groupe de ressources.

## Exemple d'utilisation

```hcl
module "resource_group" {
  source = "./modules/resourcegroup"

  name     = "rg-app-prod-westeurope"
  location = "westeurope"

  tags = {
    environment = "prod"
    owner       = "team-platform"
  }

  lock = {
    kind = "CanNotDelete"
    name = "rg-lock"
  }

  role_assignments = [
    {
      principal_id         = "00000000-0000-0000-0000-000000000000"
      role_definition_name = "Reader"
      description          = "Lecture seule pour l'équipe FinOps"
    }
  ]
}
```

## Variables d'entrée

| Nom                | Type                                                 | Défaut | Description                                                                                                                                                                                                                                                                                    |
| ------------------ | ---------------------------------------------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`             | `string`                                             | n/a    | **Obligatoire.** Nom du groupe de ressources (1-90 caractères, autorise lettres, chiffres, `_`, `-`, `.`, `()`, ne doit pas se terminer par un point).                                                                                                                                         |
| `location`         | `string`                                             | n/a    | **Obligatoire.** Région Azure où déployer le groupe de ressources.                                                                                                                                                                                                                             |
| `tags`             | `map(string)`                                        | `{}`   | Tags supplémentaires à fusionner avec le tag `CreatedOn` généré automatiquement.                                                                                                                                                                                                               |
| `lock`             | `object({ kind = string, name = optional(string) })` | `null` | Configuration facultative d'un verrou de gestion. `kind` doit être `"CanNotDelete"` ou `"ReadOnly"`.                                                                                                                                                                                           |
| `role_assignments` | `list(object({ ... }))`                              | `[]`   | Liste d'attributions de rôles facultatives. Chaque entrée doit définir `principal_id` et exactement une des propriétés `role_definition_id` ou `role_definition_name`, plus des champs optionnels (`condition`, `condition_version`, `description`, `delegated_managed_identity_resource_id`). |

## Sorties

| Nom        | Description                                                               |
| ---------- | ------------------------------------------------------------------------- |
| `id`       | Identifiant du groupe de ressources, utile pour chaîner d'autres modules. |
| `name`     | Nom du groupe de ressources créé.                                         |
| `location` | Région du groupe de ressources.                                           |
| `tags`     | Ensemble complet des tags appliqués, incluant `CreatedOn`.                |

## Notes complémentaires

- Le tag `CreatedOn` est généré grâce à la ressource `time_static` et reflète l'heure du premier `terraform apply`, ajustée d'une heure.
- La ressource de verrouillage n'est créée que si la variable `lock` est définie.
- Les attributions de rôles sont gérées via une itération sur la liste `role_assignments` et permettent de combiner `role_definition_id` ou `role_definition_name` avec des options avancées comme les conditions.
