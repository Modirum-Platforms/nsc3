#!/bin/bash

ORGANIZATIONS=$(
    docker exec main-postgres \
        psql -U nsc -d maindatabase -t -A \
        -c "SELECT id, name FROM organizationlist.organizations;"
)

echo "'OrgName','DaysToExpiry'"

while IFS="|" read -r ORG_ID ORG_NAME; do
    EXPR=$(
        docker exec main-postgres \
            psql -U nsc -d maindatabase -t -A \
            -c "SELECT
                    to_timestamp(valid_until_date / 1000)::date - current_date
                FROM \"$ORG_ID\".license
                WHERE enabled IS TRUE;"
    )

    if [[ -n "$EXPR" ]]; then
        echo "'$ORG_NAME','$EXPR'"
    fi
done <<< "$ORGANIZATIONS"
