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
    // {
    //   label: "Events",
    //   href: "/dashboard/events",
    // },
    {
      label: "News",
      href: "/dashboard/news",
    },
    {
      label: "Banners",
      href: "/dashboard/banners",
    },
    {
      label: "State Admins",
      href: "/dashboard/state-admins",
    },
  ]
};
