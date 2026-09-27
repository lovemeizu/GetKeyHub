const express = require("express");
const cors = require("cors");
const crypto = require("crypto");

const app = express();

app.use(cors());
app.use(express.json());

const PORT = Number(process.env.PORT || 3000);

const SITE_URL = String(
  process.env.SITE_URL ||
  "https://lovemeizu.github.io/GetKeyHub"
).replace(/\/+$/, "");

const KEY_PREFIX = String(
  process.env.KEY_PREFIX || "MEIZU"
);

const KEY_HOURS = Number(
  process.env.KEY_HOURS || 48
);

const COOLDOWN_SECONDS = Number(
  process.env.COOLDOWN_SECONDS || 30
);

/*
========================================
LoveMeizu KeyHub
========================================

API:

GET /api/health

GET /api/getlink?hwid=...

GET /api/redeem?hwid=...&token=...

GET /api/verify?key=...&hwid=...

========================================
*/

const keys = new Map();
const sessions = new Map();
const cooldowns = new Map();

function now() {
  return Date.now();
}

/*
========================================
CLEAN EXPIRED DATA
========================================
*/

function cleanExpired() {
  const current = now();

  // Remove expired keys
  for (const [key, data] of keys.entries()) {
    if (data.expiresAt <= current) {
      keys.delete(key);
    }
  }

  // Remove expired sessions
  for (const [token, data] of sessions.entries()) {
    if (
      data.expiresAt <= current ||
      data.redeemed === true
    ) {
      sessions.delete(token);
    }
  }

  // Remove expired cooldowns
  for (const [hwid, expiresAt] of cooldowns.entries()) {
    if (expiresAt <= current) {
      cooldowns.delete(hwid);
    }
  }
}

setInterval(cleanExpired, 60 * 1000).unref();

/*
========================================
HWID VALIDATION
========================================
*/

function normalizeHwid(value) {
  const hwid = String(value || "").trim();

  if (!hwid) {
    return null;
  }

  if (hwid.length < 6 || hwid.length > 160) {
    return null;
  }

  if (!/^[A-Za-z0-9._:-]+$/.test(hwid)) {
    return null;
  }

  return hwid;
}

/*
========================================
GENERATE KEY
========================================
*/

function createKey() {
  const part1 = crypto
    .randomBytes(4)
    .toString("hex")
    .toUpperCase();

  const part2 = crypto
    .randomBytes(4)
    .toString("hex")
    .toUpperCase();

  const part3 = crypto
    .randomBytes(4)
    .toString("hex")
    .toUpperCase();

  return `${KEY_PREFIX}-${part1}-${part2}-${part3}`;
}

/*
========================================
GENERATE ONE-TIME TOKEN
========================================
*/

function createToken() {
  return crypto
    .randomBytes(24)
    .toString("base64url");
}

/*
========================================
HOME
========================================
*/

app.get("/", (_req, res) => {
  res.status(200).type("text").send(
    "LoveMeizu KeyHub is online."
  );
});

/*
========================================
HEALTH CHECK
========================================
*/

app.get("/api/health", (_req, res) => {
  res.json({
    ok: true,
    service: "LoveMeizu KeyHub",
    version: "1.0.0",
    time: new Date().toISOString()
  });
});

/*
========================================
GET LINK
========================================

Creates a temporary token for an HWID.

Example:

/api/getlink?hwid=ABC123456
*/

app.get("/api/getlink", (req, res) => {
  cleanExpired();

  const hwid = normalizeHwid(
    req.query.hwid
  );

  if (!hwid) {
    return res.status(400).json({
      ok: false,
      error: "INVALID_HWID"
    });
  }

  /*
  ----------------------------------------
  COOLDOWN
  ----------------------------------------
  */

  const cooldownUntil =
    cooldowns.get(hwid) || 0;

  if (cooldownUntil > now()) {
    return res.status(429).json({
      ok: false,
      error: "COOLDOWN",
      retryAfter: Math.ceil(
        (cooldownUntil - now()) / 1000
      )
    });
  }

  /*
  ----------------------------------------
  CREATE TOKEN
  ----------------------------------------
  */

  const token = createToken();

  const tokenLifetime =
    10 * 60 * 1000;

  sessions.set(token, {
    hwid: hwid,
    createdAt: now(),
    expiresAt: now() + tokenLifetime,
    redeemed: false
  });

  /*
  ----------------------------------------
  SET COOLDOWN
  ----------------------------------------
  */

  cooldowns.set(
    hwid,
    now() + COOLDOWN_SECONDS * 1000
  );

  /*
  ----------------------------------------
  CREATE CHECKPOINT URL
  ----------------------------------------
  */

  const checkpointUrl =
    `${SITE_URL}/getkey.html` +
    `?hwid=${encodeURIComponent(hwid)}` +
    `&token=${encodeURIComponent(token)}`;

  return res.json({
    ok: true,
    token: token,
    checkpointUrl: checkpointUrl,
    expiresIn: 600
  });
});

/*
========================================
REDEEM
========================================

Example:

/api/redeem?hwid=ABC123456&token=TOKEN
*/

app.get("/api/redeem", (req, res) => {
  cleanExpired();

  const hwid = normalizeHwid(
    req.query.hwid
  );

  const token = String(
    req.query.token || ""
  ).trim();

  if (!hwid || !token) {
    return res.status(400).json({
      ok: false,
      error: "MISSING_HWID_OR_TOKEN"
    });
  }

  /*
  ----------------------------------------
  FIND SESSION
  ----------------------------------------
  */

  const session =
    sessions.get(token);

  if (!session) {
    return res.status(410).json({
      ok: false,
      error: "TOKEN_EXPIRED_OR_INVALID"
    });
  }

  /*
  ----------------------------------------
  TOKEN ALREADY USED
  ----------------------------------------
  */

  if (session.redeemed) {
    return res.status(409).json({
      ok: false,
      error: "TOKEN_ALREADY_USED"
    });
  }

  /*
  ----------------------------------------
  HWID CHECK
  ----------------------------------------
  */

  if (session.hwid !== hwid) {
    return res.status(403).json({
      ok: false,
      error: "HWID_MISMATCH"
    });
  }

  /*
  ----------------------------------------
  MARK TOKEN USED
  ----------------------------------------
  */

  session.redeemed = true;

  /*
  ----------------------------------------
  CREATE KEY
  ----------------------------------------
  */

  const key = createKey();

  const expiresAt =
    now() +
    KEY_HOURS *
    60 *
    60 *
    1000;

  keys.set(key, {
    hwid: hwid,
    createdAt: now(),
    expiresAt: expiresAt
  });

  /*
  ----------------------------------------
  RESPONSE
  ----------------------------------------
  */

  return res.json({
    ok: true,
    key: key,
    expiresAt: expiresAt,
    expiresInHours: KEY_HOURS
  });
});

/*
========================================
VERIFY
========================================

Example:

/api/verify?key=MEIZU-XXXX-XXXX-XXXX&hwid=ABC123456
*/

app.get("/api/verify", (req, res) => {
  cleanExpired();

  const hwid = normalizeHwid(
    req.query.hwid
  );

  const key = String(
    req.query.key || ""
  ).trim();

  if (!hwid || !key) {
    return res.status(400).json({
      ok: false,
      valid: false,
      error: "MISSING_KEY_OR_HWID"
    });
  }

  /*
  ----------------------------------------
  FIND KEY
  ----------------------------------------
  */

  const record =
    keys.get(key);

  if (!record) {
    return res.status(404).json({
      ok: false,
      valid: false,
      error: "KEY_NOT_FOUND"
    });
  }

  /*
  ----------------------------------------
  HWID CHECK
  ----------------------------------------
  */

  if (record.hwid !== hwid) {
    return res.status(403).json({
      ok: false,
      valid: false,
      error: "HWID_MISMATCH"
    });
  }

  /*
  ----------------------------------------
  EXPIRATION
  ----------------------------------------
  */

  if (record.expiresAt <= now()) {
    keys.delete(key);

    return res.status(410).json({
      ok: false,
      valid: false,
      error: "KEY_EXPIRED"
    });
  }

  /*
  ----------------------------------------
  VALID
  ----------------------------------------
  */

  return res.json({
    ok: true,
    valid: true,
    expiresAt: record.expiresAt,
    remainingSeconds: Math.floor(
      (record.expiresAt - now()) / 1000
    )
  });
});

/*
========================================
404 API
========================================
*/

app.use("/api", (_req, res) => {
  res.status(404).json({
    ok: false,
    error: "API_NOT_FOUND"
  });
});

/*
========================================
START SERVER
========================================
*/

app.listen(
  PORT,
  "0.0.0.0",
  () => {
    console.log(
      `LoveMeizu KeyHub running on port ${PORT}`
    );

    console.log(
      `Site URL: ${SITE_URL}`
    );

    console.log(
      `Key prefix: ${KEY_PREFIX}`
    );

    console.log(
      `Key lifetime: ${KEY_HOURS} hours`
    );

    console.log(
      `Cooldown: ${COOLDOWN_SECONDS} seconds`
    );
  }
);
