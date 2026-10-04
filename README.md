# Emerging Sciences Website

Free Mathematics platform for IIT JAM, CUET PG, TIFR & all MSc entrances.

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
