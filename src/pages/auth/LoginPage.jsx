import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../context/ToastContext';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { User, Lock, ArrowRight, Eye, EyeOff } from 'lucide-react';
import { LocationModal } from '../../components/auth/LocationModal';

export const LoginPage = () => {
  const [usernameOrEmail, setUsernameOrEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  // Location modal state upon successful login
  const [showLocationModal, setShowLocationModal] = useState(false);
  const [loggedInUser, setLoggedInUser] = useState(null);
  const [loggedInProfile, setLoggedInProfile] = useState(null);

  const { login } = useAuth();
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

  return (
    <>
      <div className="w-full max-w-md mx-auto">
        <div className="bg-white rounded-md shadow-card border border-soft-beige p-7 sm:p-10 space-y-6">

          {/* Card Header */}
          <div className="text-center space-y-1 pb-4 border-b border-soft-beige/60">
            <h1 className="font-serif text-2xl sm:text-3xl font-medium tracking-tight text-charcoal">
              Sign In
            </h1>
            <p className="text-xs uppercase tracking-wider text-muted-text font-medium">
              Access your orders, saved addresses, and wishlist
            </p>
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
              placeholder="e.g. abdalle13 or you@domain.com"
            />

            <div className="space-y-1">
              <div className="relative">
                <Input
                  label="Password"
                  type={showPassword ? 'text' : 'password'}
                  required
                  autoComplete="current-password"
                  icon={Lock}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  tabIndex={-1}
                  onClick={() => setShowPassword((v) => !v)}
                  className="absolute right-3 top-[34px] text-muted-text hover:text-charcoal transition-colors"
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
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
