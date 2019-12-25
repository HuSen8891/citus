CREATE SCHEMA upgrade_rebalance_strategy;
SET search_path TO upgrade_rebalance_strategy, public;

-- The following function signatures should always keep working
CREATE FUNCTION shard_cost_2(bigint)
    RETURNS float4 AS $$ SELECT 2.0::float4 $$ LANGUAGE sql;

CREATE FUNCTION capacity_high_worker_1(nodeidarg int)
    RETURNS real AS $$
    SELECT
        (CASE WHEN nodeport = 57637 THEN 1000 ELSE 1 END)::real
    FROM pg_dist_node where nodeid = nodeidarg
    $$ LANGUAGE sql;

CREATE FUNCTION only_worker_2(shardid bigint, nodeidarg int)
    RETURNS boolean AS $$
    SELECT
        (CASE WHEN nodeport = 57638 THEN TRUE ELSE FALSE END)
    FROM pg_dist_node where nodeid = nodeidarg
    $$ LANGUAGE sql;
ALTER TABLE pg_catalog.pg_dist_rebalance_strategy DISABLE TRIGGER pg_dist_rebalance_strategy_enterprise_check_trigger;

SELECT citus_add_rebalance_strategy(
        'custom_strategy',
        'shard_cost_2',
        'capacity_high_worker_1',
        'only_worker_2',
        0.5,
        0.2
    );
SELECT citus_set_default_rebalance_strategy('custom_strategy');
ALTER TABLE pg_catalog.pg_dist_rebalance_strategy ENABLE TRIGGER pg_dist_rebalance_strategy_enterprise_check_trigger;