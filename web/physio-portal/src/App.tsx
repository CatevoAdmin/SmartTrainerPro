import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Dashboard from './pages/Dashboard'
import PatientDetail from './pages/PatientDetail'
import './index.css'

function App() {
  return (
    <BrowserRouter>
      <div className="min-h-screen">
        {/* Header */}
        <header className="bg-ponce-teal text-white px-6 py-4 shadow-lg">
          <div className="max-w-6xl mx-auto flex items-center justify-between">
            <h1 className="text-2xl font-bold tracking-tight">
              <span className="text-ponce-orange">Smart</span> Trainer Pro
            </h1>
            <span className="text-ponce-blue text-sm">Physio Portal</span>
          </div>
        </header>

        {/* Main Content */}
        <main className="max-w-6xl mx-auto p-6">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/patient/:id" element={<PatientDetail />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  )
}

export default App
