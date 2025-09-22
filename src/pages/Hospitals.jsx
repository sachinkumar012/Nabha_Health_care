import React, { useState, useMemo } from 'react';
import { 
  MapPin, 
  Phone, 
  Clock, 
  Star, 
  Search, 
  Filter,
  Navigation,
  Heart,
  Building2,
  Shield,
  PhoneCall,
  AlertCircle,
  CheckCircle,
  MessageCircle,
  Users,
  ExternalLink,
  ArrowRight
} from 'lucide-react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { 
  nabhaHospitals, 
  hospitalCategories, 
  emergencyContacts,
  nabhaAreas,
  getHospitalsByType,
  getHospitalsByArea,
  searchHospitals 
} from '../data/hospitalsData';
import AnimatedCounter from '../components/UI/AnimatedCounter';

const Hospitals = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All Hospitals');
  const [selectedArea, setSelectedArea] = useState('All Areas');
  const [showEmergency, setShowEmergency] = useState(false);

  // Filter hospitals based on search, category, and area
  const filteredHospitals = useMemo(() => {
    let hospitals = nabhaHospitals;
    
    // Apply search filter
    if (searchQuery.trim()) {
      hospitals = searchHospitals(searchQuery);
    }
    
    // Apply category filter
    if (selectedCategory !== 'All Hospitals') {
      hospitals = hospitals.filter(hospital => hospital.type === selectedCategory);
    }
    
    // Apply area filter
    if (selectedArea !== 'All Areas') {
      hospitals = hospitals.filter(hospital => hospital.area === selectedArea);
    }
    
    return hospitals;
  }, [searchQuery, selectedCategory, selectedArea]);

  const handleCall = (phone) => {
    window.open(`tel:${phone}`, '_self');
  };

  const handleGetDirections = (hospital) => {
    const query = encodeURIComponent(`${hospital.name}, ${hospital.address}`);
    window.open(`https://www.google.com/maps/search/?api=1&query=${query}`, '_blank');
  };

  return (
    <div className="min-h-screen bg-light" style={{ paddingTop: '5rem', paddingBottom: '4rem' }}>
      <div className="container">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center"
          style={{ marginBottom: '3rem' }}
        >
          <h1>Healthcare Facilities in Nabha</h1>
          <p className="text-gray-600">
            Find trusted hospitals and medical centers in Nabha with comprehensive healthcare services
          </p>
        </motion.div>

        <div className="grid grid-md-2 gap-8">
          {filteredHospitals.map((hospital, index) => (
            <motion.div
              key={hospital.id}
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              className="doctor-card"
            >
              {/* Hospital Header */}
              <div className="doctor-header">
                <div className="doctor-avatar" style={{ 
                  width: '5rem', 
                  height: '5rem', 
                  borderRadius: '50%', 
                  background: 'linear-gradient(135deg, var(--primary-500) 0%, var(--primary-600) 100%)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: 'white',
                  border: '3px solid var(--primary-100)',
                  transition: 'all 0.3s ease'
                }}>
                  <Building2 className="w-8 h-8" />
                </div>
                
                <div className="doctor-info" style={{ flex: 1 }}>
                  <div className="flex justify-between items-center" style={{ marginBottom: '0.5rem' }}>
                    <h3>{hospital.name}</h3>
                    <div className="availability-badge available">
                      <CheckCircle size={12} />
                      <span>Open</span>
                    </div>
                  </div>
                  
                  <p className="doctor-specialization">{hospital.type}</p>
                  
                  <div className="doctor-meta">
                    <span>
                      <Star size={16} style={{ color: '#fbbf24', fill: 'currentColor' }} />
                      <span style={{ marginLeft: '0.25rem' }}>{hospital.rating}</span>
                    </span>
                    <span>
                      <MapPin size={16} />
                      {hospital.area}
                    </span>
                  </div>
                  
                  <div className="flex items-center text-gray-600" style={{ fontSize: '0.875rem', marginBottom: '0.75rem' }}>
                    <Clock size={16} style={{ marginRight: '0.25rem' }} />
                    <span>24/7 Emergency Services</span>
                  </div>
                </div>
              </div>
              
              {/* Hospital Specialties (like doctor languages) */}
              <div className="doctor-languages">
                {hospital.specialties.slice(0, 3).map((specialty, idx) => (
                  <span key={idx} className="language-tag">
                    {specialty}
                  </span>
                ))}
                {hospital.specialties.length > 3 && (
                  <span className="language-tag" style={{ background: 'var(--gray-500)' }}>
                    +{hospital.specialties.length - 3}
                  </span>
                )}
              </div>

              {/* Hospital Services */}
              <div style={{ marginBottom: 'var(--space-4)' }}>
                <h4 style={{ 
                  fontSize: '0.875rem', 
                  fontWeight: '700', 
                  color: 'var(--gray-700)', 
                  marginBottom: 'var(--space-2)',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em'
                }}>
                  Services
                </h4>
                <div className="flex flex-wrap gap-2">
                  {hospital.services.slice(0, 4).map((service, idx) => (
                    <span
                      key={idx}
                      style={{
                        background: 'var(--gray-100)',
                        color: 'var(--gray-700)',
                        padding: 'var(--space-1) var(--space-2)',
                        borderRadius: '0.5rem',
                        fontSize: '0.75rem',
                        fontWeight: '600'
                      }}
                    >
                      {service}
                    </span>
                  ))}
                  {hospital.services.length > 4 && (
                    <span style={{
                      background: 'var(--gray-200)',
                      color: 'var(--gray-600)',
                      padding: 'var(--space-1) var(--space-2)',
                      borderRadius: '0.5rem',
                      fontSize: '0.75rem',
                      fontWeight: '600'
                    }}>
                      +{hospital.services.length - 4} more
                    </span>
                  )}
                </div>
              </div>

              {/* Contact Info */}
              {hospital.phones.length > 0 && (
                <div style={{ marginBottom: 'var(--space-4)' }}>
                  <h4 style={{ 
                    fontSize: '0.875rem', 
                    fontWeight: '700', 
                    color: 'var(--gray-700)', 
                    marginBottom: 'var(--space-2)',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em'
                  }}>
                    Contact
                  </h4>
                  <div className="space-y-1">
                    {hospital.phones.slice(0, 2).map((phone, idx) => (
                      <div key={idx} className="flex items-center gap-2 text-sm">
                        <Phone size={14} className="text-gray-400" />
                        <span className="text-gray-700 font-semibold">{phone}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
              
              {/* Action Buttons (same style as doctors) */}
              <div className="doctor-actions" style={{ pointerEvents: 'auto', position: 'relative', zIndex: 10 }}>
                {hospital.primaryPhone && (
                  <motion.a
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    href={`tel:${hospital.primaryPhone}`}
                    className="btn btn-primary"
                    style={{
                      flex: 1,
                      backgroundColor: 'var(--primary-500)',
                      color: 'white',
                      cursor: 'pointer',
                      marginRight: '0.5rem',
                      pointerEvents: 'auto',
                      textDecoration: 'none',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    <Phone size={16} style={{ marginRight: '0.5rem' }} />
                    <span>Call Now</span>
                  </motion.a>
                )}
                
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => handleGetDirections(hospital)}
                  className="btn btn-secondary"
                  style={{
                    flex: 1,
                    backgroundColor: 'var(--secondary-500)',
                    color: 'white',
                    cursor: 'pointer',
                    marginRight: '0.5rem'
                  }}
                >
                  <Navigation size={16} style={{ marginRight: '0.5rem' }} />
                  <span>Directions</span>
                </motion.button>
                
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => {
                    const message = encodeURIComponent(`Hello, I need information about ${hospital.name} in Nabha.`);
                    window.open(`https://wa.me/918264851226?text=${message}`, '_blank');
                  }}
                  className="btn btn-outline"
                  style={{ padding: '0.75rem' }}
                >
                  <MessageCircle size={16} />
                </motion.button>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Hospitals;