/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['selector', '[data-theme="forest"]'], // DaisyUI forest theme as dark mode
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      screens: {
        'xs': '480px', // Extra small devices (large phones)
      },
      colors: {
        'csu-green-dark': '#0A400C',
        'csu-green-light': '#18aa1d', 
        'csu-yellow': '#d0db34',
        'csu-yellow-alt': '#d3ad03',
        'form-border': '#e0e6ed',
        'form-text': '#2c3e50',
        'form-placeholder': '#7f8c8d',
        'form-blue': '#3498db',
        'form-blue-dark': '#2980b9',
      },
     fontFamily: {
        'inter': ['Inter', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
      },
      animation: {
        'fadeIn': 'fadeIn 0.3s ease-out',
        'slideUp': 'slideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        }
      }
    },
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: ["light", "forest"],
    darkTheme: "forest",
  },
}