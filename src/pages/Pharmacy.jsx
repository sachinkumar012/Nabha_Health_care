import  { useState, useEffect } from 'react';
import { Search, Plus, Edit3, User, Lock, Mail, Phone, Clock, MapPin, Package } from 'lucide-react';
import NabhaHealthIcon from '../components/UI/NabhaHealthIcon';
import IconShowcase from '../components/UI/IconShowcase';

const Pharmacy = () => {
  // State management
  const [medicines, setMedicines] = useState([
    {
      id: 1,
      name: 'Paracetamol 500mg',
      type: 'Tablet',
      availability: true,
      location: 'Main Street Pharmacy'
    },
    {
      id: 2,
      name: 'Amoxicillin 250mg',
      type: 'Capsule',
      availability: true,
      location: 'City Center Pharmacy'
    },
    {
      id: 3,
      name: 'Ibuprofen 400mg',
      type: 'Tablet',
      availability: false,
      location: 'Downtown Pharmacy'
    },
    {
      id: 4,
      name: 'Cough Syrup',
      type: 'Syrup',
      availability: true,
      location: 'City Center Pharmacy',
    },
    {
      id: 5,
      name: 'Aspirin 75mg',
      type: 'Tablet',
      availability: true,
      location: 'Main Street Pharmacy'
    },
    {
      id: 6,
      name: 'Omeprazole 20mg',
      type: 'Capsule',
      availability: true,
      location: 'Health Plus Pharmacy'
    },
    {
      id: 7,
      name: 'Metformin 500mg',
      type: 'Tablet',
      availability: false,
      location: 'Downtown Pharmacy'
    },
    {
      id: 8,
      name: 'Cetirizine 10mg',
      type: 'Tablet',
      availability: true,
      location: 'Quick Care Pharmacy'
    },
    {
      id: 9,
      name: 'Vitamin D3',
      type: 'Capsule',
      availability: true,
      location: 'Health Plus Pharmacy'
    },
    {
      id: 10,
      name: 'Insulin Injection',
      type: 'Injection',
      availability: false,
      location: 'Main Street Pharmacy'
    },
    {
      id: 11,
      name: 'Losartan 50mg',
      type: 'Tablet',
      availability: true,
      location: 'City Center Pharmacy'
    },
    {
      id: 12,
      name: 'Azithromycin 500mg',
      type: 'Tablet',
      availability: true,
      location: 'Quick Care Pharmacy'
    },
    {
      id: 13,
      name: 'Salbutamol Inhaler',
      type: 'Inhaler',
      availability: false,
      location: 'Health Plus Pharmacy'
    },
    {
      id: 14,
      name: 'Diclofenac Gel',
      type: 'Ointment',
      availability: true,
      location: 'Downtown Pharmacy'
    },
    {
      id: 15,
      name: 'Loratadine 10mg',
      type: 'Tablet',
      availability: true,
      location: 'Quick Care Pharmacy'
    },
    {
      id: 16,
      name: 'Simvastatin 20mg',
      type: 'Tablet',
      availability: false,
      location: 'Main Street Pharmacy'
    },
    {
      id: 17,
      name: 'Calcium Carbonate',
      type: 'Tablet',
      availability: true,
      location: 'Health Plus Pharmacy'
    },
    {
      id: 18,
      name: 'Hydrocortisone Cream',
      type: 'Ointment',
      availability: true,
      location: 'City Center Pharmacy'
    },
    {
      id: 19,
      name: 'Ranitidine 150mg',
      type: 'Tablet',
      availability: false,
      location: 'Downtown Pharmacy'
    },
    {
      id: 20,
      name: 'Multivitamin Syrup',
      type: 'Syrup',
      availability: true,
      location: 'Quick Care Pharmacy'
    }
  ]);

  // User management state
  const [users, setUsers] = useState([
    { id: 1, username: 'sachin', password: '12345', name: 'Sachin Kumar', email: 'sachin@pharmacy.com', role: 'admin' }
  ]);
  const [currentUser, setCurrentUser] = useState(null);
  const [currentView, setCurrentView] = useState('user-search');
  const [searchQuery, setSearchQuery] = useState('');
  const [showLogin, setShowLogin] = useState(false);
  const [showSignup, setShowSignup] = useState(false);
  const [showAddMedicine, setShowAddMedicine] = useState(false);
  const [editingMedicine, setEditingMedicine] = useState(null);
  const [authMode, setAuthMode] = useState('login'); // 'login' or 'signup'
  
  // Form states
  const [loginForm, setLoginForm] = useState({ username: '', password: '' });
  const [signupForm, setSignupForm] = useState({ 
    username: '', 
    password: '', 
    confirmPassword: '', 
    name: '', 
    email: '' 
  });
  const [medicineForm, setMedicineForm] = useState({
    name: '',
    type: 'Tablet',
    availability: true,
    location: ''
  });

  // Authentication functions
  const handleLogin = (e) => {
    e.preventDefault();
    const user = users.find(u => u.username === loginForm.username && u.password === loginForm.password);
    
    if (user) {
      setCurrentUser(user);
      setCurrentView('dashboard');
      setShowLogin(false);
      setLoginForm({ username: '', password: '' });
    } else {
      alert('Invalid credentials! Please check your username and password.');
    }
  };

  const handleSignup = (e) => {
    e.preventDefault();
    
    // Validation
    if (signupForm.password !== signupForm.confirmPassword) {
      alert('Passwords do not match!');
      return;
    }
    
    if (signupForm.password.length < 4) {
      alert('Password must be at least 4 characters long!');
      return;
    }
    
    // Check if username already exists
    const existingUser = users.find(u => u.username === signupForm.username);
    if (existingUser) {
      alert('Username already exists! Please choose a different username.');
      return;
    }
    
    // Check if email already exists
    const existingEmail = users.find(u => u.email === signupForm.email);
    if (existingEmail) {
      alert('Email already registered! Please use a different email.');
      return;
    }
    
    // Create new user
    const newUser = {
      id: Date.now(),
      username: signupForm.username,
      password: signupForm.password,
      name: signupForm.name,
      email: signupForm.email,
      role: 'pharmacist'
    };
    
    setUsers([...users, newUser]);
    setCurrentUser(newUser);
    setCurrentView('dashboard');
    setShowSignup(false);
    setSignupForm({ username: '', password: '', confirmPassword: '', name: '', email: '' });
    alert('Account created successfully! Welcome to the pharmacy system.');
  };

  const handleLogout = () => {
    setCurrentUser(null);
    setCurrentView('user-search');
  };

  const resetAuthForms = () => {
    setLoginForm({ username: '', password: '' });
    setSignupForm({ username: '', password: '', confirmPassword: '', name: '', email: '' });
  };

  // Medicine management functions
  const handleAddMedicine = (e) => {
    e.preventDefault();
    const newMedicine = {
      id: Date.now(),
      ...medicineForm,
    };
    setMedicines([...medicines, newMedicine]);
    setMedicineForm({
      name: '',
      type: 'Tablet',
      availability: true,
      location: ''
    });
    setShowAddMedicine(false);
  };

  const handleEditMedicine = (medicine) => {
    setEditingMedicine(medicine);
    setMedicineForm({ ...medicine });
    setShowAddMedicine(true);
  };

  const handleUpdateMedicine = (e) => {
    e.preventDefault();
    const updatedMedicines = medicines.map(med =>
      med.id === editingMedicine.id
        ? { ...medicineForm }
        : med
    );
    setMedicines(updatedMedicines);
    setEditingMedicine(null);
    setShowAddMedicine(false);
    setMedicineForm({
      name: '',
      type: 'Tablet',
      availability: true,
      location: ''
    });
  };

  const toggleAvailability = (medicineId) => {
    const updatedMedicines = medicines.map(med =>
      med.id === medicineId
        ? { ...med, availability: !med.availability }
        : med
    );
    setMedicines(updatedMedicines);
  };

  // Search functionality
  const filteredMedicines = medicines.filter(medicine =>
    medicine.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    medicine.type.toLowerCase().includes(searchQuery.toLowerCase()) ||
    medicine.location.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="pharmacy-container">
      <style>
        {`
          .pharmacy-container {
            min-height: 100vh;
            background-color: #ffffff;
            color: #1f2937;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 2rem;
          }

          .pharmacist-login-section {
            margin-top:50px;
            text-align: center;
            margin-bottom: 2rem;
            padding: 1rem;
            // background-color: #ffffff;
            // border: 2px solid #1f2937;
            border-radius: 12px;
          }

          .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1rem;
          }

          .btn-primary {
            background: #1f2937;
            color: white;
          }

          .btn-primary:hover {
            background: #374151;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(31, 41, 55, 0.3);
          }

          .btn-secondary {
            background: #ffffff;
            color: #1f2937;
            border: 2px solid #1f2937;
          }

          .btn-secondary:hover {
            background: #f9fafb;
            transform: translateY(-2px);
          }

          .btn-success {
            background: #059669;
            color: white;
          }

          .btn-success:hover {
            background: #047857;
            transform: translateY(-2px);
          }

          .btn-warning {
            background: #d97706;
            color: white;
          }

          .btn-warning:hover {
            background: #b45309;
            transform: translateY(-2px);
          }

          .main-content {
            max-width: 1400px;
            margin: 0 auto;
          }

          .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            background: #ffffff;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 2px 4px rgba(31, 41, 55, 0.1);
            border: 2px solid #1f2937;
          }

          .dashboard-title {
            margin: 0;
            color: #1f2937;
            font-size: 1.5rem;
          }

          .medicines-list {
            max-width: 1000px;
            margin: 2rem auto;
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(31, 41, 55, 0.1);
            border: 2px solid #e5e7eb;
            overflow: hidden;
          }

          .medicines-header {
            background: linear-gradient(135deg, #1f2937 0%, #374151 100%);
            color: white;
            padding: 1.5rem 2rem;
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1.5fr auto;
            gap: 1rem;
            font-weight: 600;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .medicine-item {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1.5fr auto;
            gap: 1rem;
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e5e7eb;
            transition: all 0.3s ease;
            align-items: center;
            background: #ffffff;
          }

          .medicine-item:hover {
            background: #f8fafc;
            transform: translateX(5px);
            box-shadow: 0 4px 8px rgba(31, 41, 55, 0.05);
          }

          .medicine-item:last-child {
            border-bottom: none;
          }

          .medicine-name-cell {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
          }

          .medicine-name-primary {
            font-size: 1.1rem;
            font-weight: 700;
            color: #1f2937;
            margin: 0;
          }

          .medicine-name-secondary {
            font-size: 0.85rem;
            color: #6b7280;
            margin: 0;
          }

          .medicine-type-cell {
            display: flex;
            align-items: center;
          }

          .medicine-type-badge {
            background: #1f2937;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 25px;
            font-size: 0.8rem;
            font-weight: 600;
            text-align: center;
            min-width: 80px;
          }

          .availability-cell {
            display: flex;
            align-items: center;
            gap: 0.5rem;
          }

          .availability-badge {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            border-radius: 25px;
            font-size: 0.85rem;
            font-weight: 600;
            text-align: center;
          }

          .available {
            background: #d1fae5;
            color: #065f46;
          }

          .unavailable {
            background: #fee2e2;
            color: #991b1b;
          }

          .pharmacy-cell {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #4b5563;
            font-size: 0.9rem;
          }

          .actions-cell {
            display: flex;
            align-items: center;
            gap: 0.5rem;
          }

          .action-btn {
            padding: 0.5rem;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
          }

          .action-btn:hover {
            transform: scale(1.1);
          }

          .edit-btn {
            background: #3b82f6;
            color: white;
          }

          .edit-btn:hover {
            background: #2563eb;
          }

          .toggle-btn-available {
            background: #f59e0b;
            color: white;
          }

          .toggle-btn-available:hover {
            background: #d97706;
          }

          .toggle-btn-unavailable {
            background: #10b981;
            color: white;
          }

          .toggle-btn-unavailable:hover {
            background: #059669;
          }

          .no-results {
            text-align: center;
            padding: 3rem 2rem;
            color: #6b7280;
            font-size: 1.1rem;
          }

          .stats-container {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin: 2rem 0;
            flex-wrap: wrap;
          }

          .stat-card {
            background: #ffffff;
            padding: 1.5rem 2rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(31, 41, 55, 0.1);
            border: 2px solid #e5e7eb;
            text-align: center;
            min-width: 150px;
          }

          .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: #1f2937;
            margin: 0;
          }

          .stat-label {
            font-size: 0.9rem;
            color: #6b7280;
            margin: 0.25rem 0 0 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .search-container {
            max-width: 600px;
            margin: 2rem auto;
            position: relative;
          }

          .search-input {
            width: 100%;
            padding: 1rem 1rem 1rem 3rem;
            font-size: 1.1rem;
            border: 2px solid #1f2937;
            border-radius: 50px;
            background-color: #ffffff;
            color: #1f2937;
            transition: all 0.3s ease;
          }

          .search-input:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(31, 41, 55, 0.1);
          }

          .search-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #1f2937;
          }

          .modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(31, 41, 55, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            animation: fadeIn 0.3s ease-out;
          }

          .modal-content {
            background: #ffffff;
            padding: 2rem;
            border-radius: 16px;
            max-width: 500px;
            width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            animation: slideIn 0.3s ease-out;
            border: 2px solid #1f2937;
          }

          .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
          }

          .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #1f2937;
          }

          .form-group {
            margin-bottom: 1rem;
          }

          .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #1f2937;
          }

          .form-input {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #1f2937;
            border-radius: 8px;
            font-size: 1rem;
            background-color: #ffffff;
            color: #1f2937;
            transition: border-color 0.3s ease;
          }

          .form-input:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(31, 41, 55, 0.1);
          }

          .form-select {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #1f2937;
            border-radius: 8px;
            font-size: 1rem;
            background: white;
            color: #1f2937;
          }

          .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
          }

          .checkbox-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin: 1rem 0;
          }

          .checkbox-group input[type="checkbox"] {
            width: 1.25rem;
            height: 1.25rem;
          }

          /* Enhanced Authentication Styles */
          .auth-modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            animation: fadeIn 0.3s ease-out;
          }

          .auth-modal-content {
            background: white;
            border-radius: 16px;
            padding: 2rem;
            width: 100%;
            max-width: 450px;
            max-height: 90vh;
            overflow-y: auto;
            position: relative;
            animation: slideUp 0.3s ease-out;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
          }

          .auth-header {
            text-align: center;
            margin-bottom: 2rem;
          }

          .auth-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #1f2937;
            margin: 0 0 0.5rem 0;
          }

          .auth-subtitle {
            color: #6b7280;
            font-size: 0.95rem;
          }

          .auth-tabs {
            display: flex;
            background: #f3f4f6;
            border-radius: 8px;
            padding: 0.25rem;
            margin-bottom: 2rem;
          }

          .auth-tab {
            flex: 1;
            padding: 0.75rem;
            border: none;
            background: transparent;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.2s ease;
            color: #6b7280;
          }

          .auth-tab.active {
            background: white;
            color: #1f2937;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
          }

          .auth-form {
            display: flex;
            flex-direction: column;
            gap: 1rem;
          }

          .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
          }

          .form-label {
            font-weight: 600;
            color: #374151;
            font-size: 0.9rem;
          }

          .form-input {
            padding: 0.875rem 1rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.2s ease;
            background: #ffffff;
          }

          .form-input:focus {
            outline: none;
            border-color: #1f2937;
            box-shadow: 0 0 0 3px rgba(31, 41, 55, 0.1);
          }

          .form-input.error {
            border-color: #ef4444;
            background: #fef2f2;
          }

          .error-message {
            color: #ef4444;
            font-size: 0.85rem;
            font-weight: 500;
          }

          .password-strength {
            font-size: 0.8rem;
            margin-top: 0.25rem;
          }

          .strength-weak {
            color: #ef4444;
          }

          .strength-medium {
            color: #f59e0b;
          }

          .strength-strong {
            color: #10b981;
          }

          .auth-submit-btn {
            background: linear-gradient(135deg, #1f2937 0%, #374151 100%);
            color: white;
            border: none;
            padding: 1rem;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            margin-top: 0.5rem;
          }

          .auth-submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(31, 41, 55, 0.3);
          }

          .auth-submit-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
          }

          .auth-divider {
            display: flex;
            align-items: center;
            margin: 1.5rem 0;
            color: #9ca3af;
            font-size: 0.9rem;
          }

          .auth-divider::before,
          .auth-divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e5e7eb;
          }

          .auth-divider span {
            padding: 0 1rem;
          }

          .demo-credentials {
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
          }

          .demo-credentials h4 {
            margin: 0 0 0.5rem 0;
            color: #0369a1;
            font-size: 0.9rem;
          }

          .demo-credentials p {
            margin: 0.25rem 0;
            font-size: 0.85rem;
            color: #0c4a6e;
          }

          @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
          }

          @keyframes slideUp {
            from { 
              opacity: 0;
              transform: translateY(20px);
            }
            to { 
              opacity: 1;
              transform: translateY(0);
            }
          }

          .welcome-section {
            text-align: center;
            color: #1f2937;
            margin-bottom: 2rem;
          }

          .welcome-title {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            font-weight: 700;
            color: #1f2937;
          }

          .welcome-subtitle {
            font-size: 1.1rem;
            color: #1f2937;
            opacity: 0.8;
          }

          .action-buttons {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
            flex-wrap: wrap;
          }

          .action-buttons .btn {
            font-size: 0.8rem;
            padding: 0.5rem 1rem;
          }

          @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
          }

          @keyframes slideIn {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
          }

          @keyframes fadeInUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
          }

          @media (max-width: 1200px) {
            .medicines-grid {
              grid-template-columns: repeat(4, 1fr);
            }
          }

          @media (max-width: 992px) {
            .medicines-header,
            .medicine-item {
              grid-template-columns: 1.5fr 1fr 1fr auto;
            }
            
            .pharmacy-cell {
              display: none;
            }
            
            .stat-card {
              min-width: 120px;
            }
          }

          @media (max-width: 768px) {
            .medicines-header,
            .medicine-item {
              grid-template-columns: 2fr 1fr auto;
              gap: 0.75rem;
            }
            
            .medicine-type-cell {
              display: none;
            }
            
            .main-content {
              padding: 1rem;
            }
            
            .form-row {
              grid-template-columns: 1fr;
            }
            
            .welcome-title {
              font-size: 2rem;
            }

            .dashboard-header {
              flex-direction: column;
              gap: 1rem;
            }
            
            .medicines-list {
              margin: 1rem auto;
            }
            
            .medicines-header,
            .medicine-item {
              padding: 1rem;
            }
            
            .stats-container {
              gap: 1rem;
            }
          }

          @media (max-width: 480px) {
            .medicines-header,
            .medicine-item {
              grid-template-columns: 1fr auto;
              gap: 0.5rem;
            }
            
            .medicine-name-primary {
              font-size: 1rem;
            }
            
            .medicines-header {
              font-size: 0.8rem;
            }
            
            .stat-card {
              min-width: 100px;
              padding: 1rem;
            }
            
            .stat-number {
              font-size: 1.5rem;
            }
          }
        `}
      </style>

      <div className="main-content">
        {/* Nabha Health Care Header */}
        <div style={{
          textAlign: 'center',
          padding: '2rem 1rem',
          marginBottom: '1rem',
          background: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',
          borderRadius: '16px',
          border: '2px solid #e5e7eb',
          boxShadow: '0 4px 12px rgba(31, 41, 55, 0.05)'
        }}>
          <div style={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            gap: '1rem',
            marginBottom: '1rem',
            flexWrap: 'wrap'
          }}>
            <NabhaHealthIcon size={64} variant="gradient" />
            <div>
              <h1 style={{
                margin: 0,
                fontSize: '2.5rem',
                fontWeight: '700',
                background: 'linear-gradient(135deg, #1f2937 0%, #10b981 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundClip: 'text'
              }}>
                Nabha Health Care
              </h1>
              <p style={{
                margin: '0.5rem 0 0 0',
                color: '#6b7280',
                fontSize: '1.1rem',
                fontWeight: '500'
              }}>
                Pharmacy Management System
              </p>
            </div>
          </div>
          
          {/* Quick Stats */}
          <div style={{
            display: 'flex',
            justifyContent: 'center',
            gap: '2rem',
            flexWrap: 'wrap',
            marginTop: '1.5rem'
          }}>
            <div style={{ textAlign: 'center' }}>
              <div style={{ 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center', 
                gap: '0.5rem',
                color: '#10b981',
                fontWeight: '600'
              }}>
                <NabhaHealthIcon size={20} variant="filled" color="#10b981" />
                <span>Trusted Care</span>
              </div>
            </div>
            <div style={{ textAlign: 'center' }}>
              <div style={{ 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center', 
                gap: '0.5rem',
                color: '#3b82f6',
                fontWeight: '600'
              }}>
                <Package size={20} />
                <span>Quality Medicines</span>
              </div>
            </div>
            <div style={{ textAlign: 'center' }}>
              <div style={{ 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center', 
                gap: '0.5rem',
                color: '#8b5cf6',
                fontWeight: '600'
              }}>
                <Clock size={20} />
                <span>24/7 Service</span>
              </div>
            </div>
          </div>
        </div>

        {/* Icon Showcase - Show only when no user is logged in */}
        {!currentUser && (
          <IconShowcase />
        )}

        {/* Pharmacist Login Section */}
        <div className="pharmacist-login-section">
          {currentUser ? (
            <div style={{display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '1rem', flexWrap: 'wrap'}}>
              <span style={{color: '#1f2937', fontWeight: '600'}}>Welcome, {currentUser.name}! ({currentUser.role})</span>
              <button
                className={`btn ${currentView === 'dashboard' ? 'btn-primary' : 'btn-secondary'}`}
                onClick={() => setCurrentView('dashboard')}
              >
                <User size={16} />
                Dashboard
              </button>
              <button
                className={`btn ${currentView === 'user-search' ? 'btn-primary' : 'btn-secondary'}`}
                onClick={() => setCurrentView('user-search')}
              >
                <Search size={16} />
                Search Medicines
              </button>
              <button className="btn btn-warning" onClick={handleLogout}>
                Logout
              </button>
            </div>
          ) : (
            <div style={{display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '1rem', flexWrap: 'wrap'}}>
              <h3 style={{color: '#1f2937', margin: '0 1rem 0 0'}}>Pharmacist Portal</h3>
              <button
                className="btn btn-primary"
                onClick={() => {
                  setAuthMode('login');
                  setShowLogin(true);
                  resetAuthForms();
                }}
              >
                <Lock size={16} />
                Login
              </button>
              <button
                className="btn btn-secondary"
                onClick={() => {
                  setAuthMode('signup');
                  setShowLogin(true);
                  resetAuthForms();
                }}
              >
                <User size={16} />
                Create Account
              </button>
            </div>
          )}
        </div>

        {/* User Search View */}
        {currentView === 'user-search' && (
          <div>
            <div className="welcome-section">
              <h2 className="welcome-title">Find Your Medicines</h2>
              <p className="welcome-subtitle">Search through our extensive database of medicines and find what you need</p>
            </div>

            {/* Statistics */}
            <div className="stats-container">
              <div className="stat-card">
                <h3 className="stat-number">{medicines.length}</h3>
                <p className="stat-label">Total Medicines</p>
              </div>
              <div className="stat-card">
                <h3 className="stat-number">{medicines.filter(m => m.availability).length}</h3>
                <p className="stat-label">Available</p>
              </div>
              <div className="stat-card">
                <h3 className="stat-number">{new Set(medicines.map(m => m.location)).size}</h3>
                <p className="stat-label">Pharmacy Locations</p>
              </div>
            </div>

            <div className="search-container">
              <Search className="search-icon" size={20} />
              <input
                type="text"
                placeholder="Search medicines by name, type, or pharmacy location..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="search-input"
              />
            </div>

            <div className="medicines-list">
              <div className="medicines-header">
                <div>Medicine</div>
                <div>Type</div>
                <div>Availability</div>
                <div>Pharmacy Location</div>
                <div></div>
              </div>
              {filteredMedicines.map((medicine) => (
                <div key={medicine.id} className="medicine-item">
                  <div className="medicine-name-cell">
                    <h3 className="medicine-name-primary">{medicine.name}</h3>
                    <p className="medicine-name-secondary">ID: {medicine.id}</p>
                  </div>
                  <div className="medicine-type-cell">
                    <span className="medicine-type-badge">{medicine.type}</span>
                  </div>
                  <div className="availability-cell">
                    <span className={`availability-badge ${medicine.availability ? 'available' : 'unavailable'}`}>
                      {medicine.availability ? '✅ Available' : '❌ Out of Stock'}
                    </span>
                  </div>
                  <div className="pharmacy-cell">
                    <MapPin size={16} />
                    {medicine.location}
                  </div>
                  <div className="actions-cell">
                    <Package size={16} color="#6b7280" />
                  </div>
                </div>
              ))}
            </div>

            {filteredMedicines.length === 0 && searchQuery && (
              <div className="no-results">
                <p>No medicines found matching your search criteria.</p>
              </div>
            )}
          </div>
        )}

        {/* Dashboard View */}
        {currentView === 'dashboard' && currentUser && (
          <div className="dashboard">
            <div className="dashboard-header">
              <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                <NabhaHealthIcon size={40} variant="filled" color="#10b981" />
                <h2 className="dashboard-title">Pharmacist Dashboard - Manage Medicines</h2>
              </div>
              <button
                className="btn btn-success"
                onClick={() => setShowAddMedicine(true)}
              >
                <Plus size={16} />
                Add Medicine
              </button>
            </div>

            {/* Dashboard Statistics */}
            <div className="stats-container">
              <div className="stat-card">
                <h3 className="stat-number">{medicines.length}</h3>
                <p className="stat-label">Total Medicines</p>
              </div>
              <div className="stat-card">
                <h3 className="stat-number">{medicines.filter(m => m.availability).length}</h3>
                <p className="stat-label">In Stock</p>
              </div>
              <div className="stat-card">
                <h3 className="stat-number">{medicines.filter(m => !m.availability).length}</h3>
                <p className="stat-label">Out of Stock</p>
              </div>
              <div className="stat-card">
                <h3 className="stat-number">{new Set(medicines.map(m => m.location)).size}</h3>
                <p className="stat-label">Locations</p>
              </div>
            </div>

            <div className="medicines-list">
              <div className="medicines-header">
                <div>Medicine</div>
                <div>Type</div>
                <div>Availability</div>
                <div>Pharmacy Location</div>
                <div>Actions</div>
              </div>
              {medicines.map((medicine) => (
                <div key={medicine.id} className="medicine-item">
                  <div className="medicine-name-cell">
                    <h3 className="medicine-name-primary">{medicine.name}</h3>
                    <p className="medicine-name-secondary">ID: {medicine.id}</p>
                  </div>
                  <div className="medicine-type-cell">
                    <span className="medicine-type-badge">{medicine.type}</span>
                  </div>
                  <div className="availability-cell">
                    <span className={`availability-badge ${medicine.availability ? 'available' : 'unavailable'}`}>
                      {medicine.availability ? '✅ Available' : '❌ Out of Stock'}
                    </span>
                  </div>
                  <div className="pharmacy-cell">
                    <MapPin size={16} />
                    {medicine.location}
                  </div>
                  <div className="actions-cell">
                    <button
                      className="action-btn edit-btn"
                      onClick={() => handleEditMedicine(medicine)}
                      title="Edit Medicine"
                    >
                      <Edit3 size={16} />
                    </button>
                    <button
                      className={`action-btn ${medicine.availability ? 'toggle-btn-available' : 'toggle-btn-unavailable'}`}
                      onClick={() => toggleAvailability(medicine.id)}
                      title={medicine.availability ? 'Mark as Out of Stock' : 'Mark as Available'}
                    >
                      {medicine.availability ? <Clock size={16} /> : <Package size={16} />}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Enhanced Authentication Modal */}
        {showLogin && (
          <div className="auth-modal">
            <div className="auth-modal-content">
              <button
                className="close-btn"
                onClick={() => {
                  setShowLogin(false);
                  resetAuthForms();
                }}
                style={{position: 'absolute', top: '1rem', right: '1rem', background: 'none', border: 'none', fontSize: '1.5rem', cursor: 'pointer'}}
              >
                ×
              </button>

              <div className="auth-header">
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '1rem', marginBottom: '1rem' }}>
                  <NabhaHealthIcon size={48} variant="gradient" />
                  <div>
                    <h2 className="auth-title" style={{ margin: 0 }}>Pharmacist Portal</h2>
                    <p className="auth-subtitle" style={{ margin: '0.25rem 0 0 0' }}>Access your pharmacy management dashboard</p>
                  </div>
                </div>
              </div>

              <div className="auth-tabs">
                <button
                  type="button"
                  className={`auth-tab ${authMode === 'login' ? 'active' : ''}`}
                  onClick={() => setAuthMode('login')}
                >
                  Login
                </button>
                <button
                  type="button"
                  className={`auth-tab ${authMode === 'signup' ? 'active' : ''}`}
                  onClick={() => setAuthMode('signup')}
                >
                  Sign Up
                </button>
              </div>

              {authMode === 'login' ? (
                <form onSubmit={handleLogin} className="auth-form">
                  <div className="form-group">
                    <label className="form-label">Username</label>
                    <input
                      type="text"
                      className="form-input"
                      value={loginForm.username}
                      onChange={(e) => setLoginForm({...loginForm, username: e.target.value})}
                      placeholder="Enter your username"
                      required
                    />
                  </div>
                  
                  <div className="form-group">
                    <label className="form-label">Password</label>
                    <input
                      type="password"
                      className="form-input"
                      value={loginForm.password}
                      onChange={(e) => setLoginForm({...loginForm, password: e.target.value})}
                      placeholder="Enter your password"
                      required
                    />
                  </div>
                  
                  <button type="submit" className="auth-submit-btn">
                    Login to Dashboard
                  </button>

                  <div className="demo-credentials">
                    <h4>Demo Credentials</h4>
                    <p><strong>Username:</strong> sachin</p>
                    <p><strong>Password:</strong> 12345</p>
                  </div>
                </form>
              ) : (
                <form onSubmit={handleSignup} className="auth-form">
                  <div className="form-group">
                    <label className="form-label">Full Name</label>
                    <input
                      type="text"
                      className="form-input"
                      value={signupForm.name}
                      onChange={(e) => setSignupForm({...signupForm, name: e.target.value})}
                      placeholder="Enter your full name"
                      required
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">Email Address</label>
                    <input
                      type="email"
                      className="form-input"
                      value={signupForm.email}
                      onChange={(e) => setSignupForm({...signupForm, email: e.target.value})}
                      placeholder="Enter your email"
                      required
                    />
                  </div>
                  
                  <div className="form-group">
                    <label className="form-label">Username</label>
                    <input
                      type="text"
                      className="form-input"
                      value={signupForm.username}
                      onChange={(e) => setSignupForm({...signupForm, username: e.target.value})}
                      placeholder="Choose a username"
                      required
                      minLength="3"
                    />
                  </div>
                  
                  <div className="form-group">
                    <label className="form-label">Password</label>
                    <input
                      type="password"
                      className="form-input"
                      value={signupForm.password}
                      onChange={(e) => setSignupForm({...signupForm, password: e.target.value})}
                      placeholder="Create a password"
                      required
                      minLength="4"
                    />
                    {signupForm.password && (
                      <div className="password-strength">
                        <span className={
                          signupForm.password.length < 6 ? 'strength-weak' :
                          signupForm.password.length < 8 ? 'strength-medium' : 'strength-strong'
                        }>
                          Password strength: {
                            signupForm.password.length < 6 ? 'Weak' :
                            signupForm.password.length < 8 ? 'Medium' : 'Strong'
                          }
                        </span>
                      </div>
                    )}
                  </div>
                  
                  <div className="form-group">
                    <label className="form-label">Confirm Password</label>
                    <input
                      type="password"
                      className={`form-input ${signupForm.confirmPassword && signupForm.password !== signupForm.confirmPassword ? 'error' : ''}`}
                      value={signupForm.confirmPassword}
                      onChange={(e) => setSignupForm({...signupForm, confirmPassword: e.target.value})}
                      placeholder="Confirm your password"
                      required
                    />
                    {signupForm.confirmPassword && signupForm.password !== signupForm.confirmPassword && (
                      <span className="error-message">Passwords do not match</span>
                    )}
                  </div>
                  
                  <button 
                    type="submit" 
                    className="auth-submit-btn"
                    disabled={signupForm.password !== signupForm.confirmPassword}
                  >
                    Create Account
                  </button>
                </form>
              )}
            </div>
          </div>
        )}

        {/* Add/Edit Medicine Modal */}
        {showAddMedicine && (
          <div className="modal">
            <div className="modal-content">
              <div className="modal-header">
                <h3>{editingMedicine ? 'Edit Medicine' : 'Add New Medicine'}</h3>
                <button
                  className="close-btn"
                  onClick={() => {
                    setShowAddMedicine(false);
                    setEditingMedicine(null);
                    setMedicineForm({
                      name: '',
                      type: 'Tablet',
                      availability: true,
                      location: ''
                    });
                  }}
                >
                  ×
                </button>
              </div>
              <form onSubmit={editingMedicine ? handleUpdateMedicine : handleAddMedicine}>
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Medicine Name</label>
                    <input
                      type="text"
                      className="form-input"
                      value={medicineForm.name}
                      onChange={(e) => setMedicineForm({...medicineForm, name: e.target.value})}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Type</label>
                    <select
                      className="form-select"
                      value={medicineForm.type}
                      onChange={(e) => setMedicineForm({...medicineForm, type: e.target.value})}
                    >
                      <option value="Tablet">Tablet</option>
                      <option value="Syrup">Syrup</option>
                      <option value="Capsule">Capsule</option>
                      <option value="Injection">Injection</option>
                      <option value="Ointment">Ointment</option>
                      <option value="Inhaler">Inhaler</option>
                    </select>
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Pharmacy Location</label>
                  <input
                    type="text"
                    className="form-input"
                    value={medicineForm.location}
                    onChange={(e) => setMedicineForm({...medicineForm, location: e.target.value})}
                    required
                  />
                </div>
                <div className="checkbox-group">
                  <input
                    type="checkbox"
                    id="availability"
                    checked={medicineForm.availability}
                    onChange={(e) => setMedicineForm({...medicineForm, availability: e.target.checked})}
                  />
                  <label htmlFor="availability">Available in stock</label>
                </div>
                <button type="submit" className="btn btn-success" style={{width: '100%'}}>
                  {editingMedicine ? 'Update Medicine' : 'Add Medicine'}
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Pharmacy;