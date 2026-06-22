const namespace = process.env.K8S_NAMESPACE ?? process.env.NS ?? 'chahen';
const baseUrl = process.env.WORKSTATION_BASE_URL ?? `https://${namespace}.workstation.getbuilt.com`;
const localUserEmail = process.env.LOCAL_PORTFOLIO_USER_EMAIL ?? 'built.branchadmin@getbuilt.local';
const localUserSub = process.env.LOCAL_PORTFOLIO_USER_SUB ?? '1e5ee983-4be3-4aa7-a297-8b32e69fd383';

function base64UrlJson(value) {
  return Buffer.from(JSON.stringify(value)).toString('base64url');
}

function createLocalBuiltToken() {
  const now = Date.now() / 1000;
  const payload = {
    token_use: 'id',
    sub: localUserSub,
    email: localUserEmail,
    email_verified: true,
    iss: 'http://id.getbuilt.local/fakeUserPool',
    mfa_complete: 'true',
    aud: 'fakeClientId',
    exp: now + 3600,
    iat: now,
    auth_time: now,
    'cognito:username': localUserEmail,
    'custom:mfaType': 'sms',
    'apps:default': 'cla',
  };

  return `BUILT.${base64UrlJson(payload)}.FAKE`;
}

const query = `query PortfolioDeals($input: PortfolioDealsSearchInput!) {
  portfolioDeals(input: $input) {
    results {
      dealUid
      dealCreatedAt
      dealName
      dealStatus
      __typename
    }
    totals {
      totalCount
      __typename
    }
    __typename
  }
}`;

const variables = {
  input: {
    pageSize: 25,
    pageNumber: 1,
    sortField: 'deal_created_at',
    sortDirection: 'DESC',
    filters: {
      flexFields: [],
    },
    groupBy: [],
    dealStatusSortOrder: [
      'Pending',
      'Borrower Prep',
      'Loan Sizing',
      'Term Sheet',
      'Closing',
      'Asset Management',
      'Active Construction',
      'Construction Complete',
      'Paid Off',
      'Defaulted',
      'Archived',
      'Frozen',
    ],
  },
};

const response = await fetch(`${baseUrl}/lending-portfolio-product-api/graphql`, {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${createLocalBuiltToken()}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ query, variables }),
});

const text = await response.text();
let parsed;
try {
  parsed = JSON.parse(text);
} catch {
  parsed = { raw: text };
}

const summary = {
  status: response.status,
  hasErrors: Array.isArray(parsed.errors) && parsed.errors.length > 0,
  errors: parsed.errors,
  resultCount: parsed.data?.portfolioDeals?.results?.length,
  totalCount: parsed.data?.portfolioDeals?.totals?.totalCount,
};
console.log(JSON.stringify(summary, null, 2));

if (summary.status < 200 || summary.status >= 300 || summary.hasErrors) {
  process.exitCode = 1;
}
