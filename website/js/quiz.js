// Quiz engine (reusable)
const qEl = document.getElementById('question');
const aEl = document.getElementById('answers');
const nextBtn = document.getElementById('nextBtn');
const resultEl = document.getElementById('result');
const quizArea = document.getElementById('quizArea');
const scoreEl = document.getElementById('score');
const badgeEl = document.getElementById('badge');
const restartBtn = document.getElementById('restart');
let idx = 0, score = 0;

function renderQuestion(){
  const cur = QUESTIONS[idx];
  qEl.textContent = `Q${idx+1}. ${cur.q}`;
  aEl.innerHTML = '';
  cur.opts.forEach((opt,i)=>{
    const btn = document.createElement('button');
    btn.className = 'w-full border rounded-lg py-2 text-left px-3 hover:bg-slate-100';
    btn.textContent = opt;
    btn.onclick = ()=> select(i);
    aEl.appendChild(btn);
  });
}

function select(i){
  const cur = QUESTIONS[idx];
  const correct = i === cur.correct;
  if(correct){ score++; confetti({particleCount:60,spread:50,origin:{y:0.6}}); }
  Array.from(aEl.children).forEach((b,j)=>{
    b.disabled = true;
    if(j === cur.correct) b.classList.add('bg-green-100');
    if(j === i && !correct) b.classList.add('bg-red-100');
  });
  nextBtn.classList.remove('hidden');
}

if(nextBtn) nextBtn.addEventListener('click', ()=>{
  idx++;
  if(idx < QUESTIONS.length){ nextBtn.classList.add('hidden'); renderQuestion(); }
  else finish();
});

function finish(){ quizArea.classList.add('hidden'); resultEl.classList.remove('hidden'); scoreEl.textContent = `You scored ${score}/${QUESTIONS.length}`; badgeEl.textContent = score > 3 ? 'Azure Pro' : 'Azure Learner'; }

if(restartBtn) restartBtn.addEventListener('click', ()=>{ idx = score = 0; resultEl.classList.add('hidden'); quizArea.classList.remove('hidden'); renderQuestion(); });

document.addEventListener('DOMContentLoaded', ()=>{ if(typeof QUESTIONS !== 'undefined') renderQuestion(); });
