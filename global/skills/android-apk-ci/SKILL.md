---
name: android-apk-ci
description: Настройка и починка сборки Android APK в GitHub Actions — debug и подписанный release, артефакты, релизы по тегу. Используй, когда нужно собрать APK без локального Android SDK или CI-сборка падает.
---

# Сборка APK в GitHub Actions

## Готовый workflow
Шаблон лежит рядом: `build-apk.yml`. Скопируй его в `.github/workflows/build-apk.yml` проекта.

Что он делает:
- На каждый push в `main` и вручную (`workflow_dispatch`) — собирает debug APK и выкладывает как артефакт.
- На тег `v*` — собирает подписанный release APK и создаёт GitHub Release с файлом.

## Подпись release
Нужны 4 секрета в Settings → Secrets and variables → Actions:

| Секрет | Что это |
|---|---|
| `KEYSTORE_BASE64` | keystore в base64: `base64 -w0 release.jks` |
| `KEYSTORE_PASSWORD` | пароль keystore |
| `KEY_ALIAS` | алиас ключа |
| `KEY_PASSWORD` | пароль ключа |

Создать keystore (один раз, хранить в надёжном месте, **не в репозитории**):
```bash
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

В `app/build.gradle.kts` нужен блок подписи, читающий переменные окружения:
```kotlin
android {
    signingConfigs {
        create("release") {
            val ks = System.getenv("KEYSTORE_FILE")
            if (ks != null) {
                storeFile = file(ks)
                storePassword = System.getenv("KEYSTORE_PASSWORD")
                keyAlias = System.getenv("KEY_ALIAS")
                keyPassword = System.getenv("KEY_PASSWORD")
            }
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
        }
    }
}
```

## Частые падения
- `Permission denied: ./gradlew` → в workflow есть `chmod +x gradlew`; или локально `git update-index --chmod=+x gradlew`.
- `Unsupported class file major version` / ошибка AGP про Java → поменять `java-version` в workflow (AGP 8.x требует JDK 17, новые версии — 21).
- `SDK location not found` → не коммитить `local.properties`.
- `Namespace not specified` → добавить `namespace = "..."` в `android {}`.
- Release APK не устанавливается поверх debug → разные подписи, удалить старое приложение.

## Как смотреть логи
```bash
gh run list --limit 5
gh run view <id> --log-failed
gh run download <id>   # скачать APK-артефакт
```
