/* ============================================================================
   AXION — Vue « phase analyse »
   Quand un chantier est en phase d'études (analyse des offres entreprises),
   chantier.html remplace les onglets travaux par des onglets d'analyse.
   Activation : window.AxionAnalysis.isAnalysisPhase(project) === true
   Données : pilotées par slug (extensible). Fallback générique sinon.
   Charte : réutilise les variables CSS de chantier.html (ink/azure/gold).
   ========================================================================== */
(function () {
  'use strict';

  function esc(s){return String(s==null?'':s).replace(/[&<>"]/g,function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]);});}
  function eur(n){return n==null?'—':new Intl.NumberFormat('fr-FR').format(n)+' €';}

  /* ---- Jeux de données par chantier (slug) -------------------------------- */
  var DATA = {
    'gueules-cassees': {
      kpis: [
        { k:'Lots en consultation', v:'3', s:'Gros-Œuvre · Démolition/Désamiantage · VRD' },
        { k:'Offres analysées', v:'5', s:'3 Gros-Œuvre · 1 démolition · 1 VRD' },
        { k:'Fourchette Gros-Œuvre', v:'5,60 → 7,64 M€', s:'Écart max +36 %', c:'gold' },
        { k:'Point dur transverse', v:'BREEAM', s:'Non chiffré par aucune entreprise', c:'red' }
      ],
      offres: [
        { n:'STB', d:'Offre finale V5 · 07/05/2026', montant:5600000, pct:73.3, tag:'win', note:'moins-disant' },
        { n:'DC Bâtiment', d:'« Entreprise A » · DPGF 08/04/2025', montant:6496204, pct:85, tag:'mid', note:'+ 16 %' },
        { n:'JORYF', d:'Offre · 04/03/2026', montant:7642000, pct:100, tag:'hi', note:'+ 36 %' }
      ],
      ecartMax:'2 042 000 € HT',
      lot2:{ ent:'BATEX', montant:600008, note:'Offre unique · 02/06/2026',
             risque:'Désamiantage réellement chiffré ≈ 47 700 € (8 %) — anormalement bas pour 4 bâtiments amiantés. 14 lignes de confinement à 0 €.' },
      vrd:[
        ['1 — Terrassement, assainissement, voirie, tranchées',1699459,'83,7 %'],
        ['2 — Eau potable',71920,'3,5 %'],
        ['3 — Électricité BT + Gaz',51765,'2,5 %'],
        ['4 — Éclairage',207223,'10,2 %'],
        ['Total SOMAG (offre unique)',2030367,'100 %']
      ],
      comparatif: [
        ['Prestations sur l\'existant','1 049 050 €','1 418 283 €','+369 233 €','red','STB plus cher (+35 %)'],
        ['Prestations neuf','5 447 154 €','4 084 267 €','−1 362 888 €','green','STB moins cher (−25 %)'],
        ['Installation de chantier','incluse','97 450 €','—','','STB l\'isole (Lot 1)'],
        ['Total comparable','6 496 204 €','5 600 000 €','−896 204 €','green','STB moins-disant (−13,8 %)']
      ],
      causes: [
        { t:'Béton matricé exclu par STB', tag:'≈ 284 000 €', tagc:'amber', p:'DC Bâtiment chiffre 836 m² × 340 €/m². STB l\'exclut. Or le CCTP l\'impose (art. 4.4.6.3) → non-conformité, pas une économie.' },
        { t:'Façades : brique vs voile béton', tag:'Variante', tagc:'amber', p:'STB chiffre les façades 100 % en voiles béton armé là où DC Bâtiment intègre de la brique. Variante à valider.' },
        { t:'Arrondi commercial STB', tag:'Négociation', tagc:'', p:'Total STB pile à 5 600 000 € : offre finale négociée, pas un cumul analytique.' },
        { t:'Prix unitaires fondations identiques', tag:'Constat', tagc:'green', p:'Longrines 184,80 €/ml, béton 190 €/m³, acier 2,40 €/kg… strictement égaux. L\'écart vient des quantités.' }
      ],
      cctp: [
        ['Façades neuves en prémurs béton (4.4.6.1)','ok','ok','ko','JORYF a chiffré brique → rechiffrer'],
        ['Béton matricé imposé (4.4.6.3)','ko','ok','q','Seul DC Bâtiment le chiffre (~284 k€). Non-conformité STB'],
        ['Échafaudage façades existantes','ko','ok','q','STB exclut → à réintégrer'],
        ['Reprise en sous-œuvre (4.3.2.1)','ko','ok','q','STB exclut'],
        ['Rabattement de nappe (4.4.1.6)','ko','q','q','STB exclut'],
        ['Lift / monte-matériaux','ko','ok','ko','STB & JORYF excluent'],
        ['Études EXE structure (4.4.6.1.1)','ok','ok','ok','STB 115 k€ · DC 131,5 k€'],
        ['Pieux = Lot 24 séparé','ok','ok','ok','JORYF chiffré à part 224 k€']
      ],
      alertes: [
        { n:1, lvl:'hi', t:'Béton matricé — exigé par le CCTP, exclu par STB', who:'STB · élevée', p:'Art. 4.4.6.3. STB le sort explicitement. Non-conformité CCTP. Demander un chiffrage (~284 k€ chez DC Bâtiment).' },
        { n:2, lvl:'hi', t:'JORYF — façades en brique au lieu des prémurs béton', who:'JORYF · élevée', p:'Art. 4.4.6.1 impose les prémurs béton. Variante non conforme. Demander un rechiffrage.' },
        { n:3, lvl:'hi', t:'STB — ~25 exclusions explicites', who:'STB · élevée', p:'Échafaudages, sous-œuvre, rabattement, branchements, lift… Ordre de grandeur 400–800 k€. Chiffrer à périmètre équivalent.' },
        { n:4, lvl:'mid', t:'DC Bâtiment — deux totaux qui circulent', who:'DC Bâtiment · moyenne', p:'DPGF 6 496 204 € vs devis commercial 6 617 412 €. Écart 121 208 €. Confirmer la version + DPGF signé.' },
        { n:5, lvl:'mid', t:'JORYF — validité d\'offre courte', who:'JORYF · moyenne', p:'Offre valable 90 jours depuis le 04/03/2026 → expire vers le 02/06/2026. Demander une prolongation.' },
        { n:6, lvl:'hi', t:'BATEX — désamiantage non maîtrisé (Lot 02)', who:'BATEX · critique', p:'Aucune méthodologie de retrait ; confinements et mesures à 0 €. QUALIBAT 1552 non justifiée. Scinder le lot + concurrence.' }
      ],
      breeam: {
        titre:'Objectif Excellent visé, aucune entreprise ne l\'a chiffré',
        p1:'Le maître d\'ouvrage vise la certification BREEAM RFO niveau Excellent (charte chantier annexée au DCE). Aucune offre — ni BATEX, ni le Gros-Œuvre — ne chiffre les sujétions propres au label.',
        p2:'Pour les lots démolition/curage, les crédits BREEAM se gagnent sur le chantier (réemploi, tri, preuve documentaire). Un matériau évacué sans traçabilité conforme est un crédit perdu définitivement.',
        items:['Diagnostic ressources / PEMD : non prévu, non chiffré.','Objectif contractuel de taux de réemploi : absent.','Traçabilité renforcée pour l\'audit : limitée au légal.','Coordination et production des preuves : personne ne la pilote.'],
        mo:'Soulever ce point n\'ajoute pas un problème, il en évite un. Chiffrer le BREEAM maintenant coûte peu ; le rattraper après coup coûte cher, voire devient impossible.'
      },
      planning: {
        scale:['J26','J','A','S','O','N','D','J27','F','M','A','M','J','J','A','S','O','N','D','J28','F','M'],
        rows:[
          { lbl:'Château', sub:'livraison déc. 2027', bars:[[1,10,'go','GO / démol.'],[3,8,'cc','Clos-couvert'],[3,18,'so','Second œuvre · OPR']] },
          { lbl:'Corps de ferme', sub:'livraison mars 2028', bars:[[1,9,'go','GO / démol.'],[3,12,'cc','Clos-couvert'],[3,21,'so','Second œuvre · OPR']] },
          { lbl:'Neuf (héberg.+resto)', sub:'livraison mars 2028', bars:[[1,16,'go','Terrass. / GO'],[12,15,'cc','Clos-c.'],[13,21,'so','Second œuvre · OPR']] }
        ]
      }
    }
  };

  function isAnalysisPhase(project){
    if(!project) return false;
    return /étud|analyse|consultation|appel d.offre|dce/i.test(project.status||'');
  }

  /* ---- Styles scopés (.anl-*) -------------------------------------------- */
  function injectStyle(){
    if(document.getElementById('anl-style')) return;
    var css = `
.anl-grid{display:grid;gap:14px}
.anl-g4{grid-template-columns:repeat(auto-fit,minmax(200px,1fr))}
.anl-g2{grid-template-columns:repeat(auto-fit,minmax(300px,1fr))}
.anl-card{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:18px}
.anl-k{font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:var(--text-faint);margin-bottom:9px}
.anl-v{font-family:'Space Grotesk',sans-serif;font-size:24px;font-weight:700;letter-spacing:-.3px}
.anl-v.gold{color:var(--gold-soft)}.anl-v.red{color:var(--red)}.anl-v.green{color:var(--green)}
.anl-s{font-size:12.5px;color:var(--text-dim);margin-top:5px}
.anl-h{font-family:'Space Grotesk';font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.12em;color:var(--text-dim);margin:30px 0 14px;display:flex;align-items:center;gap:10px}
.anl-h:first-child{margin-top:4px}
.anl-h::before{content:"";width:18px;height:2px;background:var(--gold);border-radius:2px}
.anl-lead{color:var(--text-dim);font-size:14px;max-width:760px;margin:-4px 0 18px;line-height:1.6}
.anl-offer{display:grid;grid-template-columns:150px 1fr 120px;align-items:center;gap:14px;margin-bottom:14px}
.anl-offer .nm{font-weight:600;font-size:14px}.anl-offer .nm small{display:block;color:var(--text-faint);font-size:11px;font-weight:500}
.anl-track{height:30px;background:var(--surface-2);border-radius:7px;overflow:hidden}
.anl-fill{height:100%;border-radius:7px;display:flex;align-items:center;padding-left:12px;font-size:11.5px;font-weight:600;color:#0A1628}
.anl-fill.win{background:linear-gradient(90deg,#34D399,#6EE7B7)}
.anl-fill.mid{background:linear-gradient(90deg,#D4A946,#E9C97A)}
.anl-fill.hi{background:linear-gradient(90deg,#F87171,#FCA5A5);color:#fff}
.anl-amt{text-align:right;font-family:'JetBrains Mono',monospace;font-weight:600;font-size:14px}
.anl-amt small{display:block;font-size:11px;color:var(--text-dim);font-weight:500}
.anl-table{width:100%;border-collapse:collapse;font-size:13.5px;background:var(--surface);border:1px solid var(--border);border-radius:14px;overflow:hidden}
.anl-table th{text-align:left;background:var(--surface-2);color:var(--text-dim);font-weight:600;font-size:10.5px;text-transform:uppercase;letter-spacing:.06em;padding:12px 14px;border-bottom:1px solid var(--border)}
.anl-table td{padding:12px 14px;border-bottom:1px solid var(--border);vertical-align:top}
.anl-table tr:last-child td{border-bottom:none}
.anl-num{font-family:'JetBrains Mono',monospace;text-align:right;white-space:nowrap}
.anl-tag{display:inline-block;padding:2px 9px;border-radius:6px;font-size:11px;font-weight:700}
.anl-ok{background:color-mix(in oklab,var(--green) 16%,transparent);color:var(--green)}
.anl-ko{background:color-mix(in oklab,var(--red) 16%,transparent);color:var(--red)}
.anl-q{background:var(--surface-2);color:var(--text-dim)}
.anl-chip{display:inline-block;padding:3px 10px;border-radius:999px;font-size:11px;font-weight:600;border:1px solid var(--border-2);color:var(--text-dim)}
.anl-chip.amber{background:color-mix(in oklab,var(--amber) 14%,transparent);color:#FBBF24;border-color:transparent}
.anl-chip.green{background:color-mix(in oklab,var(--green) 14%,transparent);color:var(--green);border-color:transparent}
.anl-alert{display:flex;gap:14px;padding:15px 16px;background:var(--surface);border:1px solid var(--border);border-left:3px solid var(--text-faint);border-radius:0 10px 10px 0;margin-bottom:11px}
.anl-alert.hi{border-left-color:var(--red)}.anl-alert.mid{border-left-color:var(--amber)}
.anl-alert .ic{flex:0 0 auto;width:32px;height:32px;border-radius:9px;display:grid;place-items:center;font-weight:800;font-family:'JetBrains Mono',monospace}
.anl-alert.hi .ic{background:color-mix(in oklab,var(--red) 16%,transparent);color:var(--red)}
.anl-alert.mid .ic{background:color-mix(in oklab,var(--amber) 16%,transparent);color:#FBBF24}
.anl-alert h4{font-size:14px;font-weight:600;margin:0 0 3px}.anl-alert p{font-size:12.7px;color:var(--text-dim);margin:0}
.anl-alert .who{display:inline-block;margin-top:7px;font-size:10.5px;font-family:'JetBrains Mono',monospace;color:var(--text-faint);border:1px solid var(--border-2);padding:2px 8px;border-radius:6px}
.anl-note{background:color-mix(in oklab,var(--amber) 12%,transparent);border:1px solid color-mix(in oklab,var(--amber) 35%,transparent);border-radius:14px;padding:20px 22px}
.anl-note h3{font-family:'Space Grotesk';font-size:16px;font-weight:700;color:#FBBF24;margin:0 0 8px}
.anl-note p{font-size:13.6px;color:var(--text);margin:0 0 10px;line-height:1.6}
.anl-note ul{margin:10px 0 0;padding-left:20px;color:var(--text-dim);font-size:13.2px}.anl-note li{margin-bottom:6px}
.anl-note .mo{margin-top:13px;padding-top:12px;border-top:1px solid color-mix(in oklab,var(--amber) 30%,transparent);font-size:13px;color:var(--text-dim)}
.anl-gantt{overflow-x:auto;border:1px solid var(--border);border-radius:14px;background:var(--surface);padding:18px}
.anl-gi{min-width:860px}
.anl-grow{display:grid;grid-template-columns:150px 1fr;gap:14px;align-items:center;margin-bottom:9px}
.anl-glbl{font-size:13px;font-weight:600}.anl-glbl small{display:block;color:var(--text-faint);font-size:11px}
.anl-gtrack{position:relative;height:24px;background:var(--surface-2);border-radius:6px}
.anl-gbar{position:absolute;top:3px;height:18px;border-radius:5px;display:flex;align-items:center;padding:0 9px;font-size:10px;font-weight:600;color:#0A1628;white-space:nowrap;overflow:hidden}
.anl-gbar.go{background:linear-gradient(90deg,#D4A946,#E9C97A)}
.anl-gbar.cc{background:linear-gradient(90deg,#60A5FA,#93C5FD);color:#fff}
.anl-gbar.so{background:linear-gradient(90deg,#A78BFA,#C4B5FD);color:#fff}
.anl-gscale{display:grid;grid-template-columns:150px 1fr;gap:14px;margin-bottom:10px}
.anl-gmonths{display:grid;font-family:'JetBrains Mono',monospace;font-size:9px;color:var(--text-faint);text-align:center}
.anl-gleg{display:flex;gap:18px;flex-wrap:wrap;margin-top:14px;font-size:12px;color:var(--text-dim)}
.anl-gleg span{display:inline-flex;align-items:center;gap:7px}.anl-sw{width:11px;height:11px;border-radius:3px}
.anl-doc{display:flex;align-items:center;gap:14px;padding:13px 15px;background:var(--surface);border:1px solid var(--border);border-radius:10px;margin-bottom:10px;text-decoration:none;color:inherit}
.anl-doc:hover{border-color:var(--border-2)}
.anl-doc .di{width:38px;height:38px;border-radius:9px;background:var(--surface-2);display:grid;place-items:center;color:var(--text-dim);flex:0 0 auto}
.anl-doc .dt{flex:1;min-width:0}.anl-doc .dt h4{font-size:14px;font-weight:600;margin:0}.anl-doc .dt p{font-size:12px;color:var(--text-faint);margin:2px 0 0}
.anl-lock{font-size:10px;font-weight:700;letter-spacing:.04em;padding:3px 9px;border-radius:6px;background:color-mix(in oklab,var(--red) 14%,transparent);color:var(--red)}
.anl-lock.t0{background:color-mix(in oklab,var(--green) 14%,transparent);color:var(--green)}
`;
    var st=document.createElement('style'); st.id='anl-style'; st.textContent=css;
    document.head.appendChild(st);
  }

  /* ---- Rendu des panes ---------------------------------------------------- */
  function paneSynth(d){
    var k=d.kpis.map(function(x){return '<div class="anl-card"><div class="anl-k">'+esc(x.k)+'</div><div class="anl-v '+(x.c||'')+'">'+esc(x.v)+'</div><div class="anl-s">'+esc(x.s)+'</div></div>';}).join('');
    return '<div class="anl-h">Où en est le projet</div>'+
      '<p class="anl-lead">Le chantier n\'a pas démarré. Nous sommes en <b>phase d\'analyse des offres entreprises</b> : dépouillement des devis, comparatif à périmètre équivalent, contrôle de conformité au CCTP et préparation des décisions d\'attribution. Aucune attribution n\'est arrêtée.</p>'+
      '<div class="anl-grid anl-g4">'+k+'</div>';
  }
  function paneOffres(d){
    var off=d.offres.map(function(o){return '<div class="anl-offer"><div class="nm">'+esc(o.n)+'<small>'+esc(o.d)+'</small></div><div class="anl-track"><div class="anl-fill '+o.tag+'" style="width:'+o.pct+'%">'+eur(o.montant)+'</div></div><div class="anl-amt">'+(o.montant/1e6).toFixed(2).replace('.',',')+' M€<small>'+esc(o.note)+'</small></div></div>';}).join('');
    var vrd=d.vrd.map(function(r){return '<tr><td>'+esc(r[0])+'</td><td class="anl-num">'+eur(r[1])+'</td><td class="anl-num">'+esc(r[2])+'</td></tr>';}).join('');
    return '<div class="anl-h">Lot 04 — Gros-Œuvre · 3 offres</div>'+
      '<p class="anl-lead">Comparaison des totaux HT (installation + gros-œuvre). Seuls les totaux sont comparables : décompositions différentes.</p>'+
      '<div class="anl-card">'+off+'<p style="font-size:12.5px;color:var(--text-faint);margin:14px 0 0">Écart maximal JORYF − STB : <b style="color:var(--text-dim)" class="font-mono">'+esc(d.ecartMax)+'</b>. Avantage STB à relativiser (exclusions 400–800 k€, 13 mois d\'écart).</p></div>'+
      '<div class="anl-h">Lot 02 — Démolition · Désamiantage</div>'+
      '<div class="anl-grid anl-g2"><div class="anl-card"><div class="anl-k">'+esc(d.lot2.ent)+' — offre unique</div><div class="anl-v">'+eur(d.lot2.montant)+'</div><div class="anl-s">'+esc(d.lot2.note)+'</div></div><div class="anl-card"><span class="anl-chip amber">Risque amiante</span><p style="font-size:13px;color:var(--text-dim);margin:10px 0 0">'+esc(d.lot2.risque)+'</p></div></div>'+
      '<div class="anl-h">VRD — Terrassement · Réseaux · Voirie</div>'+
      '<table class="anl-table"><thead><tr><th>Lot VRD</th><th class="anl-num">Montant HT</th><th class="anl-num">Part</th></tr></thead><tbody>'+vrd+'</tbody></table>';
  }
  function paneComparatif(d){
    var rows=d.comparatif.map(function(r){var last=r[0]==='Total comparable';return '<tr'+(last?' style="font-weight:600"':'')+'><td>'+esc(r[0])+'</td><td class="anl-num">'+esc(r[1])+'</td><td class="anl-num">'+esc(r[2])+'</td><td class="anl-num" style="color:var(--'+(r[4]||'text-dim')+')">'+esc(r[3])+'</td><td>'+esc(r[5])+'</td></tr>';}).join('');
    var causes=d.causes.map(function(c){return '<div class="anl-card"><span class="anl-chip '+(c.tagc||'')+'">'+esc(c.tag)+'</span><h4 style="font-size:14px;margin:11px 0 5px">'+esc(c.t)+'</h4><p style="font-size:13px;color:var(--text-dim);margin:0">'+esc(c.p)+'</p></div>';}).join('');
    return '<div class="anl-h">D\'où vient l\'écart de 896 204 € (STB vs DC Bâtiment) ?</div>'+
      '<p class="anl-lead">L\'écart net en faveur de STB est la somme de deux mouvements opposés : plus cher sur l\'existant, nettement moins cher sur le neuf.</p>'+
      '<table class="anl-table"><thead><tr><th>Bloc</th><th class="anl-num">DC Bâtiment</th><th class="anl-num">STB</th><th class="anl-num">Écart STB−A</th><th>Lecture</th></tr></thead><tbody>'+rows+'</tbody></table>'+
      '<div class="anl-h">Les vraies causes de l\'écart</div><div class="anl-grid anl-g2">'+causes+'</div>';
  }
  function paneCctp(d){
    function cell(v){var m={ok:['anl-ok','OK'],ko:['anl-ko','KO'],q:['anl-q','?']}[v];return '<td style="text-align:center"><span class="anl-tag '+m[0]+'">'+m[1]+'</span></td>';}
    var rows=d.cctp.map(function(r){return '<tr><td>'+esc(r[0])+'</td>'+cell(r[1])+cell(r[2])+cell(r[3])+'<td>'+esc(r[4])+'</td></tr>';}).join('');
    return '<div class="anl-h">Conformité des 3 offres au CCTP Lot 04</div>'+
      '<p class="anl-lead">CCTP LOGABAT Ingénierie, 69 pages. Extrait des points structurants — <span class="anl-tag anl-ok">OK</span> conforme · <span class="anl-tag anl-ko">KO</span> exclusion · <span class="anl-tag anl-q">?</span> à vérifier.</p>'+
      '<table class="anl-table"><thead><tr><th>Exigence CCTP</th><th style="text-align:center">STB</th><th style="text-align:center">DC Bât.</th><th style="text-align:center">JORYF</th><th>Action</th></tr></thead><tbody>'+rows+'</tbody></table>';
  }
  function paneAlertes(d){
    var a=d.alertes.map(function(x){return '<div class="anl-alert '+x.lvl+'"><div class="ic">'+x.n+'</div><div><h4>'+esc(x.t)+'</h4><p>'+esc(x.p)+'</p><span class="who">'+esc(x.who)+'</span></div></div>';}).join('');
    return '<div class="anl-h">Alertes prioritaires pour la réunion</div>'+
      '<p class="anl-lead">Chaque offre a un point bloquant. Recommandation MOE : <b>ne pas attribuer définitivement</b> avant levée de ces points et nouveau comparatif à périmètre équivalent.</p>'+a;
  }
  function paneBreeam(d){
    var b=d.breeam, items=b.items.map(function(i){return '<li>'+esc(i)+'</li>';}).join('');
    return '<div class="anl-h">BREEAM — l\'angle mort de tous les devis</div>'+
      '<div class="anl-note"><h3>⚠ '+esc(b.titre)+'</h3><p>'+esc(b.p1)+'</p><p>'+esc(b.p2)+'</p><ul>'+items+'</ul><div class="mo"><b style="color:#FBBF24">Message au maître d\'ouvrage :</b> '+esc(b.mo)+'</div></div>';
  }
  function panePlanning(d){
    var p=d.planning, n=p.scale.length;
    var months=p.scale.map(function(m){return '<div>'+esc(m)+'</div>';}).join('');
    var rows=p.rows.map(function(r){
      var bars=r.bars.map(function(b){var left=(b[0]-1)/n*100, w=(b[1]-b[0]+1)/n*100;return '<div class="anl-gbar '+b[2]+'" style="left:'+left+'%;width:calc('+w+'% - 3px)">'+esc(b[3])+'</div>';}).join('');
      return '<div class="anl-grow"><div class="anl-glbl">'+esc(r.lbl)+'<small>'+esc(r.sub)+'</small></div><div class="anl-gtrack">'+bars+'</div></div>';
    }).join('');
    return '<div class="anl-h">Planning prévisionnel MOA — v1 (28/05/2026)</div>'+
      '<p class="anl-lead">Démarrage prévu 01/06/2026, granularité mensuelle, ≈ 22 mois. Trois entités en parallèle.</p>'+
      '<div class="anl-gantt"><div class="anl-gi"><div class="anl-gscale"><div></div><div class="anl-gmonths" style="grid-template-columns:repeat('+n+',1fr)">'+months+'</div></div>'+rows+
      '<div class="anl-gleg"><span><i class="anl-sw" style="background:#D4A946"></i>Démolition / désamiantage / gros-œuvre</span><span><i class="anl-sw" style="background:#60A5FA"></i>Clos-couvert</span><span><i class="anl-sw" style="background:#A78BFA"></i>Second œuvre · technique · OPR</span></div></div></div>';
  }
  function paneDocs(docs){
    if(!docs || !docs.length) return '<div class="anl-h">Documents du dossier d\'analyse</div><p class="anl-lead">Aucun document rattaché pour l\'instant.</p>';
    var ic='<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg>';
    var list=docs.map(function(d){
      var conf=/restreint|confiden|T2|analyse/i.test((d.visibility||'')+' '+(d.category||''));
      var url=d.file_path||d.url||'#';
      var openable=url && url.indexOf('PENDING')<0 && /^https?:/i.test(url);
      var inner='<div class="di">'+ic+'</div><div class="dt"><h4>'+esc(d.title||d.name||'Document')+'</h4><p>'+esc(d.category||'Document')+(openable?' · ouvrir':' · lien à venir')+'</p></div>'+
        (conf?'<span class="anl-lock">CONFIDENTIEL · T2</span>':'<span class="anl-lock t0">PROJET · T0</span>');
      return openable
        ? '<a class="anl-doc" href="'+esc(url)+'" target="_blank" rel="noopener">'+inner+'</a>'
        : '<div class="anl-doc" style="cursor:default">'+inner+'</div>';
    }).join('');
    return '<div class="anl-h">Documents du dossier d\'analyse</div>'+
      '<p class="anl-lead">Les pièces <span class="anl-lock" style="display:inline-block">CONFIDENTIEL</span> ne sont visibles que de la MOA et de la MOE.</p>'+list;
  }

  var TABS = [
  var PHOTOS_URL = 'https://cadencearchitectes-my.sharepoint.com/:f:/g/personal/f_clarisse_cadence-architectes_fr/IgB7SkaBqZRQR5GF0o1R_skOAZOu0xTYt5FgHaklCy7fR-w?e=m1vrpC';

  function panePhotos(){
    var embedUrl = PHOTOS_URL + '&action=embedview&viewid=&wdAllowInteractivity=False';
    return '<div class="anl-h">Photos du chantier</div>'+
      '<div style="margin-bottom:14px;display:flex;align-items:center;gap:12px">'+
        '<a href="'+PHOTOS_URL+'" target="_blank" rel="noopener" style="display:inline-flex;align-items:center;gap:7px;padding:9px 16px;background:var(--azure);color:#fff;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;transition:opacity .15s" onmouseover="this.style.opacity=\'.8\'" onmouseout="this.style.opacity=\'1\'">'+
          '<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>'+
          'Ouvrir dans SharePoint</a>'+
        '<span style="font-size:12px;color:var(--text-faint)">Galerie partagée · Château Moussy-le-Vieux</span>'+
      '</div>'+
      '<div style="position:relative;width:100%;border-radius:12px;overflow:hidden;border:1px solid var(--border);background:var(--surface)">'+
        '<iframe src="'+embedUrl+'" '+
          'style="width:100%;height:680px;border:none;display:block" '+
          'title="Galerie photos chantier" '+
          'allowfullscreen loading="lazy">'+
        '</iframe>'+
        '<div id="photos-fallback" style="display:none;padding:32px;text-align:center;color:var(--text-faint)">'+
          '<p style="margin-bottom:12px">La galerie ne peut pas s\'afficher en ligne.</p>'+
          '<a href="'+PHOTOS_URL+'" target="_blank" rel="noopener" style="color:var(--azure);text-decoration:underline">Ouvrir SharePoint dans un nouvel onglet →</a>'+
        '</div>'+
      '</div>';
  }

    { id:'synth', label:'Synthèse' },
    { id:'offres', label:'Offres par lot', count:3 },
    { id:'comparatif', label:'Comparatif GO' },
    { id:'cctp', label:'Conformité CCTP' },
    { id:'alertes', label:'Alertes', count:6 },
    { id:'breeam', label:'BREEAM' },
    { id:'planning', label:'Planning' },
    { id:'docs', label:'Documents' },
    { id:'photos', label:'Photos' }
  ];

  async function mount(project){
    injectStyle();
    var d = DATA[project.slug];
    var nav = document.getElementById('tabsNav');
    var main = document.querySelector('.layout > main') || document.querySelector('main');
    if(!nav || !main) return;

    // documents (live depuis Supabase, sinon vide)
    var docs = [];
    try {
      if (window.AxionAuth && AxionAuth.sb) {
        var r = await AxionAuth.sb.from('documents').select('*').eq('project_id', project.id).order('title');
        docs = r.data || [];
      }
    } catch(e){}

    // onglets
    nav.innerHTML = TABS.map(function(t,i){
      return '<button class="tab" role="tab" data-tab="anl-'+t.id+'"'+(i===0?' aria-selected="true"':'')+'>'+esc(t.label)+
        (t.count?' <span class="badge">'+t.count+'</span>':'')+'</button>';
    }).join('');

    // contenu (si pas de dataset spécifique : Synthèse minimale + Documents)
    var panes;
    if (d) {
      panes = {
        synth: paneSynth(d), offres: paneOffres(d), comparatif: paneComparatif(d),
        cctp: paneCctp(d), alertes: paneAlertes(d), breeam: paneBreeam(d),
        planning: panePlanning(d), docs: paneDocs(docs), photos: panePhotos()
      };
    } else {
      panes = {
        synth:'<div class="anl-h">Phase d\'analyse</div><p class="anl-lead">Ce chantier est en phase d\'études / analyse des offres. Les documents d\'analyse sont rassemblés dans l\'onglet Documents.</p>',
        offres:'', comparatif:'', cctp:'', alertes:'', breeam:'', planning:'', docs: paneDocs(docs), photos: panePhotos()
      };
    }
    main.innerHTML = TABS.map(function(t,i){
      var body = panes[t.id] || '<p class="anl-lead">À venir.</p>';
      return '<section class="tab-pane'+(i===0?' active':'')+'" id="pane-anl-'+t.id+'">'+body+'</section>';
    }).join('');

    // commutation d'onglets (le handler délégué de chantier.html gère déjà
    // pane-<data-tab> ; on en ajoute un par sécurité si appelé isolément)
    nav.addEventListener('click', function(e){
      var btn = e.target.closest('.tab'); if(!btn) return;
      nav.querySelectorAll('.tab').forEach(function(t){ t.setAttribute('aria-selected', t===btn?'true':'false'); });
      var id = btn.dataset.tab;
      main.querySelectorAll('.tab-pane').forEach(function(p){ p.classList.toggle('active', p.id==='pane-'+id); });
    });
  }

  window.AxionAnalysis = { isAnalysisPhase: isAnalysisPhase, mount: mount, DATA: DATA };
})();
