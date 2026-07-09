export type SiteConfig = typeof siteConfig;

export const siteConfig = {
  name: "JJJF Admin Portal",
  description: "Admin portal for Jalore Jain Sangh",
  navItems: [
    {
      label: "Dashboard",
      href: "/dashboard",
    },
    {
      label: "Users",
      href: "/dashboard/users",
    },
    {
      label: "Businesses",
      href: "/dashboard/businesses",
    },
    {
      label: "Jobs",
      href: "/dashboard/jobs",
    },
    {
      label: "Matrimonials",
      href: "/dashboard/matrimonials",
    },
    {
      label: "Events",
      href: "/dashboard/events",
    },
    {
      label: "Shok Sandesh",
      href: "/dashboard/shok-sandesh",
    },
    {
      label: "News",
      href: "/dashboard/news",
    },
  ]
};
