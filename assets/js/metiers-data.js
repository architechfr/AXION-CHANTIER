/* ════════════════════════════════════════════════════════════════════
   AXION — Roue des métiers · données
   Chaque métier pointe vers l'annuaire réel : entreprises.html?type=…  ou ?q=…
   (hook déjà présent dans entreprises.html → affiche un chip de filtre)
   Textes = placeholder à valider par Cadence Architectes.
   ════════════════════════════════════════════════════════════════════ */
window.AXION_METIERS = [
  {
    id: "moa", name: "Maître d'ouvrage", short: "MOA", phase: "Initiation",
    subtitle: "Le commanditaire du projet", color: "#5EEAD4", link: "entreprises.html?type=moa",
    icon: '<path d="M3 21h18M5 21V8l7-5 7 5v13M9 21v-6h6v6" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Donneur d'ordre à l'origine de l'opération. Il définit le besoin, le budget et le calendrier, et porte la responsabilité juridique et financière du projet.",
    missions: ["Définir le programme et le budget", "Choisir les intervenants", "Valider les grandes étapes", "Réceptionner l'ouvrage"]
  },
  {
    id: "amo", name: "AMO", short: "AMO", phase: "Programmation",
    subtitle: "Assistance à maîtrise d'ouvrage", color: "#60A5FA", link: "entreprises.html?type=amo",
    icon: '<circle cx="12" cy="8" r="4"/><path d="M5 20v-1a5 5 0 0 1 5-5h1M14.5 18l2 2 3.5-3.5" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Conseil et bras droit du maître d'ouvrage. L'AMO sécurise les décisions, structure le programme et pilote les intervenants pour le compte du commanditaire.",
    missions: ["Cadrer les besoins", "Rédiger le programme", "Assister aux choix techniques", "Suivre les délais et coûts"]
  },
  {
    id: "moe", name: "Architecte", short: "MOE", phase: "Conception",
    subtitle: "Conception & maîtrise d'œuvre", color: "#93C5FD", link: "entreprises.html?type=moe",
    icon: '<path d="M9 4v9.5a3 3 0 1 0 2 2.8M9 4l8 14M9 7h4" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Concepteur de l'ouvrage. L'architecte traduit le programme en projet, dessine les espaces et conduit la maîtrise d'œuvre jusqu'à la livraison.",
    missions: ["Concevoir le projet", "Déposer le permis", "Élaborer les plans EXE", "Diriger les travaux"]
  },
  {
    id: "economiste", name: "Économiste", short: "ECO", phase: "Chiffrage",
    subtitle: "Estimation & optimisation des coûts", color: "#FBBF24", link: "entreprises.html?q=" + encodeURIComponent("économiste"),
    icon: '<rect x="5" y="3" width="14" height="18" rx="1.5"/><path d="M8 7h8M8 11h2m2 0h2m-6 4h2m2 0h2" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Garant des coûts. L'économiste de la construction chiffre, optimise et contrôle le budget à chaque phase pour tenir l'enveloppe financière.",
    missions: ["Estimer les coûts", "Rédiger les quantitatifs (DPGF)", "Analyser les offres", "Optimiser le budget"]
  },
  {
    id: "moex", name: "MOEX", short: "MOEX", phase: "Exécution",
    subtitle: "Maîtrise d'œuvre d'exécution", color: "#38BDF8", link: "entreprises.html?type=moex",
    icon: '<path d="M3 11a9 9 0 0 1 18 0M2 11h20v2a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1v-2ZM12 2v3" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Pilote opérationnel du chantier. Le MOEX coordonne les entreprises, contrôle la conformité d'exécution et fait respecter les plannings sur le terrain.",
    missions: ["Coordonner les corps d'état", "Contrôler l'exécution", "Animer les réunions de chantier", "Gérer le planning"]
  },
  {
    id: "sps", name: "Coordonnateur SPS", short: "SPS", phase: "Sécurité",
    subtitle: "Sécurité & protection de la santé", color: "#F472B6", link: "entreprises.html?type=sps",
    icon: '<path d="M12 3 5 6v5c0 4.5 3 7.5 7 9 4-1.5 7-4.5 7-9V6l-7-3ZM9 12l2 2 4-4" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Coordonnateur de la sécurité. Il prévient les risques, harmonise les mesures entre entreprises et veille à la santé de tous les intervenants.",
    missions: ["Élaborer le PGC", "Prévenir les co-activités", "Inspecter le chantier", "Tenir le registre-journal"]
  },
  {
    id: "bet", name: "Bureau d'études", short: "BET", phase: "Études",
    subtitle: "Études techniques & spécialités", color: "#34D399", link: "entreprises.html?type=bet",
    icon: '<rect x="3" y="4" width="18" height="13" rx="1.5"/><path d="M8 21h8M12 17v4M6.5 13l3-3 2.5 2.5L16 8" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Expertise technique du projet. Les bureaux d'études dimensionnent structure, fluides, thermique et VRD pour garantir la faisabilité et la performance.",
    missions: ["Calculs de structure", "Études fluides & thermiques", "Notes techniques", "Coordination des lots"]
  },
  {
    id: "entreprise", name: "Entreprises", short: "ENT", phase: "Travaux",
    subtitle: "Réalisation & exécution des travaux", color: "#C4B5FD", link: "entreprises.html?type=entreprise",
    icon: '<path d="M12 4a4 4 0 0 0-4 4v1h8V8a4 4 0 0 0-4-4ZM6 9 4 7m14 2 2-2M5 20v-1a4 4 0 0 1 4-4h6a4 4 0 0 1 4 4v1M12 15v5" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Bâtisseurs de l'ouvrage. Les entreprises de travaux exécutent les lots, du gros œuvre aux finitions, dans le respect des plans et des normes.",
    missions: ["Réaliser les travaux", "Respecter plans & normes", "Tenir les délais", "Lever les réserves"]
  },
  {
    id: "fournisseur", name: "Fournisseurs", short: "FRN", phase: "Approvisionnement",
    subtitle: "Matériaux & solutions produits", color: "#FB923C", link: "entreprises.html?q=" + encodeURIComponent("fournisseur"),
    icon: '<path d="M3 8 12 4l9 4-9 4-9-4ZM3 8v8l9 4 9-4V8M12 12v8" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Sourcing des matériaux et équipements. Les fournisseurs approvisionnent le chantier en produits conformes, dans les délais et au juste coût.",
    missions: ["Proposer des solutions produits", "Garantir la disponibilité", "Assurer la logistique", "Suivre la conformité"]
  },
  {
    id: "concessionnaire", name: "Concessionnaire", short: "CCS", phase: "Raccordements",
    subtitle: "Réseaux & services publics", color: "#2DD4BF", link: "entreprises.html?q=" + encodeURIComponent("concessionnaire"),
    icon: '<path d="M3 21h18M5 21V10l7-5 7 5v11M9 21v-6h6v6M5 10h14" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Gestionnaire des réseaux. Eau, électricité, gaz, télécom : le concessionnaire raccorde l'ouvrage aux réseaux publics et en assure le service.",
    missions: ["Étudier les raccordements", "Coordonner les travaux réseaux", "Valider les branchements", "Mettre en service"]
  },
  {
    id: "administratif", name: "Administratif", short: "ADM", phase: "Support",
    subtitle: "Gestion & suivi administratif", color: "#94A3B8", link: "entreprises.html?q=" + encodeURIComponent("administratif"),
    icon: '<path d="M4 7a2 2 0 0 1 2-2h3l2 2.5h7a2 2 0 0 1 2 2V17a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7Z" stroke-linecap="round" stroke-linejoin="round"/>',
    desc: "Colonne vertébrale documentaire. Le pôle administratif gère contrats, marchés, autorisations et facturation tout au long de l'opération.",
    missions: ["Monter les dossiers de marché", "Suivre les autorisations", "Gérer la facturation", "Archiver les pièces"]
  }
];

/* Entreprises de démonstration (extraites du jeu de données réel du portail)
   pour la maquette d'aperçu d'annuaire. */
window.AXION_DEMO_FIRMS = {
  entreprise: [
    { name: "AGZ", trade: "Gros-œuvre", lot: "01", color: "#60A5FA", ville: "Paris 12e" },
    { name: "Les Toits d'Orivana", trade: "Étanchéité", lot: "02", color: "#38BDF8", ville: "Noisy-le-Grand" },
    { name: "LCI Concept", trade: "Menuiseries extérieures", lot: "05", color: "#A78BFA", ville: "Champigny" },
    { name: "APM", trade: "Plomberie · CVC", lot: "15", color: "#34D399", ville: "Créteil" },
    { name: "LED", trade: "Électricité", lot: "14", color: "#FBBF24", ville: "Villiers" },
    { name: "Socotec", trade: "Bureau de contrôle", lot: null, color: "#5EEAD4", ville: "Paris" }
  ]
};
