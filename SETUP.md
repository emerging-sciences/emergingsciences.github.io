# Emerging Sciences Android App — Setup (ek baar ka kaam)

## Step 1 — Files repo me daalo
Is zip ke andar ki cheezein apne GitHub repo (`emergingsciences.github.io`) me upload karo:

| Zip me | Repo me kahan |
|---|---|
| `app/` folder | repo root me `app/` |
| `.github/workflows/build-apk.yml` | repo root me `.github/workflows/` |
| `index.html` | purani `index.html` replace karo (naya "Android App" section judega) |
| `sw.js` | purani `sw.js` replace karo (content ab 2-4 min me fresh dikhega) |

Note: GitHub web upload me hidden folder `.github` kabhi kabhi nahi dikhta. "Add file → Create new file" me naam `.github/workflows/build-apk.yml` likhkar content paste kar do.

## Step 2 — Permanent signing key (bahut zaroori, ek baar)
Isse future updates purane app ke upar install ho paate hain. Iske bina har APK alag "sign" hogi aur students ko uninstall karna padega.

Kisi bhi PC par jisme Java (ya Android Studio) ho:
```
keytool -genkeypair -v -keystore es-release.jks -alias es -keyalg RSA -keysize 2048 -validity 10000 -storepass APNA_PASSWORD -keypass APNA_PASSWORD -dname "CN=Emerging Sciences, O=Emerging Sciences, C=IN"
```
Phir base64 nikalo:
- Linux/Mac: `base64 -w0 es-release.jks`
- Windows PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("es-release.jks"))`

GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**, ye 3 banao:
- `KEYSTORE_BASE64` = upar wala lamba base64 text
- `KEYSTORE_PASSWORD` = APNA_PASSWORD
- `KEY_ALIAS` = `es`

`es-release.jks` file aur password kisi safe jagah (Drive + pendrive) backup rakho. **Repo me kabhi upload mat karna.** Kho gayi to students ko app uninstall karke dobara install karna padega.

## Step 3 — APK banao
Repo → **Actions → Build Android APK → Run workflow**. 5-8 min me:
- APK GitHub **Releases** me aa jaati hai (`EmergingSciences.apk`)
- `app-version.json` apne aap repo me update ho jaata hai
- Website ke home page par "Android App" section me download button kaam karne lagta hai

## Roz ka kaam
- **Naya lecture / material:** pehle jaisa `data.js` (ya Google Sheet) edit karo. App me kuch nahi karna.
  - `data.js` edit → GitHub Pages deploy (1-2 min) ke baad app me aa jaata hai.
  - Google Sheet edit → Google khud ~5 min tak purana CSV dikhata hai.
- **App ka design/naya feature badalna ho:** `app/lib/main.dart` edit karo, phir Step 3 dobara. App me students ko "Update karo" popup dikhega.

## Agar kuch galat ho
- Actions me build fail: log ka last error copy karke mujhe bhej do.
- Download button 404: Step 3 abhi chalaya nahi hai, ya `app/lib/config.dart` aur `index.html` me `emerging-sciences/emergingsciences.github.io` GitHub ke asli `owner/repo` se match karo.
