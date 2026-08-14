// Netlify Function: proxies requests to the official joke API to avoid CORS/rate-limit issues
// Deploy by committing to repository; Netlify will pick up functions in netlify/functions

export async function handler(event, context) {
  const API_URL = 'https://official-joke-api.appspot.com/random_joke';

  try {
    const res = await fetch(API_URL);
    const body = await res.text();

    return {
      statusCode: res.status,
      headers: {
        'content-type': res.headers.get('content-type') || 'application/json',
        'access-control-allow-origin': '*', // tighten to your domain in prod
        'access-control-allow-methods': 'GET, OPTIONS',
      },
      body,
    };
  } catch (err) {
    return {
      statusCode: 500,
      headers: {
        'content-type': 'application/json',
        'access-control-allow-origin': '*',
      },
      body: JSON.stringify({ error: String(err) }),
    };
  }
}
