document.addEventListener('DOMContentLoaded', function() {
    // List of services to check
    const services = [
        { name: 'n8n', url: 'https://n8n.kwintes.cloud/healthz', selector: '.service-card.automation .status' },
        { name: 'openwebui', url: 'https://openwebui.kwintes.cloud/', selector: '.service-card.ai:nth-child(2) .status' },
        { name: 'flowise', url: 'https://flowise.kwintes.cloud/', selector: '.service-card.ai:nth-child(3) .status' },
        { name: 'supabase', url: 'https://supabase.kwintes.cloud/', selector: '.service-card.database:nth-child(4) .status' },
        { name: 'qdrant', url: 'https://qdrant.kwintes.cloud/healthz', selector: '.service-card.database:nth-child(5) .status' },
        { name: 'grafana', url: 'https://grafana.kwintes.cloud/', selector: '.service-card.monitoring:nth-child(6) .status' },
        { name: 'prometheus', url: 'https://prometheus.kwintes.cloud/-/healthy', selector: '.service-card.monitoring:nth-child(7) .status' },
        { name: 'ollama', url: 'https://ollama.kwintes.cloud/', selector: '.service-card.ai:nth-child(8) .status' },
        { name: 'searxng', url: 'https://searxng.kwintes.cloud/healthz', selector: '.service-card.search .status' }
    ];
    
    // Function to check service status
    function checkServiceStatus(service) {
        const statusElement = document.querySelector(service.selector);
        const indicator = statusElement.querySelector('.status-indicator');
        const statusText = statusElement.querySelector('span:last-child');
        
        // Make a fetch request with a timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 3000);
        
        fetch(service.url, { 
            method: 'GET',
            mode: 'no-cors', // Since we're crossing domains
            signal: controller.signal
        })
        .then(response => {
            clearTimeout(timeoutId);
            indicator.style.backgroundColor = 'var(--success)';
            statusText.textContent = 'Running';
        })
        .catch(error => {
            clearTimeout(timeoutId);
            indicator.style.backgroundColor = 'var(--danger)';
            statusText.textContent = 'Unavailable';
            console.error(`Error checking ${service.name}:`, error);
        });
    }
    
    // Check status of all services
    services.forEach(checkServiceStatus);
    
    // Refresh status every 60 seconds
    setInterval(() => {
        services.forEach(checkServiceStatus);
    }, 60000);
}); 