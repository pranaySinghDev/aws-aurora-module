package rules.relational_database_instanc_ilability_automatic_failover

__rego__metadoc__ := {
	"custom": {
		"controls": {
			"RelationalDB": [
				"RelationalDB_E"
			]
		},
		"severity": "Medium"
	},
	"description": "Document: Technology Engineering - Relational database - Best Practice - Version: 1.0",
	"id": "E",
	"title": "Relational database instances and clusters shall be configured for multiple Availability Zones (Multi-AZ) to ensure high availability and automatic failover.",
}

# Please write your OPA rule here
resource_type := "aws_rds_cluster"

default allow = false

allow {
    input.availability_zones != ""
}

