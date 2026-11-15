import React, { useState, useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ArrowRight,
  Truck,
  Shield,
  CreditCard,
  RefreshCw,
  Sparkles,
  ChevronLeft,
  ChevronRight,
  Star,
  CheckCircle2,
  Clock,
  Compass,
} from 'lucide-react';
import { supabase, isSupabaseConfigured } from '../../lib/supabase';
import { ProductGrid } from '../../components/product/ProductGrid';
import { Button } from '../../components/common/Button';
import { REAL_PRODUCTS, REAL_CATEGORIES } from '../../data/catalog';

// ─── Animation Variants ───────────────────────────────────────────────────────
const fadeUp = {
  hidden: { opacity: 0, y: 28 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: [0.22, 1, 0.36, 1] } },
};

// ─── Hero Slides Data ──────────────────────────────────────────────────────────
const HERO_SLIDES = [
  {
    id: 'slide-women-haute',
    eyebrow: 'Horn of Africa • Private Atelier Collection',
    title: 'Elegance woven in',
    titleItalic: 'gold & silk.',
    description:
      'Artisanal silk-chiffon Dirac sets and hand-embroidered Guntiino ensembles. Fluid draping paired with delicate gold lurex threading, tailored for celebratory gatherings and sovereign moments.',
    image: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=1400&q=90',
    tag: 'Haute Dirac & Guntiino',
    featuredProduct: {
      name: 'Embroidered Gold Thread Guntiino',
      price: '$110.00',
      slug: 'embroidered-gold-thread-guntiino',
    },
    primaryCta: {
      label: "Explore Women's Haute",
      href: '/collections/womens-dirac-caftans',
    },
    secondaryCta: {
      label: 'Explore Catalog',
      href: '/shop',
    },
    badge: 'Limited Atelier Edition',
  },
  {
    id: 'slide-men-sartorial',
    eyebrow: 'Modern Sartorial Pride • 320 GSM Flax',
    title: 'Sculpted for the',
    titleItalic: 'modern sovereign.',
    description:
      'Pure Egyptian linen Khamiis, structured Safari Blazers, and woven formal Macawis. Engineered for commanding poise, effortless breathability, and timeless distinction under the Horn sun.',
    image: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=1400&q=90',
    tag: 'Sartorial Linen & Blazers',
    featuredProduct: {
      name: 'Somali Tailored Pure Linen Caftan',
      price: '$78.00',
      slug: 'tailored-pure-linen-caftan',
    },
    primaryCta: {
      label: "Explore Men's Tailoring",
      href: '/collections/mens-khamiis-caftans',
    },
    secondaryCta: {
      label: 'Safari Blazers',
      href: '/collections/mens-tailoring-blazers',
    },
    badge: 'Hand-Finished Collars',
  },
  {
    id: 'slide-women-velvet',
    eyebrow: 'Nocturne Evening Splendor',
    title: 'The undeniable',
    titleItalic: 'radiance of Hilaara.',
    description:
      'Heavy royal velvet Dirac with intricate beaded cuffs and delicate sheen. A celebration of Somali grace designed to leave an indelible impression at every formal banquet and wedding.',
    image: 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=1400&q=90',
    tag: 'Royal Velvet & Crystals',
    featuredProduct: {
      name: 'Crimson Velvet Regal Dirac',
      price: '$135.00',
      slug: 'crimson-velvet-regal-dirac',
    },
    primaryCta: {
      label: 'Discover Evening Wear',
      href: '/collections/womens-guntiino-evening',
    },
    secondaryCta: {
      label: 'New Arrivals',
      href: '/collections/new-arrivals',
    },
    badge: 'Ceremonial Masterpiece',
  },
];

// ─── Benefits Data ────────────────────────────────────────────────────────────
const BENEFITS = [
  {
    icon: Truck,
    title: 'Nationwide Express Logistics',
    desc: 'Same-day delivery in Mogadishu; 48-72h express courier to Hargeisa, Garowe, Bosaso and Kismayo.',
  },
  {
    icon: CreditCard,
    title: 'Seamless Mobile Wallets',
    desc: 'Instant checkout with Hormuud EVC Plus, Somtel eDahab, Telesom ZAAD, or Pay on Delivery.',
  },
  {
    icon: Shield,
    title: '100% Authentic Horn Fabrics',
    desc: 'Genuine silk-chiffon, pure flax linen, and artisanal embroidery verified for lasting quality.',
  },
  {
    icon: RefreshCw,
    title: 'Direct Size Guarantee',
    desc: 'Tailored dimensions with generous internal seams and simple exchanges for peace of mind.',
  },
];

// ─── Patron Testimonials ──────────────────────────────────────────────────────
const PATRON_REVIEWS = [
  {
    quote:
      'The drape of the Silk Blend Dirac is sublime. It arrived in Mogadishu within 4 hours via courier, beautifully boxed, and the EVC Plus payment was instantaneous.',
    author: 'Fadumo Xasan A.',
    city: 'Mogadishu (Waberi)',
    item: 'Somali Silk Blend Dirac & Scarf Set',
  },
  {
    quote:
      'Finding real 320 GSM pure linen Khamiis with sharp modern tailoring in the Horn was nearly impossible until HILAARA. Immaculate collar finishing.',
    author: 'Eng. Guled M. Warsame',
    city: 'Hargeisa (Jigjiga Yar)',
    item: 'Tailored Pure Linen Caftan',
  },
  {
    quote:
      'The gold thread embroidery on the Guntiino caught every eye at my sister’s wedding banquet. Truly regal craftsmanship and unmatched service.',
    author: 'Ayan Dahir Shire',
    city: 'Garowe (Puntland)',
    item: 'Embroidered Gold Thread Guntiino',
  },
];

// ─── 1. Upgraded Interactive Multi-Slide Hero ─────────────────────────────────
const EditorialHero = () => {
  const [current, setCurrent] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const slide = HERO_SLIDES[current];

  // Auto-slide every 7.5 seconds when not hovered
  useEffect(() => {
    if (isPaused) return;
    const timer = setInterval(() => {
      setCurrent((prev) => (prev + 1) % HERO_SLIDES.length);
    }, 7500);
    return () => clearInterval(timer);
  }, [isPaused]);

  const handlePrev = () => {
    setCurrent((prev) => (prev === 0 ? HERO_SLIDES.length - 1 : prev - 1));
  };

  const handleNext = () => {
    setCurrent((prev) => (prev + 1) % HERO_SLIDES.length);
  };

  return (
    <section
      className="relative bg-[#121311] text-white overflow-hidden border-b border-white/10"
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={() => setIsPaused(false)}
    >
      {/* Ambient background glows */}
      <div className="absolute top-0 right-1/4 w-[600px] h-[600px] bg-muted-olive/12 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute -bottom-24 -left-20 w-[500px] h-[500px] bg-warm-ivory/5 rounded-full blur-[100px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-14 sm:py-16 lg:py-24 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-8 items-center min-h-[580px]">
          
          {/* Left Column: Editorial Narrative (7 cols) */}
          <div className="lg:col-span-7 flex flex-col justify-center space-y-6 sm:space-y-8 text-center lg:text-left">
            <AnimatePresence mode="wait">
              <motion.div
                key={slide.id + '-text'}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -16 }}
                transition={{ duration: 0.5, ease: 'easeOut' }}
                className="space-y-6 sm:space-y-7"
              >
                {/* Eyebrow Pill */}
                <div className="inline-flex items-center gap-2.5 px-3.5 py-1.5 rounded-full bg-white/[0.06] border border-white/15 text-[11px] font-semibold uppercase tracking-widest-brand text-soft-beige backdrop-blur-md shadow-xs">
                  <span className="w-2 h-2 rounded-full bg-muted-olive animate-pulse" />
                  <span>{slide.eyebrow}</span>
                </div>

                {/* Main Headline */}
                <h1 className="font-serif text-4xl sm:text-5xl lg:text-6xl xl:text-7xl font-light leading-[1.05] tracking-tight text-white">
                  {slide.title}
                  <span className="font-serif italic font-normal block text-soft-beige mt-1.5 sm:mt-2">
                    {slide.titleItalic}
                  </span>
                </h1>

                {/* Subtitle */}
                <p className="text-soft-beige/85 text-sm sm:text-base lg:text-lg leading-relaxed max-w-xl mx-auto lg:mx-0 font-light">
                  {slide.description}
                </p>

                {/* Dual Call-to-Actions */}
                <div className="flex flex-col sm:flex-row items-center gap-3.5 sm:gap-4 justify-center lg:justify-start pt-1">
                  <Link to={slide.primaryCta.href} className="w-full sm:w-auto">
                    <Button
                      variant="white"
                      size="lg"
                      icon={ArrowRight}
                      iconPosition="right"
                      className="w-full sm:w-auto font-medium shadow-card"
                    >
                      {slide.primaryCta.label}
                    </Button>
                  </Link>
                  <Link to={slide.secondaryCta.href} className="w-full sm:w-auto">
                    <Button
                      variant="outline"
                      size="lg"
                      className="w-full sm:w-auto border-white/30 text-white hover:bg-white/10 hover:border-white/60 font-medium"
                    >
                      {slide.secondaryCta.label}
                    </Button>
                  </Link>
                </div>
              </motion.div>
            </AnimatePresence>

            {/* Slide Navigation Controls & Interactive Counter */}
            <div className="pt-6 sm:pt-8 border-t border-white/10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              {/* Slide Selector Indicators */}
              <div className="flex items-center justify-center lg:justify-start gap-2.5">
                {HERO_SLIDES.map((s, idx) => (
                  <button
                    key={s.id}
                    onClick={() => setCurrent(idx)}
                    className={`group relative flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-mono transition-all ${
                      current === idx
                        ? 'bg-white/15 text-white border border-white/30'
                        : 'text-white/40 hover:text-white/80 border border-transparent'
                    }`}
                    aria-label={`Go to slide ${idx + 1}`}
                  >
                    <span>0{idx + 1}</span>
                    {current === idx && (
                      <span className="hidden sm:inline text-[10px] font-sans uppercase tracking-wider text-soft-beige font-semibold">
                        {s.tag.split(' ')[0]}
                      </span>
                    )}
                  </button>
                ))}
              </div>

              {/* Prev / Next Buttons */}
              <div className="flex items-center justify-center lg:justify-end gap-2 text-white/70">
                <button
                  onClick={handlePrev}
                  className="w-9 h-9 rounded-full border border-white/15 bg-white/[0.04] hover:bg-white/15 hover:border-white/30 text-white flex items-center justify-center transition"
                  aria-label="Previous slide"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>
                <button
                  onClick={handleNext}
                  className="w-9 h-9 rounded-full border border-white/15 bg-white/[0.04] hover:bg-white/15 hover:border-white/30 text-white flex items-center justify-center transition"
                  aria-label="Next slide"
                >
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          {/* Right Column: Editorial Visual Canvas (5 cols) */}
          <div className="lg:col-span-5 relative flex justify-center">
            <AnimatePresence mode="wait">
              <motion.div
                key={slide.id + '-image'}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.98 }}
                transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
                className="relative w-full max-w-md lg:max-w-none aspect-[4/5] rounded-xs overflow-hidden border border-white/20 shadow-2xl group"
              >
                {/* Background Image with Slow Luxury Scale */}
                <img
                  src={slide.image}
                  alt={slide.tag}
                  className="w-full h-full object-cover object-center transform transition-transform duration-1000 group-hover:scale-105"
                  loading="eager"
                />

                {/* Vignette Gradient Scrim */}
                <div className="absolute inset-0 bg-gradient-to-t from-[#121311]/90 via-transparent to-black/25" />

                {/* Floating Top Badge */}
                <div className="absolute top-4 left-4 bg-charcoal/80 backdrop-blur-md border border-white/25 text-white text-[10px] uppercase tracking-wider-brand font-semibold px-3.5 py-1.5 rounded-full shadow-lg flex items-center gap-1.5">
                  <Sparkles className="w-3 h-3 text-soft-beige" />
                  <span>{slide.badge}</span>
                </div>

                {/* Floating Patron Rating Pill */}
                <div className="absolute top-4 right-4 bg-charcoal/80 backdrop-blur-md border border-white/20 text-white text-[11px] px-2.5 py-1 rounded-full shadow-lg flex items-center gap-1">
                  <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
                  <span className="font-semibold text-xs">4.9</span>
                </div>

                {/* Floating Bottom Product Micro-Card */}
                <div className="absolute bottom-4 left-4 right-4 bg-[#141513]/90 backdrop-blur-md border border-white/20 p-4 rounded-xs text-white shadow-2xl flex items-center justify-between">
                  <div className="space-y-0.5">
                    <span className="text-[10px] uppercase tracking-wider-brand text-soft-beige/70 block font-medium">
                      Atelier Highlight
                    </span>
                    <span className="font-serif text-sm font-semibold text-white block">
                      {slide.featuredProduct.name}
                    </span>
                    <span className="text-xs font-medium text-soft-beige">
                      {slide.featuredProduct.price}
                    </span>
                  </div>
                  <Link to={`/products/${slide.featuredProduct.slug}`}>
                    <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xs bg-white text-charcoal text-xs font-semibold uppercase tracking-wider-brand hover:bg-soft-beige transition-colors">
                      View Look <ArrowRight className="w-3.5 h-3.5" />
                    </span>
                  </Link>
                </div>
              </motion.div>
            </AnimatePresence>
          </div>
        </div>

        {/* Floating Trust Strip directly anchored to Hero */}
        <div className="mt-12 pt-6 border-t border-white/10 grid grid-cols-2 lg:grid-cols-4 gap-4 text-left">
          <div className="flex items-center gap-3 text-soft-beige/90">
            <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center shrink-0">
              <Clock className="w-4 h-4 text-soft-beige" />
            </div>
            <div>
              <span className="text-white text-xs font-semibold block">Mogadishu Same-Day</span>
              <span className="text-[11px] text-soft-beige/70">Delivered within 6 hours</span>
            </div>
          </div>

          <div className="flex items-center gap-3 text-soft-beige/90">
            <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center shrink-0">
              <CreditCard className="w-4 h-4 text-soft-beige" />
            </div>
            <div>
              <span className="text-white text-xs font-semibold block">Somali Mobile Money</span>
              <span className="text-[11px] text-soft-beige/70">EVC Plus, eDahab, ZAAD</span>
            </div>
          </div>

          <div className="flex items-center gap-3 text-soft-beige/90">
            <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center shrink-0">
              <Shield className="w-4 h-4 text-soft-beige" />
            </div>
            <div>
              <span className="text-white text-xs font-semibold block">100% Verified Quality</span>
              <span className="text-[11px] text-soft-beige/70">Pure natural flax & silk</span>
            </div>
          </div>

          <div className="flex items-center gap-3 text-soft-beige/90">
            <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center shrink-0">
              <CheckCircle2 className="w-4 h-4 text-soft-beige" />
            </div>
            <div>
              <span className="text-white text-xs font-semibold block">Doorstep Mobile Pay</span>
              <span className="text-[11px] text-soft-beige/70">Pay when courier arrives</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

// ─── 2. Infinite Typographic Marquee ──────────────────────────────────────────
const AtelierMarquee = () => {
  const marqueeItems = [
    'HILAARA ATELIER',
    'HAUTE SOMALI FASHION',
    'EXPRESS DISPATCH MOGADISHU & HARGEISA',
    'PURE EGYPTIAN LINEN & SILK CHIFFON',
    'INSTANT EVC PLUS & ZAAD CHECKOUT',
    'DOORSTEP MOBILE TRANSFER ON DELIVERY',
    'ETHICAL HORN ARTISANSHIP',
    'COMPLIMENTARY NATIONWIDE SHIPPING OVER $100',
  ];

  return (
    <div className="bg-[#191A17] text-soft-beige border-b border-soft-beige/10 py-3.5 overflow-hidden whitespace-nowrap select-none">
      <div className="inline-flex animate-marquee gap-8 items-center text-xs uppercase font-medium tracking-widest-brand">
        {marqueeItems.concat(marqueeItems).map((text, idx) => (
          <span key={idx} className="inline-flex items-center gap-8">
            <span className="hover:text-white transition-colors">{text}</span>
            <span className="text-muted-olive text-sm">✦</span>
          </span>
        ))}
      </div>
    </div>
  );
};

// ─── 3. Curated Collections Bento Grid ────────────────────────────────────────
const CollectionBento = () => (
  <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-24">
    <motion.div
      variants={fadeUp}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: '-60px' }}
      className="text-center mb-12 sm:mb-16 space-y-3"
    >
      <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-soft-beige/60 text-muted-olive text-xs font-semibold uppercase tracking-widest-brand">
        <Compass className="w-3.5 h-3.5" />
        <span>Curated Gateways</span>
      </div>
      <h2 className="font-serif text-3xl sm:text-4xl lg:text-5xl font-normal text-charcoal">
        Explore by Wardrobe Category
      </h2>
      <p className="text-muted-text text-sm sm:text-base max-w-xl mx-auto">
        Every garment represents a modern interpretation of heritage Somali design, constructed for celebration, office, and everyday poise.
      </p>
    </motion.div>

    {/* Bento Grid */}
    <div className="grid grid-cols-1 md:grid-cols-12 gap-5">
      {/* Big Card: Women's Dirac & Caftans (7 cols) */}
      <motion.div
        variants={fadeUp}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-40px' }}
        className="md:col-span-7 group relative overflow-hidden rounded-xs min-h-[380px] sm:min-h-[440px] border border-soft-beige shadow-soft"
      >
        <img
          src="https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1200&q=85"
          alt="Women's Dirac & Caftans"
          className="absolute inset-0 w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-105"
          loading="lazy"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-charcoal/90 via-charcoal/30 to-transparent" />
        <Link
          to="/collections/womens-dirac-caftans"
          className="relative z-10 p-6 sm:p-10 flex flex-col justify-end h-full text-white"
        >
          <span className="text-[11px] font-semibold uppercase tracking-widest-brand text-soft-beige/80 block mb-1">
            Haute Couture • 5 Styles
          </span>
          <h3 className="font-serif text-2xl sm:text-4xl font-normal text-white group-hover:text-soft-beige transition-colors">
            Women's Dirac & Caftans
          </h3>
          <p className="text-xs sm:text-sm text-soft-beige/80 mt-1.5 max-w-md">
            Artisanal silk chiffon, gold lurex hem finishing, and matched shashi scarves for formal occasions.
          </p>
          <span className="inline-flex items-center gap-1.5 mt-4 text-xs font-semibold uppercase tracking-wider-brand text-soft-beige group-hover:gap-2.5 transition-all">
            Discover Collection <ArrowRight className="w-3.5 h-3.5" />
          </span>
        </Link>
      </motion.div>

      {/* Right Column: 2 Stacked Cards (5 cols) */}
      <div className="md:col-span-5 grid grid-cols-1 gap-5">
        {/* Men's Tailoring */}
        <motion.div
          variants={fadeUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-40px' }}
          className="group relative overflow-hidden rounded-xs min-h-[210px] sm:min-h-[210px] border border-soft-beige shadow-soft"
        >
          <img
            src="https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80"
            alt="Men's Tailoring & Blazers"
            className="absolute inset-0 w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-105"
            loading="lazy"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-charcoal/90 via-charcoal/40 to-transparent" />
          <Link
            to="/collections/mens-tailoring-blazers"
            className="relative z-10 p-5 sm:p-6 flex flex-col justify-end h-full text-white"
          >
            <span className="text-[10px] font-semibold uppercase tracking-widest-brand text-soft-beige/80 block">
              Sartorial • 4 Styles
            </span>
            <h3 className="font-serif text-xl sm:text-2xl font-normal text-white group-hover:text-soft-beige transition-colors">
              Men's Safari Blazers & Caftans
            </h3>
            <span className="inline-flex items-center gap-1.5 mt-2 text-xs font-semibold uppercase tracking-wider-brand text-soft-beige group-hover:gap-2.5 transition-all">
              Discover <ArrowRight className="w-3.5 h-3.5" />
            </span>
          </Link>
        </motion.div>

        {/* Heritage Guntiino & Evening */}
        <motion.div
          variants={fadeUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-40px' }}
          className="group relative overflow-hidden rounded-xs min-h-[210px] sm:min-h-[210px] border border-soft-beige shadow-soft"
        >
          <img
            src="https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=800&q=80"
            alt="Guntiino & Evening Wear"
            className="absolute inset-0 w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-105"
            loading="lazy"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-charcoal/90 via-charcoal/40 to-transparent" />
          <Link
            to="/collections/womens-guntiino-evening"
            className="relative z-10 p-5 sm:p-6 flex flex-col justify-end h-full text-white"
          >
            <span className="text-[10px] font-semibold uppercase tracking-widest-brand text-soft-beige/80 block">
              Traditional Elegance • Evening
            </span>
            <h3 className="font-serif text-xl sm:text-2xl font-normal text-white group-hover:text-soft-beige transition-colors">
              Gold Guntiinos & Chiffon
            </h3>
            <span className="inline-flex items-center gap-1.5 mt-2 text-xs font-semibold uppercase tracking-wider-brand text-soft-beige group-hover:gap-2.5 transition-all">
              Discover <ArrowRight className="w-3.5 h-3.5" />
            </span>
          </Link>
        </motion.div>
      </div>
    </div>
  </section>
);

// ─── 4. Interactive Curated Catalog Showcase ──────────────────────────────────
const CuratedShowcase = () => {
  const [activeTab, setActiveTab] = useState('all');

  const filterProducts = () => {
    switch (activeTab) {
      case 'women':
        return REAL_PRODUCTS.filter((p) => p.gender === 'women');
      case 'men':
        return REAL_PRODUCTS.filter((p) => p.gender === 'men');
      case 'new':
        return REAL_PRODUCTS.filter((p) => p.is_new_arrival);
      case 'all':
      default:
        return REAL_PRODUCTS.slice(0, 8);
    }
  };

  const displayed = filterProducts();

  return (
    <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-20 border-t border-soft-beige">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-10">
        <div className="space-y-2">
          <span className="text-xs uppercase tracking-widest-brand text-muted-olive font-medium">
            Atelier Catalog
          </span>
          <h2 className="font-serif text-3xl sm:text-4xl font-normal text-charcoal">
            Featured Collection
          </h2>
        </div>

        {/* Tab Pills */}
        <div className="flex items-center gap-2 overflow-x-auto pb-2 md:pb-0 scrollbar-none">
          {[
            { id: 'all', label: 'All Highlights' },
            { id: 'women', label: "Women's Haute" },
            { id: 'men', label: "Men's Tailoring" },
            { id: 'new', label: 'New Arrivals' },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-4 py-2 rounded-full text-xs font-medium uppercase tracking-wider-brand transition-all shrink-0 ${
                activeTab === tab.id
                  ? 'bg-charcoal text-white shadow-xs'
                  : 'bg-soft-beige/50 text-muted-text hover:bg-soft-beige hover:text-charcoal'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Grid */}
      <AnimatePresence mode="wait">
        <motion.div
          key={activeTab}
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -12 }}
          transition={{ duration: 0.35 }}
        >
          <ProductGrid products={displayed} skeletonCount={4} />
        </motion.div>
      </AnimatePresence>

      <div className="mt-12 text-center">
        <Link to="/shop">
          <Button variant="outline" size="lg" icon={ArrowRight} iconPosition="right">
            View All {REAL_PRODUCTS.length} Atelier Garments
          </Button>
        </Link>
      </div>
    </section>
  );
};

// ─── 5. The HILAARA Craft & Fabric Standards ──────────────────────────────────
const CraftManifesto = () => (
  <section className="bg-[#141513] text-white py-20 lg:py-28 overflow-hidden relative">
    <div className="absolute top-1/2 left-0 w-80 h-80 bg-muted-olive/10 rounded-full blur-3xl pointer-events-none" />

    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-16 items-center">
        {/* Left: Macro Fabric Image with Floating Tag */}
        <div className="lg:col-span-5 relative">
          <div className="relative aspect-[4/5] rounded-xs overflow-hidden border border-white/15 shadow-2xl">
            <img
              src="https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=1000&q=85"
              alt="HILAARA Fabric Detail"
              className="w-full h-full object-cover"
              loading="lazy"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-charcoal/80 via-transparent to-transparent" />
            <div className="absolute bottom-6 left-6 right-6 bg-charcoal/80 backdrop-blur-md p-4 rounded-xs border border-white/20">
              <span className="text-[10px] uppercase tracking-widest-brand text-soft-beige block">
                Fabric Authenticity
              </span>
              <span className="font-serif text-sm font-semibold text-white">
                Horn Silk-Chiffon & Egyptian Pure Flax
              </span>
            </div>
          </div>
        </div>

        {/* Right: Narrative & Key Metrics */}
        <div className="lg:col-span-7 space-y-8">
          <div className="space-y-3">
            <span className="text-xs uppercase tracking-widest-brand text-soft-beige font-semibold">
              The HILAARA Standard
            </span>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-5xl font-light leading-tight text-white">
              Sartorial heritage.
              <span className="italic block text-soft-beige font-normal mt-1">
                Refined for modern distinction.
              </span>
            </h2>
          </div>

          <p className="text-soft-beige/80 text-sm sm:text-base leading-relaxed font-light">
            Every garment begins with natural fiber sourcing. In a world of synthetic mass-production, HILAARA remains committed to genuine breathability, handcrafted detailing, and generous tailoring that respects traditional Somali form while championing contemporary clean lines.
          </p>

          {/* 4 Metrics Matrix */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-6 pt-4 border-t border-white/15">
            <div>
              <span className="font-serif text-3xl lg:text-4xl font-normal text-white block">100%</span>
              <span className="text-[11px] text-soft-beige/70 uppercase tracking-wider block mt-1">
                Natural Fibers
              </span>
            </div>
            <div>
              <span className="font-serif text-3xl lg:text-4xl font-normal text-white block">&lt;6h</span>
              <span className="text-[11px] text-soft-beige/70 uppercase tracking-wider block mt-1">
                Mogadishu Dispatch
              </span>
            </div>
            <div>
              <span className="font-serif text-3xl lg:text-4xl font-normal text-white block">4</span>
              <span className="text-[11px] text-soft-beige/70 uppercase tracking-wider block mt-1">
                Mobile Wallets
              </span>
            </div>
            <div>
              <span className="font-serif text-3xl lg:text-4xl font-normal text-white block">4.9★</span>
              <span className="text-[11px] text-soft-beige/70 uppercase tracking-wider block mt-1">
                Patron Rating
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
);

// ─── 6. Patron Testimonials ───────────────────────────────────────────────────
const PatronReviews = () => (
  <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-24">
    <div className="text-center mb-12 space-y-2">
      <span className="text-xs uppercase tracking-widest-brand text-muted-olive font-semibold">
        Client Testimonials
      </span>
      <h2 className="font-serif text-3xl sm:text-4xl font-normal text-charcoal">
        Words from Our Patrons
      </h2>
    </div>

    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      {PATRON_REVIEWS.map((rev, idx) => (
        <div
          key={idx}
          className="bg-white border border-soft-beige p-6 sm:p-8 rounded-xs shadow-xs flex flex-col justify-between space-y-6"
        >
          <div className="space-y-4">
            <div className="flex items-center gap-1 text-amber-400">
              {Array.from({ length: 5 }).map((_, i) => (
                <Star key={i} className="w-3.5 h-3.5 fill-amber-400" />
              ))}
            </div>
            <p className="text-xs sm:text-sm text-charcoal/90 leading-relaxed italic">
              "{rev.quote}"
            </p>
          </div>

          <div className="pt-4 border-t border-soft-beige/60">
            <span className="text-xs font-semibold text-charcoal block">{rev.author}</span>
            <span className="text-[11px] text-muted-text block">{rev.city}</span>
            <span className="text-[10px] text-muted-olive font-medium mt-1 block">
              Purchased: {rev.item}
            </span>
          </div>
        </div>
      ))}
    </div>
  </section>
);

// ─── 7. Main Homepage Export ──────────────────────────────────────────────────
export const HomePage = () => {
  const [email, setEmail] = useState('');
  const [subscribed, setSubscribed] = useState(false);

  const handleSubscribe = (e) => {
    e.preventDefault();
    if (email) {
      setSubscribed(true);
    }
  };

  return (
    <div className="bg-warm-ivory selection:bg-charcoal selection:text-white">
      {/* 1. New Haute Editorial Multi-Slide Hero */}
      <EditorialHero />

      {/* 2. Typographic Luxury Marquee Ribbon */}
      <AtelierMarquee />

      {/* 3. Curated Gateways Bento Grid */}
      <CollectionBento />

      {/* 4. Interactive Curated Product Showcase */}
      <CuratedShowcase />

      {/* 5. Benefits Bar */}
      <section className="bg-soft-beige/40 border-y border-soft-beige py-14">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-6">
            {BENEFITS.map(({ icon: Icon, title, desc }) => (
              <div key={title} className="flex flex-col items-center text-center space-y-3">
                <div className="w-12 h-12 rounded-full bg-charcoal/8 border border-charcoal/10 flex items-center justify-center">
                  <Icon className="w-5 h-5 text-muted-olive" />
                </div>
                <div className="space-y-1">
                  <h3 className="text-sm font-semibold text-charcoal">{title}</h3>
                  <p className="text-xs text-muted-text leading-relaxed">{desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 6. The HILAARA Craft & Fabric Standards */}
      <CraftManifesto />

      {/* 7. Patron Testimonials */}
      <PatronReviews />

      {/* 8. VIP Atelier Club Newsletter */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-20 pt-10">
        <div className="bg-[#191A17] text-white border border-white/10 rounded-xs p-8 sm:p-14 text-center max-w-3xl mx-auto space-y-6 shadow-2xl relative overflow-hidden">
          <div className="absolute top-0 right-0 w-64 h-64 bg-muted-olive/15 rounded-full blur-3xl pointer-events-none" />

          <div className="relative z-10 space-y-3">
            <span className="text-[11px] uppercase tracking-widest-brand text-soft-beige font-semibold">
              The HILAARA Atelier Club
            </span>
            <h2 className="font-serif text-3xl sm:text-4xl font-light text-white leading-tight">
              Exclusive seasonal drops & private previews.
            </h2>
            <p className="text-xs sm:text-sm text-soft-beige/70 max-w-md mx-auto leading-relaxed">
              Join our private patron circle for early access to limited Dirac runs, bespoke sizing notices, and festive Eid previews.
            </p>
          </div>

          <div className="relative z-10 max-w-md mx-auto">
            {subscribed ? (
              <div className="flex items-center justify-center gap-2 text-sm text-emerald-400 font-medium py-3 bg-white/5 rounded-xs border border-white/10">
                <CheckCircle2 className="w-4 h-4" />
                <span>You are welcomed into the Atelier Club.</span>
              </div>
            ) : (
              <form onSubmit={handleSubscribe} className="flex flex-col sm:flex-row gap-2.5">
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="Enter your email address"
                  className="flex-1 px-4 py-3 text-sm bg-white/10 border border-white/20 rounded-xs text-white placeholder:text-soft-beige/40 focus:outline-none focus:ring-1 focus:ring-soft-beige focus:border-soft-beige"
                />
                <button
                  type="submit"
                  className="px-6 py-3 bg-white text-charcoal font-semibold text-xs uppercase tracking-wider-brand rounded-xs hover:bg-soft-beige transition-colors"
                >
                  Join Circle
                </button>
              </form>
            )}
          </div>
        </div>
      </section>
    </div>
  );
};

export default HomePage;
