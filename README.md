# Emerging Sciences Website

Mathematics platform for IIT JAM, CUET PG, TIFR GS, GATE, CSIR NET, NBHM, ISI, CMI & other MSc entrances.

## Content sirf `data.js` me add hota hai
Pages khud ban jaate hain (lectures, watch, material, search, more).

**Naya lecture:** `lectures: [...]` me ek line add karo
`{id:"ode-17",s:"ode",n:"L-17",t:"Title",k:"T",yt:"YOUTUBE_VIDEO_ID"}`
(`k`: "T" = Theory, "P" = Practice; `yt` = youtu.be/ ke baad wali 11 character ID; `id` unique hona chahiye)

**Nayi PDF:** `material: [...]` me
`{id:"m12",t:"Title",d:"Description",k:"Notes",s:"ra",drive:"GOOGLE_DRIVE_FILE_ID"}`
(`k`: Notes / PYQ / Practice; Drive file "Anyone with the link" share honi chahiye)

**Naya subject:** `subjects` me `live:true` karo aur lectures me wahi `s` id use karo.
**Update/news:** `updates` me line add karo. **Exam date / daily goal:** `exam`, `goalMin`.

Purane pages zip ke `old-backup/` me hain (repo me upload karna zaroori nahi).

**FAQ / doubt links:** `faq` aur `doubtLinks` bhi `data.js` me hain.

## Exam-wise flow (v4)
Lectures / Study Material / Mock Test all follow: **Exam → Subject → content**.
- **Exams** live in `data.js → exams`: `{id, short, tag, name, body, date (YYYY-MM-DD, first day), dateText, note, site (official link), desc, subjects:[subject ids]}`.
  The day-count on the cards is computed from `date`. Update `date`/`dateText`/`note` when the official schedule changes.
- A subject can appear under many exams (same `id` in each exam's `subjects`) — its lectures/PDFs are shared.
  Subjects for GATE, CSIR NET, CUET PG, TIFR, NBHM, ISI, CMI were taken from public syllabi — please verify.
- **Mock tests:** list in `data.js → mocks` `{id, e:"exam id", s:"full" or subject id, t:"Title", q:12, min:30}` and put the questions in `mocks.js` under the same `id` (format described at the top of that file).
- Header + bottom navigation come from `nav.js` (edit once, applies to every page).

## Notifications (🔔) — agar naye notification na aayein
- Notification tab banta hai jab koi **kisi ke comment par reply** karta hai (naya top-level comment kisi ko notify nahi karta).
- Reply karne wale ka browser/app doosre user ke `users/{uid}/notifs` me likhta hai, isliye Firestore rules me wo block hona zaroori hai: `firestore.rules` dekho (Firebase console → Firestore → Rules me paste → Publish).
- Ab agar notification save nahi ho paye to reply karne wale ko lal message dikhta hai (jaise `permission-denied`), aur bell ke panel me load-error ka code dikhta hai. Pehle ye chup-chap fail hota tha.

## Search
Search me Lectures / Material / Mock Tests ke tabs (counts ke saath) hain; matching mock tests sabse upar dikhte hain.

