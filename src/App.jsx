import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { LanguageProvider } from './context/LanguageContext';
import { HealthProvider } from './context/HealthContext';
import Header from './components/Layout/Header';
import Footer from './components/Layout/Footer';
import Home from './pages/Home';
import Doctors from './pages/Doctors';
import Hospitals from './pages/Hospitals';
import HealthRecords from './pages/HealthRecords';
import Pharmacy from './pages/Pharmacy';
import SymptomChecker from './pages/SymptomChecker';
import About from './pages/About';
import PatientAuth from './Login/PatientAuth';
import VideoCallRoom from './components/VideoCall/VideoCallRoom';

function App() {
  return (
    <LanguageProvider>
      <HealthProvider>
        <Router>
          <div className="min-h-screen flex flex-col">
            <Routes>
              <Route path="/video-call/:callId" element={<VideoCallRoom />} />
              <Route path="/*" element={
                <>
                  <Header />
                  <main className="flex-grow">
                    <Routes>
                      <Route path="/" element={<Home />} />
                      <Route path="/doctors" element={<Doctors />} />
                      <Route path="/hospitals" element={<Hospitals />} />
                      <Route path="/records" element={<HealthRecords />} />
                      <Route path="/pharmacy" element={<Pharmacy />} />
                      <Route path="/symptoms" element={<SymptomChecker />} />
                      <Route path="/about" element={<About />} />
                      <Route path="/patient/auth" element={<PatientAuth />} />
                    </Routes>
                  </main>
                  <Footer />
                </>
              } />
            </Routes>
          </div>
        </Router>
      </HealthProvider>
    </LanguageProvider>
  );
}

export default App;