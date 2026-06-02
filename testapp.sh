#!/bin/sh
set -e

if [ "$1" ]; then
  rm -rf ./tmp/app
  mkdir -p ./tmp/app
fi

if [ "$1" = "next" ]; then
  pnpm create next-app --typescript --eslint ./tmp/app/next
  pnpm prettier --write ./tmp/app/next
  pnpm --prefix ./tmp/app/next install isomorphic-unfetch formik @tanstack/react-query

  # Tailwind
  pnpm --prefix ./tmp/app/next install tailwindcss postcss autoprefixer
  pnpm --prefix ./tmp/app/next tailwindcss init -p
  cp ./templates/common/tailwind.config.js ./tmp/app/next
  cp ./templates/common/style.css ./tmp/app/next/styles

  cp -R ./tmp/next/* ./tmp/app/next
  rm ./tmp/app/next/pages/index.tsx
  rm -rf ./tmp/app/next/pages/api
  pnpm --prefix ./tmp/app/next run build
  pnpm dlx start-server-and-test 'pnpm --prefix ./tmp/app/next start' http://127.0.0.1:3000/books/ 'pnpm --prefix ./tmp/app/next run playwright test'
fi

if [ "$1" = "react" ]; then
  pnpm create react-app --template typescript ./tmp/app/reactapp
  pnpm --prefix ./tmp/app/reactapp install react-router-dom react-hook-form

  cp -R ./tmp/react/* ./tmp/app/reactapp/src
  cp ./templates/react/index.tsx ./tmp/app/reactapp/src
  pnpm dlx start-server-and-test 'BROWSER=none pnpm --prefix ./tmp/app/reactapp start' http://127.0.0.1:3000/books/ 'pnpm --prefix ./tmp/app/reactapp run playwright test'
fi

if [ "$1" = "nuxt" ]; then
  pnpm dlx nuxi init ./tmp/app/nuxt

  rm ./tmp/app/nuxt/app.vue
  rm ./tmp/app/nuxt/nuxt.config.ts

  cp ./templates/nuxt/nuxt.config.ts ./tmp/app/nuxt

  pnpm --prefix ./tmp/app/nuxt install dayjs @pinia/nuxt qs @types/qs

  cp -R ./tmp/nuxt/* ./tmp/app/nuxt

  # Tailwind
  pnpm --prefix ./tmp/app/nuxt install tailwindcss postcss autoprefixer
  pnpm --prefix ./tmp/app/nuxt tailwindcss init -p
  cp ./templates/common/tailwind.config.js ./tmp/app/nuxt
  cp ./templates/common/style.css ./tmp/app/nuxt/assets/css

  pnpm --prefix ./tmp/app/nuxt run generate

  pnpm dlx start-server-and-test 'pnpm --prefix ./tmp/app/nuxt run preview' http://127.0.0.1:3000/books/ 'pnpm --prefix ./tmp/app/nuxt run playwright test'
fi

if [ "$1" = "vue" ]; then
  cd ./tmp/app
  pnpm create vue@3 -- --typescript --router --pinia --eslint-with-prettier vue
  cd ../..
  pnpm --prefix ./tmp/app/vue install
  pnpm --prefix ./tmp/app/vue install qs @types/qs dayjs

  # Tailwind
  pnpm --prefix ./tmp/app/vue install tailwindcss postcss autoprefixer
  pnpm --prefix ./tmp/app/vue tailwindcss init -p
  cp ./templates/common/tailwind.config.js ./tmp/app/vue
  cp ./templates/common/style.css ./tmp/app/vue/src/assets

  cp -R ./tmp/vue/* ./tmp/app/vue/src
  cp ./templates/vue/main.ts ./tmp/app/vue/src
  cp ./templates/vue/App.vue ./tmp/app/vue/src
  pnpm --prefix ./tmp/app/vue run build
  pnpm dlx start-server-and-test 'pnpm --prefix ./tmp/app/vue vite preview --port 3000' http://localhost:3000/books/ 'pnpm --prefix ./tmp/app/vue run playwright test'
fi
