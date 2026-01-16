import { useState, useEffect } from 'react'
import { useParams, Link } from 'react-router-dom'
import { ArrowLeft, Zap, Clock, Plus } from 'lucide-react'

interface Prescription {
    id: number
    title: string
    description: string
    targetWatts: number
    durationMinutes: number
    isCompleted: boolean
    createdAt: string
}

interface User {
    id: number
    name: string
    email: string
}

const API_BASE = 'http://localhost:5223/api'

export default function PatientDetail() {
    const { id } = useParams()
    const [patient, setPatient] = useState<User | null>(null)
    const [prescriptions, setPrescriptions] = useState<Prescription[]>([])
    const [showPrescribeForm, setShowPrescribeForm] = useState(false)
    const [newRx, setNewRx] = useState({
        title: '',
        description: '',
        targetWatts: 75,
        durationMinutes: 15
    })

    useEffect(() => {
        fetchPatient()
        fetchPrescriptions()
    }, [id])

    const fetchPatient = async () => {
        try {
            const res = await fetch(`${API_BASE}/users`)
            if (res.ok) {
                const users = await res.json()
                const found = users.find((u: User) => u.id === Number(id))
                setPatient(found || null)
            }
        } catch (err) {
            console.error('Failed to fetch patient:', err)
        }
    }

    const fetchPrescriptions = async () => {
        try {
            const res = await fetch(`${API_BASE}/users/${id}/prescriptions`)
            if (res.ok) {
                const data = await res.json()
                setPrescriptions(data)
            }
        } catch (err) {
            console.error('Failed to fetch prescriptions:', err)
        }
    }

    const createPrescription = async (e: React.FormEvent) => {
        e.preventDefault()
        try {
            const res = await fetch(`${API_BASE}/practitioners/1/prescribe`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ...newRx, userId: Number(id) })
            })
            if (res.ok) {
                setShowPrescribeForm(false)
                setNewRx({ title: '', description: '', targetWatts: 75, durationMinutes: 15 })
                fetchPrescriptions()
            }
        } catch (err) {
            console.error('Failed to create prescription:', err)
        }
    }

    if (!patient) {
        return <div className="text-center py-12">Loading...</div>
    }

    return (
        <div className="space-y-6">
            {/* Back Link */}
            <Link to="/" className="inline-flex items-center gap-2 text-ponce-blue hover:text-ponce-teal transition-colors">
                <ArrowLeft className="w-4 h-4" />
                Back to Patients
            </Link>

            {/* Patient Header */}
            <div className="bg-white p-6 rounded-xl shadow-lg">
                <h2 className="text-3xl font-bold text-ponce-teal">{patient.name}</h2>
                <p className="text-ponce-blue">{patient.email || 'No email provided'}</p>
            </div>

            {/* Prescriptions Section */}
            <div className="flex items-center justify-between">
                <h3 className="text-2xl font-semibold">Prescribed Rides</h3>
                <button
                    onClick={() => setShowPrescribeForm(true)}
                    className="flex items-center gap-2 bg-ponce-orange text-white px-4 py-2 rounded-lg hover:bg-orange-600 transition-colors font-medium"
                >
                    <Plus className="w-5 h-5" />
                    Prescribe Ride
                </button>
            </div>

            {/* Prescription Form */}
            {showPrescribeForm && (
                <div className="bg-ponce-cream p-6 rounded-xl shadow-lg border border-ponce-orange/30">
                    <h4 className="text-xl font-semibold mb-4 text-ponce-teal">New Prescription</h4>
                    <form onSubmit={createPrescription} className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium mb-1">Title</label>
                            <input
                                type="text"
                                placeholder="e.g., Easy Recovery Spin"
                                value={newRx.title}
                                onChange={e => setNewRx({ ...newRx, title: e.target.value })}
                                className="w-full px-4 py-2 border border-ponce-blue/30 rounded-lg focus:outline-none focus:ring-2 focus:ring-ponce-orange"
                                required
                            />
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-medium mb-1">Target Watts</label>
                                <div className="flex items-center gap-2">
                                    <Zap className="w-5 h-5 text-ponce-orange" />
                                    <input
                                        type="number"
                                        value={newRx.targetWatts}
                                        onChange={e => setNewRx({ ...newRx, targetWatts: Number(e.target.value) })}
                                        className="flex-1 px-4 py-2 border border-ponce-blue/30 rounded-lg focus:outline-none focus:ring-2 focus:ring-ponce-orange"
                                        min="25"
                                        max="200"
                                    />
                                    <span className="text-ponce-blue">W</span>
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Duration</label>
                                <div className="flex items-center gap-2">
                                    <Clock className="w-5 h-5 text-ponce-blue" />
                                    <input
                                        type="number"
                                        value={newRx.durationMinutes}
                                        onChange={e => setNewRx({ ...newRx, durationMinutes: Number(e.target.value) })}
                                        className="flex-1 px-4 py-2 border border-ponce-blue/30 rounded-lg focus:outline-none focus:ring-2 focus:ring-ponce-orange"
                                        min="5"
                                        max="60"
                                    />
                                    <span className="text-ponce-blue">min</span>
                                </div>
                            </div>
                        </div>
                        <div>
                            <label className="block text-sm font-medium mb-1">Notes</label>
                            <textarea
                                placeholder="Instructions for the patient..."
                                value={newRx.description}
                                onChange={e => setNewRx({ ...newRx, description: e.target.value })}
                                className="w-full px-4 py-2 border border-ponce-blue/30 rounded-lg focus:outline-none focus:ring-2 focus:ring-ponce-orange h-20"
                            />
                        </div>
                        <div className="flex gap-4">
                            <button type="submit" className="bg-ponce-teal text-white px-6 py-2 rounded-lg hover:bg-teal-800 transition-colors font-medium">
                                Create Prescription
                            </button>
                            <button type="button" onClick={() => setShowPrescribeForm(false)} className="text-gray-500 hover:text-gray-700">
                                Cancel
                            </button>
                        </div>
                    </form>
                </div>
            )}

            {/* Prescription List */}
            <div className="grid gap-4">
                {prescriptions.length === 0 ? (
                    <div className="text-center py-12 text-ponce-blue bg-white rounded-xl">
                        <p>No prescriptions yet. Create one to assign a ride.</p>
                    </div>
                ) : (
                    prescriptions.map(rx => (
                        <div
                            key={rx.id}
                            className={`bg-white p-5 rounded-xl shadow-md border-l-4 ${rx.isCompleted ? 'border-green-500' : 'border-ponce-orange'}`}
                        >
                            <div className="flex items-start justify-between">
                                <div>
                                    <h4 className="text-lg font-semibold text-ponce-teal">{rx.title}</h4>
                                    <p className="text-ponce-blue text-sm mt-1">{rx.description}</p>
                                </div>
                                {rx.isCompleted && (
                                    <span className="bg-green-100 text-green-700 text-xs px-2 py-1 rounded-full">Completed</span>
                                )}
                            </div>
                            <div className="flex gap-6 mt-4 text-sm">
                                <div className="flex items-center gap-2">
                                    <Zap className="w-4 h-4 text-ponce-orange" />
                                    <span className="font-medium">{rx.targetWatts}W</span>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Clock className="w-4 h-4 text-ponce-blue" />
                                    <span className="font-medium">{rx.durationMinutes} min</span>
                                </div>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    )
}
