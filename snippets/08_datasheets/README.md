# 08 — Datasheets : courbes caractéristiques NMOS LV avec PySpice + OSDI

Génération des courbes « datasheet » du `sg13_lv_nmos` (IHP SG13G2) et validation
contre la spec process officielle — le tout depuis un notebook Jupyter macOS,
avec ngspice + modèles OSDI (PSP103) dans Docker.

## Contenu

- `nmos_lv_datasheet.ipynb` — le notebook (kernel `venv_kpex`, Python 3.12)
- `results/` — netlists générés, données `wrdata`, figures PNG
- `tmp/` — TMPDIR local partageable avec Docker (créé au run)

## Ce que fait le notebook

| Sim | Analyse | Sortie |
|---|---|---|
| 1 | `dc Vds 0 1.5 0.01 Vgs 0.5 1.5 0.2` (sweep imbriqué) | Ids(Vds) @ 6 niveaux de Vgs |
| 2 | `dc Vgs 0 1.5 0.005 Vds 0.1 1.5 0.35` | Ids(Vgs) @ 5 niveaux de Vds, linéaire + semilog |
| 3 | 2 sweeps enchaînés par `alter` (Vds = 50 mV puis 1,2 V) | Vth, Idsat, Ioff, DIBL, SS aux conditions de la spec |
| 4 | (réutilise la sim 3) | **VgsTh** à courant constant, définition explicite façon datasheet |
| 5 | 1 sweep Vgs @ Vds=50mV × 3 températures (3 runs) | **Tableau VgsTh / Rdson / Rdson·W** à −40 °C, TEMP_C et +125 °C (bornes PDK, spec §1.2) + figure ZTC |

**Rdson** (défini dans le notebook) : Vds/Id à Vgs = `VGS_ON` = 1,2 V, Vds = 50 mV →
733 Ω·µm à 27 °C (mos_tt), 675 à −40 °C, 883 à +125 °C. VgsTh dérive à −0,67 mV/K.

| 6 | `N_MC` tirages `mos_tt_stat` en boucle `repeat`/`reset`/`meas` (1 seul run Docker, ~2 s) | **Monte Carlo process global** : histogrammes VgsTh et Rdson + corners ss/ff superposés |

**Résultat MC marquant** : σ(VgsTh) = 42 mV alors que (ss−ff)/6 ≈ 20 mV — les corners
tombent à ±1,4σ, ils ne bornent PAS la dispersion process globale (tirage indépendant
des 17 paramètres `_stat`, termes de canal court dominants à L=0.13µ).

| 7 | paires appariées, 4 géométries × `N_MC` tirages `mos_tt_mismatch` (4 runs) | **Mismatch local / loi de Pelgrom** : σ(ΔVgsTh) vs 1/√(W·L), fit A_ΔVT |

**Résultats mismatch** : loi de Pelgrom parfaitement suivie (σ×√A constant sur 77:1 de
surface) avec **A_ΔVT effectif = 5,5 mV·µm** — à utiliser pour le design. C'est ~1,9× la
prédiction `delvto_mm` de la lib (2,83) : diagnostiqué par ablation + lecture directe de
l'instance, le tirage `agauss` sur paramètre d'instance **OSDI** sort ~1,9× trop large
(agauss propre partout ailleurs ; gain DELVTO→Vth = 1,00 exactement). Quirk
ngspice↔OSDI, uniforme en géométrie donc Pelgrom valide au coefficient effectif près.

| 8 | (markdown, sourcé spec PDF) | **Limites absolues & parasites** : Vgs max 1,65 V, BVDSS 2,0–2,7 V, BVNPW 12 V, Miller 0,36 fF/µm, Cj 0,95 fF/µm², Leff/Weff |

| 9 | sweep imbriqué Vbs externe (1 run) | **Effet substrat** : VgsTh(Vbs), fit γ = 0,242 √V (2φF fixé à 0,8 V) |
| 10 | dérivé de la sim 2, aucun run | **gm/Id** : abaque vs Vgs et vs densité de courant (max 27,9 V⁻¹) |
| 11 | boucle `alter`+`ac` 31 points de bias (1 run) | **C-V petit signal** : Cgg 1,31→2,03 fF, Cdg 0,61→1,01 fF (→Cgg/2 à Vds=0) |

Restent à simuler (candidats) : bruit (thermique/flicker), Qg par intégration, PMOS (§2.2).

Le device est **paramétré en tête de première cellule** : `W`, `L`, `CORNER`, `VBS`,
`TEMP_C` (injecté via `.temp`, honoré par les OSDI : VgsTh mesuré à −0,69 mV/K)
et `JTH` (critère de seuil). La comparaison spec (sim 3) n'a de sens qu'à `TEMP_C = 27`.

**Définition de VgsTh retenue** (affichée en toutes lettres dans le notebook, comme dans
toute datasheet) : Vgs telle que Id = JTH·W/L avec JTH = 100 nA (critère industriel
classique), à Vds = 50 mV, Vbs = 0, 27 °C → 452 mV en mos_tt pour W=1µ/L=0.13µ.
L'ELR (définition officielle IHP, A.a1) reste utilisée pour la comparaison spec (546 mV) ;
le choix de JTH est une convention, pas une physique (0,5 nA → ~250 mV, 100 nA → ~450 mV).

Résultat (corner `mos_tt`, W=1µ, L=0.13µ) : **les 5 paramètres tombent dans les
bornes min/max de la spec process** (`SG13G2_os_process_spec.pdf` Rev 1.2, §2.1
et Attachment A).

## Architecture

- **PySpice = générateur de netlist uniquement** (circuit-as-code). Pas de
  `libngspice` (indisponible sur macOS Intel), pas du parseur PySpice : la sortie
  passe par `wrdata` + `numpy.loadtxt`.
- Exécution via `scripts/ngspice-docker-python` qui traduit les chemins macOS →
  conteneur (`.lib`, `pre_osdi`).
- Un sweep DC imbriqué = toute une famille de courbes en un seul run Docker.

## Prérequis

- `pip install PySpice` dans `venv_kpex` (fait le 2026-07-10, PySpice 1.5, OK
  sous Python 3.12 / numpy 2.0)
- Modèles OSDI compilés (`scripts/compile-va-models.sh`)
- `PDK_ROOT` pointant sur IHP-Open-PDK

## Pièges gérés (voir doc/00_installation.md)

1. `TMPDIR` forcé dans le projet (`tmp/`) — le `/var/folders/...` de macOS n'est
   pas partagé avec Docker, or le wrapper y copie le netlist traduit.
2. Chemins `wrdata` **relatifs** (résolus dans `/work` côté conteneur).
3. Le modèle de la lib LV est `pspnqs103va` → précharger `psp103_nqs.osdi`
   (pas `psp103.osdi`).

## Lancer

```bash
cd snippets/08_datasheets
source ../../../venv_kpex/bin/activate   # ou kernel Jupyter "Python 3.12 (kpex)"
jupyter lab nmos_lv_datasheet.ipynb
```
