package rules.relational_database_snapshots_backups_rest

__rego__metadoc__ := {
	"custom": {
		"controls": {
			"RelationalDB": [
				"RelationalDB_B"
			]
		},
		"severity": "Medium"
	},
	"description": "Document: Technology Engineering - Relational database - Best Practice - Version: 1.0",
	"id": "B",
	"title": "Relational database snapshots and backups shall be encrypted at rest.",
}

# Please write your OPA rule here

input_type = "tf"

resource_type = "aws_rds_cluster"

default allow = false

allow {
  input.storage_encrypted == true
}
