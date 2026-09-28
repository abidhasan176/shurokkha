USE shurokkha_db;

-- ============================================================================
-- Migration 14: Create Database Views
-- Purpose: Create secure, read-only views for the admin dashboard that expose
-- only non-sensitive aggregated shelter/donation data.
-- Depends on: Migrations 08 (shelters), 05 (affected_areas), 10 (donations)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- VIEW 1: view_shelter_public_summary
-- Exposes only non-sensitive shelter fields (capacity, occupancy, availability).
-- Intentionally omits internal admin notes and soft-delete metadata.
-- Linked to affected_areas for area-level severity context.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW view_shelter_public_summary AS
SELECT
    s.shelter_id,
    s.shelter_name,
    s.capacity,
    s.occupancy,
    (s.capacity - s.occupancy)                         AS available_capacity,
    ROUND(
        (s.occupancy / NULLIF(s.capacity, 0)) * 100, 2
    )                                                   AS occupancy_percentage,
    s.status                                            AS shelter_status,
    aa.area_id,
    aa.severity                                         AS area_severity,
    s.created_at
FROM shelters s
LEFT JOIN affected_areas aa ON s.area_id = aa.area_id;


-- ----------------------------------------------------------------------------
-- VIEW 2: view_donation_summary
-- Exposes aggregated, non-sensitive donation metrics.
-- Excludes donor PII (phone, address). Used by the public dashboard.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW view_donation_summary AS
SELECT
    d.donation_id,
    d.donation_kind,
    d.amount,
    d.currency,
    d.campaign_title,
    d.status                                            AS donation_status,
    d.receipt_number,
    d.created_at
FROM donations d;
