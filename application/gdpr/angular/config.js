window['app_config'] = {
  api: {
    baseurl: '/gdpr/api'
  },
  authConfig: {
    clientId: 'GDPR-UI',
    dummyClientSecret: '',
    scope: 'gdpr-retention:view gdpr-retention:review gdpr-retention:manage ' +
           'gdpr-deletions:manage gdpr-deletions:resolve gdpr-deletions:review gdpr-deletions:view ' +
           'gdpr-duplicates:manage gdpr-duplicates:review gdpr-duplicates:view ' +
           'gdpr-destruction:manage gdpr-destruction:view gdpr-destruction:search gdpr-destruction:download',
    resource: 'NDelius',
    responseType: 'code',
    oidc: false,
    requireHttps: false,
    loginUrl: '/umt/oauth/authorize',
    tokenEndpoint: '/umt/oauth/token',
    redirectUri: '/gdpr/ui/homepage'
  }
};
