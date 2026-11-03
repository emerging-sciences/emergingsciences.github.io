#!/usr/bin/env python3
"""Run by the build workflow right after `flutter create`.
Adds what the generated Android project needs: internet permission, app name,
launcher icons, black launch screen. Fails loudly if the manifest looks unexpected."""
import os, re, shutil, sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # .../flutter_app
manifest = os.path.join(root, 'android', 'app', 'src', 'main', 'AndroidManifest.xml')
res_dst = os.path.join(root, 'android', 'app', 'src', 'main', 'res')
res_src = os.path.join(root, 'android_overlay', 'res')

if not os.path.isfile(manifest):
    sys.exit('AndroidManifest.xml not found - did `flutter create` run?')

xml = open(manifest, encoding='utf-8').read()
m = re.search(r'<application\b', xml)
if not m:
    sys.exit('<application> tag not found in AndroidManifest.xml')

extra = ''
if 'android.permission.INTERNET' not in xml:
    extra += '    <uses-permission android:name="android.permission.INTERNET"/>\n'
if 'es-app-queries' not in xml:
    extra += '''    <!-- es-app-queries: lets the app open links in the browser / Telegram / UPI apps -->
    <queries>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="http"/></intent>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="upi"/></intent>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="tg"/></intent>
    </queries>
'''
xml = xml[:m.start()] + extra + '    ' + xml[m.start():]

# app name shown under the launcher icon
app_tag = re.search(r'<application\b[^>]*>', xml, re.S)
tag = app_tag.group(0)
if 'android:label="' in tag:
    new_tag = re.sub(r'android:label="[^"]*"', 'android:label="Emerging Sciences"', tag, count=1)
else:
    new_tag = tag[:-1] + ' android:label="Emerging Sciences">'
xml = xml.replace(tag, new_tag, 1)
open(manifest, 'w', encoding='utf-8').write(xml)
print('manifest patched')

# launcher icons + launch screen: replace whatever the template generated
for old in ('mipmap-anydpi-v26', 'mipmap-anydpi'):
    shutil.rmtree(os.path.join(res_dst, old), ignore_errors=True)
for dirpath, _dirs, files in os.walk(res_src):
    rel = os.path.relpath(dirpath, res_src)
    target = os.path.join(res_dst, rel)
    os.makedirs(target, exist_ok=True)
    for f in files:
        shutil.copy2(os.path.join(dirpath, f), os.path.join(target, f))
print('icons and launch screen copied')
