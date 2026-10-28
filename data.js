// EDIT THIS FILE to add lectures / PDFs / exams. Site pages build themselves from it.
// After every edit: check for a missing comma "," or quote. One mistake = blank black page.
//
// FLOW:  Exam  ->  Subject ("papers")  ->  Topic ("subjects")  ->  lectures / material / mocks
//
// ADD A NEW EXAM    : add a block in "exams" (id, short, tag, color, name, body, date, dateText, note, site, desc,
//                     "papers":[ids of subjects it has], "subjects":[ids of topics it has]).
// ADD A NEW SUBJECT : add { "id":"xy", "name":"Name", "icon":"emoji" } in "papers", then put "xy" in the exam's "papers" list.
// ADD A NEW TOPIC   : add { "id":"ph-mech", "name":"Mechanics", "icon":"F=ma", "p":"ph", "live":true } in "subjects"
//                     ("p" = subject id; no "p" means Mathematics), then put "ph-mech" in the exam's "subjects" list.
// ADD A LECTURE     : in "lectures": { "id":"ph-mech-01", "s":"ph-mech", "n":"L-01", "t":"Title", "k":"T", "yt":"YouTubeVideoId" }   (k: T = theory, P = practice)
// ADD MATERIAL      : in "material": { "id":"m99", "t":"Title", "d":"short note", "k":"Notes", "s":"ph-mech", "drive":"<Google Drive file id>" }
// ADD A MOCK        : in "mocks": { "id":"jam-ph-1", "e":"jam", "p":"ph", "s":"full", "t":"Title", "q":12, "min":30 }
// SYLLABUS rows     : { "e":"jam", "p":"ph", "t":"Title", "url":"https://official-link.pdf", "src":"Official · site" }  (or "drive":"<id>"; no "p" = Mathematics)
// PYQS rows         : { "e":"jam", "p":"ph", "y":2026, "t":"Title", "qp":"https://...", "key":"https://..." }  ("g" = optional group, "n" = optional note)
// pyqPortals        : official 'all years' page. Key "jam" = fallback for every subject of that exam; key "jam-ph" = only for Physics.
//                     Shown for any exam+subject that has no year rows yet. Once you add PYQS rows for it, the rows are shown.
// Exams WITHOUT "papers" (NBHM, ISI, CMI) skip the subject step and open topics directly.
window.ES_DATA = {
 "goalMin": 30,
 "papers": [
  {
   "id": "ma",
   "name": "Mathematics",
   "icon": "∑"
  },
  {
   "id": "ph",
   "name": "Physics",
   "icon": "⚛️"
  },
  {
   "id": "cy",
   "name": "Chemistry",
   "icon": "🧪"
  },
  {
   "id": "bt",
   "name": "Biotechnology",
   "icon": "🧬"
  },
  {
   "id": "en",
   "name": "Economics",
   "icon": "📈"
  },
  {
   "id": "gg",
   "name": "Geology",
   "icon": "🪨"
  },
  {
   "id": "ms",
   "name": "Mathematical Statistics",
   "icon": "📊"
  },
  {
   "id": "bc",
   "name": "Biochemistry",
   "icon": "🔬"
  },
  {
   "id": "bo",
   "name": "Botany",
   "icon": "🌿"
  },
  {
   "id": "zo",
   "name": "Zoology",
   "icon": "🦎"
  },
  {
   "id": "mb",
   "name": "Microbiology",
   "icon": "🦠"
  },
  {
   "id": "st",
   "name": "Statistics",
   "icon": "📉"
  },
  {
   "id": "cs",
   "name": "Computer Science",
   "icon": "💻"
  },
  {
   "id": "es",
   "name": "Environmental Science",
   "icon": "🌍"
  },
  {
   "id": "bg",
   "name": "Biology",
   "icon": "🧫"
  },
  {
   "id": "se",
   "name": "Science Education",
   "icon": "🎓"
  },
  {
   "id": "ls",
   "name": "Life Sciences",
   "icon": "🌱"
  },
  {
   "id": "xh",
   "name": "Humanities & Social Sciences",
   "icon": "📚"
  },
  {
   "id": "ey",
   "name": "Ecology & Evolution",
   "icon": "🌳"
  },
  {
   "id": "da",
   "name": "Data Science & AI",
   "icon": "🤖"
  },
  {
   "id": "pys",
   "name": "Physical Sciences",
   "icon": "🔭"
  },
  {
   "id": "chs",
   "name": "Chemical Sciences",
   "icon": "⚗️"
  },
  {
   "id": "eas",
   "name": "Earth, Atmospheric, Ocean & Planetary Sciences",
   "icon": "🌊"
  }
 ],
 "subjects": [
  {
   "id": "ode",
   "name": "Ordinary Differential Equations",
   "icon": "dy/dx",
   "live": true
  },
  {
   "id": "ra",
   "name": "Real Analysis",
   "icon": "ε–δ",
   "live": true
  },
  {
   "id": "bm",
   "name": "Basic Maths for JAM",
   "icon": "📐",
   "live": true
  },
  {
   "id": "ba",
   "name": "Basic Algebra",
   "icon": "n!",
   "live": true
  },
  {
   "id": "alg",
   "name": "Abstract Algebra",
   "icon": "G/H"
  },
  {
   "id": "la",
   "name": "Linear Algebra",
   "icon": "Ax=λx"
  },
  {
   "id": "ic",
   "name": "Integral Calculus",
   "icon": "∫ f(x)dx",
   "live": true
  },
  {
   "id": "top",
   "name": "Topology",
   "icon": "(X,τ)"
  },
  {
   "id": "ca",
   "name": "Complex Analysis",
   "icon": "f(z)"
  },
  {
   "id": "calc",
   "name": "Calculus & Multivariable Calculus",
   "icon": "∂f/∂x"
  },
  {
   "id": "fa",
   "name": "Functional Analysis",
   "icon": "‖x‖"
  },
  {
   "id": "na",
   "name": "Numerical Analysis",
   "icon": "x₍ₙ₊₁₎"
  },
  {
   "id": "pde",
   "name": "Partial Differential Equations",
   "icon": "∂²u"
  },
  {
   "id": "lp",
   "name": "Linear Programming",
   "icon": "max cᵀx"
  },
  {
   "id": "ps",
   "name": "Probability & Statistics",
   "icon": "P(A)"
  },
  {
   "id": "mech",
   "name": "Mechanics",
   "icon": "F=ma"
  },
  {
   "id": "cvie",
   "name": "Calculus of Variations & Integral Equations",
   "icon": "δJ"
  },
  {
   "id": "comb",
   "name": "Combinatorics & Number Theory",
   "icon": "C(n,r)"
  },
  {
   "id": "ph-mech",
   "name": "Mechanics & General Properties of Matter",
   "icon": "W=mg",
   "p": "ph",
   "live": true
  },
  {
   "id": "ph-mm",
   "name": "Mathematical Methods",
   "icon": "dy/dx",
   "p": "ph",
   "live": true
  },
  {
   "id": "ph-shmo",
   "name": "Oscillations, Waves and Optics",
   "icon": "R=2f",
   "p": "ph",
   "live": true
  },
  {
   "id": "ph-emt",
   "name": "Electricity and Magnetism",
   "icon": "V=IR",
   "p": "ph",
   "live": true
  },
  {
   "id": "ph-ktt",
   "name": "Kinetic theroy and thermodynamics",
   "icon": "PV=nRT",
   "p": "ph",
   "live": true
  },
  {
   "id": "ph-mopy",
   "name": "Modern Physics",
   "icon": "E=mc^2",
    "p": "ph",
   "live": true
  },
  {
   "id": "ph-sspe",
   "name": "Solid state physics , Devices & Electronics",
   "icon": "a=2r",
   "p": "ph",
   "live": true
  },
  {
   "id": "cy-bmc",
   "name": "Basic mathematical concepts",
   "icon": "y=mx",
   "p": "cy",
   "live": true
  },
  {
   "id": "cy-pc",
   "name": "Physical Chemistry",
   "icon": "ΔG",
   "p": "cy",
   "live": true
  },
  {
   "id": "cy-oc",
   "name": "Organic Chemistry",
   "icon": "R-OH",
   "p": "cy",
   "live": true
  },
  {
   "id": "cy-ic",
   "name": "Inorganic chemistry",
   "icon": "logx",
   "p": "cy",
   "live": true
  },
  {
    "id": "bt-gen",
    "name": "General Biology",
    "icon": "DNA",
    "p": "bt",
    "live": true
  },
  {
    "id": "bt-mpa",
    "name": "Microbial, Plant & Animal Biotechnology",
    "icon": "Cell",
    "p": "bt",
    "live": true
  },
  {
    "id": "bt-tech",
    "name": "Biotechniques",
    "icon": "PCR",
    "p": "bt",
    "live": true
  },
  {
    "id": "bt-chem",
    "name": "Chemistry",
    "icon": "ΔG",
    "p": "bt",
    "live": true
  },
  {
    "id": "bt-math",
    "name": "Mathematics",
    "icon": "f(x)",
    "p": "bt",
    "live": true
  },
  {
    "id": "bt-phys",
    "name": "Physics",
    "icon": "E=mc^2",
    "p": "bt",
    "live": true
  }
 ],
 "lectures": [
  {
   "id": "ode-01",
   "s": "ode",
   "n": "L-01",
   "t": "Introduction to ODE — Basic Concepts & Classification",
   "k": "T",
   "yt": "oI_GrYNmJmE"
  },
  {
   "id": "ode-02",
   "s": "ode",
   "n": "L-02",
   "t": "Linear, Non-linear and Solution of Differential Equations",
   "k": "T",
   "yt": "pXXVUlv4qHY"
  },
  {
   "id": "ode-03",
   "s": "ode",
   "n": "L-03",
   "t": "Formation and Variable Separation",
   "k": "T",
   "yt": "VAuIf_EZ9pw"
  },
  {
   "id": "ode-04",
   "s": "ode",
   "n": "L-04",
   "t": "Variable Separation — Questions",
   "k": "P",
   "yt": "aPnshDf-6uA"
  },
  {
   "id": "ode-05",
   "s": "ode",
   "n": "L-05",
   "t": "Variable Separation by Substitution",
   "k": "T",
   "yt": "rq5UvnJ2Ex4"
  },
  {
   "id": "ode-06",
   "s": "ode",
   "n": "L-06",
   "t": "Homogeneous Differential Equations",
   "k": "T",
   "yt": "DWiC67UK9lM"
  },
  {
   "id": "ode-07",
   "s": "ode",
   "n": "L-07",
   "t": "Homogeneous Differential Equations — Questions",
   "k": "P",
   "yt": "am3kzy-frvo"
  },
  {
   "id": "ode-08",
   "s": "ode",
   "n": "L-08",
   "t": "Reducible to Homogeneous",
   "k": "T",
   "yt": "RokfXwbfw7U"
  },
  {
   "id": "ode-09",
   "s": "ode",
   "n": "L-09",
   "t": "Reducible to Homogeneous — Questions",
   "k": "P",
   "yt": "dxfxedKu8gA"
  },
  {
   "id": "ode-10",
   "s": "ode",
   "n": "L-10",
   "t": "Linear Differential Equations",
   "k": "T",
   "yt": "NoxUCzIwXgk"
  },
  {
   "id": "ode-11",
   "s": "ode",
   "n": "L-11",
   "t": "Linear Differential Equations — Questions",
   "k": "P",
   "yt": "9ZlZjW-pUSM"
  },
  {
   "id": "ode-12",
   "s": "ode",
   "n": "L-12",
   "t": "Bernoulli's Differential Equations",
   "k": "T",
   "yt": "LPuyXi5a03I"
  },
  {
   "id": "ode-13",
   "s": "ode",
   "n": "L-13",
   "t": "Exact Differential Equations",
   "k": "T",
   "yt": "y-OpPKjnyaI"
  },
  {
   "id": "ode-14",
   "s": "ode",
   "n": "L-14",
   "t": "Exact Differential Equations — Questions",
   "k": "P",
   "yt": "DIuJGqRpFgc"
  },
  {
   "id": "ode-15",
   "s": "ode",
   "n": "L-15",
   "t": "Non-Exact Differential Equations — Theory",
   "k": "T",
   "yt": "CHnOpIQYbg0"
  },
  {
   "id": "ode-16",
   "s": "ode",
   "n": "L-16",
   "t": "Non-Exact Differential Equations — Questions",
   "k": "P",
   "yt": "4n9xDvg-ODA"
  },
  {
   "id": "ra-01",
   "s": "ra",
   "n": "L-01",
   "t": "Elementary Set Theory",
   "k": "T",
   "yt": "GQIUw_6T5a0"
  },
  {
   "id": "ra-02",
   "s": "ra",
   "n": "L-02",
   "t": "Functions",
   "k": "T",
   "yt": "xA4xOZZn7Lc"
  },
  {
   "id": "ra-03",
   "s": "ra",
   "n": "L-03",
   "t": "Bounds",
   "k": "T",
   "yt": "RCB9bBi8dKc"
  },
  {
   "id": "ra-04",
   "s": "ra",
   "n": "L-04",
   "t": "Supremum & Infimum — Upper & Lower Bounds",
   "k": "T",
   "yt": "6avoV_KGqcg"
  },
  {
   "id": "ra-05",
   "s": "ra",
   "n": "L-05",
   "t": "Intervals and Neighbourhood",
   "k": "T",
   "yt": "MfG9iN7raEs"
  },
  {
   "id": "ra-06",
   "s": "ra",
   "n": "L-06",
   "t": "Adherent Point and Closure",
   "k": "T",
   "yt": "oPNtIX2caGY"
  },
  {
   "id": "ra-07",
   "s": "ra",
   "n": "L-07",
   "t": "Limit Point and Derived Set",
   "k": "T",
   "yt": "9uVbI0iBCBU"
  },
  {
   "id": "ra-08",
   "s": "ra",
   "n": "L-08",
   "t": "Condensation Points",
   "k": "T",
   "yt": "IYZJrQIQaEo"
  },
  {
   "id": "ra-09",
   "s": "ra",
   "n": "L-09",
   "t": "Interior, Exterior, Isolated, Frontier & Boundary Points",
   "k": "T",
   "yt": "mrniPjcllbQ"
  }
 ],
 "material": [
  {
   "id": "m01",
   "t": "ODE Notes — Part 1",
   "d": "First order, first degree differential equations",
   "k": "Notes",
   "s": "ode",
   "drive": "1ipTlTJoFwGeEJTyRl5ADbPKOeiO3w8bz"
  },
  {
   "id": "m02",
   "t": "ODE Notes — Part 2",
   "d": "Exact differential equations questions",
   "k": "PYQ",
   "s": "ode",
   "drive": "1wmHk0IJo2V-BfPr-gM2Pv_jfer1ShCNK"
  },
  {
   "id": "m03",
   "t": "ODE Notes — Part 3",
   "d": "Non-exact differential equations questions",
   "k": "PYQ",
   "s": "ode",
   "drive": "1i3eeH-ebRvlbbic2SFyxGi6Y42ttLCQr"
  },
  {
   "id": "m04",
   "t": "Real Analysis Notes — Part 1",
   "d": "Chapter 01 · Preliminaries",
   "k": "Notes",
   "s": "ra",
   "drive": "1CkfzYPfvg2xt7mmJTDfdlOcv2lKUqMnn"
  },
  {
   "id": "m05",
   "t": "Point Set Topology Notes",
   "d": "Complete point set topology notes",
   "k": "Notes",
   "s": "ra",
   "drive": "1TM6UxpTaulh8r_FY7wAbgZgZaX7QY48b"
  },
  {
   "id": "m06",
   "t": "Point Set Topology PYQs",
   "d": "IIT JAM PYQs and practice",
   "k": "PYQ",
   "s": "ra",
   "drive": "10wWkL6OaHoQk2FC5hOnXjxwma-FS6OCt"
  },
  {
   "id": "m07",
   "t": "Countable Sets",
   "d": "Chapter 02 · Theory",
   "k": "Notes",
   "s": "ra",
   "drive": "1bBSoDkQsnE51fODQD13wWm7_3L5ttCBs"
  },
  {
   "id": "m08",
   "t": "Real Sequences",
   "d": "Chapter 03 · Theory",
   "k": "Notes",
   "s": "ra",
   "drive": "1a5iRhzRRiNz1IBTes33ZCj1DKjHlJ9x9"
  },
  {
   "id": "m09",
   "t": "Real Sequences PYQs",
   "d": "Chapter 03 · IIT JAM PYQs",
   "k": "PYQ",
   "s": "ra",
   "drive": "15peSQWKzYi6UuRIzJ2Pwp9nn3BTzygvo"
  },
  {
   "id": "m10",
   "t": "Real Sequences Practice Sheet 1",
   "d": "Chapter 03 · Examples",
   "k": "Practice",
   "s": "ra",
   "drive": "12rjXxAaNhLl7JhZbuIS4X5SGeBywA1N2"
  },
  {
   "id": "m11",
   "t": "Series PYQs",
   "d": "Chapter 04 · IIT JAM PYQs",
   "k": "PYQ",
   "s": "ra",
   "drive": "1SVOy9FxNQ5sQhPeT9att3y4D-Ryt-pba"
  },
  {
   "id": "bm1",
   "t": "Sets,Relations and functions",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "1bUriJ0FrUV7KOIOOLJLUtja5DL956hl3"
  },
  {
   "id": "bm2",
   "t": "Co-ordinate geometry",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "1-BNFd45vsZ4gBvo2HwUCI-BstxTwG4aP"
  },
  {
   "id": "bm3",
   "t": "Conic sections",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "1l-qfJQJQtCLOyrVqfLdN6L7mfvCBgs1r"
  },
  {
   "id": "bm4",
   "t": "Matrices and determinants",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "10BPhX3uoOP6eOTQ8mGA2AHihGMeUMDFA"
  },
  {
   "id": "bm5",
   "t": "Sequence and Series",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "1hmWm0tRjCC9dPwsUlUBuBd1EpDY0AUxc"
  },
  {
   "id": "bm6",
   "t": "Inequalities",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "1wDnyQ5spWkWFJ1AWri_gqyQ5cG2PS6Om"
  },
  {
   "id": "bm7",
   "t": "Trigonometry",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "1wqCv3D7DOtP71G-1jRab7MssQOYNZukU"
  },
  {
   "id": "bm8",
   "t": "Theory of equations",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "1u7KYLauszzNlh_WlPg7o0DjqV8veCCIS"
  },
  {
   "id": "bm9",
   "t": "Principle of mathematical induction",
   "d": "theory",
   "k": "Notes",
   "s": "bm",
   "drive": "1jDqzQhCeaQQMF8U6MzVEnBJ_-TVh5l80"
  },
  {
   "id": "ba-01",
   "t": "Permutations and combinations",
   "d": "One-shot revision sheet · Theory with examples",
   "k": "Notes",
   "s": "ba",
   "drive": "1aEXD-gJn9Gfqo1LYxSqiqHjJxP7c7rY9"
  },
  {
   "id": "ba-02",
   "t": "Bionomial theorem",
   "d": "One-shot revision sheet · Theory with examples",
   "k": "Notes",
   "s": "ba",
   "drive": "1lbbw4SsGr1Qw-hGDbmgbTunKsVVTwEqu"
  },
  {
   "id": "ic-01",
   "t": "Indefinite integration",
   "d": "One-shot revision sheet · Theory with examples",
   "k": "Notes",
   "s": "ic",
   "drive": "1AoEYOyIp03TTZ2_Z5Ph1Wl51eu0hnrDS"
  }
 ],
 "faq": [
  {
   "q": "Why Emerging Sciences?",
   "a": "Lectures, notes and practice follow a single flow: watch the lecture, read the matching PDF, then solve questions — organised exam by exam."
  },
  {
   "q": "Is everything really free?",
   "a": "Yes. Every lecture, note and PDF is free forever. No fees, no registration."
  },
  {
   "q": "Which exams is this for?",
   "a": "IIT JAM, CUET PG, TIFR GS, GATE (Mathematics), CSIR-UGC NET (Mathematical Sciences), NBHM, ISI and CMI — plus other MSc entrances such as DU and BHU via CUET PG."
  },
  {
   "q": "How should I study here?",
   "a": "Pick your exam, choose a subject, watch the lecture first, then read the matching PDF notes and practise with mock tests."
  },
  {
   "q": "When will new subjects arrive?",
   "a": "Abstract Algebra, Linear Algebra, Complex Analysis and Topology are being uploaded over time. Join Telegram for updates."
  },
  {
   "q": "How do I ask a doubt?",
   "a": "Use the Doubts tab. Your question opens in Telegram so you can send it directly."
  }
 ],
 "doubtLinks": [],
 "updates": [
  {
   "date": "2026-10-28",
   "text": "Subjects added in every exam: choose Exam → Subject → Topic. New subjects for IIT JAM, CUET PG, TIFR, GATE and CSIR NET, each with Syllabus and PYQ cards."
  },
  {
   "date": "2026-10-27",
   "text": "Lectures, Study Material and Mock Tests are now organised exam-wise: IIT JAM, CUET PG, TIFR, GATE, CSIR NET, NBHM, ISI and CMI."
  },
  {
   "date": "2026-10-04",
   "text": "New site: lecture progress, daily goal, study streak and search added."
  }
 ],
 "links": {
  "youtube": "https://youtube.com/@EMS4518-k4s",
  "telegram": "https://t.me/emer816",
  "x": "https://x.com/emergingsc28041"
 },
 "exams": [
  {
   "id": "jam",
   "short": "IIT JAM",
   "tag": "IIT<br>JAM",
   "color": "#4F8CFF",
   "name": "IIT JAM",
   "body": "IIT Kharagpur (JAM 2027)",
   "date": "2027-02-14",
   "dateText": "14 Feb 2027",
   "note": "confirmed",
   "site": "https://jam.iitkgp.ac.in/",
   "desc": "Joint Admission Test for M.Sc. admission to IITs, IISc and other premier institutes. Papers: Mathematics, Physics, Chemistry, Biotechnology, Economics, Geology and Mathematical Statistics.",
   "papers": [
    "ma",
    "ph",
    "cy",
    "bt",
    "en",
    "gg",
    "ms"
   ],
   "subjects": [
    "ode",
    "ra",
    "bm",
    "ba",
    "alg",
    "la",
    "ic",
    "top",
    "ph-mech",
    "ph-mm",
    "ph-shmo",
    "ph-emt",
    "ph-ktt",
    "ph-mopy",
    "ph-sspe",
    "cy-bmc",
    "cy-pc",
    "cy-oc",
    "cy-ic",
    "bt-gen",
    "bt-mpa",
    "bt-tech",
    "bt-chem",
    "bt-math",
    "bt-phys"
   ],
  },
  {
   "id": "cuetpg",
   "short": "CUET PG",
   "tag": "CUET<br>PG",
   "color": "#34D399",
   "name": "CUET PG",
   "body": "National Testing Agency (NTA)",
   "date": "2027-03-02",
   "dateText": "2 – 31 Mar 2027",
   "note": "tentative",
   "site": "https://exams.nta.nic.in/cuet-pg/",
   "desc": "Common entrance for M.Sc. at central universities (DU, BHU, JNU and more) and participating institutions. Science papers: Mathematics, Physics, Chemistry, Biotechnology, Biochemistry, Botany, Zoology, Microbiology, Statistics, Computer Science, Environmental Science, Geology and Economics.",
   "papers": [
    "ma",
    "ph",
    "cy",
    "bt",
    "bc",
    "bo",
    "zo",
    "mb",
    "st",
    "cs",
    "es",
    "gg",
    "en"
   ],
   "subjects": [
    "alg",
    "la",
    "ra",
    "ca",
    "ode",
    "pde",
    "calc",
    "ps",
    "na",
    "mech"
   ]
  },
  {
   "id": "tifr",
   "short": "TIFR GS",
   "tag": "TIFR",
   "color": "#FB923C",
   "name": "TIFR Graduate School (GS)",
   "body": "Tata Institute of Fundamental Research",
   "date": "2026-12-13",
   "dateText": "13 Dec 2026",
   "note": "confirmed",
   "site": "https://www.tifr.res.in/academics/",
   "desc": "Admission to the Ph.D., Integrated Ph.D. and M.Sc. programmes at TIFR Mumbai and Bengaluru. Papers: Mathematics, Physics, Chemistry, Biology, Computer Science and Science Education.",
   "papers": [
    "ma",
    "ph",
    "cy",
    "bg",
    "cs",
    "se"
   ],
   "subjects": [
    "alg",
    "la",
    "ra",
    "calc",
    "ode",
    "top",
    "comb"
   ]
  },
  {
   "id": "gate",
   "short": "GATE",
   "tag": "GATE",
   "color": "#A78BFA",
   "name": "GATE",
   "body": "IIT Madras (GATE 2027)",
   "date": "2027-02-06",
   "dateText": "6 – 21 Feb 2027",
   "note": "paper-wise schedule awaited",
   "site": "https://gate2027.iitm.ac.in/",
   "desc": "Graduate Aptitude Test in Engineering — science-side papers for M.Tech/Ph.D. admissions and PSU recruitment: Mathematics, Physics, Chemistry, Biotechnology, Life Sciences, Geology & Geophysics, Statistics, Humanities & Social Sciences, Ecology & Evolution, Data Science & AI.",
   "papers": [
    "ma",
    "ph",
    "cy",
    "bt",
    "ls",
    "gg",
    "st",
    "xh",
    "ey",
    "da"
   ],
   "subjects": [
    "calc",
    "la",
    "ra",
    "ca",
    "ode",
    "alg",
    "fa",
    "na",
    "pde",
    "top",
    "lp"
   ]
  },
  {
   "id": "csir",
   "short": "CSIR NET",
   "tag": "CSIR<br>NET",
   "color": "#F472B6",
   "name": "CSIR-UGC NET",
   "body": "National Testing Agency (NTA)",
   "date": "2026-12-19",
   "dateText": "19, 22 & 27 Dec 2026",
   "note": "subject-wise date on admit card",
   "site": "https://csirnet.nta.nic.in/",
   "desc": "Eligibility for Junior Research Fellowship (JRF) and Assistant Professor. Subjects: Mathematical Sciences, Physical Sciences, Chemical Sciences, Life Sciences and Earth, Atmospheric, Ocean & Planetary Sciences.",
   "papers": [
    "ma",
    "pys",
    "chs",
    "ls",
    "eas"
   ],
   "subjects": [
    "ra",
    "la",
    "ca",
    "alg",
    "comb",
    "top",
    "ode",
    "pde",
    "na",
    "cvie",
    "mech",
    "ps",
    "lp"
   ]
  },
  {
   "id": "nbhm",
   "short": "NBHM",
   "tag": "NBHM",
   "color": "#FACC15",
   "name": "NBHM M.A./M.Sc. & Ph.D. Scholarship Test",
   "body": "National Board for Higher Mathematics",
   "date": "2027-01-30",
   "dateText": "30 Jan 2027",
   "note": "tentative",
   "site": "https://nbhm.dae.gov.in/",
   "desc": "Screening test for NBHM Master's and Doctoral scholarships in Mathematics. No fixed syllabus — based on past papers.",
   "subjects": [
    "calc",
    "la",
    "alg",
    "ra",
    "top",
    "ca",
    "comb"
   ]
  },
  {
   "id": "isi",
   "short": "ISI",
   "tag": "ISI",
   "color": "#22D3EE",
   "name": "ISI M.Math Admission Test",
   "body": "Indian Statistical Institute",
   "date": "2027-05-09",
   "dateText": "2nd week of May 2027",
   "note": "tentative",
   "site": "https://admission.isical.ac.in/",
   "desc": "Admission to the two-year Master of Mathematics programme at ISI Kolkata and Bengaluru.",
   "subjects": [
    "calc",
    "ra",
    "la",
    "alg",
    "comb",
    "top"
   ]
  },
  {
   "id": "cmi",
   "short": "CMI",
   "tag": "CMI",
   "color": "#F87171",
   "name": "CMI M.Sc. Mathematics Entrance",
   "body": "Chennai Mathematical Institute",
   "date": "2027-05-02",
   "dateText": "Early May 2027",
   "note": "tentative",
   "site": "https://www.cmi.ac.in/admissions/",
   "desc": "Admission to the M.Sc. Mathematics programme at Chennai Mathematical Institute.",
   "subjects": [
    "ra",
    "la",
    "alg",
    "calc",
    "top",
    "comb"
   ]
  }
 ],
 "syllabus": [
  {
   "e": "jam",
   "t": "IIT JAM Mathematics (MA) — Syllabus 2027",
   "url": "https://jam.iitkgp.ac.in/docs/ma_2027_syllabus.pdf",
   "src": "Official · jam.iitkgp.ac.in"
  },
  {
   "e": "jam",
   "t": "JAM 2027 Information Brochure (pattern, eligibility)",
   "url": "https://jam.iitkgp.ac.in/docs/Info_Brochure_v3.pdf",
   "src": "Official · jam.iitkgp.ac.in"
  },
  {
   "e": "cuetpg",
   "t": "CUET (PG) — Syllabus page (open the Mathematics paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own notice; NTA refreshes this page every year."
  },
  {
   "e": "tifr",
   "t": "TIFR GS — Mathematics syllabus & exam instructions",
   "url": "https://www.tifr.res.in/academics/docs/Maths_syllabus_exam_instructions.pdf",
   "src": "Official · tifr.res.in"
  },
  {
   "e": "gate",
   "t": "GATE 2027 Mathematics (MA) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/static/doc/GATE2027_Syllabus/MA_GATE2027_Syllabus.pdf",
   "src": "Official · IIT Madras"
  },
  {
   "e": "gate",
   "t": "GATE 2027 General Aptitude (GA) — common 15 marks",
   "url": "https://gate2027.iitm.ac.in/static/doc/GATE2027_Syllabus/GA_GATE2027_Syllabus.pdf",
   "src": "Official · IIT Madras"
  },
  {
   "e": "csir",
   "t": "CSIR-UGC NET Mathematical Sciences — Syllabus",
   "url": "https://www.csirhrdg.res.in/old_website/mcs_ma_sylbs.pdf",
   "src": "CSIR-HRDG (older copy)",
   "n": "Older CSIR-HRDG copy of the syllabus; cross-check with the Dec 2026 bulletin below."
  },
  {
   "e": "csir",
   "t": "Joint CSIR-UGC NET Dec 2026 — Information Bulletin (scheme, dates)",
   "url": "https://cdnbbsr.s3waas.gov.in/s3efdf562ce2fb0ad460fd8e9d33e57f57/uploads/2026/10/202610071407707951.pdf",
   "src": "Official · NTA"
  },
  {
   "e": "nbhm",
   "t": "NBHM — no prescribed syllabus (official FAQ). Study from past papers.",
   "url": "https://www.imsc.res.in/~nbhm/ST_current/faq.html",
   "src": "Official · NBHM",
   "n": "NBHM publishes no syllabus; question papers from 2005 onward are the guide."
  },
  {
   "e": "isi",
   "t": "ISI M.Math (PMA & PMB) — Syllabus 2026",
   "url": "https://admission.isical.ac.in/Syllabus/MMath-Syllabus-PMA-PMB-2026.pdf",
   "src": "Official · ISI"
  },
  {
   "e": "cmi",
   "t": "CMI MSc/PhD Mathematics — Syllabus & reading material",
   "url": "https://www.cmi.ac.in/admissions/syllabus/pgmath-syllabus.pdf",
   "src": "Official · cmi.ac.in"
  },
  {
   "e": "jam",
   "p": "ph",
   "t": "IIT JAM Physics (PH) — Syllabus 2027",
   "url": "https://jam.iitkgp.ac.in/",
   "src": "Official · jam.iitkgp.ac.in",
   "n": "Opens the official JAM site — the syllabus PDF of this paper is listed there. Later you can replace this url with the direct PDF link."
  },
  {
   "e": "jam",
   "p": "cy",
   "t": "IIT JAM Chemistry (CY) — Syllabus 2027",
   "url": "https://jam.iitkgp.ac.in/",
   "src": "Official · jam.iitkgp.ac.in",
   "n": "Opens the official JAM site — the syllabus PDF of this paper is listed there. Later you can replace this url with the direct PDF link."
  },
  {
   "e": "jam",
   "p": "bt",
   "t": "IIT JAM Biotechnology (BT) — Syllabus 2027",
   "url": "https://jam.iitkgp.ac.in/",
   "src": "Official · jam.iitkgp.ac.in",
   "n": "Opens the official JAM site — the syllabus PDF of this paper is listed there. Later you can replace this url with the direct PDF link."
  },
  {
   "e": "jam",
   "p": "en",
   "t": "IIT JAM Economics (EN) — Syllabus 2027",
   "url": "https://jam.iitkgp.ac.in/",
   "src": "Official · jam.iitkgp.ac.in",
   "n": "Opens the official JAM site — the syllabus PDF of this paper is listed there. Later you can replace this url with the direct PDF link."
  },
  {
   "e": "jam",
   "p": "gg",
   "t": "IIT JAM Geology (GG) — Syllabus 2027",
   "url": "https://jam.iitkgp.ac.in/",
   "src": "Official · jam.iitkgp.ac.in",
   "n": "Opens the official JAM site — the syllabus PDF of this paper is listed there. Later you can replace this url with the direct PDF link."
  },
  {
   "e": "jam",
   "p": "ms",
   "t": "IIT JAM Mathematical Statistics (MS) — Syllabus 2027",
   "url": "https://jam.iitkgp.ac.in/",
   "src": "Official · jam.iitkgp.ac.in",
   "n": "Opens the official JAM site — the syllabus PDF of this paper is listed there. Later you can replace this url with the direct PDF link."
  },
  {
   "e": "cuetpg",
   "p": "ph",
   "t": "CUET (PG) Physics — Syllabus (open the Physics paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "cy",
   "t": "CUET (PG) Chemistry — Syllabus (open the Chemistry paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "bt",
   "t": "CUET (PG) Biotechnology — Syllabus (open the Biotechnology paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "bc",
   "t": "CUET (PG) Biochemistry — Syllabus (open the Biochemistry paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "bo",
   "t": "CUET (PG) Botany — Syllabus (open the Botany paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "zo",
   "t": "CUET (PG) Zoology — Syllabus (open the Zoology paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "mb",
   "t": "CUET (PG) Microbiology — Syllabus (open the Microbiology paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "st",
   "t": "CUET (PG) Statistics — Syllabus (open the Statistics paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "cs",
   "t": "CUET (PG) Computer Science — Syllabus (open the Computer Science paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "es",
   "t": "CUET (PG) Environmental Science — Syllabus (open the Environmental Science paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "gg",
   "t": "CUET (PG) Geology — Syllabus (open the Geology paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "cuetpg",
   "p": "en",
   "t": "CUET (PG) Economics — Syllabus (open the Economics paper)",
   "url": "https://exams.nta.nic.in/cuet-pg/syllabus/",
   "src": "Official · NTA",
   "n": "Link taken from NTA's own syllabus page; NTA refreshes it every year."
  },
  {
   "e": "tifr",
   "p": "ph",
   "t": "TIFR GS Physics — Syllabus & exam instructions",
   "url": "https://www.tifr.res.in/academics/",
   "src": "Official · tifr.res.in",
   "n": "Opens TIFR's official academics page; find the paper-wise syllabus there."
  },
  {
   "e": "tifr",
   "p": "cy",
   "t": "TIFR GS Chemistry — Syllabus & exam instructions",
   "url": "https://www.tifr.res.in/academics/",
   "src": "Official · tifr.res.in",
   "n": "Opens TIFR's official academics page; find the paper-wise syllabus there."
  },
  {
   "e": "tifr",
   "p": "bg",
   "t": "TIFR GS Biology — Syllabus & exam instructions",
   "url": "https://www.tifr.res.in/academics/",
   "src": "Official · tifr.res.in",
   "n": "Opens TIFR's official academics page; find the paper-wise syllabus there."
  },
  {
   "e": "tifr",
   "p": "cs",
   "t": "TIFR GS Computer Science — Syllabus & exam instructions",
   "url": "https://www.tifr.res.in/academics/",
   "src": "Official · tifr.res.in",
   "n": "Opens TIFR's official academics page; find the paper-wise syllabus there."
  },
  {
   "e": "tifr",
   "p": "se",
   "t": "TIFR GS Science Education — Syllabus & exam instructions",
   "url": "https://www.tifr.res.in/academics/",
   "src": "Official · tifr.res.in",
   "n": "Opens TIFR's official academics page; find the paper-wise syllabus there."
  },
  {
   "e": "gate",
   "p": "ph",
   "t": "GATE 2027 Physics (PH) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "gate",
   "p": "cy",
   "t": "GATE 2027 Chemistry (CY) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "gate",
   "p": "bt",
   "t": "GATE 2027 Biotechnology (BT) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "gate",
   "p": "ls",
   "t": "GATE 2027 Life Sciences (XL) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "gate",
   "p": "gg",
   "t": "GATE 2027 Geology (GG) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "gate",
   "p": "st",
   "t": "GATE 2027 Statistics (ST) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "gate",
   "p": "xh",
   "t": "GATE 2027 Humanities & Social Sciences (XH) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "gate",
   "p": "ey",
   "t": "GATE 2027 Ecology & Evolution (EY) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "gate",
   "p": "da",
   "t": "GATE 2027 Data Science & AI (DA) — Syllabus",
   "url": "https://gate2027.iitm.ac.in/exam_papers_and_syllabus",
   "src": "Official · IIT Madras",
   "n": "Click this paper's code on the official page to download its syllabus PDF."
  },
  {
   "e": "csir",
   "p": "pys",
   "t": "CSIR-UGC NET Physical Sciences — Syllabus",
   "url": "https://csirnet.nta.nic.in/",
   "src": "Official · NTA",
   "n": "Syllabus is in the Information Bulletin / syllabus section of the NTA CSIR NET site."
  },
  {
   "e": "csir",
   "p": "chs",
   "t": "CSIR-UGC NET Chemical Sciences — Syllabus",
   "url": "https://csirnet.nta.nic.in/",
   "src": "Official · NTA",
   "n": "Syllabus is in the Information Bulletin / syllabus section of the NTA CSIR NET site."
  },
  {
   "e": "csir",
   "p": "ls",
   "t": "CSIR-UGC NET Life Sciences — Syllabus",
   "url": "https://csirnet.nta.nic.in/",
   "src": "Official · NTA",
   "n": "Syllabus is in the Information Bulletin / syllabus section of the NTA CSIR NET site."
  },
  {
   "e": "csir",
   "p": "eas",
   "t": "CSIR-UGC NET Earth, Atmospheric, Ocean & Planetary Sciences — Syllabus",
   "url": "https://csirnet.nta.nic.in/",
   "src": "Official · NTA",
   "n": "Syllabus is in the Information Bulletin / syllabus section of the NTA CSIR NET site."
  }
 ],
 "pyqs": [
  {
   "e": "jam",
   "y": 2026,
   "t": "IIT JAM 2026 Mathematics (MA)",
   "qp": "https://jam.iitkgp.ac.in/docs/2026_MA_QP_AK.pdf",
   "n": "Question paper + answer key (one PDF)"
  },
  {
   "e": "jam",
   "y": 2025,
   "t": "IIT JAM 2025 Mathematics (MA)",
   "qp": "https://jam.iitkgp.ac.in/docs/2025_MA_QP_AK.pdf",
   "n": "Question paper + answer key (one PDF)"
  },
  {
   "e": "jam",
   "y": 2024,
   "t": "IIT JAM 2024 Mathematics (MA)",
   "qp": "https://jam.iitkgp.ac.in/docs/2024_MA_QP_AK.pdf",
   "n": "Question paper + answer key (one PDF)"
  },
  {
   "e": "jam",
   "y": 2023,
   "t": "IIT JAM 2023 Mathematics (MA)",
   "qp": "https://jam.iitkgp.ac.in/docs/2023_MA_QP_AK.pdf",
   "n": "Question paper + answer key (one PDF)"
  },
  {
   "e": "jam",
   "y": 2022,
   "t": "IIT JAM 2022 Mathematics (MA)",
   "qp": "https://jam.iitkgp.ac.in/docs/2022_MA_QP.pdf",
   "n": "Question paper"
  },
  {
   "e": "gate",
   "y": 2026,
   "t": "GATE 2026 Mathematics (MA)",
   "qp": "https://gate2027.iitm.ac.in/static/doc/download/2026/QPs/MA.pdf",
   "key": "https://gate2027.iitm.ac.in/static/doc/download/2026/Keys/MA_Keys.pdf"
  },
  {
   "e": "gate",
   "y": 2025,
   "t": "GATE 2025 Mathematics (MA)",
   "qp": "https://gate2027.iitm.ac.in/static/doc/download/2025/MA2025.pdf",
   "key": "https://gate2027.iitm.ac.in/static/doc/download/2025_Key/MA_Keys.pdf"
  },
  {
   "e": "gate",
   "y": 2024,
   "t": "GATE 2024 Mathematics (MA)",
   "qp": "https://gate2027.iitm.ac.in/static/doc/download/2024/MA24S4.pdf",
   "key": "https://gate2027.iitm.ac.in/static/doc/download/2024/MAFinalAnswerKey.pdf"
  },
  {
   "e": "gate",
   "y": 2023,
   "t": "GATE 2023 Mathematics (MA)",
   "qp": "https://gate2027.iitm.ac.in/static/doc/download/2023/ma_2023.pdf",
   "key": "https://gate2027.iitm.ac.in/static/doc/download/Answer_keys2023/MA_ANS_GATE2023.pdf"
  },
  {
   "e": "gate",
   "y": 2022,
   "t": "GATE 2022 Mathematics (MA)",
   "qp": "https://gate2027.iitm.ac.in/static/doc/download/2022/ma_2022.pdf",
   "key": "https://gate2027.iitm.ac.in/static/doc/download/Answer_keys2022/ma_2022.pdf"
  },
  {
   "e": "gate",
   "y": 2021,
   "t": "GATE 2021 Mathematics (MA)",
   "qp": "https://gate2027.iitm.ac.in/static/doc/download/2021/ma_2021.pdf",
   "key": "https://gate2027.iitm.ac.in/static/doc/download/Answer_keys2021/ma_2021.pdf"
  },
  {
   "e": "nbhm",
   "y": 2026,
   "g": "Combined",
   "t": "NBHM Scholarship Test (Master's + Doctoral) — 2026",
   "qp": "https://www.imsc.res.in/~nbhm/qp/comb26.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/comb26key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2025,
   "g": "Combined",
   "t": "NBHM Scholarship Test (Master's + Doctoral) — 2025",
   "qp": "https://www.imsc.res.in/~nbhm/qp/comb25.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/comb25key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2024,
   "g": "Combined",
   "t": "NBHM Scholarship Test (Master's + Doctoral) — Jan 2024",
   "qp": "https://www.imsc.res.in/~nbhm/qp/comb24.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/comb24key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2023,
   "g": "Combined",
   "t": "NBHM Scholarship Test (Master's + Doctoral) — Apr 2023",
   "qp": "https://www.imsc.res.in/~nbhm/qp/comb23.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/comb23key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2022,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2022",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra22.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra22key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2021,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2021",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra21.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra21key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2020,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2020",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra20.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra20key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2019,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2019",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra19.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra19key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2019,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2019",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc19.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc19key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2018,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2018",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra18.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra18key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2018,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2018",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc18.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc18key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2017,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2017",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra17.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra17key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2017,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2017",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc17.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc17key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2016,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2016",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra16.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra16key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2016,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2016",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc16.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc16key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2015,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2015",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra15.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra15key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2015,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2015",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc15.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc15key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2014,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2014",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra14.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra14key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2014,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2014",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc14.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc14key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2013,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2013",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra13.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra13key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2013,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2013",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc13.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc13key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2012,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2012",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra12.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra12key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2012,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2012",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc12.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc12key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2011,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2011",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra11.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra11key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2011,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2011",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc11.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc11key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2010,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2010",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra10.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra10key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2010,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2010",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc10.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc10key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2009,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2009",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra09.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra09key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2009,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2009",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc09.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc09key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2008,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2008",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra08.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra08key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2008,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2008",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc08.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc08key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2007,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2007",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra07.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra07key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2007,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2007",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc07.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc07key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2006,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2006",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra06.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra06key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2006,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2006",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc06.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc06key.pdf"
  },
  {
   "e": "nbhm",
   "y": 2005,
   "g": "Doctoral",
   "t": "NBHM Doctoral Scholarship Test — 2005",
   "qp": "https://www.imsc.res.in/~nbhm/qp/nbhmra05.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/nbhmra05ans.pdf"
  },
  {
   "e": "nbhm",
   "y": 2005,
   "g": "Master's",
   "t": "NBHM M.A./M.Sc. Scholarship Test — 2005",
   "qp": "https://www.imsc.res.in/~nbhm/qp/msc05.pdf",
   "key": "https://www.imsc.res.in/~nbhm/qp/msc05key.pdf"
  },
  {
   "e": "isi",
   "y": 2026,
   "t": "ISI M.Math 2026 — question paper (open on ISI's page)",
   "qp": "https://admission.isical.ac.in/Programs/MMath.html",
   "n": "Opens ISI's official M.Math page; pick the year there."
  },
  {
   "e": "isi",
   "y": 2024,
   "t": "ISI M.Math 2024 — question paper (open on ISI's page)",
   "qp": "https://admission.isical.ac.in/Programs/MMath.html",
   "n": "Opens ISI's official M.Math page; pick the year there."
  },
  {
   "e": "isi",
   "y": 2023,
   "t": "ISI M.Math 2023 — question paper (open on ISI's page)",
   "qp": "https://admission.isical.ac.in/Programs/MMath.html",
   "n": "Opens ISI's official M.Math page; pick the year there."
  },
  {
   "e": "isi",
   "y": 2022,
   "t": "ISI M.Math 2022 — question paper (open on ISI's page)",
   "qp": "https://admission.isical.ac.in/Programs/MMath.html",
   "n": "Opens ISI's official M.Math page; pick the year there."
  },
  {
   "e": "isi",
   "y": 2020,
   "t": "ISI M.Math 2020 — question paper (open on ISI's page)",
   "qp": "https://admission.isical.ac.in/Programs/MMath.html",
   "n": "Opens ISI's official M.Math page; pick the year there."
  },
  {
   "e": "cmi",
   "y": 2026,
   "t": "CMI MSc/PhD Mathematics 2026",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2026.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2026-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2025,
   "t": "CMI MSc/PhD Mathematics 2025",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2025.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2025-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2024,
   "t": "CMI MSc/PhD Mathematics 2024",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2024.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2024-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2023,
   "t": "CMI MSc/PhD Mathematics 2023",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2023.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2023-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2022,
   "t": "CMI MSc/PhD Mathematics 2022",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2022.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2022-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2021,
   "t": "CMI MSc/PhD Mathematics 2021",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2021.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2021-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2020,
   "t": "CMI MSc/PhD Mathematics 2020",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2020.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2020-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2019,
   "t": "CMI MSc/PhD Mathematics 2019",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2019.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2019-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2018,
   "t": "CMI MSc/PhD Mathematics 2018",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2018.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2018-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2017,
   "t": "CMI MSc/PhD Mathematics 2017",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2017.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2017-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2016,
   "t": "CMI MSc/PhD Mathematics 2016",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2016.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2016-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2015,
   "t": "CMI MSc/PhD Mathematics 2015",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2015.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2015-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2014,
   "t": "CMI MSc/PhD Mathematics 2014",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2014.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2014-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2013,
   "t": "CMI MSc/PhD Mathematics 2013",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2013.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2013-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2012,
   "t": "CMI MSc/PhD Mathematics 2012",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2012.pdf",
   "key": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2012-solutions.pdf"
  },
  {
   "e": "cmi",
   "y": 2011,
   "t": "CMI MSc/PhD Mathematics 2011",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2011.pdf"
  },
  {
   "e": "cmi",
   "y": 2010,
   "t": "CMI MSc/PhD Mathematics 2010",
   "qp": "https://www.cmi.ac.in/admissions/sample-qp/pgmath2010.pdf"
  }
 ],
 "pyqPortals": {
  "jam": {
   "url": "https://jam.iitkgp.ac.in/download.html",
   "label": "JAM official downloads"
  },
  "cuetpg": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) official page"
  },
  "tifr": {
   "url": "https://www.tifr.res.in/academics/",
   "label": "TIFR Graduate School official page"
  },
  "gate": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "csir": {
   "url": "https://csirnet.nta.nic.in/archive/",
   "label": "NTA CSIR NET archive"
  },
  "nbhm": {
   "url": "https://www.imsc.res.in/~nbhm/qp/",
   "label": "NBHM official repository"
  },
  "isi": {
   "url": "https://admission.isical.ac.in/Programs/MMath.html",
   "label": "ISI M.Math official page"
  },
  "cmi": {
   "url": "https://www.cmi.ac.in/admissions/syllabus.php",
   "label": "CMI official past papers page"
  },
  "jam-ph": {
   "url": "https://jam.iitkgp.ac.in/download.html",
   "label": "IIT JAM Physics — official previous papers"
  },
  "jam-cy": {
   "url": "https://jam.iitkgp.ac.in/download.html",
   "label": "IIT JAM Chemistry — official previous papers"
  },
  "jam-bt": {
   "url": "https://jam.iitkgp.ac.in/download.html",
   "label": "IIT JAM Biotechnology — official previous papers"
  },
  "jam-en": {
   "url": "https://jam.iitkgp.ac.in/download.html",
   "label": "IIT JAM Economics — official previous papers"
  },
  "jam-gg": {
   "url": "https://jam.iitkgp.ac.in/download.html",
   "label": "IIT JAM Geology — official previous papers"
  },
  "jam-ms": {
   "url": "https://jam.iitkgp.ac.in/download.html",
   "label": "IIT JAM Mathematical Statistics — official previous papers"
  },
  "cuetpg-ph": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Physics — official page"
  },
  "cuetpg-cy": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Chemistry — official page"
  },
  "cuetpg-bt": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Biotechnology — official page"
  },
  "cuetpg-bc": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Biochemistry — official page"
  },
  "cuetpg-bo": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Botany — official page"
  },
  "cuetpg-zo": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Zoology — official page"
  },
  "cuetpg-mb": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Microbiology — official page"
  },
  "cuetpg-st": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Statistics — official page"
  },
  "cuetpg-cs": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Computer Science — official page"
  },
  "cuetpg-es": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Environmental Science — official page"
  },
  "cuetpg-gg": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Geology — official page"
  },
  "cuetpg-en": {
   "url": "https://exams.nta.nic.in/cuet-pg/",
   "label": "NTA CUET (PG) Economics — official page"
  },
  "tifr-ph": {
   "url": "https://www.tifr.res.in/academics/",
   "label": "TIFR GS Physics — official page"
  },
  "tifr-cy": {
   "url": "https://www.tifr.res.in/academics/",
   "label": "TIFR GS Chemistry — official page"
  },
  "tifr-bg": {
   "url": "https://www.tifr.res.in/academics/",
   "label": "TIFR GS Biology — official page"
  },
  "tifr-cs": {
   "url": "https://www.tifr.res.in/academics/",
   "label": "TIFR GS Computer Science — official page"
  },
  "tifr-se": {
   "url": "https://www.tifr.res.in/academics/",
   "label": "TIFR GS Science Education — official page"
  },
  "gate-ph": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Physics — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "gate-cy": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Chemistry — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "gate-bt": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Biotechnology — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "gate-ls": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Life Sciences — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "gate-gg": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Geology — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "gate-st": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Statistics — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "gate-xh": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Humanities & Social Sciences — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "gate-ey": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Ecology & Evolution — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "gate-da": {
   "url": "https://gate2027.iitm.ac.in/download",
   "label": "GATE Data Science & AI — official downloads",
   "more": "https://drive.google.com/drive/folders/1xUn7rGTzKlfvJDoo4SzCRi8jRlBD63ud?usp=sharing",
   "moreLabel": "All GATE papers 2007–2026 (official bulk folder)"
  },
  "csir-pys": {
   "url": "https://csirnet.nta.nic.in/archive/",
   "label": "NTA CSIR NET Physical Sciences — archive"
  },
  "csir-chs": {
   "url": "https://csirnet.nta.nic.in/archive/",
   "label": "NTA CSIR NET Chemical Sciences — archive"
  },
  "csir-ls": {
   "url": "https://csirnet.nta.nic.in/archive/",
   "label": "NTA CSIR NET Life Sciences — archive"
  },
  "csir-eas": {
   "url": "https://csirnet.nta.nic.in/archive/",
   "label": "NTA CSIR NET Earth, Atmospheric, Ocean & Planetary Sciences — archive"
  }
 },
 "mocks": [
  {
   "id": "jam-full-1",
   "e": "jam",
   "s": "full",
   "t": "IIT JAM Mathematics — Full Length Mock 1",
   "q": 12,
   "min": 30
  }
 ]
};
