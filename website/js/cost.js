// Simple cost simulator logic using Chart.js
const vmCosts = { B1s: 10, D2s_v3: 50, E4s_v3: 100 };
const storageCosts = { Standard_HDD: 0.05, Standard_SSD: 0.1, Premium_SSD: 0.2 };
let chart;

function renderChart(data){
  const ctx = document.getElementById('costChart');
  if(!ctx) return;
  if(chart) chart.destroy();
  chart = new Chart(ctx, {
    type:'bar',
    data: { labels:['VM','Traffic','Storage'], datasets:[{data, backgroundColor:['#4e79a7','#f28e2b','#e15759']}] },
    options:{ plugins:{ legend:{display:false}, title:{display:true,text:'Estimated Monthly Cost ($)'}} }
  });
}

function calculateAndShow(){
  const vm = document.getElementById('vmType').value;
  const traffic = parseInt(document.getElementById('traffic').value);
  const storage = document.getElementById('storage').value;
  document.getElementById('trafficVal').textContent = traffic;
  const vmCost = vmCosts[vm];
  const trafficCost = parseFloat((traffic * 0.02).toFixed(2));
  const storageCost = parseFloat((100 * storageCosts[storage]).toFixed(2));
  const total = (vmCost + trafficCost + storageCost).toFixed(2);
  renderChart([vmCost, trafficCost, storageCost]);
  const recs = document.getElementById('recomms');
  recs.innerHTML = '';
  if(vm === 'E4s_v3' && traffic < 2000) recs.innerHTML += '<li>Consider downsizing VM</li>';
  if(storage === 'Premium_SSD' && traffic < 1500) recs.innerHTML += '<li>Switch to Standard SSD</li>';
  if(traffic > 5000) recs.innerHTML += '<li>Use CDN to reduce outbound cost</li>';
  recs.innerHTML += '<li>Total est. $'+ total + ' / month</li>';
}

document.addEventListener('DOMContentLoaded', function(){
  if(document.getElementById('calcBtn')) document.getElementById('calcBtn').addEventListener('click', calculateAndShow);
  if(document.getElementById('traffic')){
    const t = document.getElementById('traffic'); const v = document.getElementById('trafficVal');
    t.addEventListener('input', ()=> v.textContent = t.value);
  }
  if(document.getElementById('calcBtn')) calculateAndShow();
});
