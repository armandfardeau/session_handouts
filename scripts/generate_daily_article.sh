#!/bin/bash
# Daily article generator for session_handouts Jekyll blog
# Creates a new post with "unapproved" category + researched topic + git push

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

# ---------- Topic pool (focused on fun & pleasant sailing activities) ----------

DEFAULT_TOPICS=(
  "Relais en flotte : course par équipes sur catamaran"
  "Chasse au trésor en baie : orientation et lecture de l'eau"
  "Rallye photo nautique : découvrir le plan d'eau en s'amusant"
  "Tir au flotteur : exercice de précision en dériveur"
  "Carrousel à plusieurs bateaux : manœuvres en musique"
  "Tour de l'île en escadre : navigation côtière conviviale"
  "Slalom géant entre bouées : pilotage et vitesse"
  "Radeau improvisé : esprit d'équipe et sécurité ludiques"
  "Quiz sur l'eau : questions de culture maritime"
  "Pêche à la traîne en douceur : activité détente en catamaran"
  "Balade coucher de soleil : navigation plaisir en fin de journée"
  "Relais d'équipiers : changement de barreurs en course"
  "Bain de mer encadré : pause rafraîchissante en sécurité"
  "Construction d'un radeau de fortune : atelier collaboratif"
  "Joute nautique轻柔 : duel amical entre deux supports"
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

SLUG_TOPIC=$(echo "$TOPIC" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g' \
  | sed -E 's/^-+|-+$//g' \
  | cut -c1-60)

SLUG="article-${SLUG_TOPIC}-$(date +%s | tail -c 6)"
FILENAME="${POSTS_DIR}/${TODAY}-${SLUG}.md"
TITLE="Activité fun et conviviale — ${TOPIC}"

# ---------- Snippet from local research base (if any) ----------
RESEARCH_SNIPPET=""
if [[ -f "$RESEARCH_BASE" ]]; then
  # Pull a relevant line for the topic (best-effort fuzzy match)
  LINE=$(grep -i -m1 "$(echo "$TOPIC" | cut -d' ' -f1-2)" "$RESEARCH_BASE" 2>/dev/null || true)
  [[ -n "$LINE" ]] && RESEARCH_SNIPPET="> $LINE\n"
fi

RESEARCH_BLOCK="## 🔎 Recherche préliminaire\n\n"
if [[ -n "$RESEARCH_SNIPPET" ]]; then
  RESEARCH_BLOCK+="${RESEARCH_SNIPPET}\n"
  RESEARCH_BLOCK+="*Extrait du knowledge base local (${RESEARCH_BASE}). À approfondir si nécessaire.*\n"
else
  RESEARCH_BLOCK+="*Knowledge base local absent ou vide. Recherche en ligne recommandée.*\n"
fi

# ---------- Write post ----------
cat > "$FILENAME" << EOF
---
layout: post
title:  "${TITLE}"
author: armand
categories: [ ${CATEGORY} ]
image: https://images.unsplash.com/photo-1500627964684-141351970a7f?w=800&q=80
tags: [ ${CATEGORY}, fun-activity, recherche ]
---

## 🎉 Fiche activité fun et conviviale

**Status :** 🔴 En attente d'approbation  
**Date de création :** ${TODAY}  
**Heure :** ${TIME}  
**Catégorie :** ${CATEGORY}  
**Sujet :** ${TOPIC}

---

## 🎯 Pourquoi cette activité ?

Cette fiche met en avant une activité **fun et agréable** à pratiquer avec les stagiaires, afin de :

- Favoriser la motivation et l'engagement
- Renforcer la cohésion de groupe
- Apprendre en s'amusant
- Créer des souvenirs positifs liés à la voile

---

${RESEARCH_BLOCK}

---

## 🧭 Déroulement suggéré

1. **Briefing ludique** — présenter l'activité comme un jeu, expliquer les règles
2. **Mise en place** — organisation du matériel et constitution des équipes
3. **Pratique** — déroulement de l'activité sur l'eau avec accompagnement
4. **Debriefing festif** — partage des impressions, photos, goûter

---

## ✅ Critères de réussite (fun !)

- [ ] Tous les participants ont pu essayer
- [ ] L'ambiance était bienveillante et ludique
- [ ] Les objectifs pédagogiques sont atteints sans que la pression se fasse sentir
- [ ] Les stagiaires repartent avec le sourire

---

## 📝 Notes pour le moniteur

> 🎯 Astuce : adapter la difficulté au niveau du groupe et célébrer les petites réussites.

- À compléter après test réel sur le terrain
- Sources et inspirations à ajouter
- Photos/vidéos à prévoir pour la promotion

---

## ✅ Checklist d'approbation

- [ ] Activité testée et approuvée
- [ ] Sécurité validée (gilets, encadrement, conditions)
- [ ] Sources et inspirations documentées
- [ ] Relecture pédagogique

---

*Cette fiche sera intégrée au catalogue à la suite de son approbation.*
EOF

echo ""
echo "✓ Article created: $FILENAME"
echo "  Title: $TITLE"
echo "  Categories: [ $CATEGORY ]"
echo "  Sujet: $TOPIC  (index $NEXT_INDEX / $NUM_TOPICS)"

# ---------- Git: feature branch + push + PR ----------
cd "$BLOG_DIR"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "⚠ Not a git repo — skipping git workflow."
  exit 0
fi

MAIN_BRANCH="main"
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
ORIGINAL_BRANCH="$CURRENT_BRANCH"
echo "🌿 Current branch: $CURRENT_BRANCH"

# Stash any in-progress changes (defensive)
STASH_NEEDED=0
if ! git diff --quiet || ! git diff --cached --quiet; then
  STASH_NEEDED=1
  echo "📥 Stashing existing changes..."
  git stash push -u -m "auto-gen-daily-article stash $(date +%s)" >/dev/null 2>&1 || STASH_NEEDED=0
fi

# Switch to main and pull
git checkout "$MAIN_BRANCH" 2>/dev/null || {
  echo "⚠ Cannot checkout $MAIN_BRANCH — aborting git workflow."
  [[ $STASH_NEEDED -eq 1 ]] && git stash pop >/dev/null 2>&1 || true
  exit 0
}

REMOTE=$(git remote 2>/dev/null | head -n1 || echo "")
if [[ -z "$REMOTE" ]]; then
  echo "⚠ No git remote configured."
  git checkout "$ORIGINAL_BRANCH" >/dev/null 2>&1 || true
  [[ $STASH_NEEDED -eq 1 ]] && git stash pop >/dev/null 2>&1 || true
  exit 0
fi

git pull --rebase "$REMOTE" "$MAIN_BRANCH" 2>/dev/null || true

# Create a feature branch
BRANCH_NAME="auto/daily-article-${TODAY}-$(echo "$SLUG_TOPIC" | cut -c1-30)"
echo "🌿 Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"

if [[ $STASH_NEEDED -eq 1 ]]; then
  git stash pop >/dev/null 2>&1 || true
fi

# Add & commit
COMMIT_MSG="auto: daily article [${TODAY}] ${SLUG_TOPIC}"
git config user.name "${GIT_AUTHOR_NAME:-Armand Fardeau}" 2>/dev/null || true
git config user.email "${GIT_AUTHOR_EMAIL:-armand@fardeau.com}" 2>/dev/null || true

echo "📦 git add..."
git add -A

if git diff --cached --quiet; then
  echo "ℹ Nothing to commit."
  git checkout "$MAIN_BRANCH" >/dev/null 2>&1
  git branch -d "$BRANCH_NAME" 2>/dev/null || true
  git checkout "$ORIGINAL_BRANCH" >/dev/null 2>&1 || true
  exit 0
fi

echo "✏️ git commit..."
git commit -m "$COMMIT_MSG"

echo "👉 git push $REMOTE $BRANCH_NAME..."
if ! git push "$REMOTE" "$BRANCH_NAME" 2>&1; then
  echo "✗ Push failed — branch kept local."
  exit 1
fi

echo "✓ Branch pushed: $REMOTE/$BRANCH_NAME"

# ---------- Open Pull Request via gh CLI ----------
PR_URL=""
if command -v gh >/dev/null 2>&1; then
  gh label create "auto-generated" \
       --description "Article generated automatically by the daily cron" \
       --color "fbca04" >/dev/null 2>&1 || true
  gh label create "unapproved" \
       --description "Content awaiting pedagogical review" \
       --color "e99695" >/dev/null 2>&1 || true

  echo "🔀 Creating Pull Request..."
  PR_BODY=$(cat <<EOF
## 🌅 Article quotidien (en attente d'approbation)

**Date :** ${TODAY}
**Sujet :** ${TOPIC}
**Catégorie :** ${CATEGORY}

### 📝 Changements

- Article Jekyll ajouté dans \`_posts/\`
- Catégorie \`Unapproved\` appliquée
- Activité pédagogique **fun et conviviale**

### ✅ À vérifier avant merge

- [ ] Cohérence pédagogique
- [ ] Sécurité (gilets, conditions, encadrement)
- [ ] Sources et inspirations
- [ ] Retrait de la catégorie \`Unapproved\` si validé

---
*Généré automatiquement par le cron OpenClaw.*
EOF
)

  if PR_URL=$(gh pr create \
      --base "$MAIN_BRANCH" \
      --head "$BRANCH_NAME" \
      --title "📝 Auto: Daily article [${TODAY}] ${SLUG_TOPIC}" \
      --body "$PR_BODY" \
      --label "auto-generated,unapproved" 2>&1); then
    echo "✓ PR created: $PR_URL"
  else
    echo "⚠ Could not create PR via gh CLI:"
    echo "$PR_URL"
  fi
else
  echo "ℹ gh CLI not installed — branch pushed, PR must be created manually."
fi

# Return to original branch
git checkout "$ORIGINAL_BRANCH" >/dev/null 2>&1 || git checkout "$MAIN_BRANCH"
echo "↩️ Returned to branch: $(git branch --show-current)"
