import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MapPin, Phone, CreditCard, Check, X, Shield, ArrowRight } from 'lucide-react';
import { supabase, isSupabaseConfigured } from '../../lib/supabase';
import { Button } from '../common/Button';

const SOMALIA_CITIES = [
  { value: 'Mogadishu', label: 'Mogadishu Metropolitan (Same-Day Delivery)', fee: '$3 - $5' },
  { value: 'Hargeisa', label: 'Hargeisa Urban (2-3 Days)', fee: '$7' },
  { value: 'Garowe', label: 'Garowe Hub (2-4 Days)', fee: '$8' },
  { value: 'Bosaso', label: 'Bosaso Coastal Hub (2-4 Days)', fee: '$8' },
  { value: 'Kismayo', label: 'Kismayo Southern Center (3-5 Days)', fee: '$10' },
  { value: 'Baidoa', label: 'Baidoa Regional Hub (3-5 Days)', fee: '$10' },
  { value: 'Borama', label: 'Borama Urban (2-3 Days)', fee: '$7' },
];

export const LocationModal = ({ isOpen, onClose, user, profile, onSave }) => {
  const [city, setCity] = useState(profile?.city || 'Mogadishu');
  const [district, setDistrict] = useState(profile?.district || 'Hodan');
  const [streetAddress, setStreetAddress] = useState(profile?.street_address || '');
  const [phone, setPhone] = useState(profile?.phone || '');
  const [wallet, setWallet] = useState('evc_plus');
  const [isSaving, setIsSaving] = useState(false);

  if (!isOpen) return null;

  const handleSave = async (e) => {
    e.preventDefault();
    setIsSaving(true);

    try {
      if (isSupabaseConfigured && user?.id) {
        // Upsert address record
        await supabase.from('addresses').insert({
          user_id: user.id,
          full_name: profile?.full_name || profile?.username || 'Customer',
          phone: phone || profile?.phone || '',
          city,
          district,
          street_address: streetAddress || 'Central District',
          is_default: true,
        });

        // Update profile phone if changed
        if (phone) {
          await supabase.from('profiles').update({ phone }).eq('id', user.id);
        }
      }

      // Save locally to localStorage as well for offline/demo resilience
      localStorage.setItem(
        'hilaara_saved_location',
        JSON.stringify({ city, district, streetAddress, phone, wallet })
      );

      if (onSave) onSave({ city, district, streetAddress, phone, wallet });
      onClose();
    } catch (err) {
      console.warn('Location save note:', err);
      // Still proceed gracefully
      onClose();
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-charcoal/70 backdrop-blur-sm">
        <motion.div
          initial={{ opacity: 0, scale: 0.95, y: 16 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 16 }}
          transition={{ duration: 0.3, ease: 'easeOut' }}
          className="bg-white rounded-md shadow-2xl border border-soft-beige w-full max-w-lg overflow-hidden relative"
        >
          {/* Header Banner */}
          <div className="bg-[#191A17] text-white p-6 relative">
            <button
              onClick={onClose}
              className="absolute top-5 right-5 text-soft-beige/70 hover:text-white transition-colors"
              aria-label="Close"
            >
              <X className="w-5 h-5" />
            </button>
            <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/10 text-[10px] uppercase tracking-widest-brand text-soft-beige mb-2">
              <MapPin className="w-3 h-3 text-muted-olive" />
              <span>Somalia Delivery Setup</span>
            </div>
            <h3 className="font-serif text-2xl font-light text-white">
              Welcome, {profile?.username || profile?.full_name || 'Patron'}.
            </h3>
            <p className="text-xs text-soft-beige/80 mt-1 font-light">
              Set your primary delivery city & mobile wallet for express dispatch and personalized courier rates.
            </p>
          </div>

          {/* Form Content */}
          <form onSubmit={handleSave} className="p-6 sm:p-8 space-y-4">
            {/* City Selection */}
            <div>
              <label className="block text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                Delivery City & Zone
              </label>
              <select
                value={city}
                onChange={(e) => setCity(e.target.value)}
                className="w-full px-3.5 py-2.5 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal"
              >
                {SOMALIA_CITIES.map((c) => (
                  <option key={c.value} value={c.value}>
                    {c.label} ({c.fee})
                  </option>
                ))}
              </select>
            </div>

            {/* District & Street Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label className="block text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                  District / Area
                </label>
                <input
                  type="text"
                  required
                  value={district}
                  onChange={(e) => setDistrict(e.target.value)}
                  placeholder="e.g. Hodan, Waberi, Jigjiga Yar"
                  className="w-full px-3.5 py-2.5 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal placeholder:text-muted-text/50"
                />
              </div>

              <div>
                <label className="block text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                  Street / Landmark
                </label>
                <input
                  type="text"
                  value={streetAddress}
                  onChange={(e) => setStreetAddress(e.target.value)}
                  placeholder="e.g. Maka Al-Mukarama Rd"
                  className="w-full px-3.5 py-2.5 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal placeholder:text-muted-text/50"
                />
              </div>
            </div>

            {/* Phone Number */}
            <div>
              <label className="block text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                Courier & Mobile Money Phone
              </label>
              <div className="relative">
                <Phone className="w-4 h-4 text-muted-text absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+252 61 500 0000 or 061..."
                  className="w-full pl-10 pr-3.5 py-2.5 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal placeholder:text-muted-text/50"
                />
              </div>
            </div>

            {/* Default Mobile Money Wallet */}
            <div>
              <label className="block text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                Preferred Mobile Wallet
              </label>
              <div className="grid grid-cols-2 gap-2 text-xs">
                {[
                  { id: 'evc_plus', label: 'EVC Plus (Hormuud)' },
                  { id: 'edahab', label: 'eDahab (Somtel)' },
                  { id: 'zaad', label: 'ZAAD (Telesom)' },
                  { id: 'pay_on_delivery', label: 'Pay on Delivery' },
                ].map((w) => (
                  <button
                    key={w.id}
                    type="button"
                    onClick={() => setWallet(w.id)}
                    className={`py-2 px-3 rounded-xs border text-left flex items-center justify-between transition-all ${
                      wallet === w.id
                        ? 'border-charcoal bg-charcoal text-white font-medium'
                        : 'border-soft-beige bg-warm-ivory/30 text-charcoal/80 hover:bg-soft-beige/50'
                    }`}
                  >
                    <span>{w.label}</span>
                    {wallet === w.id && <Check className="w-3.5 h-3.5" />}
                  </button>
                ))}
              </div>
            </div>

            {/* Action Buttons */}
            <div className="pt-3 flex flex-col sm:flex-row items-center gap-2.5">
              <Button
                type="submit"
                variant="primary"
                size="md"
                isLoading={isSaving}
                icon={ArrowRight}
                iconPosition="right"
                className="w-full sm:flex-1"
              >
                Save Preferences
              </Button>
              <button
                type="button"
                onClick={onClose}
                className="w-full sm:w-auto px-4 py-2.5 text-xs text-muted-text hover:text-charcoal transition-colors font-medium"
              >
                Skip for Now
              </button>
            </div>
          </form>
        </motion.div>
      </div>
    </AnimatePresence>
  );
};

export default LocationModal;

