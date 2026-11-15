import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../context/ToastContext';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { Mail, ArrowLeft, CheckCircle2 } from 'lucide-react';

export const ForgotPasswordPage = () => {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [error, setError] = useState('');

  const { resetPassword } = useAuth();
  const toast = useToast();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!email) {
      setError('Please provide your registered email address.');
      return;
    }

    setIsLoading(true);
    try {
      await resetPassword(email);
      setIsSubmitted(true);
      toast.success('Password reset instructions have been dispatched.');
    } catch (err) {
      console.error('Password reset error:', err);
      const message = err.message || 'Unable to process reset request. Please verify the email.';
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
              Recover Password
            </h1>
            <p className="text-xs uppercase tracking-wider-brand text-muted-text mt-1 font-medium">
              Enter your email to receive recovery instructions
            </p>
          </div>
        </div>

        {isSubmitted ? (
          <div className="text-center space-y-4 py-3">
            <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto border border-emerald-200">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <h3 className="font-serif text-lg font-medium text-charcoal">Instructions Dispatched</h3>
            <p className="text-xs text-muted-text leading-relaxed">
              If an account exists for <span className="font-semibold text-charcoal">{email}</span>, you will receive a secure password recovery link shortly.
            </p>
            <div className="pt-2">
              <Link to="/login">
                <Button variant="outline" size="sm" icon={ArrowLeft} iconPosition="left">
                  Back to Sign In
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
              label="Registered Email"
              type="email"
              required
              autoComplete="email"
              icon={Mail}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@domain.com"
            />

            <Button
              type="submit"
              variant="primary"
              size="lg"
              className="w-full mt-2"
              isLoading={isLoading}
            >
              Dispatch Instructions
            </Button>
          </form>
        )}

        <div className="pt-4 border-t border-soft-beige/60 text-center text-xs text-muted-text">
          <Link to="/login" className="inline-flex items-center gap-1.5 font-medium text-charcoal hover:underline">
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Return to Sign In</span>
          </Link>
        </div>
      </div>
    </div>
  );
};

export default ForgotPasswordPage;
