/* AXION — Sous-catégories par métier de la roue principale.
   À enrichir/corriger librement : chaque ajout d'item se reflète automatiquement
   sur la page categorie.html?cat=<code>.
   Champs par item :
     slug    = identifiant interne (lower-case, sans accents)
     label   = libellé affiché sur la carte
     hint    = sous-titre court (qui ? quoi ?)
     q       = chaîne de recherche envoyée à entreprises.html (filtre full-text)
     color   = couleur d'accent de la carte (hex)
     icon    = path SVG (24×24, fill="none", stroke="currentColor")
*/
(function () {
  "use strict";

  // Icônes (paths 24×24, stroke-width:1.6)
  var I = {
    hammer:    '<path d="M14 6l8 8-3 3-8-8 3-3z"/><path d="M11 9l-8 8 3 3 8-8"/>',
    crane:     '<path d="M3 21V5h18M3 5l18 8M9 21V13"/>',
    truck:     '<rect x="2" y="8" width="13" height="9"/><path d="M15 11h4l3 4v2h-7M5 21a2 2 0 100-4 2 2 0 000 4zm12 0a2 2 0 100-4 2 2 0 000 4z"/>',
    foundation:'<path d="M3 18h18M5 18V8h14v10M9 8V5h6v3M9 12h6"/>',
    roof:      '<path d="M3 12L12 4l9 8M5 12v8h14v-8M9 16h6"/>',
    rain:      '<path d="M16 13a4 4 0 10-8 0 4 4 0 008 0z"/><path d="M8 17v3M12 17v3M16 17v3M5 7a3 3 0 016 0M13 7a3 3 0 016 0"/>',
    window:    '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M12 3v18M3 12h18"/>',
    bolt:      '<path d="M13 3L4 14h7l-1 7 9-11h-7l1-7z"/>',
    pipe:      '<path d="M3 8h14a4 4 0 014 4v8M3 16h10"/>',
    fire:      '<path d="M12 22c4 0 7-3 7-7 0-3-2-5-3-7 0 4-3 4-3 1 0-2-1-4-3-5 1 4-3 4-3 9 0 4 1 9 5 9z"/>',
    plug:      '<path d="M9 2v6M15 2v6M6 8h12v3a6 6 0 11-12 0V8zM12 17v5"/>',
    drop:      '<path d="M12 2.7l5 8.3a6 6 0 11-10 0z"/>',
    fan:       '<path d="M12 12c2-4 6-4 6 0s-4 4-6 0zm0 0c-2 4-6 4-6 0s4-4 6 0zm0 0c4 2 4 6 0 6s-4-4 0-6zm0 0c-4-2-4-6 0-6s4 4 0 6z"/>',
    brick:     '<path d="M3 6h7v6H3zM10 6h7v6h-7zM17 6h4v6h-4zM3 12h4v6H3zM7 12h7v6H7zM14 12h7v6h-7z"/>',
    paint:     '<path d="M19 11V6a2 2 0 00-2-2H5a2 2 0 00-2 2v5h16zM3 11v3h13v2a3 3 0 003 3v3"/>',
    tree:      '<path d="M12 2C9 4 8 7 9 10c-3 0-4 2-3 4 1 2 3 2 4 1v7M12 6c2 2 3 4 2 6 2 0 4 1 3 4-1 2-3 2-4 1"/>',
    elevator:  '<rect x="6" y="3" width="12" height="18" rx="1"/><path d="M9 8l3-3 3 3M9 16l3 3 3-3"/>',
    door:      '<rect x="6" y="3" width="12" height="18"/><circle cx="14.5" cy="12" r=".8" fill="currentColor"/>',
    floor:     '<rect x="3" y="14" width="18" height="6"/><path d="M3 14l6-6h6l6 6M9 8v6M15 8v6"/>',
    broom:     '<path d="M14 3l7 7-4 4-7-7zM10 7l-7 7v7h7l7-7"/>',
    water:     '<path d="M3 12c3-3 6-3 9 0s6 3 9 0M3 17c3-3 6-3 9 0s6 3 9 0M3 7c3-3 6-3 9 0s6 3 9 0"/>',
    sewer:     '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3v18"/>',
    gas:       '<path d="M12 22c5 0 8-4 8-9 0-5-4-8-6-11 0 4-4 5-4 8 0 2 1 3 2 3 0-3 1-5 2-5-1 3 1 5 2 7"/>',
    spark:     '<path d="M5 13l4-4-3-3 7-2-2 7-3-3-4 4M14 19l2-2-1-1 3-1-1 3-1-1-2 2"/>',
    antenna:   '<path d="M5 19c0-7 7-7 7 0M9 19c0-3 6-3 6 0M19 19c0-7-7-7-7 0M12 12V4M9 7l3-3 3 3"/>',
    streetlamp:'<path d="M5 4h6v4l-1 11h-4l-1-11zM11 8h7M18 4v4"/>',
    radiator:  '<path d="M4 5v14M8 5v14M12 5v14M16 5v14M20 5v14M3 9h18M3 15h18"/>',
    trash:     '<path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14"/>',
    layers:    '<path d="M12 2L2 8l10 6 10-6-10-6zM2 14l10 6 10-6M2 11l10 6 10-6"/>',
    cube:      '<path d="M12 2L3 7v10l9 5 9-5V7l-9-5zM3 7l9 5 9-5M12 12v10"/>',
    nut:       '<polygon points="12 2 21 7 21 17 12 22 3 17 3 7"/><circle cx="12" cy="12" r="3"/>',
    tools:     '<path d="M7 7l3-3 6 6-3 3zM10 10l-7 7v4h4l7-7"/>',
    box:       '<path d="M21 8l-9-5-9 5 9 5 9-5zM3 8v8l9 5 9-5V8M12 13v8"/>',
    columns:   '<rect x="4" y="3" width="4" height="18"/><rect x="16" y="3" width="4" height="18"/>',
    waves:     '<path d="M3 8c3-2 6 2 9 0s6 2 9 0M3 14c3-2 6 2 9 0s6 2 9 0M3 20c3-2 6 2 9 0s6 2 9 0"/>',
    speaker:   '<path d="M11 5L6 9H2v6h4l5 4V5zM15 9a4 4 0 010 6M18 6a8 8 0 010 12"/>',
    leaf:      '<path d="M11 20A7 7 0 014 13c0-6 7-9 16-9 0 9-3 16-9 16zM4 13L17 4"/>',
    shield:    '<path d="M12 22s8-3 8-11V5l-8-3-8 3v6c0 8 8 11 8 11z"/>',
    bolt2:     '<path d="M2 12h6l2-3 4 6 2-3h6"/>',
    drill:     '<path d="M6 6h10v4H6zM7 10v3l3 2v3l-3 2M16 8h3l2 2-2 2h-3"/>',
    map:       '<path d="M3 6l6-3 6 3 6-3v15l-6 3-6-3-6 3z"/><path d="M9 3v15M15 6v15"/>',
    school:    '<path d="M3 21h18M5 21V10l7-5 7 5v11M9 21v-6h6v6M9 14h.01M15 14h.01"/>',
    folder:    '<path d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V7z"/>',
    palette:   '<circle cx="12" cy="12" r="10"/><circle cx="7" cy="10" r="1.5" fill="currentColor"/><circle cx="12" cy="7" r="1.5" fill="currentColor"/><circle cx="17" cy="10" r="1.5" fill="currentColor"/><circle cx="15" cy="15" r="1.5" fill="currentColor"/>',
    coins:     '<circle cx="9" cy="9" r="6"/><circle cx="15" cy="15" r="6"/>',
    chart:     '<path d="M3 21V3M3 21h18M7 17V9M11 17V5M15 17v-9M19 17V11"/>',
    clipboard: '<rect x="6" y="3" width="12" height="18" rx="2"/><path d="M9 3h6v3H9zM9 11h6M9 15h4"/>',
    badge:     '<circle cx="12" cy="9" r="5"/><path d="M9 14v7l3-2 3 2v-7"/>'
  };

  // ────────────────────────────────────────────────────────────────────────
  // ENT — Entreprises (corps d'état TCE) — ordre par phase travaux
  // ────────────────────────────────────────────────────────────────────────
  var ENT_ITEMS = [
    { slug:'demolition', label:'Démolition · Désamiantage', hint:'Curage, dépose, désamiantage', q:'démolition',     color:'#94A3B8', icon:I.hammer },
    { slug:'vrd',        label:'Terrassements · VRD',       hint:'Voirie, réseaux divers',     q:'VRD',            color:'#A78BFA', icon:I.truck },
    { slug:'fondations', label:'Fondations spéciales',      hint:'Pieux, micropieux, parois',  q:'fondation',      color:'#60A5FA', icon:I.foundation },
    { slug:'go',         label:'Gros œuvre · Béton',        hint:'Structure béton armé',       q:'gros',           color:'#60A5FA', icon:I.brick },
    { slug:'charpb',     label:'Charpente bois',            hint:'Ossature, lamellé-collé',    q:'charpente bois', color:'#D4A946', icon:I.cube },
    { slug:'charpm',     label:'Charpente métallique',      hint:'Profilés acier',             q:'charpente métal',color:'#94A3B8', icon:I.columns },
    { slug:'couverture', label:'Couverture · Bardage',      hint:'Tuiles, ardoise, zinc, bardage', q:'couverture', color:'#38BDF8', icon:I.roof },
    { slug:'etancheite', label:'Étanchéité',                hint:'Toiture-terrasse, isolation',q:'étanchéité',     color:'#38BDF8', icon:I.rain },
    { slug:'menext',     label:'Menuiseries extérieures',   hint:'Alu, bois, mixte, PVC',      q:'menuiserie ext', color:'#A78BFA', icon:I.window },
    { slug:'serrurerie', label:'Serrurerie · Métallerie',   hint:'Garde-corps, portails',      q:'serrurerie',     color:'#94A3B8', icon:I.bolt },
    { slug:'cloisons',   label:'Cloisons · Plâtrerie',      hint:'Placo, doublages, faux-plafonds', q:'cloison',  color:'#E2E8F0', icon:I.layers },
    { slug:'menint',     label:'Menuiseries intérieures',   hint:'Portes, agencement bois',    q:'menuiserie int', color:'#A78BFA', icon:I.door },
    { slug:'plomberie',  label:'Plomberie · Sanitaire',     hint:'Adduction, évacuation, EFS', q:'plomberie',      color:'#34D399', icon:I.pipe },
    { slug:'cvc',        label:'CVC · Chauffage · Ventil.', hint:'Production thermique, VMC',  q:'CVC',           color:'#34D399', icon:I.radiator },
    { slug:'elec',       label:'Électricité CFO · CFA',     hint:'Courants forts et faibles',  q:'électricité',    color:'#FBBF24', icon:I.plug },
    { slug:'ascenseur',  label:'Ascenseurs',                hint:'Installation, maintenance',  q:'ascenseur',     color:'#94A3B8', icon:I.elevator },
    { slug:'carrelage',  label:'Carrelage · Faïence',       hint:'Sols et murs',               q:'carrelage',      color:'#F472B6', icon:I.brick },
    { slug:'sols',       label:'Sols souples · Parquet',    hint:'PVC, moquette, parquet',     q:'sol souple',     color:'#F472B6', icon:I.floor },
    { slug:'peinture',   label:'Peinture · Revêtements',    hint:'Murs et plafonds',           q:'peinture',       color:'#F472B6', icon:I.paint },
    { slug:'ev',         label:'Espaces verts · VRD finit.', hint:'Plantations, mobilier',     q:'espace vert',    color:'#22C55E', icon:I.tree },
    { slug:'nettoyage',  label:'Nettoyage fin de chantier', hint:'Livraison propre',           q:'nettoyage',      color:'#94A3B8', icon:I.broom }
  ];

  // ────────────────────────────────────────────────────────────────────────
  // CONC — Concessionnaires (réseaux & services urbains)
  // ────────────────────────────────────────────────────────────────────────
  var CONC_ITEMS = [
    { slug:'aep',         label:'Eau potable (AEP)',          hint:'Fermier / Régie locale',     q:'AEP',          color:'#38BDF8', icon:I.drop },
    { slug:'eu',          label:'Assainissement EU',          hint:'Eaux usées',                 q:'eaux usées',   color:'#A78BFA', icon:I.sewer },
    { slug:'ep',          label:'Assainissement EP',          hint:'Eaux pluviales',             q:'eaux pluviales', color:'#60A5FA', icon:I.water },
    { slug:'gaz',         label:'Gaz (GRDF)',                 hint:'Distribution gaz naturel',   q:'GRDF',         color:'#FBBF24', icon:I.gas },
    { slug:'elec',        label:'Électricité (ENEDIS)',       hint:'Distribution publique',      q:'ENEDIS',       color:'#FBBF24', icon:I.spark },
    { slug:'telcuivre',   label:'Télécoms cuivre',            hint:'Orange (DSP historique)',    q:'Orange',       color:'#F472B6', icon:I.antenna },
    { slug:'telfibre',    label:'Télécoms fibre',             hint:'Orange · Free · SFR · alt.', q:'fibre',        color:'#F472B6', icon:I.antenna },
    { slug:'eclairage',   label:'Éclairage public',           hint:'Collectivité ou délégataire',q:'éclairage',    color:'#FBBF24', icon:I.streetlamp },
    { slug:'chaleur',     label:'Chauffage urbain',           hint:'Réseau de chaleur si présent',q:'chauffage urbain', color:'#F59E0B', icon:I.radiator },
    { slug:'dechets',     label:'Collecte des déchets',       hint:'OM / tri / déchèterie',      q:'déchet',       color:'#22C55E', icon:I.trash }
  ];

  // ────────────────────────────────────────────────────────────────────────
  // FOUR — Fournisseurs
  // ────────────────────────────────────────────────────────────────────────
  var FOUR_ITEMS = [
    { slug:'beton',     label:'Béton · Granulats',        hint:'BPE, ciment, granulats',    q:'béton',       color:'#94A3B8', icon:I.cube },
    { slug:'acier',     label:'Aciers · Armatures',       hint:'Profilés, armatures',       q:'acier',       color:'#94A3B8', icon:I.bolt },
    { slug:'bois',      label:'Bois · Panneaux',          hint:'Bois de structure, OSB',    q:'bois',        color:'#D4A946', icon:I.cube },
    { slug:'isolation', label:'Isolation',                hint:'Laines, biosourcés, PSE',   q:'isolation',   color:'#34D399', icon:I.layers },
    { slug:'platre',    label:'Plâtre · Cloisons',        hint:'Plaques, profilés',         q:'plâtre',      color:'#E2E8F0', icon:I.layers },
    { slug:'menuis',    label:'Menuiseries (industriels)',hint:'Fenêtres, portes, agencement', q:'menuiserie industrielle', color:'#A78BFA', icon:I.window },
    { slug:'sanit',     label:'Équipements sanitaires',   hint:'Robinetterie, vasques',     q:'sanitaire',   color:'#34D399', icon:I.drop },
    { slug:'cvc',       label:'Équipements CVC',          hint:'Chaudières, PAC, VMC',      q:'équipement CVC', color:'#34D399', icon:I.fan },
    { slug:'elec',      label:'Équipements électriques',  hint:'Tableaux, appareillage',    q:'équipement électrique', color:'#FBBF24', icon:I.plug },
    { slug:'quinc',     label:'Quincaillerie · Visserie', hint:'Fixations, ferrages',       q:'quincaillerie',color:'#94A3B8', icon:I.nut },
    { slug:'outillage', label:'Outillage · Location',     hint:'Engins, location matériel', q:'outillage',   color:'#94A3B8', icon:I.tools },
    { slug:'echaf',     label:'Échafaudage · Coffrages',  hint:'Étaiement, banches',        q:'échafaudage', color:'#94A3B8', icon:I.columns },
    { slug:'revet',     label:'Carrelage · Revêtements',  hint:'Sols, murs',                q:'carrelage',   color:'#F472B6', icon:I.brick },
    { slug:'peint',     label:'Peintures · Vernis',       hint:'Finitions',                 q:'peinture',    color:'#F472B6', icon:I.palette }
  ];

  // ────────────────────────────────────────────────────────────────────────
  // BET — Bureaux d'études
  // ────────────────────────────────────────────────────────────────────────
  var BET_ITEMS = [
    { slug:'structure',   label:'Structure · Béton armé',   hint:'Calcul béton, métal, bois', q:'structure',     color:'#60A5FA', icon:I.brick },
    { slug:'fluides',     label:'Fluides (PB · CVC · ELEC)',hint:'BET pluri-techniques',      q:'fluides',       color:'#34D399', icon:I.pipe },
    { slug:'thermique',   label:'Thermique · Énergie',      hint:'RE2020, STD, simulation',   q:'thermique',     color:'#F59E0B', icon:I.fire },
    { slug:'acoustique',  label:'Acoustique',               hint:'Étude, mesures',            q:'acoustique',    color:'#A78BFA', icon:I.speaker },
    { slug:'facade',      label:'Façade',                   hint:'Bardage, mur rideau',       q:'façade',        color:'#94A3B8', icon:I.window },
    { slug:'env',         label:'HQE · Environnement',      hint:'Certifications, biodiv.',   q:'environnement', color:'#22C55E', icon:I.leaf },
    { slug:'incendie',    label:'Sécurité incendie',        hint:'ISI, ERP, désenfumage',     q:'incendie',      color:'#EF4444', icon:I.shield },
    { slug:'vrd',         label:'VRD · Hydraulique',        hint:'Réseaux, gestion EP',       q:'VRD',           color:'#38BDF8', icon:I.water },
    { slug:'geotech',     label:'Géotechnique',             hint:'G1 à G5, étude de sol',     q:'géotechnique',  color:'#94A3B8', icon:I.layers },
    { slug:'economie',    label:'Économie de la construction', hint:'Estimation, chiffrage',  q:'économiste',    color:'#FDBA74', icon:I.coins },
    { slug:'synthese',    label:'Synthèse · BIM',           hint:'Maquette numérique, OPC',   q:'BIM',           color:'#A78BFA', icon:I.layers },
    { slug:'diagnostic',  label:'Diagnostics',              hint:'Amiante, plomb, énergie',   q:'diagnostic',    color:'#FBBF24', icon:I.clipboard }
  ];

  // ────────────────────────────────────────────────────────────────────────
  // AMO — Assistance à Maîtrise d'Ouvrage
  // ────────────────────────────────────────────────────────────────────────
  var AMO_ITEMS = [
    { slug:'prog',        label:'Programmation',            hint:'Pré-programme, programme',  q:'programmation', color:'#60A5FA', icon:I.clipboard },
    { slug:'technique',   label:'Conduite d\'opération',    hint:'AMO technique',             q:'conduite',      color:'#A78BFA', icon:I.tools },
    { slug:'opc',         label:'OPC',                      hint:'Ordo. Pilotage Coordination',q:'OPC',          color:'#34D399', icon:I.chart },
    { slug:'env',         label:'HQE · Environnement',      hint:'BREEAM, LEED, BiodiverCity',q:'HQE',           color:'#22C55E', icon:I.leaf },
    { slug:'energie',     label:'Énergie · RE2020',         hint:'Sobriété, bas-carbone',     q:'énergie',       color:'#F59E0B', icon:I.fire },
    { slug:'juridique',   label:'Juridique · Foncier',      hint:'Maîtrise foncière, baux',   q:'juridique',     color:'#94A3B8', icon:I.shield },
    { slug:'financiere',  label:'Financière',               hint:'Faisabilité, bilan',        q:'financière',    color:'#FBBF24', icon:I.coins },
    { slug:'commercial',  label:'Commercialisation VEFA',   hint:'Logements neufs',           q:'commercialisation', color:'#F472B6', icon:I.badge },
    { slug:'concertation',label:'Concertation · Comm.',     hint:'Riverains, élus, presse',   q:'concertation',  color:'#38BDF8', icon:I.map }
  ];

  // ────────────────────────────────────────────────────────────────────────
  // Définition des catégories
  // ────────────────────────────────────────────────────────────────────────
  window.AXION_SOUS_METIERS = {
    ent: {
      code: 'ent', accent: '#60A5FA',
      parentLabel: 'Entreprises', parentSub: 'Corps d\'état',
      title: 'Les corps d\'état',
      lead: 'Toutes les entreprises de travaux du projet, classées par corps d\'état (TCE). Cliquez sur un domaine pour consulter les sociétés référencées.',
      items: ENT_ITEMS
    },
    conc: {
      code: 'conc', accent: '#38BDF8',
      parentLabel: 'Concessionnaires', parentSub: 'Réseaux & services',
      title: 'Les concessionnaires',
      lead: 'Les opérateurs de réseaux et services urbains à coordonner pendant la conception et le chantier.',
      items: CONC_ITEMS
    },
    four: {
      code: 'four', accent: '#A78BFA',
      parentLabel: 'Fournisseurs', parentSub: 'Matériaux & équipements',
      title: 'Les fournisseurs',
      lead: 'Les industriels, négociants et loueurs de matériels qui alimentent le chantier.',
      items: FOUR_ITEMS
    },
    bet: {
      code: 'bet', accent: '#34D399',
      parentLabel: 'Bureaux d\'études', parentSub: 'Spécialités techniques',
      title: 'Les bureaux d\'études',
      lead: 'Les BET spécialisés qui complètent l\'équipe de maîtrise d\'œuvre selon les enjeux du projet.',
      items: BET_ITEMS
    },
    amo: {
      code: 'amo', accent: '#FBBF24',
      parentLabel: 'Assistance MOA', parentSub: 'Spécialités',
      title: 'Les AMO',
      lead: 'Les missions d\'assistance à maîtrise d\'ouvrage selon les besoins de l\'opération.',
      items: AMO_ITEMS
    }
  };
})();
