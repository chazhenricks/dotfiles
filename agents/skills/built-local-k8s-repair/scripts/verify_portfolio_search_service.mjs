const namespace = process.env.K8S_NAMESPACE ?? process.env.NS ?? 'chahen';
const baseUrl = process.env.WORKSTATION_BASE_URL ?? `https://${namespace}.workstation.getbuilt.com`;
const indexName = process.env.PORTFOLIO_INDEX ?? 'view-portfolio-deals-main-lambda';
const systemKeyId = process.env.SYSTEM_KEY_ID;
const systemKeySecret = process.env.SYSTEM_KEY_SECRET;

if (!systemKeyId || !systemKeySecret) {
  throw new Error('Missing SYSTEM_KEY_ID or SYSTEM_KEY_SECRET');
}

async function requestText(url, init) {
  const response = await fetch(url, init);
  const text = await response.text();
  return { status: response.status, text };
}

async function requestJson(url, init) {
  const { status, text } = await requestText(url, init);
  if (status < 200 || status >= 300) {
    throw new Error(`${status} ${text}`);
  }
  return JSON.parse(text);
}

const tokenResponse = await requestJson(`${baseUrl}/auth/exchange/system_key?client_id=user-management-product-api`, {
  method: 'POST',
  headers: {
    'X-BUILT-SYSTEM-KEY': systemKeyId,
    Authorization: systemKeySecret,
  },
});

const body = {
  size: 1,
  sort: [
    {
      deal_created_at: {
        order: 'desc',
      },
    },
  ],
  aggs: {
    deal_uid_terms: {
      terms: {
        field: 'deal_uid',
      },
    },
  },
};

const response = await requestText(`${baseUrl}/search/v4/${indexName}/_search`, {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${tokenResponse.token}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(body),
});

const summary = {
  status: response.status,
  body: response.text.slice(0, 1000),
};
console.log(JSON.stringify(summary, null, 2));

if (response.status < 200 || response.status >= 300) {
  process.exitCode = 1;
}
