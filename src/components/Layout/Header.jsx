import { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, Globe, Stethoscope } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isLanguageOpen, setIsLanguageOpen] = useState(false);
  const { t, currentLanguage, changeLanguage } = useLanguage();
  const location = useLocation();

  const navigation = [
    { name: t('home'), href: '/', key: 'home' },
    { name: t('doctors'), href: '/doctors', key: 'doctors' },
    { name: 'Hospitals', href: '/hospitals', key: 'hospitals' },
    { name: t('records'), href: '/records', key: 'records' },
    { name: t('pharmacy'), href: '/pharmacy', key: 'pharmacy' },
    { name: t('symptoms'), href: '/symptoms', key: 'symptoms' },
    { name: t('about'), href: '/about', key: 'about' },
  ];

  const languages = [
    { code: 'en', name: 'English', flag: '🇺🇸' },
    { code: 'hi', name: 'हिंदी', flag: '🇮🇳' },
    { code: 'pa', name: 'ਪੰਜਾਬੀ', flag: '🇮🇳' },
  ];

  return (
    <header className="header">
      <div className="header-content">
        {/* Logo */}
        <Link to="/" className="logo">
          <div className="logo-icon">
            <Stethoscope size={20} />
          </div>
          <span>Nabha Healthcare</span>
        </Link>

        {/* Desktop Navigation */}
        <nav className="nav">
          {navigation.map((item) => (
            <Link
              key={item.key}
              to={item.href}
              className={`nav-link ${location.pathname === item.href ? 'active' : ''}`}
            >
              {item.name}
            </Link>
          ))}
        </nav>

        {/* Language Selector & Mobile Menu */}
        <div className="flex items-center space-x-4">
          {/* Language Dropdown */}
          <div className="language-selector">
            <button
              onClick={() => setIsLanguageOpen(!isLanguageOpen)}
              className="language-btn"
            >
              <Globe size={16} />
              <span className="hidden sm:block">
                {languages.find(lang => lang.code === currentLanguage)?.name}
              </span>
            </button>
            
            {isLanguageOpen && (
              <div className="language-dropdown">
                {languages.map((language) => (
                  <button
                    key={language.code}
                    onClick={() => {
                      changeLanguage(language.code);
                      setIsLanguageOpen(false);
                    }}
                    className={`language-option ${
                      currentLanguage === language.code ? 'active' : ''
                    }`}
                  >
                    <span>{language.flag}</span> {language.name}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Mobile menu button */}
          <button
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="mobile-menu-btn"
          >
            {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {/* Mobile Navigation */}
        <nav className={`mobile-nav ${isMenuOpen ? 'open' : ''}`}>
          {navigation.map((item) => (
            <Link
              key={item.key}
              to={item.href}
              onClick={() => setIsMenuOpen(false)}
              className={`nav-link ${location.pathname === item.href ? 'active' : ''}`}
            >
              {item.name}
            </Link>
          ))}
        </nav>
      </div>
      
      {/* Click outside to close language dropdown */}
      {isLanguageOpen && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 40
          }}
          onClick={() => setIsLanguageOpen(false)}
        />
      )}
    </header>
  );
}