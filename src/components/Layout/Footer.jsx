import { Stethoscope, Phone, Mail, MapPin, Facebook, Twitter, Instagram } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

export default function Footer() {
  const { t } = useLanguage();

  return (
    <>
      <footer className="footer">
        <div className="container">
          <div className="footer-content">
            {/* Company Info */}
            <div className="footer-section">
              <div className="flex items-center space-x-2" style={{ marginBottom: '1rem' }}>
                <div className="logo-icon">
                  <Stethoscope size={20} />
                </div>
                <span style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>Nabha Healthcare</span>
              </div>
              <p style={{ marginBottom: '1rem' }}>
                {t('missionText')}
              </p>
              <div className="flex space-x-4">
                <a href="#" className="social-icon facebook">
                  <Facebook size={20} />
                  <span className="sr-only">Facebook</span>
                </a>
                <a href="#" className="social-icon twitter">
                  <Twitter size={20} />
                  <span className="sr-only">Twitter</span>
                </a>
                <a href="#" className="social-icon instagram">
                  <Instagram size={20} />
                  <span className="sr-only">Instagram</span>
                </a>
              </div>
            </div>

          {/* Quick Links */}
          <div className="footer-section">
            <h3>Quick Links</h3>
            <ul className="footer-links">
              <li><a href="/doctors">{t('doctors')}</a></li>
              <li><a href="/records">{t('records')}</a></li>
              <li><a href="/pharmacy">{t('pharmacy')}</a></li>
              <li><a href="/symptoms">{t('symptoms')}</a></li>
              <li><a href="/about">{t('about')}</a></li>
            </ul>
          </div>

          {/* Contact Info */}
          <div className="footer-section">
            <h3>Contact Us</h3>
            <div className="space-y-4">
              <div className="flex items-center space-x-2">
                <MapPin size={16} style={{ color: 'var(--primary-400)' }} />
                <span>Nabha, Punjab, India</span>
              </div>
              <div className="flex items-center space-x-2">
                <Phone size={16} style={{ color: 'var(--primary-400)' }} />
                <span>+91 123 456 7890</span>
              </div>
              <div className="flex items-center space-x-2">
                <Mail size={16} style={{ color: 'var(--primary-400)' }} />
                <span>contact@nabhahealthcare.com</span>
              </div>
            </div>
          </div>
        </div>

        <div className="footer-bottom">
          <p>© 2025 Nabha Healthcare Solution. All rights reserved.</p>
        </div>
      </div>
    </footer>

    <style>{`
      .social-icon {
        width: 40px;
        height: 40px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        text-decoration: none;
      }

      .social-icon.facebook {
        background-color: #1877f2;
        color: white;
      }

      .social-icon.facebook:hover {
        background-color: #166fe5;
        transform: translateY(-2px);
      }

      .social-icon.twitter {
        background-color: #1da1f2;
        color: white;
      }

      .social-icon.twitter:hover {
        background-color: #1a91da;
        transform: translateY(-2px);
      }

      .social-icon.instagram {
        background: linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%);
        color: white;
      }

      .social-icon.instagram:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(188, 24, 136, 0.3);
      }
    `}</style>
    </>
  );
}