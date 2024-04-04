package rules.enhanced_monitoring_for_rel_detailed_performance_metrics

__rego__metadoc__ := {
	"custom": {
		"controls": {
			"RelationalDB": [
				"RelationalDB_H"
			]
		},
		"severity": "Medium"
	},
	"description": "Document: Technology Engineering - Relational database - Best Practice - Version: 1.0",
	"id": "H",
	"title": "Enhanced monitoring shall be enabled for Relational database instances to collect detailed performance metrics.",
}

# Please write your OPA rule here
# Please write your OPA rule here
resource_type := "aws_rds_cluster_instance"

default allow = false

allow {
    input.performance_insights_enabled == true
}
