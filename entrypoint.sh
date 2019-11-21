#!/bin/bash
if [[ $1 == startweb ]]; then
    endpoint=${2:-/}
    echo "Starting MeMe on $endpoint"
    echo "site.url = $endpoint" >> MemeSuite.properties
    cat MemeSuite.properties > "$CATALINA_HOME/webapps/meme_5.1.0/WEB-INF/classes/MemeSuite.properties"
    exec "$CATALINA_HOME/bin/catalina.sh" run
fi
exec "$@"
