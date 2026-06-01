/* =============================================================================
   AXION — Couche d'authentification (portail)
   -----------------------------------------------------------------------------
   Responsabilités :
   • signIn / signOut Supabase
   • lecture du profil (user_profiles) → rôle + entreprise
   • redirection selon le rôle
   • construction du lien de handoff SSO vers le Planning (domaine séparé)
   Dépend de : supabase-js v2 + supabase-config.js (chargés avant).
   ============================================================================= */
(function () {
  'use strict';

  var sb = window.getAxionSupabase();

  /* Récupère le profil métier de l'utilisateur connecté.
     RLS : un user ne peut lire que sa propre ligne (admin = toutes). */
  async function fetchProfile(userId) {
    var res = await sb
      .from('user_profiles')
      .select('id, email, full_name, role, company_id')
      .eq('id', userId)
      .single();
    if (res.error) throw res.error;
    return res.data;
  }

  /* Connexion email / mot de passe. Retourne { session, profile }. */
  async function signIn(email, password) {
    var auth = await sb.auth.signInWithPassword({ email: email, password: password });
    if (auth.error) throw auth.error;
    var profile = await fetchProfile(auth.data.user.id);
    return { session: auth.data.session, profile: profile };
  }

  async function signOut() {
    await sb.auth.signOut();
  }

  async function currentSession() {
    var res = await sb.auth.getSession();
    return res.data.session || null;
  }

  /* Construit l'URL du Planning avec handoff SSO :
     on passe les tokens + le rôle dans le hash (jamais loggé côté serveur). */
  function planningHandoffUrl(session, role) {
    var base = window.AXION_SUPABASE.planningUrl;
    var hash = '#sb_at=' + encodeURIComponent(session.access_token) +
               '&sb_rt=' + encodeURIComponent(session.refresh_token) +
               '&sb_role=' + encodeURIComponent(role || '');
    return base + hash;
  }

  /* Redirige vers l'espace adapté au rôle. */
  function routeByRole(profile) {
    // Seuls les rôles 'admin' (MOE, édition, publication, gestion users)
    // et 'user' (entreprise, lecture seule, périmètre RLS) accèdent au dashboard.
    // On garde la logique centralisée ici pour évoluer facilement.
    if (profile.role === 'admin' || profile.role === 'user') {
      window.location.href = 'app.html';
    } else {
      // rôle inconnu → on déconnecte par sécurité
      signOut().finally(function () {
        window.location.href = 'axion.html?error=role';
      });
    }
  }

  // API publique
  window.AxionAuth = {
    sb: sb,
    signIn: signIn,
    signOut: signOut,
    currentSession: currentSession,
    fetchProfile: fetchProfile,
    planningHandoffUrl: planningHandoffUrl,
    routeByRole: routeByRole
  };
})();
