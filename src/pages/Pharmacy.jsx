import  { useState, useEffect } from 'react';
import { Search, Plus, Edit3, User, Lock, Mail, Phone, Clock, MapPin, Package } from 'lucide-react';

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
  const [currentUser, setCurrentUser] = useState(null);
  const [currentView, setCurrentView] = useState('user-search');
  const [searchQuery, setSearchQuery] = useState('');
  const [showLogin, setShowLogin] = useState(false);
  const [showAddMedicine, setShowAddMedicine] = useState(false);
  const [editingMedicine, setEditingMedicine] = useState(null);
  
  // Form states
  const [loginForm, setLoginForm] = useState({ username: '', password: '' });
  const [medicineForm, setMedicineForm] = useState({
    name: '',
    type: 'Tablet',
    availability: true,
    location: ''
  });

  // Authentication functions
  const handleLogin = (e) => {
    e.preventDefault();
    if (loginForm.username === 'sachin' && loginForm.password === '12345') {
      setCurrentUser({ username: 'sachin', name: 'Sachin' });
      setCurrentView('dashboard');
      setShowLogin(false);
      setLoginForm({ username: '', password: '' });
    } else {
      alert('Invalid credentials! Use username: sachin, password: 12345');
    }
  };

  const handleLogout = () => {
    setCurrentUser(null);
    setCurrentView('user-search');
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

          .medicines-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 1.5rem;
            margin-top: 2rem;
          }

          .medicine-card {
            background: #ffffff;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(31, 41, 55, 0.1);
            border: 2px solid #1f2937;
            transition: all 0.3s ease;
            animation: fadeInUp 0.5s ease-out;
            min-height: 200px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
          }

          .medicine-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(31, 41, 55, 0.2);
          }

          .medicine-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
          }

          .medicine-name {
            font-size: 1.1rem;
            font-weight: 700;
            color: #1f2937;
            margin: 0;
            line-height: 1.3;
          }

          .medicine-type {
            background: #1f2937;
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
          }

          .availability-status {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin: 0.75rem 0;
            font-weight: 600;
            font-size: 0.9rem;
          }

          .in-stock {
            color: #059669;
          }

          .out-of-stock {
            color: #dc2626;
          }

          .pharmacy-info {
            background: #f9fafb;
            padding: 0.75rem;
            border-radius: 8px;
            margin: 1rem 0;
            font-size: 0.8rem;
            border: 1px solid #e5e7eb;
          }

          .pharmacy-info div {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #1f2937;
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
            .medicines-grid {
              grid-template-columns: repeat(3, 1fr);
            }
          }

          @media (max-width: 768px) {
            .medicines-grid {
              grid-template-columns: repeat(2, 1fr);
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
          }

          @media (max-width: 480px) {
            .medicines-grid {
              grid-template-columns: 1fr;
            }
          }
        `}
      </style>

      <div className="main-content">
        {/* Pharmacist Login Section */}
        <div className="pharmacist-login-section">
          {currentUser ? (
            <div style={{display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '1rem'}}>
              <span>Welcome, {currentUser.name}!</span>
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
            <button
              className="btn btn-primary"
              onClick={() => setShowLogin(true)}
            >
              <Lock size={16} />
              Pharmacist Login
            </button>
          )}
        </div>

        {/* User Search View */}
        {currentView === 'user-search' && (
          <div>
            <div className="welcome-section">
              <h2 className="welcome-title">Find Your Medicines</h2>
              <p className="welcome-subtitle">Search through our extensive database of medicines and find what you need</p>
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

            <div className="medicines-grid">
              {filteredMedicines.map((medicine) => (
                <div key={medicine.id} className="medicine-card">
                  <div>
                    <div className="medicine-header">
                      <h3 className="medicine-name">{medicine.name}</h3>
                      <span className="medicine-type">{medicine.type}</span>
                    </div>
                    <div className={`availability-status ${medicine.availability ? 'in-stock' : 'out-of-stock'}`}>
                      {medicine.availability ? '✅ In Stock' : '❌ Out of Stock'}
                    </div>
                  </div>
                  <div className="pharmacy-info">
                    <div>
                      <MapPin size={14} />
                      {medicine.location}
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {filteredMedicines.length === 0 && searchQuery && (
              <div style={{ textAlign: 'center', color: '#1f2937', marginTop: '2rem' }}>
                <p>No medicines found matching your search.</p>
              </div>
            )}
          </div>
        )}

        {/* Dashboard View */}
        {currentView === 'dashboard' && currentUser && (
          <div className="dashboard">
            <div className="dashboard-header">
              <h2 className="dashboard-title">Pharmacist Dashboard - Manage Medicines</h2>
              <button
                className="btn btn-success"
                onClick={() => setShowAddMedicine(true)}
              >
                <Plus size={16} />
                Add Medicine
              </button>
            </div>

            <div className="medicines-grid">
              {medicines.map((medicine) => (
                <div key={medicine.id} className="medicine-card">
                  <div>
                    <div className="medicine-header">
                      <h3 className="medicine-name">{medicine.name}</h3>
                      <span className="medicine-type">{medicine.type}</span>
                    </div>
                    <div className={`availability-status ${medicine.availability ? 'in-stock' : 'out-of-stock'}`}>
                      {medicine.availability ? '✅ In Stock' : '❌ Out of Stock'}
                    </div>
                    <div className="pharmacy-info">
                      <div>
                        <MapPin size={14} />
                        {medicine.location}
                      </div>
                    </div>
                  </div>
                  <div className="action-buttons">
                    <button
                      className="btn btn-primary"
                      onClick={() => handleEditMedicine(medicine)}
                    >
                      <Edit3 size={12} />
                      Edit
                    </button>
                    <button
                      className={`btn ${medicine.availability ? 'btn-warning' : 'btn-success'}`}
                      onClick={() => toggleAvailability(medicine.id)}
                    >
                      {medicine.availability ? 'Mark Out' : 'Mark In'}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Login Modal */}
        {showLogin && (
          <div className="modal">
            <div className="modal-content">
              <div className="modal-header">
                <h3>Pharmacist Login</h3>
                <button
                  className="close-btn"
                  onClick={() => setShowLogin(false)}
                >
                  ×
                </button>
              </div>
              <form onSubmit={handleLogin}>
                <div className="form-group">
                  <label className="form-label">Username</label>
                  <input
                    type="text"
                    className="form-input"
                    value={loginForm.username}
                    onChange={(e) => setLoginForm({...loginForm, username: e.target.value})}
                    placeholder="Enter username (nikunj)"
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
                    placeholder="Enter password (12345)"
                    required
                  />
                </div>
                <button type="submit" className="btn btn-primary" style={{width: '100%'}}>
                  Login
                </button>
              </form>
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