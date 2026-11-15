import { REAL_CATEGORIES, REAL_PRODUCTS } from '../src/data/catalog.js';
import fs from 'fs';
import crypto from 'node:crypto';

// Deterministic valid UUID v4 generator
function toUUID(str) {
  const hash = crypto.createHash('md5').update('hilaara-' + str).digest('hex');
  return [
    hash.substring(0, 8),
    hash.substring(8, 12),
    '4' + hash.substring(13, 16),
    'a' + hash.substring(17, 20),
    hash.substring(20, 32)
  ].join('-');
}

let sql = `-- ============================================================================
-- HILAARA Store — Comprehensive Seed Data
-- Run this in the Supabase SQL Editor AFTER running the schema migration
-- ============================================================================

`;

// 1. Categories
sql += '-- 1. CATEGORIES\n';
for (const cat of REAL_CATEGORIES) {
  const catUUID = toUUID(cat.id);
  const desc = (cat.description || cat.name).replace(/'/g, "''");
  const name = cat.name.replace(/'/g, "''");
  sql += `INSERT INTO public.categories (id, name, slug, description, gender, is_active)
VALUES ('${catUUID}', '${name}', '${cat.slug}', '${desc}', '${cat.gender}', true)
ON CONFLICT (slug) DO UPDATE SET id = EXCLUDED.id, name = EXCLUDED.name, description = EXCLUDED.description;\n`;
}

// 2. Shipping Methods
sql += `\n-- 2. SHIPPING METHODS
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
`;

// 3. Products
sql += '\n-- 3. PRODUCTS, IMAGES, VARIANTS & INVENTORY\n';
for (const p of REAL_PRODUCTS) {
  const prodUUID = toUUID(p.id);
  const catUUID = toUUID(p.category_id);
  const disc = p.discount_price !== undefined && p.discount_price !== null ? p.discount_price : 'NULL';
  const name = p.name.replace(/'/g, "''");
  const desc = (p.description || '').replace(/'/g, "''");

  sql += `
-- Product: ${name}
INSERT INTO public.products (id, category_id, name, slug, description, gender, base_price, discount_price, is_published, is_featured, is_new_arrival)
VALUES ('${prodUUID}', '${catUUID}', '${name}', '${p.slug}', '${desc}', '${p.gender}', ${p.base_price}, ${disc}, true, ${Boolean(p.is_featured)}, ${Boolean(p.is_new_arrival)})
ON CONFLICT (slug) DO UPDATE SET
  id = EXCLUDED.id,
  category_id = EXCLUDED.category_id,
  base_price = EXCLUDED.base_price,
  discount_price = EXCLUDED.discount_price,
  is_published = true;
`;

  // Images
  for (const img of (p.images || [])) {
    const imgUUID = toUUID(img.id);
    const alt = (img.alt_text || p.name).replace(/'/g, "''");
    sql += `INSERT INTO public.product_images (id, product_id, imagekit_file_id, imagekit_url, imagekit_path, alt_text, display_order, is_primary)
VALUES ('${imgUUID}', '${prodUUID}', 'file-${img.id}', '${img.imagekit_url}', '/catalog/${p.slug}', '${alt}', ${img.display_order || 0}, ${Boolean(img.is_primary)})
ON CONFLICT (id) DO UPDATE SET imagekit_url = EXCLUDED.imagekit_url;
`;
  }

  // Variants & Inventory
  for (const v of (p.variants || [])) {
    const varUUID = toUUID(v.id);
    const pOverride = v.price_override !== undefined && v.price_override !== null ? v.price_override : 'NULL';
    const cName = (v.color_name || 'Standard').replace(/'/g, "''");
    const stock = v.stock ?? 30;

    sql += `INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price_override, is_active)
VALUES ('${varUUID}', '${prodUUID}', '${v.sku}', '${v.size}', '${cName}', '${v.color_hex}', ${pOverride}, true)
ON CONFLICT (sku) DO UPDATE SET id = EXCLUDED.id, price_override = EXCLUDED.price_override;

INSERT INTO public.inventory (variant_id, quantity, low_stock_threshold)
VALUES ('${varUUID}', ${stock}, 5)
ON CONFLICT (variant_id) DO UPDATE SET quantity = EXCLUDED.quantity;
`;
  }
}

fs.writeFileSync('./supabase_seed.sql', sql);
console.log('Successfully generated supabase_seed.sql with valid UUIDs!');
