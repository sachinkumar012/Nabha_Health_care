import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { Heart, Users, Shield, Clock, ArrowRight, Building2 } from 'lucide-react';
import { useLanguage } from '../context/LanguageContext';
import AppointmentChatBot from '../components/AppointmentChatBot';
import AnimatedCounter from '../components/UI/AnimatedCounter';
import { nabhaHospitals } from '../data/hospitalsData';

export default function Home() {
  const { t } = useLanguage();

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
    </div>
  );
}