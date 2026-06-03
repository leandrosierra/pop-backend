import crypto from "node:crypto";
import bcrypt from "bcryptjs";
import cors from "cors";
import express from "express";
import pg from "pg";

const { Pool } = pg;

const PORT = Number(process.env.SERVER_PORT || process.env.PORT || 8080);
const TOKEN_SECRET = process.env.POP_TOKEN_SECRET || "";
const TOKEN_TTL_SECONDS = Number(process.env.POP_TOKEN_TTL_SECONDS || 86400);

if (TOKEN_SECRET.trim().length < 32) {
  throw new Error("POP_TOKEN_SECRET must contain at least 32 characters.");
}

const pool = new Pool(parsePgConfig(process.env.POP_DB_URL, process.env.POP_DB_USERNAME, process.env.POP_DB_PASSWORD));
const app = express();

app.disable("x-powered-by");
app.use(express.json({ limit: "1mb" }));
app.use(cors({
  origin(origin, done) {
    done(null, !origin || isAllowedOrigin(origin));
  },
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Authorization", "Content-Type", "Accept", "Origin"]
}));

app.get("/health", (_req, res) => res.json({ status: "ok" }));
app.post("/user/create", route(async (req, res) => res.json(await createUser(req.body || {}))));
app.post("/user/login", route(async (req, res) => res.json(await login(req.body || {}))));
app.post("/user/oauth/login", route(async (_req, res) => res.status(401).end()));

app.use(authenticate);

app.get("/user/all", requireAdmin, pageRoute("users", "id_user", userFromRow, userSelect()));
app.get("/user/current", route(async (req, res) => res.json(await getUser(req.user.userId))));
app.delete("/user/current", route(async (req, res) => {
  await deleteUser(req.user.userId, req.user);
  res.json({});
}));
app.put("/user/current/password", route(async (req, res) => {
  const password = String((req.body || {}).password || "");
  await db("update users set password=$1, date_modification=now() where id_user=$2", [bcrypt.hashSync(password, 12), req.user.userId]);
  res.json({});
}));
app.get("/user/current/language", route(async (req, res) => res.json({ code: await readLanguageCode(req.user.userId) })));
app.put("/user/current/language", route(async (req, res) => {
  const code = normalizeLanguageCode((req.body || {}).code);
  const user = await getUser(req.user.userId);
  const lang = await one("select id_langue from langues_ref where upper(code)=upper($1) limit 1", [code]);
  if (!lang) throw httpError(404);
  await db("delete from user_parametres_langue where id_parametre=$1", [user.parametres.idParametre]);
  await db("insert into user_parametres_langue (id_parametre,id_langue,ordre) values ($1,$2,1)", [user.parametres.idParametre, lang.id_langue]);
  res.json({ code });
}));
app.get("/user/:id", route(async (req, res) => {
  requireCurrentUserOrAdmin(req.user, Number(req.params.id));
  res.json(await getUser(req.params.id));
}));
app.put("/user/update", route(async (req, res) => {
  const body = req.body || {};
  requireCurrentUserOrAdmin(req.user, Number(body.id));
  const target = await getUser(body.id);
  const roleId = req.user.role === "ADMIN" && body.role ? idFrom(body.role, "idRole") : target.role.idRole;
  const actif = req.user.role === "ADMIN" && typeof body.actif === "boolean" ? body.actif : target.actif;
  await db(
    "update users set nom=$1, prenom=$2, email=$3, id_role=$4, actif=$5, date_modification=now() where id_user=$6",
    [body.nom ?? target.nom, body.prenom ?? target.prenom, body.email ?? target.email, roleId, actif, target.id]
  );
  res.json(await getUser(target.id));
}));
app.delete("/user/delete/:id", route(async (req, res) => {
  requireCurrentUserOrAdmin(req.user, Number(req.params.id));
  await deleteUser(Number(req.params.id), req.user);
  res.json({});
}));
app.post("/user/:id/questions", route(async (req, res) => {
  requireCurrentUserOrAdmin(req.user, Number(req.params.id));
  res.json(await pageQuery(req, questionBaseSql("q.id_user=$1"), [Number(req.params.id)], "q.id_question desc", questionFromRow));
}));

app.get("/question/all", requireAdmin, route(async (req, res) => {
  res.json(await pageQuery(req, questionBaseSql("true"), [], "q.id_question desc", questionFromRow));
}));
app.get("/question/feed", route(async (req, res) => {
  const sql = questionBaseSql("st.code=$1 and q.id_user<>$2 and not exists (select 1 from questions_stat s where s.id_question=q.id_question and s.id_user=$2)");
  res.json(await pageQuery(req, sql, ["ACTIF", req.user.userId], "q.date_creation desc nulls last, q.id_question desc", questionFromRow));
}));
app.post("/question/create", route(async (req, res) => {
  const body = req.body || {};
  const draft = await statusByCode("BROUILLON");
  const inserted = await one(
    "insert into questions (id_user,id_statut,code,libelle,description,image,forwards,date_expiration) values ($1,$2,$3,$4,$5,$6,$7,$8) returning id_question",
    [req.user.userId, draft.idStatut, body.code || null, body.libelle || null, body.description || null, body.image || null, body.forwards || 0, body.dateExpiration || null]
  );
  res.json(await getQuestion(inserted.id_question));
}));
app.post("/question/geo/create", requireAdmin, route(async (req, res) => {
  const body = req.body || {};
  const inserted = await one(
    "insert into question_choix_geo (id_question,id_ville,id_pays,id_dept) values ($1,$2,$3,$4) returning *",
    [idFrom(body.question, "id"), idFrom(body.ville, "idVille"), idFrom(body.pays, "idPays"), idFrom(body.dept, "idDept")]
  );
  res.json(inserted);
}));
app.get("/question/user/current", route(async (req, res) => {
  res.json(await pageQuery(req, questionBaseSql("q.id_user=$1"), [req.user.userId], "q.id_question desc", questionFromRow));
}));
app.post("/question/user/:id", route(async (req, res) => {
  requireCurrentUserOrAdmin(req.user, Number(req.params.id));
  res.json(await pageQuery(req, questionBaseSql("q.id_user=$1"), [Number(req.params.id)], "q.id_question desc", questionFromRow));
}));
app.get("/question/:id", route(async (req, res) => {
  const question = await getQuestion(req.params.id);
  requireReadableQuestion(req.user, question);
  res.json(question);
}));
app.put("/question/update", requireAdmin, route(async (req, res) => {
  const body = req.body || {};
  await db(
    "update questions set libelle=$1,description=$2,forwards=$3,image=$4,id_statut=$5,date_modification=now() where id_question=$6",
    [body.libelle, body.description, body.forwards || 0, body.image || null, idFrom(body.statut, "idStatut"), body.id]
  );
  res.json(await getQuestion(body.id));
}));
app.delete("/question/delete/:id", requireAdmin, route(async (req, res) => {
  await db("delete from questions where id_question=$1", [Number(req.params.id)]);
  res.json({});
}));

app.get("/stat/all", requireAdmin, route(async (req, res) => res.json(await pageStats(req, "true", []))));
app.get("/stat/question/:id", route(async (req, res) => {
  const question = await getQuestion(req.params.id);
  requireReadableQuestion(req.user, question);
  res.json(await pageStats(req, "s.id_question=$1", [Number(req.params.id)]));
}));
app.get("/stat/user/current", route(async (req, res) => res.json(await pageStats(req, "s.id_user=$1", [req.user.userId]))));
app.post("/stat/create", route(async (req, res) => {
  const body = req.body || {};
  const questionId = idFrom(body.question, "id");
  const answerId = idFrom(body.reponse, "id");
  const existing = await one("select id_questions_stat from questions_stat where id_question=$1 and id_user=$2", [questionId, req.user.userId]);
  if (existing) {
    await db("update questions_stat set id_answer=$1,date_modification=now() where id_questions_stat=$2", [answerId, existing.id_questions_stat]);
    res.json(await getStat(existing.id_questions_stat));
    return;
  }
  const inserted = await one(
    "insert into questions_stat (id_question,id_answer,id_user,date_creation) values ($1,$2,$3,now()) returning id_questions_stat",
    [questionId, answerId, req.user.userId]
  );
  res.json(await getStat(inserted.id_questions_stat));
}));
app.get("/stat/:id", route(async (req, res) => {
  const stat = await getStat(req.params.id);
  requireAccessibleStat(req.user, stat);
  res.json(stat);
}));
app.put("/stat/update", route(async (req, res) => {
  const body = req.body || {};
  const stat = await getStat(body.idStat);
  requireAccessibleStat(req.user, stat);
  await db("update questions_stat set id_answer=$1,date_modification=now() where id_questions_stat=$2", [idFrom(body.reponse, "id"), body.idStat]);
  res.json(await getStat(body.idStat));
}));

app.get("/actualite/all", route(async (req, res) => res.json(await pageTable(req, "actualites", "date_publication desc nulls last", actualiteFromRow))));
app.post("/actualite/create", requireAdmin, route(async (req, res) => {
  const b = req.body || {};
  const row = await one("insert into actualites (source,titre,resume,url,date_publication,date_creation) values ($1,$2,$3,$4,$5,now()) returning *", [b.source, b.titre, b.resume, b.url, b.datePublication || null]);
  res.json(actualiteFromRow(row));
}));
app.get("/actualite/suggestions", route(async (req, res) => res.json(await pageSuggestions(req, "true", []))));
app.post("/actualite/:id/question/suggest", requireAdmin, route(async (req, res) => {
  const actualite = await findOne("actualites", "id_actualite", req.params.id);
  const existing = await one("select id_question_suggestion from question_suggestions where id_actualite=$1", [actualite.id_actualite]);
  if (existing) {
    res.json((await pageSuggestions(req, "s.id_question_suggestion=$1", [existing.id_question_suggestion])).content[0]);
    return;
  }
  const actif = await statusByCode("ACTIF");
  const q = await one(
    "insert into questions (id_user,id_statut,code,libelle,description,date_expiration) values ($1,$2,$3,$4,$5,now()+interval '30 days') returning id_question",
    [req.user.userId, actif.idStatut, `ACTU-${actualite.id_actualite}`, limit(`Faut-il agir sur ${actualite.titre}`, 255), actualite.resume]
  );
  const s = await one("insert into question_suggestions (id_actualite,id_question,statut,titre,description,date_creation) values ($1,$2,$3,$4,$5,now()) returning id_question_suggestion", [actualite.id_actualite, q.id_question, "PUBLIEE", limit(`Faut-il agir sur ${actualite.titre}`, 255), actualite.resume]);
  res.json((await pageSuggestions(req, "s.id_question_suggestion=$1", [s.id_question_suggestion])).content[0]);
}));

app.get("/discussion/question/:id/comments", route(async (req, res) => {
  const question = await getQuestion(req.params.id);
  requireReadableQuestion(req.user, question);
  res.json(await pageComments(req, "c.id_question=$1", [Number(req.params.id)]));
}));
app.post("/discussion/question/:id/comment/create", route(async (req, res) => {
  const question = await getQuestion(req.params.id);
  requireReadableQuestion(req.user, question);
  const b = req.body || {};
  const parentId = b.parentComment ? idFrom(b.parentComment, "id") : null;
  const row = await one("insert into question_comments (id_question,id_user,id_parent_comment,contenu,date_creation) values ($1,$2,$3,$4,now()) returning id_comment", [question.id, req.user.userId, parentId, b.contenu]);
  res.json((await pageComments(req, "c.id_comment=$1", [row.id_comment])).content[0]);
}));
app.put("/discussion/comment/update", route(async (req, res) => {
  const b = req.body || {};
  const current = await findOne("question_comments", "id_comment", b.id);
  requireCurrentUserOrAdmin(req.user, current.id_user);
  await db("update question_comments set contenu=$1,date_modification=now() where id_comment=$2", [b.contenu, b.id]);
  res.json((await pageComments(req, "c.id_comment=$1", [b.id])).content[0]);
}));
app.delete("/discussion/comment/delete/:id", route(async (req, res) => {
  const current = await findOne("question_comments", "id_comment", req.params.id);
  requireCurrentUserOrAdmin(req.user, current.id_user);
  await db("delete from question_comments where id_comment=$1", [Number(req.params.id)]);
  res.json({});
}));
app.get("/discussion/question/:id/meetings", route(async (req, res) => {
  const question = await getQuestion(req.params.id);
  requireReadableQuestion(req.user, question);
  res.json(await pageMeetings(req, "m.id_question=$1", [Number(req.params.id)]));
}));
app.post("/discussion/question/:id/meeting/create", route(async (req, res) => {
  const question = await getQuestion(req.params.id);
  requireReadableQuestion(req.user, question);
  const b = req.body || {};
  const row = await one("insert into question_meetings (id_question,id_user,type_meeting,titre,description,lieu,url,date_debut,date_fin,date_creation) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,now()) returning id_meeting", [question.id, req.user.userId, b.typeMeeting, b.titre, b.description, b.lieu, b.url, b.dateDebut || null, b.dateFin || null]);
  res.json((await pageMeetings(req, "m.id_meeting=$1", [row.id_meeting])).content[0]);
}));
app.put("/discussion/meeting/update", route(async (req, res) => {
  const b = req.body || {};
  const current = await findOne("question_meetings", "id_meeting", b.id);
  requireCurrentUserOrAdmin(req.user, current.id_user);
  await db("update question_meetings set type_meeting=$1,titre=$2,description=$3,lieu=$4,url=$5,date_debut=$6,date_fin=$7,date_modification=now() where id_meeting=$8", [b.typeMeeting, b.titre, b.description, b.lieu, b.url, b.dateDebut || null, b.dateFin || null, b.id]);
  res.json((await pageMeetings(req, "m.id_meeting=$1", [b.id])).content[0]);
}));
app.delete("/discussion/meeting/delete/:id", route(async (req, res) => {
  const current = await findOne("question_meetings", "id_meeting", req.params.id);
  requireCurrentUserOrAdmin(req.user, current.id_user);
  await db("delete from question_meetings where id_meeting=$1", [Number(req.params.id)]);
  res.json({});
}));

app.get("/loi/all", route(async (req, res) => res.json(await pageTable(req, "lois", "date_creation desc nulls last", loiFromRow))));
app.post("/loi/create", requireAdmin, route(async (req, res) => {
  const b = req.body || {};
  const row = await one("insert into lois (code,titre,contenu,source,date_publication,date_creation) values ($1,$2,$3,$4,$5,now()) returning *", [b.code, b.titre, b.contenu, b.source, b.datePublication || null]);
  res.json(loiFromRow(row));
}));
app.put("/loi/update", requireAdmin, route(async (req, res) => {
  const b = req.body || {};
  await db("update lois set code=$1,titre=$2,contenu=$3,source=$4,date_publication=$5,date_modification=now() where id_loi=$6", [b.code, b.titre, b.contenu, b.source, b.datePublication || null, b.id]);
  res.json(loiFromRow(await findOne("lois", "id_loi", b.id)));
}));
app.get("/loi/incoherence/all", route(async (req, res) => res.json(await pageIncoherences(req, "true", []))));
app.get("/loi/:id/incoherences", route(async (req, res) => res.json(await pageIncoherences(req, "i.id_loi=$1 or i.id_loi_reference=$1", [Number(req.params.id)]))));
app.post("/loi/incoherence/create", requireAdmin, route(async (req, res) => {
  const b = req.body || {};
  const row = await one("insert into loi_incoherences (id_loi,id_loi_reference,description,correction_proposee,statut,date_creation) values ($1,$2,$3,$4,$5,now()) returning id_loi_incoherence", [idFrom(b.loi, "id"), idFrom(b.loiReference, "id"), b.description, b.correctionProposee, b.statut]);
  res.json((await pageIncoherences(req, "i.id_loi_incoherence=$1", [row.id_loi_incoherence])).content[0]);
}));
app.get("/loi/proposition/all", requireAdmin, route(async (req, res) => res.json(await pagePropositions(req, "true", []))));
app.get("/loi/proposition/question/:id", route(async (req, res) => {
  const question = await getQuestion(req.params.id);
  requireReadableQuestion(req.user, question);
  res.json(await pagePropositions(req, "p.id_question=$1", [Number(req.params.id)]));
}));
app.get("/loi/proposition/user/current", route(async (req, res) => res.json(await pagePropositions(req, "p.id_user=$1", [req.user.userId]))));
app.post("/loi/proposition/create", route(async (req, res) => {
  const b = req.body || {};
  const question = await getQuestion(idFrom(b.question, "id"));
  requireReadableQuestion(req.user, question);
  const row = await one("insert into propositions_loi (id_question,id_user,titre,expose_motifs,dispositif,analyse_conformite,statut,date_creation) values ($1,$2,$3,$4,$5,$6,$7,now()) returning id_proposition_loi", [question.id, req.user.userId, b.titre, b.exposeMotifs, b.dispositif, b.analyseConformite, b.statut]);
  res.json((await pagePropositions(req, "p.id_proposition_loi=$1", [row.id_proposition_loi])).content[0]);
}));
app.put("/loi/proposition/update", route(async (req, res) => {
  const b = req.body || {};
  const current = await findOne("propositions_loi", "id_proposition_loi", b.id);
  requireCurrentUserOrAdmin(req.user, current.id_user);
  await db("update propositions_loi set titre=$1,expose_motifs=$2,dispositif=$3,analyse_conformite=$4,statut=$5,date_modification=now() where id_proposition_loi=$6", [b.titre, b.exposeMotifs, b.dispositif, b.analyseConformite, b.statut, b.id]);
  res.json((await pagePropositions(req, "p.id_proposition_loi=$1", [b.id])).content[0]);
}));
app.get("/loi/:id", route(async (req, res) => res.json(loiFromRow(await findOne("lois", "id_loi", req.params.id)))));

app.get("/budget/all", requireAdmin, route(async (req, res) => res.json(await pageBudgets(req, "true", []))));
app.get("/budget/territoire/:niveau/:code", route(async (req, res) => res.json(await pageBudgets(req, "b.niveau=$1 and b.code_territoire=$2", [req.params.niveau, req.params.code]))));
app.post("/budget/create", requireAdmin, route(async (req, res) => {
  const b = req.body || {};
  const row = await one("insert into budgets (niveau,code_territoire,libelle_territoire,annee,montant_total,date_creation) values ($1,$2,$3,$4,$5,now()) returning id_budget", [b.niveau, b.codeTerritoire, b.libelleTerritoire, b.annee, b.montantTotal]);
  res.json(await getBudget(row.id_budget));
}));
app.post("/budget/:id/poste/create", requireAdmin, route(async (req, res) => {
  const b = req.body || {};
  const row = await one("insert into budget_postes (id_budget,code,libelle,description,montant_actuel) values ($1,$2,$3,$4,$5) returning *", [Number(req.params.id), b.code, b.libelle, b.description, b.montantActuel]);
  res.json(budgetPosteFromRow(row));
}));
app.post("/budget/poste/:id/impact/create", requireAdmin, route(async (req, res) => {
  const b = req.body || {};
  const row = await one("insert into budget_impacts (id_budget_poste,sens,libelle,description,seuil_pourcentage) values ($1,$2,$3,$4,$5) returning *", [Number(req.params.id), b.sens, b.libelle, b.description, b.seuilPourcentage]);
  res.json(budgetImpactFromRow(row));
}));
app.get("/budget/choix/user/current", route(async (req, res) => res.json(await pageBudgetChoix(req, "c.id_user=$1", [req.user.userId]))));
app.get("/budget/choix/:id", route(async (req, res) => {
  const choix = await getBudgetChoix(req.params.id);
  requireCurrentUserOrAdmin(req.user, choix.user.id);
  res.json(choix);
}));
app.get("/budget/choix/:id/impacts", route(async (req, res) => res.json(await impactsForChoix(req.params.id))));
app.post("/budget/choix/create", route(async (req, res) => {
  const b = req.body || {};
  const budgetId = idFrom(b.budget, "id");
  const client = await pool.connect();
  try {
    await client.query("begin");
    let choix = (await client.query("select id_budget_choix from budget_choix where id_budget=$1 and id_user=$2", [budgetId, req.user.userId])).rows[0];
    if (choix) {
      await client.query("delete from budget_choix_postes where id_budget_choix=$1", [choix.id_budget_choix]);
      await client.query("update budget_choix set date_modification=now() where id_budget_choix=$1", [choix.id_budget_choix]);
    } else {
      choix = (await client.query("insert into budget_choix (id_budget,id_user,date_creation) values ($1,$2,now()) returning id_budget_choix", [budgetId, req.user.userId])).rows[0];
    }
    for (const allocation of b.allocations || []) {
      await client.query("insert into budget_choix_postes (id_budget_choix,id_budget_poste,montant) values ($1,$2,$3)", [choix.id_budget_choix, idFrom(allocation.poste, "id"), allocation.montant]);
    }
    await client.query("commit");
    const result = await getBudgetChoix(choix.id_budget_choix);
    res.json({ choix: result, impacts: await impactsForChoix(choix.id_budget_choix) });
  } catch (error) {
    await client.query("rollback");
    throw error;
  } finally {
    client.release();
  }
}));
app.get("/budget/:id", route(async (req, res) => res.json(await getBudget(req.params.id))));

app.use((err, _req, res, _next) => {
  const status = err.status || 500;
  if (status >= 500) console.error(err);
  res.status(status).json(status >= 500 ? { error: "Internal Server Error" } : { error: err.message || "Error" });
});

app.listen(PORT, () => {
  console.log(`pop-backend node listening on ${PORT}`);
});

function parsePgConfig(url, user, password) {
  const value = String(url || "");
  if (!value.startsWith("jdbc:postgresql://")) throw new Error("POP_DB_URL must be a jdbc:postgresql:// URL");
  const parsed = new URL(value.replace(/^jdbc:/, ""));
  return {
    host: parsed.hostname,
    port: Number(parsed.port || 5432),
    database: parsed.pathname.replace(/^\//, ""),
    user,
    password,
    max: Number(process.env.PG_POOL_MAX || 5),
    idleTimeoutMillis: 30000
  };
}

function isAllowedOrigin(origin) {
  const local = ["localhost", "127.0.0.1"];
  const url = new URL(origin);
  return (local.includes(url.hostname) && url.port) || (url.protocol === "https:" && (url.hostname === "leandro-sierra.com" || url.hostname.endsWith(".leandro-sierra.com")));
}

function route(fn) {
  return (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
}

async function db(sql, params = []) {
  return pool.query(sql, params);
}

async function one(sql, params = []) {
  return (await db(sql, params)).rows[0] || null;
}

async function findOne(table, idColumn, id) {
  const row = await one(`select * from ${table} where ${idColumn}=$1`, [Number(id)]);
  if (!row) throw httpError(404, "Not found");
  return row;
}

function httpError(status, message = status === 403 ? "Forbidden" : status === 401 ? "Unauthorized" : "Not found") {
  const error = new Error(message);
  error.status = status;
  return error;
}

async function authenticate(req, _res, next) {
  const header = req.get("authorization") || "";
  if (!header.startsWith("Bearer ")) return next(httpError(401, "Unauthorized"));
  const principal = verifyToken(header.slice("Bearer ".length).trim());
  const user = await one("select u.id_user, u.actif, r.code role_code from users u left join roles r on r.id_role=u.id_role where u.id_user=$1", [principal.userId]);
  if (!user || !user.actif) return next(httpError(401, "Unauthorized"));
  req.user = { userId: Number(user.id_user), role: user.role_code || principal.role || "USER" };
  next();
}

function requireAdmin(req, _res, next) {
  if (req.user.role !== "ADMIN") return next(httpError(403, "Forbidden"));
  next();
}

function requireCurrentUserOrAdmin(principal, userId) {
  if (principal.role !== "ADMIN" && Number(principal.userId) !== Number(userId)) throw httpError(403, "Forbidden");
}

function createToken(userId, role) {
  const expiresAt = Math.floor(Date.now() / 1000) + TOKEN_TTL_SECONDS;
  const encodedPayload = base64url(`${userId}:${role}:${expiresAt}`);
  return `${encodedPayload}.${sign(encodedPayload)}`;
}

function verifyToken(token) {
  const parts = token.split(".");
  if (parts.length !== 2 || sign(parts[0]) !== parts[1]) throw httpError(401, "Unauthorized");
  const values = Buffer.from(parts[0], "base64url").toString("utf8").split(":");
  if (values.length !== 3 || Number(values[2]) < Math.floor(Date.now() / 1000)) throw httpError(401, "Unauthorized");
  return { userId: Number(values[0]), role: values[1] };
}

function sign(payload) {
  return crypto.createHmac("sha256", TOKEN_SECRET).update(payload).digest("base64url");
}

function base64url(value) {
  return Buffer.from(value, "utf8").toString("base64url");
}

async function createUser(body) {
  const role = await one("select id_role from roles where code=$1", ["USER"]);
  const hash = bcrypt.hashSync(String(body.password || ""), 12);
  const row = await one(
    "insert into users (id_role,login,nom,prenom,email,password,actif) values ($1,$2,$3,$4,$5,$6,true) returning id_user",
    [role.id_role, body.login, body.nom || null, body.prenom || null, body.email, hash]
  );
  return getUser(row.id_user);
}

async function login(body) {
  const authUser = await one(`${userSelect(true)} where u.login=$1`, [body.login]);
  if (!authUser || !authUser.actif || !matchesPassword(String(body.password || ""), authUser.password)) throw httpError(401, "Unauthorized");
  if (!String(authUser.password).startsWith("$2")) {
    await db("update users set password=$1,date_modification=now() where id_user=$2", [bcrypt.hashSync(String(body.password || ""), 12), authUser.id_user]);
  }
  const user = userFromRow(authUser);
  const role = user.role?.code || "USER";
  const token = createToken(user.id, role);
  return { token, refreshToken: token, user };
}

function matchesPassword(raw, stored) {
  if (!stored || !raw) return false;
  return String(stored).startsWith("$2") ? bcrypt.compareSync(raw, stored) : stored === raw;
}

async function getUser(id) {
  const row = await one(`${userSelect()} where u.id_user=$1`, [Number(id)]);
  if (!row) throw httpError(404, "Not found");
  return userFromRow(row);
}

async function deleteUser(id, principal) {
  const user = await getUser(id);
  if (user.role?.code === "ADMIN") throw httpError(403, "Forbidden");
  requireCurrentUserOrAdmin(principal, user.id);
  await db("delete from users where id_user=$1", [user.id]);
}

function userSelect(includePassword = false) {
  return `select u.id_user,u.login,u.nom,u.prenom,u.email,u.actif,u.date_creation,u.date_modification,u.date_suppression,u.id_parametre,${includePassword ? "u.password," : ""}r.id_role,r.code role_code,r.libelle role_libelle from users u left join roles r on r.id_role=u.id_role`;
}

function userFromRow(r) {
  return {
    id: Number(r.id_user),
    login: r.login,
    nom: r.nom,
    prenom: r.prenom,
    email: r.email,
    actif: Boolean(r.actif),
    role: r.id_role ? { idRole: Number(r.id_role), code: r.role_code, libelle: r.role_libelle } : null,
    parametres: r.id_parametre ? { idParametre: Number(r.id_parametre) } : null,
    adresses: [],
    interets: [],
    choixGeo: [],
    dateCreation: r.date_creation,
    dateModification: r.date_modification,
    dateSuppression: r.date_suppression
  };
}

async function readLanguageCode(userId) {
  const user = await getUser(userId);
  if (!user.parametres) return "FR";
  const row = await one("select l.code from user_parametres_langue upl join langues_ref l on l.id_langue=upl.id_langue where upl.id_parametre=$1 order by coalesce(upl.ordre,0), l.id_langue limit 1", [user.parametres.idParametre]);
  return normalizeLanguageCode(row?.code);
}

function normalizeLanguageCode(code) {
  return String(code || "FR").trim().toUpperCase() || "FR";
}

async function statusByCode(code) {
  const row = await one("select id_statut,code,libelle from statut_ref where code=$1", [code]);
  if (!row) throw httpError(404, "Not found");
  return statutFromRow(row);
}

async function getQuestion(id) {
  const page = await pageQuery({ query: { page: 0, size: 1 } }, questionBaseSql("q.id_question=$1"), [Number(id)], "q.id_question", questionFromRow);
  if (!page.content[0]) throw httpError(404, "Not found");
  return page.content[0];
}

function questionBaseSql(where) {
  return `select q.*, st.id_statut, st.code statut_code, st.libelle statut_libelle, u.id_user user_id, u.login user_login, u.nom user_nom, u.prenom user_prenom, u.email user_email, u.actif user_actif, r.id_role user_role_id, r.code user_role_code, r.libelle user_role_libelle from questions q join statut_ref st on st.id_statut=q.id_statut left join users u on u.id_user=q.id_user left join roles r on r.id_role=u.id_role where ${where}`;
}

function questionFromRow(r) {
  return {
    id: Number(r.id_question),
    code: r.code,
    libelle: r.libelle,
    description: r.description,
    image: r.image,
    forwards: Number(r.forwards || 0),
    dateCreation: r.date_creation,
    dateModification: r.date_modification,
    dateExpiration: r.date_expiration,
    statut: statutFromRow({ id_statut: r.id_statut, code: r.statut_code, libelle: r.statut_libelle }),
    user: r.user_id ? userFromRow({ id_user: r.user_id, login: r.user_login, nom: r.user_nom, prenom: r.user_prenom, email: r.user_email, actif: r.user_actif, id_role: r.user_role_id, role_code: r.user_role_code, role_libelle: r.user_role_libelle }) : null,
    choixGeo: []
  };
}

function statutFromRow(r) {
  return { idStatut: Number(r.id_statut), code: r.code, libelle: r.libelle };
}

function reponseFromRow(r) {
  return { id: Number(r.id_answer), code: r.answer_code || r.code, libelle: r.answer_libelle || r.libelle };
}

function requireReadableQuestion(principal, question) {
  if (principal.role === "ADMIN") return;
  if (question.user && Number(question.user.id) === Number(principal.userId)) return;
  if (question.statut && question.statut.code === "ACTIF") return;
  throw httpError(403, "Forbidden");
}

async function getStat(id) {
  const page = await pageStats({ query: { page: 0, size: 1 } }, "s.id_questions_stat=$1", [Number(id)]);
  if (!page.content[0]) throw httpError(404, "Not found");
  return page.content[0];
}

async function pageStats(req, where, params) {
  const sql = `select s.*, a.id_answer, a.code answer_code, a.libelle answer_libelle, q.id_question, q.id_user question_user_id, st.code question_status_code, u.id_user stat_user_id from questions_stat s join answer_ref a on a.id_answer=s.id_answer join questions q on q.id_question=s.id_question join statut_ref st on st.id_statut=q.id_statut join users u on u.id_user=s.id_user where ${where}`;
  return pageQuery(req, sql, params, "s.id_questions_stat desc", (r) => ({
    idStat: Number(r.id_questions_stat),
    reponse: reponseFromRow(r),
    question: { id: Number(r.id_question), user: { id: Number(r.question_user_id) }, statut: { code: r.question_status_code } },
    user: { id: Number(r.stat_user_id) },
    dateCreation: r.date_creation,
    dateModification: r.date_modification
  }));
}

function requireAccessibleStat(principal, stat) {
  if (principal.role === "ADMIN" || Number(stat.user?.id) === Number(principal.userId) || Number(stat.question?.user?.id) === Number(principal.userId)) return;
  throw httpError(403, "Forbidden");
}

async function pageQuery(req, baseSql, params, orderBy, mapper) {
  const { page, size, offset } = pageParams(req);
  const rows = (await db(`${baseSql} order by ${orderBy} limit $${params.length + 1} offset $${params.length + 2}`, [...params, size, offset])).rows.map(mapper);
  const countSql = `select count(*)::int total from (${baseSql}) x`;
  const total = (await one(countSql, params)).total;
  return pageResponse(rows, page, size, total);
}

async function pageTable(req, table, orderBy, mapper) {
  return pageQuery(req, `select * from ${table} where true`, [], orderBy, mapper);
}

function pageRoute(table, idColumn, mapper, selectSql) {
  return route(async (req, res) => res.json(await pageQuery(req, `${selectSql} where true`, [], `${idColumn} desc`, mapper)));
}

function pageParams(req) {
  const page = Math.max(0, Number(req.query.page || 0));
  const size = Math.min(100, Math.max(1, Number(req.query.size || 10)));
  return { page, size, offset: page * size };
}

function pageResponse(content, page, size, totalElements) {
  return {
    content,
    totalElements,
    totalPages: Math.ceil(totalElements / size),
    size,
    number: page,
    first: page === 0,
    last: (page + 1) * size >= totalElements,
    numberOfElements: content.length,
    empty: content.length === 0
  };
}

function idFrom(value, key) {
  if (value == null) return null;
  if (typeof value === "number" || typeof value === "string") return Number(value);
  return Number(value[key] ?? value.id ?? value.idStatut ?? value.idRole);
}

function limit(value, max) {
  const text = String(value || "");
  return text.length > max ? text.slice(0, max) : text;
}

function actualiteFromRow(r) {
  return { id: Number(r.id_actualite), source: r.source, titre: r.titre, resume: r.resume, url: r.url, datePublication: r.date_publication, dateCreation: r.date_creation };
}

async function pageSuggestions(req, where, params) {
  const sql = `select s.*, a.titre actualite_titre, q.libelle question_libelle from question_suggestions s left join actualites a on a.id_actualite=s.id_actualite left join questions q on q.id_question=s.id_question where ${where}`;
  return pageQuery(req, sql, params, "s.date_creation desc nulls last", (r) => ({
    id: Number(r.id_question_suggestion),
    actualite: r.id_actualite ? { id: Number(r.id_actualite), titre: r.actualite_titre } : null,
    question: r.id_question ? { id: Number(r.id_question), libelle: r.question_libelle } : null,
    statut: r.statut,
    titre: r.titre,
    description: r.description,
    dateCreation: r.date_creation,
    dateModification: r.date_modification
  }));
}

async function pageComments(req, where, params) {
  const sql = `select c.*, u.login from question_comments c left join users u on u.id_user=c.id_user where ${where}`;
  return pageQuery(req, sql, params, "c.date_creation desc nulls last", (r) => ({
    id: Number(r.id_comment),
    question: { id: Number(r.id_question) },
    user: { id: Number(r.id_user), login: r.login },
    parentComment: r.id_parent_comment ? { id: Number(r.id_parent_comment) } : null,
    contenu: r.contenu,
    dateCreation: r.date_creation,
    dateModification: r.date_modification
  }));
}

async function pageMeetings(req, where, params) {
  const sql = `select m.*, u.login from question_meetings m left join users u on u.id_user=m.id_user where ${where}`;
  return pageQuery(req, sql, params, "m.date_debut asc nulls last", (r) => ({
    id: Number(r.id_meeting),
    question: { id: Number(r.id_question) },
    user: { id: Number(r.id_user), login: r.login },
    typeMeeting: r.type_meeting,
    titre: r.titre,
    description: r.description,
    lieu: r.lieu,
    url: r.url,
    dateDebut: r.date_debut,
    dateFin: r.date_fin,
    dateCreation: r.date_creation,
    dateModification: r.date_modification
  }));
}

function registerSimpleRoutes(prefix, table, idColumn, mapper, fields, orderBy) {
  app.get(`${prefix}/all`, route(async (req, res) => res.json(await pageTable(req, table, orderBy, mapper))));
  app.get(`${prefix}/:id`, route(async (req, res) => res.json(mapper(await findOne(table, idColumn, req.params.id)))));
  app.post(`${prefix}/create`, requireAdmin, route(async (req, res) => {
    const body = req.body || {};
    const columns = fields.concat(["date_creation"]);
    const placeholders = fields.map((_, i) => `$${i + 1}`).concat(["now()"]);
    const values = fields.map((field) => body[camel(field)] ?? null);
    const row = await one(`insert into ${table} (${columns.join(",")}) values (${placeholders.join(",")}) returning *`, values);
    res.json(mapper(row));
  }));
  app.put(`${prefix}/update`, requireAdmin, route(async (req, res) => {
    const body = req.body || {};
    const assignments = fields.map((field, i) => `${field}=$${i + 1}`).concat(["date_modification=now()"]);
    const values = fields.map((field) => body[camel(field)] ?? null).concat([body.id]);
    await db(`update ${table} set ${assignments.join(",")} where ${idColumn}=$${fields.length + 1}`, values);
    res.json(mapper(await findOne(table, idColumn, body.id)));
  }));
}

function camel(snake) {
  return snake.replace(/_([a-z])/g, (_m, c) => c.toUpperCase());
}

function loiFromRow(r) {
  return { id: Number(r.id_loi), code: r.code, titre: r.titre, contenu: r.contenu, source: r.source, datePublication: r.date_publication, dateCreation: r.date_creation, dateModification: r.date_modification };
}

async function pageIncoherences(req, where, params) {
  const sql = `select i.* from loi_incoherences i where ${where}`;
  return pageQuery(req, sql, params, "i.date_creation desc nulls last", (r) => ({
    id: Number(r.id_loi_incoherence),
    loi: { id: Number(r.id_loi) },
    loiReference: { id: Number(r.id_loi_reference) },
    description: r.description,
    correctionProposee: r.correction_proposee,
    statut: r.statut,
    dateCreation: r.date_creation,
    dateModification: r.date_modification
  }));
}

async function pagePropositions(req, where, params) {
  const sql = `select p.* from propositions_loi p where ${where}`;
  return pageQuery(req, sql, params, "p.date_creation desc nulls last", propositionFromRow);
}

function propositionFromRow(r) {
  return { id: Number(r.id_proposition_loi), question: { id: Number(r.id_question) }, user: { id: Number(r.id_user) }, titre: r.titre, exposeMotifs: r.expose_motifs, dispositif: r.dispositif, analyseConformite: r.analyse_conformite, statut: r.statut, dateCreation: r.date_creation, dateModification: r.date_modification };
}

async function pageBudgets(req, where, params) {
  const page = await pageQuery(req, `select b.* from budgets b where ${where}`, params, "b.annee desc nulls last", budgetFromRow);
  page.content = await Promise.all(page.content.map((budget) => getBudget(budget.id)));
  return page;
}

async function getBudget(id) {
  const row = await findOne("budgets", "id_budget", id);
  const budget = budgetFromRow(row);
  budget.postes = (await db("select * from budget_postes where id_budget=$1 order by libelle asc", [budget.id])).rows.map(budgetPosteFromRow);
  return budget;
}

function budgetFromRow(r) {
  return { id: Number(r.id_budget), niveau: r.niveau, codeTerritoire: r.code_territoire, libelleTerritoire: r.libelle_territoire, annee: r.annee, montantTotal: r.montant_total, postes: [], dateCreation: r.date_creation, dateModification: r.date_modification };
}

function budgetPosteFromRow(r) {
  return { id: Number(r.id_budget_poste), code: r.code, libelle: r.libelle, description: r.description, montantActuel: r.montant_actuel, impacts: [] };
}

function budgetImpactFromRow(r) {
  return { id: Number(r.id_budget_impact), sens: r.sens, libelle: r.libelle, description: r.description, seuilPourcentage: r.seuil_pourcentage };
}

async function pageBudgetChoix(req, where, params) {
  const sql = `select c.* from budget_choix c where ${where}`;
  const page = await pageQuery(req, sql, params, "c.date_creation desc nulls last", (r) => ({ id: Number(r.id_budget_choix), budget: { id: Number(r.id_budget) }, user: { id: Number(r.id_user) }, allocations: [], dateCreation: r.date_creation, dateModification: r.date_modification }));
  page.content = await Promise.all(page.content.map((item) => getBudgetChoix(item.id)));
  return page;
}

async function getBudgetChoix(id) {
  const row = await findOne("budget_choix", "id_budget_choix", id);
  const allocations = (await db("select a.*, p.code,p.libelle,p.description,p.montant_actuel from budget_choix_postes a join budget_postes p on p.id_budget_poste=a.id_budget_poste where a.id_budget_choix=$1", [Number(id)])).rows.map((r) => ({
    id: Number(r.id_budget_choix_poste),
    poste: budgetPosteFromRow(r),
    montant: r.montant
  }));
  return { id: Number(row.id_budget_choix), budget: { id: Number(row.id_budget) }, user: { id: Number(row.id_user) }, allocations, dateCreation: row.date_creation, dateModification: row.date_modification };
}

async function impactsForChoix(id) {
  const allocations = (await db("select a.montant,p.id_budget_poste,p.montant_actuel from budget_choix_postes a join budget_postes p on p.id_budget_poste=a.id_budget_poste where a.id_budget_choix=$1", [Number(id)])).rows;
  const out = [];
  for (const allocation of allocations) {
    const current = Number(allocation.montant_actuel || 0);
    const chosen = Number(allocation.montant || 0);
    if (current <= 0) continue;
    const delta = ((chosen - current) * 100) / current;
    const impacts = (await db("select * from budget_impacts where id_budget_poste=$1", [allocation.id_budget_poste])).rows;
    for (const impact of impacts) {
      const threshold = Math.abs(Number(impact.seuil_pourcentage || 0));
      if ((impact.sens === "POSITIF" && delta >= threshold) || (impact.sens === "NEGATIF" && delta <= -threshold)) out.push(budgetImpactFromRow(impact));
    }
  }
  return out;
}
