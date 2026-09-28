<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Creates the MySQL Stored Procedure used by AdminShelterController::updateOccupancy().
 *
 * Procedure: sp_update_shelter_occupancy(p_shelter_id INT, p_new_occupancy INT)
 *   - Reads the shelter's capacity.
 *   - If p_new_occupancy >= capacity  → status = 'full'
 *   - If p_new_occupancy <  capacity  → status = 'open'
 *
 * Uses DB::unprepared() with explicit DELIMITER to support multi-statement DDL.
 * The DROP ... IF EXISTS guard makes the migration safely re-runnable.
 */
return new class extends Migration
{
    public function up(): void
    {
        // Drop first so CREATE OR REPLACE is not needed (MySQL PROCEDURE
        // does not support OR REPLACE in all versions).
        DB::unprepared('DROP PROCEDURE IF EXISTS sp_update_shelter_occupancy');

        DB::unprepared(<<<'SQL'
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
            END
        SQL);
    }

    public function down(): void
    {
        DB::unprepared('DROP PROCEDURE IF EXISTS sp_update_shelter_occupancy');
    }
};
