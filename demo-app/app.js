import Keycloak from 'https://esm.sh/keycloak-js@26.0.7';

const keycloak = new Keycloak({
  url: 'http://localhost:8080',
  realm: 'myapps',
  clientId: 'demo-app'
});

const loggedOut = document.getElementById('logged-out');
const loggedIn = document.getElementById('logged-in');
const errorEl = document.getElementById('error');
const userName = document.getElementById('user-name');
const userEmail = document.getElementById('user-email');

function showError(message) {
  errorEl.textContent = message;
  errorEl.classList.remove('hidden');
}

function renderUser() {
  const profile = keycloak.tokenParsed;
  userName.textContent = profile?.name || profile?.preferred_username || '—';
  userEmail.textContent = profile?.email || '—';
  loggedOut.classList.add('hidden');
  loggedIn.classList.remove('hidden');
  errorEl.classList.add('hidden');
}

function renderLoggedOut() {
  loggedIn.classList.add('hidden');
  loggedOut.classList.remove('hidden');
}

document.getElementById('login-btn').addEventListener('click', () => keycloak.login());

document.getElementById('logout-btn').addEventListener('click', () => {
  keycloak.logout({ redirectUri: window.location.origin + window.location.pathname });
});

try {
  const authenticated = await keycloak.init({
    onLoad: 'check-sso',
    pkceMethod: 'S256',
    checkLoginIframe: false
  });

  if (authenticated) {
    renderUser();
  } else {
    renderLoggedOut();
  }

  keycloak.onTokenExpired = () => {
    keycloak.updateToken(30).catch(() => keycloak.login());
  };
} catch (err) {
  showError(
    'Could not reach Keycloak at http://localhost:8080. Start RaksAppSSO: ./scripts/start.sh'
  );
  console.error(err);
}
