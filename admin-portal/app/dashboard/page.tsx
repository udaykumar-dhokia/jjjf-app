"use client";

import { useEffect, useState } from "react";
import { fetchApi } from "@/lib/api";
import { Card } from "@heroui/react";
import Link from "next/link";

export default function DashboardOverview() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const loadStats = async () => {
      try {
        const res = await fetchApi("/admin/dashboard/stats");
        if (!res.ok) throw new Error("Failed to fetch stats");
        const data = await res.json();
        setStats(data);
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    loadStats();
  }, []);

  if (loading) return <div>Loading dashboard...</div>;
  if (error) return <div className="text-red-500">Error: {error}</div>;

  const statCards = [
    {
      title: "Pending Users",
      value: stats?.pendingUsers || 0,
      href: "/dashboard/users",
    },
    {
      title: "Pending Businesses",
      value: stats?.pendingBusinesses || 0,
      href: "/dashboard/businesses",
    },
    {
      title: "Pending Jobs",
      value: stats?.pendingJobs || 0,
      href: "/dashboard/jobs",
    },
    {
      title: "Pending Matrimonials",
      value: stats?.pendingMatrimonials || 0,
      href: "/dashboard/matrimonials",
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">
          Dashboard Overview
        </h1>
        <p className="text-slate-500 mt-1">
          Welcome to the administration panel. You have{" "}
          <span className="font-bold text-slate-900 dark:text-white">
            {stats?.totalPending || 0}
          </span>{" "}
          items pending approval.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {statCards.map((card, i) => (
          <Link
            key={i}
            href={card.href}
            className="block transition-transform hover:-translate-y-1"
          >
            <Card className="p-6 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm h-full flex flex-col justify-between">
              <h3 className="text-sm font-medium text-slate-500 dark:text-slate-400">
                {card.title}
              </h3>
              <div className="mt-2 flex items-baseline gap-2">
                <span className="text-4xl font-bold tracking-tight text-slate-900 dark:text-white">
                  {card.value}
                </span>
                {card.value > 0 && (
                  <span className="inline-flex items-center rounded-full bg-slate-100 dark:bg-slate-800 px-2.5 py-0.5 text-xs font-medium text-slate-800 dark:text-slate-200">
                    Action needed
                  </span>
                )}
              </div>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
