import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowRight, Truck, Shield, CreditCard, RefreshCw, Sparkles } from 'lucide-react';
import { supabase, isSupabaseConfigured } from '../../lib/supabase';
import { ProductGrid } from '../../components/product/ProductGrid';
import { Button } from '../../components/common/Button';
import { REAL_PRODUCTS } from '../../data/catalog';

// ─── Fade-in-up animation variant ─────────────────────────────────────────────
const fadeUp = {
  hidden: { opacity: 0, y: 24 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } },
};

// ─── Benefits data ────────────────────────────────────────────────────────────
const BENEFITS = [
  {
    icon: Truck,
    title: 'Nationwide Delivery',
    desc: 'Fast courier fulfillment to Mogadishu, Hargeisa, Garowe, Kismayo and beyond.',
  },
  {
    icon: CreditCard,
    title: 'Mobile Money Payments',
    desc: 'Pay securely via EVC Plus, eDahab, or ZAAD. No bank account required.',
  },
  {
    icon: Shield,
    title: 'Genuine Products',
    desc: 'Every garment in the HILAARA catalog is verified for quality and authenticity.',
  },
  {
    icon: RefreshCw,
    title: 'Easy Returns',
    desc: 'Straightforward returns policy so you can shop with complete confidence.',
  },
];

// ─── Editorial Hero with Right Fashion Photography ─────────────────────────────
const EditorialHero = () => (
  <section className="relative bg-[#141513] text-white overflow-hidden border-b border-white/10">
    {/* Subtle ambient luxury glow */}
    <div className="absolute top-0 right-1/4 w-96 h-96 bg-muted-olive/15 rounded-full blur-3xl pointer-events-none" />
    <div className="absolute -bottom-20 left-10 w-80 h-80 bg-warm-ivory/5 rounded-full blur-3xl pointer-events-none" />

    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-24 lg:py-32">
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
        {/* Left Editorial Copy (7 cols) */}
        <motion.div
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          className="lg:col-span-7 space-y-6 sm:space-y-8 text-center lg:text-left"
        >
          {/* Eyebrow Pill */}
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/5 border border-white/10 text-[11px] font-semibold uppercase tracking-widest-brand text-soft-beige">
            <span className="w-1.5 h-1.5 rounded-full bg-muted-olive" />
            <span>Horn of Africa • Modern Luxury Atelier</span>
          </div>

          {/* Headline */}
          <h1 className="font-serif text-4xl sm:text-5xl lg:text-6xl font-light leading-[1.08] tracking-tight text-white">
            Dressed for the
            <span className="font-serif italic font-normal block text-soft-beige mt-1">
              modern era.
            </span>
          </h1>

          {/* Description */}
          <p className="text-soft-beige/80 text-sm sm:text-base lg:text-lg leading-relaxed max-w-xl mx-auto lg:mx-0 font-light">
            Refined contemporary silhouettes crafted with pure Egyptian linen, Horn silk-chiffon, and bespoke tailoring. Purpose-built for Somalia with nationwide express courier delivery and seamless mobile money payments.
          </p>

          {/* Dual CTAs */}
          <div className="flex flex-col sm:flex-row items-center gap-3 sm:gap-4 justify-center lg:justify-start pt-2">
            <Link to="/collections/women" className="w-full sm:w-auto">
              <Button
                variant="white"
                size="lg"
                icon={ArrowRight}
                iconPosition="right"
                className="w-full sm:w-auto font-medium"
              >
                Women's Collection
              </Button>
            </Link>
            <Link to="/collections/men" className="w-full sm:w-auto">
              <Button
                variant="outline"
                size="lg"
                className="w-full sm:w-auto border-white/30 text-white hover:bg-white/10 hover:border-white/60 font-medium"
              >
                Men's Collection
              </Button>
            </Link>
          </div>

          {/* Trust Highlights */}
          <div className="pt-4 border-t border-white/10 grid grid-cols-2 sm:grid-cols-3 gap-3 text-left text-[11px] text-soft-beige/70">
            <div>
              <span className="text-white font-semibold block text-xs">Mogadishu & Hargeisa</span>
              <span>1 to 2 business days</span>
            </div>
            <div>
              <span className="text-white font-semibold block text-xs">Mobile Money</span>
              <span>EVC Plus, ZAAD, eDahab</span>
            </div>
            <div className="hidden sm:block">
              <span className="text-white font-semibold block text-xs">100% Guaranteed</span>
              <span>Authentic Somali fabrics</span>
            </div>
          </div>
        </motion.div>

        {/* Right Fashion Photography (5 cols) */}
        <motion.div
          initial={{ opacity: 0, scale: 0.96 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
          className="lg:col-span-5 relative flex justify-center"
        >
          <div className="relative w-full max-w-md lg:max-w-none aspect-[4/5] rounded-xs overflow-hidden border border-white/15 shadow-2xl group">
            {/* Main Luxury Fashion Hero Image */}
            <img
              src="https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=1200&q=90"
              alt="HILAARA Autumn Winter Haute Collection"
              className="w-full h-full object-cover object-center transform transition duration-700 group-hover:scale-105"
              loading="eager"
            />

            {/* Gradient Scrim */}
            <div className="absolute inset-0 bg-gradient-to-t from-charcoal/80 via-transparent to-black/20" />

            {/* Floating Top Pill */}
            <div className="absolute top-4 left-4 bg-charcoal/80 backdrop-blur-md border border-white/20 text-white text-[10px] uppercase tracking-wider-brand font-semibold px-3 py-1.5 rounded-full shadow-lg">
              New Atelier Drop
            </div>

            {/* Floating Bottom Card */}
            <div className="absolute bottom-4 left-4 right-4 bg-[#141513]/90 backdrop-blur-md border border-white/15 p-3.5 rounded-xs text-white shadow-xl flex items-center justify-between">
              <div>
                <span className="text-[10px] uppercase tracking-wider-brand text-soft-beige/70 block">
                  Featured Style
                </span>
                <span className="font-serif text-sm font-semibold text-white">
                  Gold Thread Guntiino & Dirac
                </span>
              </div>
              <Link to="/collections/women">
                <span className="text-xs font-semibold uppercase tracking-wider-brand text-soft-beige hover:text-white flex items-center gap-1 transition">
                  Shop <ArrowRight className="w-3.5 h-3.5" />
                </span>
              </Link>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  </section>
);

// ─── Collection Gateway cards ─────────────────────────────────────────────────
const CollectionGateway = () => (
  <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-20">
    <motion.div
      variants={fadeUp}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: '-80px' }}
      className="text-center mb-12 space-y-2"
    >
      <span className="text-xs uppercase tracking-widest-brand text-muted-olive font-medium">Explore</span>
      <h2 className="font-serif text-3xl lg:text-4xl font-medium text-charcoal">Shop by Collection</h2>
    </motion.div>

    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
      {[
        {
          label: "Men's Collection",
          sub: "Tailored linen caftans, khamiis, and safari blazers.",
          href: '/collections/men',
          image: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=900&q=80',
        },
        {
          label: "Women's Collection",
          sub: "Silk blend diracs, embroidered guntiinos, and evening caftans.",
          href: '/collections/women',
          image: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
        },
      ].map((col) => (
        <motion.div
          key={col.label}
          variants={fadeUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-60px' }}
          className="group relative overflow-hidden rounded-xs aspect-[16/9] sm:aspect-[21/9] border border-soft-beige shadow-xs"
        >
          <img
            src={col.image}
            alt={col.label}
            className="absolute inset-0 w-full h-full object-cover transform transition duration-700 group-hover:scale-105"
            loading="lazy"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-charcoal/90 via-charcoal/40 to-transparent" />
          <Link
            to={col.href}
            className="relative z-10 p-6 sm:p-8 flex flex-col justify-end h-full text-white"
          >
            <h3 className="font-serif text-2xl sm:text-3xl font-medium text-white group-hover:text-soft-beige transition-colors">
              {col.label}
            </h3>
            <p className="text-xs sm:text-sm text-soft-beige/80 mt-1">{col.sub}</p>
            <span className="inline-flex items-center gap-1.5 mt-3 text-xs font-semibold uppercase tracking-wider-brand text-soft-beige group-hover:gap-2.5 transition-all">
              Discover Pieces <ArrowRight className="w-3.5 h-3.5" />
            </span>
          </Link>
        </motion.div>
      ))}
    </div>
  </section>
);

// ─── Benefits strip ───────────────────────────────────────────────────────────
const BenefitsStrip = () => (
  <section className="bg-soft-beige/40 border-y border-soft-beige py-14">
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-6">
        {BENEFITS.map(({ icon: Icon, title, desc }) => (
          <motion.div
            key={title}
            variants={fadeUp}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: '-60px' }}
            className="flex flex-col items-center text-center space-y-3"
          >
            <div className="w-11 h-11 rounded-full bg-charcoal/8 border border-charcoal/10 flex items-center justify-center">
              <Icon className="w-5 h-5 text-muted-olive" />
            </div>
            <div className="space-y-1">
              <h3 className="text-sm font-semibold text-charcoal">{title}</h3>
              <p className="text-xs text-muted-text leading-relaxed">{desc}</p>
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  </section>
);

// ─── Main Homepage Component ──────────────────────────────────────────────────
export const HomePage = () => {
  const initialFeatured = REAL_PRODUCTS.filter((p) => p.is_featured);
  const initialNew = REAL_PRODUCTS.filter((p) => p.is_new_arrival);

  const [featuredProducts, setFeaturedProducts] = useState(initialFeatured);
  const [newArrivals, setNewArrivals] = useState(initialNew);
  const [loadingFeatured, setLoadingFeatured] = useState(false);
  const [loadingNew, setLoadingNew] = useState(false);
  const [email, setEmail] = useState('');
  const [subscribed, setSubscribed] = useState(false);

  useEffect(() => {
    if (!isSupabaseConfigured || !supabase) {
      return;
    }

    const fetchFeatured = async () => {
      try {
        const { data } = await supabase
          .from('products')
          .select(`
            id, name, slug, gender, base_price, discount_price, is_featured, is_new_arrival,
            images:product_images(imagekit_url, is_primary, display_order),
            category:categories(name, slug)
          `)
          .eq('is_published', true)
          .eq('is_featured', true)
          .order('created_at', { ascending: false })
          .limit(8);
        if (data && data.length > 0) {
          setFeaturedProducts(data);
        }
      } catch (err) {
        console.warn('Failed to fetch featured products from Supabase, using catalog:', err);
      }
    };

    const fetchNew = async () => {
      try {
        const { data } = await supabase
          .from('products')
          .select(`
            id, name, slug, gender, base_price, discount_price, is_featured, is_new_arrival,
            images:product_images(imagekit_url, is_primary, display_order),
            category:categories(name, slug)
          `)
          .eq('is_published', true)
          .eq('is_new_arrival', true)
          .order('created_at', { ascending: false })
          .limit(8);
        if (data && data.length > 0) {
          setNewArrivals(data);
        }
      } catch (err) {
        console.warn('Failed to fetch new arrivals from Supabase, using catalog:', err);
      }
    };

    fetchFeatured();
    fetchNew();
  }, []);

  const handleSubscribe = (e) => {
    e.preventDefault();
    if (email) {
      setSubscribed(true);
    }
  };

  return (
    <div className="bg-warm-ivory">
      {/* Editorial Luxury Hero with Right Photography */}
      <EditorialHero />

      {/* Collection Gateways */}
      <CollectionGateway />

      {/* Featured Products */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-20">
        <motion.div
          variants={fadeUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-80px' }}
          className="flex items-end justify-between mb-10"
        >
          <div className="space-y-2">
            <span className="text-xs uppercase tracking-widest-brand text-muted-olive font-medium">Curated Pieces</span>
            <h2 className="font-serif text-3xl lg:text-4xl font-medium text-charcoal">Featured Collection</h2>
          </div>
          <Link
            to="/collections/featured"
            className="hidden sm:flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider-brand text-charcoal hover:text-muted-olive transition-colors"
          >
            View All <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </motion.div>

        <ProductGrid products={featuredProducts} loading={loadingFeatured} skeletonCount={4} />
      </section>

      {/* Benefits */}
      <BenefitsStrip />

      {/* New Arrivals */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-20">
        <motion.div
          variants={fadeUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-80px' }}
          className="flex items-end justify-between mb-10"
        >
          <div className="space-y-2">
            <span className="text-xs uppercase tracking-widest-brand text-muted-olive font-medium">Just In</span>
            <h2 className="font-serif text-3xl lg:text-4xl font-medium text-charcoal">New Arrivals</h2>
          </div>
          <Link
            to="/collections/new-arrivals"
            className="hidden sm:flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider-brand text-charcoal hover:text-muted-olive transition-colors"
          >
            View All <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </motion.div>

        <ProductGrid products={newArrivals} loading={loadingNew} skeletonCount={4} />
      </section>

      {/* Brand Story */}
      <section className="bg-charcoal">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28">
          <motion.div
            variants={fadeUp}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: '-80px' }}
            className="max-w-2xl mx-auto text-center space-y-6"
          >
            <img src="/brand/hilaara-mark-light.svg" alt="HILAARA" className="h-12 w-auto mx-auto opacity-80" />
            <h2 className="font-serif text-3xl lg:text-4xl font-light text-white leading-tight">
              Fashion with intention.
              <br />
              <span className="italic font-medium text-soft-beige">Made for Somalia.</span>
            </h2>
            <p className="text-soft-beige/70 text-sm sm:text-base leading-relaxed">
              HILAARA brings a refined, contemporary wardrobe to Somalia. Every garment is chosen for quality, versatility, and enduring style. No shortcuts. No excess. Just clothing made to be worn with poise.
            </p>
            <div className="pt-2">
              <Link to="/shop">
                <Button variant="white" size="md" icon={ArrowRight} iconPosition="right">
                  Explore the Full Catalog
                </Button>
              </Link>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Newsletter */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-20">
        <motion.div
          variants={fadeUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-60px' }}
          className="bg-soft-beige/50 border border-soft-beige rounded-xs px-6 py-12 text-center max-w-2xl mx-auto space-y-5"
        >
          <span className="text-xs uppercase tracking-widest-brand text-muted-olive font-medium">Stay Updated</span>
          <h2 className="font-serif text-2xl lg:text-3xl font-medium text-charcoal">
            New arrivals and exclusive updates
          </h2>
          <p className="text-sm text-muted-text">
            Enter your email to receive early access to new collections and curated seasonal selections.
          </p>

          {subscribed ? (
            <div className="flex items-center justify-center gap-2 text-sm text-status-success font-medium py-2">
              <span>You are subscribed. Thank you.</span>
            </div>
          ) : (
            <form onSubmit={handleSubscribe} className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto">
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="flex-1 px-4 py-2.5 text-sm bg-white border border-soft-beige rounded-xs focus:outline-none focus:ring-1 focus:ring-charcoal focus:border-charcoal placeholder:text-muted-text/60"
                aria-label="Email address for newsletter"
              />
              <Button type="submit" variant="primary" size="md">
                Subscribe
              </Button>
            </form>
          )}
          <p className="text-xs text-muted-text/70">We respect your privacy. Unsubscribe at any time.</p>
        </motion.div>
      </section>
    </div>
  );
};

export default HomePage;
