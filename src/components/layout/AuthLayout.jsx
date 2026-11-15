import React from 'react';
import { Link, Outlet } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';

export const AuthLayout = () => {
  return (
    <div className="min-h-screen bg-warm-ivory flex flex-col justify-between selection:bg-charcoal selection:text-white">
      {/* Minimalist Dedicated Auth Header */}
      <header className="w-full border-b border-soft-beige/80 bg-white/70 backdrop-blur-md sticky top-0 z-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          {/* Back to Home Link */}
          <Link
            to="/"
            className="inline-flex items-center gap-2 text-xs font-semibold uppercase tracking-wider-brand text-charcoal/80 hover:text-charcoal transition-colors group"
          >
            <ArrowLeft className="w-4 h-4 transform group-hover:-translate-x-1 transition-transform" />
            <span>Back to Home</span>
          </Link>

          {/* Center Brand Mark */}
          <Link to="/" className="flex items-center gap-2.5">
            <img src="/brand/hilaara-mark-dark.svg" alt="HILAARA" className="h-7 w-auto" />
            <span className="font-serif text-lg font-medium tracking-tight text-charcoal">
              HILAARA
            </span>
          </Link>

          {/* Right helper info */}
          <div className="text-right hidden sm:block">
            <span className="text-[11px] text-muted-text font-light">
              Somali Luxury Fashion Atelier
            </span>
          </div>
        </div>
      </header>

      {/* Main Form Content */}
      <main className="flex-1 flex items-center justify-center p-4 sm:p-6 lg:p-8">
        <Outlet />
      </main>

      {/* Subtle bottom copyright without noisy footer links */}
      <footer className="py-6 text-center text-xs text-muted-text/70 border-t border-soft-beige/50">
        <p>© {new Date().getFullYear()} HILAARA Atelier. Mogadishu & Hargeisa.</p>
      </footer>
    </div>
  );
};

export default AuthLayout;
