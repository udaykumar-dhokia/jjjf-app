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
      title: "Users",
      total: stats?.users?.total || 0,
      pending: stats?.users?.pending || 0,
      href: "/dashboard/users",
    },
    {
      title: "Businesses",
      total: stats?.businesses?.total || 0,
      pending: stats?.businesses?.pending || 0,
      href: "/dashboard/businesses",
    },
    {
      title: "Jobs",
      total: stats?.jobs?.total || 0,
      pending: stats?.jobs?.pending || 0,
      href: "/dashboard/jobs",
    },
    {
      title: "Matrimonials",
      total: stats?.matrimonials?.total || 0,
      pending: stats?.matrimonials?.pending || 0,
      href: "/dashboard/matrimonials",
    },
    {
      title: "News",
      total: stats?.news?.total || 0,
      pending: stats?.news?.pending || 0,
      href: "/dashboard/news",
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

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {statCards.map((card, i) => (
          <Link
            key={i}
            href={card.href}
            className="block transition-transform hover:-translate-y-1"
          >
            <Card className="p-6 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm h-full flex flex-col justify-between">
              <h3 className="text-sm font-medium text-slate-500 dark:text-slate-400">
                Total {card.title}
              </h3>
              <div className="mt-2 flex flex-col items-start gap-2">
                <span className="text-4xl font-bold tracking-tight text-slate-900 dark:text-white">
                  {card.total}
                </span>
                {card.pending > 0 ? (
                  <span className="inline-flex items-center rounded-full bg-orange-100 dark:bg-orange-900/30 px-2.5 py-0.5 text-xs font-medium text-orange-800 dark:text-orange-300">
                    {card.pending} Pending Action
                  </span>
                ) : (
                  <span className="inline-flex items-center rounded-full bg-slate-100 dark:bg-slate-800 px-2.5 py-0.5 text-xs font-medium text-slate-500 dark:text-slate-400">
                    All clear
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
