-- ============================================================================
-- HILAARA Store — Comprehensive Seed Data
-- Run this in the Supabase SQL Editor AFTER running the schema migration
-- ============================================================================

-- 1. CATEGORIES
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('3ab52059-0c5f-4743-a1c9-1d38f76068bd', 'Women''s Dirac & Caftans', 'womens-dirac-caftans', 'Women''s Dirac & Caftans', 'women', true)
ON CONFLICT (slug) DO UPDATE SET id = EXCLUDED.id, name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('f4b38f7b-2d0e-4d40-aae8-7f26cbaebd26', 'Women''s Guntiino & Evening Wear', 'womens-guntiino-evening', 'Women''s Guntiino & Evening Wear', 'women', true)
ON CONFLICT (slug) DO UPDATE SET id = EXCLUDED.id, name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('238a5c6c-82b7-4ace-a165-44c18eec6215', 'Silk Scarves & Shashi', 'silk-scarves-shashi', 'Silk Scarves & Shashi', 'women', true)
ON CONFLICT (slug) DO UPDATE SET id = EXCLUDED.id, name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('9ab100ed-f9f2-4140-aed6-0e84a6203c52', 'Men''s Khamiis & Linen Caftans', 'mens-khamiis-caftans', 'Men''s Khamiis & Linen Caftans', 'men', true)
ON CONFLICT (slug) DO UPDATE SET id = EXCLUDED.id, name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('ed8dd344-92a8-40a1-a8db-e279b2f3f8a8', 'Men''s Tailoring & Safari Blazers', 'mens-tailoring-blazers', 'Men''s Tailoring & Safari Blazers', 'men', true)
ON CONFLICT (slug) DO UPDATE SET id = EXCLUDED.id, name = EXCLUDED.name, description = EXCLUDED.description;
INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('7d304322-d4e8-4d56-a88a-ae4b66b2a695', 'Heritage Macawis & Accessories', 'heritage-macawis-accessories', 'Heritage Macawis & Accessories', 'men', true)
ON CONFLICT (slug) DO UPDATE SET id = EXCLUDED.id, name = EXCLUDED.name, description = EXCLUDED.description;

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
VALUES ('90167343-d429-4825-a9d3-38367d345d2a', '3ab52059-0c5f-4743-a1c9-1d38f76068bd', 'Somali Silk Blend Dirac & Scarf Set', 'silk-blend-dirac-scarf-set', 'Exquisitely woven silk-chiffon Dirac paired with an artisanal matching printed scarf. Features delicate gold lurex threading along the hemline and a fluid, featherweight drape designed for celebratory gatherings and formal occasions.', 'women', 95, 85, true, true, true)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('55761a14-5085-4dcd-a8fb-901b81cfe662', '90167343-d429-4825-a9d3-38367d345d2a', 'file-img-w01-1', 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1000&q=85', '/catalog/silk-blend-dirac-scarf-set', 'Somali Silk Blend Dirac in Olive and Gold', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('a97ee45b-498c-47b7-a4b7-55658b04f796', '90167343-d429-4825-a9d3-38367d345d2a', 'file-img-w01-2', 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=1000&q=85', '/catalog/silk-blend-dirac-scarf-set', 'Somali Silk Blend Dirac Fabric Detail', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('8c26f716-2804-44b2-acb4-7b72d14fc704', '90167343-d429-4825-a9d3-38367d345d2a', 'file-img-w01-3', 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=1000&q=85', '/catalog/silk-blend-dirac-scarf-set', 'Silk Scarf Draped', 3, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('ccf11d16-9b66-464e-afd9-16082db0185e', '90167343-d429-4825-a9d3-38367d345d2a', 'HLR-DIRAC-S-OLV', 'S', 'Olive Dust', '#777B62', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('ccf11d16-9b66-464e-afd9-16082db0185e', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('b8b01ac3-2d79-4b77-a579-b19b317b78e6', '90167343-d429-4825-a9d3-38367d345d2a', 'HLR-DIRAC-M-OLV', 'M', 'Olive Dust', '#777B62', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('b8b01ac3-2d79-4b77-a579-b19b317b78e6', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('53148ad2-bde2-4011-a6d0-724747a7f652', '90167343-d429-4825-a9d3-38367d345d2a', 'HLR-DIRAC-L-OLV', 'L', 'Olive Dust', '#777B62', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('53148ad2-bde2-4011-a6d0-724747a7f652', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('e4ea1a99-83cb-469a-af0c-806da96cff5d', '90167343-d429-4825-a9d3-38367d345d2a', 'HLR-DIRAC-M-GLD', 'M', 'Champagne Gold', '#D4AF37', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('e4ea1a99-83cb-469a-af0c-806da96cff5d', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('0714ae14-0504-4e2c-a729-bd24249db86f', '90167343-d429-4825-a9d3-38367d345d2a', 'HLR-DIRAC-L-GLD', 'L', 'Champagne Gold', '#D4AF37', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('0714ae14-0504-4e2c-a729-bd24249db86f', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Embroidered Gold Thread Guntiino
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('c1e617d1-8d17-489b-a7c3-bc634b22551a', 'f4b38f7b-2d0e-4d40-aae8-7f26cbaebd26', 'Embroidered Gold Thread Guntiino', 'embroidered-gold-thread-guntiino', 'Handcrafted heritage Guntiino woven with metallic golden thread accents. Tailored from a breathable cotton-silk blend with asymmetric shoulder draping, honoring traditional Somali silhouettes with modern luxury refinement.', 'women', 130, 115, true, true, false)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('f2068ad1-bc4b-4bdd-a25d-b8fee6547df8', 'c1e617d1-8d17-489b-a7c3-bc634b22551a', 'file-img-w02-1', 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=1000&q=85', '/catalog/embroidered-gold-thread-guntiino', 'Embroidered Gold Thread Guntiino', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('58f0bb2a-1c28-47a6-ac6b-9ea86bf5ef70', 'c1e617d1-8d17-489b-a7c3-bc634b22551a', 'file-img-w02-2', 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=1000&q=85', '/catalog/embroidered-gold-thread-guntiino', 'Gold Thread Detailing', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('50113cbc-b12d-40a9-abb7-db2bebac0d2d', 'c1e617d1-8d17-489b-a7c3-bc634b22551a', 'HLR-GUNT-FREE-CRM', 'One Size', 'Crimson Ember', '#8B0000', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('50113cbc-b12d-40a9-abb7-db2bebac0d2d', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('348c7ad3-a6b9-4a04-a44e-db548039fe12', 'c1e617d1-8d17-489b-a7c3-bc634b22551a', 'HLR-GUNT-FREE-BLK', 'One Size', 'Midnight Black', '#191A17', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('348c7ad3-a6b9-4a04-a44e-db548039fe12', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Chiffon Evening Caftan with Beaded Cuffs
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('94479a71-fc35-4493-ae25-4c21704da091', '3ab52059-0c5f-4743-a1c9-1d38f76068bd', 'Chiffon Evening Caftan with Beaded Cuffs', 'chiffon-evening-caftan', 'Floor-length chiffon evening caftan featuring hand-stitched glass beading around the bell cuffs and collar. Lined with ultra-soft mulberry silk for unparalleled evening comfort.', 'women', 110, NULL, true, true, true)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('f9adebdf-c78c-47d6-a238-4ff76239dbef', '94479a71-fc35-4493-ae25-4c21704da091', 'file-img-w03-1', 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1000&q=85', '/catalog/chiffon-evening-caftan', 'Chiffon Evening Caftan', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('e7a10e66-7e3b-4504-a22f-aa29394452a5', '94479a71-fc35-4493-ae25-4c21704da091', 'file-img-w03-2', 'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&w=1000&q=85', '/catalog/chiffon-evening-caftan', 'Beaded Cuff Detail', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('1de02d84-ef82-4cde-a866-be30209dc336', '94479a71-fc35-4493-ae25-4c21704da091', 'HLR-CAFT-S-IVR', 'S', 'Warm Ivory', '#F7F5EF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('1de02d84-ef82-4cde-a866-be30209dc336', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('c2e9efdc-4511-4ebd-aa92-7a7b9c69612d', '94479a71-fc35-4493-ae25-4c21704da091', 'HLR-CAFT-M-IVR', 'M', 'Warm Ivory', '#F7F5EF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('c2e9efdc-4511-4ebd-aa92-7a7b9c69612d', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('37a938a5-b738-43b4-a5de-229f663a5b1e', '94479a71-fc35-4493-ae25-4c21704da091', 'HLR-CAFT-L-IVR', 'L', 'Warm Ivory', '#F7F5EF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('37a938a5-b738-43b4-a5de-229f663a5b1e', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Crimson Velvet Regal Dirac
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('4f641c9b-afe9-417f-ac14-fb30e27cbff8', 'f4b38f7b-2d0e-4d40-aae8-7f26cbaebd26', 'Crimson Velvet Regal Dirac', 'crimson-velvet-regal-dirac', 'Sumptuous deep-crimson silk velvet Dirac crafted for grand wedding receptions and gala evenings. Subtle metallic embroidery along the neckline catches the light with aristocratic elegance.', 'women', 145, 125, true, false, true)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('573c0c47-67a4-4209-a33c-7c89074e7d4d', '4f641c9b-afe9-417f-ac14-fb30e27cbff8', 'file-img-w04-1', 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=1000&q=85', '/catalog/crimson-velvet-regal-dirac', 'Crimson Velvet Regal Dirac', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('34404903-0ef7-40a1-ab3c-f63ec7df4420', '4f641c9b-afe9-417f-ac14-fb30e27cbff8', 'file-img-w04-2', 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?auto=format&fit=crop&w=1000&q=85', '/catalog/crimson-velvet-regal-dirac', 'Velvet Dirac Fabric Texture', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('0046106c-d79d-4c18-a987-9df34b7b0495', '4f641c9b-afe9-417f-ac14-fb30e27cbff8', 'HLR-VLV-M-CRM', 'M', 'Royal Crimson', '#6A0C14', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('0046106c-d79d-4c18-a987-9df34b7b0495', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('c72793df-9eab-49aa-af4c-5da45ff5826c', '4f641c9b-afe9-417f-ac14-fb30e27cbff8', 'HLR-VLV-L-CRM', 'L', 'Royal Crimson', '#6A0C14', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('c72793df-9eab-49aa-af4c-5da45ff5826c', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Pastel Linen Minimalist Shift Dress
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('eadb59fb-292b-47a1-abe6-d33308b1de97', '3ab52059-0c5f-4743-a1c9-1d38f76068bd', 'Pastel Linen Minimalist Shift Dress', 'pastel-linen-minimalist-shift', 'Pure organic washed linen tailored into an effortless everyday shift dress. Breathable, hypoallergenic, and crafted for the warm coastal climate of Mogadishu and Berbera.', 'women', 75, NULL, true, false, false)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('30dd7aef-e075-453b-a871-c57fb398bc2d', 'eadb59fb-292b-47a1-abe6-d33308b1de97', 'file-img-w05-1', 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&w=1000&q=85', '/catalog/pastel-linen-minimalist-shift', 'Pastel Linen Shift Dress', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('092dd4b0-abbc-423e-a41b-01579c78e3f4', 'eadb59fb-292b-47a1-abe6-d33308b1de97', 'HLR-SHFT-S-SGE', 'S', 'Desert Sage', '#9CAF88', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('092dd4b0-abbc-423e-a41b-01579c78e3f4', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('dd538c19-b89d-4462-a5c5-54b57c0ca193', 'eadb59fb-292b-47a1-abe6-d33308b1de97', 'HLR-SHFT-M-SGE', 'M', 'Desert Sage', '#9CAF88', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('dd538c19-b89d-4462-a5c5-54b57c0ca193', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('c729171e-3535-47ea-ac98-e0d0e4baf244', 'eadb59fb-292b-47a1-abe6-d33308b1de97', 'HLR-SHFT-L-SGE', 'L', 'Desert Sage', '#9CAF88', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('c729171e-3535-47ea-ac98-e0d0e4baf244', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Somali Tailored Pure Linen Caftan
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', '9ab100ed-f9f2-4140-aed6-0e84a6203c52', 'Somali Tailored Pure Linen Caftan', 'somali-linen-caftan', 'Bespoke pure flax linen Caftan tailored with clean minimal lines. Features a mandarin collar, mother-of-pearl buttons, and structured side vents for effortless Horn of Africa prestige.', 'men', 80, NULL, true, true, true)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('331886ca-60e8-41cd-a054-004b1c334211', '7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', 'file-img-m01-1', 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=1000&q=85', '/catalog/somali-linen-caftan', 'Somali Tailored Linen Caftan in Sand Beige', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('f93c5aeb-8cb0-41d1-a23c-32a501f4ee8a', '7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', 'file-img-m01-2', 'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?auto=format&fit=crop&w=1000&q=85', '/catalog/somali-linen-caftan', 'Linen Caftan Collar and Fabric Detail', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('cbabcc48-4c96-4944-acf2-1b63e0f6210f', '7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', 'HLR-CAFT-S-BEG', 'S', 'Sand Beige', '#E8E2D8', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('cbabcc48-4c96-4944-acf2-1b63e0f6210f', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('5941af9d-bf5a-4c42-a0e6-a57287a1ea85', '7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', 'HLR-CAFT-M-BEG', 'M', 'Sand Beige', '#E8E2D8', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('5941af9d-bf5a-4c42-a0e6-a57287a1ea85', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('869b62fd-c792-4fb0-a129-5c53da395376', '7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', 'HLR-CAFT-L-BEG', 'L', 'Sand Beige', '#E8E2D8', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('869b62fd-c792-4fb0-a129-5c53da395376', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('df0e56e3-c1db-47f7-a53e-233e31080fb7', '7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', 'HLR-CAFT-XL-BEG', 'XL', 'Sand Beige', '#E8E2D8', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('df0e56e3-c1db-47f7-a53e-233e31080fb7', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('aae43d40-1598-4491-aada-631ad8cc94c0', '7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', 'HLR-CAFT-M-WHT', 'M', 'Crisp White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('aae43d40-1598-4491-aada-631ad8cc94c0', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('b33cad0a-160c-4d3c-ac61-971a17247644', '7bfe0d32-6e7c-42d5-a8d9-034ac1b728d1', 'HLR-CAFT-L-WHT', 'L', 'Crisp White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('b33cad0a-160c-4d3c-ac61-971a17247644', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Fine Wool Somali Safari Blazer
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('7b53bec7-f019-4388-a07b-ec336963512e', 'ed8dd344-92a8-40a1-a8db-e279b2f3f8a8', 'Fine Wool Somali Safari Blazer', 'fine-wool-somali-safari-blazer', 'Structured unlined lightweight wool blazer inspired by mid-century Horn of Africa diplomatic tailoring. Features pleated safari chest pockets, horn buttons, and an interior silk passport pocket.', 'men', 140, NULL, true, true, false)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('dface7ce-5f5c-41f3-aaf4-4c90e9ac828f', '7b53bec7-f019-4388-a07b-ec336963512e', 'file-img-m02-1', 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=1000&q=85', '/catalog/fine-wool-somali-safari-blazer', 'Fine Wool Somali Safari Blazer in Charcoal', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('2b90acd6-b327-42bd-a807-349ae4a4f8b8', '7b53bec7-f019-4388-a07b-ec336963512e', 'file-img-m02-2', 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?auto=format&fit=crop&w=1000&q=85', '/catalog/fine-wool-somali-safari-blazer', 'Safari Blazer Pocket Tailoring Detail', 2, false)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('6ec85377-cf99-44c8-ad7a-3575c3a09b32', '7b53bec7-f019-4388-a07b-ec336963512e', 'HLR-BLZ-38R-CHR', '38R', 'Charcoal Grey', '#191A17', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('6ec85377-cf99-44c8-ad7a-3575c3a09b32', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('5d8c5c07-b635-4b23-a179-83929cba9f6d', '7b53bec7-f019-4388-a07b-ec336963512e', 'HLR-BLZ-40R-CHR', '40R', 'Charcoal Grey', '#191A17', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('5d8c5c07-b635-4b23-a179-83929cba9f6d', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('f74f5e34-1ae9-4bf2-ac84-46847c3a3d31', '7b53bec7-f019-4388-a07b-ec336963512e', 'HLR-BLZ-42R-CHR', '42R', 'Charcoal Grey', '#191A17', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('f74f5e34-1ae9-4bf2-ac84-46847c3a3d31', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('c9bf3bef-9a94-41d9-a670-c72faf60eb02', '7b53bec7-f019-4388-a07b-ec336963512e', 'HLR-BLZ-40R-OLV', '40R', 'Muted Olive', '#777B62', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('c9bf3bef-9a94-41d9-a670-c72faf60eb02', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Classic White Crisp Cotton Khamiis
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('f71646cd-7ad0-4268-a2c5-3aaf2f36e0dd', '9ab100ed-f9f2-4140-aed6-0e84a6203c52', 'Classic White Crisp Cotton Khamiis', 'classic-white-cotton-khamiis', 'Impeccably tailored from 100% long-staple Egyptian cotton. Features a structured standing collar, concealed placket, and reinforced double-needle stitching for daily elegance and Friday prayer refinement.', 'men', 65, NULL, true, true, true)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('4041b69d-e472-4ff8-a68e-58f2c53f48b4', 'f71646cd-7ad0-4268-a2c5-3aaf2f36e0dd', 'file-img-m03-1', 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?auto=format&fit=crop&w=1000&q=85', '/catalog/classic-white-cotton-khamiis', 'Classic White Cotton Khamiis', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('f997873f-c9a8-41e3-a5ad-668efa052d15', 'f71646cd-7ad0-4268-a2c5-3aaf2f36e0dd', 'HLR-KHM-54-WHT', '54 (S)', 'Pure White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('f997873f-c9a8-41e3-a5ad-668efa052d15', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('fdfaf627-e891-4229-ab08-6bf281779e74', 'f71646cd-7ad0-4268-a2c5-3aaf2f36e0dd', 'HLR-KHM-56-WHT', '56 (M)', 'Pure White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('fdfaf627-e891-4229-ab08-6bf281779e74', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('9ea0105d-7a17-4ed0-afa6-fcb0114e60a8', 'f71646cd-7ad0-4268-a2c5-3aaf2f36e0dd', 'HLR-KHM-58-WHT', '58 (L)', 'Pure White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('9ea0105d-7a17-4ed0-afa6-fcb0114e60a8', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('16181046-a0f5-42fb-abcd-973ccb590232', 'f71646cd-7ad0-4268-a2c5-3aaf2f36e0dd', 'HLR-KHM-60-WHT', '60 (XL)', 'Pure White', '#FFFFFF', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('16181046-a0f5-42fb-abcd-973ccb590232', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Woven Formal Silk Macawis Shawl
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('cea441e7-1c68-433e-a211-3d45f3d91767', '7d304322-d4e8-4d56-a88a-ae4b66b2a695', 'Woven Formal Silk Macawis Shawl', 'formal-silk-macawis-shawl', 'Traditional heritage Macawis hand-loomed with rich geometrical borders and paired with an optional shoulder shawl. Softened finish ensures zero stiffness straight out of the package.', 'men', 55, 45, true, false, false)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('a9988871-d272-48dd-a33f-96ca267fce5d', 'cea441e7-1c68-433e-a211-3d45f3d91767', 'file-img-m04-1', 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?auto=format&fit=crop&w=1000&q=85', '/catalog/formal-silk-macawis-shawl', 'Woven Formal Macawis Shawl', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('ce7fba87-6bea-4724-aacb-7d2aed492357', 'cea441e7-1c68-433e-a211-3d45f3d91767', 'HLR-MCW-OS-NVY', 'One Size', 'Navy Check', '#0A192F', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('ce7fba87-6bea-4724-aacb-7d2aed492357', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('ded07590-0561-4279-a7fc-d39e738b0d7e', 'cea441e7-1c68-433e-a211-3d45f3d91767', 'HLR-MCW-OS-MAR', 'One Size', 'Maroon Stripe', '#581845', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('ded07590-0561-4279-a7fc-d39e738b0d7e', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Structured Double-Breasted Linen Vest
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('93985ddb-2e41-4175-ace1-d4a319fe6f20', 'ed8dd344-92a8-40a1-a8db-e279b2f3f8a8', 'Structured Double-Breasted Linen Vest', 'structured-linen-vest', 'Sharp six-button double-breasted vest woven from heavy European flax. Designed to be worn over crisp white khamiis or linen shirts for modern Somali formal styling.', 'men', 90, NULL, true, false, true)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('4219b1e8-5b2a-4b5f-ab14-8eddadbaa53d', '93985ddb-2e41-4175-ace1-d4a319fe6f20', 'file-img-m05-1', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=1000&q=85', '/catalog/structured-linen-vest', 'Structured Double-Breasted Linen Vest', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('3203b42b-cc69-4865-a227-2020bf819567', '93985ddb-2e41-4175-ace1-d4a319fe6f20', 'HLR-VST-M-KHK', 'M', 'Desert Khaki', '#C3B091', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('3203b42b-cc69-4865-a227-2020bf819567', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('6603c2fe-d96e-439f-ae4d-947f2e627729', '93985ddb-2e41-4175-ace1-d4a319fe6f20', 'HLR-VST-L-KHK', 'L', 'Desert Khaki', '#C3B091', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('6603c2fe-d96e-439f-ae4d-947f2e627729', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Product: Handmade Somali Nubuck Leather Sandals
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('3bb0ac16-a762-41ba-aa89-109158096373', '7d304322-d4e8-4d56-a88a-ae4b66b2a695', 'Handmade Somali Nubuck Leather Sandals', 'handmade-somali-nubuck-sandals', 'Full-grain Somali cowhide leather sandals with cushioned footbed and vulcanized rubber sole. Hand-burnished by master leather artisans in Mogadishu.', 'men', 70, 60, true, true, false)
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('c9248200-896a-4ab5-a6ec-b6b60e6da858', '3bb0ac16-a762-41ba-aa89-109158096373', 'file-img-m06-1', 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=1000&q=85', '/catalog/handmade-somali-nubuck-sandals', 'Somali Nubuck Leather Sandals', 1, true)
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('b29a0af3-b845-453c-af8f-006d5145bcfa', '3bb0ac16-a762-41ba-aa89-109158096373', 'HLR-SND-41-BRN', 'EU 41', 'Cognac Brown', '#9A463D', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('b29a0af3-b845-453c-af8f-006d5145bcfa', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('19860df3-7d6f-46a6-a738-980c7df4a4f7', '3bb0ac16-a762-41ba-aa89-109158096373', 'HLR-SND-42-BRN', 'EU 42', 'Cognac Brown', '#9A463D', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('19860df3-7d6f-46a6-a738-980c7df4a4f7', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('64c0e50e-e11a-4c0d-a670-6a8d74cd1257', '3bb0ac16-a762-41ba-aa89-109158096373', 'HLR-SND-43-BRN', 'EU 43', 'Cognac Brown', '#9A463D', NULL, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('64c0e50e-e11a-4c0d-a670-6a8d74cd1257', 30, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
