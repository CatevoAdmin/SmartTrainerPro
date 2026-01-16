/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'ponce-orange': '#FF5722',
        'ponce-teal': '#1A3C40',
        'ponce-blue': '#4D8090',
        'ponce-bg': '#F7F4F0',
        'ponce-cream': '#F5E6D3',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
