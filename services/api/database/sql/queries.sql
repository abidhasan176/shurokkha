-- ============================================================================
-- SHUROKKHA - Relational Join & Aggregate Queries
-- Database: shurokkha_db (MySQL 8.0+)
-- Covers the complete ERD schema, including operational junction tables.
-- ============================================================================

USE shurokkha_db;

-- ============================================================================
-- SECTION 1: INNER JOIN QUERIES
-- Purpose: Retrieve matching records that exist in both related tables.
-- ============================================================================

-- 1.1 INNER JOIN: Get each Emergency Request with User details
-- Shows which user submitted which emergency request.
SELECT
    er.request_id,
    u.user_id,
    u.full_name AS requester_name,
    u.phone AS contact_number,
    u.email,
    er.priority,
    er.status AS request_status,
    er.request_at
FROM emergency_requests er
INNER JOIN users u ON er.user_id = u.user_id
ORDER BY er.request_at DESC;

-- 1.2 INNER JOIN: Get Users along with their Role information
-- Resolves the HAS_ROLE relationship between users and roles.
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.status AS user_status,
    r.role_id,
    r.role_name,
    r.description AS role_description
FROM users u
INNER JOIN roles r ON u.role_id = r.role_id
ORDER BY u.user_id ASC;

-- 1.3 3-Table INNER JOIN: Emergency Requests + Users + Roles
-- Demonstrates multi-level relational traversal across 3 tables.
SELECT 
    er.request_id,
    er.priority,
    er.status AS request_status,
    er.request_at,
    u.full_name AS requester_name,
    u.phone AS requester_phone,
    r.role_name AS requester_role
FROM emergency_requests er
INNER JOIN users u ON er.user_id = u.user_id
INNER JOIN roles r ON u.role_id = r.role_id
WHERE er.priority IN ('high', 'critical')
ORDER BY er.request_at DESC;


-- ============================================================================
-- SECTION 2: LEFT OUTER JOIN QUERIES
-- Purpose: Keep all records from the left table, even if no match exists in right.
-- ============================================================================

-- 2.1 LEFT JOIN: List ALL Users and their Emergency Requests (if any)
-- Shows users who requested help AND users/admins who made 0 requests.
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.status AS user_status,
    er.request_id,
    er.priority,
    COALESCE(er.status, 'NO REQUEST') AS request_status,
    er.request_at
FROM users u
LEFT JOIN emergency_requests er ON u.user_id = er.user_id
ORDER BY u.user_id ASC, er.request_at DESC;

-- 2.2 LEFT JOIN: List ALL Roles and the Users assigned to them
-- Identifies roles that have active members or zero members.
SELECT 
    r.role_id,
    r.role_name,
    u.user_id,
    u.full_name,
    u.email
FROM roles r
LEFT JOIN users u ON r.role_id = u.role_id
ORDER BY r.role_id ASC;


-- ============================================================================
-- SECTION 3: RIGHT OUTER JOIN QUERIES
-- Purpose: Keep all records from the right table.
-- ============================================================================

-- 3.1 RIGHT JOIN: Ensure every Emergency Request is mapped to its User
-- Guarantees no orphaned emergency requests are omitted.
SELECT 
    u.user_id,
    u.full_name AS requester_name,
    u.phone AS contact_phone,
    er.request_id,
    er.priority,
    er.status AS request_status,
    er.request_at
FROM users u
RIGHT JOIN emergency_requests er ON u.user_id = er.user_id
ORDER BY er.request_at DESC;

-- 3.2 RIGHT JOIN: All Users mapped to Roles
SELECT 
    r.role_name,
    u.user_id,
    u.full_name,
    u.email
FROM roles r
RIGHT JOIN users u ON r.role_id = u.role_id
ORDER BY u.user_id ASC;


-- ============================================================================
-- SECTION 4: AGGREGATE FUNCTIONS & GROUP BY OPERATIONS
-- Purpose: Summarize data using COUNT, GROUP BY, HAVING, and ORDER BY.
-- ============================================================================

-- 4.1 AGGREGATE: Count total Emergency Requests submitted by each User
SELECT 
    u.user_id,
    u.full_name,
    u.phone,
    COUNT(er.request_id) AS total_requests,
    SUM(CASE WHEN er.priority = 'critical' THEN 1 ELSE 0 END) AS critical_requests,
    SUM(CASE WHEN er.status = 'rescued' THEN 1 ELSE 0 END) AS resolved_requests,
    MAX(er.request_at) AS last_request_time
FROM users u
INNER JOIN emergency_requests er ON u.user_id = er.user_id
GROUP BY u.user_id, u.full_name, u.phone
ORDER BY total_requests DESC;

-- 4.2 AGGREGATE with HAVING: Users who submitted more than 1 emergency request
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    COUNT(er.request_id) AS request_count
FROM users u
INNER JOIN emergency_requests er ON u.user_id = er.user_id
GROUP BY u.user_id, u.full_name, u.email
HAVING COUNT(er.request_id) > 1
ORDER BY request_count DESC;

-- 4.3 AGGREGATE: User count per Role
SELECT 
    r.role_id,
    r.role_name,
    COUNT(u.user_id) AS total_users
FROM roles r
LEFT JOIN users u ON r.role_id = u.role_id
GROUP BY r.role_id, r.role_name
ORDER BY total_users DESC;

-- 4.4 AGGREGATE: Emergency Requests Breakdown by Priority & Status
SELECT 
    er.priority,
    er.status,
    COUNT(er.request_id) AS request_count,
    MIN(er.request_at) AS earliest_request,
    MAX(er.request_at) AS latest_request
FROM emergency_requests er
GROUP BY er.priority, er.status
ORDER BY er.priority ASC, request_count DESC;

-- 4.5 AGGREGATE: Disasters summary grouped by Severity and Status
SELECT 
    d.severity,
    d.status AS disaster_status,
    COUNT(d.disaster_id) AS total_disasters,
    MIN(d.start_datetime) AS oldest_incident,
    MAX(d.start_datetime) AS newest_incident
FROM disasters d
GROUP BY d.severity, d.status
ORDER BY total_disasters DESC;


-- ============================================================================
-- SECTION 5: COMPLETE ERD JOIN QUERIES
-- ============================================================================

-- 5.1 Disaster -> affected area -> request -> requester
SELECT
    d.disaster_name,
    aa.area_id,
    aa.affected_population,
    er.request_id,
    er.priority,
    u.full_name AS requester_name
FROM disasters d
INNER JOIN affected_areas aa ON aa.disaster_id = d.disaster_id
LEFT JOIN emergency_requests er ON er.area_id = aa.area_id
LEFT JOIN users u ON u.user_id = er.user_id
ORDER BY d.disaster_id, aa.area_id;

-- 5.2 Rescue assignment details
SELECT
    tm.assignment_id,
    rt.team_name,
    er.request_id,
    er.priority,
    aa.area_id,
    tm.status AS assignment_status
FROM team_management tm
INNER JOIN rescue_teams rt ON rt.team_id = tm.team_id
INNER JOIN emergency_requests er ON er.request_id = tm.request_id
LEFT JOIN affected_areas aa ON aa.area_id = er.area_id
ORDER BY tm.assignment_at DESC;

-- 5.3 Donor and donation details
SELECT
    u.full_name AS donor_name,
    d.donation_kind,
    d.amount,
    d.status
FROM donations d
LEFT JOIN users u ON u.user_id = d.user_id
ORDER BY d.amount DESC;

-- 5.4 Distribution route and delivered resources
SELECT
    rd.distribution_id,
    w.warehouse_name,
    s.shelter_name,
    r.resource_name,
    dr.quantity,
    r.unit,
    rd.status
FROM relief_distributions rd
LEFT JOIN warehouses w ON w.warehouse_id = rd.warehouse_id
LEFT JOIN shelters s ON s.shelter_id = rd.shelter_id
INNER JOIN distribution_resources dr ON dr.distribution_id = rd.distribution_id
INNER JOIN resources r ON r.resource_id = dr.resource_id
ORDER BY rd.distribution_id, r.resource_name;


-- ============================================================================
-- SECTION 6: JOIN WITH AGGREGATION
-- ============================================================================

-- 6.1 Total affected population and requests per disaster
SELECT
    d.disaster_id,
    d.disaster_name,
    COALESCE(SUM(aa.affected_population), 0) AS affected_population,
    COUNT(DISTINCT er.request_id) AS total_requests
FROM disasters d
LEFT JOIN affected_areas aa ON aa.disaster_id = d.disaster_id
LEFT JOIN emergency_requests er ON er.area_id = aa.area_id
GROUP BY d.disaster_id, d.disaster_name
ORDER BY affected_population DESC;

-- 6.2 Assignment count per rescue team
SELECT
    rt.team_id,
    rt.team_name,
    COUNT(tm.assignment_id) AS assignment_count
FROM rescue_teams rt
LEFT JOIN team_management tm ON tm.team_id = rt.team_id
GROUP BY rt.team_id, rt.team_name
ORDER BY assignment_count DESC;

-- 6.3 Teams with more than one assignment (HAVING)
SELECT
    rt.team_id,
    rt.team_name,
    COUNT(tm.assignment_id) AS assignment_count
FROM rescue_teams rt
INNER JOIN team_management tm ON tm.team_id = rt.team_id
GROUP BY rt.team_id, rt.team_name
HAVING COUNT(tm.assignment_id) > 1;

-- 6.4 Shelter capacity per affected area
SELECT
    aa.area_id,
    aa.severity,
    COUNT(s.shelter_id) AS shelter_count,
    COALESCE(SUM(s.capacity), 0) AS total_capacity,
    COALESCE(SUM(s.occupancy), 0) AS total_occupancy,
    COALESCE(SUM(s.capacity - s.occupancy), 0) AS available_capacity
FROM affected_areas aa
LEFT JOIN shelters s ON s.area_id = aa.area_id
GROUP BY aa.area_id, aa.severity
ORDER BY available_capacity DESC;

-- 6.5 Warehouse resource stock
SELECT
    w.warehouse_id,
    w.warehouse_name,
    COUNT(wr.resource_id) AS resource_types,
    COALESCE(SUM(wr.quantity), 0) AS total_quantity
FROM warehouses w
LEFT JOIN warehouse_resources wr ON wr.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name
ORDER BY total_quantity DESC;

-- 6.6 Donation allocation summary
SELECT
    d.donation_id,
    d.donation_kind,
    d.amount AS donated_amount,
    COALESCE(SUM(da.allocated_amount), 0) AS allocated_amount,
    d.amount - COALESCE(SUM(da.allocated_amount), 0) AS remaining_amount
FROM donations d
LEFT JOIN donation_allocations da ON da.donation_id = d.donation_id
GROUP BY d.donation_id, d.donation_kind, d.amount
ORDER BY allocated_amount DESC;

-- 6.7 Requests with no rescue-team assignment
SELECT er.request_id, er.priority, er.status, er.request_at
FROM emergency_requests er
LEFT JOIN team_management tm ON tm.request_id = er.request_id
WHERE tm.assignment_id IS NULL;

-- 6.8 Above-average affected areas (subquery)
SELECT area_id, disaster_id, affected_population, severity
FROM affected_areas
WHERE affected_population > (
    SELECT AVG(affected_population)
    FROM affected_areas
)
ORDER BY affected_population DESC;


-- ============================================================================
-- SECTION 7: VIEW — Secure Dashboard Report
-- Purpose: Pre-computed, read-only views that expose only non-sensitive columns.
-- The view is created by migration 14_create_views.sql.
-- PHP controller: AggregateReportController::shelterPublicSummary()
-- Endpoint: GET /api/v1/admin/reports/shelter-summary-view
-- ============================================================================

-- 7.1 Query the secure shelter dashboard VIEW.
-- Intentionally hides raw internal metadata; exposes only capacity metrics.
SELECT
    shelter_id,
    shelter_name,
    capacity,
    occupancy,
    available_capacity,
    occupancy_percentage,
    shelter_status,
    area_id,
    area_severity,
    created_at
FROM view_shelter_public_summary
ORDER BY available_capacity ASC;

-- 7.2 Query the donation summary VIEW (non-PII view of donation records).
SELECT
    donation_id,
    donation_kind,
    amount,
    currency,
    campaign_title,
    donation_status,
    receipt_number,
    created_at
FROM view_donation_summary
ORDER BY created_at DESC;


-- ============================================================================
-- SECTION 8: UNION — Combined Facilities Location Report
-- Purpose: Merge shelters and warehouses into one polymorphic result set.
-- PHP controller: JoinReportController::facilityLocations()
-- Endpoint: GET /api/v1/admin/reports/facility-locations
--
-- Design note: UNION ALL is used instead of UNION DISTINCT because shelter
-- and warehouse IDs are independent sequences — the same integer can exist in
-- both tables for different real-world entities.
-- ============================================================================

-- 8.1 UNION ALL: All operational facilities (shelters + warehouses) in one list.
SELECT
    s.shelter_id    AS facility_id,
    s.shelter_name  AS facility_name,
    'shelter'       AS facility_type,
    s.status        AS facility_status,
    s.capacity      AS total_capacity,
    s.area_id       AS area_reference
FROM shelters s

UNION ALL

SELECT
    w.warehouse_id                          AS facility_id,
    w.warehouse_name                        AS facility_name,
    'warehouse'                             AS facility_type,
    'active'                                AS facility_status,
    COALESCE(SUM(wr.quantity), 0)           AS total_capacity,
    w.location_id                           AS area_reference
FROM warehouses w
LEFT JOIN warehouse_resources wr ON w.warehouse_id = wr.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name, w.location_id

ORDER BY facility_type ASC, facility_name ASC;


-- ============================================================================
-- SECTION 9: TRANSACTION — Atomic Relief Distribution
-- Purpose: Safely deduct warehouse inventory while simultaneously inserting
-- a distribution record. All steps succeed or none do (ACID atomicity).
-- PHP controller: AdminWarehouseController::distributeRelief()
-- Endpoint: POST /api/v1/admin/warehouses/{id}/distribute
--
-- Step-by-step:
--   1. BEGIN TRANSACTION
--   2. SELECT ... FOR UPDATE  (pessimistic row-lock on warehouse stock)
--   3. Validate stock >= quantity (application layer)
--   4. UPDATE warehouse_resources (deduct inventory)
--   5. INSERT relief_distributions (create distribution header)
--   6. INSERT distribution_resources (record line item)
--   7. COMMIT  — OR ROLLBACK on any failure
-- ============================================================================

-- 9.1 Verify stock before dispatch (run standalone to check inventory).
SELECT
    wr.warehouse_id,
    w.warehouse_name,
    r.resource_name,
    wr.quantity AS current_stock
FROM warehouse_resources wr
INNER JOIN warehouses w ON w.warehouse_id = wr.warehouse_id
INNER JOIN resources  r ON r.resource_id  = wr.resource_id
ORDER BY w.warehouse_name, r.resource_name;

-- 9.2 Full transaction example (replace ? placeholders with real values).
-- In production this is executed via DB::transaction() in PHP; shown here
-- for direct MySQL client use and academic reference.
START TRANSACTION;

    -- Lock the specific stock row to prevent concurrent over-allocation.
    SELECT quantity
    FROM   warehouse_resources
    WHERE  warehouse_id = 1 AND resource_id = 1
    FOR UPDATE;

    -- Deduct 10 units of resource 1 from warehouse 1.
    UPDATE warehouse_resources
    SET    quantity = quantity - 10
    WHERE  warehouse_id = 1 AND resource_id = 1;

    -- Create the distribution header record.
    INSERT INTO relief_distributions (area_id, warehouse_id, shelter_id, status, delivered_at, created_at, updated_at)
    VALUES (1, 1, 1, 'dispatched', NOW(), NOW(), NOW());

    -- Record the resource line-item using the last inserted distribution ID.
    SET @last_dist_id = LAST_INSERT_ID();
    INSERT INTO distribution_resources (distribution_id, resource_id, quantity)
    VALUES (@last_dist_id, 1, 10);

COMMIT;


-- ============================================================================
-- SECTION 10: STORED PROCEDURE — Automated Shelter Status Management
-- Purpose: Centralize the occupancy→status business rule inside MySQL so it
-- cannot be bypassed by any API caller.
-- Procedure: sp_update_shelter_occupancy(p_shelter_id, p_new_occupancy)
-- PHP controller: AdminShelterController::updateOccupancy()
-- Endpoint: PATCH /api/v1/admin/shelters/{id}/occupancy
-- ============================================================================

-- 10.1 Procedure definition (also lives in 15_create_stored_procedures.sql).
DROP PROCEDURE IF EXISTS sp_update_shelter_occupancy;

DELIMITER //
CREATE PROCEDURE sp_update_shelter_occupancy(
    IN p_shelter_id    INT,
    IN p_new_occupancy INT
)
BEGIN
    DECLARE v_capacity INT DEFAULT 0;

    SELECT capacity
    INTO   v_capacity
    FROM   shelters
    WHERE  shelter_id = p_shelter_id
    LIMIT  1;

    IF p_new_occupancy >= v_capacity THEN
        UPDATE shelters
        SET    occupancy   = p_new_occupancy,
               status      = 'full',
               updated_at  = NOW()
        WHERE  shelter_id  = p_shelter_id;
    ELSE
        UPDATE shelters
        SET    occupancy   = p_new_occupancy,
               status      = 'open',
               updated_at  = NOW()
        WHERE  shelter_id  = p_shelter_id;
    END IF;
END //
DELIMITER ;

-- 10.2 Call the procedure (example: set shelter 1 to 80 occupants).
CALL sp_update_shelter_occupancy(1, 80);

-- 10.3 Verify the result.
SELECT shelter_id, shelter_name, capacity, occupancy, status, updated_at
FROM   shelters
WHERE  shelter_id = 1;
