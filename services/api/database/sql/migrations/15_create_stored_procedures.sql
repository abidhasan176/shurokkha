USE shurokkha_db;

-- ============================================================================
-- Migration 15: Create Stored Procedures
-- Purpose: Automate shelter occupancy updates with business-logic enforcement.
-- The procedure reads the shelter's capacity and automatically flips status
-- to 'full' when occupancy meets or exceeds capacity, or 'open' otherwise.
-- Depends on: Migration 08 (shelters table)
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_update_shelter_occupancy;

DELIMITER //

-- ----------------------------------------------------------------------------
-- PROCEDURE: sp_update_shelter_occupancy
-- Parameters:
--   p_shelter_id   INT  - The target shelter.
--   p_new_occupancy INT - The occupancy value to set.
-- Business Rules:
--   - If p_new_occupancy >= capacity  => status becomes 'full'
--   - If p_new_occupancy <  capacity  => status becomes 'open'
--   - If shelter does not exist, procedure exits without error (no rows updated).
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_update_shelter_occupancy(
    IN p_shelter_id    INT,
    IN p_new_occupancy INT
)
BEGIN
    DECLARE v_capacity INT DEFAULT 0;

    -- Read the current capacity for this shelter.
    SELECT capacity
    INTO   v_capacity
    FROM   shelters
    WHERE  shelter_id = p_shelter_id
    LIMIT  1;

    -- Update occupancy and derive status automatically.
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
