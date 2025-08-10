// small common helpers: activate nav link, smooth anchors
document.addEventListener('DOMContentLoaded', function(){
  document.querySelectorAll('a.nav-link').forEach(a=>{
    try {
      const href = a.getAttribute('href');
      const current = location.pathname.split('/').pop() || 'index.html';
      if(href === current) a.classList.add('text-azure','font-semibold');
    } catch(e){}
  });
});
