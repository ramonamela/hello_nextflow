#!/usr/bin/env nextflow

process sayHello {
  input:
    val x
  output:
    stdout
  script:
    """
    echo '$x world!'

    echo "--- Checking for Azure Managed Identity ---"

    # Attempt to retrieve an access token from the Azure IMDS endpoint
    # This endpoint is available inside Azure Batch compute nodes
    IMDS_URL="http://169.254.169.254/metadata/identity/oauth2/token"
    IMDS_PARAMS="api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F"

    RESPONSE=\$(curl --silent --max-time 5 \
        --header "Metadata: true" \
        "\${IMDS_URL}?\${IMDS_PARAMS}" 2>&1) || true

    if echo "\$RESPONSE" | grep -q '"access_token"'; then
        echo "Managed Identity is available on this node."

        # Extract client_id from the token endpoint (system-assigned returns empty, user-assigned returns the id)
        CLIENT_ID=\$(echo "\$RESPONSE" | grep -o '"client_id":"[^"]*"' | cut -d'"' -f4)
        TOKEN_TYPE=\$(echo "\$RESPONSE" | grep -o '"token_type":"[^"]*"' | cut -d'"' -f4)
        EXPIRES_ON=\$(echo "\$RESPONSE" | grep -o '"expires_on":"[^"]*"' | cut -d'"' -f4)

        if [ -n "\$CLIENT_ID" ] && [ "\$CLIENT_ID" != "00000000-0000-0000-0000-000000000000" ]; then
            echo "  Type      : User-Assigned Managed Identity"
            echo "  Client ID : \$CLIENT_ID"
        else
            echo "  Type      : System-Assigned Managed Identity"
        fi

        echo "  Token Type: \$TOKEN_TYPE"
        echo "  Expires On: \$EXPIRES_ON (epoch)"
    elif echo "\$RESPONSE" | grep -q '"error"'; then
        ERROR=\$(echo "\$RESPONSE" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
        echo "Managed Identity endpoint responded with an error: \$ERROR"
        echo "  (The node may have IMDS access but no identity assigned)"
    else
        echo "No Managed Identity detected (IMDS endpoint unreachable or not an Azure node)."
        echo "  Raw response: \$RESPONSE"
    fi

    echo "-------------------------------------------"
    """
}

workflow {
  channel.of('Bonjour', 'Ciao', 'Hello', 'Hola') | sayHello | view
}
