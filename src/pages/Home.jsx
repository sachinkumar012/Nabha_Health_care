import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { Heart, Users, Shield, Clock, ArrowRight, Building2, Video, Pill, Stethoscope, Search, Calendar, FileText } from 'lucide-react';
import { useLanguage } from '../context/LanguageContext';
import AppointmentChatBot from '../components/AppointmentChatBot';
import AnimatedCounter from '../components/UI/AnimatedCounter';
import { nabhaHospitals } from '../data/hospitalsData';
import videocallImage from '../assets/videocall.jpg';
import pharmacyImage from '../assets/pharmacy.jpg';
import symptomImage from '../assets/chat-img.png';
import hospitalImage from '../assets/hospital.jpg';
import healthRecordImage from '../assets/health record.webp';
import appointmentImage from '../assets/appointment.jpg';

export default function Home() {
  const { t } = useLanguage();

  const facilities = [
    {
      icon: Video,
      title: 'Video Consultation',
      description: 'Connect with doctors remotely through secure video calls for instant medical advice.',
      image: videocallImage,
      isImageFile: true,
      link: '/doctors',
      color: 'bg-gradient-to-br from-blue-500 to-blue-600'
    },
    {
      icon: Pill,
      title: 'Pharmacy Services',
      description: 'Order medicines online with home delivery and get expert pharmaceutical guidance.',
      image: pharmacyImage,
      isImageFile: true,
      link: '/pharmacy',
      color: 'bg-gradient-to-br from-green-500 to-green-600'
    },
    {
      icon: Search,
      title: 'Symptom Checker',
      description: 'AI-powered symptom analysis to help you understand your health conditions better.',
      image: symptomImage,
      isImageFile: true,
      link: '/symptom-checker',
      color: 'bg-gradient-to-br from-purple-500 to-purple-600'
    },
    {
      icon: Building2,
      title: 'Hospital Directory',
      description: 'Find nearby hospitals with complete information about services and facilities.',
      image: hospitalImage,
      isImageFile: true,
      link: '/hospitals',
      color: 'bg-gradient-to-br from-red-500 to-red-600'
    },
    {
      icon: Calendar,
      title: 'Appointment Booking',
      description: 'Schedule appointments with doctors at your convenience with easy online booking.',
      image: appointmentImage,
      isImageFile: true,
      link: '/doctors',
      color: 'bg-gradient-to-br from-indigo-500 to-indigo-600'
    },
    {
      icon: FileText,
      title: 'Health Records',
      description: 'Access and manage your medical records securely with offline backup capabilities.',
      image: healthRecordImage,
      isImageFile: true,
      link: '/health-records',
      color: 'bg-gradient-to-br from-teal-500 to-teal-600'
    }
  ];

  const features = [
    {
      icon: Heart,
      title: 'Expert Doctors',
      description: 'Connect with qualified doctors specializing in rural healthcare needs.',
    },
    {
      icon: Building2,
      title: 'Hospital Directory',
      description: 'Complete information about hospitals in Nabha with contact details and services.',
    },
    {
      icon: Users,
      title: 'Community Care',
      description: 'Healthcare solutions designed specifically for rural communities.',
    },
    {
      icon: Shield,
      title: 'Secure Records',
      description: 'Your health data is protected with offline backup capabilities.',
    },
    {
      icon: Clock,
      title: '24/7 Support',
      description: 'Access healthcare guidance and emergency support anytime.',
    },
  ];

  const stats = [
    { number: '500+', label: 'Patients Served' },
    { number: '50+', label: 'Expert Doctors' },
    { number: `${nabhaHospitals.length}+`, label: 'Hospitals Listed' },
    { number: '24/7', label: 'Support' },
  ];

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="hero">
        <div className="container">
          <div className="text-center">
            <motion.h1
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              {t('welcome')}
            </motion.h1>
            
            <motion.p
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="subtitle"
            >
              {t('subtitle')}
            </motion.p>
            
            <motion.p
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="description"
            >
              {t('description')}
            </motion.p>
            
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="flex flex-col sm:flex-row gap-4 justify-center items-center"
            >
              <Link to="/doctors" className="btn btn-primary group">
                {t('getStarted')}
                <ArrowRight 
                  size={20} 
                  className="ml-2 transition-transform group-hover:translate-x-1" 
                />
              </Link>
              <Link to="/about" className="btn btn-secondary">
                {t('learnMore') || 'Learn More'}
              </Link>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="stats">
        <div className="container">
          <div className="stats-grid">
            {stats.map((stat, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="stat-item"
              >
                <div className="stat-number">
                  <AnimatedCounter 
                    end={stat.number}
                    duration={2500}
                    delay={index * 200}
                  />
                </div>
                <div className="stat-label">{stat.label}</div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Facilities Section */}
      <section className="facilities">
        <div className="container">
          <div className="text-center" style={{ marginBottom: '4rem' }}>
            <motion.h2
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              Our Healthcare Services
            </motion.h2>
            <motion.p
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="text-gray-600"
              style={{ maxWidth: '600px', margin: '0 auto' }}
            >
              Comprehensive healthcare solutions designed for modern medical needs
            </motion.p>
          </div>
          
          <div className="facilities-grid">
            {facilities.map((facility, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="facility-card"
              >
                <Link to={facility.link} className="facility-link">
                  <div className={`facility-icon-wrapper ${facility.color}`}>
                    {facility.isImageFile ? (
                      <img 
                        src={facility.image} 
                        alt={facility.title}
                        className="facility-full-img"
                      />
                    ) : (
                      <>
                        <div className="facility-image">{facility.image}</div>
                        <facility.icon size={24} className="facility-icon" />
                      </>
                    )}
                  </div>
                  <div className="facility-content">
                    <h3 className="facility-title">{facility.title}</h3>
                    <p className="facility-description">{facility.description}</p>
                    <div className="facility-arrow">
                      <ArrowRight size={20} />
                    </div>
                  </div>
                </Link>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features">
        <div className="container">
          <div className="text-center" style={{ marginBottom: '4rem' }}>
            <h2>Why Choose Nabha Healthcare?</h2>
            <p className="text-gray-600" style={{ maxWidth: '600px', margin: '0 auto' }}>
              We understand the unique healthcare challenges in rural areas and provide tailored solutions.
            </p>
          </div>
          
          <div className="features-grid">
            {features.map((feature, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="feature-card"
              >
                <div className="feature-icon">
                  <feature.icon size={24} />
                </div>
                <h3>{feature.title}</h3>
                <p className="text-gray-600">{feature.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-primary" style={{ padding: '4rem 0', color: 'white' }}>
        <div className="container text-center">
          <h2 style={{ color: 'white', marginBottom: '1rem' }}>Ready to Get Started?</h2>
          <p style={{ fontSize: '1.25rem', marginBottom: '2rem', opacity: 0.9 }}>
            Join thousands of patients who trust Nabha Healthcare for their medical needs.
          </p>
          <Link to="/doctors" className="btn btn-secondary">
            Book Consultation
            <ArrowRight size={20} style={{ marginLeft: '0.5rem' }} />
          </Link>
        </div>
      </section>

      {/* Appointment ChatBot */}
      <AppointmentChatBot />

      <style>{`
        .facilities {
          padding: 4rem 0;
          background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        }

        .facilities-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 2rem;
          max-width: 1400px;
          margin: 0 auto;
        }

        @media (min-width: 1024px) {
          .facilities-grid {
            grid-template-columns: repeat(3, 1fr);
          }
        }

        .facility-card {
          background: white;
          border-radius: 20px;
          overflow: hidden;
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
          transition: all 0.3s ease;
          height: 100%;
        }

        .facility-card:hover {
          transform: translateY(-8px);
          box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .facility-link {
          display: block;
          text-decoration: none;
          color: inherit;
          height: 100%;
        }

        .facility-icon-wrapper {
          height: 200px;
          display: flex;
          align-items: center;
          justify-content: center;
          position: relative;
          overflow: hidden;
        }

        .facility-image {
          font-size: 4rem;
          position: absolute;
          top: 20px;
          left: 20px;
          z-index: 1;
        }

        .facility-img {
          width: 80px;
          height: 80px;
          object-fit: cover;
          border-radius: 12px;
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .facility-full-img {
          width: 100%;
          height: 100%;
          object-fit: cover;
          object-position: center;
          border-radius: 20px 20px 0 0;
        }

        .facility-icon {
          color: white;
          z-index: 2;
          filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
        }

        .facility-content {
          padding: 2rem;
          position: relative;
        }

        .facility-title {
          font-size: 1.5rem;
          font-weight: 700;
          margin-bottom: 1rem;
          color: #1a202c;
        }

        .facility-description {
          color: #4a5568;
          line-height: 1.6;
          margin-bottom: 1.5rem;
        }

        .facility-arrow {
          position: absolute;
          bottom: 2rem;
          right: 2rem;
          color: #3182ce;
          transition: transform 0.3s ease;
        }

        .facility-card:hover .facility-arrow {
          transform: translateX(4px);
        }

        @media (max-width: 768px) {
          .facilities {
            padding: 3rem 0;
          }

          .facilities-grid {
            grid-template-columns: 1fr;
            gap: 1.5rem;
            padding: 0 1rem;
          }

          .facility-card {
            border-radius: 16px;
          }

          .facility-icon-wrapper {
            height: 180px;
          }

          .facility-image {
            font-size: 3rem;
            top: 15px;
            left: 15px;
          }

          .facility-img {
            width: 60px;
            height: 60px;
          }

          .facility-full-img {
            border-radius: 16px 16px 0 0;
          }

          .facility-content {
            padding: 1.5rem;
          }

          .facility-title {
            font-size: 1.25rem;
          }

          .facility-description {
            font-size: 0.9rem;
          }
        }

        @media (max-width: 480px) {
          .facilities-grid {
            padding: 0 0.5rem;
          }

          .facility-icon-wrapper {
            height: 160px;
          }

          .facility-image {
            font-size: 2.5rem;
            top: 10px;
            left: 10px;
          }

          .facility-img {
            width: 50px;
            height: 50px;
          }

          .facility-full-img {
            border-radius: 16px 16px 0 0;
          }

          .facility-content {
            padding: 1.25rem;
          }
        }
      `}</style>
    </div>
  );
}