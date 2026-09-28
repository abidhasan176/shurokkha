"use client"

import { useState } from "react"
import {
  MapPin,
  ShieldCheck,
  ClipboardList,
  Database,
  CheckCircle2,
} from "lucide-react"
import { Badge } from "@shurokkha/ui/components/badge"
import { useOperationsData } from "../hooks/use-operations"
import { AffectedAreasTab } from "./affected-areas-tab"
import { RescueTeamsTab } from "./rescue-teams-tab"
import { TeamManagementTab } from "./team-management-tab"

export function OperationsDashboard() {
  const [activeTab, setActiveTab] = useState<string>("affected-areas")
  const { affectedAreas, rescueTeams, assignments } = useOperationsData()

  const availableTeams = rescueTeams.data.filter((t) => t.availability === "available").length
  const activeAssignments = assignments.data.filter(
    (a) => a.status === "assigned" || a.status === "on_route"
  ).length
  const totalPopulation = affectedAreas.data.reduce(
    (sum, a) => sum + Number(a.affected_population || 0),
    0
  )

  return (
    <div className="space-y-8 pb-16">
      {/* Header Banner */}
      <div className="rounded-2xl bg-gradient-to-r from-primary/10 via-primary/5 to-transparent p-6 sm:p-8 border border-primary/20">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <Badge variant="default" className="bg-primary text-primary-foreground font-semibold">
                Direct Lab Admin
              </Badge>
              <Badge variant="outline" className="border-primary/30 text-primary">
                <Database className="size-3 mr-1 inline" /> MySQL: shurokkha_db
              </Badge>
            </div>
            <h1 className="text-3xl font-bold tracking-tight text-foreground">
              Response Operations Management
            </h1>
            <p className="text-muted-foreground text-sm max-w-2xl">
              Dedicated management interface for <strong>Affected Areas</strong>, <strong>Rescue Teams</strong>, and <strong>Team Management</strong>. No login required.
            </p>
          </div>

          <div className="flex items-center gap-3">
            <div className="bg-background/80 backdrop-blur border rounded-xl p-3 px-4 shadow-sm text-center">
              <span className="text-xs text-muted-foreground block">DB Status</span>
              <span className="text-sm font-semibold text-emerald-600 flex items-center justify-center gap-1">
                ● Live Connected
              </span>
            </div>
          </div>
        </div>

        {/* Quick Stats Grid */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-6 pt-6 border-t border-primary/15">
          <div className="bg-background/70 backdrop-blur rounded-xl p-3.5 border">
            <div className="flex items-center gap-2 text-muted-foreground text-xs font-medium">
              <MapPin className="size-3.5 text-primary" /> Affected Areas
            </div>
            <div className="text-2xl font-bold mt-1 text-foreground">
              {affectedAreas.data.length}
            </div>
            <span className="text-[11px] text-muted-foreground">
              {totalPopulation.toLocaleString()} affected pop.
            </span>
          </div>

          <div className="bg-background/70 backdrop-blur rounded-xl p-3.5 border">
            <div className="flex items-center gap-2 text-muted-foreground text-xs font-medium">
              <ShieldCheck className="size-3.5 text-emerald-500" /> Rescue Teams
            </div>
            <div className="text-2xl font-bold mt-1 text-foreground">
              {rescueTeams.data.length}
            </div>
            <span className="text-[11px] text-emerald-600 dark:text-emerald-400 font-medium">
              {availableTeams} ready / available
            </span>
          </div>

          <div className="bg-background/70 backdrop-blur rounded-xl p-3.5 border">
            <div className="flex items-center gap-2 text-muted-foreground text-xs font-medium">
              <ClipboardList className="size-3.5 text-blue-500" /> Active Missions
            </div>
            <div className="text-2xl font-bold mt-1 text-foreground">
              {activeAssignments}
            </div>
            <span className="text-[11px] text-muted-foreground">
              {assignments.data.length} total assignments
            </span>
          </div>

          <div className="bg-background/70 backdrop-blur rounded-xl p-3.5 border">
            <div className="flex items-center gap-2 text-muted-foreground text-xs font-medium">
              <CheckCircle2 className="size-3.5 text-indigo-500" /> Completed
            </div>
            <div className="text-2xl font-bold mt-1 text-foreground">
              {assignments.data.filter((a) => a.status === "completed").length}
            </div>
            <span className="text-[11px] text-muted-foreground">
              Missions accomplished
            </span>
          </div>
        </div>
      </div>

      {/* Tab Selector Bar */}
      <div className="bg-muted/80 p-1.5 rounded-2xl border flex flex-wrap sm:flex-nowrap gap-2">
        <button
          type="button"
          onClick={() => setActiveTab("affected-areas")}
          className={`flex-1 flex items-center justify-center gap-2 py-3 px-4 rounded-xl font-medium text-sm transition-all duration-200 ${
            activeTab === "affected-areas"
              ? "bg-background text-foreground shadow-sm font-semibold ring-1 ring-border"
              : "text-muted-foreground hover:text-foreground hover:bg-background/50"
          }`}
        >
          <MapPin className="size-4 text-primary" />
          <span>1. Affected Areas</span>
          <Badge
            variant={activeTab === "affected-areas" ? "default" : "secondary"}
            className="text-xs px-2 py-0.5"
          >
            {affectedAreas.data.length}
          </Badge>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab("rescue-teams")}
          className={`flex-1 flex items-center justify-center gap-2 py-3 px-4 rounded-xl font-medium text-sm transition-all duration-200 ${
            activeTab === "rescue-teams"
              ? "bg-background text-foreground shadow-sm font-semibold ring-1 ring-border"
              : "text-muted-foreground hover:text-foreground hover:bg-background/50"
          }`}
        >
          <ShieldCheck className="size-4 text-emerald-500" />
          <span>2. Rescue Teams</span>
          <Badge
            variant={activeTab === "rescue-teams" ? "default" : "secondary"}
            className="text-xs px-2 py-0.5"
          >
            {rescueTeams.data.length}
          </Badge>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab("team-management")}
          className={`flex-1 flex items-center justify-center gap-2 py-3 px-4 rounded-xl font-medium text-sm transition-all duration-200 ${
            activeTab === "team-management"
              ? "bg-background text-foreground shadow-sm font-semibold ring-1 ring-border"
              : "text-muted-foreground hover:text-foreground hover:bg-background/50"
          }`}
        >
          <ClipboardList className="size-4 text-blue-500" />
          <span>3. Team Management</span>
          <Badge
            variant={activeTab === "team-management" ? "default" : "secondary"}
            className="text-xs px-2 py-0.5"
          >
            {assignments.data.length}
          </Badge>
        </button>
      </div>

      {/* Tab Panels */}
      <div className="space-y-4">
        {activeTab === "affected-areas" && <AffectedAreasTab />}
        {activeTab === "rescue-teams" && <RescueTeamsTab />}
        {activeTab === "team-management" && <TeamManagementTab />}
      </div>
    </div>
  )
}
