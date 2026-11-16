import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { Heart, ShoppingBag, Eye, Check } from 'lucide-react';
import { useWishlist } from '../../context/WishlistContext';
import { useCart } from '../../context/CartContext';
import { useToast } from '../../context/ToastContext';
import { formatPrice } from '../../utils/formatters';
import { buildImageUrl } from '../../lib/imagekit';
import { cn } from '../../utils/cn';
import { Badge } from '../common/Badge';

export const ProductCard = ({ product, className }) => {
  const { toggle, isWishlisted } = useWishlist();
  const { addItem } = useCart();
  const toast = useToast();
  const navigate = useNavigate();
  const [hovered, setHovered] = useState(false);
  const [justAdded, setJustAdded] = useState(false);

  if (!product) return null;

  const getImageSrc = (img) => {
    if (!img) return null;
    if (typeof img === 'string') return img;
    return img.imagekit_url || img.url || null;
  };

  const primaryImage =
    getImageSrc(product.images?.find((img) => img?.is_primary)) ||
    getImageSrc(product.images?.[0]) ||
    product.primary_image ||
    null;

  const secondaryImage =
    getImageSrc(product.images?.find((img) => !img?.is_primary && img?.display_order > 0)) ||
    getImageSrc(product.images?.[1]) ||
    null;

  const effectivePrice = product.discount_price ?? product.base_price;
  const hasDiscount = product.discount_price && product.discount_price < product.base_price;
  const discountPct = hasDiscount
    ? Math.round(((product.base_price - product.discount_price) / product.base_price) * 100)
    : 0;

  const wishlisted = isWishlisted(product.id);

  const handleWishlistToggle = (e) => {
    e.preventDefault();
    e.stopPropagation();
    toggle(product.id);
    toast.info(wishlisted ? 'Removed from wishlist.' : 'Saved to wishlist.');
  };

  const handleQuickAdd = (e) => {
    e.preventDefault();
    e.stopPropagation();

    // Select first active variant if available
    const activeVariant = product.variants?.find((v) => v.is_active) || product.variants?.[0] || null;
    addItem(product, activeVariant, 1);
    setJustAdded(true);
    toast.success(`${product.name} added to your cart.`);
    setTimeout(() => setJustAdded(false), 2000);
  };

  const handleViewDetails = (e) => {
    e.preventDefault();
    e.stopPropagation();
    navigate(`/products/${product.slug}`);
  };

  return (
    <article
      className={cn('group relative flex flex-col', className)}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      {/* Image Container — completely clean by default, reveals actions on hover */}
      <Link
        to={`/products/${product.slug}`}
        className="relative block overflow-hidden bg-soft-beige/40 aspect-[3/4] rounded-xs"
        aria-label={`View ${product.name}`}
      >
        {/* Primary Image */}
        {primaryImage ? (
          <motion.img
            src={buildImageUrl(primaryImage, { width: 600, height: 800, quality: 85 })}
            alt={product.name}
            className="absolute inset-0 w-full h-full object-cover"
            animate={{ opacity: hovered && secondaryImage ? 0 : 1 }}
            transition={{ duration: 0.35, ease: 'easeInOut' }}
            loading="lazy"
          />
        ) : (
          <div className="absolute inset-0 w-full h-full bg-soft-beige flex items-center justify-center">
            <ShoppingBag className="w-10 h-10 text-soft-beige" />
          </div>
        )}

        {/* Secondary Hover Image */}
        {secondaryImage && (
          <motion.img
            src={buildImageUrl(secondaryImage, { width: 600, height: 800, quality: 85 })}
            alt={`${product.name} alternate view`}
            className="absolute inset-0 w-full h-full object-cover"
            animate={{ opacity: hovered ? 1 : 0 }}
            transition={{ duration: 0.35, ease: 'easeInOut' }}
            loading="lazy"
          />
        )}

        {/* Minimal Badges — only shown in top left */}
        <div className="absolute top-3 left-3 flex flex-col gap-1.5 pointer-events-none">
          {product.is_new_arrival && <Badge variant="new" size="xs">New</Badge>}
          {hasDiscount && <Badge variant="sale" size="xs">-{discountPct}%</Badge>}
        </div>

        {/* Wishlist Button — only revealed when cursor is over the card */}
        <AnimatePresence>
          {hovered && (
            <motion.button
              initial={{ opacity: 0, scale: 0.85 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.85 }}
              transition={{ duration: 0.15 }}
              onClick={handleWishlistToggle}
              whileTap={{ scale: 0.9 }}
              className={cn(
                'absolute top-3 right-3 w-8 h-8 rounded-full flex items-center justify-center transition-colors shadow-soft z-20',
                wishlisted
                  ? 'bg-charcoal text-white'
                  : 'bg-white/95 text-charcoal hover:bg-white hover:text-charcoal'
              )}
              aria-label={wishlisted ? 'Remove from wishlist' : 'Add to wishlist'}
              aria-pressed={wishlisted}
            >
              <Heart className={cn('w-3.5 h-3.5', wishlisted && 'fill-current text-rose-500')} />
            </motion.button>
          )}
        </AnimatePresence>

        {/* Quick Actions Hover Overlay — only shown when cursor is up */}
        <AnimatePresence>
          {hovered && (
            <motion.div
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 12 }}
              transition={{ duration: 0.2, ease: 'easeOut' }}
              className="absolute bottom-3 left-3 right-3 z-20 flex flex-col gap-1.5"
            >
              {/* Quick Add to Cart button */}
              <button
                type="button"
                onClick={handleQuickAdd}
                className={cn(
                  'w-full py-2.5 px-3 rounded-xs text-xs font-semibold uppercase tracking-wider-brand flex items-center justify-center gap-1.5 shadow-lg transition-all',
                  justAdded
                    ? 'bg-muted-olive text-white'
                    : 'bg-charcoal text-white hover:bg-black'
                )}
              >
                {justAdded ? (
                  <>
                    <Check className="w-3.5 h-3.5" />
                    <span>Added to Cart</span>
                  </>
                ) : (
                  <>
                    <ShoppingBag className="w-3.5 h-3.5" />
                    <span>Add to Cart</span>
                  </>
                )}
              </button>

              {/* View Details button */}
              <button
                type="button"
                onClick={handleViewDetails}
                className="w-full py-2 px-3 rounded-xs text-[11px] font-medium uppercase tracking-wider-brand bg-white/95 backdrop-blur-sm text-charcoal hover:bg-white transition-colors flex items-center justify-center gap-1 shadow-xs"
              >
                <Eye className="w-3 h-3 text-muted-text" />
                <span>View Details</span>
              </button>
            </motion.div>
          )}
        </AnimatePresence>
      </Link>

      {/* Product Info below image */}
      <div className="mt-3 space-y-1 flex-1">
        {product.category && (
          <p className="text-[11px] uppercase tracking-wider-brand text-muted-text">
            {product.category?.name || product.gender}
          </p>
        )}
        <h3 className="text-sm font-medium text-charcoal leading-snug line-clamp-2 group-hover:text-muted-olive transition-colors">
          <Link to={`/products/${product.slug}`}>{product.name}</Link>
        </h3>
        <div className="flex items-baseline gap-2 pt-0.5">
          <span className="text-sm font-semibold text-charcoal">
            {formatPrice(effectivePrice)}
          </span>
          {hasDiscount && (
            <span className="text-xs text-muted-text line-through">
              {formatPrice(product.base_price)}
            </span>
          )}
        </div>
      </div>
    </article>
  );
};

export default ProductCard;
