-- sqlite3 /Users/victor/.local/share/opencode/opencode.db < scripts/opencode-metrics.sql

.headers on
.mode column
.nullvalue NULL

-- 1) uso por provider/modelo: sesiones, tokens, costo
WITH session_models AS (
  SELECT
    CASE
      WHEN model IS NULL OR trim(model) = '' THEN 'unknown'
      WHEN json_valid(model) THEN coalesce(json_extract(model, '$.providerID'), 'unknown')
      ELSE 'unknown'
    END AS provider,
    CASE
      WHEN model IS NULL OR trim(model) = '' THEN 'unknown'
      WHEN json_valid(model) THEN coalesce(json_extract(model, '$.id'), 'unknown')
      ELSE model
    END AS model_name,
    CASE
      WHEN model IS NOT NULL AND json_valid(model) THEN coalesce(json_extract(model, '$.variant'), 'none')
      ELSE 'none'
    END AS variant,
    cost,
    (
      coalesce(tokens_input, 0)
      + coalesce(tokens_output, 0)
      + coalesce(tokens_reasoning, 0)
      + coalesce(tokens_cache_read, 0)
      + coalesce(tokens_cache_write, 0)
    ) AS tokens
  FROM session
)
SELECT
  provider,
  model_name,
  variant,
  count(*) AS sessions,
  sum(tokens) AS tokens,
  round(sum(cost), 4) AS cost
FROM session_models
GROUP BY provider, model_name, variant
ORDER BY cost DESC, sessions DESC;

-- 2) duración aproximada de sesión (NO latencia real de modelo)
SELECT
  count(*) AS sessions,
  round(avg((time_updated - time_created) / 60000.0), 1) AS avg_session_span_minutes,
  round(min((time_updated - time_created) / 60000.0), 1) AS min_session_span_minutes,
  round(max((time_updated - time_created) / 60000.0), 1) AS max_session_span_minutes
FROM session;

SELECT
  id,
  title,
  round((time_updated - time_created) / 60000.0, 1) AS minutes
FROM session
ORDER BY (time_updated - time_created) DESC
LIMIT 10;

-- 3) señales heurísticas de error desde event
SELECT
  type,
  count(*) AS hits
FROM event
WHERE json_valid(data)
  AND (
    json_extract(data, '$.info.error') IS NOT NULL
    OR json_extract(data, '$.part.state.error') IS NOT NULL
    OR json_extract(data, '$.part.state.status') = 'error'
  )
GROUP BY type
ORDER BY hits DESC, type;

SELECT
  type,
  substr(data, 1, 200) AS sample
FROM event
WHERE json_valid(data)
  AND (
    json_extract(data, '$.info.error') IS NOT NULL
    OR json_extract(data, '$.part.state.error') IS NOT NULL
    OR json_extract(data, '$.part.state.status') = 'error'
  )
LIMIT 20;
