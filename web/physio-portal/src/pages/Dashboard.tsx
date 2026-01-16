import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { Users, Plus, Activity } from 'lucide-react'

interface User {
    id: number
    name: string
    email: string
}

const API_BASE = 'http://localhost:5223/api'

export default function Dashboard() {
    const [patients, setPatients] = useState<User[]>([])
    const [showAddForm, setShowAddForm] = useState(false)
    const [newPatient, setNewPatient] = useState({ name: '', email: '' })

    useEffect(() => {
        fetchPatients()
    }, [])

    const fetchPatients = async () => {
        try {
            const res = await fetch(`${API_BASE}/users`)
            if (res.ok) {
                const data = await res.json()
                setPatients(data)
            }
        } catch (err) {
            console.error('Failed to fetch patients:', err)
        }
    }

    const addPatient = async (e: React.FormEvent) => {
        e.preventDefault()
        try {
            const res = await fetch(`${API_BASE}/users`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(newPatient)
            })
            if (res.ok) {
                setNewPatient({ name: '', email: '' })
                setShowAddForm(false)
                fetchPatients()
            }
        } catch (err) {
            console.error('Failed to add patient:', err)
        }
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                    <Users className="w-8 h-8 text-ponce-orange" />
                    <h2 className="text-3xl font-bold">Patients</h2>
                </div>
                <button
                    onClick={() => setShowAddForm(true)}
                    className="flex items-center gap-2 bg-ponce-orange text-white px-4 py-2 rounded-lg hover:bg-orange-600 transition-colors font-medium"
                >
                    <Plus className="w-5 h-5" />
                    Add Patient
                </button>
            </div>

            {/* Add Patient Form */}
            {showAddForm && (
                <div className="bg-white p-6 rounded-xl shadow-lg border border-ponce-blue/20">
                    <h3 className="text-xl font-semibold mb-4">New Patient</h3>
                    <form onSubmit={addPatient} className="flex gap-4">
                        <input
                            type="text"
                            placeholder="Name"
                            value={newPatient.name}
                            onChange={e => setNewPatient({ ...newPatient, name: e.target.value })}
                            className="flex-1 px-4 py-2 border border-ponce-blue/30 rounded-lg focus:outline-none focus:ring-2 focus:ring-ponce-orange"
                            required
                        />
                        <input
                            type="email"
                            placeholder="Email"
                            value={newPatient.email}
                            onChange={e => setNewPatient({ ...newPatient, email: e.target.value })}
                            className="flex-1 px-4 py-2 border border-ponce-blue/30 rounded-lg focus:outline-none focus:ring-2 focus:ring-ponce-orange"
                        />
                        <button type="submit" className="bg-ponce-teal text-white px-6 py-2 rounded-lg hover:bg-teal-800 transition-colors">
                            Save
                        </button>
                        <button type="button" onClick={() => setShowAddForm(false)} className="text-gray-500 hover:text-gray-700">
                            Cancel
                        </button>
                    </form>
                </div>
            )}

            {/* Patient List */}
            <div className="grid gap-4">
                {patients.length === 0 ? (
                    <div className="text-center py-12 text-ponce-blue">
                        <Activity className="w-12 h-12 mx-auto mb-4 opacity-50" />
                        <p>No patients yet. Add your first patient to get started.</p>
                    </div>
                ) : (
                    patients.map(patient => (
                        <Link
                            key={patient.id}
                            to={`/patient/${patient.id}`}
                            className="bg-white p-5 rounded-xl shadow-md hover:shadow-lg transition-shadow border-l-4 border-ponce-orange flex items-center justify-between"
                        >
                            <div>
                                <h3 className="text-xl font-semibold text-ponce-teal">{patient.name}</h3>
                                <p className="text-ponce-blue text-sm">{patient.email || 'No email'}</p>
                            </div>
                            <span className="text-ponce-orange font-medium">View →</span>
                        </Link>
                    ))
                )}
            </div>
        </div>
    )
}
