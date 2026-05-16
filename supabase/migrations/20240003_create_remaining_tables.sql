-- ============================================================
-- Migration: Create Remaining Tables
-- Task:      #11 — cart_items, orders, order_items,
--                  wishlist, notifications + RLS
-- Depends:   product_variants table (Task #10)
-- Stage:     2. Database Design (Supabase)
-- ============================================================

-- ============================================================
-- 1. ORDER STATUS ENUM
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
    CREATE TYPE public.order_status AS ENUM (
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
      'refunded'
    );
  END IF;
END;
$$;

COMMENT ON TYPE public.order_status IS
  'Lifecycle states for a customer order';

-- ============================================================
-- 2. NOTIFICATION TYPE ENUM
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_type') THEN
    CREATE TYPE public.notification_type AS ENUM (
      'order_confirmed',
      'order_shipped',
      'order_delivered',
      'order_cancelled',
      'promo',
      'general'
    );
  END IF;
END;
$$;

COMMENT ON TYPE public.notification_type IS
  'Categories of push/in-app notifications sent to users';

-- ============================================================
-- 3. CART ITEMS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.cart_items (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL
                         REFERENCES auth.users(id)
                         ON DELETE CASCADE,
  variant_id UUID        NOT NULL
                         REFERENCES public.product_variants(id)
                         ON DELETE CASCADE,
  quantity   INTEGER     NOT NULL DEFAULT 1
                         CHECK (quantity >= 1),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- One row per (user, variant) — quantity updated in-place
  CONSTRAINT uq_cart_items_user_variant UNIQUE (user_id, variant_id)
);

COMMENT ON TABLE  public.cart_items            IS 'Per-user shopping cart; each row is one variant line item';
COMMENT ON COLUMN public.cart_items.user_id    IS 'FK → auth.users; cart owner';
COMMENT ON COLUMN public.cart_items.variant_id IS 'FK → product_variants; the specific size+color selected';
COMMENT ON COLUMN public.cart_items.quantity   IS 'Number of units; minimum 1';

-- ============================================================
-- 4. ORDERS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.orders (
  id               UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID         NOT NULL
                                REFERENCES auth.users(id)
                                ON DELETE RESTRICT,
  status           order_status NOT NULL DEFAULT 'pending',
  total_amount     NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
  shipping_address JSONB        NOT NULL DEFAULT '{}',
  notes            TEXT         NOT NULL DEFAULT '',
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  public.orders                  IS 'Customer order headers';
COMMENT ON COLUMN public.orders.user_id          IS 'FK → auth.users; the customer who placed the order';
COMMENT ON COLUMN public.orders.status           IS 'Current order lifecycle state';
COMMENT ON COLUMN public.orders.total_amount     IS 'Sum of all order_items unit_price × quantity';
COMMENT ON COLUMN public.orders.shipping_address IS 'Snapshot of delivery address at order time (jsonb)';
COMMENT ON COLUMN public.orders.notes            IS 'Optional customer notes / delivery instructions';

-- ============================================================
-- 5. ORDER ITEMS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.order_items (
  id         UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id   UUID          NOT NULL
                           REFERENCES public.orders(id)
                           ON DELETE CASCADE,
  variant_id UUID          NOT NULL
                           REFERENCES public.product_variants(id)
                           ON DELETE RESTRICT,
  quantity   INTEGER       NOT NULL CHECK (quantity >= 1),
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
  created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  public.order_items            IS 'Line items belonging to an order; immutable after creation';
COMMENT ON COLUMN public.order_items.order_id   IS 'FK → orders; parent order';
COMMENT ON COLUMN public.order_items.variant_id IS 'FK → product_variants; snapshot of variant selected';
COMMENT ON COLUMN public.order_items.unit_price IS 'Price at time of purchase — never updated after creation';

-- ============================================================
-- 6. WISHLIST TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.wishlist (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL
                         REFERENCES auth.users(id)
                         ON DELETE CASCADE,
  product_id UUID        NOT NULL
                         REFERENCES public.products(id)
                         ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- A user can wishlist a product only once
  CONSTRAINT uq_wishlist_user_product UNIQUE (user_id, product_id)
);

COMMENT ON TABLE  public.wishlist            IS 'User saved / favourite products';
COMMENT ON COLUMN public.wishlist.user_id    IS 'FK → auth.users; wishlist owner';
COMMENT ON COLUMN public.wishlist.product_id IS 'FK → products; saved product (not variant-level)';

-- ============================================================
-- 7. NOTIFICATIONS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.notifications (
  id         UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID              NOT NULL
                               REFERENCES auth.users(id)
                               ON DELETE CASCADE,
  title      TEXT              NOT NULL CHECK (char_length(title) BETWEEN 1 AND 255),
  body       TEXT              NOT NULL DEFAULT '',
  type       notification_type NOT NULL DEFAULT 'general',
  is_read    BOOLEAN           NOT NULL DEFAULT FALSE,
  order_id   UUID                       REFERENCES public.orders(id)
                               ON DELETE SET NULL,
  created_at TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  public.notifications          IS 'In-app notifications delivered to users';
COMMENT ON COLUMN public.notifications.type     IS 'Determines icon and deep-link behaviour in the app';
COMMENT ON COLUMN public.notifications.is_read  IS 'Toggled to true when user opens the notification';
COMMENT ON COLUMN public.notifications.order_id IS 'Optional link to a related order for deep-linking';

-- ============================================================
-- 8. INDEXES
-- ============================================================

-- Cart
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id
  ON public.cart_items (user_id);

CREATE INDEX IF NOT EXISTS idx_cart_items_variant_id
  ON public.cart_items (variant_id);

-- Orders
CREATE INDEX IF NOT EXISTS idx_orders_user_id
  ON public.orders (user_id);

CREATE INDEX IF NOT EXISTS idx_orders_status
  ON public.orders (status);

CREATE INDEX IF NOT EXISTS idx_orders_user_created
  ON public.orders (user_id, created_at DESC);

-- Order items
CREATE INDEX IF NOT EXISTS idx_order_items_order_id
  ON public.order_items (order_id);

CREATE INDEX IF NOT EXISTS idx_order_items_variant_id
  ON public.order_items (variant_id);

-- Wishlist
CREATE INDEX IF NOT EXISTS idx_wishlist_user_id
  ON public.wishlist (user_id);

CREATE INDEX IF NOT EXISTS idx_wishlist_product_id
  ON public.wishlist (product_id);

-- Notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_id
  ON public.notifications (user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
  ON public.notifications (user_id, created_at DESC)
  WHERE is_read = FALSE;

-- ============================================================
-- 9. UPDATED_AT TRIGGERS
--    Reuses set_updated_at() from Task #9 migration.
-- ============================================================

CREATE OR REPLACE TRIGGER trg_cart_items_set_updated_at
  BEFORE UPDATE ON public.cart_items
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE TRIGGER trg_orders_set_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 10. ROW LEVEL SECURITY — CART ITEMS
-- ============================================================

ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cart_items_owner_select"
  ON public.cart_items FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "cart_items_owner_insert"
  ON public.cart_items FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "cart_items_owner_update"
  ON public.cart_items FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "cart_items_owner_delete"
  ON public.cart_items FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- 11. ROW LEVEL SECURITY — ORDERS
-- ============================================================

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Users see only their own orders
CREATE POLICY "orders_owner_select"
  ON public.orders FOR SELECT
  USING (user_id = auth.uid());

-- Users can create orders for themselves only
CREATE POLICY "orders_owner_insert"
  ON public.orders FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Users cannot update orders directly (status managed server-side)
-- Admin full access
CREATE POLICY "orders_admin_all"
  ON public.orders FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

-- ============================================================
-- 12. ROW LEVEL SECURITY — ORDER ITEMS
-- ============================================================

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Users see items belonging to their own orders
CREATE POLICY "order_items_owner_select"
  ON public.order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id      = order_id
        AND o.user_id = auth.uid()
    )
  );

-- Items inserted only as part of own order
CREATE POLICY "order_items_owner_insert"
  ON public.order_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id      = order_id
        AND o.user_id = auth.uid()
    )
  );

-- Admin full access
CREATE POLICY "order_items_admin_all"
  ON public.order_items FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

-- ============================================================
-- 13. ROW LEVEL SECURITY — WISHLIST
-- ============================================================

ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wishlist_owner_select"
  ON public.wishlist FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "wishlist_owner_insert"
  ON public.wishlist FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "wishlist_owner_delete"
  ON public.wishlist FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- 14. ROW LEVEL SECURITY — NOTIFICATIONS
-- ============================================================

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_owner_select"
  ON public.notifications FOR SELECT
  USING (user_id = auth.uid());

-- Users can only mark their own notifications as read
CREATE POLICY "notifications_owner_update"
  ON public.notifications FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Notifications created server-side via service_role only
-- Admin can read all
CREATE POLICY "notifications_admin_all"
  ON public.notifications FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

-- ============================================================
-- 15. GRANT PERMISSIONS
-- ============================================================

-- cart_items: authenticated users only
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cart_items    TO authenticated;

-- orders + order_items: authenticated users only
GRANT SELECT, INSERT                 ON public.orders        TO authenticated;
GRANT SELECT, INSERT                 ON public.order_items   TO authenticated;

-- wishlist: authenticated users only
GRANT SELECT, INSERT, DELETE         ON public.wishlist      TO authenticated;

-- notifications: authenticated users only
GRANT SELECT, UPDATE                 ON public.notifications TO authenticated;

-- service_role bypasses RLS (admin SDK / edge functions)
GRANT ALL ON public.cart_items    TO service_role;
GRANT ALL ON public.orders        TO service_role;
GRANT ALL ON public.order_items   TO service_role;
GRANT ALL ON public.wishlist      TO service_role;
GRANT ALL ON public.notifications TO service_role;
