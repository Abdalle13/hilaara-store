-- ============================================================================
-- HILAARA Store — Comprehensive Seed Data
-- Run this in the Supabase SQL Editor AFTER running the schema migration
-- ============================================================================

-- 1. CATEGORIES
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('cat-women-dirac', 'Women''s Dirac & Caftans', 'womens-dirac-caftans', 'Women''s Dirac & Caftans', 'women', true)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('cat-women-guntiino', 'Women''s Guntiino & Evening Wear', 'womens-guntiino-evening', 'Women''s Guntiino & Evening Wear', 'women', true)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('cat-women-shawls', 'Silk Scarves & Shashi', 'silk-scarves-shashi', 'Silk Scarves & Shashi', 'women', true)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('cat-men-caftans', 'Men''s Khamiis & Linen Caftans', 'mens-khamiis-caftans', 'Men''s Khamiis & Linen Caftans', 'men', true)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('cat-men-tailoring', 'Men''s Tailoring & Safari Blazers', 'mens-tailoring-blazers', 'Men''s Tailoring & Safari Blazers', 'men', true)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('cat-men-macawis', 'Heritage Macawis & Accessories', 'heritage-macawis-accessories', 'Heritage Macawis & Accessories', 'men', true)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;

-- 2. SHIPPING METHODS
INSERT INTO public.shipping_methods (zone_id, name, fee, estimated_delivery_time, is_active)
SELECT id, 'Standard Delivery', 3.00, '1-2 Days', true FROM public.shipping_zones WHERE name = 'Mogadishu Metropolitan'
ON CONFLICT DO NOTHING;

INSERT INTO public.shipping_methods (zone_id, name, fee, estimated_delivery_time, is_active)
SELECT id, 'Express Same-Day', 5.00, 'Same Day (Under 6 Hours)', true FROM public.shipping_zones WHERE name = 'Mogadishu Metropolitan'
ON CONFLICT DO NOTHING;

INSERT INTO public.shipping_methods (zone_id, name, fee, estimated_delivery_time, is_active)
SELECT id, 'Regional Urban Express', 7.00, '2-3 Days', true FROM public.shipping_zones WHERE name = 'Somaliland Urban'
ON CONFLICT DO NOTHING;

INSERT INTO public.shipping_methods (zone_id, name, fee, estimated_delivery_time, is_active)
SELECT id, 'Hub Delivery', 8.00, '2-4 Days', true FROM public.shipping_zones WHERE name = 'Puntland Hubs'
ON CONFLICT DO NOTHING;

INSERT INTO public.shipping_methods (zone_id, name, fee, estimated_delivery_time, is_active)
SELECT id, 'Southern Express', 10.00, '3-5 Days', true FROM public.shipping_zones WHERE name = 'Southern Centers'
ON CONFLICT DO NOTHING;

-- 3. PRODUCTS, IMAGES, VARIANTS & INVENTORY

-- Product: Somali Silk Blend Dirac & Scarf Set
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-w-01', 'cat-women-dirac', 'Somali Silk Blend Dirac & Scarf Set', 'silk-blend-dirac-scarf-set', 'Exquisitely woven silk-chiffon Dirac paired with an artisanal matching printed scarf. Features delicate gold lurex threading along the hemline and a fluid, featherweight drape designed for celebratory gatherings and formal occasions.', 'women', 95, 85, true, true, true)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w01-1', 'prod-w-01', 'file-img-w01-1', 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1000&q=85', '/catalog/silk-blend-dirac-scarf-set', 'Somali Silk Blend Dirac in Olive and Gold', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w01-2', 'prod-w-01', 'file-img-w01-2', 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=1000&q=85', '/catalog/silk-blend-dirac-scarf-set', 'Somali Silk Blend Dirac Fabric Detail', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w01-3', 'prod-w-01', 'file-img-w01-3', 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=1000&q=85', '/catalog/silk-blend-dirac-scarf-set', 'Silk Scarf Draped', 3, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w01-s-olv', 'prod-w-01', 'HLR-DIRAC-S-OLV', 'S', 'Olive Dust', '#777B62', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w01-s-olv', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w01-m-olv', 'prod-w-01', 'HLR-DIRAC-M-OLV', 'M', 'Olive Dust', '#777B62', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w01-m-olv', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w01-l-olv', 'prod-w-01', 'HLR-DIRAC-L-OLV', 'L', 'Olive Dust', '#777B62', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w01-l-olv', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w01-m-gld', 'prod-w-01', 'HLR-DIRAC-M-GLD', 'M', 'Champagne Gold', '#D4AF37', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w01-m-gld', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w01-l-gld', 'prod-w-01', 'HLR-DIRAC-L-GLD', 'L', 'Champagne Gold', '#D4AF37', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w01-l-gld', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Embroidered Gold Thread Guntiino
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-w-02', 'cat-women-guntiino', 'Embroidered Gold Thread Guntiino', 'embroidered-gold-thread-guntiino', 'Handcrafted heritage Guntiino woven with metallic golden thread accents. Tailored from a breathable cotton-silk blend with asymmetric shoulder draping, honoring traditional Somali silhouettes with modern luxury refinement.', 'women', 130, 115, true, true, false)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w02-1', 'prod-w-02', 'file-img-w02-1', 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=1000&q=85', '/catalog/embroidered-gold-thread-guntiino', 'Embroidered Gold Thread Guntiino', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w02-2', 'prod-w-02', 'file-img-w02-2', 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=1000&q=85', '/catalog/embroidered-gold-thread-guntiino', 'Gold Thread Detailing', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w02-free-crm', 'prod-w-02', 'HLR-GUNT-FREE-CRM', 'One Size', 'Crimson Ember', '#8B0000', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w02-free-crm', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w02-free-blk', 'prod-w-02', 'HLR-GUNT-FREE-BLK', 'One Size', 'Midnight Black', '#191A17', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w02-free-blk', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Chiffon Evening Caftan with Beaded Cuffs
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-w-03', 'cat-women-dirac', 'Chiffon Evening Caftan with Beaded Cuffs', 'chiffon-evening-caftan', 'Floor-length chiffon evening caftan featuring hand-stitched glass beading around the bell cuffs and collar. Lined with ultra-soft mulberry silk for unparalleled evening comfort.', 'women', 110, NULL, true, true, true)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w03-1', 'prod-w-03', 'file-img-w03-1', 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1000&q=85', '/catalog/chiffon-evening-caftan', 'Chiffon Evening Caftan', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w03-2', 'prod-w-03', 'file-img-w03-2', 'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&w=1000&q=85', '/catalog/chiffon-evening-caftan', 'Beaded Cuff Detail', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w03-s-ivory', 'prod-w-03', 'HLR-CAFT-S-IVR', 'S', 'Warm Ivory', '#F7F5EF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w03-s-ivory', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w03-m-ivory', 'prod-w-03', 'HLR-CAFT-M-IVR', 'M', 'Warm Ivory', '#F7F5EF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w03-m-ivory', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w03-l-ivory', 'prod-w-03', 'HLR-CAFT-L-IVR', 'L', 'Warm Ivory', '#F7F5EF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w03-l-ivory', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Crimson Velvet Regal Dirac
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-w-04', 'cat-women-guntiino', 'Crimson Velvet Regal Dirac', 'crimson-velvet-regal-dirac', 'Sumptuous deep-crimson silk velvet Dirac crafted for grand wedding receptions and gala evenings. Subtle metallic embroidery along the neckline catches the light with aristocratic elegance.', 'women', 145, 125, true, false, true)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w04-1', 'prod-w-04', 'file-img-w04-1', 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=1000&q=85', '/catalog/crimson-velvet-regal-dirac', 'Crimson Velvet Regal Dirac', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w04-2', 'prod-w-04', 'file-img-w04-2', 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?auto=format&fit=crop&w=1000&q=85', '/catalog/crimson-velvet-regal-dirac', 'Velvet Dirac Fabric Texture', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w04-m-crm', 'prod-w-04', 'HLR-VLV-M-CRM', 'M', 'Royal Crimson', '#6A0C14', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w04-m-crm', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w04-l-crm', 'prod-w-04', 'HLR-VLV-L-CRM', 'L', 'Royal Crimson', '#6A0C14', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w04-l-crm', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Pastel Linen Minimalist Shift Dress
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-w-05', 'cat-women-dirac', 'Pastel Linen Minimalist Shift Dress', 'pastel-linen-minimalist-shift', 'Pure organic washed linen tailored into an effortless everyday shift dress. Breathable, hypoallergenic, and crafted for the warm coastal climate of Mogadishu and Berbera.', 'women', 75, NULL, true, false, false)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-w05-1', 'prod-w-05', 'file-img-w05-1', 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&w=1000&q=85', '/catalog/pastel-linen-minimalist-shift', 'Pastel Linen Shift Dress', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w05-s-sge', 'prod-w-05', 'HLR-SHFT-S-SGE', 'S', 'Desert Sage', '#9CAF88', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w05-s-sge', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w05-m-sge', 'prod-w-05', 'HLR-SHFT-M-SGE', 'M', 'Desert Sage', '#9CAF88', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w05-m-sge', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-w05-l-sge', 'prod-w-05', 'HLR-SHFT-L-SGE', 'L', 'Desert Sage', '#9CAF88', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-w05-l-sge', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Somali Tailored Pure Linen Caftan
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-m-01', 'cat-men-caftans', 'Somali Tailored Pure Linen Caftan', 'somali-linen-caftan', 'Bespoke pure flax linen Caftan tailored with clean minimal lines. Features a mandarin collar, mother-of-pearl buttons, and structured side vents for effortless Horn of Africa prestige.', 'men', 80, NULL, true, true, true)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-m01-1', 'prod-m-01', 'file-img-m01-1', 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=1000&q=85', '/catalog/somali-linen-caftan', 'Somali Tailored Linen Caftan in Sand Beige', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-m01-2', 'prod-m-01', 'file-img-m01-2', 'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?auto=format&fit=crop&w=1000&q=85', '/catalog/somali-linen-caftan', 'Linen Caftan Collar and Fabric Detail', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m01-s-bge', 'prod-m-01', 'HLR-CAFT-S-BEG', 'S', 'Sand Beige', '#E8E2D8', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m01-s-bge', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m01-m-bge', 'prod-m-01', 'HLR-CAFT-M-BEG', 'M', 'Sand Beige', '#E8E2D8', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m01-m-bge', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m01-l-bge', 'prod-m-01', 'HLR-CAFT-L-BEG', 'L', 'Sand Beige', '#E8E2D8', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m01-l-bge', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m01-xl-bge', 'prod-m-01', 'HLR-CAFT-XL-BEG', 'XL', 'Sand Beige', '#E8E2D8', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m01-xl-bge', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m01-m-wht', 'prod-m-01', 'HLR-CAFT-M-WHT', 'M', 'Crisp White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m01-m-wht', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m01-l-wht', 'prod-m-01', 'HLR-CAFT-L-WHT', 'L', 'Crisp White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m01-l-wht', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Fine Wool Somali Safari Blazer
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-m-02', 'cat-men-tailoring', 'Fine Wool Somali Safari Blazer', 'fine-wool-somali-safari-blazer', 'Structured unlined lightweight wool blazer inspired by mid-century Horn of Africa diplomatic tailoring. Features pleated safari chest pockets, horn buttons, and an interior silk passport pocket.', 'men', 140, NULL, true, true, false)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-m02-1', 'prod-m-02', 'file-img-m02-1', 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=1000&q=85', '/catalog/fine-wool-somali-safari-blazer', 'Fine Wool Somali Safari Blazer in Charcoal', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-m02-2', 'prod-m-02', 'file-img-m02-2', 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?auto=format&fit=crop&w=1000&q=85', '/catalog/fine-wool-somali-safari-blazer', 'Safari Blazer Pocket Tailoring Detail', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m02-38r-chr', 'prod-m-02', 'HLR-BLZ-38R-CHR', '38R', 'Charcoal Grey', '#191A17', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m02-38r-chr', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m02-40r-chr', 'prod-m-02', 'HLR-BLZ-40R-CHR', '40R', 'Charcoal Grey', '#191A17', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m02-40r-chr', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m02-42r-chr', 'prod-m-02', 'HLR-BLZ-42R-CHR', '42R', 'Charcoal Grey', '#191A17', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m02-42r-chr', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m02-40r-olv', 'prod-m-02', 'HLR-BLZ-40R-OLV', '40R', 'Muted Olive', '#777B62', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m02-40r-olv', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Classic White Crisp Cotton Khamiis
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-m-03', 'cat-men-caftans', 'Classic White Crisp Cotton Khamiis', 'classic-white-cotton-khamiis', 'Impeccably tailored from 100% long-staple Egyptian cotton. Features a structured standing collar, concealed placket, and reinforced double-needle stitching for daily elegance and Friday prayer refinement.', 'men', 65, NULL, true, true, true)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-m03-1', 'prod-m-03', 'file-img-m03-1', 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?auto=format&fit=crop&w=1000&q=85', '/catalog/classic-white-cotton-khamiis', 'Classic White Cotton Khamiis', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m03-54-wht', 'prod-m-03', 'HLR-KHM-54-WHT', '54 (S)', 'Pure White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m03-54-wht', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m03-56-wht', 'prod-m-03', 'HLR-KHM-56-WHT', '56 (M)', 'Pure White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m03-56-wht', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m03-58-wht', 'prod-m-03', 'HLR-KHM-58-WHT', '58 (L)', 'Pure White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m03-58-wht', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m03-60-wht', 'prod-m-03', 'HLR-KHM-60-WHT', '60 (XL)', 'Pure White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m03-60-wht', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Woven Formal Silk Macawis Shawl
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-m-04', 'cat-men-macawis', 'Woven Formal Silk Macawis Shawl', 'formal-silk-macawis-shawl', 'Traditional heritage Macawis hand-loomed with rich geometrical borders and paired with an optional shoulder shawl. Softened finish ensures zero stiffness straight out of the package.', 'men', 55, 45, true, false, false)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-m04-1', 'prod-m-04', 'file-img-m04-1', 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?auto=format&fit=crop&w=1000&q=85', '/catalog/formal-silk-macawis-shawl', 'Woven Formal Macawis Shawl', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m04-os-navy', 'prod-m-04', 'HLR-MCW-OS-NVY', 'One Size', 'Navy Check', '#0A192F', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m04-os-navy', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m04-os-mar', 'prod-m-04', 'HLR-MCW-OS-MAR', 'One Size', 'Maroon Stripe', '#581845', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m04-os-mar', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Structured Double-Breasted Linen Vest
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-m-05', 'cat-men-tailoring', 'Structured Double-Breasted Linen Vest', 'structured-linen-vest', 'Sharp six-button double-breasted vest woven from heavy European flax. Designed to be worn over crisp white khamiis or linen shirts for modern Somali formal styling.', 'men', 90, NULL, true, false, true)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-m05-1', 'prod-m-05', 'file-img-m05-1', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=1000&q=85', '/catalog/structured-linen-vest', 'Structured Double-Breasted Linen Vest', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m05-m-khk', 'prod-m-05', 'HLR-VST-M-KHK', 'M', 'Desert Khaki', '#C3B091', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m05-m-khk', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m05-l-khk', 'prod-m-05', 'HLR-VST-L-KHK', 'L', 'Desert Khaki', '#C3B091', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m05-l-khk', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Handmade Somali Nubuck Leather Sandals
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('prod-m-06', 'cat-men-macawis', 'Handmade Somali Nubuck Leather Sandals', 'handmade-somali-nubuck-sandals', 'Full-grain Somali cowhide leather sandals with cushioned footbed and vulcanized rubber sole. Hand-burnished by master leather artisans in Mogadishu.', 'men', 70, 60, true, true, false)
ON CONFLICT (slug) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('img-m06-1', 'prod-m-06', 'file-img-m06-1', 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=1000&q=85', '/catalog/handmade-somali-nubuck-sandals', 'Somali Nubuck Leather Sandals', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m06-41-brn', 'prod-m-06', 'HLR-SND-41-BRN', 'EU 41', 'Cognac Brown', '#9A463D', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m06-41-brn', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m06-42-brn', 'prod-m-06', 'HLR-SND-42-BRN', 'EU 42', 'Cognac Brown', '#9A463D', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m06-42-brn', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('var-m06-43-brn', 'prod-m-06', 'HLR-SND-43-BRN', 'EU 43', 'Cognac Brown', '#9A463D', NULL, true)
ON CONFLICT (sku) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('var-m06-43-brn', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
