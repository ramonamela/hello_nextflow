#!/usr/bin/env nextflow

process sayHello {
  input:
    val x
  output:
    stdout
  script:
    """
    echo '$x world!'

    echo "=== Environment ==="
    echo "Hostname: \$(hostname)"
    echo "User: \$(whoami)"
    echo "Shell: \$0"
    echo "PATH: \$PATH"

    echo "=== Installing curl ==="
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y -qq curl > /dev/null 2>&1
    echo "curl location: \$(which curl 2>&1 || echo 'NOT FOUND')"

    echo "=== IMDS Check ==="
    IMDS_URL="http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F"
    echo "URL: \$IMDS_URL"

    RESPONSE=\$(curl --silent --max-time 5 --header "Metadata: true" "\$IMDS_URL" 2>&1) || true
    EXIT_CODE=\$?
    echo "curl exit code: \$EXIT_CODE"
    echo "Response: \$RESPONSE"

    if echo "\$RESPONSE" | grep -q '"access_token"'; then
        echo "Managed Identity: AVAILABLE"
    else
        echo "Managed Identity: NOT AVAILABLE"
    fi
    echo "==================="
    """
}

workflow {
  channel.of('Bonjour', 'Ciao', 'Hello', 'Hola') | sayHello | view
}
