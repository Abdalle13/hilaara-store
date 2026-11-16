import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MapPin, Phone, X, ArrowRight, Building, Compass, FileText } from 'lucide-react';
import { supabase, isSupabaseConfigured } from '../../lib/supabase';
import { Button } from '../common/Button';
import { SOMALIA_REGIONS, getDistrictsByRegionName } from '../../data/somaliaLocations';

export const LocationModal = ({ isOpen, onClose, user, profile, onSave }) => {
  const [selectedRegion, setSelectedRegion] = useState('Banaadir');
  const [availableDistricts, setAvailableDistricts] = useState(getDistrictsByRegionName('Banaadir'));
  const [district, setDistrict] = useState('Hodan');
  const [streetAddress, setStreetAddress] = useState(profile?.street_address || '');
  const [phone, setPhone] = useState(profile?.phone || '');
  const [deliveryNotes, setDeliveryNotes] = useState('');
  const [isSaving, setIsSaving] = useState(false);

  // Sync when profile or modal opens
  useEffect(() => {
    if (profile?.city) {
      const match = SOMALIA_REGIONS.find(
        (r) =>
          r.name.toLowerCase() === profile.city.toLowerCase() ||
          r.capital.toLowerCase() === profile.city.toLowerCase()
      );
      if (match) {
        setSelectedRegion(match.name);
        setAvailableDistricts(match.districts);
      }
    }
    if (profile?.district) {
      setDistrict(profile.district);
    }
    if (profile?.phone && !phone) {
      setPhone(profile.phone);
    }
  }, [profile, isOpen]);

  // When region changes, update available districts
  const handleRegionChange = (regionName) => {
    setSelectedRegion(regionName);
    const districts = getDistrictsByRegionName(regionName);
    setAvailableDistricts(districts);
    setDistrict(districts[0] || '');
  };

  if (!isOpen) return null;

  const handleSave = async (e) => {
    e.preventDefault();
    setIsSaving(true);

    const fullLocationData = {
      region: selectedRegion,
      city: selectedRegion,
      district,
      streetAddress: streetAddress || 'Central Area',
      phone: phone || profile?.phone || '',
      deliveryNotes,
    };

    try {
      if (isSupabaseConfigured && user?.id) {
        // Upsert address record
        await supabase.from('addresses').insert({
          user_id: user.id,
          full_name: profile?.full_name || profile?.username || 'Customer',
          phone: fullLocationData.phone,
          city: selectedRegion,
          district,
          street_address: fullLocationData.streetAddress,
          is_default: true,
        });

        // Update profile phone and city if provided
        await supabase
          .from('profiles')
          .update({
            phone: fullLocationData.phone || null,
            city: selectedRegion,
            district,
          })
          .eq('id', user.id);
      }

      // Save locally to localStorage as well
      localStorage.setItem('hilaara_saved_location', JSON.stringify(fullLocationData));

      if (onSave) onSave(fullLocationData);
      onClose();
    } catch (err) {
      console.warn('Location save note:', err);
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
          className="bg-white rounded-md shadow-2xl border border-soft-beige w-full max-w-lg overflow-hidden relative max-h-[92vh] flex flex-col"
        >
          {/* Header Banner */}
          <div className="bg-[#191A17] text-white p-6 relative flex-shrink-0">
            <button
              onClick={onClose}
              className="absolute top-5 right-5 text-soft-beige/70 hover:text-white transition-colors"
              aria-label="Close"
            >
              <X className="w-5 h-5" />
            </button>
            <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/10 text-[10px] uppercase tracking-widest-brand text-soft-beige mb-2">
              <MapPin className="w-3 h-3 text-muted-olive" />
              <span>Somalia Delivery Profile</span>
            </div>
            <h3 className="font-serif text-2xl font-light text-white">
              Delivery Details
            </h3>
            <p className="text-xs text-soft-beige/80 mt-1 font-light">
              Select your region (Gobol) and district (Degmo) across Somalia for express courier routing.
            </p>
          </div>

          {/* Form Content */}
          <form onSubmit={handleSave} className="p-6 sm:p-7 space-y-4 overflow-y-auto flex-1">
            {/* Region / Gobol Dropdown */}
            <div>
              <label className="flex items-center gap-1.5 text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                <Compass className="w-3.5 h-3.5 text-muted-olive" />
                <span>Region (Gobolka)</span>
              </label>
              <select
                value={selectedRegion}
                onChange={(e) => handleRegionChange(e.target.value)}
                className="w-full px-3.5 py-2.5 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal font-medium"
              >
                {SOMALIA_REGIONS.map((r) => (
                  <option key={r.id} value={r.name}>
                    {r.somaliName} — {r.capital} ({r.zone})
                  </option>
                ))}
              </select>
            </div>

            {/* District / Degmo Dropdown */}
            <div>
              <label className="flex items-center gap-1.5 text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                <Building className="w-3.5 h-3.5 text-muted-olive" />
                <span>District (Degmada)</span>
              </label>
              <select
                value={district}
                onChange={(e) => setDistrict(e.target.value)}
                className="w-full px-3.5 py-2.5 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal"
              >
                {availableDistricts.map((d) => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}
              </select>
            </div>

            {/* Specific Street Address / Area Landmark */}
            <div>
              <label className="block text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                Street / Landmark / House Description
              </label>
              <input
                type="text"
                value={streetAddress}
                onChange={(e) => setStreetAddress(e.target.value)}
                placeholder="e.g. Near KM4, Maka Al-Mukarama Road, opposite City Center"
                className="w-full px-3.5 py-2.5 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal placeholder:text-muted-text/50"
              />
            </div>

            {/* Delivery Contact Phone */}
            <div>
              <label className="flex items-center gap-1.5 text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                <Phone className="w-3.5 h-3.5 text-muted-olive" />
                <span>Courier Contact Phone</span>
              </label>
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="+252 61 500 0000 or 061..."
                className="w-full px-3.5 py-2.5 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal placeholder:text-muted-text/50"
              />
              <p className="text-[11px] text-muted-text mt-1">
                Used strictly by the courier upon dispatch and arrival.
              </p>
            </div>

            {/* Optional Courier Notes */}
            <div>
              <label className="flex items-center gap-1.5 text-xs uppercase tracking-wider-brand font-semibold text-charcoal mb-1.5">
                <FileText className="w-3.5 h-3.5 text-muted-olive" />
                <span>Delivery Notes for Courier (Optional)</span>
              </label>
              <textarea
                rows={2}
                value={deliveryNotes}
                onChange={(e) => setDeliveryNotes(e.target.value)}
                placeholder="e.g. Call before delivery, deliver after 2 PM, 2nd floor"
                className="w-full px-3.5 py-2 text-sm bg-warm-ivory/40 border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal text-charcoal placeholder:text-muted-text/50 resize-none"
              />
            </div>

            {/* Action Buttons */}
            <div className="pt-2 flex flex-col sm:flex-row items-center gap-2.5">
              <Button
                type="submit"
                variant="primary"
                size="md"
                isLoading={isSaving}
                icon={ArrowRight}
                iconPosition="right"
                className="w-full sm:flex-1"
              >
                Save Delivery Address
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
