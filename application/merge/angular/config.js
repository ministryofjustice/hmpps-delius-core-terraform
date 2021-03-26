window['app_config'] = {
  api: {
    baseurl: '/merge/api'
  },
  authConfig: {
    clientId: 'MERGE-UI',
    dummyClientSecret: '',
    scope: 'merge-batch_job:manage merge-offender:view merge-app_settings:view merge-request:manage '+
        'merge-batch_job:view merge-unmerge:manage merge-app_settings:manage merge-request:view merge-errors:view '+
        'merge-app_admin:manage merge-batch_configuration:manage merge-merge:manage merge-errors:manage '+
        'merge-batch_configuration:view merge-merge:view merge-unmerge:view',
    resource: 'Merge',
    responseType: 'code',
    useHttpBasicAuth: true,
    oidc: false,
    requireHttps: false,
    loginUrl: '/umt/oauth/authorize',
    tokenEndpoint: '/umt/oauth/token',
    redirectUri: '/merge/ui/homepage'
  }
};
