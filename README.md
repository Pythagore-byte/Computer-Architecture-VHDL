# Implémentation d'un Processeur Monocycle en VHDL

## Description
Conception et simulation d'une architecture de processeur monocycle capable d'exécuter un jeu d'instructions de base (Arithmétique, Logique, Sauts).

## Détails de l'implémentation
* **Datapath :** Unité Arithmétique et Logique (ALU), banc de registres, et gestion de la mémoire de données/instructions.
* **Control Unit :** Logique combinatoire assurant le décodage des instructions et la génération des signaux de contrôle.
* **Validation :** Simulation exhaustive sous **ModelSim** avec des chronogrammes détaillant chaque cycle d'instruction.

## Cible Matérielle
* Testé sur carte **DE10-Lite** (FPGA Intel Max 10).