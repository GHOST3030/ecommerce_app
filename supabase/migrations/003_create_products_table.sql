-- ============================================================
-- Migration: Create Products Table
-- Task:      #9 — Create Products Table
-- Depends:   categories table (Task #7)
-- Stage:     2. Database Design (Supabase)
-- ============================================================

-- ============================================================
-- 1. PRODUCTS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.products (
  id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id      UUID          NOT NULL
                                 REFERENCES public.categories(id)
                                 ON DELETE RESTRICT,
  name_en          TEXT          NOT NULL CHECK (char_length(name_en) BETWEEN 1 AND 255),
  name_ar          TEXT          NOT NULL CHECK (char_length(name_ar) BETWEEN 1 AND 255),
  description_en   TEXT          NOT NULL DEFAULT '',
  description_ar   TEXT          NOT NULL DEFAULT '',
  base_price       NUMERIC(10,2) NOT NULL CHECK (base_price >= 0),
  discount_price   NUMERIC(10,2)           CHECK (
                                   discount_price IS NULL
                                   OR (discount_price >= 0 AND discount_price < base_price)
                                 ),
  images           TEXT[]        NOT NULL DEFAULT '{}',
  is_active        BOOLEAN       NOT NULL DEFAULT TRUE,
  is_featured      BOOLEAN       NOT NULL DEFAULT FALSE,
  sort_order       INTEGER       NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 2. COMMENTS — document every column for team clarity
-- ============================================================

COMMENT ON TABLE  public.products                IS 'Core product catalog for the e-commerce app';
COMMENT ON COLUMN public.products.id             IS 'Unique product identifier';
COMMENT ON COLUMN public.products.category_id    IS 'FK → categories.id; each product belongs to one category';
COMMENT ON COLUMN public.products.name_en        IS 'Product name in English';
COMMENT ON COLUMN public.products.name_ar        IS 'Product name in Arabic';
COMMENT ON COLUMN public.products.description_en IS 'Full product description in English';
COMMENT ON COLUMN public.products.description_ar IS 'Full product description in Arabic';
COMMENT ON COLUMN public.products.base_price     IS 'Original price before any discount (2 decimal places)';
COMMENT ON COLUMN public.products.discount_price IS 'Sale price; must be < base_price when set';
COMMENT ON COLUMN public.products.images         IS 'Ordered array of Supabase Storage public URLs';
COMMENT ON COLUMN public.products.is_active      IS 'Controls visibility in storefront; false = hidden';
COMMENT ON COLUMN public.products.is_featured    IS 'Surfaces product in featured/home sections';
COMMENT ON COLUMN public.products.sort_order     IS 'Manual ordering within a category (ascending)';
COMMENT ON COLUMN public.products.created_at     IS 'Record creation timestamp (UTC)';
COMMENT ON COLUMN public.products.updated_at     IS 'Last modification timestamp (UTC); managed by trigger';

-- ============================================================
-- 3. INDEXES — optimized for storefront query patterns
-- ============================================================

-- Fetch all products in a category (most common query)
CREATE INDEX IF NOT EXISTS idx_products_category_id
  ON public.products (category_id);

-- Active-only filter (every storefront list uses this)
CREATE INDEX IF NOT EXISTS idx_products_is_active
  ON public.products (is_active);

-- Featured products section on home screen
CREATE INDEX IF NOT EXISTS idx_products_is_featured
  ON public.products (is_featured)
  WHERE is_featured = TRUE;

-- Category listing sorted by sort_order
CREATE INDEX IF NOT EXISTS idx_products_category_sort
  ON public.products (category_id, sort_order ASC)
  WHERE is_active = TRUE;

-- Full-text search support (EN + AR combined)
CREATE INDEX IF NOT EXISTS idx_products_fts
  ON public.products
  USING GIN (
    to_tsvector('simple', name_en || ' ' || name_ar)
  );

-- ============================================================
-- 4. UPDATED_AT TRIGGER
-- ============================================================

-- Reuse or create the generic set_updated_at function
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_products_set_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 5. ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- ── 5a. Public storefront: anyone can read active products ──

CREATE POLICY "products_public_read"
  ON public.products
  FOR SELECT
  USING (is_active = TRUE);

-- ── 5b. Admin full read (including inactive) ──
-- Admins see all products regardless of is_active

CREATE POLICY "products_admin_read_all"
  ON public.products
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.users u
      WHERE u.id   = auth.uid()
        AND u.role = 'admin'
    )
  );

-- ── 5c. Admin INSERT ──

CREATE POLICY "products_admin_insert"
  ON public.products
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.users u
      WHERE u.id   = auth.uid()
        AND u.role = 'admin'
    )
  );

-- ── 5d. Admin UPDATE ──

CREATE POLICY "products_admin_update"
  ON public.products
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1
      FROM public.users u
      WHERE u.id   = auth.uid()
        AND u.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.users u
      WHERE u.id   = auth.uid()
        AND u.role = 'admin'
    )
  );

-- ── 5e. Admin DELETE ──

CREATE POLICY "products_admin_delete"
  ON public.products
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1
      FROM public.users u
      WHERE u.id   = auth.uid()
        AND u.role = 'admin'
    )
  );

-- ============================================================
-- 6. HELPER VIEW — storefront-safe public products
--    Joins category for convenience; used by product listing
--    queries to avoid repeated joins in the app layer.
-- ============================================================


CREATE OR REPLACE VIEW public.v_active_products
WITH (security_invoker = on)   -- ← respects RLS of the calling user
AS
SELECT
  p.id,
  p.category_id,
  c.name_en      AS category_name_en,
  c.name_ar      AS category_name_ar,
  p.name_en,
  p.name_ar,
  p.description_en,
  p.description_ar,
  p.base_price,
  p.discount_price,
  p.images,
  p.is_featured,
  p.sort_order,
  p.created_at
FROM public.products  p
JOIN public.categories c ON c.id = p.category_id
WHERE p.is_active = TRUE
  AND c.is_active = TRUE
ORDER BY p.sort_order ASC, p.created_at DESC;

COMMENT ON VIEW public.v_active_products IS
  'Storefront view: active products joined with their active category. Read-only.';

-- ============================================================
-- 7. GRANT PERMISSIONS
-- ============================================================

-- Authenticated users: read only via RLS
GRANT SELECT ON public.products TO authenticated;
GRANT SELECT ON public.v_active_products TO authenticated;

-- Anonymous users: read only (RLS filters to is_active = true)
GRANT SELECT ON public.products TO anon;
GRANT SELECT ON public.v_active_products TO anon;

-- service_role bypasses RLS (used only server-side / admin SDK)
GRANT ALL ON public.products TO service_role;