# Create Remaining Tables (cart_items, orders, order_items, wishlist, notifications) + RLS

#: 11
Assigned: Ahmed Alalawi
Depends on: Create Product Variants Table (Create%20Product%20Variants%20Table%2004e88ae73107484aac310afc7eaa3393.md)
Description: cart_items: id, user_id (FK), variant_id (FK product_variants), quantity, created_at. Unique constraint (user_id, variant_id). RLS: users access own rows only. orders: id, user_id, status (enum), total_amount, shipping_address (jsonb), created_at. order_items: id, order_id, variant_id, quantity, unit_price. wishlist: id, user_id, product_id, created_at. Unique (user_id, product_id). notifications: id, user_id, title, body, type, is_read, order_id (nullable), created_at. RLS: users access own rows only across all tables.
Stage: 2. Database Design (Supabase)
Status: Done