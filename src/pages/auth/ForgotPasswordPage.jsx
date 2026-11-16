import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../context/ToastContext';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { Mail, ArrowLeft, CheckCircle2 } from 'lucide-react';

export const ForgotPasswordPage = () => {
  const [email, setEmail] = useState('');
  const [targetEmail, setTargetEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [error, setError] = useState('');

  const { resetPassword } = useAuth();
  const toast = useToast();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    const cleanInput = (email || '').trim();
    if (!cleanInput) {
      setError('Please provide your registered email address or username.');
      return;
    }

    setIsLoading(true);
    try {
      const result = await resetPassword(cleanInput);
      setTargetEmail(result?.targetEmail || cleanInput);
      setIsSubmitted(true);
      toast.success('Password reset link has been dispatched to your email.');
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
        
        {/* Card Header */}
        <div className="text-center space-y-1 pb-4 border-b border-soft-beige/60">
          <h1 className="font-serif text-2xl sm:text-3xl font-medium tracking-tight text-charcoal">
            Recover Password
          </h1>
          <p className="text-xs uppercase tracking-wider text-muted-text font-medium">
            Enter your email to receive recovery instructions
          </p>
        </div>

        {isSubmitted ? (
          <div className="text-center space-y-4 py-3">
            <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto border border-emerald-200">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <h3 className="font-serif text-lg font-medium text-charcoal">Recovery Link Dispatched</h3>
            <p className="text-xs text-muted-text leading-relaxed">
              A secure password reset link has been dispatched to <span className="font-semibold text-charcoal">{targetEmail || email}</span>. Please check your inbox and spam folder.
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
              label="Registered Email or Username"
              type="text"
              required
              autoComplete="email"
              icon={Mail}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="e.g. abdalle13 or you@domain.com"
            />

            <Button
              type="submit"
              variant="primary"
              size="lg"
              className="w-full mt-2"
              isLoading={isLoading}
            >
              Verify & Send Reset Link
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
