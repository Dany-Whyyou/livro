// Envoie à Firebase Cloud Messaging les notifications en attente dans `file_push`.
//
// Appelée par la base (trigger sur file_push) avec l'en-tête x-push-secret.
// Secrets attendus : FIREBASE_SERVICE_ACCOUNT (JSON du compte de service), PUSH_SECRET.
// SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont fournis par Supabase.

import { createClient } from "jsr:@supabase/supabase-js@2";

const compte = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}");
const base = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

const TENTATIVES_MAX = 5;
const LOT = 100;

// ─── Jeton d'accès Google (OAuth 2, compte de service) ────────────────────

let jeton: { valeur: string; expire: number } | null = null;

function base64url(octets: Uint8Array): string {
  let binaire = "";
  for (const o of octets) binaire += String.fromCharCode(o);
  return btoa(binaire).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function jetonGoogle(): Promise<string> {
  const maintenant = Math.floor(Date.now() / 1000);
  if (jeton && jeton.expire - 60 > maintenant) return jeton.valeur;

  const encode = (objet: unknown) => base64url(new TextEncoder().encode(JSON.stringify(objet)));
  const entete = encode({ alg: "RS256", typ: "JWT" });
  const contenu = encode({
    iss: compte.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: compte.token_uri,
    iat: maintenant,
    exp: maintenant + 3600,
  });
  const pem = (compte.private_key as string).replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const cle = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", cle, new TextEncoder().encode(`${entete}.${contenu}`)),
  );

  const reponse = await fetch(compte.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${entete}.${contenu}.${base64url(signature)}`,
    }),
  });
  if (!reponse.ok) throw new Error(`Jeton Google refusé : ${reponse.status} ${await reponse.text()}`);
  const json = await reponse.json();
  jeton = { valeur: json.access_token, expire: maintenant + json.expires_in };
  return jeton.valeur;
}

// ─── Envoi d'un message FCM ───────────────────────────────────────────────

type Cible = { topic: string } | { token: string };
type Resultat = { ok: true } | { ok: false; jetonInvalide: boolean; erreur: string };

async function envoyerFcm(cible: Cible, titre: string, message: string, donnees: Record<string, unknown>): Promise<Resultat> {
  const reponse = await fetch(`https://fcm.googleapis.com/v1/projects/${compte.project_id}/messages:send`, {
    method: "POST",
    headers: { Authorization: `Bearer ${await jetonGoogle()}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      message: {
        ...cible,
        notification: { title: titre, body: message },
        // FCM n'accepte que des chaînes dans `data`
        data: Object.fromEntries(Object.entries(donnees).map(([k, v]) => [k, String(v)])),
        android: { priority: "high", notification: { channel_id: "livro" } },
        apns: { payload: { aps: { sound: "default" } } },
      },
    }),
  });
  if (reponse.ok) return { ok: true };
  const texte = await reponse.text();
  // Téléphone désinstallé ou jeton périmé : on le retire
  const jetonInvalide = "token" in cible && (reponse.status === 404 || texte.includes("UNREGISTERED") || texte.includes("INVALID_ARGUMENT"));
  return { ok: false, jetonInvalide, erreur: `${reponse.status} ${texte.slice(0, 300)}` };
}

// ─── Traitement de la file ────────────────────────────────────────────────

Deno.serve(async (requete) => {
  if (requete.headers.get("x-push-secret") !== Deno.env.get("PUSH_SECRET")) {
    return new Response("Non autorisé", { status: 401 });
  }

  const { data: enAttente, error } = await base
    .from("file_push")
    .select("id, sujet, livreur_id, titre, message, donnees, tentatives")
    .is("envoye_le", null)
    .lt("tentatives", TENTATIVES_MAX)
    .order("cree_le")
    .limit(LOT);
  if (error) return new Response(error.message, { status: 500 });

  let envoyes = 0;
  for (const n of enAttente ?? []) {
    const erreurs: string[] = [];

    if (n.sujet) {
      const r = await envoyerFcm({ topic: n.sujet }, n.titre, n.message, n.donnees);
      if (!r.ok) erreurs.push(r.erreur);
    } else {
      const { data: appareils } = await base.from("appareils").select("token").eq("livreur_id", n.livreur_id);
      for (const { token } of appareils ?? []) {
        const r = await envoyerFcm({ token }, n.titre, n.message, n.donnees);
        if (!r.ok) {
          if (r.jetonInvalide) await base.from("appareils").delete().eq("token", token);
          else erreurs.push(r.erreur);
        }
      }
    }

    if (erreurs.length === 0) {
      await base.from("file_push").update({ envoye_le: new Date().toISOString(), erreur: null }).eq("id", n.id);
      envoyes++;
    } else {
      await base.from("file_push").update({ tentatives: n.tentatives + 1, erreur: erreurs.join(" | ") }).eq("id", n.id);
    }
  }

  return Response.json({ traites: enAttente?.length ?? 0, envoyes });
});
