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

// Load translation file
async function loadTranslation(lang) {
    try {
        showLoading();
        const response = await fetch(`/translations/${lang}.json`);
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