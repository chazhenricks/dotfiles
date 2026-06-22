const namespace = process.env.K8S_NAMESPACE ?? process.env.NS ?? 'chahen';
const baseUrl = process.env.WORKSTATION_BASE_URL ?? `https://${namespace}.workstation.getbuilt.com`;
const systemKeyId = process.env.SYSTEM_KEY_ID;
const systemKeySecret = process.env.SYSTEM_KEY_SECRET;
const toleratedFailureUid = process.env.TOLERATED_HYDRATION_FAILURE_UID ?? 'a57c347f-45d2-4b89-bbc6-49e63dc5cda3';
const maxAttempts = Number.parseInt(process.env.HYDRATE_REQUEST_ATTEMPTS ?? '5', 10);

if (!systemKeyId || !systemKeySecret) {
  throw new Error('Missing SYSTEM_KEY_ID or SYSTEM_KEY_SECRET');
}

function wait(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function requestText(url, init = {}) {
  let lastError;
  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      const response = await fetch(url, init);
      const text = await response.text();
      if (response.ok) {
        return { status: response.status, text };
      }

      lastError = new Error(`${response.status} ${text}`);
      if (response.status < 500 && response.status !== 429) {
        throw lastError;
      }
    } catch (error) {
      lastError = error;
    }

    if (attempt < maxAttempts) {
      await wait(1000 * attempt);
    }
  }

  throw lastError;
}

async function requestJson(url, init = {}) {
  const { text } = await requestText(url, init);
  return JSON.parse(text);
}

async function exchangeSystemToken() {
  const response = await requestJson(`${baseUrl}/auth/exchange/system_key?client_id=user-management-product-api`, {
    method: 'POST',
    headers: {
      'X-BUILT-SYSTEM-KEY': systemKeyId,
      Authorization: systemKeySecret,
    },
  });
  return response.token;
}

async function fetchAgreementUids(serviceToken) {
  const uids = [];
  let page = 1;
  let pages = 1;

  while (page <= pages) {
    const url = `${baseUrl}/agreements/v2/agreements?page=${page}&size=100&filters=[]&sort_by=created_at&include_lsr=true&include_estimated_credit_metrics=true`;
    const response = await requestJson(url, {
      headers: {
        Authorization: `Bearer ${serviceToken}`,
      },
    });

    for (const item of response.items ?? []) {
      if (item.agreement_uid) {
        uids.push(item.agreement_uid);
      }
    }

    pages = response.pages ?? page;
    page += 1;
  }

  return Array.from(new Set(uids));
}

async function hydrateDeal(uid) {
  const response = await requestJson(`${baseUrl}/deal-product-api/graphql`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-BUILT-SYSTEM-KEY': systemKeyId,
      Authorization: systemKeySecret,
    },
    body: JSON.stringify({
      query: 'mutation HydrateDealEventById($dealId: ID!) { hydrateDealEventById(dealId: $dealId) { dealUid } }',
      variables: { dealId: uid },
    }),
  });

  if (response.errors?.length) {
    throw new Error(JSON.stringify(response.errors));
  }

  return response.data?.hydrateDealEventById?.dealUid ?? uid;
}

const serviceToken = await exchangeSystemToken();
const uids = await fetchAgreementUids(serviceToken);
console.log(`Found ${uids.length} agreement/deal UID(s).`);

let fulfilled = 0;
let rejected = 0;
const failures = [];

for (const uid of uids) {
  try {
    await hydrateDeal(uid);
    fulfilled += 1;
    console.log(`hydrated ${uid}`);
  } catch (error) {
    rejected += 1;
    failures.push({ uid, message: error.message });
    console.error(`failed ${uid}: ${error.message}`);
  }
}

const summary = { fulfilled, rejected, failures };
console.log(JSON.stringify(summary, null, 2));

const onlyToleratedFailure = failures.length === 1 && failures[0].uid === toleratedFailureUid;
if (fulfilled === 0 || (rejected > 0 && !onlyToleratedFailure)) {
  process.exitCode = 1;
}
