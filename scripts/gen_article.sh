#!/bin/bash
# Daily article generator v2 - no Unapproved, branch+PR flow

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BLOG_DIR="/Users/armandfardeau/WWW/session_handouts"
POSTS_DIR="${BLOG_DIR}/_posts"
TOPICS_FILE="${SCRIPT_DIR}/topics_pool.json"
STATE_FILE="${SCRIPT_DIR}/.last_topic_index"
RESEARCH_BASE="${BLOG_DIR}/research_base.md"

mkdir -p "$POSTS_DIR"

TODAY=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

CATEGORIES=("Catamaran" "Croisière" "Dériveur")
DAY_OF_MONTH=$(date +%d | sed 's/^0//')
CATEGORY_INDEX=$((($DAY_OF_MONTH - 1) % ${#CATEGORIES[@]}))
CATEGORY="${CATEGORIES[$CATEGORY_INDEX]}"

DEFAULT_TOPICS=(
  "Relais en flotte : course par equipes sur catamaran"
  "Chasse au tresor en baie : orientation et lecture de l'eau"
  "Rallye photo nautique : decouvrir le plan d'eau en s'amusant"
  "Tir au flotteur : exercice de precision en deriveur"
  "Carrousel a plusieurs bateaux : manoeuvres en musique"
  "Tour de l'ile en escadre : navigation cotiere conviviale"
  "Slalom geant entre bouees : pilotage et vitesse"
  "Radeau improvise : esprit d'equipe et securite ludiques"
  "Quiz sur l'eau : questions de culture maritime"
  "Peche a la traine en douceur : activite detente en catamaran"
  "Balade coucher de soleil : navigation plaisir en fin de journee"
  "Relais d'equipiers : changement de barreurs en course"
  "Bain de mer encadre : pause rafraichissante en securite"
  "Construction d'un radeau de fortune : atelier collaboratif"
  "Joute nautique legere : duel amical entre deux supports"
)

TOPICS=("${DEFAULT_TOPICS[@]}")
if [[ -f "$TOPICS_FILE" ]] && command -v jq >/dev/null 2>&1; then
  if jq -e 'type == "array" and length > 0' "$TOPICS_FILE" >/dev/null 2>&1; then
    mapfile -t TOPICS < <(jq -r '.[]' "$TOPICS_FILE")
  fi
fi

NUM_TOPICS=${#TOPICS[@]}
LAST_INDEX=-1
[[ -f "$STATE_FILE" ]] && LAST_INDEX=$(cat "$STATE_FILE" 2>/dev/null || echo "-1")
NEXT_INDEX=$(( (LAST_INDEX + 1) % NUM_TOPICS ))
TOPIC="${TOPICS[$NEXT_INDEX]}"
echo "$NEXT_INDEX" > "$STATE_FILE"

SLUG_TOPIC=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | cut -c1-60)
SLUG="article-${SLUG_TOPIC}-$(date +%s | tail -c 6)"
FILENAME="${POSTS_DIR}/${TODAY}-${SLUG}.md"
TITLE="Activite fun et conviviale - ${TOPIC}"

RESEARCH_SNIPPET=""
if [[ -f "$RESEARCH_BASE" ]]; then
  LINE=$(grep -i -m1 "$(echo "$TOPIC" | cut -d' ' -f1-2)" "$RESEARCH_BASE" 2>/dev/null || true)
  [[ -n "$LINE" ]] && RESEARCH_SNIPPET="> $LINE"
fi

cat > "$FILENAME" <<POSTEOF
---
layout: post
title:  "${TITLE}"
author: armand
categories: [ ${CATEGORY} ]
image: https://images.unsplash.com/photo-1500627964684-141351970a7f?w=800&q=80
tags: [ ${CATEGORY}, fun-activity, recherche ]
---

## 🎉 Fiche activite fun et conviviale

**Status :** 🔵 En revision (PR ouverte)
**Date de creation :** ${TODAY}
**Heure :** ${TIME}
**Categorie :** ${CATEGORY}
**Sujet :** ${TOPIC}

---

## 🎯 Pourquoi cette activite ?

Fiche d'activite **fun et agreable** a pratiquer avec les stagiaires, pour :

- Favoriser la motivation et l'engagement
- Renforcer la cohesion de groupe
- Apprendre en s'amusant
- Creer des souvenirs positifs lies a la voile

---

## 🔎 Recherche preliminaire

${RESEARCH_SNIPPET:-*Knowledge base local absent. Recherche en ligne recommandee.*}

*Source : \`${RESEARCH_BASE}\`*

---

## 🧭 Deroulement suggere

1. Briefing ludique - presenter l'activite comme un jeu
2. Mise en place - constitution des equipes, materiel
3. Pratique - deroulement sur l'eau
4. Debriefing festif - partage, photos, gouter

---

## ✅ Criteres de reussite

- [ ] Tous les participants ont pu essayer
- [ ] L'ambiance etait bienveillante et ludique
- [ ] Les objectifs pedagogiques sont atteints
- [ ] Les stagiaires repartent avec le sourire

---

## 📝 Notes pour le moniteur

> 🎯 Astuce : adapter la difficulte au niveau du groupe.

---

## ✅ Checklist d'approbation

- [ ] Activite testee et approuvee
- [ ] Securite validee (gilets, encadrement, conditions)
- [ ] Sources et inspirations documentees
- [ ] Relecture pedagogique

---

*Cette fiche sera integree au catalogue a la suite de l'approbation de la PR.*
POSTEOF

echo ""
echo "OK Article cree : $FILENAME"
echo "  Titre: $TITLE"
echo "  Categories: [ $CATEGORY ]"
echo "  Sujet: $TOPIC  (index $NEXT_INDEX / $NUM_TOPICS)"

# ---------- Git : branche + push + PR ----------
cd "$BLOG_DIR"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "⚠ Pas un repo git."
  exit 0
fi

MAIN_BRANCH="main"
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
ORIGINAL_BRANCH="$CURRENT_BRANCH"
echo ""
echo "🌿 Branche actuelle : $CURRENT_BRANCH"

STASH_NEEDED=0
if ! git diff --quiet || ! git diff --cached --quiet; then
  STASH_NEEDED=1
  echo "📥 Stash des changements..."
  git stash push -u -m "auto-gen-daily-article stash $(date +%s)" >/dev/null 2>&1 || STASH_NEEDED=0
fi

git checkout "$MAIN_BRANCH" 2>/dev/null || {
  echo "⚠ Impossible de basculer sur $MAIN_BRANCH."
  [[ $STASH_NEEDED -eq 1 ]] && git stash pop >/dev/null 2>&1 || true
  exit 0
}

REMOTE=$(git remote 2>/dev/null | head -n1 || echo "")
if [[ -z "$REMOTE" ]]; then
  echo "⚠ Aucun remote git."
  git checkout "$ORIGINAL_BRANCH" >/dev/null 2>&1 || true
  [[ $STASH_NEEDED -eq 1 ]] && git stash pop >/dev/null 2>&1 || true
  exit 0
fi

git pull --rebase "$REMOTE" "$MAIN_BRANCH" 2>/dev/null || true

BRANCH_NAME="auto/daily-article-${TODAY}-$(echo "$SLUG_TOPIC" | cut -c1-30)"
echo "🌿 Creation de la branche : $BRANCH_NAME"
git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"

if [[ $STASH_NEEDED -eq 1 ]]; then
  git stash pop >/dev/null 2>&1 || true
fi

COMMIT_MSG="auto: daily article [${TODAY}] ${SLUG_TOPIC}"
git config user.name "${GIT_AUTHOR_NAME:-Armand Fardeau}" 2>/dev/null || true
git config user.email "${GIT_AUTHOR_EMAIL:-armand@fardeau.com}" 2>/dev/null || true

echo "📦 git add..."
git add -A

if git diff --cached --quiet; then
  echo "ℹ Rien a committer."
  git checkout "$MAIN_BRANCH" >/dev/null 2>&1
  git branch -d "$BRANCH_NAME" 2>/dev/null || true
  git checkout "$ORIGINAL_BRANCH" >/dev/null 2>&1 || true
  exit 0
fi

echo "✏️ git commit..."
git commit -m "$COMMIT_MSG"

echo "👉 git push $REMOTE $BRANCH_NAME..."
if ! git push "$REMOTE" "$BRANCH_NAME" 2>&1; then
  echo "✗ Push echoue."
  exit 1
fi

echo "✓ Branche pushed : $REMOTE/$BRANCH_NAME"

# ---------- Pull Request via gh CLI ----------
if command -v gh >/dev/null 2>&1; then
  gh label create "auto-generated" \
       --description "Article generated automatically by the daily cron" \
       --color "fbca04" >/dev/null 2>&1 || true

  echo "🔀 Creation de la Pull Request..."
  PR_BODY="## 🌅 Article quotidien

**Date :** ${TODAY}
**Sujet :** ${TOPIC}
**Categorie :** ${CATEGORY}

### Changements

- Article Jekyll ajoute dans _posts/
- Activite pedagogique fun et conviviale
- Recherche de base appliquee

### A verifier avant merge

- [ ] Coherence pedagogique
- [ ] Securite (gilets, conditions, encadrement)
- [ ] Sources et inspirations documentees
- [ ] Pret pour publication

---
*Genere automatiquement par le cron OpenClaw.*"

  if PR_URL=$(gh pr create \
      --base "$MAIN_BRANCH" \
      --head "$BRANCH_NAME" \
      --title "Auto: Daily article [${TODAY}] ${SLUG_TOPIC}" \
      --body "$PR_BODY" \
      --label "auto-generated" 2>&1); then
    echo "✓ PR creee : $PR_URL"
  else
    echo "⚠ Impossible de creer la PR via gh CLI"
  fi
else
  echo "ℹ gh CLI non installe - PR a creer manuellement."
fi

git checkout "$ORIGINAL_BRANCH" >/dev/null 2>&1 || git checkout "$MAIN_BRANCH"
echo "↩️ Retour a : $(git branch --show-current)"
