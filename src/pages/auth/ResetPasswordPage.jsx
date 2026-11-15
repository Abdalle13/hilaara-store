import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../context/ToastContext';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { Lock, ArrowRight, CheckCircle2 } from 'lucide-react';

export const ResetPasswordPage = () => {
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState('');

  const { updatePassword } = useAuth();
  const toast = useToast();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (password.length < 8) {
      setError('Password must be at least 8 characters in length.');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match. Please verify.');
      return;
    }

    setIsLoading(true);
    try {
      await updatePassword(password);
      setIsSuccess(true);
      toast.success('Your password has been updated securely.');
      setTimeout(() => {
        navigate('/login');
      }, 2500);
    } catch (err) {
      console.error('Password update error:', err);
      const message = err.message || 'Unable to update password. Your reset link may have expired.';
      setError(message);
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
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
              Set New Password
            </h1>
            <p className="text-xs uppercase tracking-wider-brand text-muted-text mt-1 font-medium">
              Create a secure password for your account
            </p>
          </div>
        </div>

        {isSuccess ? (
          <div className="text-center space-y-4 py-3">
            <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto border border-emerald-200">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <h3 className="font-serif text-lg font-medium text-charcoal">Password Updated</h3>
            <p className="text-xs text-muted-text leading-relaxed">
              Your new password has been established. Redirecting you to sign in...
            </p>
            <div className="pt-2">
              <Link to="/login">
                <Button variant="primary" size="sm">
                  Sign In Now
                </Button>
              </Link>
            </div>
          </div>
        ) : (
          <form className="space-y-4" onSubmit={handleSubmit}>
            {error && (
              <div className="p-3 bg-status-error/10 border border-status-error/20 rounded-xs text-xs text-status-error font-medium">
                {error}
              </div>
            )}

            <Input
              label="New Password (min. 8 characters)"
              type="password"
              required
              autoComplete="new-password"
              icon={Lock}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
            />

            <Input
              label="Confirm New Password"
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
              Update Password
            </Button>
          </form>
        )}

        <div className="pt-4 border-t border-soft-beige/60 text-center text-xs text-muted-text">
          <Link to="/login" className="font-semibold text-charcoal hover:underline">
            Return to Sign In
          </Link>
        </div>
      </div>
    </div>
  );
};

export default ResetPasswordPage;
