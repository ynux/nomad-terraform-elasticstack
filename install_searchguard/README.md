### Search Guard

Search Guard is a security product, a lot like Elasticsearch Security. If elastic hadn't [opened some of the security features, like TLS, in May 2019](https://www.elastic.co/blog/security-for-elasticsearch-is-now-free ) ... but they have.

They still got some cool stuff, like Proxy & PKI authentication, so check them out.

Note: I didn't try to break in or anything. I just installed and configured the product.

Let's go through their [install documentation](https://docs.search-guard.com/latest/search-guard-installation)

1. Install OpenJDK 7/8/11, Oracle JVM 7/8/11 or Amazon Corretto 8/11: OK, let's do this with ansible
2. Generate all required TLS certificates: There are many ways: With vault - we'd have to install that; or consul ... but as i run out of time, i'll use their demo certificates.
3. Shut down elasticsearch, and start with plugin - first build the docker image as in [Effective Elasticsearch Plugin Management with Docker](https://www.elastic.co/blog/elasticsearch-docker-plugin-management), see [docker directory](./docker)

https://downloads.search-guard.com/resources/certificates/certificates.zip

elasticsearch config - map it:
```
searchguard.ssl.transport.pemcert_filepath: esnode.pem
searchguard.ssl.transport.pemkey_filepath: esnode-key.pem
searchguard.ssl.transport.pemtrustedcas_filepath: root-ca.pem
searchguard.ssl.transport.enforce_hostname_verification: false
searchguard.ssl.http.enabled: true
searchguard.ssl.http.pemcert_filepath: esnode.pem
searchguard.ssl.http.pemkey_filepath: esnode-key.pem
searchguard.ssl.http.pemtrustedcas_filepath: root-ca.pem
searchguard.allow_unsafe_democertificates: true
searchguard.allow_default_init_sgindex: true
searchguard.authcz.admin_dn:
  - CN=kirk,OU=client,O=client,L=test,C=de

```
