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

    echo "=== IMDS Check (pure bash) ==="
    RESPONSE=""
    {
        exec 3<>/dev/tcp/169.254.169.254/80
        printf 'GET /metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%%3A%%2F%%2Fmanagement.azure.com%%2F HTTP/1.1\\r\\nHost: 169.254.169.254\\r\\nMetadata: true\\r\\nConnection: close\\r\\n\\r\\n' >&3
        RESPONSE=\$(timeout 5 cat <&3 2>&1)
        exec 3<&-
    } 2>/dev/null || true

    echo "Raw response: \$RESPONSE"

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
