---
name: pwa-checklist
description: Проверка и настройка PWA — manifest, service worker, иконки, офлайн, установка на телефон, обновление кеша, деплой на GitHub Pages. Используй при создании PWA или когда она не устанавливается / не обновляется.
---

# PWA: чек-лист

## 1. manifest.json
```json
{
  "name": "Полное название",
  "short_name": "Коротко",
  "start_url": "./",
  "scope": "./",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#ffffff",
  "lang": "ru",
  "icons": [
    { "src": "icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icons/icon-512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "icons/icon-512-maskable.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```
В `<head>`: `<link rel="manifest" href="manifest.json">`, `<meta name="theme-color">`, `<meta name="viewport" content="width=device-width, initial-scale=1">`, `<link rel="apple-touch-icon" href="icons/icon-192.png">`.

## 2. Service worker
Шаблон рядом: `sw.js`. Главное правило — **версия кеша в имени**. Поменял файлы → поднял `CACHE_VERSION`, иначе у пользователей останется старая версия.

Регистрация:
```js
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('./sw.js');
}
```

## 3. Проверка
- [ ] Открывается по HTTPS
- [ ] DevTools → Application → Manifest: нет ошибок, иконки видны
- [ ] Application → Service Workers: активен
- [ ] Включить Offline в DevTools → страница грузится
- [ ] На Android в Chrome появляется «Установить приложение»
- [ ] После релиза с новым `CACHE_VERSION` обновление приходит (иногда со второго открытия)

## 4. GitHub Pages
- Сайт открывается по адресу `https://<логин>.github.io/<репо>/` — поэтому все пути относительные (`./`, без ведущего `/`).
- Деплой — workflow `deploy-pages.yml` из шаблона `web-pwa`.

## Частые проблемы
- **Не предлагает установить** — нет иконки 512, `start_url` вне `scope`, или нет fetch-обработчика в SW.
- **Не обновляется** — не поменяли `CACHE_VERSION`; или `sw.js` закеширован сервером.
- **404 на GitHub Pages** — абсолютные пути `/icons/...` вместо `./icons/...`.
