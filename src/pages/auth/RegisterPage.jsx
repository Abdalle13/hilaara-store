import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../context/ToastContext';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { Mail, Lock, User, Phone, ArrowRight } from 'lucide-react';
import { formatSomaliPhone } from '../../utils/formatters';
import { LocationModal } from '../../components/auth/LocationModal';

export const RegisterPage = () => {
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  // Location modal upon successful signup
  const [showLocationModal, setShowLocationModal] = useState(false);
  const [registeredUser, setRegisteredUser] = useState(null);
  const [registeredProfile, setRegisteredProfile] = useState(null);

  const { register } = useAuth();
  const toast = useToast();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    const cleanUsername = username.trim().toLowerCase();

    if (!cleanUsername || !email.trim() || !password) {
      setError('Please fill in your username, email address, and password.');
      return;
    }

    // Username format check (letters, numbers, underscore)
    if (!/^[a-zA-Z0-9_]{3,24}$/.test(cleanUsername)) {
      setError('Username must be 3-24 characters containing only letters, numbers, or underscores.');
      return;
    }

    if (password.length < 8) {
      setError('Password must be at least 8 characters in length.');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match. Please re-enter.');
      return;
    }

    if (phone) {
      const phoneValidation = formatSomaliPhone(phone);
      if (!phoneValidation.isValid) {
        setError('Please provide a valid Somali phone number (e.g. +252 61 555 1234 or 0615551234).');
        return;
      }
    }

    setIsLoading(true);
    try {
      const { user, profile } = await register({
        username: cleanUsername,
        email: email.trim().toLowerCase(),
        password,
        phone: phone ? formatSomaliPhone(phone).formatted : '',
      });

      toast.success('Your HILAARA account has been created successfully.');
      setRegisteredUser(user);
      setRegisteredProfile(profile);
      setShowLocationModal(true);
    } catch (err) {
      console.error('Registration error:', err);
      const message = err.message || 'Unable to complete registration. Please try again.';
      setError(message);
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
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
                Create an Account
              </h1>
              <p className="text-xs uppercase tracking-wider-brand text-muted-text mt-1 font-medium">
                Join HILAARA for fast checkout and delivery tracking
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

            {/* Username Input */}
            <Input
              label="Username"
              type="text"
              required
              autoComplete="username"
              icon={User}
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="e.g. abdalle13"
            />

            {/* Email Address */}
            <Input
              label="Email Address"
              type="email"
              required
              autoComplete="email"
              icon={Mail}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@domain.com"
            />

            {/* Somali Mobile Number */}
            <Input
              label="Mobile Number (Somalia - Optional)"
              type="tel"
              autoComplete="tel"
              icon={Phone}
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="+252 61 500 0000 or 061..."
            />

            {/* Password */}
            <Input
              label="Password (min. 8 characters)"
              type="password"
              required
              autoComplete="new-password"
              icon={Lock}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
            />

            {/* Confirm Password */}
            <Input
              label="Confirm Password"
              type="password"
              required
              autoComplete="new-password"
              icon={Lock}
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="••••••••"
            />

            <Button
              type="submit"
              variant="primary"
              size="lg"
              className="w-full mt-2"
              isLoading={isLoading}
              icon={ArrowRight}
              iconPosition="right"
            >
              Create Account
            </Button>
          </form>

          {/* Bottom Switch to Login */}
          <div className="pt-4 border-t border-soft-beige/60 text-center text-xs text-muted-text">
            <span>Already have an account? </span>
            <Link to="/login" className="font-semibold text-charcoal hover:underline">
              Sign in here
            </Link>
          </div>
        </div>
      </div>

      {/* Location Setup Popup upon registration */}
      <LocationModal
        isOpen={showLocationModal}
        user={registeredUser}
        profile={registeredProfile}
        onClose={() => {
          setShowLocationModal(false);
          navigate('/');
        }}
        onSave={() => {
          setShowLocationModal(false);
          toast.success('Your profile and delivery location have been registered.');
          navigate('/');
        }}
      />
    </>
  );
};

export default RegisterPage;
