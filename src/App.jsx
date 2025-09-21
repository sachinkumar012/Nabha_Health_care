import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { LanguageProvider } from './context/LanguageContext';
import { HealthProvider } from './context/HealthContext';
import Header from './components/Layout/Header';
import Footer from './components/Layout/Footer';
import Home from './pages/Home';
import Doctors from './pages/Doctors';
import HealthRecords from './pages/HealthRecords';
import Pharmacy from './pages/Pharmacy';
import SymptomChecker from './pages/SymptomChecker';
import About from './pages/About';
import PatientAuth from './Login/PatientAuth';

function App() {
  return (
    <LanguageProvider>
      <HealthProvider>
        <Router>
          <div className="min-h-screen flex flex-col">
            <Header />
            <main className="flex-grow">
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/doctors" element={<Doctors />} />
                <Route path="/records" element={<HealthRecords />} />
                <Route path="/pharmacy" element={<Pharmacy />} />
                <Route path="/symptoms" element={<SymptomChecker />} />
                <Route path="/about" element={<About />} />
                <Route path="/patient/auth" element={<PatientAuth />} />
              </Routes>
            </main>
            <Footer />
          </div>
        </Router>
      </HealthProvider>
    </LanguageProvider>
  );
}

export default App;