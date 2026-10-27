// Mock test questions. Add a test here and list it in data.js -> mocks.
// Question format: s=section, t=MCQ|MSQ|NAT, m=marks, q=question, o=options, a=answer index list (MCQ/MSQ) or [min,max] (NAT), e=solution. Math: $...$ (use \\ for backslash)
window.ES_MOCKS={
'jam-full-1':{cfg:{title:'IIT JAM Mathematics (MA) — Mock Test 1',minutes:30,secs:{A:'Section A (MCQ)',B:'Section B (MSQ)',C:'Section C (NAT)'}},
q:[
{s:'A',t:'MCQ',m:1,q:'The value of $\\displaystyle\\lim_{x\\to0}\\frac{\\sin x-x\\cos x}{x^{3}}$ is',o:['$1/6$','$1/3$','$1/2$','$1/12$'],a:[1],e:'$\\sin x=x-\\frac{x^3}{6}+\\dots$ and $x\\cos x=x-\\frac{x^3}{2}+\\dots$, so the numerator behaves like $\\frac{x^3}{3}$.'},
{s:'A',t:'MCQ',m:1,q:'Which of the following series converges?',o:['$\\sum_{n\\ge2}\\frac{1}{n\\ln n}$','$\\sum_{n\\ge1}\\frac{1}{\\sqrt n}$','$\\sum_{n\\ge2}\\frac{1}{n(\\ln n)^2}$','$\\sum_{n\\ge1}\\frac{n}{n+1}$'],a:[2],e:'Integral test: $\\int\\frac{dx}{x(\\ln x)^2}$ converges; the other three diverge.'},
{s:'A',t:'MCQ',m:2,q:'If $y^{\\prime}+y=e^{-x}$ and $y(0)=1$, then $y(1)$ equals',o:['$1/e$','$2/e$','$3/e$','$e$'],a:[1],e:'Integrating factor $e^x$: $(ye^x)^{\\prime}=1\\Rightarrow y=(x+1)e^{-x}$, so $y(1)=2/e$.'},
{s:'A',t:'MCQ',m:2,q:'Let $A$ be a $3\\times3$ real matrix with eigenvalues $1,2,3$. Then $\\det(A^{-1}+I)$ equals',o:['$2$','$4$','$6$','$8$'],a:[1],e:'Eigenvalues of $A^{-1}+I$ are $2,\\frac32,\\frac43$; their product is $4$.'},
{s:'A',t:'MCQ',m:2,q:'The number of elements of order $4$ in the group $\\mathbb Z_4\\times\\mathbb Z_4$ is',o:['$4$','$8$','$12$','$16$'],a:[2],e:'Elements of order dividing $2$ form $\\{0,2\\}^2$ (4 elements). Hence $16-4=12$.'},
{s:'B',t:'MSQ',m:2,q:'Which of the following subsets of $\\mathbb R$ are compact?',o:['$[0,1]\\cup\\{2\\}$','$\\mathbb Q\\cap[0,1]$','$\\{1/n:n\\ge1\\}\\cup\\{0\\}$','$(0,1]$'],a:[0,2],e:'Heine–Borel: closed and bounded. $\\mathbb Q\\cap[0,1]$ and $(0,1]$ are not closed.'},
{s:'B',t:'MSQ',m:2,q:'Let $A$ be a real $n\\times n$ matrix with $A^2=A$. Which of the following are TRUE?',o:['Every eigenvalue of $A$ is $0$ or $1$','$A$ is diagonalizable','$I-A$ is also idempotent','$A$ is invertible'],a:[0,1,2],e:'Minimal polynomial divides $x(x-1)$ (distinct roots), $(I-A)^2=I-A$. $A=0$ is not invertible.'},
{s:'B',t:'MSQ',m:2,q:'Which of the following functions are entire?',o:['$e^{z^2}$','$\\frac{1}{1+z^2}$','$|z|^2$','$z^3-3z+\\cos z$'],a:[0,3],e:'$\\frac1{1+z^2}$ has poles at $\\pm i$; $|z|^2$ fails the Cauchy–Riemann equations away from $0$.'},
{s:'C',t:'NAT',m:1,q:'The value of $\\displaystyle\\sum_{n=1}^{\\infty}\\frac{1}{n(n+2)}$ is ______ (rounded to two decimal places).',a:[0.75,0.75],e:'$\\frac12\\left(\\frac1n-\\frac1{n+2}\\right)$ telescopes to $\\frac12\\left(1+\\frac12\\right)=0.75$.'},
{s:'C',t:'NAT',m:1,q:'The rank of the matrix $\\begin{pmatrix}1&2&3\\\\2&4&6\\\\1&0&1\\end{pmatrix}$ is ______.',a:[2,2],e:'Row 2 = 2 × Row 1, while Rows 1 and 3 are independent. Rank $=2$.'},
{s:'C',t:'NAT',m:2,q:'Let $y^{\\prime\\prime}-3y^{\\prime}+2y=0$, $y(0)=0$, $y^{\\prime}(0)=1$. Then $y(\\ln 2)=$ ______.',a:[2,2],e:'$y=e^{2x}-e^{x}$, so $y(\\ln2)=4-2=2$.'},
{s:'C',t:'NAT',m:2,q:'The value of $\\dfrac{1}{2\\pi i}\\displaystyle\\oint_{|z|=2}\\dfrac{e^{z}}{z(z-1)}\\,dz$ is ______ (rounded to two decimal places).',a:[1.71,1.72],e:'Residue at $0$ is $-1$, at $1$ is $e$. Sum $=e-1\\approx1.72$.'}
]}
};
