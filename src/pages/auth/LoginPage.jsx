import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../context/ToastContext';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { User, Lock, ArrowRight, ShieldCheck, Zap } from 'lucide-react';
import { LocationModal } from '../../components/auth/LocationModal';

export const LoginPage = () => {
  const [usernameOrEmail, setUsernameOrEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  
  // Location modal state upon successful login
  const [showLocationModal, setShowLocationModal] = useState(false);
  const [loggedInUser, setLoggedInUser] = useState(null);
  const [loggedInProfile, setLoggedInProfile] = useState(null);

  const { login, instantDemoLogin } = useAuth();
  const toast = useToast();
  const navigate = useNavigate();
  const location = useLocation();

  const searchParams = new URLSearchParams(location.search);
  const returnUrl = searchParams.get('returnUrl') || '/';

  const finishLoginNavigation = (profile) => {
    if (profile?.role === 'admin' && returnUrl === '/') {
      navigate('/admin');
    } else {
      navigate(returnUrl);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!usernameOrEmail || !password) {
      setError('Please provide your username or email address and password.');
      return;
    }

    setIsLoading(true);
    try {
      const { user, profile } = await login(usernameOrEmail, password);
      toast.success(`Welcome back, ${profile?.username || profile?.full_name || 'Customer'}.`);
      
      // Store session and open the location preferences popup
      setLoggedInUser(user);
      setLoggedInProfile(profile);
      setShowLocationModal(true);
    } catch (err) {
      console.error('Login error:', err);
      const message = err.message || 'Invalid username or password. Please verify your credentials.';
      setError(message);
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleInstantDemo = (role) => {
    const { user, profile } = instantDemoLogin(role);
    toast.success(`Active demo session: Logged in as ${role === 'admin' ? 'Administrator' : 'Customer'}.`);
    setLoggedInUser(user);
    setLoggedInProfile(profile);
    setShowLocationModal(true);
  };

  const handleQuickFill = (role) => {
    if (role === 'admin') {
      setUsernameOrEmail('admin');
      setPassword('Admin123!Secure');
    } else {
      setUsernameOrEmail('customer');
      setPassword('Customer123!');
    }
    setError('');
  };

  return (
    <>
      <div className="w-full max-w-md mx-auto">
        {/* Luxury All-in-One Enclosed Card */}
        <div className="bg-white rounded-md shadow-card border border-soft-beige p-7 sm:p-10 space-y-6">
          
          {/* Brand Mark & Titles inside the card */}
          <div className="text-center space-y-3 pb-2 border-b border-soft-beige/60">
            <Link to="/" className="inline-flex items-center justify-center p-2 rounded-full bg-warm-ivory/60 hover:bg-warm-ivory transition-colors">
              <img src="/brand/hilaara-mark-dark.svg" alt="HILAARA" className="h-8 w-auto" />
            </Link>
            <div>
              <h1 className="font-serif text-2xl sm:text-3xl font-medium tracking-tight text-charcoal">
                Sign In to HILAARA
              </h1>
              <p className="text-xs uppercase tracking-wider-brand text-muted-text mt-1 font-medium">
                Access your orders, saved addresses, and wishlist
              </p>
            </div>
          </div>

          {/* Form */}
          <form className="space-y-4" onSubmit={handleSubmit}>
            {error && (
              <div className="p-3 bg-status-error/10 border border-status-error/25 rounded-xs text-xs text-status-error font-medium">
                {error}
              </div>
            )}

            <Input
              label="Username or Email Address"
              type="text"
              required
              autoComplete="username"
              icon={User}
              value={usernameOrEmail}
              onChange={(e) => setUsernameOrEmail(e.target.value)}
              placeholder="e.g. abdalle13 or admin@hilaara.com"
            />

            <div className="space-y-1">
              <Input
                label="Password"
                type="password"
                required
                autoComplete="current-password"
                icon={Lock}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
              />
              <div className="flex justify-end pt-1">
                <Link
                  to="/forgot-password"
                  className="text-xs text-muted-text hover:text-charcoal transition-colors underline"
                >
                  Forgot your password?
                </Link>
              </div>
            </div>

            <Button
              type="submit"
              variant="primary"
              size="lg"
              className="w-full mt-2"
              isLoading={isLoading}
              icon={ArrowRight}
              iconPosition="right"
            >
              Sign In
            </Button>
          </form>

          {/* 1-Click Instant Demo Login & Quick Fill */}
          <div className="pt-4 border-t border-soft-beige/80 space-y-3">
            <div className="flex items-center justify-between text-xs text-muted-text font-medium">
              <span className="flex items-center gap-1.5">
                <ShieldCheck className="w-3.5 h-3.5 text-muted-olive" />
                <span>Reviewer Quick Access:</span>
              </span>
              <span className="text-[10px] uppercase tracking-wider text-muted-olive font-semibold">
                1-Click Sign-In
              </span>
            </div>

            <div className="grid grid-cols-2 gap-2">
              <button
                type="button"
                onClick={() => handleInstantDemo('admin')}
                className="py-2.5 px-3 bg-charcoal text-white hover:bg-black rounded-xs text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors shadow-xs"
              >
                <Zap className="w-3.5 h-3.5 text-amber-300" />
                <span>Instant Admin</span>
              </button>
              <button
                type="button"
                onClick={() => handleInstantDemo('customer')}
                className="py-2.5 px-3 bg-soft-beige/60 hover:bg-soft-beige text-charcoal rounded-xs text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors border border-soft-beige"
              >
                <Zap className="w-3.5 h-3.5 text-muted-olive" />
                <span>Instant Patron</span>
              </button>
            </div>

            <div className="flex items-center justify-center gap-3 text-[11px] text-muted-text pt-1">
              <span>Or fill credentials:</span>
              <button
                type="button"
                onClick={() => handleQuickFill('admin')}
                className="underline hover:text-charcoal font-medium"
              >
                Fill Admin
              </button>
              <span>•</span>
              <button
                type="button"
                onClick={() => handleQuickFill('customer')}
                className="underline hover:text-charcoal font-medium"
              >
                Fill Customer
              </button>
            </div>
          </div>

          {/* Bottom Switch to Register */}
          <div className="pt-4 border-t border-soft-beige/60 text-center text-xs text-muted-text">
            <span>Do not have an account yet? </span>
            <Link to="/register" className="font-semibold text-charcoal hover:underline">
              Create an account
            </Link>
          </div>
        </div>
      </div>

      {/* Delivery Location & Preferences Popup */}
      <LocationModal
        isOpen={showLocationModal}
        user={loggedInUser}
        profile={loggedInProfile}
        onClose={() => {
          setShowLocationModal(false);
          finishLoginNavigation(loggedInProfile);
        }}
        onSave={() => {
          setShowLocationModal(false);
          toast.success('Delivery location preferences saved.');
          finishLoginNavigation(loggedInProfile);
        }}
      />
    </>
  );
};

export default LoginPage;
