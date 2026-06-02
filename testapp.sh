#!/bin/sh
set -e

if [ "$1" ]; then
  rm -rf ./tmp/app
  mkdir -p ./tmp/app
fi

if [ "$1" = "next" ]; then
  npx create-next-app --typescript --eslint ./tmp/app/next
  npx prettier --write ./tmp/app/next
  npm --prefix ./tmp/app/next install isomorphic-unfetch formik react-query

  # Tailwind
  npm --prefix ./tmp/app/next install tailwindcss postcss autoprefixer
  npx --prefix ./tmp/app/next tailwindcss init -p
  cp ./templates/common/tailwind.config.js ./tmp/app/next
  cp ./templates/common/style.css ./tmp/app/next/styles

  cp -R ./tmp/next/* ./tmp/app/next
  rm ./tmp/app/next/pages/index.tsx
  rm -rf ./tmp/app/next/pages/api
  npm --prefix ./tmp/app/next run build
  npx start-server-and-test 'npm --prefix ./tmp/app/next start' http://127.0.0.1:3000/books/ 'npm --prefix ./tmp/app/next run playwright test'
fi

if [ "$1" = "react" ]; then
  npx create-react-app --template typescript ./tmp/app/reactapp
  npm --prefix ./tmp/app/reactapp install react-router-dom react-hook-form

  cp -R ./tmp/react/* ./tmp/app/reactapp/src
  cp ./templates/react/index.tsx ./tmp/app/reactapp/src
  npx start-server-and-test 'BROWSER=none npm --prefix ./tmp/app/reactapp start' http://127.0.0.1:3000/books/ 'npm --prefix ./tmp/app/reactapp run playwright test'
fi

if [ "$1" = "nuxt" ]; then
  npx nuxi init ./tmp/app/nuxt

  rm ./tmp/app/nuxt/app.vue
  rm ./tmp/app/nuxt/nuxt.config.ts

  cp ./templates/nuxt/nuxt.config.ts ./tmp/app/nuxt

  npm --prefix ./tmp/app/nuxt install dayjs @pinia/nuxt qs @types/qs

  cp -R ./tmp/nuxt/* ./tmp/app/nuxt

  # Tailwind
  npm --prefix ./tmp/app/nuxt install tailwindcss postcss autoprefixer
  npx --prefix ./tmp/app/nuxt tailwindcss init -p
  cp ./templates/common/tailwind.config.js ./tmp/app/nuxt
  cp ./templates/common/style.css ./tmp/app/nuxt/assets/css

  npm --prefix ./tmp/app/nuxt run generate

  npx start-server-and-test 'npm --prefix ./tmp/app/nuxt run preview' http://127.0.0.1:3000/books/ 'npm --prefix ./tmp/app/nuxt run playwright test'
fi

if [ "$1" = "vue" ]; then
  cd ./tmp/app
  npm init vue@3 -- --typescript --router --pinia --eslint-with-prettier vue
  cd ../..
  npm --prefix ./tmp/app/vue install
  npm --prefix ./tmp/app/vue install qs @types/qs dayjs

  # Tailwind
  npm --prefix ./tmp/app/vue install tailwindcss postcss autoprefixer
  npx --prefix ./tmp/app/vue tailwindcss init -p
  cp ./templates/common/tailwind.config.js ./tmp/app/vue
  cp ./templates/common/style.css ./tmp/app/vue/src/assets

  cp -R ./tmp/vue/* ./tmp/app/vue/src
  cp ./templates/vue/main.ts ./tmp/app/vue/src
  cp ./templates/vue/App.vue ./tmp/app/vue/src
  npm --prefix ./tmp/app/vue run build
  npx start-server-and-test 'npm --prefix ./tmp/app/vue vite preview --port 3000' http://localhost:3000/books/ 'npm --prefix ./tmp/app/vue run playwright test'
fi
