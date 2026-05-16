-- ============================================================
-- Migration: Create Product Variants Table
-- Task:      #10 — Create Product Variants Table
-- Depends:   products table (Task #9)
-- Stage:     2. Database Design (Supabase)
-- ============================================================

-- ============================================================
-- 1. SIZE ENUM
--    Defined once here; reused by product_variants.
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'product_size') THEN
    CREATE TYPE public.product_size AS ENUM (
      'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL',
      'ONE_SIZE'
    );
  END IF;
END;
$$;

COMMENT ON TYPE public.product_size IS
  'Standard clothing sizes used across product variants';

-- ============================================================
-- 2. PRODUCT VARIANTS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.product_variants (
  id             UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id     UUID           NOT NULL
                                REFERENCES public.products(id)
                                ON DELETE CASCADE,
  sku            TEXT           NOT NULL
                                CHECK (char_length(sku) BETWEEN 1 AND 100),
  size           product_size   NOT NULL,
  color_en       TEXT           NOT NULL
                                CHECK (char_length(color_en) BETWEEN 1 AND 100),
  color_ar       TEXT           NOT NULL
                                CHECK (char_length(color_ar) BETWEEN 1 AND 100),
  color_hex      TEXT           NOT NULL
                                CHECK (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
  price          NUMERIC(10,2)  NOT NULL CHECK (price >= 0),
  discount_price NUMERIC(10,2)           CHECK (
                                  discount_price IS NULL
                                  OR (discount_price >= 0 AND discount_price < price)
                                ),
  stock          INTEGER        NOT NULL DEFAULT 0 CHECK (stock >= 0),
  is_active      BOOLEAN        NOT NULL DEFAULT TRUE,
  sort_order     INTEGER        NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  -- Each SKU must be globally unique across all variants
  CONSTRAINT uq_product_variants_sku UNIQUE (sku),

  -- A product cannot have duplicate (size, color) combinations
  CONSTRAINT uq_product_variants_product_size_color
    UNIQUE (product_id, size, color_en)
);

-- ============================================================
-- 3. COMMENTS
-- ============================================================

COMMENT ON TABLE  public.product_variants                 IS 'Size × color combinations for every product';
COMMENT ON COLUMN public.product_variants.id              IS 'Unique variant identifier';
COMMENT ON COLUMN public.product_variants.product_id      IS 'FK → products.id; cascade-deletes when product removed';
COMMENT ON COLUMN public.product_variants.sku             IS 'Stock-keeping unit; globally unique across all variants';
COMMENT ON COLUMN public.product_variants.size            IS 'Clothing size using product_size enum';
COMMENT ON COLUMN public.product_variants.color_en        IS 'Human-readable color name in English (e.g. "Navy Blue")';
COMMENT ON COLUMN public.product_variants.color_ar        IS 'Human-readable color name in Arabic';
COMMENT ON COLUMN public.product_variants.color_hex       IS 'CSS hex color for swatch rendering (e.g. #1B3A6B)';
COMMENT ON COLUMN public.product_variants.price           IS 'Variant base price; may override product base_price';
COMMENT ON COLUMN public.product_variants.discount_price  IS 'Variant sale price; must be < price when set';
COMMENT ON COLUMN public.product_variants.stock           IS 'Available inventory units; 0 = out of stock';
COMMENT ON COLUMN public.product_variants.is_active       IS 'Controls storefront visibility of this variant';
COMMENT ON COLUMN public.product_variants.sort_order      IS 'Manual ordering of variants within a product';
COMMENT ON COLUMN public.product_variants.created_at      IS 'Record creation timestamp (UTC)';
COMMENT ON COLUMN public.product_variants.updated_at      IS 'Last modification timestamp; managed by trigger';

-- ============================================================
-- 4. INDEXES
-- ============================================================

-- All variants for a product (product detail screen)
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id
  ON public.product_variants (product_id);

-- Active variants only (storefront filter)
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id_active
  ON public.product_variants (product_id, sort_order ASC)
  WHERE is_active = TRUE;

-- In-stock variants (cart / add-to-cart availability check)
CREATE INDEX IF NOT EXISTS idx_product_variants_in_stock
  ON public.product_variants (product_id)
  WHERE is_active = TRUE AND stock > 0;

-- SKU lookup (order processing / admin search)
CREATE INDEX IF NOT EXISTS idx_product_variants_sku
  ON public.product_variants (sku);

-- ============================================================
-- 5. UPDATED_AT TRIGGER
--    Reuses set_updated_at() created in Task #9 migration.
-- ============================================================

CREATE OR REPLACE TRIGGER trg_product_variants_set_updated_at
  BEFORE UPDATE ON public.product_variants
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 6. STOCK GUARD FUNCTION + TRIGGER
--    Prevents stock from going below 0 on any UPDATE.
-- ============================================================

CREATE OR REPLACE FUNCTION public.prevent_negative_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.stock < 0 THEN
    RAISE EXCEPTION
      'Stock cannot be negative for variant %', NEW.id
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.prevent_negative_stock IS
  'Guard trigger: raises an exception if an UPDATE tries to set stock < 0';

CREATE OR REPLACE TRIGGER trg_product_variants_no_negative_stock
  BEFORE UPDATE OF stock ON public.product_variants
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_negative_stock();

-- ============================================================
-- 7. ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;

-- ── 7a. Public read — active variants of active products ──

CREATE POLICY "product_variants_public_read"
  ON public.product_variants
  FOR SELECT
  USING (
    is_active = TRUE
    AND EXISTS (
      SELECT 1
      FROM public.products p
      WHERE p.id        = product_id
        AND p.is_active = TRUE
    )
  );

-- ── 7b. Admin full read (including inactive) ──

CREATE POLICY "product_variants_admin_read_all"
  ON public.product_variants
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.users u
      WHERE u.id   = auth.uid()
        AND u.role = 'admin'
    )
  );

-- ── 7c. Admin INSERT ──

CREATE POLICY "product_variants_admin_insert"
  ON public.product_variants
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.users u
      WHERE u.id   = auth.uid()
        AND u.role = 'admin'
    )
  );

-- ── 7d. Admin UPDATE ──

CREATE POLICY "product_variants_admin_update"
  ON public.product_variants
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

-- ── 7e. Admin DELETE ──

CREATE POLICY "product_variants_admin_delete"
  ON public.product_variants
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
-- 8. HELPER VIEW — available variants per product
--    security_invoker ensures RLS of the caller is enforced.
-- ============================================================

CREATE OR REPLACE VIEW public.v_available_variants
WITH (security_invoker = on)
AS
SELECT
  pv.id,
  pv.product_id,
  pv.sku,
  pv.size,
  pv.color_en,
  pv.color_ar,
  pv.color_hex,
  pv.price,
  pv.discount_price,
  CASE
    WHEN pv.discount_price IS NOT NULL
    THEN pv.discount_price
    ELSE pv.price
  END                                                  AS effective_price,
  CASE
    WHEN pv.discount_price IS NOT NULL
    THEN ROUND(((pv.price - pv.discount_price) / pv.price) * 100)
    ELSE 0
  END                                                  AS discount_percent,
  pv.stock,
  (pv.stock > 0)                                       AS in_stock,
  pv.sort_order
FROM public.product_variants pv
WHERE pv.is_active = TRUE
ORDER BY pv.sort_order ASC;

COMMENT ON VIEW public.v_available_variants IS
  'Active, in-stock-aware variants with computed effective_price and discount_percent. Read-only.';

-- ============================================================
-- 9. GRANT PERMISSIONS
-- ============================================================

GRANT SELECT ON public.product_variants    TO authenticated;
GRANT SELECT ON public.v_available_variants TO authenticated;

GRANT SELECT ON public.product_variants    TO anon;
GRANT SELECT ON public.v_available_variants TO anon;

GRANT ALL    ON public.product_variants    TO service_role;
