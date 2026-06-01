/* =============================================================================
   AXION — Configuration Supabase (PARTAGÉE portail + planning)
   -----------------------------------------------------------------------------
   Ces deux valeurs sont PUBLIQUES par conception : la clé "publishable"/"anon"
   est destinée à tourner dans le navigateur. La sécurité réelle est assurée
   par les politiques RLS côté base (voir supabase/policies.sql).
   NE JAMAIS mettre ici la clé "service_role" (secrète).
   ============================================================================= */
window.AXION_SUPABASE = {
  url: 'https://phfdrgvdfhwtyycxpahq.supabase.co',
  anonKey: 'sb_publishable_GD32kGL-4Et4FEAAOQQrBQ_zClazT3V',

  // URL du module Planning PROTÉGÉ (handoff SSO par hash d'URL).
  // ⚠️ À renseigner après déploiement du nouveau dépôt AXION-PLANNING sur Vercel.
  //    NE PAS mettre planning-lisa.vercel.app (= planning LIVE public, sans auth).
  //    Laisser vide tant que non déployé → le bouton planning s'affiche « en préparation ».
  planningUrl: '',

  // URL du portail (cible des redirections « non connecté »)
  portalUrl: 'https://axion-sand-iota.vercel.app/axion.html'
};

/* Instancie un client Supabase unique et réutilisable.
   Suppose que le SDK @supabase/supabase-js v2 est déjà chargé (global `supabase`). */
window.getAxionSupabase = function () {
  if (window.__axionSb) return window.__axionSb;
  if (!window.supabase || !window.supabase.createClient) {
    throw new Error('SDK Supabase non chargé : ajoutez <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script> avant ce fichier.');
  }
  window.__axionSb = window.supabase.createClient(
    window.AXION_SUPABASE.url,
    window.AXION_SUPABASE.anonKey,
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false   // on gère le handoff par hash nous-mêmes
      }
    }
  );
  return window.__axionSb;
};
