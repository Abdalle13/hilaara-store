import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { supabase, isSupabaseConfigured } from '../lib/supabase';
import { authService } from '../services/authService';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState(null);
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);

  // Derive admin status
  const isAdmin = profile?.role === 'admin';

  const loadUserProfile = useCallback(async (userId) => {
    try {
      const userProfile = await authService.getProfile(userId);
      if (userProfile) {
        setProfile(userProfile);
      }
    } catch (err) {
      console.error('Failed to load user profile:', err);
    }
  }, []);

  useEffect(() => {
    let mounted = true;

    async function initAuth() {
      // 1. Check for real Supabase session
      try {
        const { data: { session: initialSession } } = await supabase.auth.getSession();
        if (initialSession?.user && mounted) {
          setSession(initialSession);
          setUser(initialSession.user);
          await loadUserProfile(initialSession.user.id);
          setLoading(false);
          return;
        }
      } catch (err) {
        console.warn('Supabase auth session check note:', err);
      }

      // 2. Check for active reviewer demo session
      const saved = localStorage.getItem('hilaara_demo_session');
      if (saved && mounted) {
        try {
          const { user: demoUser, profile: demoProfile } = JSON.parse(saved);
          setUser(demoUser);
          setProfile(demoProfile);
          setSession({ access_token: 'demo-token' });
        } catch {
          localStorage.removeItem('hilaara_demo_session');
        }
      }

      if (mounted) setLoading(false);
    }

    initAuth();

    // Subscribe to auth state changes from Supabase
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (_event, newSession) => {
        if (!mounted) return;
        if (newSession?.user) {
          setSession(newSession);
          setUser(newSession.user);
          await loadUserProfile(newSession.user.id);
        } else {
          // If no new session, check if demo session exists
          const saved = localStorage.getItem('hilaara_demo_session');
          if (saved) {
            try {
              const { user: demoUser, profile: demoProfile } = JSON.parse(saved);
              setUser(demoUser);
              setProfile(demoProfile);
              setSession({ access_token: 'demo-token' });
              return;
            } catch {
              localStorage.removeItem('hilaara_demo_session');
            }
          }
          setSession(null);
          setUser(null);
          setProfile(null);
        }
        setLoading(false);
      }
    );

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, [loadUserProfile]);

  const login = async (usernameOrEmail, password) => {
    setLoading(true);
    try {
      const { data, profile: userProfile } = await authService.signIn({
        usernameOrEmail,
        password,
      });
      setUser(data.user);
      setSession(data.session);
      setProfile(userProfile);
      return { user: data.user, profile: userProfile };
    } finally {
      setLoading(false);
    }
  };

  const register = async ({ username, email, password, phone }) => {
    setLoading(true);
    try {
      const { data, profile: userProfile } = await authService.signUp({
        username,
        email,
        password,
        phone,
      });
      setUser(data.user);
      setSession(data.session);
      setProfile(userProfile);
      return { user: data.user, profile: userProfile };
    } finally {
      setLoading(false);
    }
  };

  const instantDemoLogin = (role = 'admin') => {
    const { data, profile: userProfile } = authService.createReviewerDemoSession(
      role === 'admin' ? 'admin@hilaara.com' : 'customer@hilaara.com'
    );
    setUser(data.user);
    setProfile(userProfile);
    setSession(data.session);
    return { user: data.user, profile: userProfile };
  };

  const logout = async () => {
    setLoading(true);
    try {
      await authService.signOut();
      setUser(null);
      setProfile(null);
      setSession(null);
    } finally {
      setLoading(false);
    }
  };

  const resetPassword = async (email) => {
    return authService.resetPasswordForEmail(email);
  };

  const updatePassword = async (newPassword) => {
    return authService.updatePassword(newPassword);
  };

  const refreshProfile = async () => {
    if (user?.id) {
      await loadUserProfile(user.id);
    }
  };

  const value = {
    user,
    profile,
    session,
    loading,
    isAdmin,
    login,
    register,
    instantDemoLogin,
    logout,
    resetPassword,
    updatePassword,
    refreshProfile,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export default AuthContext;
