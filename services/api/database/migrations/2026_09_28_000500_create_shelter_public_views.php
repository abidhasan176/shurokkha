<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Creates the read-only database VIEWs used by the admin dashboard
 * and the public-facing reporting controller.
 *
 * Two views are created:
 *   1. view_shelter_public_summary  – shelter capacity metrics joined with area severity.
 *   2. view_donation_summary        – non-PII aggregated donation records.
 *
 * Both views use CREATE OR REPLACE so the migration is safely re-runnable.
 */
return new class extends Migration
{
    /**
     * Run the migrations.
     * PDO::exec() is used because Laravel's Schema facade does not support
     * CREATE VIEW statements. DB::unprepared() is the Eloquent-idiomatic
     * equivalent and handles the multi-statement DDL correctly.
     */
    public function up(): void
    {
        // -----------------------------------------------------------------------
        // VIEW 1: view_shelter_public_summary
        // Non-sensitive shelter capacity overview with area severity context.
        // Omits internal admin metadata. Safe to expose on the admin dashboard.
        // -----------------------------------------------------------------------
        DB::unprepared(<<<'SQL'
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
            LEFT JOIN affected_areas aa ON s.area_id = aa.area_id
        SQL);

        // -----------------------------------------------------------------------
        // VIEW 2: view_donation_summary
        // Aggregated donation records without donor PII.
        // Exposes only amount, kind, status, and campaign metadata.
        // -----------------------------------------------------------------------
        DB::unprepared(<<<'SQL'
            CREATE OR REPLACE VIEW view_donation_summary AS
            SELECT
                d.donation_id,
                d.donation_kind,
                d.amount,
                d.currency,
                d.campaign_title,
                d.status      AS donation_status,
                d.receipt_number,
                d.created_at
            FROM donations d
        SQL);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::unprepared('DROP VIEW IF EXISTS view_donation_summary');
        DB::unprepared('DROP VIEW IF EXISTS view_shelter_public_summary');
    }
};
