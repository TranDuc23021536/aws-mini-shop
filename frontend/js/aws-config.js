// AWS Cognito Configuration
const AWS_CONFIG = {
    region: 'ap-southeast-1',
    userPoolId: 'ap-southeast-1_O4GWbgM7y',
    userPoolClientId: '51q67e7j9g607g1trfckeqa99e'
};

if (typeof module !== 'undefined' && module.exports) {
    module.exports = AWS_CONFIG;
}
