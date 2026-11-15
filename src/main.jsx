import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './styles/index.css';

// Mount application and smoothly remove instant preloader
const rootElement = document.getElementById('root');
if (rootElement) {
  const root = ReactDOM.createRoot(rootElement);
  root.render(
    <React.StrictMode>
      <App />
    </React.StrictMode>
  );

  // Immediately dismiss preloader upon mount
  const preloader = document.getElementById('app-preloader');
  if (preloader) {
    preloader.remove();
  }
}

