-- ============================================================================
-- HILAARA STORE — COMPLETE DATABASE SETUP (SCHEMA + REAL PRODUCTS SEED)
-- Run this in the Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nloetsqpdloapgvzqkqn/sql/new
-- ============================================================================

-- HILAARA Store - Complete Database Schema Migration
-- Designed for Supabase PostgreSQL 15+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. PROFILES & ROLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Helper function to check if active session user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
    AND role = 'admin'
  );
$$;

-- Protect role column against customer privilege escalation
CREATE OR REPLACE FUNCTION public.protect_profile_role()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role THEN
    IF NOT public.is_admin() THEN
      RAISE EXCEPTION 'Access denied: You cannot alter account roles.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_protect_profile_role ON public.profiles;
CREATE TRIGGER trg_protect_profile_role
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.protect_profile_role();

-- Automatically create profile record when auth.users row is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Customer'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')
  )
  ON CONFLICT (id) DO UPDATE
  SET email = EXCLUDED.email;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- 2. ADDRESSES
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    city TEXT NOT NULL,
    district TEXT NOT NULL,
    street_address TEXT NOT NULL,
    delivery_instructions TEXT,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 3. CATEGORIES & CATALOG
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    gender TEXT NOT NULL CHECK (gender IN ('men', 'women', 'unisex')),
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('men', 'women', 'unisex')),
    base_price NUMERIC(10,2) NOT NULL CHECK (base_price >= 0),
    discount_price NUMERIC(10,2) CHECK (discount_price IS NULL OR discount_price < base_price),
    is_published BOOLEAN NOT NULL DEFAULT false,
    is_featured BOOLEAN NOT NULL DEFAULT false,
    is_new_arrival BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    imagekit_file_id TEXT NOT NULL,
    imagekit_url TEXT NOT NULL,
    imagekit_path TEXT NOT NULL,
    alt_text TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    sku TEXT NOT NULL UNIQUE,
    size TEXT NOT NULL,
    color_name TEXT NOT NULL,
    color_hex TEXT NOT NULL,
    price_override NUMERIC(10,2) CHECK (price_override IS NULL OR price_override >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL UNIQUE REFERENCES public.product_variants(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    low_stock_threshold INTEGER NOT NULL DEFAULT 5,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.inventory_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_id UUID NOT NULL REFERENCES public.inventory(id) ON DELETE CASCADE,
    quantity_change INTEGER NOT NULL,
    previous_quantity INTEGER NOT NULL,
    new_quantity INTEGER NOT NULL,
    movement_type TEXT NOT NULL CHECK (movement_type IN ('purchase_deduction', 'cancellation_restock', 'manual_adjustment', 'initial_stock')),
    reference_id TEXT,
    performed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 4. SHOPPING CART & WISHLIST
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_cart_variant UNIQUE (cart_id, variant_id)
);

CREATE TABLE IF NOT EXISTS public.wishlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.wishlist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wishlist_id UUID NOT NULL REFERENCES public.wishlists(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_wishlist_product UNIQUE (wishlist_id, product_id)
);

-- ============================================================================
-- 5. SHIPPING & LOGISTICS (SOMALIA)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.shipping_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.shipping_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_id UUID NOT NULL REFERENCES public.shipping_zones(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    fee NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (fee >= 0),
    estimated_delivery_time TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 6. ORDERS & FULFILLMENT
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    shipping_method_id UUID REFERENCES public.shipping_methods(id) ON DELETE SET NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    shipping_city TEXT NOT NULL,
    shipping_district TEXT NOT NULL,
    shipping_address TEXT NOT NULL,
    delivery_instructions TEXT,
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
    delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (delivery_fee >= 0),
    discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
    currency TEXT NOT NULL DEFAULT 'USD',
    order_status TEXT NOT NULL DEFAULT 'pending' CHECK (order_status IN ('pending', 'confirmed', 'processing', 'ready_for_delivery', 'out_for_delivery', 'delivered', 'cancelled')),
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'awaiting_delivery_payment', 'paid', 'failed', 'cancelled', 'refunded')),
    payment_method TEXT NOT NULL CHECK (payment_method IN ('evc_plus', 'edahab', 'zaad', 'pay_on_delivery')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Immutable order item snapshot
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE SET NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    variant_sku TEXT NOT NULL,
    variant_size TEXT NOT NULL,
    variant_color_name TEXT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total_price NUMERIC(10,2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    payment_method TEXT NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    currency TEXT NOT NULL DEFAULT 'USD',
    status TEXT NOT NULL CHECK (status IN ('pending', 'awaiting_delivery_payment', 'paid', 'failed', 'cancelled', 'refunded')),
    transaction_reference TEXT,
    payer_phone TEXT,
    provider_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    confirmed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.payment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 7. SETTINGS & AUDIT LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.store_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT,
    old_values JSONB,
    new_values JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 8. PERFORMANCE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_published ON public.products(is_published);
CREATE INDEX IF NOT EXISTS idx_products_gender ON public.products(gender);
CREATE INDEX IF NOT EXISTS idx_product_variants_product ON public.product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_variant ON public.inventory(variant_id);
CREATE INDEX IF NOT EXISTS idx_orders_user ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON public.orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON public.payments(order_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON public.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);

-- ============================================================================
-- 9. ROW-LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- PROFILES
CREATE POLICY "Profiles viewable by owner or admin"
ON public.profiles FOR SELECT
USING (auth.uid() = id OR public.is_admin());

CREATE POLICY "Profiles editable by owner or admin"
ON public.profiles FOR UPDATE
USING (auth.uid() = id OR public.is_admin());

-- ADDRESSES
CREATE POLICY "Addresses viewable by owner or admin"
ON public.addresses FOR SELECT
USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "Addresses insertable by owner"
ON public.addresses FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Addresses modifiable by owner"
ON public.addresses FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Addresses deletable by owner"
ON public.addresses FOR DELETE
USING (auth.uid() = user_id);

-- CATEGORIES
CREATE POLICY "Active categories public read"
ON public.categories FOR SELECT
USING (is_active = true OR public.is_admin());

CREATE POLICY "Categories admin full access"
ON public.categories FOR ALL
USING (public.is_admin());

-- PRODUCTS
CREATE POLICY "Published products public read"
ON public.products FOR SELECT
USING (is_published = true OR public.is_admin());

CREATE POLICY "Products admin full access"
ON public.products FOR ALL
USING (public.is_admin());

-- PRODUCT IMAGES
CREATE POLICY "Product images public read"
ON public.product_images FOR SELECT
USING (true);

CREATE POLICY "Product images admin full access"
ON public.product_images FOR ALL
USING (public.is_admin());

-- PRODUCT VARIANTS
CREATE POLICY "Product variants public read"
ON public.product_variants FOR SELECT
USING (is_active = true OR public.is_admin());

CREATE POLICY "Product variants admin full access"
ON public.product_variants FOR ALL
USING (public.is_admin());

-- INVENTORY
CREATE POLICY "Inventory admin viewable"
ON public.inventory FOR SELECT
USING (public.is_admin());

CREATE POLICY "Inventory admin modifiable"
ON public.inventory FOR ALL
USING (public.is_admin());

CREATE POLICY "Inventory movements admin read"
ON public.inventory_movements FOR SELECT
USING (public.is_admin());

CREATE POLICY "Inventory movements admin insert"
ON public.inventory_movements FOR INSERT
WITH CHECK (public.is_admin());

-- CARTS & ITEMS
CREATE POLICY "Carts owner access"
ON public.carts FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Cart items owner access"
ON public.cart_items FOR ALL
USING (EXISTS (SELECT 1 FROM public.carts WHERE id = cart_items.cart_id AND user_id = auth.uid()));

-- WISHLISTS & ITEMS
CREATE POLICY "Wishlists owner access"
ON public.wishlists FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Wishlist items owner access"
ON public.wishlist_items FOR ALL
USING (EXISTS (SELECT 1 FROM public.wishlists WHERE id = wishlist_items.wishlist_id AND user_id = auth.uid()));

-- SHIPPING
CREATE POLICY "Shipping zones public read"
ON public.shipping_zones FOR SELECT
USING (is_active = true OR public.is_admin());

CREATE POLICY "Shipping methods public read"
ON public.shipping_methods FOR SELECT
USING (is_active = true OR public.is_admin());

CREATE POLICY "Shipping admin full access"
ON public.shipping_zones FOR ALL
USING (public.is_admin());

CREATE POLICY "Shipping methods admin full access"
ON public.shipping_methods FOR ALL
USING (public.is_admin());

-- ORDERS
CREATE POLICY "Orders viewable by customer or admin"
ON public.orders FOR SELECT
USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "Orders insertable by customer"
ON public.orders FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Orders editable by admin only"
ON public.orders FOR UPDATE
USING (public.is_admin());

-- ORDER ITEMS
CREATE POLICY "Order items viewable by customer or admin"
ON public.order_items FOR SELECT
USING (EXISTS (SELECT 1 FROM public.orders WHERE id = order_items.order_id AND (user_id = auth.uid() OR public.is_admin())));

CREATE POLICY "Order items insertable during checkout"
ON public.order_items FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.orders WHERE id = order_items.order_id AND user_id = auth.uid()));

-- PAYMENTS
CREATE POLICY "Payments viewable by customer or admin"
ON public.payments FOR SELECT
USING (EXISTS (SELECT 1 FROM public.orders WHERE id = payments.order_id AND (user_id = auth.uid() OR public.is_admin())));

CREATE POLICY "Payments insertable during checkout"
ON public.payments FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.orders WHERE id = payments.order_id AND user_id = auth.uid()));

CREATE POLICY "Payments editable by admin only"
ON public.payments FOR UPDATE
USING (public.is_admin());

-- PAYMENT EVENTS & ORDER HISTORY
CREATE POLICY "Payment events admin read"
ON public.payment_events FOR SELECT
USING (public.is_admin());

CREATE POLICY "Order status history viewable by order owner or admin"
ON public.order_status_history FOR SELECT
USING (EXISTS (SELECT 1 FROM public.orders WHERE id = order_status_history.order_id AND (user_id = auth.uid() OR public.is_admin())));

CREATE POLICY "Order status history admin insert"
ON public.order_status_history FOR INSERT
WITH CHECK (public.is_admin());

-- STORE SETTINGS
CREATE POLICY "Store settings public read"
ON public.store_settings FOR SELECT
USING (true);

CREATE POLICY "Store settings admin full access"
ON public.store_settings FOR ALL
USING (public.is_admin());

-- AUDIT LOGS
CREATE POLICY "Audit logs admin read only"
ON public.audit_logs FOR SELECT
USING (public.is_admin());

CREATE POLICY "Audit logs insertable by admin or system"
ON public.audit_logs FOR INSERT
WITH CHECK (public.is_admin() OR auth.uid() IS NOT NULL);

-- ============================================================================
-- 10. INITIAL STORE SEED (SOMALIA SHIPPING ZONES & SETTINGS)
-- ============================================================================

INSERT INTO public.shipping_zones (name, description, is_active)
VALUES 
  ('Mogadishu Metropolitan', 'Hodan, Waberi, Hamar Weyne, Bondhere, Yaqshid, Wadajir and suburbs', true),
  ('Somaliland Urban', 'Hargeisa, Borama, Berbera, and Burao', true),
  ('Puntland Hubs', 'Garowe, Bosaso, and Galkayo', true),
  ('Southern Centers', 'Kismayo and Baidoa', true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.store_settings (key, value, description)
VALUES
  ('general_info', '{"store_name": "HILAARA Store", "contact_phone": "+252 61 500 0000", "support_email": "support@hilaara.com", "currency": "USD"}'::jsonb, 'General store contact and currency configuration'),
  ('announcement_bar', '{"enabled": true, "message": "Complimentary same-day delivery across Mogadishu for orders over $100."}'::jsonb, 'Storefront top announcement bar')
ON CONFLICT (key) DO NOTHING;



-- ============================================================================
-- 11. REAL LUXURY SOMALI FASHION SEED DATA
-- ============================================================================

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


-- ============================================================================
-- 12. ADMIN ROLE ASSIGNMENT HELPER
-- After registering in the app, run the following to grant admin access:
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'abdallehussein8@gmail.com';
-- ============================================================================
