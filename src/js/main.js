// Language handling
let currentLanguage = 'en';
let translations = {};

// Show loading indicator
function showLoading() {
    document.getElementById('loading').classList.add('show');
}

// Hide loading indicator
function hideLoading() {
    document.getElementById('loading').classList.remove('show');
}

// Toggle language dropdown
function toggleLanguageList() {
    document.getElementById('languageList').classList.toggle('show');
}

// Close language dropdown when clicking outside
document.addEventListener('click', (event) => {
    const languageSelector = document.getElementById('languageSelector');
    const languageList = document.getElementById('languageList');
    
    if (!languageSelector.contains(event.target)) {
        languageList.classList.remove('show');
    }
});

// Render page content
async function renderContent(translation) {
    const content = document.getElementById('content');
    content.innerHTML = `
        <h1>${translation.title}</h1>
        
        <div class="info-box">
            ${translation.notice.text}
        </div>

        <div class="warning-box">
            ${translation.md5_notice.text}
        </div>

        <div class="section-box">
            <h2>${translation.bandwidth_notice.title}</h2>
            <p>${translation.bandwidth_notice.text}</p>
            <p>${translation.bandwidth_notice.contact_info}</p>
        </div>

        <div class="section-box">
            <h2>${translation.sponsorship.title}</h2>
            <p>${translation.sponsorship.text}</p>
            <p>${translation.sponsorship.benefits}</p>
            <p>${translation.sponsorship.usage}</p>
        </div>

        <div class="section-box">
            <h2>Download Links for Apache Ambari 3.0.0</h2>
            <ul>
                <li><a href="/dist/ambari/3.0.0/rocky8/">Rocky Linux 8 Package Download For Ambari </a></li>
                <li><a href="/dist/ambari/3.0.0/rocky9/">Rocky Linux 9 Package Download For Ambari </a></li>
            </ul>

            <h2>Apache Ambari 3.0.0 MD5 Checksums</h2>
            <p>For security purposes, you can verify the integrity of the downloaded files using MD5 checksums.</p>
            <ul>
                <li><a href="/dist/ambari/3.0.0/rocky8/MD5SUMS.txt">View MD5 Checksums - Rocky Linux 8</a></li>
                <li><a href="/dist/ambari/3.0.0/rocky9/MD5SUMS.txt">View MD5 Checksums - Rocky Linux 9</a></li>
            </ul>

            <h2>Download Links for Apache Ambari Bigtop stack 3.0.0</h2>
            <ul>
                <li><a href="/dist/bigtop//3.3.0/rocky8/">Rocky Linux 8 Package Download For Bigtop Stack</a></li>
                <li><a href="/dist/bigtop//3.3.0/rocky9/">Rocky Linux 9 Package Download For Bigtop Stack</a></li>
            </ul>

            <h2>Apache Ambari Bigtop stack 3.0.0 MD5 Checksums</h2>
            <p>For security purposes, you can verify the integrity of the downloaded files using MD5 checksums.</p>
            <ul>
                <li><a href="/dist/bigtop/3.3.0/rocky8/md5sums.txt">View MD5 Checksums - Rocky Linux 8</a></li>
                <li><a href="/dist/bigtop/3.3.0/rocky9/md5sums.txt">View MD5 Checksums - Rocky Linux 9</a></li>
            </ul>
        </div>

        <h2>${translation.repository.title}</h2>
        
        <h3>${translation.repository.step1.title}</h3>
        <pre><code>${translation.repository.step1.command}</code></pre>
        
        <h3>${translation.repository.step2.title}</h3>
        <pre><code>${translation.repository.step2.command}</code></pre>
        
        <h3>${translation.repository.step3.title}</h3>
        <pre><code>${translation.repository.step3.command}</code></pre>
        
        <h3>${translation.repository.step4.title}</h3>
        <pre><code>${translation.repository.step4.command}</code></pre>
        

        <h2>${translation.notes.title}</h2>
        <ul>
            <li>${translation.notes.items[0]}</li>
            <li>${translation.notes.items[1]}</li>
            <li>${translation.notes.items[2]}</li>
        </ul>

        <h2>${translation.feedback.title}</h2>
        <p>${translation.feedback.text}</p>
        <ul>
            <li>${translation.feedback.jira}</li>
            <li>${translation.feedback.mailing_list}</li>
        </ul>

        <p>${translation.footer}</p>
    `;
}

// Load translation file
async function loadTranslation(lang) {
    try {
        showLoading();
        const response = await fetch(`translations/${lang}.json`);
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        const translation = await response.json();
        translations[lang] = translation;
        return translation;
    } catch (error) {
        console.error('Error loading translation:', error);
        return null;
    } finally {
        hideLoading();
    }
}

// Change language
async function changeLanguage(lang) {
    if (currentLanguage === lang) return;
    
    const translation = translations[lang] || await loadTranslation(lang);
    if (!translation) {
        console.error(`Failed to load translation for ${lang}`);
        return;
    }
    
    currentLanguage = lang;
    document.getElementById('languageList').classList.remove('show');
    document.getElementById('selectedLanguage').textContent = lang.toUpperCase();
    
    await renderContent(translation);
}

// Initialize language selector
async function initializeLanguageSelector() {
    const defaultTranslation = await loadTranslation('en');
    if (defaultTranslation) {
        await renderContent(defaultTranslation);
    }
    
    // Get browser language
    const browserLang = navigator.language.split('-')[0];
    if (browserLang !== 'en') {
        const translation = await loadTranslation(browserLang);
        if (translation) {
            currentLanguage = browserLang;
            document.getElementById('selectedLanguage').textContent = browserLang.toUpperCase();
            await renderContent(translation);
        }
    }
}

// Initialize the page
document.addEventListener('DOMContentLoaded', () => {
    initializeLanguageSelector();
}); 