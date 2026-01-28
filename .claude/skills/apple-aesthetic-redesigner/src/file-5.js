// Intersection Observer for reveal animations
const observerOptions = {
  root: null,
  rootMargin: '0px',
  threshold: 0.1
};

const revealAnimation = (entries, observer) => {
  entries.forEach((entry, index) => {
    if (entry.isIntersecting) {
      entry.target.style.animation = `revealUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) ${index * 0.1}s forwards`;
      observer.unobserve(entry.target);
    }
  });
};

const observer = new IntersectionObserver(revealAnimation, observerOptions);

document.querySelectorAll('.reveal-on-scroll').forEach(el => {
  el.style.opacity = '0';
  el.style.transform = 'translateY(30px)';
  observer.observe(el);
});

// CSS for reveal animation
const revealStyles = `
@keyframes revealUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
`;
